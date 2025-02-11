# frozen_string_literal: true

require 'spec_helper'

describe 'crowdsec::whitelist' do
  let(:title) { 'spec/whitelist' }
  let(:params) do
    {
      :ip => '1.2.3.4',
      :cidr => '1.2.3.0/24',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
