# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache::babel
#
# babel.hathitrust.org virtual host
#
# @example
#   include nebula::profile::hathitrust::apache::babel
class nebula::profile::hathitrust::apache::babel (
  String $sdrroot,
  String $sdremail,
  Hash $default_access,
  Array[String] $haproxy_ips,
  Hash $ssl_params,
  String $prefix,
  String $domain,
  String $gwt_code,
  String $useradmin_endpoint,
  Array[String] $cache_paths = [ ],
) {

  ### MONITORING

  $monitor_location = '/monitor'
  $cgi_dir = '/usr/local/lib/cgi-bin'
  $monitor_dir = "${cgi_dir}/monitor"

  file { $cgi_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  $monitor_requires = {
    enforce  => 'any',
    requires => [ 'local' ] + $haproxy_ips.map |String $ip| { "ip ${ip}" }
  }

  class { 'nebula::profile::monitor_pl':
    directory  => $monitor_dir,
    shibboleth => true,
    solr_cores => lookup('nebula::hathitrust::monitor::solr_cores'),
    mysql      => lookup('nebula::hathitrust::monitor::mysql')
  }

  $joined_paths = $cache_paths.join(' ')
  cron { 'purge caches':
    command => "/htapps/babel/mdp-misc/scripts/managecache.sh ${joined_paths}",
    user    => 'nobody',
    minute  => '23',
    hour    => '1',
  }

  ## VHOST DEFINITION

  $servername = "${prefix}babel.${domain}"

  $imgsrv_address = lookup('nebula::profile::hathitrust::imgsrv::bind');

  apache::vhost { "${servername} ssl":
    servername                  => $servername,
    serveraliases               => [ "crms-training.${servername}" ],
    port                        => '443',
    docroot                     => $sdrroot,
    manage_docroot              => false,
    error_log_file              => 'babel/error.log',
    access_log_file             => 'babel/access.log',
    access_log_format           => 'combined',
    *                           => $ssl_params,

    # from babel-common

    aliases                     => [
      {
        scriptalias => $monitor_location,
        path        => $monitor_dir
      },
      {
        aliasmatch => '^/robots.txt$',
        path       => "${sdrroot}/common/web/robots.txt"
      },
      {
        # Support Google Webmaster Tools by making its verification file
        # available at (2015-05-07 rrotter per roger)
        aliasmatch => '^google$gwt_code.html$',
        path       => "${sdrroot}/common/web/google${gwt_code}.html"
      },
      {
        aliasmatch => '^/favicon.ico$',
        path       => "${sdrroot}/common/web/favicon.ico"
      },
      {
        # Used for example logo and style sheet in error templates.
        alias => '/shibboleth-sp/main.css',
        path  => '/usr/share/shibboleth/main.css'
      }
    ],

    directoryindex              => 'index.html',

    setenv                      => [
      "SDRROOT ${sdrroot}",
      'SDRDATAROOT /sdr1',
      "ASSERTION_EMAIL ${sdremail}"
    ],

    setenvifnocase              => [
      "Host ^crms-training.${servername} CRMS_INSTANCE=crms-training",
      "Host ^${servername} CRMS_INSTANCE=production"
    ],

    rewrites                    => [
      {
        # Map web content URLs to the web directories within each application repository,
        # if the file being requested exists.
        #
        # URLs are of the form /app/foobar and are mapped to /app/web/foobar.
        #
        # 2010-10-01 skorner
        # it also supports a comment => '' field; not sure if we want to use that
        rewrite_cond => ['%{DOCUMENT_ROOT}/$1/web/$2 -f'],
        rewrite_rule => ['^/([^/]+)/(.*)       /$1/web/$2        [last]'],
      },
      {
        # Map bare application directory URLs to allow for auto loading of index files.
        #
        # URLs of the form /app or /app/ are mapped to /app/web/ to auto serve /app/web/index.*
        #
        # 2011-11-30 rrotter
        rewrite_cond => ['%{DOCUMENT_ROOT}/$1/web/ -d'],
        rewrite_rule => ['^/([^/]+)/?$ /$1/web/ [last]'],
      },

      {

        # serve ht widgets from /widgets/<widget name>/web/
        #
        # 2012-12-10 skorner
        rewrite_cond => ['%{DOCUMENT_ROOT}/widgets/$1/web/$2 -f'],
        rewrite_rule => ['^/widgets/([^/]+)/(.*)      /widgets/$1/web/$2      [last]'],
      },


      # FROM SSL

      {
        # Fold ptsearch into pageturner. Remove after 12/31/2011
        #
        # 2010-04-26 aelkiss per roger
        # 2018-11 - checked with roger -- retain indefinitely
        rewrite_rule => ['  ^/(shcgi|cgi)/ptsearch      /$1/pt/search        [redirect,noescape,last]'],
      },

      {
        # Map cgi URLs of the traditional /cgi/app form to the cgi directories within
        # each application repository, if the cgi being requested exists.  Also
        # support a second level of cgi for flexibility.  Any path info formatted
        # arguments are carried along in both cases.
        #
        # URLs are of the form /cgi/app and are mapped to /app/cgi/app, and
        # /cgi/app/subdir/foobar to /app/cgi/subdir/foobar.
        #
        # For URLs of the form /cgi/APP/PATHINFO where a FastCGI socket exists for
        # APP and PATHINFO doesn't match any other existing CGI, the FastCGI socket
        # will be used and PATHINFO arguments carried along. If another script exists
        # that matches PATHINFO (e.g. /imgsrv/pdf), that will be used instead of the
        # FastCGI socket.
        #
        # Order is important; the longer pathname is matched first.
        #
        # The passthrough is required to pick up both the access control and cgi
        # DirectoryMatch defined globally.
        #
        # 2011-04-20 aelkiss
        # 2011-12-12 skorner

        # If /htapps/VHOST/APP/cgi/SCRIPT exists, rewrite /cgi/APP/SCRIPT/PATHINFO
        # to /APP/cgi/SCRIPT/PATHINFO and stop
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$2/cgi/$3 -f'],
        rewrite_rule => ['  ^/(shcgi|cgi)/([^/]+)/([^/]+)(.*)$  /$2/cgi/$3$4        [skip]']
      },

      {
        # If the above rule didn't get used see if /htapps/VHOST/APP/cgi/APP exists,
        # and rewrite /cgi/APP/PATHINFO to /APP/cgi/APP/PATHINFO
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$2/cgi/$2 -f'],
        rewrite_rule => ['  ^/(shcgi|cgi)/([^/]+)(.*)$    /$2/cgi/$2$3'],
      },

      {
        # If there is a PSGI "choke" wrapper, invoke that so that the
        # request is considered for throttling
        rewrite_cond => ['  %{DOCUMENT_ROOT}/$1/cgi/$3.choke -f'],
        rewrite_rule => ['  ^/([^/]+)/(shcgi|cgi)/([^/]+)(.*)$  /$1/cgi/$3.choke$4      [last]'],
      },

      {
        # babel home page of sorts
        #
        # 2008-10-24 csnavely per suzchap
        rewrite_rule => ["  ^(/$|/index.html$)      https://${servername}/cgi/mb  [redirect=permanent,last]"],
      },

      {
        # user administration ruby application
        rewrite_rule =>  ["^(/usermanage.*)$ ${useradmin_endpoint}\$1 [P]"]
      },

    ],

    directories                 => [
      {
        provider => 'filesmatch',
        location =>  '~$',
        require  => 'all denied'
      },
      {
        provider       => 'directory',
        location       => $sdrroot,
        allow_override => ['None'],
        require        =>  'all denied'
      },
      {
        provider              => 'location',
        path                  => '/',
        auth_type             => 'shibboleth',
        require               => 'shibboleth',
        shib_request_settings => { 'requireSession' => '0'}
      },
      {
        # Grant access to necessary directories under the document root:
        # ${sdrroot}/*/cgi
        # ${sdrroot}/*/web
        # ${sdrroot}/cache
        #
        # 2010-10-01 skorner
        provider => 'directorymatch',
        path     => "^(${sdrroot}/(([^/]+)/(web|cgi)|widgets/([^/]+)/web|cache|mdp-web)/)(.*)",
        require  => $default_access
      },
      {
        # Enable cgi execution under ${sdrroot}/*/cgi.
        #
        # 2010-10-01 skorner
        provider       => 'directorymatch',
        path           => "^${sdrroot}/([^/]+)/cgi",
        allow_override => 'None',
        options        => '+ExecCGI',
        sethandler     => 'cgi-script',
        require        => 'unmanaged'
      },
      {
        # An Apache handler needs to be established for the "handler" location.
        # This applies the handler to any requests for a resource with a ".sso"
        # extension.
        #
        # Note: this makes *.sso files (and therefore shib session initiation)
        # public to any shib idp, but the alternatives (maintaining separate
        # ACLs for *.sso in each vhost, or devising a scheme with environment
        # variables and ugly IP range regexps) seem unacceptably complex
        provider   => 'files',
        path       => '*.sso',
        sethandler => 'shib-handler',
        require    => 'all granted'
      },
      {
        provider => 'locationmatch',
        path     => '^/shibboleth-sp/main.css',
        require  => 'all granted'
      },
      {
        provider        => 'directory',
        path            => "${sdrroot}/imgsrv/cgi",
        require         => 'unmanaged',
        allow_override  => false,
        custom_fragment => "
    <Files \"imgsrv\">
      SetHandler proxy:fcgi://${imgsrv_address}
    </Files>",
      },
      {
        provider => 'location',
        path     => '/monitor',
        require  => $monitor_requires
      },

    ],

    ssl_proxyengine             => true,
    ssl_proxy_check_peer_name   => 'on',
    ssl_proxy_check_peer_expire => 'on',

    custom_fragment             => "
    <Proxy \"fcgi://${imgsrv_address}\" enablereuse=off max=10>
    </Proxy>

    ProxyPassReverse /usermanage ${useradmin_endpoint}
    ",

    request_headers             => [
      # Explicitly forward attributes extracted via Shibboleth
      'set X-Shib-Persistent-ID %{persistent-id}e',
      'set X-Shib-eduPersonPrincipalName %{eppn}e',
      'set X-Shib-displayName %{displayName}e',
      'set X-Shib-mail %{email}e',
      'set X-Shib-eduPersonScopedAffiliation %{affiliation}e',
      'set X-Shib-Authentication-Method %{Shib-Authentication-Method}e',
      'set X-Shib-AuthnContext-Class %{Shib-AuthnContext-Class}e',
      'set X-Shib-Identity-Provider %{Shib-Identity-Provider}e',
      # Setting remote user for 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ],

    allow_encoded_slashes       =>  'on',

  }

}
