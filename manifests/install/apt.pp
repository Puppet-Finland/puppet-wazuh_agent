#
# @summary Apt repo
#
class wazuh_agent::install::apt {
  # wazuh is already installed, disable repo
  if $facts.dig('wazuh', 'version') {
    if ($wazuh_agent::version ==  $facts.dig('wazuh', 'version').split('-')[0]) {
      $_apt_dir =  '/etc/apt/sources.list.d'
      $_command = "mv ${_apt_dir}/${wazuh_agent::repo_name}.list ${_apt_dir}/${wazuh_agent::repo_name}.list.offline"
      exec { 'disable apt repo':
        path    => '/bin:/usr/bin',
        command => $_command,
        onlyif  => "test -e ${_apt_dir}/${wazuh_agent::repo_name}.list",
      }
    }
  }
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

    package { $wazuh_agent::package_name:
      ensure  => "${wazuh_agent::version}-${wazuh_agent::revision}",
      require => [
        Apt::Source[$wazuh_agent::repo_name],
        Class['apt::update'],
      ],
      notify  => Class['wazuh_agent::service'],
    }
  }
}
