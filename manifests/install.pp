#
# @summary Install Wazuh agent
#
class wazuh_agent::install {
  assert_private()

  case $facts['os']['family'] {
    'Debian': {
      contain '::wazuh_agent::install::apt'
    }
    'RedHat': {
      contain '::wazuh_agent::install::yum'
    }
    default: {
      fail('Unsupported OS or distribution.')
    }
  }
}
