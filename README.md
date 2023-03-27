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
agent. No server side is supported.

I wanted a module for just the agent side, and have a clean and simple
structure.

I've re-used some parts of their module here and there. All credits 
therefore go to them.

## Usage

<pre>
   class { wazuh_agent:
     enrollment_server => 'mywazuh.example.com',
     password          => 'created_with_enigma',
  }
</pre>

## Limitations

Only manages the Wazuh agent, not the server. The server side is frequently run
on Kubernetes.

consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
