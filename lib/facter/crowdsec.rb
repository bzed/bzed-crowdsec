# frozen_string_literal: true

require 'json'
require 'yaml'

Facter.add(:crowdsec) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    certnames_file = '/etc/crowdsec/crowdsec_machine_ids_to_certname.yaml'
    if Facter::Util::Resolution.which('cscli')
      output = {}
      output['certnames'] = YAML.load_file(certnames_file) if File.exist?(certnames_file)
      hub_data = Facter::Util::Resolution.exec('cscli hub list -o json')
      output.merge!(JSON.parse(hub_data)) unless hub_data.to_s.strip.empty?
      other_requests = %w[machines bouncers]
      other_requests.each do |request|
        data = Facter::Util::Resolution.exec("cscli #{request} list -o json")
        output[request] = JSON.parse(data) unless data.to_s.strip.empty?
      end
      output unless output.empty?
    end
  end
end
