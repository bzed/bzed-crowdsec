# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include crowdsec::local_api
class crowdsec::local_api {

  include crowdsec
  $user = $crowdsec::user
  $group = $crowdsec::group
  $local_api_url = $crowdsec::local_api_url
  $local_api_login = $crowdsec::local_api_login

  $query =  @("EOF":json)
    ["from", "resources",
      [ "extract",
        [
          "title",
          "parameters.machine_id",
          "parameters.password",
          "certname"
        ],
        [
          "and",
          [ "=", "type", "Crowdsec::Local_api::Register" ],
          [ "=", "parameters.tag", "${crowdsec::local_api_puppet_certname}" ],
          [ "=", "exported", true ]
        ]
      ]
    ]
  | EOF

  $puppetdb_query_data = puppetdb_query($query)
  $crowdsec_machine_ids_to_certname = Hash(
    $puppetdb_query_data.map |$hash| {
      [
        pick($hash['parameters.machine_id'], $hash['title']),
        $hash['certname'],
      ]
    }
  )

  file { '/etc/crowdsec/crowdsec_machine_ids_to_certname.yaml':
    ensure  => file,
    owner   => $user,
    group   => $group,
    content => to_yaml($crowdsec_machine_ids_to_certname),
    mode    => '0640',
  }

  $exported_lapi_machines = Hash(
    $puppetdb_query_data.map |$hash| {
      [
        pick($hash['parameters.machine_id'], $hash['title']),
        Sensitive($hash['parameters.password']),
      ]
    }
  )

  $crowdsec_machines = pick_default($facts.dig('crowdsec', 'machines'), [])
  $crowdsec_machines.each |$m| {
    $machine_id = $m['machineId']

    if !($machine_id in $exported_lapi_machines) {

      exec { "remove-${machine_id}":
        path    => $facts['path'],
        command => "/usr/bin/cscli machines delete '${machine_id}'",
        user    => $user,
        group   => $group,
      }
    }
  }

  $existing_machine_ids = $crowdsec_machines.map |$m| {
    $m['machineId']
  }

  $exported_lapi_machines.each |$machine_id, $sensitive_password| {
    if !($machine_id in $existing_machine_ids) {
      $_password = $sensitive_password.unwrap
      exec { "register-${machine_id}":
        path    => $facts['path'],
        command => "/usr/bin/cscli machines add '${machine_id}' --password '${_password}' --force -f - -u '${local_api_url}'",
        user    => 'root',
        group   => 'root',
      }
      if $machine_id == $local_api_login {
        Exec["register-${machine_id}"] ~> Service['crowdsec.service']
      }
    }
  }


  # FIXME - remove later
  file { '/etc/facter/facts.d/crowdsec.json':
    ensure => absent,
    force  => true,
  }

}
