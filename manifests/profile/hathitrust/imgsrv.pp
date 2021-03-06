# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache
#
# Install apache for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::imgsrv
class nebula::profile::hathitrust::imgsrv (
  Integer $num_proc,
  String $sdrroot,
  String $sdrview,
  String $sdrdataroot,
  String $bind
) {

  file { '/usr/local/bin/startup_imgsrv':
    ensure  => 'present',
    content => template('nebula/profile/hathitrust/imgsrv/startup_imgsrv.erb'),
    notify  => Service['imgsrv'],
    mode    => '0755'
  }

  file { '/etc/systemd/system/imgsrv.service':
    ensure  => 'present',
    content => template('nebula/profile/hathitrust/imgsrv/imgsrv.service.erb'),
    notify  => Service['imgsrv']
  }

  file_line { 'tiger ignore imgsrv':
    ensure => 'present',
    line   => "The process `(/htapps/babel/.*|perl-fcgi|/l/local/bin/.*)' is listening on socket .* \\(UDP on every interface\\) is run by nobody.",
    path   => '/etc/tiger/tiger.ignore'
  }

  service { 'imgsrv':
    ensure     => 'running',
    enable     => true,
    hasrestart =>  true
  }

  cron { 'imgsrv responsiveness check':
    command => '/usr/local/bin/check_imgsrv',
    user    => 'root',
    minute  => '*/2',
  }


  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/check_imgsrv':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/check_imgsrv"
  }

  file { '/usr/local/bin/startup_app':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/startup_app"
  }

}
