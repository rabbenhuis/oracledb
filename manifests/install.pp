# install
#
# Install the Oracle Database Server software.
#
# @param version Oracle installation version
# @param edition Oracle installation ediion
# @param ee_custom_install enable or disable install custom components
# @param ee_custom_options list of Enterprise Edition options to be installed
# @param oracle_base full path to the Oracle Base directory
# @param oracle_home full path to the Oracle Home directory inside Oracle Base
# @param ora_inventory_dir full path to the Oracle Inventory location directory
# @param package_source the location where the installation software is available
# @param package_name filename of the installation software
# @param package_target location for installation files used by this module
# @param package_extract should the installation files be extracted
# @param package_cleanup should the installation files and directories be removed afterwards
# @param os_user the operating system user for using the Oracle software
# @param bash_profile should the bash_profile be added to the operating system user
# @param os_group the operating group name for using the Oracle software
# @param os_group_install the operating system for the installed Oracle software
# @param os_group_oper the operating system group which is to be granted OSOPER privileges
# @param os_group_backup The BACKUPDBA_GROUP is the OS group which is to be granted OSBACKUPDBA privileges.
# @param os_group_dg The DGDBA_GROUP is the OS group which is to be granted OSDGDBA privileges.
# @param os_group_km The KMDBA_GROUP is the OS group which is to be granted OSKMDBA privileges.
# @param os_group_rac The OSRACDBA_GROUP is the OS group which is to be granted SYSRAC privileges.
# @param temp_dir location for temporaray file used by the installer
# @param cluster_nodes cluster node names
# @param log_output show all the output of the the exec actions
#
define oracledb::install (
  Enum['11.2.0.1', '11.2.0.3', '11.2.0.4', '12.1.0.1', '12.1.0.2', '12.2.0.1'] $version           = undef,
  Enum['SE', 'EE', 'SEONE']                                                    $edition           = 'SE',
  Boolean                                                                      $ee_custom_install = false,
  Optional[String]                                                             $ee_custom_options = undef,
  String                                                                       $oracle_base       = undef,
  String                                                                       $oracle_home       = undef,
  Optional[String]                                                             $ora_inventory_dir = undef,
  String                                                                       $package_source    = 'puppet:///modules/oracledb/',
  String                                                                       $package_name      = undef,
  String                                                                       $package_target    = '/var/tmp/install',
  Boolean                                                                      $package_extract   = true,
  Boolean                                                                      $package_cleanup   = true,
  String                                                                       $os_user           = 'oracle',
  Boolean                                                                      $bash_profile      = true,
  String                                                                       $os_group          = 'dba',
  String                                                                       $os_group_install  = 'oinstall',
  String                                                                       $os_group_oper     = 'oper',
  String                                                                       $os_group_backup   = 'dba',
  String                                                                       $os_group_dg       = 'dba',
  String                                                                       $os_group_km       = 'dba',
  String                                                                       $os_group_rac      = 'dba',
  String                                                                       $temp_dir          = '/tmp',
  Optional[String]                                                             $cluster_nodes     = undef,
  Boolean                                                                      $log_output        = false,
) {

  $supported_kernels = join(lookup('oracledb::kernels'), '|')
  if ($facts['kernel'] in $supported_kernels == false) {
    fail("Unrecognized operating system, please use it on a ${supported_kernels} host")
  }

  if ($oracle_base in $oracle_home == false) {
    fail('oracle_home folder should be under the oracle_base folder')
  }

  # Check if the oracle_home already exists
  $oracle_home_found = oracledb::oracle_home_exists($oracle_home)

  if $oracle_home_found == undef {
    $continue_installation = true
  }
  else {
    if $oracle_home_found {
      $continue_installation = false
    }
    else {
      notify { "oracledb::install ${oracle_home} does not exist": }
      $continue_installation = true
    }
  }

  $execution_path = lookup('oracledb::execution_path')

  if $ora_inventory_dir == undef {
    $ora_inventory = "${oracle_base}/oraInventory"
  }
  else {
    $ora_inventory = $ora_inventory_dir
  }

  # Ensure the Oracle Database Server software directories exist
  dbs_software_directories { "Oracle Database Server Software Directories ${version}_${title}":
    ensure             => present,
    oracle_base_dir    => $oracle_base,
    package_target_dir => $package_target,
    os_user            => $os_user,
    os_group           => $os_group_install,
  }

  if $continue_installation {
    if $package_extract {
      # Should the installation files be extracted or are we dealing with a pre-extracted directory structure

      case $version {
        '12.2.0.1': {
          $install_file1 = "${package_name}.zip"
          $total_install_files = 1
        }
        '11.2.0.1', '12.1.0.1', '12.1.0.2': {
          $install_file1 = "${package_name}_1of2.zip"
          $install_file2 = "${package_name}_2of2.zip"
          $total_install_files = 2
        }
        default: {
          # 11.2.0.3 and 11.2.0.4
          $install_file1 = "${package_name}_1of7.zip"
          $install_file2 = "${package_name}_2of7.zip"
          $total_install_files = 2
        }
      }

      case $package_source {
#        /^http/: {
#          # HTTP(S) install
#        }
        /^puppet/: {
          # Puppet install
          file { "${package_target}/${install_file1}":
            ensure  => present,
            owner   => $os_user,
            group   => $os_group,
            mode    => '0775',
            source  => "${package_source}/${install_file1}",
            require => Dbs_software_directories["Oracle Database Server Software Directories ${version}_${title}"],
            before  => Exec["Extract ${install_file1}"],
          }

          if ($total_install_files > 1) {
            file { "${package_target}/${install_file2}":
              ensure  => present,
              owner   => $os_user,
              group   => $os_group,
              mode    => '0775',
              source  => "${package_source}/${install_file2}",
              require => File["${package_target}/${install_file1}"],
              before  => Exec["Extract ${install_file2}"],
            }
          }

          $install_source = $package_target
        }
        /^\//: {
          # Local install
          $install_source = $package_source
        }
        default: {
          fail('Specify a valid local directory or puppet url')
        }
      }

      exec { "Extract ${install_file1}":
        command   => "unzip -o ${install_source}/${install_file1} -d ${package_target}/${package_name}",
        timeout   => 0,
        logoutput => $log_output,
        path      => $execution_path,
        user      => $os_user,
        group     => $os_group,
        require   => Dbs_software_directories["Oracle Database Server Software Directories ${version}_${title}"],
        before    => Exec["Install Oracle Database Server ${title}"],
      }

      if ($total_install_files > 1) {
        exec { "Extract ${install_file2}":
          command   => "unzip -o ${install_source}/${install_file2} -d ${package_target}/${package_name}",
          timeout   => 0,
          logoutput => $log_output,
          path      => $execution_path,
          user      => $os_user,
          group     => $os_group,
          require   => Exec["Extract ${install_file1}"],
          before    => Exec["Install Oracle Database Server ${title}"],
        }
      }
    }

    # Generate installer response file
    if !defined(File["${package_target}/db_install_${version}_${title}.rsp"]) {
      file { "${package_target}/db_install_${version}_${title}.rsp":
        ensure  => present,
        content => epp("oracledb/db_install_${version}.rsp.epp",
                      { 'os_group_install'  => $os_group_install,
                        'ora_inventory_dir' => $ora_inventory,
                        'oracle_home'       => $oracle_home,
                        'oracle_base'       => $oracle_base,
                        'edition'           => $edition,
                        'ee_custom_install' => $ee_custom_install,
                        'ee_custom_options' => $ee_custom_options,
                        'os_group_dba'      => $os_group,
                        'os_group_oper'     => $os_group_oper,
                        'os_group_backup'   => $os_group_backup,
                        'os_group_dg'       => $os_group_dg,
                        'os_group_km'       => $os_group_km,
                        'os_group_rac'      => $os_group_rac,
                        'cluster_nodes'     => $cluster_nodes }),
        mode    => '0775',
        owner   => $os_user,
        group   => $os_group,
        require => Dbs_software_directories["Oracle Database Server Software Directories ${version}_${title}"],
      }
    }

    # Install the Oracle Database Server software
    exec { "Install Oracle Database Server ${title}":
      command     => "/bin/bash -c 'unset DISPLAY;${package_target}/${package_name}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${package_target}/db_install_${version}_${title}.rsp'",
      creates     => "${oracle_home}/dbs",
      environment => ["USER=${os_user}", "LOGNAME=${os_user}"],
      timeout     => 0,
      returns     => [6, 0],
      path        => $execution_path,
      user        => $os_user,
      group       => $os_group_install,
      cwd         => $oracle_base,
      logoutput   => $log_output,
      require     => File["${package_target}/db_install_${version}_${title}.rsp"],
    }

    # run root.sh script
    exec { "Run root.sh script ${title}":
      command   => "${oracle_home}/root.sh",
      cwd       => $oracle_base,
      path      => $execution_path,
      creates   => '/etc/oratab',
      user      => 'root',
      group     => 'root',
      logoutput => $log_output,
      require   => Exec["Install Oracle Database Server ${title}"],
      before    => Exec["Run orainstRoot.sh script ${title}"],
    }

    exec { "Run orainstRoot.sh script ${title}":
      command   => "${ora_inventory}/orainstRoot.sh",
      cwd       => $oracle_base,
      path      => $execution_path,
      creates   => '/etc/oraInst.loc',
      user      => 'root',
      group     => 'root',
      logoutput => $log_output,
      require   => Exec["Run root.sh script ${title}"],
    }

    if ($bash_profile) {
      if !defined(File["/home/${os_user}/.bash_profile"]) {
        file { "/home/${os_user}/.bash_profile":
          ensure  => present,
          owner   => $os_user,
          group   => $os_group,
          mode    => '0644',
          content => regsubst(epp('oracledb/bash_profile.epp', { 'oracle_base' => $oracle_base,
                                                                 'oracle_home' => $oracle_home,
                                                                 'temp_dir'    => $temp_dir }), '\r\n', "\n", 'EMG'),
        }
      }
    }

    # Cleanup
    if ($package_cleanup) {
      if ($package_extract) {
        exec { "Remove Oracle Database Server extract folder ${title}":
          command => "rm -rf ${package_target}/${package_name}",
          cwd     => $oracle_base,
          user    => 'root',
          group   => 'root',
          path    => $execution_path,
          require => [Exec["Install Oracle Database Server ${title}"],
                      Exec["Run orainstRoot.sh script ${title}"], ]
        }

        if ($package_source =~ /^puppet/) {
          exec { "Remove Oracle Database Server Install File ${install_file1}":
            command => "rm -f ${package_target}/${install_file1}",
            cwd     => $oracle_base,
            user    => 'root',
            group   => 'root',
            path    => $execution_path,
            require => [Exec["Install Oracle Database Server ${title}"],
                        Exec["Run orainstRoot.sh script ${title}"], ]
          }

          if ($total_install_files > 1) {
            exec { "Remove Oracle Database Server Install File ${install_file2}":
              command => "rm -f ${package_target}/${install_file2}",
              cwd     => $oracle_base,
              user    => 'root',
              group   => 'root',
              path    => $execution_path,
              require => [Exec["Install Oracle Database Server ${title}"],
                          Exec["Run orainstRoot.sh script ${title}"], ]
            }
          }
        }
      }
    }
  }
}

