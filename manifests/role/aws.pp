# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal aws server
#
# @example
#   include nebula::role::aws
class nebula::role::aws {

  include nebula::role::minimum

  ########################################
  # this needs to be in a profile
  ensure_packages(['iptables-persistent'])
  ########################################

  include nebula::profile::aws::filesystem

  if $facts['os']['family'] == 'Debian' and $::lsbdistcodename != 'jessie' {
    include nebula::profile::exim4
    include nebula::profile::ntp
    include nebula::profile::tiger
    class { 'nebula::profile::networking':
      bridge => false,
    }
  }

  include nebula::profile::dns::aws
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

}
