# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include crowdsec::local_api
class crowdsec::local_api {

  include crowdsec

  concat { 'crowdsec_managed_machines':
    path   => '/etc/facter/facts.d/crowdsec.json',
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    format => 'json',
  }

  $puppet_managed_machines = pick_default(
    $facts.dig('crowdsec_puppet', 'managed_machines'), []
  )

  $crowdsec_machines = pick_default($facts.dig('crowdsec', 'machines'), [])

  $crowdsec_machines.each |$m| {
    $machine_id = $m['machineId']

    if !($machine_id in $puppet_managed_machines) {

      exec { "remove-${machine_id}":
        path    => $facts['path'],
        command => "/usr/bin/cscli machines delete '${machine_id}'",
        user    => 'root',
        group   => 'root',
      }
    }
  }


  Crowdsec::Local_api::Register <<| tag == $crowdsec::local_api_puppet_certname |>>
}
