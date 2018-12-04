# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::users
#
# Provision users and groups.
#
# @example
#   include nebula::profile::hathitrust::users
class nebula::profile::hathitrust::users inherits nebula::profile::users {
  group { htprod:
    gid => lookup('nebula::users::local_groups')['htprod']['gid']
  }

  lookup('nebula::users::local_groups')['htprod']['members'].each |$user| {
    $values = lookup('nebula::users::humans')[$user]
    user { "hathitrust-${user}":
      name       => $user,
      comment    => $values['comment'],
      uid        => $values['uid'],
      gid        => lookup('nebula::users::default_group'),
      home       => $values['home'],
      managehome => false,
      shell      => '/bin/bash',
      groups     +> ['htprod']
    }
  }

}
