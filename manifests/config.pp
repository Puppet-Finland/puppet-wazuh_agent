#
# @summary Configure and supervise Wazuh agent
#
# @api private
#
class wazuh_agent::config {
  assert_private()

  $keys_file = '/var/ossec/etc/client.keys'
  $local_options_file = '/var/ossec/etc/local_internal_options.conf'
  $ossec_conf_file = '/var/ossec/etc/ossec.conf'
  $authd_pass_file = '/var/ossec/etc/authd.pass'

  $local_options_presence = $wazuh_agent::debug ? {
    true    => 'present',
    false   => 'absent',
    default => 'absent',
  }

  file {
    default:
      ensure => 'file',
      owner  => 'root',
      group  => 'wazuh',
      mode   => '0640',
      notify => Class['wazuh_agent::service'],
      ;
    $keys_file:
      ;
    $local_options_file:
      ensure => $local_options_presence,
      source => 'puppet:///modules/wazuh_agent/local_internal_options.conf',
      ;
    $authd_pass_file:
      content => $wazuh_agent::enrollment_password,
      ;
  }

  concat { 'ossec.conf':
    path   => $ossec_conf_file,
    owner  => 'root',
    group  => 'wazuh',
    mode   => '0640',
    notify => Class['wazuh_agent::service'],
  }

  concat::fragment {
    'ossec.conf.header':
      target  => 'ossec.conf',
      order   => '00',
      content => epp('wazuh_agent/ossec.conf.header.epp', {
          'header_message' => '<!-- *** THIS FILE IS MANAGED BY PUPPET. ANY MANUAL CHANGES WILL BE OVERWRITTEN *** -->'
      }),
  }

  concat::fragment {
    'ossec.conf.main':
      target  => 'ossec.conf',
      order   => '01',
      content => epp('wazuh_agent/ossec.conf.main.epp', {
          'rootcheck_disabled'       => $wazuh_agent::rootcheck_disabled,
          'open_scap_disabled'       => $wazuh_agent::open_scap_disabled,
          'cis_cat_disabled'         => $wazuh_agent::cis_cat_disabled,
          'osquery_disabled'         => $wazuh_agent::osquery_disabled,
          'syscollector_disabled'    => $wazuh_agent::syscollector_disabled,
          'active_response_disabled' => $wazuh_agent::active_response_disabled,
          'management_server'        => $wazuh_agent::_management_server,
          'management_server_port'   => $wazuh_agent::management_server_port
      }),
  }

  if ($wazuh_agent::syscheck_disabled == 'no') {
    concat::fragment {
      'ossec.conf.syscheck':
        target  => 'ossec.conf',
        order   => '02',
        content => epp('wazuh_agent/ossec.conf.syscheck.epp', {
            'syscheck_disabled'                     => $wazuh_agent::syscheck_disabled,
            'syscheck_frequency'                    => $wazuh_agent::syscheck_frequency,
            'syscheck_scan_on_start'                => $wazuh_agent::syscheck_scan_on_start,
            'syscheck_synchronization_enabled'      => $wazuh_agent::syscheck_synchronization_enabled,
            'syscheck_synchronization_interval'     => $wazuh_agent::syscheck_synchronization_interval,
            'syscheck_synchronization_max_interval' => $wazuh_agent::syscheck_synchronization_max_interval,
            'syscheck_synchronization_max_eps'      => $wazuh_agent::syscheck_synchronization_max_eps,
            'syscheck_dirs_full'                    => $wazuh_agent::syscheck_dirs_full,
            'syscheck_text_files'                   => $wazuh_agent::syscheck_text_files,
            'syscheck_dirs_ignore'                  => $wazuh_agent::syscheck_dirs_ignore,
            'syscheck_types_ignore'                 => $wazuh_agent::syscheck_types_ignore,
            'syscheck_skip_nfs'                     => $wazuh_agent::syscheck_skip_nfs,
            'syscheck_skip_dev'                     => $wazuh_agent::syscheck_skip_dev,
            'syscheck_skip_proc'                    => $wazuh_agent::syscheck_skip_proc,
            'syscheck_skip_sys'                     => $wazuh_agent::syscheck_skip_sys,
            'syscheck_max_eps'                      => $wazuh_agent::syscheck_max_eps,
            'syscheck_nice_value'                   => $wazuh_agent::syscheck_nice_value
        }),
    }
  }

  concat::fragment {
    'ossec.conf.footer':
      target  => 'ossec.conf',
      order   => '20',
      content => epp('wazuh_agent/ossec.conf.footer.epp', {
          'footer_message' => '<!-- *** THIS FILE IS MANAGED BY PUPPET. ANY MANUAL CHANGES WILL BE OVERWRITTEN *** -->'
      }),
  }

  $auth_command = "/var/ossec/bin/agent-auth -A ${wazuh_agent::agent_name} -m ${wazuh_agent::enrollment_server} -P ${wazuh_agent::enrollment_password}" # lint:ignore:140chars
  $_auth_command = String($wazuh_agent::enrollment_server_port) ? {
    /1515/      => $auth_command,
    /(\d{4,5})/ => sprintf('%s -p %s', $auth_command, $1),
    default     => $auth_command,
  }

  exec { 'auth':
    command => Sensitive($_auth_command),
    unless  => "/bin/egrep -q \'${wazuh_agent::agent_name}\' ${keys_file}",
    require => [
      Concat['ossec.conf'],
      File[$keys_file],
    ],
    notify  => Class['wazuh_agent::service'],
  }

  if $facts.dig('wazuh', 'server') {
    if $wazuh_agent::check_status and ($facts.dig('wazuh', 'status') != 'connected') {
      warning('agent disconnected')
      exec { 'reauth':
        command   => Sensitive($_auth_command),
        logoutput => on_failure,
        notify    => Class['wazuh_agent::service'],
      }
    }
    elsif $wazuh_agent::check_keepalive and ($facts.dig('wazuh', 'last_keepalive') > $wazuh_agent::keepalive_limit) {
      warning('keepalive_limit exceeded')
      notify { 'refresh service':
        message => 'Keepalive limit exceeded. Refreshing Wazuh agent service.',
        notify  => Class['wazuh_agent::service'],
      }
    }
    elsif $wazuh_agent::check_last_ack and ($facts.dig('wazuh', 'last_ack') > $wazuh_agent::last_ack_limit) {
      warning('last_ack_limit exceeded')
      notify { 'refresh service':
        message => 'Last ack limit exceeded. Refreshing Wazuh agent service.',
        notify  => Class['wazuh_agent::service'],
      }
    }
  }
}
