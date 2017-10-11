# opatch_upgrade
#
# Upgrade Oracle opatch of the given Oracle Home
#
# @param oracle_home full path to the Oracle Home directory
# @param os_user the operating system user for using the Oracle software
# @param os_group the operating group name for using the Oracle software
# @param package_source the location where the installation software is available
# @param package_name filename of the opatch upgrade file
# @param package_target location for installation files used by this module
# @param opatch_version opatch version of the opatch upgrade file
# @param csi_number Oracle support csi number
# @param support_id Oracle support id
# @param log_output show all the output of the the exec actions
#
define oracledb::opatch_upgrade (
  String            $oracle_home     = undef,
  String            $os_user         = lookup('oracledb::os_user'),
  String            $os_group        = lookup('oracledb::os_group_install'),
  String            $package_source  = lookup('oracledb::package_source'),
  String            $package_name    = undef,
  String            $package_target  = lookup('oracledb::package_target'),
  String            $opatch_version  = undef,
  Optional[Integer] $csi_number      = undef,
  Optional[String]  $support_id      = undef,
  Boolean           $log_output      = false,
) {
  $supported_kernels = join(lookup('oracledb::kernels'), '|')
  if ($facts['kernel'] in $supported_kernels == false) {
    fail("Unrecognized operating system, please use it on a ${supported_kernels} host")
  }

  $execution_path = lookup('oracledb::execution_path')
  $opatch_dir = "${oracle_home}/OPatch"

  if ($package_source =~ /^puppet/) {
    # Puppet install
    file { "${package_target}/${package_name}":
      ensure => present,
      owner  => $os_user,
      group  => $os_group,
      mode   => '0664',
      source => "${package_source}/${package_name}",
    }

    $install_source = $package_target
  }
  else {
    # Local install
    $install_source = $package_source
  }

  dbs_opatch_upgrade { $package_name:
    ensure        => present,
    oracle_home   => $oracle_home,
    install_dir   => $install_source,
    patch_version => $opatch_version,
  }

  if ($opatch_version < '12.2.0.1.5') {
    if (($csi_number != undef) and ($support_id != undef)) {
      exec { "Execute emocmrsp ${title} ${opatch_version}":
        command     => "${opatch_dir}/ocm/bin/emocmrsp -repeater NONE ${csi_number} ${support_id}",
        cwd         => $opatch_dir,
        environment => ["ORACLE_HOME=${oracle_home}"],
        path        => $execution_path,
        user        => $os_user,
        group       => $os_group,
        logoutput   => $log_output,
        require     => Dbs_opatch_upgrade[$package_name],
      }
    }
    else {
      # Install expect
      if !defined(Package['expect']) {
        package { 'expect':
          ensure => present,
        }
      }

      file { "${package_target}/opatch_upgrade_${title}_${opatch_version}.sh":
        ensure  => present,
        owner   => $os_user,
        group   => $os_group,
        mode    => '0775',
        content => epp('oracledb/ocm.rsp.epp', { 'opatch_dir' => $opatch_dir }),
        require => Package['expect'],
      }

      exec { "Execute ${package_target}/opatch_upgrade_${title}_${opatch_version}.sh":
        command     => "/bin/bash ${package_target}/opatch_upgrade_${title}_${opatch_version}.sh",
        cwd         => $opatch_dir,
        environment => ["ORACLE_HOME=${oracle_home}"],
        path        => $execution_path,
        user        => $os_user,
        group       => $os_group,
        logoutput   => $log_output,
        require     => [
          File["${package_target}/opatch_upgrade_${title}_${opatch_version}.sh"],
          Dbs_opatch_upgrade[$package_name]],
      }
    }
  }
}
