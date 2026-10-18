'''Checks for which installs uv_python_upgrade.py uninstalls. Run with python3
uv_python_upgrade_test.py.'''

from uv_python_upgrade import Install, obsolete


def install(key: str, version: str) -> Install:
    major, minor, *_ = version.split('.')
    return {
        'key': key,
        'version': version,
        'version_parts': {'major': int(major), 'minor': int(minor)},
    }


OLD = install('cpython-3.14.2-linux-x86_64-gnu', '3.14.2')
NEW = install('cpython-3.14.8-linux-x86_64-gnu', '3.14.8')
LINKS = {'cpython-3.14-linux-x86_64-gnu': NEW['key']}


def test_superseded_patch_is_removed() -> None:
    assert obsolete((OLD, NEW), LINKS) == (OLD['key'],)


def test_variant_follows_its_own_link() -> None:
    ft_old = install('cpython-3.14.2+freethreaded-linux-x86_64-gnu', '3.14.2')
    ft_new = install('cpython-3.14.8+freethreaded-linux-x86_64-gnu', '3.14.8')
    links = {**LINKS, 'cpython-3.14+freethreaded-linux-x86_64-gnu': ft_new['key']}
    assert obsolete((OLD, NEW, ft_old, ft_new), links) == (OLD['key'], ft_old['key'])


def test_install_without_link_is_kept() -> None:
    pre = install('cpython-3.16.0a1-linux-x86_64-gnu', '3.16.0a1')
    assert obsolete((NEW, pre), LINKS) == ()


if __name__ == '__main__':
    test_superseded_patch_is_removed()
    test_variant_follows_its_own_link()
    test_install_without_link_is_kept()
