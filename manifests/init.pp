# @summary Wazuh agent state managment
#
# Manage installation and changes to Wazuh agent
#
# @example
#   class { wazuh_agent:
#     server_name => 'mywazuh.example.com',
#     agent_name  => 'a_truly_funky_name',
#     password    => 'created_with_enigma',
#  }
class wazuh_agent (
  String $agent_name,
  String $server_name,
  Variant[Sensitive[String],String] $password,
  String $repo_name                                         = 'wazuh-puppet',
  String $package_name                                      = 'wazuh-agent',
  String $service_name                                      = 'wazuh-agent.service',
  Integer $last_ack_limit                                   = 300,
  Integer $keepalive_limit                                  = 300,
  String $version                                           = '4.3.5',
  String $revision                                          = '1',
  Boolean $debug                                            = false,
  Boolean $check_status                                     = true,
  Boolean $check_keepalive                                  = true,
  Boolean $check_last_ack                                   = false,
  Boolean $check_state_match                                = false,
  Boolean $check_name_match                                 = false,
  Boolean $check_match_id                                   = false,
  Optional[Variant[Sensitive[String],String]] $api_username = undef,
  Optional[Variant[Sensitive[String],String]] $api_password = undef,
  Optional[String] $api_host                                = undef,
  Optional[Integer] $api_port                               = undef,
) {
  contain 'wazuh_agent::install'
  contain 'wazuh_agent::config'
  contain 'wazuh_agent::service'

  Class['wazuh_agent::install']
  -> Class['wazuh_agent::config']
  -> Class['wazuh_agent::service']
}
