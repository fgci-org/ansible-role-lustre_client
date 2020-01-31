import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')
url = "https://downloads.whamcloud.com/public/lustre/latest-release/el7/client"


def test_lustre_repo(host):
    repo = host.file('/etc/yum.repos.d/lustre-client.repo')
    assert repo.exists
    assert repo.contains(r'\[lustre-client\]')
    assert repo.contains(f"baseurl = {url}")


def test_lustre_package(host):
    assert host.package('lustre-client').is_installed


def test_lustre_mounts(host):
    fstab = '/etc/fstab'
    assert host.file(fstab).contains(
        r'/default lustre _netdev,noatime,localflock,noauto '
    )
    assert host.file(fstab).contains(
        r'/merge lustre _netdev,noatime,localflock,noauto,my_opt '
    )
    assert host.file(fstab).contains(r'/my lustre my_opt ')


def test_lustre_module_options(host):
    modfile = '/etc/modprobe.d/lustre.conf'
    assert host.file(modfile).contains(
        r"networks='tcp2(eth0)' routes='my route' auto_down=1"
    )