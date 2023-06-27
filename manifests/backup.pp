# @summary Add a backup job to backup databases via profile_backup.
#
# @param backup_cmd 
#   Command used to backup the database. Output to STDOUT. 
#   Generally mysqldump.
#
# @param backup_cmd_options
#   Options to add to the command to dump the database
#   An example would be --single-transaction.
#
# @param databases
#   A list of databases to backup. Default is back up all databases
#
# @example 
#   include profile_mysql_server::backup
class profile_mysql_server::backup (
  String            $backup_cmd,
  String            $backup_cmd_options,
  Array[String]     $databases,
) {
  if empty($databases) {
    profile_backup::client::add_cmd_job { 'profile_mysql_server_all_databases':
      backup_command => "${backup_cmd} ${backup_cmd_options} --all-databases",
      filename       => 'mysql_all_databases.dump',
    }
  } else {
    $databases.each|$db| {
      profile_backup::client::add_cmd_job { "profile_mysql_server_${db}":
        backup_command => "${backup_cmd} ${backup_cmd_options} ${db}",
        filename       => "mysql_${db}.dump",
      }
    }
  }
}
