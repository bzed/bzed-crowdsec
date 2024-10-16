# @summary Registers a bouncer at the local api
#
# Registering bouncers at the local api is done using puppetdb_query,
# so we only collect exported ressources. Don't try to use this define
# directly.
#
# @param password
# Password used to authenticate the bouncer
#
# @example
#   @@crowdsec::bouncers::register { 'namevar':
#     password => 'mysecret',
#   }
define crowdsec::bouncers::register (
  String $password,
) {
  fail('crowdsec::bouncers::register should be used as exported resource only!')
}
