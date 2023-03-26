# @summary Wazuh agent service
#
# Manage Wazuh agent service
#
class wazuh_agent::service {
  assert_private()
  
  service { $wazuh_agent::service_name:
    ensure => 'running',
    enable => true,
  }
}
