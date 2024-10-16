# @summary Manage the crowdsec local api
#
# To run a local api we need to register machines and bouncers
# and also remove them in case they disappear.
# For now we expect that they are fully puppet managed.
#
# @example
#   include crowdsec::local_api
class crowdsec::local_api {
  include crowdsec

  crowdsec::local_api::manage { ['machines', 'bouncers']: }
}
