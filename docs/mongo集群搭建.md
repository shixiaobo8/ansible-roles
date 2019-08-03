# 目录
[toc]



**说明**
mongo版本：4.0.9
环境：centos


## 环境准备
```
//安装mongodb
# tar -xzvf mongodb-linux-x86_64-4.0.9.tgz
# mv mongodb-linux-x86_64-4.0.9 mongo 
# mv mongo /usr/local/

//创建目录
# mkdir -p /data/mongo/conf

# mkdir -p /data/mongo/mongos/log

# mkdir -p /data/mongo/config/data
# mkdir -p /data/mongo/config/log

# mkdir -p /data/mongo/shard1/data
# mkdir -p /data/mongo/shard1/log

# mkdir -p /data/mongo/shard2/data
# mkdir -p /data/mongo/shard2/log

# mkdir -p /data/mongo/shard3/data
# mkdir -p /data/mongo/shard3/log

//创建mongo账号
# groupadd mongo
# useradd -g mongo mongo
//修改目录权限
# chown -R mongo:mongo /usr/local/mongo
# chown -R mongo:mongo /data/mongo

```



## 部署configServer
### 配置文件
```
# vim /data/mongo/conf/config.conf

# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/mongo/config/log/mongod.log
  logRotate: rename
# Where and how to store data.
storage:
  dbPath: /data/mongo/config/data
  journal:
    enabled: true
#  engine: wiredTiger
#  mmapv1:
  wiredTiger:
     engineConfig:
        cacheSizeGB: 2

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/mongo/config/mongod.pid  # location of pidfile

# network interfaces
net:
  port: 21004
  bindIp: 0.0.0.0  # Listen to local interface only, comment to listen on all interfaces.

#security:
#security:
#  authorization: enabled
#  keyFile: /data/mongo/conf/mongo.key
#operationProfiling:

#replication:
replication:
  replSetName: config
sharding:
  clusterRole: "configsvr"
## Enterprise-Only Options

#auditLog:

#snmp:


```
bindIp绑定0.0.0.0
### 启动服务
```
# mongod -f /data/mongo/conf/config.conf
```
### 初始化配置副本集
```
//登录其他一台服务器配置
# mongo 127.0.0.1:21004
> use admin
//config变量
> config = {
    _id : "config",
     members : [
         {_id : 0, host : "172.19.0.237:21004" },
         {_id : 1, host : "172.19.0.238:21004" },
         {_id : 2, host : "172.19.0.239:21004"}
     ]
 }
 //初始化副本集
 > rs.initiate(config)
 
 //查看状态
 > rs.status()
 
```

## 部署shard(3片)


### 配置文件

```
# vim /data/mongo/conf/shard1.conf

# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /data/mongo/shard1/log/mongod.log
  logRotate: rename
# Where and how to store data.
storage:
  dbPath: /data/mongo/shard1/data
  journal:
    enabled: true
  engine: wiredTiger
#  mmapv1:
  wiredTiger:
     engineConfig:
        cacheSizeGB: 5

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /data/mongo/shard1/mongod.pid  # location of pidfile

# network interfaces
net:
  port: 21001
  bindIp: 0.0.0.0  # Listen to local interface only, comment to listen on all interfaces.


#security:
#ecurity:
#  authorization: enabled
#  keyFile: /data/mongo/conf/mongo.key
#operationProfiling:

#replication:
replication:
  replSetName: shard1
sharding:
  clusterRole: "shardsvr"
## Enterprise-Only Options

#auditLog:

#snmp:

```

- 启动服务
```
> mongod -f /data/mongo/conf/shard1.conf
```

- 初始化副本集

