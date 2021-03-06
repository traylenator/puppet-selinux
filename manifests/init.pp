# Class: selinux
#
# Description
#  This class manages SELinux on RHEL based systems.
#
# Parameters:
#  - $mode (enforcing|permissive|disabled) - sets the operating state for SELinux.
#  - $type (enforcing|permissive|disabled) - sets the operating state for SELinux.
#  - $sx_mod_dir (absolute_path) - sets the operating state for SELinux.
#  - $makefile (string) - the default makefile to use for module compilation
#  - $manage_package (boolean) - manage the package for selinux tools
#  - $package_name (string) - sets the name for the selinux tools package
#
# Actions:
#  This module will configure SELinux and/or deploy SELinux based modules to running
#  system.
#
# Requires:
#  - Class[stdlib]. This is Puppet Labs standard library to include additional methods for use within Puppet. [https://github.com/puppetlabs/puppetlabs-stdlib]
#
# Sample Usage:
#  include selinux
#
class selinux (
  $mode           = $::selinux::params::mode,
  $type           = $::selinux::params::type,
  $sx_mod_dir     = $::selinux::params::sx_mod_dir,
  $makefile       = $::selinux::params::makefile,
  $manage_package = $::selinux::params::manage_package,
  $package_name   = $::selinux::params::package_name,

  ### START Hiera Lookups ###
  $boolean        = undef,
  $fcontext       = undef,
  $module         = undef,
  $permissive     = undef,
  $port           = undef,
  ### END Hiera Lookups ###

) inherits selinux::params {

  $mode_real = $mode ? {
    /\w+/   => $mode,
    default => 'undef',
  }

  $type_real = $type ? {
    /\w+/   => $type,
    default => 'undef',
  }

  validate_absolute_path($sx_mod_dir)
  validate_re($mode_real, ['^enforcing$', '^permissive$', '^disabled$', '^undef$'], "Valid modes are enforcing, permissive, and disabled.  Received: ${mode}")
  validate_re($type_real, ['^targeted$', '^minimum$', '^mls$', '^undef$'], "Valid types are targeted, minimum, and mls.  Received: ${type}")
  validate_string($makefile)
  validate_bool($manage_package)
  validate_string($package_name)

  class { '::selinux::package':
    manage_package => $manage_package,
    package_name   => $package_name,
  } ->
  class { '::selinux::config': }

  if $boolean {
    create_resources ( 'selinux::boolean', hiera_hash('selinux::boolean') )
  }
  if $fcontext {
    create_resources ( 'selinux::fcontext', hiera_hash('selinux::fcontext') )
  }
  if $module {
    create_resources ( 'selinux::module', hiera_hash('selinux::module') )
  }
  if $permissive {
    create_resources ( 'selinux::fcontext', hiera_hash('selinux::permissive') )
  }
  if $port {
    create_resources ( 'selinux::port', hiera_hash('selinux::port') )
  }
}
