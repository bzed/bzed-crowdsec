# @summary Install and manage crowdsec
#
# @example
#   include crowdsec
#
# @param manage_sources
# Setup apt sources from the crowdsec repositories.
# Defaults to true.
#
#
class crowdsec (
  Boolean $manage_sources = True,
) {

  if $manage_sources {
    include crowdsec::sources
  }
}
