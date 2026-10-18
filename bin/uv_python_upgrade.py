#!/usr/bin/env python3
'''Upgrade every uv-managed Python minor version to its latest patch, then uninstall the patches
that the minor-version links no longer point to.

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


def uv(*args: str) -> str:
    cmd = ('uv', 'python', *args)
    return subprocess.run(cmd, check=True, stdout=subprocess.PIPE, text=True).stdout


def main() -> None:
    uv('upgrade')
    root = Path(uv('dir').strip())
    links = {p.name: p.readlink().name for p in root.iterdir() if p.is_symlink()}
    installs: list[Install] = json.loads(
        uv('list', '--only-installed', '--managed-python', '--output-format', 'json')
    )
    if keys := obsolete(installs, links):
        uv('uninstall', *keys)


if __name__ == '__main__':
    main()
