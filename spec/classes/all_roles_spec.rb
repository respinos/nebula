# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

def puppet_role_name_from(path)
  path.strip.gsub('/', '::').gsub(%r{^manifests}, 'nebula').gsub(%r{\.pp}, '')
end

`find manifests/role -name '*.pp'`.each_line do |file_path|
  describe puppet_role_name_from(file_path) do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        it { is_expected.to compile }
        it { is_expected.not_to contain_user('fake_canary_user') }
      end
    end
  end
end
