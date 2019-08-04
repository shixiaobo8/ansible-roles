zabbix server role 安装
=========
[toc]


注意事项说明
------------
```
	1. 由于安装zabbix-java 因此请安装 先执行 jdk1.8 roles
	2. 依赖包 mysql 未包含在程序中需要手动 先执行  zabbix 的mysql 数据库重要配置信息在其中 mysql 密码变量请务必配置正确
 	3. 其他依赖 tengine_source / php7  已经导入roles中
```

role 变量说明:
--------------
|变量名称|变量说明|
|-------|------|
|zabbix_download_url|zabbix下载地址|
|zabbix_dingding_url|zabbix 钉钉告警机器人配置信息|
|zabbix_server_ip|zabbix服务器ip地址|
|zabbix_web_url|zabbix web 访问地址|
|zabbix_server_mysql_host|zabbix mysql 主机|
|zabbix_server_mysql_root_pwd|zabbix mysql root 用户密码|
|zabbix_mail_user|邮件告警地址|
......



执行示例
----------------
     ansible-playbook zabbix_server_roles.yml 

    - hosts: codis2
      remote_user: root
      roles:
        #- role: linux_jdk1.8
        - role: tengine_source
        - role: php7
        - role: zabbix_server


作者
-------
yiguo.shi 2019.8.7