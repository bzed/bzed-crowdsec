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
# @param local_api_login
# The login/user used to authenticate against the local api server.
#
# @param local_api_password
# The password used to login on the local api server.
#
# @param use_anonymous_api_logins
# Use a hash over fqdn and  password instead of the puppet certname.
# This sounds weird, but it makes sure that we update user/password
# in case the password changes. There is not way to verify an existing password
# unfortunately.
# Don't disable if you plan to connect to the central API.
#
# @param local_api_puppet_certname
# If this option is set and matches $trusted['certname'], enable the local api
# and collect host registrations exported for that certname.
#
# @noparam documentation_readers
# Nobody reads the documentation. If you actually did so, raise this number: 0
# Pull requests for it are fine!
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
# @param automatic_hub_updates
# Update packages from the crowdsec hub automatically. Defaults to true.
#
# @param config_basedir
# Base directory for all crowdsec config files.
#
# @param service_name
# Name of the service used to control the crowdsec daemon.
#
# @param manage_modules
# Remove modules/configs that are not installed by puppet
#
# @param parsers
# Either the name of the module or an array, containing the module name and
# all the params to pass to crowdsec::module to install the module.
#
# @param postoverflows
# See parsers
#
# @param scenarios
# See parsers
#
# @param contexts
# See parsers
#
# @param appsec_configs
# See parsers
#
# @param appsec_rules
# See parsers
#
# @param collections
# See parsers
#
class crowdsec (
  Hash $config = {},
  Boolean $manage_sources = true,
  Stdlib::HTTPUrl $local_api_url = 'http://127.0.0.1:8080',
  Boolean $use_anonymous_api_logins = true,
  Optional[Stdlib::Fqdn] $local_api_puppet_certname = undef,
  Sensitive[String] $local_api_password = Sensitive(
    fqdn_rand_string(
      32,
      undef,
      $facts['networking']['mac'],
    )
  ),
  String $local_api_login = if $use_anonymous_api_logins {
    sha256("${trusted['certname']} ${local_api_password}")
  } else {
    $trusted['certname']
  },
  Boolean $force_local_api_no_tls = false,
  Boolean $register_machine = ($local_api_url != 'http://127.0.0.1:8080') and $local_api_puppet_certname,
  Boolean $enable_local_api = $local_api_puppet_certname and $local_api_puppet_certname == $trusted['certname'],
  Boolean $run_as_root = !$enable_local_api,
  Boolean $automatic_hub_updates = true,
  Stdlib::Absolutepath $config_basedir = $crowdsec::params::config_basedir,
  String $service_name = $crowdsec::params::service_name,
  Boolean $manage_modules = true,
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $appsec_configs = [],
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $appsec_rules = [],
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $collections = [
    'crowdsecurity/linux',
    'crowdsecurity/sshd',
  ],
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $contexts = ['crowdsecurity/bf_base'],
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $parsers = [
    'crowdsecurity/dateparse-enrich',
    'crowdsecurity/geoip-enrich',
    'crowdsecurity/sshd-logs',
    'crowdsecurity/syslog-logs',
    'crowdsecurity/whitelists',
  ],
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $postoverflows = ['crowdsecurity/cdn-whitelist'],
  Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0] $scenarios = [
    'crowdsecurity/ssh-bf',
    'crowdsecurity/ssh-cve-2024-6387',
    'crowdsecurity/ssh-slow-bf',
  ],
) inherits crowdsec::params {
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
      unit          => $service_name,
      notify        => Service[$service_name],
      service_entry => {
        'User'                => $user,
        'Group'               => $group,
        'AmbientCapabilities' => 'CAP_NET_BIND_SERVICE',
      },
    }
  }

  file { [$config_basedir, '/var/log/crowdsec', '/var/lib/crowdsec']:
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

  package { 'crowdsec':
    ensure => installed,
  }

  service { $service_name:
    ensure  => 'running',
    enable  => 'true',
    require => Package['crowdsec'],
  }

  file { "${config_basedir}/config.yaml.local":
    ensure  => file,
    owner   => $user,
    group   => $group,
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

  file { "${config_basedir}/local_api_credentials.yaml":
    ensure  => file,
    owner   => $user,
    group   => $group,
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

  [
    'parsers',
    'postoverflows',
    'scenarios',
    'contexts',
    'appsec-configs',
    'appsec-rules',
    'collections',
  ].each |$module_type| {
    $_varname = regsubst($module_type, /-/, '_', 'G')
    getvar($_varname).each|$module| {
      if $module =~ Array {
        crowdsec::module { $module[0]:
          * => $module[1],
        }
      } else {
        crowdsec::module { "${module_type}-${module}":
          module_type => $module_type,
          module_name => $module,
        }
      }
    }
    if $manage_modules {
      $_modules = getvar($_varname).map|$module| {
        if $module =~ Array {
          $module[0]
        } else {
          $module
        }
      }
      $_uninstall_modules = pick_default($facts.dig('crowdsec', $module_type), []).filter|$_m| {
        $_m['status'] =~ /enabled/
      }.map|$_m| {
        $_m['name']
      }.filter|$_m| {
        !($_m in $_modules)
      }.each|$_m| {
        crowdsec::module { "${module_type}-${_m}":
          ensure      => absent,
          module_type => $module_type,
          module_name => $_m,
        }
      }
    }
  }
}
