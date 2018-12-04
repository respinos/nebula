# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::perl
#
# Install perl dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::perl
class nebula::profile::hathitrust::perl () {
  include nebula::profile::hathitrust::dependencies
  include nebula::profile::geoip

  package { [
    'libalgorithm-diff-xs-perl',
    'libany-moose-perl',
    'libapache-session-perl',
    'libarchive-zip-perl',
    'libcgi-application-perl',
    'libcgi-compile-perl',
    'libcgi-emulate-psgi-perl',
    'libcgi-psgi-perl',
    'libclass-accessor-perl',
    'libclass-c3-perl',
    'libclass-data-accessor-perl',
    'libclass-data-inheritable-perl',
    'libclass-errorhandler-perl',
    'libclass-load-perl',
    'libcommon-sense-perl',
    'libcompress-raw-zlib-perl',
    'libconfig-auto-perl',
    'libconfig-inifiles-perl',
    'libconfig-tiny-perl',
    'libcrypt-openssl-random-perl',
    'libcrypt-openssl-rsa-perl',
    'libcrypt-ssleay-perl',
    'libdata-optlist-perl',
    'libdata-page-perl',
    'libdate-calc-perl',
    'libdate-manip-perl',
    'libdbd-mysql-perl',
    'libdevel-globaldestruction-perl',
    'libdigest-sha-perl',
    'libemail-date-format-perl',
    'libencode-locale-perl',
    'liberror-perl',
    'libeval-closure-perl',
    'libfcgi-perl',
    'libfcgi-procmanager-perl',
    'libfile-listing-perl',
    'libfile-slurp-perl',
    'libfilesys-df-perl',
    'libgeo-ip-perl',
    'libhtml-parser-perl',
    'libhtml-tree-perl',
    'libhttp-browserdetect-perl',
    'libhttp-cookies-perl',
    'libhttp-daemon-perl',
    'libhttp-date-perl',
    'libhttp-dav-perl',
    'libhttp-message-perl',
    'libhttp-negotiate-perl',
    'libimage-exiftool-perl',
    'libimage-info-perl',
    'libimage-size-perl',
    'libinline-perl',
    'libio-compress-perl',
    'libio-html-perl',
    'libio-socket-ssl-perl',
    'libio-string-perl',
    'libipc-run-perl',
    'libjson-perl',
    'libjson-pp-perl',
    'libjson-xs-perl',
    'liblist-compare-perl',
    'liblist-moreutils-perl',
    'liblog-log4perl-perl',
    'liblwp-mediatypes-perl',
    'libmail-sendmail-perl',
    'libmailtools-perl',
    'libmime-lite-perl',
    'libmime-types-perl',
    'libmodule-implementation-perl',
    'libmodule-runtime-perl',
    'libmoose-perl',
    'libmouse-perl',
    'libmro-compat-perl',
    'libnet-dns-perl',
    'libnet-http-perl',
    'libnet-libidn-perl',
    'libnet-oauth-perl',
    'libnet-ssleay-perl',
    'libpackage-deprecationmanager-perl',
    'libpackage-stash-perl',
    'libparse-recdescent-perl',
    'libplack-perl',
    'libpod-simple-perl',
    'libproc-processtable-perl',
    'libreadonly-perl',
    'libreadonly-xs-perl',
    'libroman-perl',
    'libsoap-lite-perl',
    'libspreadsheet-writeexcel-perl',
    'libsub-exporter-progressive-perl',
    'libsub-name-perl',
    'libtemplate-perl',
    'libterm-readkey-perl',
    'libterm-readline-gnu-perl',
    'libtest-requiresinternet-perl',
    'libtest-simple-perl',
    'libtie-ixhash-perl',
    'libtimedate-perl',
    'libtry-tiny-perl',
    'libuniversal-require-perl',
    'liburi-encode-perl',
    'libuuid-perl',
    'libuuid-tiny-perl',
    'libversion-perl',
    'libwww-perl',
    'libwww-robotrules-perl',
    'libxml-dom-perl',
    'libxml-libxml-perl',
    'libxml-libxslt-perl',
    'libxml-sax-perl',
    'libxml-simple-perl',
    'libxml-writer-perl',
    'libyaml-appconfig-perl',
    'libyaml-libyaml-perl',
    'libyaml-perl',
    'perlmagick']:
  }

  nebula::cpan { 'File::Value': }
  nebula::cpan { 'File::ANVL': }
  nebula::cpan { 'File::Namaste': }
  nebula::cpan { 'File::Pairtree': }
  nebula::cpan { 'CGI::Application::Plugin::Routes': }
  nebula::cpan { 'Algorithm::LUHN': }
  nebula::cpan { 'OAuth::Lite': }
  nebula::cpan { 'EBook::EPUB': }
  nebula::cpan { 'Sub::Uplevel': }
  nebula::cpan { 'Test::Exception': }
  nebula::cpan { 'Devel::Cycle': }
  nebula::cpan { 'Test::Memory::Cycle': }
}
