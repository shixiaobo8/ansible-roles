# mongodb 使用ansible手册
[toc]



安装要求
------------

1. 服务端 ansible 版本号: 2.8
2. 配置/etc/ansible/hosts 文件的mongodb分组

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


版权
-------
ztiao.club

编著
------------------
yiguo.shi 2019.8.6