```
# mongo 127.0.0.1:21001
//shard1
config = {
    _id : "shard1",
     members : [
         {_id : 0, host : "172.19.0.237:21001" , arbiterOnly: true},
         {_id : 1, host : "172.19.0.238:21001" },
         {_id : 2, host : "172.19.0.239:21001" }
     ]
 }

  //初始化副本集
 > rs.initiate(config)
 
 //查看状态
 > rs.status()
 
 //shard2
config = {
    _id : "shard2",
     members : [
         {_id : 0, host : "172.19.0.237:21002" },
         {_id : 1, host : "172.19.0.238:21002" },
         {_id : 2, host : "172.19.0.239:21002" , arbiterOnly: true}
     ]
 }
 //初始化副本集
 > rs.initiate(config)
 
 //查看状态
 > rs.status()
 
//shard3
 config = {
    _id : "shard3",
     members : [
         {_id : 0, host : "172.19.0.237:21003" },
         {_id : 1, host : "172.19.0.238:21003" , arbiterOnly: true},
         {_id : 2, host : "172.19.0.239:21003" }
     ]
 }
  //初始化副本集
 > rs.initiate(config)
 
 //查看状态
 > rs.status()
```
replSetName 改为相应的shard1、shard2、shard3
path、dbPath、pidFilePath改为相应的路径

## 部署mongos
### 配置文件
```
# vim /data/mongo/conf/mongos.conf
systemLog:
  destination: file
  logAppend: true
  path: /data/mongo/mongos/log/mongos.log
processManagement:
  fork: true
  pidFilePath: /data/mongo/mongos/mongos.pid

# network interfaces
net:
  port: 21000
  bindIp: 0.0.0.0
  #监听的配置服务器,只能有1个或者3个 configs为配置服务器的副本集名字
sharding:
  configDB: config/172.19.0.237:21004,172.19.0.238:21004,172.19.0.239:21004
#security:
#    keyFile: "/data/mongo/conf/mongo.key"
```

### 启动服务
```
mongos -f /data/mongo/conf/mongos.conf
```

## 添加分片
```
//登录mongos
# mongo 127.0.0.1:21000
> use admin
> sh.addShard("shard1/172.19.0.237:21001,172.19.0.238:21001,172.19.0.239:21001")
> sh.addShard("shard2/172.19.0.237:21002,172.19.0.238:21002,172.19.0.239:21002")
> sh.addShard("shard3/172.19.0.237:21003,172.19.0.238:21003,172.19.0.239:21003")
```

## 创建账号
```
# mongo 127.0.0.1:21000
> use admin
//创建超级用户
> db.createUser({
  user: "Sadmin",
  pwd: "Pro@admin456",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "clusterManager", db : "admin" }
  ],
  passwordDigestor: "server"
})

//创建im_backend用户
> use im_backend
> db.createUser(
     {
       user:"im_backend",
       pwd:"im@Pro_2019Backend",
       roles: [ { role: "readWrite", db: "im_backend" } ]
     }
  )
  
//创建im_backend_buddy用户
> use im_backend_buddy
> db.createUser(
     {
       user:"im_backend_buddy",
       pwd:"im@Pro_2019Buddy",
       roles: [ { role: "readWrite", db: "im_backend_buddy" } ]
     }
  )


```

## 添加认证权限

### 创建key文件
```
# openssl rand -base64 756 > /etc/mongodb/conf/mongo.key
# chmod 400 /etc/mongodb/conf/mongo.key //注意修改权限，如果加认证后服务启动不了，可能问题出在这里
```

### 修改配置文件
shard*.conf和config.conf加入：
```
security:
  authorization: enabled
  keyFile: /data/mongo/conf/mongo.key

```
mongos.conf加入：
```
security:
  keyFile: /data/mongo/conf/mongo.key

```

### 关闭服务
分别关闭config、shard1-3、mongos服务，注意PRIMARY最后关闭，如：
```
config:SECONDARY> db.shutdownServer()
config:ARBITER> db.shutdownServer()
config:PRIMARY> db.shutdownServer()
```

### 开启服务
```
# mongod -f /data/mongo/conf/config.conf
# mongod -f /data/mongo/conf/shard1.conf
# mongod -f /data/mongo/conf/shard2.conf
# mongod -f /data/mongo/conf/shard3.conf
# mongod -f /data/mongo/conf/mongos.conf
```


