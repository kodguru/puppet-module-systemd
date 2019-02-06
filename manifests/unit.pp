# == Class: systemd::unit
#
#
define systemd::unit (
  $ensure                  = 'present',
  $systemd_path            = '/etc/systemd/system',
  $unit_after              = undef,
  $unit_before             = undef,
  $unit_description        = undef,
  $unit_requires           = undef,
  $environment             = undef,
  $group                   = undef,
  $user                    = undef,
  $workingdirectory        = undef,
  $service_type            = 'simple',
  $service_timeoutstartsec = undef,
  $service_restart         = undef,
  $service_restartsec      = undef,
  $service_execstartpre    = undef,
  $service_execstart       = undef,
  $service_execstop        = undef,
  $install_wantedby        = undef,
) {

  include ::systemd

  validate_re($ensure, [ '^present$', '^absent$' ],
    "systemd::unit::${name}::ensure is invalid and does not match the regex.")

  validate_absolute_path($systemd_path)

  if $unit_after != undef {
    validate_string($unit_after)
  }
  if $unit_before != undef {
    validate_string($unit_before)
  }
  if $unit_description != undef {
    validate_string($unit_description)
  }
  if $environment != undef {
    validate_string($environment)
  }
  if $group != undef {
    validate_string($group)
  }
  if $user != undef {
    validate_string($user)
  }
  if $workingdirectory != undef {
    validate_string($workingdirectory)
  }
  validate_re($service_type, [ '^simple$', '^forking$', '^oneshot$', '^dbus$', '^notify$', '^idle$' ],
    "systemd::unit::${name}::ensure is invalid and does not match the regex.")
  if $service_timeoutstartsec != undef {
    validate_string($service_timeoutstartsec)
  }
  if $service_restart != undef {
    validate_string($service_restart)
  }
  if $service_restartsec != undef {
    validate_string($service_restartsec)
  }
  if $service_execstartpre != undef {
    validate_array($service_execstartpre)
  }
  if $service_execstart != undef {
    validate_string($service_execstart)
  }
  if $service_execstop != undef {
    validate_string($service_execstop)
  }
  if $install_wantedby != undef {
    validate_string($install_wantedby)
  }

  file { "${name}_file":
    ensure  => $ensure,
    path    => "${systemd_path}/${name}.service",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('systemd/systemd_service.erb'),
  }

  service { "${name}_service":
    ensure   => running,
    name     => $name,
    enable   => true,
    provider => 'systemd',
  }

  File["${name}_file"] ~> Exec['systemd_reload'] -> Service["${name}_service"]
}
