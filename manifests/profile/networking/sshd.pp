# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::sshd
#
# Manage SSH
#
# @param whitelist A list of IPs to whitelist for pubkey auth
# @param gssapi_auth Whether to enable GSSAPI auth for whitelisted IPs
#
# @example
#   include nebula::profile::networking::sshd
class nebula::profile::networking::sshd (
  Array[String] $whitelist,
  Boolean       $gssapi_auth = false,
) {

  service { 'sshd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/ssh/sshd_config':
    content => template('nebula/profile/networking/sshd_config.erb'),
    notify  => Service['sshd'],
  }

  file { '/etc/ssh/ssh_config':
    content => template('nebula/profile/networking/ssh_config.erb'),
  }
}