# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Prometheus scraper profile
#
# This is a profile designed to scrape metrics exported by the node
# exporters on physical and virtual machines. It scrapes only machines
# claiming to share its datacenter, but it pushes alerts to all defined
# alert managers.
#
# @param alert_managers A list of alert managers to push alerts to.
# @param static_nodes A list of nodes to scrape in addition to those
#   that don't export themselves via puppet.
# @param version The version of prometheus to run.
class nebula::profile::prometheus (
  Array $alert_managers = [],
  Array $static_nodes = [],
  Array $static_wmi_nodes = [],
  String $version = 'latest',
) {
  include nebula::profile::docker

  docker::run { 'prometheus':
    image            => "prom/prometheus:${version}",
    net              => 'host',
    extra_parameters => ['--restart=always'],
    volumes          => [
      '/etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml',
      '/etc/prometheus/rules.yml:/etc/prometheus/rules.yml',
      '/etc/prometheus/nodes.yml:/etc/prometheus/nodes.yml',
      '/opt/prometheus:/prometheus',
    ],
    require          => File['/opt/prometheus'],
  }

  file { '/etc/prometheus/prometheus.yml':
    content => template('nebula/profile/prometheus/config.yml.erb'),
    notify  => Docker::Run['prometheus'],
  }

  file { '/etc/prometheus/rules.yml':
    content => template('nebula/profile/prometheus/rules.yml.erb'),
    notify  => Docker::Run['prometheus'],
  }

  concat_file { '/etc/prometheus/nodes.yml':
    notify  => Docker::Run['prometheus'],
    require => File['/etc/prometheus'],
  }

  $static_nodes.each |$static_node| {
    concat_fragment { "prometheus node service ${static_node['labels']['hostname']}":
      tag     => "${::datacenter}_prometheus_node_service_list",
      target  => '/etc/prometheus/nodes.yml',
      content => template('nebula/profile/prometheus/exporter/node/static_target.yaml.erb'),
    }
  }

  Concat_fragment <<| tag == "${::datacenter}_prometheus_node_service_list" |>>

  file { '/etc/prometheus':
    ensure => 'directory',
  }

  file { '/opt/prometheus':
    ensure => 'directory',
    owner  => 65534,
    group  => 65534,
  }

  class { 'nebula::profile::https_to_port':
    port => 9090,
  }

  nebula::exposed_port { '010 Prometheus HTTPS':
    port  => 443,
    block => 'umich::networks::all_trusted_machines',
  }

  @@firewall { "010 prometheus node exporter ${::hostname}":
    tag    => "${::datacenter}_prometheus_node_exporter",
    proto  => 'tcp',
    dport  => 9100,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
  }
}
