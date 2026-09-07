'''Checks for the substitution engine in redact.py: which part of a match is replaced, what a
placeholder promises, and the hook payload. Run with python3 redact_test.py.'''

import json
import subprocess
import sys

from collections.abc import Sequence
from pathlib import Path

from redact import Entry, Json, Label, R, Rewrite, redact_deep, redact_n

GROUPED: Sequence[Entry] = [R(r'secret: (\S+)')]
# One alternative takes part per match, and the engine has to find whichever one did.
ALTERNATIVES: Sequence[Entry] = [R(r'''secret: (?:"([^"]+)"|(\S+))''')]


def one(content: str, patterns: Sequence[Entry] = GROUPED) -> tuple[str, int]:
    return redact_n(content, patterns)


def test_group_marks_the_secret() -> None:
    out, cnt = one('secret: hunter2 stays here')
    assert cnt == 1
    assert out.startswith('secret: [redacted:')
    assert out.endswith('] stays here')


def test_whole_match_goes_without_a_group() -> None:
    out, cnt = one('call 555-0100 now', [R(r'555-\d{4}')])
    assert cnt == 1
    assert '555-0100' not in out
    assert out.startswith('call ')
    assert out.endswith(' now')


def test_alternatives_pick_the_group_that_took_part() -> None:
    for content in ('secret: "pass phrase"', 'secret: bare'):
        out, cnt = one(content, ALTERNATIVES)
        assert cnt == 1, content
        assert '[redacted:' in out, content

    quoted, _ = one('secret: "pass phrase"', ALTERNATIVES)
    assert quoted.startswith('secret: "')
    assert quoted.endswith('"')


def test_placeholder_identity() -> None:
    same, cnt = one('secret: alpha\nsecret: alpha')
    assert cnt == 2
    assert len(set(same.splitlines())) == 1

    apart, _ = one('secret: alpha\nsecret: beta')
    assert len(set(apart.splitlines())) == 2


def test_idempotent() -> None:
    once, _ = one('secret: alpha')
    twice, cnt = one(once)
    assert (twice, cnt) == (once, 0)

    deep, cnt = one(once, ALTERNATIVES)
    assert (deep, cnt) == (once, 0)


def test_label_reaches_the_placeholder() -> None:
    out, cnt = one('host is example.org', [Label('example.org', 'domain')])
    assert cnt == 1
    assert '[redacted-domain:' in out


def test_rewrite_is_taken_verbatim() -> None:
    out, cnt = one('drop me\nkeep me\n', [Rewrite(R(r'drop me\n'), '')])
    assert (out, cnt) == ('keep me\n', 1)


def test_literal_counts_every_occurrence() -> None:
    out, cnt = one('a.example a.example b', ['a.example'])
    assert cnt == 2
    assert 'a.example' not in out
    assert len(set(out.split()[:2])) == 1


def test_deep_counts_every_string() -> None:
    payload: Json = {'a': 'secret: alpha', 'b': ['secret: beta', 7], 'c': None}
    out, cnt = redact_deep(payload, GROUPED)
    assert cnt == 2
    assert isinstance(out, dict)

    nested = out['b']
    assert isinstance(nested, list)
    assert nested[1] == 7
    assert out['c'] is None
    assert 'alpha' not in json.dumps(out)
    assert 'beta' not in json.dumps(out)


def test_hook_payload() -> None:
    '''Rewrites the response in place and says so, and stays silent when nothing matched.'''
    script = str(Path(__file__).with_name('redact.py'))
    payload: dict[str, object] = {
        'hook_event_name': 'PostToolUse',
        'tool_response': {'stdout': 'mail someone@example.com', 'stderr': ''},
    }

    def run() -> str:
        return subprocess.run(
            [sys.executable, script, '--hook'],
            input=json.dumps(payload),
            capture_output=True,
            text=True,
            check=True,
            timeout=30,
        ).stdout

    out = json.loads(run())['hookSpecificOutput']
    assert out['hookEventName'] == 'PostToolUse'
    assert 'someone@example.com' not in out['updatedToolOutput']['stdout']
    assert '1 redactions' in out['additionalContext']

    payload['tool_response'] = {'stdout': 'nothing here', 'stderr': ''}
    assert run() == ''


if __name__ == '__main__':
    tests = [v for k, v in sorted(globals().items()) if k.startswith('test_')]
    for test in tests:
        test()
    print(f'{len(tests)} passed')
