# == Class: systemd
#
# Manage Systemd
#
class systemd (
  $units = undef,
) {

  exec { 'systemd_reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => '/bin:/usr/bin:/usr/local/bin',
  }

  if $units != undef {
    validate_hash($units)

    create_resources('systemd::unit', $units)
  }
}
