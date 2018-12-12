# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::dns::standard
#
# Set up standard resolv_conf.
#
# @example
#   include nebula::profile::dns::standard
class nebula::profile::dns::standard {
  exec { 'restart_networking':
    command     => '/bin/systemctl restart networking',
    refreshonly => true,
  }

  $searchpaths = lookup('nebula::resolv_conf::searchpath')
  $searchpath_str = join($searchpaths, ' ')
  if $facts['ec2_metadata'] {
    file_line {
      default:
        path   => '/etc/dhcp/dhclient.conf',
        notify => Exec['restart_networking'],
      ;
      'search_domain':
        line => "supersede domain-search \"${searchpath_str}\";",
      ;
      'domain_name':
        line => 'supersede domain-name "";',
    }
  } else {
    class { 'resolv_conf':
      nameservers => lookup('nebula::resolv_conf::nameservers'),
      searchpath  => $searchpaths,
    }
  }
}
