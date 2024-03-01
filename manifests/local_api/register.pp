# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   crowdsec::local_api::register { 'namevar': }
define crowdsec::local_api::register (
  String $password,
  String $machine_id = $name,
) {


  include crowdsec

  $sensitive_password = Sensitive($password)

  $local_api_url = $crowdsec::local_api_url
  $machines = pick_default($facts.dig('crowdsec', 'machines'), [])
  $machines_ids = $machines.map |$m| {
    $m['machineId']
  }

  if !($machine_id in $machines_ids) {
    $_password = $sensitive_password.unwrap
    exec { "register-${machine_id}":
      path    => $facts['path'],
      command => "/usr/bin/cscli machines add '${machine_id}' --password '${_password}' --force -f - -u '${local_api_url}'",
      user    => 'root',
      group   => 'root',
    }
    if $machine_id == $crowdsec::local_api_login {
      Exec["register-${machine_id}"] ~> Service['crowdsec.service']
    }
  }
  
  concat::fragment { "crowdsec-machine-${machine_id}":
    target  => 'crowdsec_managed_machines',
    content => to_json({ 'crowdsec_puppet' => { 'managed_machines' => [ $machine_id ] } }),
    order   => '050',
  }
  
}
