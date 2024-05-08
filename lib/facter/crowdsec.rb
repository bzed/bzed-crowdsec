# frozen_string_literal: true

require 'json'
require 'yaml'

Facter.add(:crowdsec) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    certnames_file = '/etc/crowdsec/crowdsec_machine_ids_to_certname.yaml'
    if Facter::Util::Resolution.which('cscli')
      output = {}
      if File.exists(certnames_file)
        output['certnames'] = YAML.load_file(certnames_file)
      end

      machines = Facter::Util::Resolution.exec('cscli machines list -o json')
      unless machines.to_s.strip.empty?
        output['machines'] = JSON.parse(machines)
      end

      bouncers = Facter::Util::Resolution.exec('cscli bouncers list -o json')
      unless machines.to_s.strip.empty?
        output['bouncers'] = JSON.parse(bouncers)
      end
      unless output.empty?
        output
      end
    end
  end
end
