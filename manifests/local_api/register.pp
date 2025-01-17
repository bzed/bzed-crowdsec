# @summary Registers a machine at the local api
#
# Registering machines at the local api is done using puppetdb_query,
# so we only collect exported ressources. Don't try to use this define
# directly.
# The name of this resource is the id the machine is registered with.
# Do not use confidential strings if you plan to connect to the
# (commercial/non local) crowdsec api.
#
# @param password
# Password used to authenticate the machine
#
# @example
#   @@crowdsec::local_api::register { 'namevar':
#     password => 'mysecret',
#   }
define crowdsec::local_api::register (
  String $password,
) {
  fail('crowdsec::local_api::register should be used as exported resource only!')
}
