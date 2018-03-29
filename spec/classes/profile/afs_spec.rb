# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::afs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:kernelrelease) { os_facts[:kernelrelease] }

      it { is_expected.to contain_package('krb5-user') }
      it { is_expected.to contain_package('libpam-afs-session') }
      it { is_expected.to contain_package('libpam-krb5') }
      it { is_expected.to contain_package('openafs-client') }
      it { is_expected.to contain_package('openafs-krb5') }
      it { is_expected.to contain_package('openafs-modules-dkms') }

      it do
        is_expected.to contain_exec('reinstall kernel to enable afs').with(
          command: '/usr/bin/apt-get -y install linux-image-amd64',
          creates: "/lib/modules/#{kernelrelease}/updates/dkms/openafs.ko",
          timeout: 600,
          require: 'Package[openafs-modules-dkms]',
        )
      end

      it { is_expected.not_to contain_reboot('afs') }

      context 'when allow_auto_reboot is true' do
        let(:params) { { allow_auto_reboot: true } }

        it do
          is_expected.to contain_reboot('afs')
            .that_subscribes_to('Exec[reinstall kernel to enable afs]')
            .with_apply('finished')
        end
      end

      it do
        is_expected.to contain_debconf('krb5-config/default_realm')
          .with_type('string')
          .with_value('REALM.DEFAULT.INVALID')
      end

      it do
        is_expected.to contain_debconf('openafs-client/thiscell')
          .with_type('string')
          .with_value('cell.default.invalid')
      end

      it do
        is_expected.to contain_debconf('openafs-client/cachesize')
          .with_type('string')
          .with_value('50000')
      end

      context 'given a realm of EXAMPLE.COM' do
        let(:params) { { realm: 'EXAMPLE.COM' } }

        it do
          is_expected.to contain_debconf('krb5-config/default_realm')
            .with_type('string')
            .with_value('EXAMPLE.COM')
        end
      end

      context 'given a cell of example.com' do
        let(:params) { { cell: 'example.com' } }

        it do
          is_expected.to contain_debconf('openafs-client/thiscell')
            .with_type('string')
            .with_value('example.com')
        end
      end

      context 'given a cache_size of 100' do
        let(:params) { { cache_size: 100 } }

        it do
          is_expected.to contain_debconf('openafs-client/cachesize')
            .with_type('string')
            .with_value('100')
        end
      end
    end
  end
end
