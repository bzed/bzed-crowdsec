# @summary Creates crowdsec whitelists.
#
# Whitelists are special parsers that allow you to "discard" events,
# and can exist as parser or postoverflow whitelist.
#
# @param whitelist_name
# Name of the whitelist. Must be unique, defaults to $name.
# Must be in the usual foo/bar format.
#
# @param description
# Long description of the whitelist content / reason.
#
# @param reason
# Reason for the whitelist
#
# @param ip
# IP Addresses to whitelist
#
# @param cidr
# CIDRs to whitelist
#
# @param expression
# Whitelist based on expressions
#
# @param data
# External data to retrieve whitelists from
#
# @param filter
# Valid expr expression that will be evaluated against the event
# If filter evaluation returns true or is absent, node will be processed.
# If filter returns false or a non-boolean, node won't be processed.
#
# @example
#   crowdsec::whitelist { 'namevar':
#     reason => "this is an example"
#   }
define crowdsec::whitelist (
  String $description,
  String $reason,
  Crowdsec::Module_name $whitelist_name = $name,
  Array[Stdlib::IP::Address::Nosubnet] $ip = [],
  Array[Stdlib::IP::Address::CIDR] $cidr = [],
  Array[String] $expression = [],
  Array[Hash] $data = [],
  Optional[String] $filter = undef,
) {
  $_whitelist = {
    ip         => $ip,
    cidr       => $cidr,
    expression => $expression,
    data       => $data,
  }.filter |$item| { !($item[1].empty) }

  $whitelist = assert_type(Hash[String, Array, 1], $_whitelist) |$expected, $actual| {
    fail('The configured whitelist would be empty, ip/cidr/expression/data are all not set')
  }

  $config = {
    name        => $whitelist_name,
    description => $description,
    filter      => $filter,
    whitelist   => $whitelist,
  }
}
