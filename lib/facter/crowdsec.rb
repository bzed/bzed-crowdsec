# frozen_string_literal: true

require 'json'

Facter.add(:crowdsec) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    if Facter::Util::Resolution.which('cscli')
      output = {}
      
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
