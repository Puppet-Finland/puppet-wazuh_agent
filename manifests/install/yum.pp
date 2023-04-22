#
# @summary Manage yum repo
#
# @api private
# 
class wazuh_agent::install::yum {
  assert_private()

  # wazuh is already installed
  if $facts.dig('wazuh', 'version') {
    # version matches, disable repo with convergence 
    if ($wazuh_agent::version ==  $facts.dig('wazuh', 'version').split('-')[0]) {
      yumrepo { $wazuh_agent::repo_name:
        enabled  => false,
      }
    }
    # version doesn't match, enable repo
    else {
      yumrepo { $wazuh_agent::repo_name:
        enabled  => true,
      }
    }
  }
  # this is a first time install
  else {
    $gpgkey = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'

    if ($facts['os']['release']['major'] == '5') {
      $baseurl = 'https://packages.wazuh.com/4.x/yum/5/'
    }
    else {
      $baseurl = 'https://packages.wazuh.com/4.x/yum/'
    }

    yumrepo { $wazuh_agent::repo_name:
      descr    => 'WAZUH repository created by Puppet',
      enabled  => true,
      gpgcheck => 1,
      gpgkey   => $gpgkey,
      baseurl  => $baseurl,
      before   => Package[$wazuh_agent::package_name],
    }
  }
}
