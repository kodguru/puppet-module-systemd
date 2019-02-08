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

  if is_string($ensure) {
    validate_re($ensure, [ '^present$', '^absent$' ],
      "systemd::unit::${name}::ensure does not match the regex.")
  } else {
    fail("systemd::unit::${name}::ensure is not a string.")
  }

  validate_absolute_path($systemd_path)

  if $unit_after != undef and is_string($unit_after) == false {
    fail("systemd::${name}::unit::unit_after is not a string")
  }
  if $unit_before != undef and is_string($unit_before) == false {
    fail("systemd::${name}::unit::unit_before is not a string")
  }
  if $unit_description != undef and is_string($unit_description) == false {
    fail("systemd::${name}::unit::unit_description is not a string")
  }
  if $environment != undef and is_string($environment) == false {
    fail("systemd::${name}::unit::environment is not a string")
  }
  if $group != undef and is_string($group) == false {
    fail("systemd::${name}::unit::group is not a string")
  }
  if $user != undef and is_string($user) == false {
    fail("systemd::${name}::unit::user is not a string")
  }
  if $service_restart != undef and is_string($service_restart) == false {
    fail("systemd::${name}::unit::restart is not a string")
  }
  if $service_execstart != undef and is_string($service_execstart) == false {
    fail("systemd::${name}::unit::service_execstart is not a string")
  }
  if $service_execstop != undef and is_string($service_execstop) == false {
    fail("systemd::${name}::unit::service_execstop is not a string")
  }
  if $install_wantedby != undef and is_string($install_wantedby) == false {
    fail("systemd::${name}::unit::install_wantedby is not a string")
  }
  if $workingdirectory != undef and is_string($workingdirectory) == false {
    fail("systemd::${name}::unit::workingdirectory is not a string")
  }

  if $service_execstartpre != undef and is_array($service_execstartpre) == false {
    fail("systemd::${name}::unit::service_execstartpre is not an Array")
  }

  if is_string($service_type) {
    validate_re($service_type, [ '^simple$', '^forking$', '^oneshot$', '^dbus$', '^notify$', '^idle$' ],
      "systemd::unit::${name}::ensure does not match the regex.")
  } else {
    fail("systemd::unit::${name}::ensure is not a string.")
  }

  if $service_timeoutstartsec != undef {
    if is_string($service_timeoutstartsec) {
      validate_re($service_timeoutstartsec, [ '^infinity$', '(([0-9]+h(our)?)?([0-9]+m(in)?)?([0-9]+s(ec)?([0-9]+ms)?)?)' ],
        "systemd::unit::${name}::service_timeoutstartsec must match either '^infinity$' or '(([0-9]+h(our)?)?([0-9]+m(in)?)?([0-9]+s(ec)?([0-9]+ms)?)?)'")
      $service_timeoutstartsec_real = $service_timeoutstartsec
    } elsif is_integer($service_timeoutstartsec) {
      validate_integer($service_timeoutstartsec, undef, 0)
      $service_timeoutstartsec_real = $service_timeoutstartsec
    } else {
      fail("system::unit::${name}::service_timeoutstartsec is not a string nor an integer")
    }
  }

  if $service_restartsec != undef {
    if is_string($service_restartsec) {
      validate_re($service_restartsec, [ '^infinity$', '(([0-9]+h(our)?)?([0-9]+m(in)?)?([0-9]+s(ec)?([0-9]+ms)?)?)' ],
        "systemd::unit::${name}::service_restartsec must match either '^infinity$' or '(([0-9]+h(our)?)?([0-9]+m(in)?)?([0-9]+s(ec)?([0-9]+ms)?)?)'")
      $service_restartsec_real = $service_restartsec
    } elsif is_integer($service_restartsec) {
      validate_integer($service_restartsec, undef, 0)
      $service_restartsec_real = $service_restartsec
    } else {
      fail("system::unit::${name}::service_timeoutstartsec is not a string nor an integer")
    }
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
