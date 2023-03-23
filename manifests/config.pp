# @summary Wazuh agenc configuration
#
# Does not do much 
#
class wazuh_agent::config {

  file { 'ossec.conf':
    ensure    => 'file',
    path      => '/var/ossec/etc/ossec.conf',
    owner     => 'root',
    group     => 'root',
    mode      => '0750',
    show_diff => true,
    content   => epp('wazuh_agent/ossec.conf.epp', {
      'server_name' => $wazuh_agent::server_name,
    }),
  }

  $keys_file = '/var/ossec/etc/client.keys'

  file { $keys_file:
    owner => 'root',
    group => 'wazuh',
    mode  => '6400',
  }

  $auth_command = Sensitive("/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::server_name} -P ${wazuh_agent::password}")

  exec { 'agent-auth-linux':
    command => $auth_command,
    unless  => "/bin/egrep -q ${wazuh_agent::agent_name} ${keys_file}",
    require => [
      File['ossec.conf'],
      File[$keys_file],
    ],
    logoutput => false,
  }
  
  $local_options_file = '/var/ossec/etc/local_internal_options.conf'
  
  if $wazuh_agent::debug {
    
    file { $local_options_file:
      owner  => 'root',
      group  => 'wazuh',
      mode   => '6400',
      source => 'puppet:///modules/wazuh_agent/local_internal_options.conf',
    }
  }
}
