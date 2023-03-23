# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include wazuh_agent::config
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
      'password'    => $wazuh_agent::password,
    }),
  }

  $keys_file = '/var/ossec/bin/client.keys'

  file { $keys_file:
    owner => 'root',
    group => 'wazuh',
    mode  => '6400',
  }

  $auth_command = "/var/ossec/bin/agent-auth -A ${wazuh_agent::name} -m ${wazuh_agent::server_name} -P ${wazuh_agent::password}"

  exec { 'agent-auth-linux':
    command => $auth_command,
    unless  => "/bin/egrep -q -w ${wazuh_agent::name} ${keys_file}",
    require => [
      File['ossec.conf'],
      File[$keys_file],
    ],
  }
}
