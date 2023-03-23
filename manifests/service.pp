# @summary Wazuh agent service
#
# Manage Wazuh agent service
#
class wazuh_agent::service {
  service { 'wazuh-agent.service':
    ensure => 'running',
    enable => true,
  }
}
