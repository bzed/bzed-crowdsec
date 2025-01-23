# @summary Create and maintain an acquis config
#
# Configures a log source in the acquis.d directory
# and restarts crowdsec.
# So far we do not verify anything.
#
# @param $config
#   Hash that is converted to yaml and written into
#   the config file.
#
# @param $acquis_name
#   Used to ensure we have a useable filename for the acquis config.
#   Also ensures you can't overwrite other files in the system....
#
# @example
#   crowdsec::acquis { 'mylog':
#     config => {
#       'filenames' : ['/var/log/mylog'],
#       'labels': { 'type' : 'syslog' }
#     }
#   }
define crowdsec::acquis (
  Hash $config,
  Pattern[/^[0-9a-zA-z_-]+$/] $acquis_name = $name,
) {
  include crowdsec

  $acquis_d = "${crowdsec::config_basedir}/acquis.d"

  file { "${acquis_d}/${acquis_name}.yaml":
    ensure  => file,
    user    => $crowdsec::user,
    group   => $crowdsec::group,
    mode    => '0644',
    content => stdlib::to_yaml($config),
    notify  => Service[$crowdsec::service_name],
  }
}
