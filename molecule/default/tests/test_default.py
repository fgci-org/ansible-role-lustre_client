import os
import pytest

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
