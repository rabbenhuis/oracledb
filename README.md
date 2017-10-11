#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with oracledb](#setup)
    * [What oracledb affects](#what-oracledb-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oracledb](#beginning-with-oracledb)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Install Oracle Database Server](#install-oracle-database-server)
    * [Configure Oracle Net8](#configure-oracle-net8)
    * [Upgrade OPatch Utility](#upgrade-opatch-utility)
    * [opatch](#opatch)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview
Oracle Database puppet module. Only for Puppet >= 4.3 on Linux.

## Module Description
Installs Oracle Database Server 11.2, 12.1 and 12.2 on Linux.

## Setup

### What oracledb affects

### Setup Requirements
This module requires the following puppet modules:
* [puppetlabs/stdlib](#https://forge.puppet.com/puppetlabs/stdlib) >= 4.0.0 < 5.0.0

### Beginning with oracledb

## Usage

### Install Oracle Database Server
To install an Oracle Database Server use `oracledb::install`.
```puppet
oracledb::install { '12.2.0.1_Linux_x86-64':
  version        => '12.2.0.1',
  edition        => 'EE',
  oracle_base    => '/oracle',
  oracle_home    => '/oracle/product/12.2.0.1/dbhome_1',
  package_source => '/software/oracle/database',
  package_name   => 'V839960-01',
  package_target => '/oracle/install',
}
```
Same configuration but then with Hiera lookup.
```puppet
log_output:      &log_output      true

oracle_version:  &oracle_version  '12.1.0.2'
oracle_base:     &oracle_base     '/oracle'
oracle_home:     &oracle_home     '/oracle/product/12.2.0.1/dbhome_1'
package_source:  &package_source  '/software/oracle/database'
install_dir:     &install_dir     '/oracle/install'

dbs_instances:
  '12.2.0.1_Linux_x86-64':
    version:        *oracle_version
    edition:        'EE'
    oracle_base:    *oracle_base
    oracle_home:    *oracle_home
    package_source: *package_source
    package_name:   'V839960-01'
    package_target: *install_dir
    log_output:     *log_output

$default_params = {}
$dbs_instances = lookup('dbs_instances', Hash, 'first', {})
create_resources('oracledb::install', $dbs_instances, $default_params)
```

### Configure Oracle Net8
To configure Oracle Net8 use `oracledb::net`.
```puppet
oracledb::net{ 'config net8':
  release     => '12.2',
  oracle_home => '/oracle/product/12.2.0.1/dbhome_1',
  install_dir => '/oracle/install',
  log_output  => true,
}
```
Same configuration but then with Hiera lookup.
```puppet
net8_instances:
  'config net8':
    release:     '12.2'
    oracle_home: *oracle_home
    install_dir: *install_dir
    log_output:  *log_output

$default_params = {}
$net8_instances = lookup('net8_instances', Hash, 'first', {})
create_resources('oracledb::net', $net8_instances, $default_params)
```

### Upgrade OPatch utility
To upgrade the OPatch utility use `oracledb::opatch_upgrade`.
```puppet
oracledb::opatch_upgrade { '122010_opatch_upgrade':
  oracle_home    => '/oracle/product/12.2.0.1/dbhome_1',
  package_source => '/software/oracle/database',
  package_name   => 'p6880880_122010_LINUX.zip',
  package_target => '/oracle/install',
  opatch_version => '12.2.0.1.9',
}
```
Same configuration but then with Hiera lookup.
```puppet
opatch_upgrade_instances:
  '122010_opatch_upgrade':
    oracle_home:    *oracle_home
    package_source: *package_source
    package_name:   'p6880880_122010_LINUX.zip'
    package_target: *install_dir
    opatch_version: '12.2.0.1.9'
    log_output:     *log_output

$default_params = {}
$opatch_upgrade_instances = lookup('opatch_upgrade_instances', Hash, 'first', {})
create_resources('oracledb::opatch_upgrade', $opatch_upgrade_instances', $default_params)
```

### opatch
To apply an OPatch on the Oracle product home use `oracledb::opatch`.
```puppet
oracledb::opatch { 'p21948354':
  oracle_home  => '/oracle/product/12.1.0.2/dbhome_1',
  patch_id     => '21948354',
  patch_file   => 'p21948354_121020_Linux-x86-64.zip',
  patch_source => '/software/oracle/database',
  install_dir  => '/oracle/install',
  ocmrf        => true,
}
```
Same configuration but then with Hiera lookup.
```puppet
opatch_instances:
  'p21948354':
    oracle_home:  *oracle_home
    patch_id:     '21948354'
    patch_file:   'p21948354_121020_Linux-x86-64.zip'
    patch_source: *package_source
    install_dir:  *install_dir
    ocmrf:        true
    log_output:   *log_output
  'p22139226':
    oracle_home:  *oracle_home
    patch_id:     '22139226'
    patch_file:   'p22139226_121020_Linux-x86-64.zip'
    patch_source: *package_source
    install_dir:  *install_dir
    ocmrf:        true
    log_output:   *log_output

$default_params = {}
$opatch_instances = lookup('opatch_instances', Hash, 'first', {})
create_resources('oracledb::opatch', $opatch_instances, $default_params)
```

## Reference

### Classes

#### Public classes

#### Private classes

### Defines

#### oracledb::install

##### `version`
The Oracle Database Server version. Valid values are 11.2.0.1, 11.2.0.3, 11.2.0.4, 12.1.0.1, 12.1.0.2 or 12.2.0.1.

##### `edition`
The Oracle Database Server edition. Valid values are 'SE', 'EE' or 'SEONE'. Defauls to 'SE'.

##### `ee_custom_install`
Enable or disable install custom components. Valid values are 'true' or 'false'. Defaults to 'false'.

##### `ee_custom_options`
List of Enterprise Edition options to be installed.

##### `oracle_base`
Full path to the Oracle Base directory.

##### `oracle_home`
Full path to the Oracle Home directory inside Oracle Base.

##### `ora_inventory_dir`
Full path to the Oracle Inventory location directory.

##### `package_source`
The location where the installation software is available. Defaults to 'puppet:///modules/oracledb'.

##### `package_name`
Filename of the installation software.

##### `package_target`
Location for the installation files. Defaults to '/var/tmp/install'.

##### `package_extract`
Should the installation files be extracted. Valid values are 'true' or 'false'. Defaults to 'true'.

##### `package_cleanup`
Should the installation files and directories be removed afterwards. Valid values are 'true' or 'false'. Defaults to 'true'.

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'.

##### `bash_profile`
Should the bash_profile be added to the operating system user, Valid values are 'true' or 'false'. Defaults to 'true'.

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'dba'.

##### `os_group_install`
The operating system for the installed Oracle software. Defaults to 'oinstall'.

##### `os_group_oper`
The operating system group which is to be granted OSOPER privileges. Defaults to 'oper'.

##### `os_group_backup`
The BACKUPDBA_GROUP is the OS group which is to be granted OSBACKUPDBA privileges. Defaults to 'dba'.

##### `os_group_dg`
The DGDBA_GROUP is the OS group which is to be granted OSDGDBA privileges. Defaults to 'dba'.

##### `os_group_km`
The KMDBA_GROUP is the OS group which is to be granted OSKMDBA privileges. Defaults to 'dba'.

##### `os_group_rac`
The OSRACDBA_GROUP is the OS group which is to be granted SYSRAC privileges. Defaults to 'dba'.

##### `temp_dir`
Location for temporary file(s) used by the installer. Defaults to '/tmp'.

##### `cluster_nodes`
List of cluster node names.

##### `log_output`
Show all the output of the the exec actions. Valid values are 'true' or 'false'. Defaults to 'false'.

#### oracledb::net

##### `release`
The Oracle Database Server release. Valid values are '11.2', '12.1' or '12.2'.

##### `oracle_home`
The full path to the Oracle Home directory.

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'.

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'dba'.

##### `install_dir`
Location for response file used by netca. Defaults to '/var/tmp/install'.

##### `listener_name`
The name of the listener. Defaults to 'LISTENER'.

##### `listener_port`
The listener port. Defaults to 1521.

##### `log_output`
Show all the output of the the exec actions. Valid values are 'true' or 'false'. Defaults to 'false'.

#### oracledb::opatch_upgrade

##### `oracle_home`
The full path to the Oracle Home directory.

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'.

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'oinstall'.

##### `package_source`
The location where the installation software is available. Defaults to 'puppet:///modules/oracledb/'.

##### `package_name`
The filename of the opatch upgrade file.

##### `package_target`
The location for installation files used by this module. Defaults to '/var/tmp/install'.

##### `opatch_version`
The opatch version of the opatch upgrade file.

##### `csi_number`
The Oracle support csi number.

##### `support_id`
The Oracle support id.

##### `log_output`
Show all the output of the the exec actions. Valid values are 'true' or 'false'. Defaults to 'false'.

#### oracledb::opatch

##### `ensure`
If the patch should be applied or removed. Valid values are 'present' or 'absent'. Defaults to 'present'.

##### `oracle_home`
The full path to the Oracle Home directory.

##### `patch_id`
The id of the opatch.

##### `patch_file`
the name of the opatch patch file.

##### `patch_source`
The location where the opatch patch file is available. Defaults to 'puppet:///modules/oracledb'.

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'.

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'dba'.

##### `install_dir`
The location for the extracted patch file. Defaults to '/var/tmp/install'.

##### `ocmrf`
Whether should the ocm response file be used. Valid values are 'true' or 'false'. Defaults to 'false'.

##### `use_opatch_auto`
Should the opatch auto command be used. Valid values are 'true' or 'false'. Defaults to 'false'.

##### `log_output`
Show all the output of the the exec actions. Valid values are 'true' or 'false'. Defaults to 'false'.

### Facts

#### `oracledb::orainventory_dir`
Returns the Oracle Inventory Directory if it exists. Otherwise returns it 'NotFound'.

#### `oracledb::oracle_homes`
Returns a comma seperated list of existing Oracle Home directories. Otherwise it returns 'NotFound'.

### Types

#### dbs_software_directories

##### `oracle_base_dir`
Full path to the Oracle Base directory.

##### `package_target_dir`
Location for the installation files. Defaults to '/var/tmp/install'

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'oinstall'

#### dbs_opatch_upgrade

##### `oracle_home`
Full path to the Oracle Home directory.

##### `install_dir`
The location of the patch file. Defaults to '/var/tmp/install'.

##### `patch_version`
OPatch version of the opatch upgrade file.

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'oinstall'

#### dbs_opatch

##### `oracle_home`
Full path to the Oracle Home directory.

##### `patch_dir`
The location off the extracted patch folder.

##### `ocmrf_file`
The full path to the ocm response file.

##### `use_opatch_auto`
Should the opatch auto command be used. Valid values are 'true' or 'false'. Defaults to 'false'.

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'oinstall'

## Limitations

## Development

