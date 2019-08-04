zabbix agentd role 安装
=========
[toc]


注意事项说明
------------
```
	1. 请注意其中的几个重要变量
	2. 使用自动注册注册到服务端
	3. 在zabbix_agentd.conf 中配置了几个重要参数,其中system.uname  中可以加入自动注册的自主变量，
```

role 变量说明:
--------------
|变量名称|变量说明|
|-------|------|
|1111|zabbix下载地址|



执行示例
----------------
     ansible-playbook zabbix_agentd_roles.yml 

    - hosts: all
      remote_user: root
      roles:
        - role: zabbix_agentd


作者
-------
yiguo.shi 2019.8.7