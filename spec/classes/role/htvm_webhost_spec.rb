# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

require_relative '../../support/contexts/with_htvm_setup'

describe 'nebula::role::webhost::htvm' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'with setup for htvm node', os_facts

      it { is_expected.to compile }

      it { is_expected.to contain_mount('/sdr1').with_options('auto,hard,nfsvers=3,ro') }

      it do
        is_expected.to contain_class('nebula::profile::shibboleth')
          .with(startup_timeout: 1800)
          .with(watchdog_minutes: '*/30')
      end

      it { is_expected.to contain_php__extension('File_MARC').with_provider('pear') }
      it { is_expected.to contain_nebula__cpan('EBook::EPUB').that_requires('Package[libmoose-perl]') }

      it { is_expected.to contain_file('/etc/resolv.conf').with_content(%r{nameserver 127.0.0.1}) }
      it { is_expected.to contain_service('bind9') }

      # default from hiera
      it { is_expected.to contain_host('mysql-sdr').with_ip('10.1.2.4') }

      it do
        is_expected.to contain_concat_fragment('monitor nfs /sdr1')
          .with(tag: 'monitor_config', content: { 'nfs' => ['/sdr1'] }.to_yaml)
      end

      it do
        is_expected.to contain_concat_fragment('monitor nfs /htapps')
          .with(tag: 'monitor_config', content: { 'nfs' => ['/htapps'] }.to_yaml)
      end

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

        it { is_expected.to contain_class('nebula::profile::afs') }
        it { is_expected.to contain_class('nebula::profile::users') }
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
