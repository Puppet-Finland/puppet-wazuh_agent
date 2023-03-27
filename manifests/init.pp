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
  Integer $enrollment_port                                  = 1515,
  Integer $communication_port                               = 1514,
  String $repo_name                                         = 'wazuh-puppet',
  String $package_name                                      = 'wazuh-agent',
  String $service_name                                      = 'wazuh-agent.service',
  Integer $last_ack_limit                                   = 300,
  Integer $keepalive_limit                                  = 300,
  String $version                                           = '4.3.5',
  String $revision                                          = '1',
  Boolean $debug                                            = false,
  Boolesn $reauth                                           = false,
  Boolean $check_status                                     = true,
  Boolean $check_keepalive                                  = false,
  Boolean $check_last_ack                                   = false,
  Boolean $check_match_state                                = false,
  Boolean $check_match_name                                 = false,
  Boolean $check_match_id                                   = false,
  Optional[Variant[Sensitive[String],String]] $api_username = undef,
  Optional[Variant[Sensitive[String],String]] $api_password = undef,
  Optional[String] $api_host                                = undef,
  Optional[Integer] $api_port                               = undef,
) {

  # check api params
  if $check_match_state or $check_match_name or  $check_match_id {
    
    $api_params = {
      'param1' => $api_username,
      'param2' => $api_password,
      'param3' => $api_host,
      'param4' => $api_port,
    }
    
    $defined_params = $params.filter |$name, $value| {
      $value != undef
    }
    
    if ($defined_params.size > 0 and $defined_params.size < 4 and $defined_params.size != $params.size) {
      fail('None or all of the api parameters must be set')
    }
  }

  contain 'wazuh_agent::install'
  contain 'wazuh_agent::config'
  contain 'wazuh_agent::service'
  
  Class['wazuh_agent::install']
  -> Class['wazuh_agent::config']
  -> Class['wazuh_agent::service']
}
