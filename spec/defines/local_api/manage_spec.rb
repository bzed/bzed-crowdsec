# frozen_string_literal: true

require 'spec_helper'

describe 'crowdsec::local_api::manage' do
  let(:pre_condition) do
    <<~PUPPET
      function puppetdb_query(String[1] $data) {
        return [
        ]
      }
      function assert_private() {
      }
    PUPPET
  end
  let(:title) { 'machines' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
