# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal umich server
#
# @example
#   include nebula::role::umich_new_firewall
class nebula::role::umich_new_firewall (
  $bridge_network = false,
) {

  include nebula::role::minimum_new_firewall

  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::afs
    include nebula::profile::duo
    include nebula::profile::exim4
    include nebula::profile::grub
    include nebula::profile::ntp
    include nebula::profile::tiger
    include nebula::profile::users
    class { 'nebula::profile::networking':
      bridge => $bridge_network,
      keytab => true
    }
  }

  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

}