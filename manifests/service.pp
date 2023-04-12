# @summary Wazuh agent service
#
# Manage Wazuh agent service
#
class wazuh_agent::service {
  assert_private()

  service { $wazuh_agent::service_name:
    ensure     => $wazuh_agent::service_ensure,
    manifest   => '/usr/lib/systemd/system/wazuh-agent.service',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
