#!/bin/bash
# mysql_backup.sh: backup mysql databases and keep newest 5 days backup.  
#  
# ${db_user} is mysql username  
# ${db_password} is mysql password  
# ${db_host} is mysql host   
# —————————–  
#/root/mysql_backup.sh
# every 30 minute AM execute database backup
# */30 * * * * /root/mysql_backup.sh
#/etc/cron.daily
#最好放在从库中去备份，可以防止主库在备份时的锁表

# the directory for story your backup file.  #
backup_dir="/var/log/mysql/binlog/"

# 要保留的备份天数 #
backup_day=10

#数据库备份日志文件存储的路径
logfile="/var/log/binlog_backup.log"

###ssh端口号###
ssh_port=1204
###定义ssh auto key的文件###
id_rsa=/root/auth_key/id_rsa_153.141.rsa
###定义ssh auto username###
id_rsa_user=rsync
###定义要同步的远程服务器的目录路径（必须是绝对路径）###
clientPath="/home/backup/mysqlbinlog"
###定义要镜像的本地文件目录路径 源服务器（必须是绝对路径）###
serverPath=${backup_dir}
###定义生产环境的ip###
web_ip="192.168.0.2"

# date format for backup file (dd-mm-yyyy)  #
time="$(date +"%Y-%m-%d")"

# the directory for story the newest backup  #
test ! -d ${backup_dir} && mkdir -p ${backup_dir}

delete_old_backup()
{    
    echo "delete old binlog file:" >>${logfile}
    # 删除旧的备份 查找出当前目录下七天前生成的文件，并将之删除
    find ${backup_dir} -type f -mtime +${backup_day} | tee delete_binlog_list.log | xargs rm -rf
    cat delete_binlog_list.log >>${logfile}
}

rsync_mysql_binlog()
{
    # rsync 同步到其他Server中 #
    for j in ${web_ip}
    do                
        echo "mysql_binlog_rsync to ${j} begin at "$(date +'%Y-%m-%d %T') >>${logfile}
        ### 同步 ###
        rsync -avz --progress --delete --include="mysql-bin.*" --exclude="*" $serverPath -e "ssh -p "${ssh_port}" -i "${id_rsa} ${id_rsa_user}@${j}:$clientPath >>${logfile} 2>&1 
        echo "mysql_binlog_rsync to ${j} done at "$(date +'%Y-%m-%d %T') >>${logfile}
    done
}

#进入数据库备份文件目录
cd ${backup_dir}

#delete_old_backup
rsync_mysql_binlog

echo -e "========================mysql binlog backup && rsync done at "$(date +'%Y-%m-%d %T')"============================\n\n">>${logfile}
cat ${logfile}


