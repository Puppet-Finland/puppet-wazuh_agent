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
  String $server_name,
  String $agent_name,
  Variant[Sensitive[String],String] $password,
  Integer $control_last_ack_since       = 300,
  Integer $control_last_keepalive_since = 300,
  String $package_name                  = 'wazuh-agent',
  String $version                       = '4.3.5',
  String $revision                      = '1',
  Boolean $debug                        = false,
  Boolean $check_state                  = true,
  Boolean $check_state_match            = false,
  Boolean $check_name_match             = false,
  Boolean $check_id_match               = false,
  Optional[Integer] $api_port           = 55000,

) {
  contain 'wazuh_agent::install'
  contain 'wazuh_agent::config'
  contain 'wazuh_agent::service'

  Class['wazuh_agent::install']
  -> Class['wazuh_agent::config']
  -> Class['wazuh_agent::service']
}
