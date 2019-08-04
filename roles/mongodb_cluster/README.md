# mongodb ansible role 安装方式使用手册
[toc]



安装要求
------------

1. 服务端 ansible 版本号: 2.8
2. 配置/etc/ansible/hosts 文件的mongodb分组
3. 改配置只部署mongod shard1 shard2 shard3 mongos mongo_conf 并设置相应的集群
4. 执行完成后mongos 没有设置用户名,请执行按需设置
5. 改部署使用supervisor 管理所有mongo进程,如不想用请删除/etc/supervisor.d/ mongodb 相应的ini文件 然后重载reload 并update supervisor即可

Role 变量说明
--------------
|变量名称| 变量说明 |
|--------|--------|---|
|mongodb_download_url|mongodb下载地址|
|intall_link_dir|mongodb安装路径|
|shard1_config|shard1配置文件路径|

```
   #######更多变量参数配置请参照 mongodb_cluster/defaults/main.yml 
```

安装依赖
------------

python-pip_role


执行演示
----------------

配置完变量后,设置一下参数.
    - hosts: mongodb_cluster # /etc/ansible/hosts 中配置
      remote_user: root
      roles:
        - role: python-pip
        - role: mongodb_cluster

其他问题
------
遇到的其他问题请在这里补充

版权
-------
ztiao.club

编著
------------------
yiguo.shi 2019.8.6