# @summary
#
# Install Wazuh agent
#
class wazuh_agent::install {
  assert_private()

  case $facts['os']['name'] {
    'Ubuntu': {
      apt::key { 'wazuh_agent':
        id     => '0DCFCA5547B19D2A6099506096B3EE5F29111145',
        source => 'https://packages.wazuh.com/key/GPG-KEY-WAZUH',
        server => 'pgp.mit.edu',
      }

      apt::source { $wazuh_agent::repo_name:
        ensure   => present,
        comment  => 'WAZUH repository created by Puppet',
        location => 'https://packages.wazuh.com/4.x/apt',
        release  => 'stable',
        repos    => 'main',
        include  => {
          'src' => false,
          'deb' => true,
        },
        require  => Apt::Key['wazuh_agent'],
      }

      package { $wazuh_agent::package_name:
        ensure  => "${wazuh_agent::version}-${wazuh_agent::revision}",
        require => [
          Apt::Source[$wazuh_agent::repo_name],
          Class['apt::update'],
        ],
        notify  => Class['wazuh_agent::service'],
      }

      # Wazuh people recommend removing repo file, but
      # That would lead to hacky manifests with puppet
      # Instad we *hope* that pinning and marking work
      # together reliably
      apt::pin { $wazuh_agent::package_name:
        packages => $wazuh_agent::package_name,
        version  => "${wazuh_agent::version}-${wazuh_agent::revision}",
        priority => 1001,
        require  => Package[$wazuh_agent::package_name],
      }

      apt::mark { $wazuh_agent::package_name:
        setting => 'hold',
        require => Package[$wazuh_agent::package_name],
      }
    }

    default: {
      fail('Unsupported distribution.')
    }
  }
}
