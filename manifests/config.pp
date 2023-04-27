#
# @summary Configure and supervise Wazuh agent
#
# @api private
#
class wazuh_agent::config {
  assert_private()

  $keys_file = '/var/ossec/etc/client.keys'
  $local_options_file = '/var/ossec/etc/local_internal_options.conf'
  $ossec_conf_file = '/var/ossec/etc/ossec.conf'
  $authd_pass_file = '/var/ossec/etc/authd_pass'

  $local_options_presence = $wazuh_agent::debug ? {
    true    => 'present',
    false   => 'absent',
    default => 'absent',
  }

  file {
    default:
      ensure => 'file',
      owner  => 'root',
      group  => 'wazuh',
      mode   => '0640',
      notify => Class['wazuh_agent::service'],
      ;
    $keys_file:
      ;
    $local_options_file:
      ensure => $local_options_presence,
      source => 'puppet:///modules/wazuh_agent/local_internal_options.conf',
      ;
    $ossec_conf_file:
      content   => epp('wazuh_agent/ossec.conf.epp', {
          'rootcheck_disabled'       => $wazuh_agent::rootcheck_disabled,
          'open_scap_disabled'       => $wazuh_agent::open_scap_disabled,
          'cis_cat_disabled'         => $wazuh_agent::cis_cat_disabled,
          'osquery_disabled'         => $wazuh_agent::osquery_disabled,
          'syscollector_disabled'    => $wazuh_agent::syscollector_disabled,
          'syscheck_disabled'        => $wazuh_agent::syscheck_disabled,
          'active_response_disabled' => $wazuh_agent::active_response_disabled,
          'management_server'        => $wazuh_agent::_management_server,
          'management_server_port'   => $wazuh_agent::management_server_port,
      }),
      ;
    $authd_pass_file:
      content => $wazuh_agent::enrollment_password,
      ;
  }

  if $facts.dig('wazuh') {
    if $wazuh_agent::check_status and ($facts.dig('wazuh', 'status') != 'connected') {
      notify { 'agent disconnected': }
      $_supervise = true
    }
    elsif $wazuh_agent::check_keepalive and ($facts.dig('wazuh', 'last_keepalive') > $wazuh_agent::keepalive_limit) {
      notify { 'keepalive_limit exceeded': }
      $_supervise = true
    }
    elsif $wazuh_agent::check_last_ack and ($facts.dig('wazuh', 'last_ack') > $wazuh_agent::last_ack_limit) {
      notify { 'last_act_limit exceeded': }
      $_supervise = true
    }
    elsif $facts.dig('wazuh', 'name') != $wazuh_agent::agent_name {
      notify { 'agent name changed': }
      $_reauth = true
    }
    elsif $facts.dig('wazuh', 'server') != $wazuh_agent::_management_server {
      notify { 'management server changed': }
      $_reauth = true
    }
  }
  else {
    notify { 'no reaction or reauthentication needed': }
    $_supervise = false
    $_reauth = false
  }

  $auth_command = "/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::enrollment_server} -P ${wazuh_agent::enrollment_password}" # lint:ignore:140chars
  $_auth_command = String($wazuh_agent::enrollment_server_port) ? {
    /1515/      => $auth_command,
    /(\d{4,5})/ => sprintf('%s -p %s', $auth_command, $1),
    default     => $auth_command,
  }

  if $_supervise or $_reauth {
    exec { 'reacting to a connection problem or need to reauthenticate':
      command => '/bin/true',
      notify  => Exec['auth notify'],
    }
  }

  exec { 'auth':
    command => Sensitive($_auth_command),
    unless  => "/bin/egrep -q \'${wazuh_agent::agent_name}\' ${keys_file}",
    require => [
      File[$ossec_conf_file],
      File[$keys_file],
    ],
    notify  => Class['wazuh_agent::service'],
  }

  exec { 'auth notify':
    command     => Sensitive($_auth_command),
    refreshonly => true,
    logoutput   => true,
    notify      => Class['wazuh_agent::service'],
  }
}
