# @summary Manage a MySQL/MariaDB server configuration.
#
# @param create_mysql_home
#   Should the mysql_home be created?
#
#   NOTE: $mysql_gid and $mysql_uid must also be specified for this to do anything.
#
# @param dbs
#   Raw data to define mysql::db resources.
#
# @param manage_yumrepo
#   Should the mysql Yumrepo be managed? Must also provide
#   Hiera data for the $yumrepo param.
#
# @param mysql_gid
#   Optionally define the GID for the mysql group (and PGID for the mysql user).
#   Must also provide $mysql_uid. If both $mysql_gid and $mysql_uid are provided,
#   the mysql user and group will be created as will various directories.
#
# @param mysql_groupname
#   The name of the mysql group.
#
#   NOTE: $mysql_gid and $mysql_uid must also be specified for this to do anything.
#
# @param mysql_home
#   The home dir of the mysql user.
#
#   NOTE: $mysql_gid and $mysql_uid must also be specified for this to do anything.
#
# @param mysql_logdir
#   Location of MySQL log files.
#
#   NOTE: $mysql_gid and $mysql_uid must also be specified for this to do anything.
#
# @param mysql_rundir
#   Location of run directory (generally a sub-directory of /var/run/).
#
#   NOTE: $mysql_gid and $mysql_uid must also be specified for this to do anything.
#
# @param mysql_uid
#   Optionally define the UID of the mysql user. Must also provide $mysql_gid. If
#   both $mysql_gid and $mysql_uid are provided, the mysql user and group will be
#   created as will various directories.
#
# @param mysql_username
#   Username of the mysql user.
#
#   NOTE: $mysql_gid and $mysql_uid must also be specified for this to do anything.
#
# @param other_dependencies
#   Other depencies to handle prior to other MySQL setup, specified as resources, e.g.:
#     - "Mount['/var/lib/mysql']"
#
# @param yumrepo
#   Raw params for a yumrepo resource from which to install MySQL/MariaDB.
#
# @example
#   include profile_mysql_server
#
class profile_mysql_server (

  Boolean           $create_mysql_home,
  Hash              $dbs,
  Boolean           $manage_yumrepo,
  String            $mysql_groupname,
  String            $mysql_home,
  String            $mysql_logdir,
  String            $mysql_rundir,
  String            $mysql_username,
  String            $config_file,
  String            $includedir,
  String            $log_error,
  String            $pid_file,
  Array             $other_dependencies,
  Hash              $yumrepo,
  Optional[Integer] $mysql_gid,
  Optional[Integer] $mysql_uid,

) {

  include ::mysql::server

    $dir_defaults = {
      before => Class['::mysql::server::install'],
      ensure => directory,
      group  => $mysql_groupname,
      owner  => $mysql_username,
    }

    if $mysql_logdir {
      file { $mysql_logdir:
        * => $dir_defaults,
      }
    }
    if $mysql_rundir {
      file { $mysql_rundir:
        * => $dir_defaults,
      }
    }

    if $create_mysql_home {
      # Ensure parents of target dir exist, if needed (excluding / )
      $dirparts = reject( split( $mysql_home, '/' ), '^$' )
      $numparts = size( $dirparts )
      if ( $numparts > 1 ) {
        each( Integer[2,$numparts] ) |$i| {
          ensure_resource(
            'file',
            reduce( Integer[2,$i], $mysql_home ) |$memo, $val| { dirname( $memo ) },
            { 'ensure' => 'directory' }
          )
        }
      }

      file { $mysql_home:
        * => $dir_defaults,
      }
    }

    group { $mysql_groupname:
      ensure => 'present',
      before => Class['::mysql::server::install'],
      gid    => 27,
    }

    user { $mysql_username:
      ensure         => 'present',
      before         => Class['::mysql::server::install'],
      uid            => 27,
      gid            => 27,
      forcelocal     => true,
      home           => $mysql_home,
      managehome     => $create_mysql_home,
      password       => '!!',
      purge_ssh_keys => true,
      shell          => '/sbin/nologin',
      comment        => 'MySQL server',
    }

  $other_dependencies.each | $dep | {
    $dep -> Class['::mysql::server::install']
  }

  if ! empty($yumrepo) {
    if $manage_yumrepo {
      $yumrepo_defaults = {
        ensure  => present,
        enabled => true,
      }
      ensure_resources( 'yumrepo', $yumrepo, $yumrepo_defaults )
    }
    Yumrepo[$yumrepo] -> Class['::mysql::server::install']
  }

  each($dbs) | $db_name, $db_data | {
    mysql::db { $db_name:
      * => $db_data,
    }
  }

}