## 创建库表
```
# mongo --port 21000 -u im_backend_buddy -p imtestbuddy --authenticationDatabase im_backend_buddy

mongos> use im_backend_buddy
switched to db im_backend_buddy

mongos> db.test2.insert({name:"dawing2"})
WriteResult({ "nInserted" : 1 })

mongos> show dbs
im_backend_buddy  0.000GB

mongos> show collections
test2

```

## 设置片键
```



```



## 问题
### 加认证后启动失败
```
# ./config.sh 
about to fork child process, waiting until server is ready for connections.
forked process: 29795
ERROR: child process failed, exited with error number 1
To see additional information in this output, start without the "--fork" option.

//查看log，提示key文件权限太大
# tailf config/log/mongod.log 
2019-04-29T11:26:01.546+0800 I CONTROL  [main] ***** SERVER RESTARTED *****
2019-04-29T11:26:01.551+0800 I ACCESS   [main] permissions on /data/mongo/conf/mongo.key are too open

//修改文件权限
# chmod 400 /data/mongo/conf/mongo.key 
# chown -R mongo:mongo /data/mongo
```
### 集群重启
```
不要使用kill -9 pid
使用db.shutdownServer()
先从后主顺序关闭
```

### 初始化分片时报错
```
> rs.initiate(config);
{
	"ok" : 0,
	"errmsg" : "This node, CentOSNode2:22002, with _id 1 is not electable under the new configuration version 1 for replica set shard2",
	"code" : 93,
	"codeName" : "InvalidReplicaSetConfig"
}

```

是因为在仲裁节点上执行操作，换个非仲裁节点即可

**注意：不能在仲裁节点上进行激活操作**


### 添加分片失败
```
mongos> sh.addShard("shard1/172.18.21.58:21001,172.18.21.59:21001,172.18.21.60:21001")
{
	"ok" : 0,
	"errmsg" : "E11000 duplicate key error collection: admin.system.version index: _id_ dup key: { : \"shardIdentity\" }",
	"code" : 11000,
	"codeName" : "DuplicateKey",
	"operationTime" : Timestamp(1557053065, 3),
	"$clusterTime" : {
		"clusterTime" : Timestamp(1557053065, 3),
		"signature" : {
			"hash" : BinData(0,"u9HdIxBAg6Lwevd8s8H/B9GWyUw="),
			"keyId" : NumberLong("6684926616935596062")
		}
	}
}

```
按照网上的说法（如下），非shardsvr启动主节点，删除shardIdentity记录，还是不行
```
> use admin
switched to db admin
> db.system.version.find({})
{ "_id" : "featureCompatibilityVersion", "version" : "4.0" }
{ "_id" : "shardIdentity", "clusterId" : ObjectId("5cc55bd247f61bf0f530e287"), "shardName" : "shard1", "configsvrConnectionString" : "config/172.18.21.58:21004,172.18.21.59:21004,172.18.21.60:21004" }
{ "_id" : "authSchema", "currentVersion" : 5 }
> db.system.version.remove({"_id":"shardIdentity"})
WriteResult({ "nRemoved" : 1 })
> exit
bye
[root@iZwz9gglwrfdrwui0jbwldZ mongo]# vim /data/mongo/conf/shard1.conf 
```

最后使用重来大法添加成功：
1、删除shard1三台服务器的data、log目录下的内容
2、重新启动三台服务
3、重新设置分片
4、重新添加分片
```
# cd /data/mongo/shard1/
# rm -rf ./log/*
# rm -rf ./data/*
# ./shard1.sh
# 
```


## 其他
### mongo下载地址
https://www.mongodb.org/dl/linux/x86_64

或者

https://pan.baidu.com/s/1I6yp3Pv3OW4rHu03Lt1VdQ 
提取码：tc74 

### 参考
https://jeremyxu2010.github.io/2018/10/mongodb%E9%AB%98%E5%8F%AF%E7%94%A8%E9%9B%86%E7%BE%A4%E9%83%A8%E7%BD%B2/
