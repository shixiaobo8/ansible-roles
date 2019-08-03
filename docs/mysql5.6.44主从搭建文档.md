# 新建软件包目录
	mkdir /www/softs
	cd  /ww/softs
# 下载mysql
	wget https://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.44.tar.gz
# 安装依赖
	yum -y install make gcc-c++ cmake bison-devel  ncurses-devel
# 编译安装 make
    cmake \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/www/mysql_datas \
    -DSYSCONFDIR=/etc \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_MEMORY_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
    -DMYSQL_TCP_PORT=3306 \
    -DENABLED_LOCAL_INFILE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DEXTRA_CHARSETS=all \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci
# 编译安装
	make && make install
# 创建mysql 和 mysql  用户组
    groupadd mysql
    useradd -g mysql mysql

#  初始化mysql
    cd scripts/
    chmod +x mysql_install_db*
    cp mysql_install_db* /usr/local/mysql/bin/
    ln -s /usr/local/mysql/bin/* /usr/bin/
    cd ..
    cd support-files
    chmod +x mysql.server
    cp mysql.server /etc/init.d/mysqld
# mysql 配置文件主服务器配置文件如下:
vim /etc/my.cnf (主)

    [client]
    port		= 3306
    socket		= /tmp/mysql.sock
    [mysqld_safe]
    socket		= /tmp/mysql.sock

    [mysqld]
    symbolic-links = 0
    user		= mysql
    pid-file	= /www/mysql_datas/mysqld.pid
    socket		= /tmp/mysql.sock
    port		= 3306
    datadir		= /www/mysql_datas
    log_error = /www/mysql_datas/error.log
    slow-query-log-file = /www/mysql_datas/mysql-slow.log
    long_query_time = 1
    character-set-server=utf8
    collation-server=utf8_unicode_ci
    init-connect='SET NAMES utf8'

    ###### master and slave replication ########
    server-id = 1
    log_bin = mysql-bin
    expire_logs_days	= 10
    max_binlog_size		= 200M
    log_bin=mysql-bin
    binlog_do_db=im_backend
    binlog_ignore_db=test
    binlog_ignore_db=information_schema
    binlog_ignore_db=mysql

#  初始化mysql data 目录权限
	chown -R  mysql:mysql /data
# 初始化mysql
	mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/www/mysql_datas
# 启动mysql 
	/etc/init.d/mysqld start

启动成功，安装完成后续配置再根据业务自己定制！

# 建立主从:

# 授权主从账号:
    grant replication slave on *.* to 'copy'@'172.19.0.235' identified by '123456';
    grant replication slave on *.* to 'copy'@'172.19.0.235' identified by 'copy@123@#$';

# 重启 主服务器mysqld
	/etc/init.d/mysqld restart

#从服务器my.cnf 配置
    [client]
    port		= 3306
    socket		= /tmp/mysql.sock
    [mysqld_safe]
    socket		= /tmp/mysql.sock

    [mysqld]
    symbolic-links = 0
    user		= mysql
    pid-file	= /www/mysql_datas/mysqld.pid
    socket		= /tmp/mysql.sock
    port		= 3306
    datadir		= /www/mysql_datas
    log_error = /www/mysql_datas/error.log
    slow-query-log-file = /www/mysql_datas/mysql-slow.log
    long_query_time = 1
    character-set-server=utf8
    collation-server=utf8_unicode_ci
    init-connect='SET NAMES utf8'

    ###### master and slave replication ########
    server-id = 2
    log_bin = mysql-bin
    expire_logs_days	= 10
    max_binlog_size		= 200M
    binlog_do_db=im_backend
    binlog_ignore_db=test
    binlog_ignore_db=information_schema
    binlog_ignore_db=mysql


# 连接mysql5.5后不能再配置文件中配置host，user参数，应该使用命令行，其中的位置号需要通过show master status \G;在主服务器上查看,执行下面的一条命令前先stop slave;
    change master to master_host='172.19.0.236', master_user='copy',		master_password='copy@123@#$',MASTER_LOG_FILE='mysql-bin.000010', MASTER_LOG_POS=120；
# 开始同步
	start slave
# 在从服务器上执行如下命令,可以查看到具体的同步结果.
	show slave status \G;
# 如果io 线程和 sql 线程的 status 为 yes 那么，就同步正常.如:
			Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
# 设置从库只读
	set global read_only=1;

# mysql 删除binlog的方法
    PURGE MASTER LOGS BEFORE '2010-10-17 00:00:00';
    interactive_timeout = 120
        wait_timeout = 120
 	max_allowed_packet = 32M