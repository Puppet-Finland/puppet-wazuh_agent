# @summary Wazuh agent configuration
#
# Configure and supervise agent  
#
class wazuh_agent::config {
  assert_private()

  file { 'ossec.conf':
    ensure    => 'file',
    path      => '/var/ossec/etc/ossec.conf',
    owner     => 'root',
    group     => 'wazuh',
    mode      => '0640',
    show_diff => true,
    content   => epp('wazuh_agent/ossec.conf.epp', {
        'management_server'      => $wazuh_agent::_management_server,
        'management_server_port' => $wazuh_agent::management_server_port,
    }),
  }

  $keys_file = '/var/ossec/etc/client.keys'

  file { $keys_file:
    owner => 'root',
    group => 'wazuh',
    mode  => '0640',
  }

  $local_options_file = '/var/ossec/etc/local_internal_options.conf'

  $presence = $wazuh_agent::debug ? {
    true     => 'present',
    false    => 'absent',
    'defaut' => 'absent',
  }

  file { $local_options_file:
    ensure => $presence,
    owner  => 'root',
    group  => 'wazuh',
    mode   => '0640',
    source => 'puppet:///modules/wazuh_agent/local_internal_options.conf',
  }

  if $facts.dig('wazuh') {
    if $wazuh_agent::check_status and ($facts.dig('wazuh', 'status') != 'connected') {
      $_supervise = true
    }
    elsif $wazuh_agent::check_keepalive and ($facts.dig('wazuh', 'last_keepalive') > $wazuh_agent::keepalive_limit) {
      $_supervice = true
    }
    elsif $wazuh_agent::check_last_ack and ($facts.dig('wazuh', 'last_ack') > $wazuh_agent::last_ack_limit) {
      $_supervise = true
    }
    else {
      $_supervise = false
    }
  }
  else {
    $_supervise = false
  }

  $auth_command = "/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::enrollment_server} -P ${wazuh_agent::enrollment_password}" # lint:ignore:140chars
  $_auth_command = String($wazuh_agent::enrollment_server_port) ? {
    /1515/      => $auth_command,
    /(\d{4,5})/ => sprintf('%s -p %s', $auth_command, $1),
    default     => $auth_command,
  }

  if $_supervise or $wazuh_agent::reauth {
    exec { 'reacting to a connection problem or a reauth request':
      command => '/bin/true',
      notify  => Exec['auth notify'],
    }
  }

  exec { 'auth':
    command   => Sensitive($_auth_command),
    unless    => "/bin/egrep -q \'${wazuh_agent::agent_name}\' ${keys_file}",
    tries     => 3,
    try_sleep => 5,
    require   => [
      File['ossec.conf'],
      File[$keys_file],
    ],
    logoutput => true,
    notify    => Class['wazuh_agent::service'],
  }

  exec { 'auth notify':
    command     => Sensitive($_auth_command),
    tries       => 3,
    try_sleep   => 5,
    refreshonly => true,
    logoutput   => true,
    notify      => Class['wazuh_agent::service'],
  }
}
