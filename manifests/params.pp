# @summary The params class defines some basic defaults for crowdsec.
#
# @example
#   include crowdsec::params
class crowdsec::params {
  case $facts['kernel'] {
    'Linux' : {
      $config_basedir = '/etc/crowdsec'
      $service_name = 'crowdsec.service'
    }
    default : {
      fail("${facts['kernel']} is not supported by the crowdsec module yet! Please send patches!")
    }
  }
}
