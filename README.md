# wazuh_agent

## Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Branches](#branches)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [TODO](#todo)
1. [License](#license)

## Description

This is a simple and straightforward module to set up and manage Wazuh
agent. No server side is and will not be supported.

The assumption was/is that the agent side is only minimally set up and kept running. The server side will provide configuration remotely by using the agent.conf file.

The drive behind this module was to have one for just the agent side, and keep it lean and mean with a simple and opinionated structure, as well as provide sensible defaults.

I've cherry-picked some code from the official Wazuh module. Credits 
naturally go to them. Their module can be found here: [wazuh-puppet](https://github.com/wazuh/wazuh-puppet)

To learn more about Wazuh, visit [their website](https://wazuh.com)

## Usage

```
   class { wazuh_agent:
     enrollment_server   => 'mywazuh.example.com',
     enrollment_password => 'created_with_rusty_enigma',
  }
```

## Branches

* ```master``` contains the latest code with more problems
* ```tagged branches``` contain the code with hopefullyless problems

## Limitations

Only supports the Wazuh agent, not the server. The server side is frequently run
on Kubernetes and the likes.

Only Linux and osfamily RedHat and Debian supported for now.

## TODO

* Write rspec-puppet tests
* More fragments for wazuh features

## Credits

* Nicolas Zin
* Jonathan Gazeley
* Michael Porter
* All official Wazuh puppet module contributors.

[Check out what's cooking in Wazuh](https://wazuh.com)

## License

GPLv2


