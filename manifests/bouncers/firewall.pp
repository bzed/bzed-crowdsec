# @summary Firewall bouncer for crowdsec
#
# Setup the nftables or iptables crowdsec bouncert
#
# @param mode
# iptables or nftables, selects the firewall type to use.
#
# @param api_key
# Password to register the bouncer with
#
# @param config
# config settings that should overwrite the defaults
#
# @example
#   include crowdsec::bouncers::firewall
class crowdsec::bouncers::firewall (
  Enum['nftables', 'iptables'] $mode = 'nftables',
  Hash $config = {},
  Sensitive[String] $api_key = Sensitive(
    fqdn_rand_string(
      32,
      undef,
      "crowdsec::bouncers::firewall-${facts['networking']['mac']}",
    )
  ),
) {
  include crowdsec

  $package = "crowdsec-firewall-bouncer-${mode}"
  ensure_packages([$package])

  $bouncer_name = "${trusted['certname']}_firewall-${mode}"

  @@crowdsec::bouncers::register { $bouncer_name:
    password => $api_key.unwrap,
  }

  $bouncer_config = {
    'mode'            => $mode,
    'api_url'         => $crowdsec::local_api_url,
    'api_key'         => $api_key,
    'iptables_chains' => ['crowdsec'],
  }
  $default_config = parseyaml(
    file('crowdsec/bouncers/crowdsec-firewall-bouncer.yaml')
  )

  $final_config = deep_merge($default_config, $bouncer_config, $config)

  file { '/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml':
    owner   => $crowdsec::user,
    group   => $crowdsec::group,
    mode    => '0600',
    content => to_yaml($final_config),
    require => [
      Package[$package],
      Service[$crowdsec::service_name],
    ],
  }
}
