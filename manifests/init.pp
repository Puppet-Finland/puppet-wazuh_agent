# @summary 
#
# Manage installation of Wazuh agent with some insight to remote state
#
# @example
#   include wazuh_agent
#
class wazuh_agent (
  Stdlib::Host $server_name,
  String $password,
  String $api_username,
  String $api_password,
  Stdlib::Host $api_host,
  Integer $control_last_ack_since,
  Integer $control_last_keepalive_since,
  String $control_status,
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
