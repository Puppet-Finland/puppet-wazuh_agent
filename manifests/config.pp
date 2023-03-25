# @summary Wazuh agenc configuration
#
# Does not do much 
#
class wazuh_agent::config {
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

  #$auth_command = Sensitive("/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::server_name} -P ${wazuh_agent::password}")
  $auth_command = ("/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::server_name} -P ${wazuh_agent::password}")

  exec { 'agent-auth-linux':
    command   => $auth_command,
    unless    => "/bin/egrep -q ${wazuh_agent::agent_name} ${keys_file}",
    require   => [
      File['ossec.conf'],
      File[$keys_file],
    ],
    logoutput => true,
  }

  $local_options_file = '/var/ossec/etc/local_internal_options.conf'

  $presence = $wazuh_agent::debug ? {
    true     => 'present',
    false    => 'absent',
    'defaut'   => 'absent',
  }

  file { $local_options_file:
    ensure => $presence,
    owner  => 'root',
    group  => 'wazuh',
    mode   => '0640',
    source => 'puppet:///modules/wazuh_agent/local_internal_options.conf',
  }

  if $facts.dig('wazuh', 'status') and $facts.dig('wazuh', 'status') != 'connected' {

    notify { Class['wazuh_agent::service']:
      message => "Wazuh: agent ${wazuh_agent::agent_name} is not connected",
      require => Exec['agent-auth-linux'],
    }
  }
}
