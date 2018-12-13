# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal aws server
#
# @example
#   include nebula::role::aws::auto
class nebula::role::aws::auto {
  include nebula::role::aws

  if $facts['ec2_metadata'] {
    notice('we have ec2_metadata!')
  } else {
    fail('ec2_metadata fact required for this role')
  }
}
