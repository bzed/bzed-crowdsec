# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @param managed_type
# Defaults to $name, either machines or bouncers.
#
# @example
#   crowdsec::local_api::manage { 'machines': }
define crowdsec::local_api::manage (
  Enum['machines', 'bouncers'] $managed_type = $name,
) {
  assert_private()

  include crowdsec
  $user = $crowdsec::user
  $group = $crowdsec::group
  $local_api_url = $crowdsec::local_api_url
  $local_api_login = $crowdsec::local_api_login

  case $managed_type {
    'machines' : {
      $puppet_register_class = 'Crowdsec::Local_api::Register'
      $id_to_certname_file = '/etc/crowdsec/crowdsec_machine_ids_to_certname.yaml'
      $name_field = 'machineId'
    }
    'bouncers' : {
      $puppet_register_class = 'Crowdsec::Bouncers::Register'
      $id_to_certname_file = '/etc/crowdsec/crowdsec_bouncers_to_certname.yaml'
      $name_field = 'name'
    }
    default: {
      fail('this might never happen')
    }
  }

  # lint:ignore:strict_indent
  $query =  @("EOF":json)
    ["from", "resources",
      [ "extract",
        [
          "title",
          "parameters.password",
          "certname"
        ],
        [
          "and",
          [ "=", "type", "${puppet_register_class}" ],
          [ "=", "parameters.tag", "${crowdsec::local_api_puppet_certname}" ],
          [ "=", "exported", true ]
        ]
      ]
    ]
  | EOF
  # lint:endignore

  $puppetdb_query_data = puppetdb_query($query)
  $crowdsec_registration_ids_to_certname = Hash(
    $puppetdb_query_data.map |$hash| {
      [
        $hash['title'],
        $hash['certname'],
      ]
    }
  )

  file { $id_to_certname_file:
    ensure  => file,
    owner   => $user,
    group   => $group,
    content => to_yaml($crowdsec_registration_ids_to_certname),
    mode    => '0640',
  }

  $exported_lapi_registrations = Hash(
    $puppetdb_query_data.map |$hash| {
      [
        $hash['title'],
        Sensitive($hash['parameters.password']),
      ]
    }
  )

  $crowdsec_registrations = pick_default($facts.dig('crowdsec', $managed_type), [])
  $crowdsec_registrations.each |$m| {
    $registration_id = $m[$name_field]

    if !($registration_id in $exported_lapi_registrations) {
      exec { "remove-${registration_id}":
        path    => $facts['path'],
        command => "/usr/bin/cscli ${managed_type} delete '${registration_id}'",
        user    => $user,
        group   => $group,
      }
    }
  }

  $existing_registration_ids = $crowdsec_registrations.map |$m| {
    $m[$name_field]
  }

  $exported_lapi_registrations.each |$registration_id, $sensitive_password| {
    if !($registration_id in $existing_registration_ids) {
      $_password = $sensitive_password.unwrap
      case $managed_type {
        'machines' : {
          $register_options = "--password '${_password}' --force -f - -u '${local_api_url}'"
        }
        'bouncers' : {
          $register_options = "--key '${_password}'"
        }
        default: {
          fail('this might never happen')
        }
      }
      exec { "${managed_type}-register-${registration_id}":
        path    => $facts['path'],
        command => "/usr/bin/cscli ${managed_type} add '${registration_id}' ${register_options}",
        user    => 'root',
        group   => 'root',
      }
      if $registration_id == $local_api_login {
        Exec["${managed_type}-register-${registration_id}"] ~> Service['crowdsec.service']
      }
    }
  }
}
