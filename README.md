# profile_mysql_server

![pdk-validate](https://github.com/ncsa/puppet-profile_mysql_server/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_mysql_server/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - install and configure MySQL/MariaDB Server

Oriented towards MariaDB.

Intends to offer support for stateful or stateless nodes, but generally with persistent storage for the DB.


## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This module manages additional resource dependencies for MySQL/MariaDB Server. It includes the
[puppetlabs-mysql](https://github.com/puppetlabs/puppetlabs-mysql) module, which actually installs
and performs most configuration of MySQL/MariaDB.


## Setup

Include profile_mysql_server in a puppet profile file:
```
include ::profile_mysql_server
```


## Usage

The defaults for this profile are relatively "sane" but it may be necessary to override them and/or override settings for the underlying puppetlabs/mysql module.

One of the main things that the profile can do is to create a mysql user and group with specified
UID and GIDs. It can also create associated folders:
```
$mysql_home (e.g., /var/lib/mysql)
$mysql_logdir (e.g., /var/log/mysql)
$mysql_run (e.g., /var/run/mysql)
```

The user and group and associated folders will ONLY be created if both $mysql_uid and $mysql_gid are
specified.

This functionality may be desirable a case like the following:
- The RPMs used to install MySQL/MariaDB do not create user/group with IDs that are guaranteed to be consistent, AND
- The node is stateless but has persistent storage for the DB.

If the selection of UID and GID is important you can provide IDs as follows:
```yaml
profile_mysql_server::mysql_gid: 238
profile_mysql_server::mysql_uid: 238
```

If they are not provided, it is assumed that the user and group have already been created or will be
created when the software is installed, and that the IDs are usable.

For use with a Slurm scheduler running on a stateless node that has stateful storage mounted by Puppet
at /var/lib/mysql, the following Hiera data generally makes sense (along with the possible specification
of $mysql_gid and $mysql_uid):
```yaml
profile_mysql_server::create_mysql_home: false
profile_mysql_server::dbs: {}
profile_mysql_server::other_dependencies:
  - "Mount['/var/lib/mysql']"
```


## Dependencies

[puppetlabs/mysql](https://github.com/puppetlabs/puppetlabs-mysql)


## Reference

See: [REFERENCE.md](REFERENCE.md)
