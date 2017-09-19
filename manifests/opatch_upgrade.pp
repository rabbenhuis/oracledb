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
# @param package_cleanup should the installation files and directories be removed afterwards
# @param opatch_version opatch version of the opatch upgrade file
# @param csi_number Oracle support csi number
# @param support_id Oracle support id
# @param log_output show all the output of the the exec actions
#
define oracledb::opatch_upgrade (
  String            $oracle_home     = undef,
  String            $os_user         = 'oracle',
  String            $os_group        = 'dba',
  String            $package_source  = 'puppet:///modules/oracledb/',
  String            $package_name    = undef,
  String            $package_target  = '/var/tmp/install',
  Boolean           $package_cleanup = true,
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

  # Check if oracle_home exists
  $oracle_home_found = oracledb::oracle_home_exists($oracle_home)

  if $oracle_home_found == undef {
    $continue_upgrade = false
  }
  else {
    if $oracle_home_found {
      # Check the opatch version
      $installed_opatch_version = oracledb::current_opatch_version($oracle_home)

      if ($installed_opatch_version == undef) or ($installed_opatch_version == 'NotFound') {
        $continue_upgrade = false
      }
      else {
        if ($installed_opatch_version == $opatch_version) {
          $continue_upgrade = false
        }
        else {
          notify { "Current OPatch version (${installed_opatch_version}) doesn't equal ${opatch_version}. So patching is required": }
          $continue_upgrade = true
        }
      }
    }
    else {
      $continue_upgrade = false
    }
  }

  if ($continue_upgrade) {
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

    # Create a backup of the current OPatch directory
    file { "${opatch_dir}_${installed_opatch_version}":
      ensure  => directory,
      source  => "file://${opatch_dir}",
      recurse => true,
      before  =>  File[$opatch_dir],
    }

    # Delete opatch directory
    file { $opatch_dir:
      ensure  => absent,
      recurse => true,
      force   => true,
      alias   => "Delete ${opatch_dir}",
    }

    # Extract the opatch upgrade file
    exec { "Extract ${install_source}/${package_name}":
      command   => "unzip -o ${install_source}/${package_name} -d ${oracle_home}",
      path      => $execution_path,
      user      => $os_user,
      group     => $os_group,
      logoutput => $log_output,
      require   => File["Delete ${opatch_dir}"],
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
          require     => File["Extract ${install_source}/${package_name}"],
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
            Exec["Extract ${install_source}/${package_name}"]],
        }
      }
    }

    if ($package_cleanup) {
      if ($package_source =~ /^puppet/) {
        exec { "Remove ${package_target}/${package_name}":
          command   => "rm -f ${package_target}/${package_name}",
          user      => 'root',
          group     => 'root',
          logoutput => $log_output,
          path      => $execution_path,
          require   => Exec["Extract ${install_source}/${package_name}"],
        }
      }
    }
  }
}
