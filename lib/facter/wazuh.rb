# frozen_string_literal: true

require 'open3'

Facter.add(:wazuh) do
  confine kernel: 'Linux'
  confine ossec_conf_exists: true

  setcode do
    @key_file = '/var/ossec/etc/client.keys'
    @state_file = '/var/ossec/var/run/wazuh-agentd.state'
    @ossec_file = '/var/ossec/etc/ossec.conf'

    wazuh_hash = {}

    def wazuh_agent_data(index)
      if File.exist?(@key_file)
        File.read(@key_file).split[index]
      else
        ''
      end
    end

    def wazuh_version
      cmd = case Facter.value('osfamily')
            when 'RedHat'
              '/bin/rpm -q wazuh-agent --queryformat "%{VERSION}"'
            when 'Debian'
              '/usr/bin/dpkg-query -W -f="\\${Version}" wazuh-agent'
            end
      stdout, _stderr, status = Open3.capture3(cmd)
      if status.success?
        stdout.strip
      else
        ''
      end
    end

    def get_ossec_conf_value(key)
      if File.exist?(@ossec_file)
        match = nil
        IO.foreach(@ossec_file) do |line|
          if line =~ %r{^.*<#{key}>(.*)</#{key}>}
            match = Regexp.last_match(1).strip
            break
          end
        end
        match || ''
      else
        ''
      end
    end

    def wazuh_server_name
      get_ossec_conf_value('address') || ''
    end

    if File.exist?(@state_file)
      File.foreach(@state_file) do |line|
        key, value = line.strip.split('=')
        case key
        when 'status'
          wazuh_hash[:status] = value.delete("'")
        when 'last_keepalive'
          # calculate seconds since last keepalive
          seconds_since_keepalive = value.delete("'").empty? ? 0 : (Time.now - Time.parse(value)).to_i
          wazuh_hash[:last_keepalive] = seconds_since_keepalive
        when 'last_ack'
          # calculate seconds since last ack
          seconds_since_ack = value.delete("'").empty? ? 0 : (Time.now - Time.parse(value)).to_i
          wazuh_hash[:last_ack] = seconds_since_ack
          break
        end
      end
    end

    wazuh_hash[:id] = wazuh_agent_data(0)
    wazuh_hash[:name] = wazuh_agent_data(1)
    wazuh_hash[:ip] = wazuh_agent_data(2)
    wazuh_hash[:server] = wazuh_server_name
    wazuh_hash[:version] = wazuh_version
    wazuh_hash
  end
end
