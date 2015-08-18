# == Class: systemd
#
# Manage Systemd
#
class systemd (
  $units = undef,
) {

  if $units != undef {
    validate_hash($units)

    create_resources('systemd::unit', $units)
  }
}
