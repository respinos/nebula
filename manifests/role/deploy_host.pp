# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::deploy_host
#
# Fauxpaas server
#
# @example
#   include nebula::role::deploy_host
class nebula::role::deploy_host {
  include nebula::profile::base
  include nebula::profile::dns::standard
  include nebula::profile::metricbeat
  include nebula::profile::ruby
}
