# @summary Registers a bouncer at the local api
#
# Registering bouncers at the local api is done using puppetdb_query,
# so we only collect exported ressources. Don't try to use this define
# directly.
#
# @param password
# Password used to authenticate the bouncer
#
# @param machine_id
# The id the bouncer is registered with.
#
# @example
#   @@crowdsec::bouncers::register { 'namevar':
#     password => 'mysecret',
#   }
define crowdsec::bouncers::register (
  String $password,
  String $machine_id = $name,
) {
  fail('crowdsec::bouncers::register should be used as exported resource only!')
}
