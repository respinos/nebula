# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::clearinghouse
#
# AWS host with apache, mysql, php
#
# @example
#   include nebula::role::app_host::standalone
class nebula::role::clearinghouse {
  include nebula::role::aws

  include nebula::profile::named_instances::apache

  include nebula::profile::mysql
  include nebula::profile::php73
}