#
# @summary Completely remove wazuh agent from the system
#
# @api private
#
class wazuh_agent::ensure_absent {
  assert_private()

  if $facts.dig('wazuh', 'version') {
    # ensure service is down
    service { $wazuh_agent::service_name:
      ensure    => stopped,
      manifest  => '/usr/lib/systemd/system/wazuh-agent.service',
      hasstatus => true,
      notify    => Package[$wazuh_agent::package_name],
    }

    # ensure package is removed
    package { $wazuh_agent::package_name:
      ensure => purged,
    }

    case $facts['os']['family'] {
      'Debian': {
        apt::key { 'wazuh_agent':
          ensure => absent,
          id     => '0DCFCA5547B19D2A6099506096B3EE5F29111145',
          source => 'https://packages.wazuh.com/key/GPG-KEY-WAZUH',
          server => 'pgp.mit.edu',
        }

        $_apt_dir =  '/etc/apt/sources.list.d'
        file {
          default:
            ensure => absent,
            ;
          "${_apt_dir}/${wazuh_agent::repo_name}.list":
            ;
          "${_apt_dir}/${wazuh_agent::repo_name}.list.offline":
            ;
        }
      }
      'RedHat': {
        yumrepo { $wazuh_agent::repo_name:
          ensure => absent,
        }
      }
      default: {
        fail('Unsupported OS or distribution.')
      }
    }

    # remove ossec directory
    file { '/var/ossec':
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }
}
