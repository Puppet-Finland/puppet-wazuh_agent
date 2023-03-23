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
        server => 'pgp.mit.edu'
      }

      apt::source { 'wazuh_agent':
        ensure   => present,
        comment  => 'WAZUH repository',
        location => 'https://packages.wazuh.com/4.x/apt',
        release  => 'stable',
        repos    => 'main',
        include  => {
          'src' => false,
          'deb' => true,
        },
        require  => Apt::Key['wazuh_agent'],
      }

      package { $wauzh_agent::package_name:
        ensure  => "${wauzh_agent::version}-${wauzh_agent::revision}",
        require => [
          Apt::Source['wazuh_agent'],
          Class['apt::update'],
        ],
      }
    }
    default: {
      fail('Unsupported distribution.')
    }
  }
}
