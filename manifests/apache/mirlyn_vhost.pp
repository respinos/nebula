
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::apache::mirlyn_vhost
#
# vufind virtual host
#
# @example
#   nebula::apache::mirlyn_vhost {...}

define nebula::apache::mirlyn_vhost (
  String $domain,
  String $app_url,
  String $prefix = '',
  String $ssl_cn = 'mirlyn.lib.umich.edu',
  String $docroot = "/www/vufind/web/${prefix}mirlyn/web",
  Array $serveraliases = [],
) {
  $servername = "${prefix}mirlyn.${domain}"

  file { "${apache::params::logroot}/${prefix}mirlyn":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { "vufind-http-${title}":
    servername     => $servername,
    serveraliases  => $serveraliases,
    docroot        => $docroot,
    logging_prefix => "${prefix}mirlyn/",
    usertrack      => false,

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ],

    headers        => [
      'set "Strict-Transport-Security" "max-age=3600"',
    ],

  }

  nebula::apache::www_lib_vhost { "vufind-https-${title}":
    servername                  => $servername,
    docroot                     => $docroot,
    logging_prefix              => "${prefix}mirlyn/",

    ssl                         => true,
    ssl_cn                      => $ssl_cn,
    cosign                      => false,
    usertrack                   => false,

    rewrites                    => [
      {
        comment      => 'mirlyn api',
        rewrite_rule => "^/api/(.*)$ ${app_url}\$1 [P]",
      },
    ],

    directories                 => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'FollowSymlinks',
        allow_override => 'All',
        require        => $nebula::profile::www_lib::apache::default_access,
      },
    ],

    request_headers             => [
      # Setting remote user for apache 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ],

    headers                     => [
      'set "Strict-Transport-Security" "max-age=3600"',
    ],

    ssl_proxyengine             => true,
    ssl_proxy_check_peer_name   => 'on',
    ssl_proxy_check_peer_expire => 'on',

    custom_fragment             => @("EOT"),
        ProxyPassReverse /api ${app_url}
    | EOT

  }
}
