# frozen_string_literal: true

require 'json'
require 'yaml'

Facter.add(:crowdsec) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    certnames_file = '/etc/crowdsec/crowdsec_machine_ids_to_certname.yaml'
    requests = ['machines', 'bouncers', 'collections', 'scenarios', 'contexts', 'appsec-configs', 'appsec-rules']
    if Facter::Util::Resolution.which('cscli')
      output = {}
      if File.exist?(certnames_file)
        output['certnames'] = YAML.load_file(certnames_file)
      end

      requests.each do |request|
        data = Facter::Util::Resolution.exec("cscli #{request} list -o json")
        unless data.to_s.strip.empty?
          output[request] = JSON.parse(data)
        end
      end
      unless output.empty?
        output
      end
    end
  end
end
