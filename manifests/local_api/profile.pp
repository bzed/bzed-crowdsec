# @summary Adds a profile to the local api profiles.yaml
#
# Under the hood we use concat to create a file with various
# yaml snippets. In case the default profiles are enabled,
# they will be deployed with order '500'.
#
# @param config
# Profile config to deploy, right now we don't do any syntax check on it.
#
# @example
#   crowdsec::local_api::profile { 'namevar':
#     config => { ....... },
#     order  => '050',
#   }
define crowdsec::local_api::profile (
  Hash $config,
  Pattern[/[0-9]{3}/] $order = '100',
) {
  $config_yaml = stdlib::to_yaml($config)

  include crowdsec::local_api
  concat::fragment { "crowdsec_local_api_profile_${name}":
    order   => $order,
    content => $config_yaml,
    target  => $crowdsec::local_api::profiles_file,
  }
}
