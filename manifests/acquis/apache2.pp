# @summary Handles acquisition of apache logfiles
#
# Takes care of default locations of apache2 logs, based on OS family
#
# @example
#   include crowdsec::acquis::apache2
class crowdsec::acquis::apache2 (
  Array[Stdlib::Absolutepath] $filenames = $facts['os']['family'] ? {
    'RedHat' => ['/var/log/httpd/*_log', '/var/log/httpd/*.log', '/var/log/httpd/*/*.log'],
    default => ['/var/log/apache2/*.log', '/var/log/apache2/*/*.log'],
  },
) {
  crowdsec::acquis::files { 'apache2':
    filenames => $filenames,
    type      => 'apache2',
  }
}
