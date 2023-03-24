# frozen_string_literal: true

# @summary Simple check if Wazuh configuration file exist
#
# @author Petri Lammi petri.lammi@puppeteers.net
#
# @example
#
# notify { $facts['wazuh']['state']['status']:
Facter.add('ossec_conf_exists') do
  setcode do
    File.exist?('/var/ossec/etc/ossec.conf')
  end
end
