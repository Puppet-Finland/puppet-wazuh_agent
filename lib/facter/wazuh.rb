# frozen_string_literal: true

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
    
    Facter.add('wazuh_agent_version') do
      setcode do
        cmd = case Facter.value('osfamily')
              when 'RedHat'
                '/bin/rpm -q wazuh-agent --queryformat "%{VERSION}"'
              when 'Debian'
                '/usr/bin/dpkg-query -W -f="\\${Version}" wazuh-agent'
              end
        stdout, stderr, status = Open3.capture3(cmd)
        if status.success?
          stdout.strip
        else
          ''
        end
      end
    end

    #def wazuh_agent_version
    #  cmd = String.new
    #  case Facter.value('osfamily')
    #  when 'RedHat'
    #    cmd = '/bin/rpm -q wazuh-agent --queryformat "%{VERSION}"'
    #  when 'Debian'
    #    cmd = '/usr/bin/dpkg-query -W -f="\\${Version}" wazuh-agent'
    #  end
    #  Facter::Core::Execution.execute(cmd)
    #end
    
    def get_ossec_conf_value(key)
      if File.exist?(@ossec_file)
        match = nil
        IO.foreach(@ossec_file) do |line|
          if line.match(%r{^.*<#{key}>(.*)</#{key}>})
            match = $1.strip
            break
          end
        end
        match || ''
      else
        ''
      end
    end
    
    #def get_ossec_conf_value(key)
    #  if File.exist?(@ossec_file)
    #    IO.readlines(@ossec_file).grep(%r{^.*<#{key}>}).map { |line|
    #      line.match(%r{^.*<#{key}>(.*)</#{key}>}).captures.first.strip
    #    }.compact.first
    #  else
    #    ''
    #  end
    #end
    
    def wazuh_server_name
      get_ossec_conf_value('address') || ''
    end
    
    if File.exist?(@state_file)
      File.foreach(@state_file) do |line|
        key, value = line.strip.split('=')
        case key
        when 'status'
          wazuh_hash[:status] = value.delete("'")
          break
        end
      end
    end
    
    wazuh_hash[:name] = wazuh_agent_data(1)
    wazuh_hash[:server] = wazuh_server_name
    wazuh_hash[:version] = wazuh_agent_version
    wazuh_hash
  end
end
