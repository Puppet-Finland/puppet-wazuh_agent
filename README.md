# wazuh_agent

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with wazuh_agent](#setup)
    * [What wazuh_agent affects](#what-wazuh_agent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with wazuh_agent](#beginning-with-wazuh_agent)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This is a simple and straightforward module to set up and manage Wazuh
agent. No server side is and will not be supported.

The drive behind this module was to have one for just the agent side, and keep a lean and mean with a simple and opinionated structure, as well as provide sensible defaults.

I've re-used some parts of Wazuh's official module here and there. All credits 
therefore go to them. Their module can be found here: [wazuh-puppet](https://github.com/wazuh/wazuh-puppet)

To know more about Wazuh, visit [Wazuh website](https://wazuh.com)

## Usage

```
   class { wazuh_agent:
     enrollment_server   => 'mywazuh.example.com',
     enrollment_password => 'created_with_rusty_enigma',
  }
```

##Branches

* ```master``` contains the latest code with more hiccups
* ```stable``` contains the code with hopefully less hiccups

## Limitations

Only supports the Wazuh agent, not the server. The server side is frequently run
on Kubernetes and the likes. 

So far minimally tested. 

## TODO

* Write rspec-puppet tests (must have)

## Credits

* Nicolas Zin
* Jonathan Gazeley
* Michael Porter
* Wazuh puppet module authors

[Check out what Wazuh is cooking](https://wazuh.com)

## License

GPLv2


