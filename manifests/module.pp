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
# @param module
# Defaults to $name. Sets the name of the hub module to install/uninstall.
#
# @param source
# Module is not from the hub, use this source as source for the file.
#
# @param content
# Module is not from the hub, use this content for the file.
#
# @param module_subtype
# "module_subtype" of the module, for example s01-parse to install in crowdsec/parsers/s01-parse
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
  Crowdsec::Module_name $module = $name,
  Optional[String] $source = undef,
  Optional[String] $content = undef,
  Optional[String] $module_subtype = undef,
) {
  include crowdsec

  $_module_name_parts = split($module, '/')
  $module_source = $_module_name_parts[0]
  $module_filename_part = $_module_name_parts[1]

  $_current_state = pick_default($facts.dig('crowdsec', $module_type), []).filter |$_module| {
    $_module['name'] == $module
  }
  if $_current_state.empty() {
    $module_file = [
      $crowdsec::config_basedir,
      $module_type,
      $module_subtype,
      "${module_filename_part}.yaml",
    ].delete_undef_values().join('/')
    $current_state = ['disabled']
  } else {
    $module_file = $_current_state[0]['local_path']
    $current_state = $_current_state[0]['status'].split(',')
  }
  $local = ($source =~ String or $content =~ String or 'local' in $current_state)
  $automatic_hub_updates = $crowdsec::automatic_hub_updates

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
    $uninstall_cmd = "cscli ${module_type} remove ${module}"
    $install_flags = shellquote(Array($install_options))
    $install_cmd = "cscli ${module_type} install ${module} --force ${install_flags}".strip()

    if ($ensure == 'absent') {
      $uninstall = ('enabled' in $current_state)
      $install = false
    } else {
      $uninstall = false
      if 'tainted' in $current_state or !('enabled' in $current_state) {
        exec { $install_cmd:
          path    => $facts['path'],
          user    => $crowdsec::user,
          group   => $crowdsec::group,
          require => [
            Package['crowdsec'],
            Service[$crowdsec::service_name],
          ],
        }
      }
      if ('update-available' in $current_state) and $automatic_hub_updates {
        $update_cmd = "cscli ${module_type} upgrade ${module} --force"
        exec { $update_cmd:
          path    => $facts['path'],
          user    => $crowdsec::user,
          group   => $crowdsec::group,
          require => [
            Package['crowdsec'],
            Service[$crowdsec::service_name],
          ],
        }
      }
    }

    if $uninstall {
      exec { $uninstall_cmd:
        path   => $facts['path'],
        user   => $crowdsec::user,
        group  => $crowdsec::group,
        before => Package['crowdsec'],
        onlyif => 'cscli version',
      }
    }
  }
}
