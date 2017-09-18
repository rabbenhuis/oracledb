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
Installs and configures Oracle Database Server 11.2, 12.1 and 12.2 on Linux.

## Setup

### What oracledb affects

### Setup Requirements

### Beginning with oracledb

## Usage

## Reference

### Classes

#### Public classes

#### Private classes

### Defines

#### oracledb::install

##### `version`
The Oracle Database version. Defaults to '12.1.0.2'.
Valid values are 11.2.0.1, 11.2.0.3, 11.2.0.4, 12.1.0.1, 12.1.0.2 or 12.2.0.1.

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

##### `os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'dba'

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

##### ` os_user`
The operating system user for using the Oracle software. Defaults to 'oracle'

##### `os_group`
The operating group name for using the Oracle software. Defaults to 'oinstall'

## Limitations

## Development

