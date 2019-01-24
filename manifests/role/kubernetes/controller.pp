# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes controller plane and etcd server
class nebula::role::kubernetes::controller {
  include nebula::role::minimum
  include nebula::profile::kubernetes::stacked_controller
}
