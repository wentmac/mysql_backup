# mysql_backup
mysql数据库定时增量和全量备份的shell
脚本很简单，使用的配置文件在Shell中都有注释，对应修改自己对应的就OK。

# 使用方法

## mysql_backup.sh
	crontab -e
	#每天凌晨3点全量备份mysql,并且把sql备份文件同步到备份服务器上。异地容灾，有备无患！
	0 3 * * * /root/mysql_backup.sh

## binlog_backup.sh
	crontab -e
	#每30分钟自动备份binglog增量mysql数据文件,并且把binlog备份文件同步到备份服务器上。异地容灾，有备无患！这个备份频率可自己根据项目情况调整。
	*/30 * * * * /root/mysql_backup.sh


