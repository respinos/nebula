# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes general profile
#
# This installs all the necessary software for kubernetes to run on this
# node, whether it's a controller node, an etcd node, or a worker node.
# It also announces its intention to listen on all the ports that are
# supposed to be open to the entire cluster.
#
# Both parameters are required, and the cluster must be a key in the
# clusters hash. Furthermore, you must set, at minimum, a kubernetes
# version, a docker version, and a control dns for each cluster; there
# are no default values.
#
# @param cluster The unique name of the cluster.
# @param clusters A hash of cluster names to cluster definitions.
class nebula::profile::kubernetes (
  String             $cluster,
  Hash[String, Hash] $clusters,
) {
  $kubernetes_version = $clusters[$cluster]['kubernetes_version']
  $docker_version = $clusters[$cluster]['docker_version']
  $control_dns = $clusters[$cluster]['control_dns']

  if $kubernetes_version == undef {
    fail('You must set a specific kubernetes version')
  }

  if $docker_version == undef {
    fail('You must set a specific kubernetes version')
  }

  if $control_dns == undef {
    fail('You must set a specific load-balanced control dns')
  }

  package { ['kubeadm', 'kubelet']:
    ensure  => "${kubernetes_version}-00",
    require => [Apt::Source['kubernetes'], Class['docker']],
  }

  apt::source { 'kubernetes':
    location => 'https://apt.kubernetes.io/',
    release  => 'kubernetes-xenial',
    repos    => 'main',
    key      => {
      'id'     => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
      'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    },
  }

  class { 'nebula::profile::docker':
    version => $docker_version,
  }

  @@firewall {
    default:
      proto  => 'tcp',
      source => $::ipaddress,
      state  => 'NEW',
      action => 'accept',
    ;

    # All nodes in this cluster will need to access the controllers over
    # 6443 for the main API.
    "200 ${cluster} API ${::fqdn}":
      tag   => "${cluster}_API",
      dport => 6443,
    ;

    # All nodes in this cluster will need to access the workers over
    # 30000-32767 for the NodePort service.
    "200 ${cluster} NodePort ${::fqdn}":
      tag   => "${cluster}_NodePort",
      dport => '30000-32767',
    ;
  }
}
