#!/usr/bin/env python3
'''Upgrade every uv-managed Python minor version to its latest patch, then uninstall the patches
that the minor-version links no longer point to and no process runs. The patches that processes
still run stay installed and their processes are listed; a run after restarting them uninstalls
the patches.

uv links each minor version (cpython-3.14-linux-x86_64-gnu) to its newest patch, and venvs
created through that link follow it across upgrades. A venv whose pyvenv.cfg names a patch
directory directly breaks when that patch is uninstalled, until uv sync recreates it.'''

import json
import subprocess

from collections.abc import Iterable, Mapping
from pathlib import Path
from typing import TypedDict


class Install(TypedDict):
    key: str
    version: str
    version_parts: dict[str, int]


def minor_link(install: Install) -> str:
    parts = install['version_parts']
    minor = f'{parts['major']}.{parts['minor']}'
    return install['key'].replace(f'-{install['version']}', f'-{minor}', 1)


def obsolete(installs: Iterable[Install], links: Mapping[str, str]) -> tuple[str, ...]:
    '''Keys of the installs whose minor-version link exists and points to another install.

    `links` maps each link name in the install directory to the name of its target.'''
    return tuple(i['key'] for i in installs if links.get(minor_link(i), i['key']) != i['key'])


def running(proc: Path, root: Path, keys: Iterable[str]) -> tuple[tuple[str, int, str, str], ...]:
    '''(install key, pid, cgroup leaf, command line) of each process whose executable lies in the
    install directory under `root` named by one of `keys`.'''
    keys = frozenset(keys)
    found: list[tuple[str, int, str, str]] = []
    for p in proc.iterdir():
        if not p.name.isdigit():
            continue
        try:
            exe = (p / 'exe').readlink()
            if not (exe.is_relative_to(root) and (key := exe.relative_to(root).parts[0]) in keys):
                continue
            unit = (p / 'cgroup').read_text().strip().rsplit('/', 1)[-1]
            cmd = (p / 'cmdline').read_bytes().replace(b'\0', b' ').decode().strip()
        # Kernel threads, processes of other users, and processes that exit during the scan.
        except OSError:
            continue
        found.append((key, int(p.name), unit, cmd))
    return tuple(sorted(found))


def uv(*args: str) -> str:
    cmd = ('uv', 'python', *args)
    return subprocess.run(cmd, check=True, stdout=subprocess.PIPE, text=True).stdout


def main() -> None:
    uv('upgrade')
    root = Path(uv('dir').strip()).resolve()
    links = {p.name: p.readlink().name for p in root.iterdir() if p.is_symlink()}
    installs: list[Install] = json.loads(
        uv('list', '--only-installed', '--managed-python', '--output-format', 'json')
    )
    keys = obsolete(installs, links)
    procs = running(Path('/proc'), root, keys)
    busy = {key for key, *_ in procs}
    if idle := tuple(k for k in keys if k not in busy):
        uv('uninstall', *idle)
    if procs:
        print('Kept installed until these processes restart:')
        for key, pid, unit, cmd in procs:
            print(f'{key}\t{unit}\t{pid}\t{cmd}')


if __name__ == '__main__':
    main()
