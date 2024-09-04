# @summary Install crowdsec modules from the hub.
#
# This rather generic defined_type allows to install all
# the different crowdsec parts that come directly from the crowdsec
# hub.
# - parsers
# - postoverflows
# - scenarios
# - contexts
# - appsec-configs
# - appsec-rules
# - collections
#
# @param hub_type
# Required parameter to specify the type of module to install from the hub
# (parsers, collections, .....)
#
# @param ensure
# Set to 'present' to install, 'absent' to uninstall.
#
#
# @param install_options
# Hash to specify necessay install options like API keys for the hub.
#   { 'foo'  => 'bar' }
# results in
#   --foo bar
# being pass as option to cscli .... install.
#
# @param module_name
# Defaults to $name. Sets the name of the hub module to install/uninstall.
#
# @example
#   crowdsec::module { 'crowdsecurity/ssh-bf':
#     type => 'collections',
#   }
define crowdsec::module (
  Crowdsec::Module_type $hub_type,
  Enum['present', 'absent'] $ensure = 'present',
  Hash[Pattern[/[a-z]+/], String] $install_options = {},
  String $module_name = $name,
) {
  include crowdsec

  $automatic_hub_updates = $crowdsec::automatic_hub_updates

  $current_state = $facts.dig('crowdsec', $hub_type)
  if ($ensure == 'present') {
    $install_command = 'install'
  } else {
    $install_command = 'uninstall'
  }
}
