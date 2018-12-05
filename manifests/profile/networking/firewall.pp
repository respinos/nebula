# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall
#
# Manage firewall (iptables) settings
#
# These are baseline/standard service provisions where specific ranges/values
# should be specified in hiera.
#
# @example
#   include nebula::profile::networking::firewall
class nebula::profile::networking::firewall {
  # Include standard SSH rules by default
  include nebula::profile::networking::firewall::ssh

  resources { 'firewall':
    purge => true,
  }

  # Default items, sorted by title
  firewall { '001 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }

  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}