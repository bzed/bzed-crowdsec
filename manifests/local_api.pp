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

  $profiles_file = '/etc/crowdsec/profiles.yaml'
  crowdsec::local_api::manage { ['machines', 'bouncers']: }

  concat { $profiles_file:
    owner => $crowdsec::user,
    group => $crowdsec::group,
    mode  => '0644',
  }
}
