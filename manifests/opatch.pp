# opatch
#
# Install Oracle Database Server Patches
#
# @param ensure if the patch should be applied or removed
# @param oracle_home full path to the Oracle Home directory
# @param patch_id the id of the opatch
# @param patch_file the opatch patch file
# @param patch_source the location where the opatch patch file is available
# @param os_user the operating system user for using the Oracle software
# @param os_group the operating group name for using the Oracle software
# @param install_dir location for the extracted patch file
# @param ocmrf should the ocm response file be used
# @param use_opatch_auto should the opatch auto command be used
# @param log_output show all the output of the the exec actions
#
define oracledb::opatch (
  Enum['present', 'absent'] $ensure          = 'present',
  String                    $oracle_home     = undef,
  String                    $patch_id        = undef,
  String                    $patch_file      = undef,
  String                    $patch_source    = lookup('oracledb::package_source'),
  String                    $os_user         = lookup('oracledb::os_user'),
  String                    $os_group        = lookup('oracledb::os_group'),
  String                    $install_dir     = lookup('oracledb::package_target'),
  Boolean                   $ocmrf           = false,
  Boolean                   $use_opatch_auto = false,
  Boolean                   $log_output      = false,
) {
  $supported_kernels = join(lookup('oracledb::kernels'), '|')
  if ($facts['kernel'] in $supported_kernels == false) {
    fail("Unrecognized operating system, please use it on a ${supported_kernels} host")
  }

  $execution_path = lookup('oracledb::execution_path')

  if ($patch_source =~ /^puppet/) {
    if !defined(File["${install_dir}/${patch_file}"]) {
      file { "${install_dir}/${patch_file}":
        ensure => present,
        source => "${patch_source}/${patch_file}",
        owner  => $os_user,
        group  => $os_group,
        mode   => '0775',
        before => Exec["Extract opatch ${patch_file} ${title}"],
      }
    }

    $install_source = $install_dir
  }
  else {
    $install_source = $patch_source
  }

  exec { "Extract opatch ${patch_file} ${title}":
    command   => "unzip -n ${install_source}/${patch_file} -d ${install_dir}",
    path      => $execution_path,
    user      => $os_user,
    group     => $os_group,
    logoutput => $log_output,
    creates   => "${install_dir}/${patch_id}",
    before    => Dbs_opatch[$patch_id],
  }

  if ($ocmrf) {
    dbs_opatch { $patch_id:
      ensure          => $ensure,
      oracle_home     => $oracle_home,
      patch_dir       => "${install_dir}/${patch_id}",
      ocmrf_file      => "${oracle_home}/OPatch/ocm.rsp",
      use_opatch_auto => $use_opatch_auto,
    }
  }
  else {
    dbs_opatch { $patch_id:
      ensure          => $ensure,
      oracle_home     => $oracle_home,
      patch_dir       => "${install_dir}/${patch_id}",
      use_opatch_auto => $use_opatch_auto,
    }
  }
}
