# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::docker_testing
#
# Install Docker and Hashicorp Vault Docker image
# Tracks 'latest' version automatically, not intended for production use
#
# @example
#   include nebula::profile::docker_testing
class nebula::profile::docker_testing () {

  class { 'docker':
    manage_package => true,
    version        => 'latest',
  }

}
