#!/usr/bin/env python3
import sys
import glob
import os
import re
from pathlib import PurePath
from typing import Callable, Iterable

try:
    from redact import redact
except ImportError:
    print('redact.py is unavailable, redaction will be disabled', file=sys.stderr)
    redact = lambda content: content

c_ext = frozenset(
    (
        '.js',
        '.ts',
        '.jsx',
        '.tsx',
        '.c',
        '.cpp',
        '.cc',
        '.h',
        '.hpp',
        '.cs',
        '.java',
        '.rs',
        '.go',
    )
)

exclude_patterns = {
    '.git',
    '.idea',
    '.vscode',
    'node_modules',
    '.venv',
    '__pycache__',
    '*.pyc',
    '*.pyo',
    '*.log',
    '*.lock',
    '*.old',
    '*.bak',
    'out.txt',
    '*.pem',
    '*.key',
    '*.crt',
    'id_rsa*',
    'id_ed25519*',
    'id_dsa*',
    'id_ecdsa*',
    '*.env',
    '*.env.*',
}

not_nt = os.name != 'nt'


def filter_block_comments(content, ext):
    """Filter out block comments based on file extension"""
    if ext in ('.py', '.pyx', '.pyi'):
        # Python triple quotes - only match when they start and end at line boundaries with only whitespace
        # Match """ or ''' that start at beginning of line (with optional whitespace) and end similarly
        content = re.sub(
            r'^\s*""".*?^\s*"""\s*$', '', content, flags=re.DOTALL | re.MULTILINE
        )
        content = re.sub(
            r"^\s*'''.*?^\s*'''\s*$", '', content, flags=re.DOTALL | re.MULTILINE
        )
    elif ext in c_ext:
        # C-style block comments
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)

    return content


type Content = tuple[str | None, ...]


def read_file(file: PurePath) -> Content:
    with open(file, encoding='utf-8') as fp:
        try:
            r = (fp.read(),)
        except UnicodeDecodeError:
            print('Binary file detected:', file, file=sys.stderr)
            r = (None, 'binary')

        if not_nt and os.access(file, os.X_OK):
            r += ('executable',)

    return r


def report_symlink(path: PurePath, to: str) -> Content:
    if not os.path.isabs(to):
        to = './' + to
    print('Symlink detected:', path, '->', to, file=sys.stderr)
    return (None, f'symlink to {to}')


def walk_dir(
    dir: PurePath, excluded: Callable[[PurePath], bool | Content]
) -> Iterable[tuple[PurePath, Content]]:
    files = []
    dirs = []
    for ent in os.scandir(dir):
        path = PurePath(ent.path)
        if (content := excluded(path)) is True:
            continue
        if ent.is_dir(follow_symlinks=False):
            dirs.append((path, content))
        elif ent.is_file(follow_symlinks=False):
            files.append((path, content))
        elif ent.is_symlink():
            files.append((path, report_symlink(path, os.readlink(path))))
        else:
            print('Skipping special file:', path, file=sys.stderr)

    for file, content in files:
        if not content:
            content = read_file(file)
        yield file, content

    for dir, content in dirs:
        if content:
            yield dir, content + ('directory',)
        else:
            yield from walk_dir(dir, excluded)


def retrieve(
    file: PurePath, excluded: Callable[[PurePath], bool | Content]
) -> Iterable[tuple[PurePath, Content]]:
    if os.path.islink(file):
        to = os.readlink(file)
        yield file, report_symlink(file, to)
    elif os.path.isdir(file):
        yield from walk_dir(file, excluded)
    else:
        yield file, read_file(file)


def main():
    sys.stdout.reconfigure(encoding='utf-8', newline='\n')

    args = iter(sys.argv[1:])
    prefix = None
    skip = None
    display_prefix = None
    display_skip = None
    omit_patterns = set()
    keep_comments = True
    dedup = None
    first = True
    for arg in args:
        cont = True

        if arg == '-p':
            prefix = PurePath(next(args))
        elif arg == '-s':
            skip = int(next(args))
        elif arg == '-P':
            display_prefix = PurePath(next(args))
        elif arg == '-S':
            display_skip = int(next(args))
        elif arg == '-c':
            os.chdir(next(args))
        elif arg == '-k':
            keep_comments = True
        elif arg == '-K':
            keep_comments = False
        elif arg == '-x':
            exclude_patterns.update(next(args).split(','))
        elif arg == '-o':
            omit_patterns.update(next(args).split(','))
        elif arg == '-d':
            dedup = set()
        else:
            cont = False

        if cont:
            continue

        print('Processing pattern:', arg, file=sys.stderr)

        files = glob.glob(arg, recursive=True)
        if not files:
            raise FileNotFoundError(arg)

        def excluded(path: PurePath) -> bool | Content:
            if dedup is not None:
                if path in dedup:
                    print('Deduplicated', path, file=sys.stderr)
                    return True

            for pattern in exclude_patterns:
                if path.match(pattern) or path.is_relative_to(pattern):
                    return True

            if dedup is not None:
                dedup.add(path)

            for pattern in omit_patterns:
                if path.match(pattern):
                    return (None, 'omitted')

            return False

        for file in files:
            path = PurePath(file)
            if (content := excluded(path)) is True:
                if file != arg:
                    continue
            elif content:
                items = ((path, content),)
            else:
                if skip:
                    path = PurePath(*path.parts[skip:])

                if prefix:
                    path = prefix / path

                items = retrieve(path, excluded)

            for path, content in items:
                d_path = path
                if display_skip:
                    d_path = PurePath(*d_path.parts[display_skip:])
                if display_prefix:
                    d_path = display_prefix / d_path
                s_path = str(d_path.as_posix())

                if first:
                    first = False
                else:
                    print()

                flags = content[1:]
                content = content[0]

                if content and not keep_comments:
                    ext = path.suffix

                    # Filter out block comments first
                    content = filter_block_comments(content, ext)

                    # Then filter out line comments
                    lines = content.split('\n')
                    content = '\n'.join(
                        line.rstrip()
                        for line in lines
                        if not line.strip().startswith('//' if ext in c_ext else '#')
                    )

                if content is not None and not (content := content.strip()):
                    flags += ('empty',)

                if flags:
                    print(f'## File: {s_path} ({", ".join(flags)})')
                else:
                    print(f'## File: {s_path}')

                if content:
                    content = redact(content)

                    print('\n```')
                    print(content)
                    print('```')


if __name__ == '__main__':
    main()
