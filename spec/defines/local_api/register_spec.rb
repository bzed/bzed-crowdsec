# frozen_string_literal: true

require 'spec_helper'

describe 'crowdsec::local_api::register' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      :password => 'password'
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.and_raise_error(%r{crowdsec::local_api::register should be used as exported resource only!}) }
    end
  end
end
