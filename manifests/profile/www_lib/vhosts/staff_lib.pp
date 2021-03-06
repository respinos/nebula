# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::staff_lib
#
# staff.lib.umich.edu virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::staff_lib
#
class nebula::profile::www_lib::vhosts::staff_lib (
  String $prefix,
  String $domain,
  String $ssl_cn = 'staff.lib.umich.edu',
  String $vhost_root = '/www/staff.lib',
  String $docroot = "${vhost_root}/web"
) {

  # These directories are all served by PHP5 using mod_php and require Cosign
  $php5_dirs = [
    'coral',
    'ptf',
    'sites/staff.lib.umich.edu/local',
  ].map |$dir| {
    {
      provider => 'directory',
      path => "${docroot}/${dir}",
      addhandlers => [{
        extensions => ['.php'],
        handler => 'application/x-httpd-php'
      }],
      custom_fragment => 'CosignAllowPublicAccess off'
    }
  }

  nebula::apache::www_lib_vhost { 'staff.lib http redirect':
    servername      => "${prefix}staff.${domain}",
    ssl             => false,
    docroot         => $docroot,
    redirect_status => 'permanent',
    redirect_source => '/',
    redirect_dest   => 'https://staff.lib.umich.edu/'
  }

  nebula::apache::www_lib_vhost { 'staff.lib ssl':
    servername                    => "${prefix}staff.${domain}",
    ssl                           => true,
    usertrack                     => true,
    cosign                        => true,
    docroot                       => $docroot,
    setenvifnocase                => ['^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1'],

    aliases                       => [
      { scriptalias => '/cgi', path => "${vhost_root}/cgi" }
    ],

    directories                   => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => ['IncludesNOEXEC','Indexes','FollowSymLinks','MultiViews'],
        allow_override => ['AuthConfig','FileInfo','Limit','Options'],
        require        => $nebula::profile::www_lib::apache::default_access,
        addhandlers    => [{
          extensions => ['.php'],
          # TODO: Extract version or socket path to params/hiera
          handler    => 'proxy:unix:/run/php/php7.3-fpm.sock|fcgi://localhost'
        }],
      },
      {
        provider       => 'directory',
        path           => "${vhost_root}/cgi",
        allow_override => ['None'],
        options        => ['None'],
        require        => $nebula::profile::www_lib::apache::default_access,
      },
      {
        provider       => 'directory',
        path           => "${vhost_root}/alida-tmp/current/public",
        allow_override => ['None'],
        options        => ['FollowSymlinks'],
        require        => $nebula::profile::www_lib::apache::default_access,
      },
      {
        # Deny access to raw php sources by default
        # To re-enable it's recommended to enable access to the files
        # only in specific virtual host or directory
        provider => 'filesmatch',
        path     => '.+\.phps$',
        require  => 'all denied'
      },
      {
        # Deny access to files without filename (e.g. '.php')
        provider => 'filesmatch',
        path     => '^\.ph(ar|p|ps|tml)$',
        require  => 'all denied'
      },
    ] + $php5_dirs,

    # Don't allow passive auth for directories still protected by auth system
    cosign_public_access_off_dirs => [
      # results in odd looping behavior
      # {
      #   provider => 'location',
      #   path     => '/user/login'
      # },
      {
        provider => 'directory',
        path     => "${docroot}/funds_transfer",
      },
      {
        provider => 'directory',
        path     => "${docroot}/sites/staff.lib.umich.edu.funds_transfer",
      },
      {
        provider => 'directory',
        path     => "${docroot}/linkscan",
      },
      {
        provider => 'directory',
        path     => "${docroot}/linkscan117",
      },
      {
        provider => 'directory',
        path     => "${docroot}/pagerate",
      },
      {
        provider => 'directory',
        path     => "${docroot}/ts",
      },
      {
        provider => 'location',
        path     => '/alida',
      },
    ],

    request_headers               => [
      # Setting remote user for 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ],

    rewrites                      => [
      {
        comment      => 'Serve static assets, retire June 2021',
        rewrite_cond => '/www/staff.lib/alida-tmp/app/current/public/$1 -f',
        rewrite_rule => '^/alida/(.*)$  /www/staff.lib/alida-tmp/app/current/public/$1 [L]'
      },
      {
        rewrite_rule => '^(/alida.*)$ http://app-alida:40160$1 [P]'
      },
    ],

    custom_fragment               => @(EOT)
      ProxyPassReverse /alida http://app-alida:40160/
    | EOT
  }
}

