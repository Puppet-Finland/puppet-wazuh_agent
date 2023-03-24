# frozen_string_literal: true

# @summary Simple check if Wazuh configuration file exist
#
# @author Petri Lammi petri.lammi@puppeteers.net
#
# @example
#
# notify { "So how is it? ${facts['ossec_conf_exists}": }
Facter.add('ossec_conf_exists') do
  setcode do
    File.exist?('/var/ossec/etc/ossec.conf')
  end
end
