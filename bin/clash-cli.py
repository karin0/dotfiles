#!/usr/bin/env python3

import sys
import argparse
import os
import traceback
import json
import platform
import hashlib
import subprocess
import gzip
import shutil
import secrets
import logging

from io import BytesIO
from zipfile import ZipFile
from typing import TextIO, Iterable
from urllib.request import urlopen, Request

OVERLAY_DIR = 'overlay'
RELEASE_FILE = 'release.json'
LOCAL_PROFILE_FILE = 'profile.yaml'
REMOTE_PROFILE_FILE = 'remote.yaml'

CLASH_DATA_DIR = 'data'
CLASH_DEFAULT_UI_DIR = 'ui'
CLASH_DEFAULT_UI_URL = (
    'https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip'
)
CLASH_CONFIG_FILE = 'config.yaml'

MIHOMO_PREFIX = 'mihomo'
RELEASES_URL = 'https://api.github.com/repos/MetaCubeX/mihomo/releases/latest'

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) Clash.Meta/1 clash-cli/0'
}

parser = argparse.ArgumentParser()
parser.add_argument(
    '-o', '--output-file', type=argparse.FileType('w', encoding='utf-8')
)
parser.add_argument('-u', '--update', action='store_true', help='Update UI and core')
parser.add_argument(
    '-e',
    '--escalate',
    action='store_true',
    help='Escalate privileges for TUN on Windows',
)
parser.add_argument('-i', '--interactive', action='store_true')
parser.add_argument('-d', '--debug', action='store_true')
parser.add_argument('run_dir', nargs='?')
args = parser.parse_args()


def get_logger():
    level = logging.DEBUG if args.debug else logging.INFO
    logger = logging.getLogger('clash-cli')
    logger.setLevel(level)
    handler = logging.StreamHandler()
    handler.setLevel(level)
    formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger


log = get_logger()


def iter_yaml(lines: Iterable[str]) -> Iterable[tuple[str | None, str]]:
    # A naive implementation. Overlays must contain only key: value pairs without nesting.
    for line in lines:
        line = line.rstrip()
        if line:
            if line[0].isalpha():
                p = line.find(':')
                if p > 0 and (v := line[p + 1 :].strip()):
                    yield line[:p], v
                else:
                    yield None, line
            else:
                yield None, line


def load_remote_cache(url: str) -> str:
    try:
        with open(REMOTE_PROFILE_FILE, encoding='utf-8') as f:
            header = f.readline().strip()
            if header == f'# {url}':
                return f.read()
            else:
                log.warning('Profile mismatch: %s', header)
    except FileNotFoundError:
        pass


def load_remote(url: str) -> str:
    if not args.update and (sub := load_remote_cache(url)):
        return sub

    log.info('Fetching subscription from %s', url)

    try:
        with urlopen(Request(url, headers=HEADERS)) as f:
            sub = f.read().decode('utf-8')
        log.debug('Retrieved %d bytes', len(sub))

        with open(REMOTE_PROFILE_FILE, 'w', encoding='utf-8') as f:
            f.write(f'# {url}\n')
            f.write(sub)
    except Exception as e:
        if sub := load_remote_cache(url):
            log.exception('Failed to fetch subscription: %s', e)
        else:
            raise RuntimeError('Failed to fetch subscription') from e

    return sub


def get_cfg(out: TextIO, default_ui: str | None) -> dict[str, str]:
    def load_overlay(cfg: dict, file: str):
        with open(file, encoding='utf-8') as f:
            for k, v in iter_yaml(f):
                if k:
                    cfg[k] = v

    preset = {}

    try:
        load_overlay(preset, LOCAL_PROFILE_FILE)
    except FileNotFoundError:
        pass

    overlay = {}
    try:
        overlays = os.listdir(OVERLAY_DIR)
    except FileNotFoundError:
        pass
    else:
        overlays.sort()
        for file in overlays:
            if file.endswith('.yaml'):
                log.info('Applying overlay: %s', file)
                load_overlay(overlay, f'{OVERLAY_DIR}/{file}')

    profile = overlay.pop('cli-profile', None) or preset.pop(
        'cli-profile', LOCAL_PROFILE_FILE
    )
    if profile == LOCAL_PROFILE_FILE:
        # LOCAL_PROFILE_FILE is the profile, rather than an overlay.
        preset = overlay
    else:
        if preset:
            log.info('Applied overlay %s', LOCAL_PROFILE_FILE)
        preset.update(overlay)

    log.info('Using profile: %s', profile)

    if profile.startswith('https://') or profile.startswith('http://'):
        sub = load_remote(profile)
    else:
        with open(profile, encoding='utf-8') as fp:
            sub = fp.read()

    for k, v in preset.items():
        out.write(f'{k}: {v}\n')
    out.write('\n')

    if sub:
        for k, v in iter_yaml(sub.splitlines(True)):
            if k:
                if k in preset:
                    out.write(f'# {k}: {v}\n')
                else:
                    out.write(f'{k}: {v}\n')
                    preset[k] = v
            else:
                out.write(f'{v}\n')

    if default_ui and 'external-ui' not in preset:
        preset['external-ui'] = default_ui
        out.write(f'external-ui: {default_ui}\n')

    if 'secret' not in preset:
        preset['secret'] = secret = secrets.token_hex(16)
        log.warning('Generated random secret: %s', secret)
        out.write(f'secret: {secret}\n')

    return preset


