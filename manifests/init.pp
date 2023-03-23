# @summary 
#
# Manage installation of Wazuh agent with some insight to remote state
#
# @example
#   include wazuh_agent
#
class wazuh_agent (
  Stdlib::Host $server_name,
  String $agent_name,
  String $password,
  Optional[String] $api_username = undef,
  Optional[String] $api_password = undef,
  Optional[Stdlib::Host] $api_host = undef,
  Integer $control_last_ack_since = 300,
  Integer $control_last_keepalive_since = 300,
  String $control_status = 'disconnected',
  String $package_name = 'wazuh_agent',
  String $version = '4.3.5',
  String $revision = '1',
  Stdlib::Port $api_port = 55000,
  Boolean $check_remote_state = false,

) {

  contain 'wazuh_agent::install'
  contain 'wazuh_agent::config'
  contain 'wazuh_agent::service'

  Class['wazuh_agent::install']
  -> Class['wazuh_agent::config']
  -> Class['wazuh_agent::service']
}
