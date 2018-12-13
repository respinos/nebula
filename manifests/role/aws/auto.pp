# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal aws server
#
# @example
#   include nebula::role::aws::auto
class nebula::role::aws::auto {
  include nebula::role::aws

  file { '/iwashere':
    ensure => 'file',
    content => 'testfile',
  }

  if $facts['ec2_metadata'] {
    notify{'found ec2_metadata':}
    if $::ec2_tag_role {
      notify{"the role says: ${::ec2_tag_role}":}
    } else {
      notify{"the role says: NOTHING":}
    }
  } else {
    fail('ec2_metadata fact required for this role')
  }
}
