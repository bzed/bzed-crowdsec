# @summary Deploys the default profiles as suggested crowdsec
#
# Deploy default local api profiles, can be disabled in
# the main crowdsec class.
#
# @example
#   include crowdsec::local_api::default_profiles
class crowdsec::local_api::default_profiles {
  $default_profiles = [
    {
      name => 'default_ip_remediation',
      filters => ['Alert.Remediation == true && Alert.GetScope() == "Ip"'],
      decisions => [{
          type => 'ban',
          duration => '4h'
      }],
      on_success => 'break',
    },
    {
      name => 'default_range_remediation',
      filters => ['Alert.Remediation == true && Alert.GetScope() == "Range"'],
      decisions => [{
          type => 'ban',
          duration => '4h'
      }],
      on_success => 'break',
    },
  ]

  $default_profiles.each |$index, $config| {
    crowdsec::local_api::profile { $config['name']:
      config => $config,
      order  => String(500 + $index),
    }
  }
}
