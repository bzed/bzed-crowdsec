# frozen_string_literal: true

require 'spec_helper'

describe 'crowdsec::module' do
  let(:title) { 'crowdsec/mymodule' }
  let(:params) do
    {
      :module_type => 'collections',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
