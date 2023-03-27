# @summary Wazuh agent service
#
# Manage Wazuh agent service
#
class wazuh_agent::service {
  assert_private()

  service { $wazuh_agent::service_name:
    ensure     => $wazuh_agent::service_ensure,
    enable     => $wazuh_agent::service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
}
