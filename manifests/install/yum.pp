#
# @summary Wazuh agent yum install
#
class wazuh_agent::install::yum {
  assert_private()

  # wazuh is already installed, disable repo (by convergence)

  if $facts.dig('wazuh', 'version') {
    if ($wazuh_agent::version ==  $facts.dig('wazuh', 'version').split('-')[0]) {
      $_yum_dir =  '/etc/yum.repos.d'
      $_command = "mv ${_yum_dir}/${wazuh_agent::repo_name}.list ${_yum_dir}/${wazuh_agent::repo_name}.list.offline"
      exec { 'disable yum repo':
        path    => '/bin:/usr/bin',
        command => $_command,
        onlyif  => "test -e ${_yum_dir}/${wazuh_agent::repo_name}.list",
      }
    }
  }
  else {
    $gpgkey = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'

    if ($facts['os']['release']['major'] == '5') {
      $baseurl = 'https://packages.wazuh.com/4.x/yum/5/'
    }
    else {
      $baseurl = 'https://packages.wazuh.com/4.x/yum/'
    }
  }

  yumrepo { $wazuh_agent::repo_name:
    descr    => 'WAZUH repository created by Puppet',
    enabled  => true,
    gpgcheck => 1,
    gpgkey   => $gpgkey,
    baseurl  => $baseurl,
    before   => Package[$wazuh_agent::package_name],
  }

  package { $wazuh_agent::package_name:
    ensure => "${wazuh_agent::version}-${wazuh_agent::revision}",
    notify => Class['wazuh_agent::service'],
  }
}
