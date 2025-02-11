# @summary Creates crowdsec whitelists.
#
# Whitelists are special parsers that allow you to "discard" events,
# and can exist as parser or postoverflow whitelist.
#
# @param module
# Name of the whitelist. Must be unique, defaults to $name.
# Must be in the usual foo/bar format.
#
# @param module_type
# parsers or postoverflows. Decides which type of whitelist / when to apply it.
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
#     description => 'long description',
#     reason => "this is an example",
#     module_type => 'parser',
#   }
define crowdsec::whitelist (
  String $description,
  String $reason,
  Enum['parsers', 'postoverflows'] $module_type,
  Crowdsec::Module_name $module = $name,
  Optional[Array[Stdlib::IP::Address::Nosubnet]] $ip = undef,
  Optional[Array[Stdlib::IP::Address::CIDR]] $cidr = undef,
  Optional[Array[String]] $expression = undef,
  Optional[Array[Hash]] $data = undef,
  Optional[String] $filter = undef,
) {
  $_whitelist = {
    ip         => $ip,
    cidr       => $cidr,
    expression => $expression,
    data       => $data,
  }.delete_undef_values

  $whitelist = assert_type(Hash[String, Array, 1], $_whitelist) |$expected, $actual| {
    fail('The configured whitelist would be empty, ip/cidr/expression/data are all not set')
  }

  $config = {
    name        => $module,
    description => $description,
    filter      => $filter,
    whitelist   => $whitelist,
  }

  crowdsec::module { $module:
    module_type    => $module_type,
    content        => stdlib::to_json($config),
    module_subtype => 's02-enrich',
  }
}
