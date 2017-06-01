# hiera_jenkins

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with hiera_jenkins](#setup)
    * [Configuration](#setup-configuration)
4. [Limitations](#limitations)
5. [Development](#development)

## Overview

This module enables Hiera 5 to lookup key/value pairs managed by the [Puppet Enterprise for Jenkins Pipeline plugin](https://wiki.jenkins-ci.org/display/JENKINS/Puppet+Enterprise+Pipeline+Plugin).

## Module Description

This module provides a Puppet function called `hiera_jenkins` that can be used by Hiera 5 to do key lookups from Jenkins. 
The [Puppet Enterprise for Jenkins Pipeline plugin](https://wiki.jenkins-ci.org/display/JENKINS/Puppet+Enterprise+Pipeline+Plugin) is used to set key/value pairs in "scopes" from continuous delivery pipelines.

## Setup

### Configuration

ee [The official Puppet documentation](https://docs.puppet.com/puppet/4.9/hiera_intro.html) for more details on configuring Hiera 5.

The following is an example Hiera 5 hiera.yaml configuration for use with hiera_jenkins

```yaml
---

version: 5

hierarchy:
  - name: "Jenkins lookup"
    lookup_key: hiera_jenkins
    uris:
      - jenkins://lookup/%{trusted.certname}
      - jenkins://lookup/%{trusted.extensions.pp_environment}
      - jenkins://lookup/%{trusted.extensions.pp_datacenter}
    options:
      host: jenkins.infra.example.com
      port: 8080
```

The following mandatory Hiera 5 options must be set for each level of the hierarchy.

`name`: A human readable name for the lookup

`lookup_key`: This option must be set to `hiera_jenkins`

`uris` or `uri`: An array of URI's passed to `uris` _or_ a single URI passed to `uri`. URI values must match the pattern `jenkins://lookup/<scope>`

`host`: The DNS address of the Jenkins server



The following are optional configuration parameters supported in the `options` hash of the Hiera 5 config

`port`: The port Jenkins is listening on (default: 8080)

`jenkins_user:`: The user for Jenkins authentication if authentication is required. `jenkins_password` is required if `jenkins_user` is specified.

`jenkins_password:`: The password for the Jenkins authentication user specified by `jenkins_user`

`http_connect_timeout: ` : Timeout in seconds for the HTTP connect (default 10)

`http_read_timeout: ` : Timeout in seconds for waiting for a HTTP response (default 10)

`confine_to_keys: ` : Only use this backend if the key matches one of the regexes in the array

      confine_to_keys:
        - "application.*"
        - "apache::.*"

`failure: ` : When set to `graceful` will stop hiera-http from throwing an exception in the event of a connection error, timeout or invalid HTTP response and move on.  Without this option set hiera-http will throw an exception in such circumstances

`use_ssl:`: When set to true, enable SSL (default: false)

`ssl_ca_cert`: Specify a CA cert for use with SSL

`ssl_cert`: Specify location of SSL certificate

`ssl_key`: Specify location of SSL key

`ssl_verify`: Specify whether to verify SSL certificates (default: true)

`headers:`: Hash of headers to send in the request

## Limitations

This module only works with Hiera 5 included in Puppet 4.9+ and Puppet Enterprise 2017.2+

## Development
Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our module contribution guide.

To report or research a bug with any part of this module, please go to http://tickets.puppetlabs.com/browse/MODULES.

## Contributors/Origin

This module is very heavily based on the [crayfishx/hiera-http](https://forge.puppet.com/crayfishx/hiera_http) module.
