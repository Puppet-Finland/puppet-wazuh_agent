#
# @summary Manage apt repo
#
# @api private
#
class wazuh_agent::install::apt {
  assert_private()

  # wazuh is already installed
  if $facts.dig('wazuh', 'version') {
    $_apt_dir =  '/etc/apt/sources.list.d'
    $_disable_cmd = "mv ${_apt_dir}/${wazuh_agent::repo_name}.list ${_apt_dir}/${wazuh_agent::repo_name}.list.offline"
    $_enable_cmd = "mv ${_apt_dir}/${wazuh_agent::repo_name}.list.offline ${_apt_dir}/${wazuh_agent::repo_name}.list"

    # version matches, disable repo with convergence
    if ($wazuh_agent::version ==  $facts.dig('wazuh', 'version').split('-')[0]) {
      exec { 'disable apt repo':
        path    => '/bin:/usr/bin',
        command => $_disable_cmd,
        onlyif  => "test -e ${_apt_dir}/${wazuh_agent::repo_name}.list",
      }
    }
    # version doesn't match
    else {
      exec { 'enable apt repo':
        path    => '/bin:/usr/bin',
        command => $_enable_cmd,
        onlyif  => "test -e ${_apt_dir}/${wazuh_agent::repo_name}.list.offline",
      }
    }
  }
  # this is a first time install
  else {
    if (versioncmp($facts['aio_agent_version'], '7.0.0') < 0) {
      package { 'lsb-release':
        ensure => 'present',
        before => Apt::Source[$wazuh_agent::repo_name],
      }
    }

    apt::key { 'wazuh_agent':
      id     => '0DCFCA5547B19D2A6099506096B3EE5F29111145',
      source => 'https://packages.wazuh.com/key/GPG-KEY-WAZUH',
      server => 'pgp.mit.edu',
      before => Apt::Source[$wazuh_agent::repo_name],
    }

    apt::source { $wazuh_agent::repo_name:
      ensure   => 'present',
      comment  => 'WAZUH repository created by Puppet',
      location => 'https://packages.wazuh.com/4.x/apt',
      release  => 'stable',
      repos    => 'main',
      include  => {
        'src' => false,
        'deb' => true,
      },
      before   => Package[$wazuh_agent::package_name],
    }
  }

  exec { 'update apt':
    path    => '/bin:/usr/bin',
    command => 'apt-get update',
    onlyif  => "test -e ${_apt_dir}/${wazuh_agent::repo_name}.list",
    before  => Package[$wazuh_agent::package_name],
  }
}
