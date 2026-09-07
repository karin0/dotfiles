import hashlib
import itertools
import json
import os
import re
import secrets
import sys

from collections.abc import Callable, Sequence
from functools import cache, partial
from pathlib import Path
from typing import NamedTuple

R: Callable[[str], re.Pattern[str]] = partial(re.compile, flags=re.IGNORECASE)

UUID = r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'

type Matcher = re.Pattern[str] | str
type Json = str | int | float | bool | dict[str, Json] | list[Json] | None


class Label(NamedTuple):
    '''Names the kind of secret a pattern finds, so its placeholder can say so.'''

    pattern: Matcher
    label: str


class Rewrite(NamedTuple):
    '''Replaces what a pattern finds with this text, in place of a placeholder.'''

    pattern: Matcher
    text: str


type Entry = Matcher | Label | Rewrite

_HOLDER = re.compile(r'\[redacted(?:-\w+)?:[0-9a-f]{6}\]')

_NOTICE = (
    'This tool output carries {n} redactions. A [redacted:<digest>] placeholder stands for one '
    'literal value, equal digests mean equal values, and writing a placeholder into a file '
    'replaces the value it stands for.'
)

# Stripped from live tool output as well as from shared documents, so an entry here has to be a
# value the agent reading that output never needs to act on or write back into a file.
hook_patterns: list[Entry] = [
    R(r'ssh-[\w]+ [A-Za-z0-9+/]+? [A-Za-z0-9+/@:]+'),
    R(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
]

# Stripped only when preparing a document to share, where a broken path or identifier costs nothing.
document_patterns: list[Entry] = [
    R(UUID),
]

# A digest lets the reader tell two redacted values apart and recognise the same value across
# separate reads. It is salted because redacted text is exactly what leaves the machine, and an
# unsalted six-hex digest of an address, a name or an email is recoverable by enumeration.
_SALT_FILE = Path(os.environ.get('XDG_STATE_HOME') or Path.home() / '.local/state') / 'redact.salt'


@cache
def _salt() -> bytes:
    try:
        return _SALT_FILE.read_bytes()
    except FileNotFoundError:
        pass

    _SALT_FILE.parent.mkdir(parents=True, exist_ok=True)
    try:
        fd = os.open(_SALT_FILE, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    except FileExistsError:
        # Another process won the race; its salt is the one that keeps digests stable.
        return _SALT_FILE.read_bytes()

    value = secrets.token_bytes(16)
    with os.fdopen(fd, 'wb') as fp:
        fp.write(value)
    return value


def _holder(label: str, value: str) -> str:
    return f'[redacted{label}:{hashlib.sha256(_salt() + value.encode()).hexdigest()[:6]}]'


class _Substituter:
    '''Rewrites the secret a match found, and counts the matches it really rewrote.'''

    def __init__(self, label: str, text: str | None) -> None:
        self.label = label
        self.text = text
        self.count = 0

    def __call__(self, m: re.Match[str]) -> str:
        out = self.text if self.text is not None else self.holder(m)
        if out != m[0]:
            self.count += 1
        return out

    def holder(self, m: re.Match[str]) -> str:
        # A capturing group marks the secret inside a wider match, so the surrounding text that
        # names the field survives. A value built from alternatives offers several groups, one of
        # which took part.
        group = next((i for i in range(1, m.re.groups + 1) if m[i] is not None), 0)
        if not group:
            return _holder(self.label, m[0])
        # Redacting an output twice has to leave the same placeholders, so that a digest keeps
        # naming the value it replaced however many times the text passes through.
        value: str = m[group]
        if _HOLDER.fullmatch(value):
            return m[0]
        start, end = m.span(group)
        offset = m.start()
        return m[0][: start - offset] + _holder(self.label, value) + m[0][end - offset :]


def redact_n(content: str, patterns: Sequence[Entry] | None = None) -> tuple[str, int]:
    if patterns is None:
        patterns = hook_patterns + document_patterns

    cnt = 0
    for entry in patterns:
        match entry:
            case Label(pattern, name):
                pat, label, text = pattern, f'-{name}', None
            case Rewrite(pattern, replacement):
                pat, label, text = pattern, '', replacement
            case _:
                pat, label, text = entry, '', None

        if isinstance(pat, str):
            cnt += content.count(pat)
            content = content.replace(pat, _holder(label, pat) if text is None else text)
        else:
            sub = _Substituter(label, text)
            content = pat.sub(sub, content)
            cnt += sub.count

    return content, cnt


def redact(content: str, patterns: Sequence[Entry] | None = None) -> str:
    return redact_n(content, patterns)[0]


def redact_deep(value: Json, patterns: Sequence[Entry]) -> tuple[Json, int]:
    match value:
        case str():
            return redact_n(value, patterns)
        case dict():
            mapping: dict[str, Json] = {}
            cnt = 0
            for k, v in value.items():
                mapping[k], delta = redact_deep(v, patterns)
                cnt += delta
            return mapping, cnt
        case list():
            items: list[Json] = []
            cnt = 0
            for v in value:
                item, delta = redact_deep(v, patterns)
                items.append(item)
                cnt += delta
            return items, cnt
        case _:
            return value, 0


def try_output_file(base: str, suffix: str) -> str:
    out_file = base + suffix
    if os.path.exists(out_file):
        for i in itertools.count(1):
            out_file = f'{base}.{i}{suffix}'
            if not os.path.exists(out_file):
                break
    return out_file


def hook_main() -> None:
    payload = json.load(sys.stdin)
    original = payload['tool_response']
    updated, cnt = redact_deep(original, hook_patterns)
    if not cnt:
        return

    json.dump(
        {
            'hookSpecificOutput': {
                'hookEventName': payload['hook_event_name'],
                'updatedToolOutput': updated,
                'additionalContext': _NOTICE.format(n=cnt),
            }
        },
        sys.stdout,
    )


def main() -> None:
    args = sys.argv[1:]
    if '--hook' in args:
        hook_main()
        return

    patterns = None
    if '--hook-like' in args:
        args.remove('--hook-like')
        patterns = hook_patterns

    (arg,) = args
    with open(arg, encoding='utf-8') as fp:
        content = fp.read()

    content, cnt = redact_n(content, patterns)

    base, ext = os.path.splitext(arg)
    out_file = try_output_file(base + '.redacted', ext)
    with open(out_file, 'w', encoding='utf-8') as fp:
        fp.write(content)

    print(f'{out_file}: {cnt} redactions', file=sys.stderr)


if __name__ == '__main__':
    main()
