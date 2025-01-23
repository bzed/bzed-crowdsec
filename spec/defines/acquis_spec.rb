# frozen_string_literal: true

require 'spec_helper'

describe 'crowdsec::acquis' do
  let(:title) { 'mylog' }
  let(:params) do
    {
      'config' => {
        'filenames' => ['/var/log/mylog.log'],
        'labels' => { 'type' => 'syslog' }
      }
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
