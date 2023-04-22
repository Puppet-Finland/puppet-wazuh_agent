#
# @summary Install Wazuh agent
#
# @api private
#
class wazuh_agent::install {
  assert_private()

  case $facts['os']['family'] {
    'Debian': {
      contain 'wazuh_agent::install::apt'
    }
    'RedHat': {
      contain 'wazuh_agent::install::yum'
    }
    default: {
      fail('Unsupported OS or distribution.')
    }
  }

  package { $wazuh_agent::package_name:
    ensure => "${wazuh_agent::version}-${wazuh_agent::revision}",
    notify => Class['wazuh_agent::service'],
  }
}
