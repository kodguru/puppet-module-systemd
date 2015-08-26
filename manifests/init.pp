# == Class: systemd
#
# Manage Systemd
#
class systemd (
  $units = undef,
) {

  exec { 'systemd_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  if $units != undef {
    validate_hash($units)

    create_resources('systemd::unit', $units)
  }
}
