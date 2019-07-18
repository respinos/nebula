
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::clearinghouse
#
# Configure apache & virtual hosts for clearinghouse
#
# AWS host with apache, mysql, php
#
# @example
#   include nebula::role::app_host::standalone
class nebula::profile::clearinghouse::apache (
  String $base_domain = 'clearinghouse.net',
  String $ch_root = '/l/web'
) {
  include nebula::profile::named_instances::apache

  $ssl_cn = Class['nebula::profile::named_instances::apache']['ssl_cn']

  include nebula::profile::php73
  include apache::mod::alias

  class { 'apache::mod::dir':
    indexes => ['index.html','index.php']
  }
  class { 'apache::mod::proxy_fcgi': }

  $public_common = {
    servername    => "www.${base_domain}",
    docroot       => "${ch_root}/chPublic/public_html",
    serveraliases => [$base_domain]
  }

  $admin_common = {
    servername => "chadmin.${base_domain}",
    docroot    => "${ch_root}/chAdmin/public_html"
  }

  $nocache_pdf = {
    rewrite_rule => '^/chDocs/(.*[.]pdf)$	/chDocs/no_cache.php?file_path=$1	[passthrough]'
  }

  $ssl_params     = {
    ssl            => true,
    ssl_protocol   => 'all -SSLv2 -SSLv3',
    ssl_cipher     => 'EECDH:EDH+aRSA:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS',
    ssl_cert       => "/etc/ssl/certs/${ssl_cn}.crt",
    ssl_key        => "/etc/ssl/private/${ssl_cn}.key",
    ssl_certs_dir  => '/etc/ssl/chain'
  }

  apache::vhost {
    default:
      port     => '80',
      rewrites => [{
        rewrite_rule => ['^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]']
      }];

    'public-http':
      * => $public_common;

    'admin-http':
      * => $admin_common;
  }

  apache::vhost {
    'public-https':
      port     => '443',
      aliases  => [
        {
          alias => '/chDocs/',
          path  => "${ch_root}/chDocs"
        }
      ],

      rewrites => [
        $nocache_pdf,
        {
          # block SQL injection attempts
          rewrite_cond => '%{QUERY_STRING}   (select|insert|update|delete)   [nocase]',
          rewrite_rule => '(.*)      -         [forbidden,last]'
        },
      ],

      *        => $public_common.merge($ssl_params)
  }

  apache::vhost {
    'admin-https':
      port     => '443',
      rewrites => [$nocache_pdf],

      *        => $admin_common.merge($ssl_params)
  }

}
