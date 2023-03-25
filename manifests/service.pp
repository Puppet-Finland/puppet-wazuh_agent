# @summary Wazuh agent service
#
# Manage Wazuh agent service
#
class wazuh_agent::service {
  assert_private()
  
  service { 'wazuh-agent.service':
    ensure => 'running',
    enable => true,
  }
}
