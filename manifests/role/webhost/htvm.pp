# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::htvm
class nebula::role::webhost::htvm {
  # Temporary copy/paste from minimum and hathitrust base to exclude
  # nebula::profile::base::firewall::ipv4...
  # FIXME: Remove when we can port custom ipv4 profile to firewall module
  include nebula::profile::base
  include nebula::profile::work_around_puppet_bugs

  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::apt
    include nebula::profile::authorized_keys
    include nebula::profile::vim
  }

  include nebula::profile::dns::smartconnect
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::afs
    include nebula::profile::duo
    include nebula::profile::exim4
    include nebula::profile::grub
    include nebula::profile::ntp
    include nebula::profile::tiger
    include nebula::profile::users
    class { 'nebula::profile::networking':
      bridge => false,
      keytab => true
    }
  }
  # End minimum/hathitrust inclusion

  nebula::balanced_frontend { 'hathitrust': }

  include nebula::profile::networking::firewall
  include nebula::profile::networking::firewall::http
}
