# @summary Read data from a systemd unit via journald.
#
# Reads data from a given systemd unit from journald.
#
# @param unit
#   systemd unit that should be monitored
#
# @param type
#   type of the logs to read
#
# @example
#   crowdsec::acquis::journald { 'sshd.service': }
define crowdsec::acquis::journald (
  Systemd::Unit $unit = $name,
  String $type = 'syslog'
) {
  $config = {
    'journalctl_filter' => [
      "_SYSTEMD_UNIT=${unit}",
    ],
    'labels' => { 'type' => 'syslog' },
  }
  $acquis_name = regsubst($unit, '[.]', '_', 'G')
  crowdsec::acquis { $acquis_name:
    config => $config,
  }
}
