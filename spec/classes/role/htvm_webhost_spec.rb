# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'
require 'faker'

require_relative '../../support/contexts/with_mocked_nodes'

describe 'nebula::role::webhost::htvm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(networking: { ip: Faker::Internet.ip_v4_address, interfaces: {} }) }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }
      let(:haproxy) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'haproxy' } }
      let(:rolenode) { { 'ip' => Faker::Internet.ip_v4_address, 'hostname' => 'rolenode' } }

      include_context 'with mocked puppetdb functions', 'somedc', %w[haproxy rolenode], 'nebula::profile::haproxy' => %w[haproxy]

      it { is_expected.to compile }

      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,nfsvers=3,ro') }

      it do
        is_expected.to contain_file('/etc/systemd/system/shibd.service.d/increase-timeout.conf')
          .with_content("[Service]\nTimeoutStartSec=900")
      end

      it { is_expected.to contain_php__extension('File_MARC').with_provider('pear') }
      it { is_expected.to contain_nebula__cpan('EBook::EPUB').that_requires('Package[libmoose-perl]') }

      it { is_expected.to contain_file('/etc/resolv.conf').with_content(%r{nameserver 127.0.0.1}) }
      it { is_expected.to contain_service('bind9') }

      # default from hiera
      it { is_expected.to contain_host('mysql-sdr').with_ip('10.1.2.4') }

      if os == 'debian-9-x86_64'
        context 'with ens4' do
          let(:facts) do
            os_facts.merge(
              networking: {
                ip: '1.2.3.123',
                interfaces: { 'ens4' => {} },
              },
              is_virtual: true,
            )
          end

          it { is_expected.to contain_mount('/htapps').that_requires('Exec[ifup ens4]') }
          it { is_expected.to contain_mount('/sdr1').that_requires('Exec[ifup ens4]') }
          it { is_expected.to contain_service('bind9').that_requires('Exec[ifup ens4]') }
        end

        it { is_expected.to contain_class('nebula::profile::networking::firewall') }
      end

      # not specified explicitly as a usergroup, just brought in as part of 'all groups'
      it { is_expected.to contain_group('htprod') }
      it { is_expected.to contain_group('htingest') }
      # not specified explicitly - realized through Nebula::Usergroup[htprod]
      it { is_expected.to contain_user('htingest') }
      it { is_expected.to contain_user('htweb') }
    end
  end
end
