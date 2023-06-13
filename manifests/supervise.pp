#
# @summary supervise Wazuh agent
#
# @api private
#
class wazuh_agent::supervise {
  assert_private()

  if $facts.dig('wazuh', 'server') {
    if $wazuh_agent::check_status and ($facts.dig('wazuh', 'status') != 'connected') {
      notify { 'agent disconnected': }
      $_reauth = true
      $_supervise = true
    }
    elsif $wazuh_agent::check_keepalive and ($facts.dig('wazuh', 'last_keepalive') > $wazuh_agent::keepalive_limit) {
      notify { 'keepalive_limit exceeded': }
      $_supervise = true
    }
    elsif $wazuh_agent::check_last_ack and ($facts.dig('wazuh', 'last_ack') > $wazuh_agent::last_ack_limit) {
      notify { 'last_ack_limit exceeded': }
      $_supervise = true
    }
    elsif $facts.dig('wazuh', 'name') != $wazuh_agent::agent_name {
      notify { 'agent name changed': }
      $_reauth = true
      $_supervise = true
    }
    elsif $facts.dig('wazuh', 'server') != $wazuh_agent::_management_server {
      notify { 'management server changed': }
      $_reauth = true
      $_supervise = true
    }
  }
  else {
    $_supervise = false
    $_reauth = false
  }

  $auth_command = "/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::enrollment_server} -P ${wazuh_agent::enrollment_password}" # lint:ignore:140chars
  $_auth_command = String($wazuh_agent::enrollment_server_port) ? {
    /1515/      => $auth_command,
    /(\d{4,5})/ => sprintf('%s -p %s', $auth_command, $1),
    default     => $auth_command,
  }

  if $_reauth {
    exec { 'reauth':
      command   => Sensitive($_auth_command),
      logoutput => true,
      notify    => Class['wazuh_agent::service'],
    }
  }

  if $_supervise {
    exec { 'restart wazuh':
      path      => ['/bin', '/usr/bin'],
      command   => "systemctl restart ${wazuh_agent::service_name}",
      logoutput => true,
    }
  }
}
