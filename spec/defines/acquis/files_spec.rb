# frozen_string_literal: true

require 'spec_helper'

describe 'crowdsec::acquis::files' do
  let(:title) { 'apache2' }
  let(:params) do
    { 'filenames' => ['/var/log/apache2/*.log', '/var/log/httpd/*.log'] }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
