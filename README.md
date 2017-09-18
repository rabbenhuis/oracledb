#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with oracledb](#setup)
    * [What oracledb affects](#what-oracledb-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oracledb](#beginning-with-oracledb)
4. [Usage - Configuration options and additional functionality](#usage)
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
To install an Oracle Database Server use `oracledb::install`.

### Install Oracle Database Server

#### Install Oracle Database 12.2.0.1
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

#### Install Oracle Database 12.1.0.2
```puppet
oracledb::install { '12.1.0.2_Linux_x86_64':
  version        => '12.1.0.2',
  edition        => 'EE',
  oracle_base    => '/oracle',
  oracle_home    => '/oracle/product/12.1.0.2/dbhome_1',
  package_source => 'puppet:///oracle/database',
  package_name   => 'V46095-01',
  package_target => '/oracle/install',
}
```

#### Install Oracle Database 11.2.0.4
```puppet
oracledb::install  { '11.2.0.4_Linux_x86-64':
  version           => '11.2.0.4',
  edition           => 'EE',
  ee_custom_install => true,
  ee_custom_options => 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0',
  oracle_base       => '/oracle',
  oracle_home       => '/oracle/product/11.2.0.4/dbhome_1',
  package_source    => '/software/oracle/database',
  package_name      => 'p13390677_112040_Linux-x86-64',
  package_target    => '/oracle/install', 
}
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
Location for the installation files. Defaults to '/var/tmp/install'

##### `package_extract`
Should the installation files be extracted.

##### `package_cleanup`
Should the installation files and directories be removed afterwards

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'

##### `bash_profile`
Should the bash_profile be added to the operating system user, Valid values are 'true' or 'false'. Defaults to 'true'.

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'dba'

##### `os_group_install`
The operating system for the installed Oracle software. Defaults to 'oinstall'

##### `os_group_oper`
The operating system group which is to be granted OSOPER privileges. Defaults to 'oper'

##### `os_group_backup`
The BACKUPDBA_GROUP is the OS group which is to be granted OSBACKUPDBA privileges. Defaults to 'dba'

##### `os_group_dg`
The DGDBA_GROUP is the OS group which is to be granted OSDGDBA privileges. Defaults to 'dba'

##### `os_group_km`
The KMDBA_GROUP is the OS group which is to be granted OSKMDBA privileges. Defaults to 'dba'

##### `os_group_rac`
The OSRACDBA_GROUP is the OS group which is to be granted SYSRAC privileges. Defaults to 'dba'

##### `temp_dir`
Location for temporary file(s) used by the installer. Defaults to '/tmp'

##### `cluster_nodes`
List of cluster node names.

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

## Limitations

## Development

