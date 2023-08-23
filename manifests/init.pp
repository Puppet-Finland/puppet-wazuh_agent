# @summary Manage Wazuh agent
#
# @example Basic usage:
#   class { wazuh_agent:
#     enrollment_server   => 'mywazuh.example.com',
#     enrollment_password => 'created_with_enigma',
#   }
#
# @see https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html?highlight=enrollment#enrollment
#
# @see data/common.yaml for default values.
#
# @param version
#   Wazuh agent version. Default 4.3.5.
#   
# @param revision
#   Wazuh agent revision. Default '-1'
#   
# @param repo_name
#   Wazuh repository name. Default is 'wazuh-puppet'
#
# @param agent_name
#   An arbitrary string for agent name. Default is facts[fqdn].
#   
# @param enrollment_server 
#   The enrollment server name.
#
# @param enrollment_server_port
#   the enrollment server port. Default 1515.
#
# @param enrollment_password
#   The password to register and enroll the agent.
#
# @param management_server
#   The management server name.
#
# @param management_server_port
#   The management server port.
#
# @param package_name
#   The package name. Default is 'wazuh-agent'.
#
# @param service_name
#   The service name. Default is 'wazuh-agent.service'.
#
# @param service_ensure
#   The service state propety. Default is 'running'.
#
# @param service_enable
#   The service enable propety. Default is true.
#
# @param last_ack_limit
#   Time in seconds since last_ack after which
#   to try restarting and reconnecting. Default is 300.
#
# @param keepalive_limit
#   Time in seconds since last keepalive after which
#   to try restarting and reconnecting. Default is 300.
#
# @param debug
#   Enable some agent side debugging. Default is false.
#
# @param check_status
#   Whether to monitor agent connection status. Default is true.
#
# @param check_keepalive
#   Whether to monitor last keepalive. Default is false.
#
# @param check_last_ack
#   Whether to monitor time since last_ack. Default is false.
#
# @param rootcheck_disabled
#   Whether to disable rootcheck. Default yes.
#
# @param open_scap_disabled
#   Whether to disable rootcheck. Default yes.
#
# @param cis_cat_disabled
#   Whether to disable cis-cat. Default yes. 
#
# @param osquery_disabled
#  Whether to disable osquery. Default yes.
#
# @param syscollector_disabled
#   Whether to disable syscollector. Default yes.
#
# @param active_response_disabled
#   Whether to disable active-response. Default yes.
#
# @param ensure_absent
#   Whether to completely remove the agent. Default false (surprise).
#
# @param syscheck_disabled
#    Whether to disable syscheck. Default yes.
#
# @param syscheck_frequency
#    Frequency that the syscheck will be run. Given in seconds. Check data for defaults.
#
# @param syscheck_scan_on_start
#    Start scan on agent start. Default yes.
#
# @param syscheck_synchronization_enabled
#    whether there will be periodic inventory synchronizations. Default yes.
#
# @param syscheck_synchronization_interval
#   Initial number of seconds between every inventory synchronization. Check data for defaults.
#
# @param syscheck_synchronization_max_interval
#    maximum number of seconds between every inventory synchronization. Check data for defaults.
#
# @param syscheck_synchronization_max_eps
#    maximum synchronization message throughput. Check data for defaults.
#
# @param syscheck_dirs_full
#    Array of direcories to "check_all". Cehck data for Defaults..
#
# @param syscheck_dirs_ignore
#    List of files or directories to be ignored. Check data for defaults.
#
# @param syscheck_types_ignore
#    List of regex patterns to ignore. Check data for defaults.
#
# @param syscheck_skip_nfs
#    Specifies if syscheck should skip network mounted filesystems. Default yes.   
#
# @param syscheck_skip_dev
#   Specifies if syscheck should skip /dev directory. Default yes.
#
# @param syscheck_skip_proc
#    Specifies if syscheck should skip /proc directory. Default yes.   
#
# @param syscheck_skip_sys
#    Specifies if syscheck should skip /sys directory. Default yes.   
#
# @param syscheck_max_eps
#     Maximum event reporting throughput. Check data for defaults
#
# @param syscheck_nice_value
#    Sets the nice value for Syscheck process. Default 10.
class wazuh_agent (
  String[1] $repo_name,
  String[1] $version,
  String[1] $revision,
  String[1] $agent_name,
  String[1] $enrollment_server,
  Integer $enrollment_server_port,
  Variant[Sensitive[String[1]],String[1]] $enrollment_password,
  Optional[String[1]] $management_server,
  Integer $management_server_port,
  String[1] $package_name,
  String[1] $service_name,
  String[1] $service_ensure,
  Boolean $service_enable,
  Integer $last_ack_limit,
  Integer $keepalive_limit,
  Boolean $debug,
  Boolean $check_status,
  Boolean $check_keepalive,
  Boolean $check_last_ack,
  Enum['yes', 'no'] $rootcheck_disabled,
  Enum['yes', 'no'] $open_scap_disabled,
  Enum['yes', 'no'] $cis_cat_disabled,
  Enum['yes', 'no'] $osquery_disabled,
  Enum['yes', 'no'] $syscollector_disabled,
  Enum['yes', 'no'] $active_response_disabled,
  Boolean $ensure_absent,
  # syscheck
  Enum['yes', 'no'] $syscheck_disabled,
  Integer[0] $syscheck_frequency,
  Enum['yes', 'no'] $syscheck_scan_on_start,
  Enum['yes', 'no'] $syscheck_synchronization_enabled,
  Integer[0] $syscheck_synchronization_interval,
  Intege[0] $syscheck_synchronization_max_interval,
  Integer[0] $syscheck_synchronization_max_eps,
  Array[String, 1] $syscheck_dirs_full,
  Array[String, 1] $syscheck_dirs_ignore,
  Array[String, 1] $syscheck_types_ignore,
  Enum['yes', 'no'] $syscheck_skip_nfs,
  Enum['yes', 'no'] $syscheck_skip_dev,
  Enum['yes', 'no'] $syscheck_skip_proc,
  Enum['yes', 'no'] $syscheck_skip_sys,
  Integer[0] $syscheck_max_eps,
  Integer[0] $syscheck_nice_value,
) {
  if $ensure_absent {
    contain 'wazuh_agent::ensure_absent'
  }
  else {
    # if management_server is not set, assume single node setup
    if $management_server == undef {
      $_management_server = $enrollment_server
    }
    else {
      $_management_server = $management_server
    }

    contain 'wazuh_agent::install'
    contain 'wazuh_agent::config'
    contain 'wazuh_agent::service'

    Class['wazuh_agent::install']
    -> Class['wazuh_agent::config']
    -> Class['wazuh_agent::service']
  }
}
