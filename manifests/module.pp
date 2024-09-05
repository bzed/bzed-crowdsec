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
# @param module_type
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
# @param source
# Module is not from the hub, use this source as source for the file.
#
# @param content
# Module is not from the hub, use this content for the file.
# 
# @example
#   crowdsec::module { 'crowdsecurity/ssh-bf':
#     type => 'collections',
#   }
#
define crowdsec::module (
  Crowdsec::Module_type $module_type,
  Enum['present', 'absent'] $ensure = 'present',
  Hash[Pattern[/[a-z]+/], String] $install_options = {},
  Crowdsec::Module_name $module_name = $name,
  String $source = undef,
  String $content = undef,
) {
  include crowdsec

  $_current_state = pick_default($facts.dig('crowdsec', $module_type), []).filter |$_module| {
    $_module['name'] == $module_name
  }
  if $_current_state {
    $module_file = $_current_state[0]['local_path']
    $current_state = $_current_state[0]['status'].split(',')
  } else {
    $module_file = "${crowdsec::config_basedir}/${module_type}/${module_filename_part}.yaml"
    $current_state = ['disabled']
  }
  $local = ($source =~ String or $content =~ String or 'local' in $current_state)
  $automatic_hub_updates = $crowdsec::automatic_hub_updates

  if ($ensure == 'present') {
    $install_command = 'install'
  } else {
    $install_command = 'uninstall'
  }

  $_module_name_parts = split($module_name, '/')
  $module_source = $_module_name_parts[0]
  $module_filename_part = $_module_name_parts[1]

# func (s *ItemState) Text() string {
# 	ret := "disabled"
# 
# 	if s.Installed {
# 		ret = "enabled"
# 	}
# 
# 	if s.IsLocal() {
# 		ret += ",local"
# 	}
# 
# 	if s.Tainted {
# 		ret += ",tainted"
# 	} else if !s.UpToDate && !s.IsLocal() {
# 		ret += ",update-available"
# 	}
# 
# 	return ret

  if $local {
    file { $module_file:
      ensure  => $ensure,
      content => $content,
      source  => $source,
      notify  => Service[$crowdsec::service_name],
    }
  } else {
    if 'tainted' in $current_state {
      fail('FIXME')
    }
  }
}
