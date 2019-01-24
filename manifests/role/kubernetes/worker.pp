# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes worker node
class nebula::role::kubernetes::worker {
  include nebula::role::minimum
  include nebula::profile::kubernetes::worker
}
