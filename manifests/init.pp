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
# @param local_api_url
# The local api url crowdsec should connect to. Defaults to http://127.0.0.1:8080
#
# @param local_api_puppet_certname
# If this option is set and matches $trusted['certname'], enable the local api
# and collect host registrations exported for that certname.
#
# @param force_local_api_no_tls
# Set this to true if you really want to run the local api server without TLS.
# Absolutely not recommended.
#
# @param register_machine
# Register machine automatically if $local_api_url and $local_api_puppet_certname
# is configured properly.
#
# @param enable_local_api
# Configure crowdsec to run as LAPI server
#
# @param run_as_root
# Defaults to true, when false we configure a user/group for crowdsec.
#
class crowdsec (
  Hash $config = {},
  Boolean $manage_sources = true,
  Stdlib::HTTPUrl $local_api_url = 'http://127.0.0.1:8080',
  Optional[Stdlib::Fqdn] $local_api_puppet_certname = undef,
  String $local_api_login = $trusted['certname'],
  Sensitive[String] $local_api_password = Sensitive(
    fqdn_rand_string(
      32,
      undef,
      $facts['networking']['mac'],
    )
  ),
  Boolean $force_local_api_no_tls = false,
  Boolean $register_machine = ($local_api_url != 'http://127.0.0.1:8080') and $local_api_puppet_certname,
  Boolean $enable_local_api = $local_api_puppet_certname and $local_api_puppet_certname == $trusted['certname'],
  Boolean $run_as_root = !$enable_local_api,
) {

  if $run_as_root {
    $user = 'root'
    $group = 'root'
  } else {
    $user = 'crowdsec'
    $group = 'crowdsec'

    group { $group:
      system => true,
    }
    user { $user:
      system => true,
      home   => '/var/lib/crowdsec',
      gid    => $group,
    }

    systemd::manage_dropin { 'crowdsec_as_non_root.conf':
      unit          => 'crowdsec.service',
      notify        => Service['crowdsec.service'],
      service_entry => {
        'User'                => $user,
        'Group'               => $group,
        'AmbientCapabilities' => 'CAP_NET_BIND_SERVICE',
      },
    }
  }

  file { ['/etc/crowdsec', '/var/log/crowdsec', '/var/lib/crowdsec']:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }


  if $manage_sources {
    include crowdsec::sources
    Class['crowdsec::sources'] -> Package['crowdsec']
  }

  $default_config = {
    'common' => {
      'log_dir' => '/var/log/crowdsec',
    },
  }
  $local_api_config = {
    'api' => {
      'server' => {
        'enable' => $enable_local_api,
      },
    },
  }

  $local_config = $default_config + $local_api_config + $config
  if !$force_local_api_no_tls and $enable_local_api {
    $tls_cert = $local_config.dig('api', 'server', 'tls', 'cert_file')
    $tls_key = $local_config.dig('api', 'server', 'tls', 'key_file')
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

  @@crowdsec::local_api::register { $local_api_login :
    password => $local_api_password.unwrap,
    tag      => $local_api_puppet_certname,
  }

  file { '/etc/crowdsec/local_api_credentials.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => to_yaml(
      {
        'url'      => $local_api_url,
        'login'    => $local_api_login,
        'password' => $local_api_password.unwrap,
      }
    ),
    require => Package['crowdsec'],
    notify  => Service['crowdsec.service'],
  }

}
