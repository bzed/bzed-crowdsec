# @summary Registers a machine at the local apu
#
# Registering machines at the local api is done using puppetdb_query,
# so we only collect exported ressources. Don't try to use this define
# directly.
#
# @param password
# Password used to register the machine
#
# @param machine_id
# String used as id to register a machine.
#
# @example
#   @@crowdsec::local_api::register { 'namevar':
#     password => 'mysecret',
#   }
define crowdsec::local_api::register (
  String $password,
  String $machine_id = $name,
) {
  fail('crowdsec::local_api::register should be used as exported resource only!')
}
