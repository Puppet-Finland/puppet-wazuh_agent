# @summary Wazuh agent service
#
# Manage Wazuh agent service
#
class wazuh_agent::service {
  service { 'wazuh_agent':
    ensure => 'running',
    enable => true,
  }
}
