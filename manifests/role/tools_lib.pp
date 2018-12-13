# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# tools.lib.umich.edu
# stand up apache server w/ dependancies for atlassian tools
#
# @example
#   include nebula::role::tools_lib
class nebula::role::tools_lib {

  file { '/tools_lib_washere':
    ensure => 'file',
    content => 'testfile',
  }
  #include nebula::profile::
  #include nebula::profile::
  #include nebula::profile::

}
