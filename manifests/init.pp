# @summary 
#
# Manage installation of Wazuh agent with some insight to remote state
#
# @example
#   class { wazuh_agent
#
class wazuh_agent (
  String $server_name,
  String $agent_name,
  Variant[Sensitive[String],String] $password,
  Boolean $debug = true,
  Optional[String] $api_username = undef,
  Optional[String] $api_password = undef,
  Optional[String] $api_host = undef,
  Integer $control_last_ack_since = 300,
  Integer $control_last_keepalive_since = 300,
  String $control_status = 'disconnected',
  String $package_name = 'wazuh-agent',
  String $version = '4.3.5',
  String $revision = '1',
  Integer $api_port = 55000,
  Boolean $check_remote_state = false,

) {

  contain 'wazuh_agent::install'
  contain 'wazuh_agent::config'
  contain 'wazuh_agent::service'

  Class['wazuh_agent::install']
  -> Class['wazuh_agent::config']
  -> Class['wazuh_agent::service']
}
