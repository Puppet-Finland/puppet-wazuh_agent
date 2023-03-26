# @summary Wazuh agent configuration
#
# 
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
        'server_name' => $wazuh_agent::server_name,
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

  if $_supervise {
    exec { 'reacting to agent having connection problems':
      command => '/bin/true',
      notify  => Exec['auth notify'],
    }
  }

  $_auth_command = Sensitive("/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::server_name} -P ${wazuh_agent::password}")
  
  exec { 'auth':
    command   => $_auth_command,
    unless    => "/bin/egrep -q \'${wazuh_agent::agent_name}\' ${keys_file}",
    tries     => 3,
    try_sleep => 3,
    require   => [
      File['ossec.conf'],
      File[$keys_file],
    ],
    logoutput => false,
  }

  exec { 'auth notify':
    command     => $_auth_command,
    tries       => 3,
    try_sleep   => 3,
    refreshonly => true,
    logoutput   => false,
    notify      => Class['wazuh_agent::service'],
  }
}
