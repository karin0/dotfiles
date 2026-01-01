import os
import re
import sys

R = lambda pattern: re.compile(pattern, re.IGNORECASE)

redact_patterns = [
    R(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    R(r'ssh-[\w]+ [A-Za-z0-9+/]+? [A-Za-z0-9+/@:]+'),
    R(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'),
]


def redact(content, patterns=None):
    if patterns is None:
        patterns = redact_patterns

    cnt = 0
    for pat in patterns:
        holder = '[redacted]'
        if isinstance(pat, tuple):
            holder = f'[redacted-{pat[1]}]'
            pat = pat[0]
        elif isinstance(pat, list):
            pat, holder = pat

        if isinstance(pat, str):
            cnt += content.count(pat)
            content = content.replace(pat, holder)
        else:

            def sub(m):
                # If capturing groups exist, redact only the first group
                groups = m.groups()
                if len(groups) > 1:
                    secret = m[1]
                    return m[0].replace(secret, holder)
                return holder

            content, delta = pat.subn(sub, content)
            cnt += delta

    if cnt:
        print(f'Redacted {cnt} items', file=sys.stderr)
    return content


def try_output_file(base: str, suffix: str) -> str:
    out_file = base + suffix
    if os.path.exists(out_file):
        import itertools

        for i in itertools.count(1):
            out_file = f'{base}.{i}{suffix}'
            if not os.path.exists(out_file):
                break
    return out_file


def main():
    arg = sys.argv[1]
    with open(arg, encoding='utf-8') as fp:
        content = fp.read()

    content = redact(content, redact_patterns)

    base, ext = os.path.splitext(arg)
    out_file = try_output_file(base + '.redacted', ext)

    with open(out_file, 'w', encoding='utf-8') as fp:
        fp.write(content)


if __name__ == '__main__':
    main()