def update_core(existing_core: str | None = None):
    """Download the latest Mihomo core from GitHub releases."""

    log.info('Downloading latest Mihomo core...')

    # Get the latest release
    with urlopen(Request(RELEASES_URL, headers=HEADERS)) as f:
        data = f.read()

    with open(RELEASE_FILE, 'wb') as fp:
        fp.write(data)

    release = json.loads(data)

    tag_name = release['tag_name']
    log.info('Latest tag: %s', tag_name)
    assets = [(asset['name'], asset) for asset in release['assets']]
    assets.sort(reverse=True)

    os_name = platform.system().lower()
    machine = platform.machine().lower()

    match machine:
        case 'amd64' | 'x86_64':
            arch = 'amd64'
        case 'i386' | 'i686' | 'x86':
            arch = 'i386'
        case 'arm64' | 'aarch64':
            arch = 'arm64'
        case 'arm' | 'armv7l':
            arch = 'armv7'
        case _:
            raise ValueError(f'Unknown architecture: {machine}')

    # Find matching asset
    url = None
    existing_stem = existing_core and os.path.splitext(existing_core)[0]
    for file, asset in assets:
        stem, ext = os.path.splitext(file)
        if existing_stem == stem:
            log.info('Core up to date: %s', file)
            return existing_core

        if file.startswith(MIHOMO_PREFIX) and os_name in file and arch in file:
            url = asset['browser_download_url']
            digest = asset['digest']
            break

    if not url:
        raise FileNotFoundError(f'No core found for platform {os_name}-{arch}')

    if existing_core:
        log.debug('Updating from %s', existing_core)

    if not (ext == '.zip' or ext == '.gz'):
        raise ValueError(f'Unsupported archive format: {file}')

    out_file = (stem + '.exe') if os.name == 'nt' else stem
    log.info('Downloading: %s', file)

    with urlopen(Request(url, headers=HEADERS)) as f:
        data = f.read()

    log.debug('Downloaded %d bytes', len(data))

    checksum = digest.removeprefix('sha256:')
    if checksum == digest:
        log.error('Unknown digest: %s', digest)
    else:
        sha256 = hashlib.sha256()
        sha256.update(data)
        if sha256.hexdigest() == checksum:
            log.debug('sha256: %s', checksum)
        else:
            log.error('Checksum mismatch! %s != %s', sha256.hexdigest(), checksum)
            return

    if ext == '.zip':
        with ZipFile(BytesIO(data)) as zf:
            names = zf.namelist()
            log.debug(
                'Zip: %s, %s, %s, %s',
                zf.comment,
                zf.compression,
                zf.compresslevel,
                names,
            )
            if len(names) != 1:
                raise ValueError('Unexpected zip content')

            zf.extract(names[0])
            if names[0] != out_file:
                os.rename(names[0], out_file)
    else:
        with open(out_file, 'wb') as f:
            f.write(gzip.decompress(data))

    if os.name != 'nt':
        os.chmod(out_file, 0o755)

    log.debug('Saved as: %s', out_file)

    if existing_core:
        os.remove(existing_core)
        log.debug('Removed: %s', existing_core)

    return out_file


