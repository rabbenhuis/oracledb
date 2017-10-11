# net.pp
#
# Configure Oracle Net
#
# @param release Oracle Database Server release
# @param oracle_home full path to the Oracle Home directory
# @param os_user the operating system user for using the Oracle software
# @param os_group the operating group name for using the Oracle software
# @param install_dir location for response file used by netca
# @param listener_name the name of the listener
# @param listener_port the listener port
# @param log_output show all the output of the the exec actions
#
define oracledb::net (
  Enum['11.2', '12.1', '12.2'] $release       = lookup('oracledb::release'),
  String                       $oracle_home   = undef,
  String                       $os_user       = lookup('oracledb::os_user'),
  String                       $os_group      = lookup('oracledb::os_group'),
  String                       $install_dir   = lookup('oracledb::package_target'),
  String                       $listener_name = lookup('oracledb::listener_name'),
  Integer                      $listener_port = lookup('oracledb::listener_port'),
  Boolean                      $log_output    = false,
) {
  $supported_kernels = join(lookup('oracledb::kernels'), '|')
  if ($facts['kernel'] in $supported_kernels == false) {
    fail("Unrecognized operating system, please use it on a ${supported_kernels} host")
  }

  $execution_path = lookup('oracledb::execution_path')

  # Create the netca response file
  if !defined(File["${install_dir}/netca_${release}.rsp"]) {
    file { "${install_dir}/netca_${release}.rsp":
      ensure  => present,
      owner   => $os_user,
      group   => $os_group,
      mode    => '0700',
      content => epp("oracledb/netca_${release}.rsp.epp", { 'lsnr_name' => $listener_name, 'lsnr_port' => $listener_port }),
    }
  }

  exec { "Install Oracle Net ${title}":
    command     => "${oracle_home}/bin/netca /silent /responsefile ${install_dir}/netca_${release}.rsp",
    path        => $execution_path,
    user        => $os_user,
    group       => $os_group,
    environment => ["USER=${os_user}"],
    logoutput   => $log_output,
    creates     => "${oracle_home}/network/admin/listener.ora",
    require     => File["${install_dir}/netca_${release}.rsp"],
  }
}
