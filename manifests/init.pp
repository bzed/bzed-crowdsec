# @summary Install and manage crowdsec
#
# @example
#   include crowdsec
#
# @param config
# The whole config part that should go into config.yaml.local.
# $config['api']['server']['enable'] is overwritten in case
# $local_api_puppet_certname is set and == $trusted['certname']
#
# @param manage_sources
# Setup apt sources from the crowdsec repositories.
# Defaults to true.
#
# @param $local_api_url
# The local api url crowdsec should connect to. Defaults to http://127.0.0.1:8080
#
# @param $local_api_puppet_certname
# If this option is set and matches $trusted['certname'], enable the local api
# and collect host registrations exported for that certname.
#
# @param $force_local_api_no_tls
# Set this to true if you really want to run the local api server without TLS.
# Absolutely not recommended.
#
# @param $register_machine
# Register machine automatically if $local_api_url and $local_api_puppet_certname
# is configured properly.
#
class crowdsec (
  Hash $config = {},
  Boolean $manage_sources = true,
  Stdlib::HTTPUrl $local_api_url = 'http://127.0.0.1:8080',
  Optional[Stdlib::Fqdn] $local_api_puppet_certname = undef,
  Boolean $force_local_api_no_tls = false,
  Boolean $register_machine = ($local_api_url != 'http://127.0.0.1:8080') and $local_api_puppet_certname,
) {

  if $manage_sources {
    include crowdsec::sources
    Class['crowdsec::sources'] -> Package['crowdsec']
  }

  if $local_api_puppet_certname and $local_api_puppet_certname == $trusted['certname'] {
    $enable_local_api = true
  } else {
    $enable_local_api = false
  }
  $local_api_config = {
    'api' => {
      'server' => {
        'enable' => $enable_local_api,
      }
    }
  }

  $local_config = $local_api_config + $config
  if !$force_local_api_no_tls and $enable_local_api {
    $tls_cert = $local_config.dig('api', 'tls', 'cert_file')
    $tls_key = $local_config.dig('api', 'tls', 'key_file')
    if !($tls_cert and $tls_key) {
      fail('Please configure TLS for the crodsec local API (or set $force_local_api_no_tls to true).')
    }
  }

  package{ 'crowdsec':
    ensure => installed,
  }

  service { 'crowdsec.service':
    ensure  => 'running',
    enable  => 'true',
    require => Package['crowdsec'],
  }

  file { '/etc/crowdsec/config.yaml.local':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => to_yaml($local_config),
    require => Package['crowdsec'],
    notify  => Service['crowdsec.service'],
  }

  if $enable_local_api {
    include crowdsec::local_api
  }

}