def find_core():
    core_ext = '.exe' if os.name == 'nt' else ''

    # Look for existing core
    core = None
    for entry in os.scandir('.'):
        if entry.is_file():
            stem, ext = os.path.splitext(entry.name)
            if stem.startswith(MIHOMO_PREFIX) and ext == core_ext:
                core = entry.name
                break

    if args.update or not core:
        try:
            core = update_core(core)
        except Exception as e:
            if core:
                log.exception('Failed to update core: %s', e)
            else:
                log.error('Failed to update core: %s', e)
                raise RuntimeError('No core available') from e

    log.info('Using core: %s', core)
    return './' + core


def prepare_ui(cfg: dict[str, str], root: str):
    url = cfg.get('external-ui-url', CLASH_DEFAULT_UI_URL)
    dir_name = cfg.get('external-ui', CLASH_DEFAULT_UI_DIR)

    # dir_name merged from remote subscription is untrusted
    if '/' in dir_name or '\\' in dir_name:
        raise ValueError(f'Invalid UI directory: {dir_name}')

    log.debug('UI: %s %s', url, dir_name)
    if not args.update and os.path.isfile(os.path.join(root, dir_name, 'index.html')):
        return

    try:
        download_ui(url, os.path.join(root, dir_name))
    except Exception as e:
        log.exception('Failed to download UI: %s', e)


def download_ui(url: str, dir_path: str):
    log.info('Downloading UI from %s', url)
    with urlopen(Request(url, headers=HEADERS)) as fp:
        data = fp.read()

    log.debug('Downloaded %d bytes', len(data))

    with ZipFile(BytesIO(data)) as zf:
        log.debug(
            'Zip: %s, %s, %s, %d files',
            zf.comment,
            zf.compression,
            zf.compresslevel,
            len(zf.namelist()),
        )
        shutil.rmtree(dir_path, ignore_errors=True)

        # Detect common parent
        if common_dir := os.path.commonpath(zf.namelist()):
            log.debug('Stripping common parent: %s', common_dir)
            tmp_dir = dir_path + '-tmp'
            try:
                os.mkdir(tmp_dir)
            except FileExistsError:
                shutil.rmtree(tmp_dir)
                os.mkdir(tmp_dir)

            zf.extractall(tmp_dir)
            shutil.move(os.path.join(tmp_dir, common_dir), dir_path)
            shutil.rmtree(tmp_dir)
        else:
            os.mkdir(dir_path)
            zf.extractall(dir_path)


def nt_escalate():
    import ctypes

    try:
        if ctypes.windll.shell32.IsUserAnAdmin():
            return
        log.info('Not admin, escalating ...')
    except RuntimeError as e:
        log.error('IsUserAnAdmin: %s', e)

    if not args.interactive:
        sys.argv.append('-i')

    cmd = ' '.join(f'"{arg}"' if ' ' in arg else arg for arg in sys.argv)

    # Rerun with elevated privileges
    r = ctypes.windll.shell32.ShellExecuteW(
        None,
        'runas',
        sys.executable,
        cmd,
        None,  # Working directory (None = current)
        1,  # Show window
    )

    # ShellExecuteW returns > 32 on success
    log.debug('ShellExecuteW: %s', r)
    if r > 32:
        sys.exit(0)
    else:
        log.error('Failed to elevate, TUN might not work (%s)', r)


def main():
    log.debug('%s %s %s', sys.executable, __file__, sys.argv)

    if args.output_file:
        get_cfg(args.output_file, None)
        return

    if args.escalate and os.name == 'nt':
        nt_escalate()

    if args.run_dir:
        os.chdir(args.run_dir)

    core_file = find_core()

    os.makedirs(CLASH_DATA_DIR, exist_ok=True)
    cfg_file = CLASH_DATA_DIR + '/' + CLASH_CONFIG_FILE

    with open(cfg_file, 'w', encoding='utf-8') as fp:
        cfg = get_cfg(fp, CLASH_DEFAULT_UI_DIR)

    log.debug('Config: %s', cfg)
    prepare_ui(cfg, CLASH_DATA_DIR)

    if api := cfg.get('external-controller'):
        log.info('Open http://%s/ui for UI', api)

    if os.name == 'nt':
        subprocess.check_call([core_file, '-d', CLASH_DATA_DIR])
    else:
        os.execv(core_file, [core_file, '-d', CLASH_DATA_DIR])


if __name__ == '__main__':
    if args.interactive:
        try:
            main()
        except BaseException as e:
            # Catch Ctrl-C to preserve logs in separate (escalated) window
            traceback.print_exc()
        finally:
            input('Press any key to quit ...')
    else:
        main()
