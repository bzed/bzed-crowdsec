# @summary Handle file acquis for crowdsec
#
# Takes a list of filenames for acquisision of logs
# for crowdsec. File type defaults to $name, but can be overwritten
# in case you want to use this several times for the same type of files.
#
# @param filenames
#   Array with all logs to parse
#
# @param type
#   Type of the files, defaults to $name
#
# @example
#   crowdsec::acquis::files { 'apache2':
#     filenames => ['/var/log/apache2/*.log']
#   }
define crowdsec::acquis::files (
  Array[Stdlib::Absolutepath] $filenames,
  String $type = $name,
) {
  $config = {
    'filenames' => $filenames,
    'labels'    => { 'type' => $type },
  }

  crowdsec::acquis { $name:
    config => $config,
  }
}
