# codis 集群部署
[toc]

## 服务器规划
| 内网ip |  安装服务|
|--------|--------|---|
| 172.18.21.45| zk1、codis-server(主1-1:6379，从2-2:6380)、codis-proxy、codis-dashbord
| 172.18.21.48| zk2、codis-server(主2-1:6379，从3-2:6380)、codis-proxy、codis-config 
| 172.18.21.50| zk3、codis-server(主3-1:6379，从1-2:6380、codis-proxy

## 环境依赖
### java 
```
> yum install java -y
```

## 部署服务

## 安装zk
下载地址 http://mirrors.hust.edu.cn/apache/zookeeper/

```
> wget http://mirrors.hust.edu.cn/apache/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz
> tar xzvf zookeeper-3.4.12.tar.gz 	

#移到/usr/local目录
> mv zookeeper-3.4.12 /usr/local/	
#创建软连接	
> ln -sf zookeeper-3.4.12/ zookeeper

#设置hosts 	
> vim /etc/hosts
172.18.21.45   zookeeper-node1
172.18.21.48   zookeeper-node2
172.18.21.50   zookeeper-node3

//修改配置文件
>vim /usr/local/zookeeper/conf/zoo.cfg
#最大连接数设置(单ip限制). 注：默认60,设成0即无限制. 
maxClientCnxns=500				#一个周期(tick)的时长(单位：毫秒). 
tickTime=28800					#初始化同步阶段最多耗费tick个数. 注：可用默认值
initLimit=10					#等待应答的最大间隔tick个数. 注：可用默认值
syncLimit=5						#数据存储目录,刚才创建那个. 注：勿放在/tmp目录
dataDir=/data/zookeeper/		
clientPort=2181					#通信端口. 注：可用默认值
server.1=zookeeper-node1:2888:3888
server.2=zookeeper-node2:2888:3888
server.3=zookeeper-node3:2888:3888


>mkdir -p /data/zookeeper
#生成myid,注意server.1，2，3 的myid分别对应为1，2，3
> echo "1" > /data/zookeeper/myid

#启动服务
> /usr/local/zookeeper/bin/zkServer.sh start
#三台zk都启动后，查看leader和follower
> /usr/local/zookeeper/bin/zkServer.sh status
```

## 部署codis-server

###### 下载 codis
> > yum install -y git gcc gcc-c++ authmake autoconf cmake
> > mkdir  CodisLabs
> > cd CodisLabs
> > git clone https://github.com/CodisLabs/codis.git
###### 安装codis
> > cd codis
> > make
> > mkdir /usr/local/codis
> > cp -rp ./*  /usr/local/codis/ 


三台服务器互备如下


| 内网ip | 主从| slaveof:6380|
|--------|---|---|
| 172.18.21.45| 主1 从2 | slaveof 172.18.21.48:6379
| 172.18.21.48| 主2 从3 | slaveof 172.18.21.50:6379
| 172.18.21.50| 主3 从1 | slaveof 172.18.21.45:6379

```
//创建目录
# mkdir -p /data/redis/data
# mkdir -p /data/redis/logs
# mkdir -p /data/redis/config

//配置主库
# vim /data/redis/config/redis_6379.conf

bind 0.0.0.0
port 6379
daemonize yes
pidfile /data/redis/logs/redis_6379.pid
logfile "/data/redis/logs/redis_6379.log"
dbfilename dump_6379.rdb
dir /data/redis/data
masterauth "654321"
requirepass "123456"


//配置从库
# vim /data/redis/config/redis_6380.conf

bind 0.0.0.0
port 6380
daemonize yes
pidfile /data/redis/logs/redis_6380.pid
logfile "/data/redis/logs/redis_6380.log"
dbfilename dump_6380.rdb
dir /data/redis/data
slaveof 172.18.21.48 6379
masterauth "123456"
requirepass "123456"


//172.18.21.48 从库配置
slaveof 172.18.21.50 6379

//172.18.21.50 从库配置
slaveof 172.18.21.45 6379

```
三台服务器主库配置一致

从库配置slaveof不一致


## 部署codis-proxy

```
//生成默认配置
# /usr/local/codis/codis-proxy --default-config | tee ./proxy.conf	

//修改配置，主要修改以下内容，其他保持默认
# vim /data/redis/config/proxy.conf

product_name = "codis-test"
product_auth = "123456"
session_auth = "123456"
admin_addr = "172.18.21.45:11080"
jodis_name = "zookeeper"
jodis_addr = "172.18.21.45:2181,172.18.21.50:2181,172.18.21.48:2181"

```

## 部署codis-dashboard
```
//成默认配置文件
# /usr/local/codis/codis-dashboard --default-config | tee ./dashboard.conf 

//修改配置，修改项如下，其他默认
# vim /data/redis/config/dashboard.conf

coordinator_name = "zookeeper"
coordinator_addr = "172.18.21.45:2181,172.18.21.50:2181,172.18.21.48:2181"
product_name = "codis-test"
product_auth = "123456"

```


## 部署codis-fe
```
//生成配置文件
# /usr/local/codis/codis-admin --dashboard-list --zookeeper=192.168.1.239:2181 >codis.json 

//保持默认生成即可,如下
# vim /data/redis/config/codis.json
[
    {
        "name": "codis-test",
        "dashboard": "redis1:18080"
    }
]

```

## 部署redis-sentinel
```
# vim /data/redis/config/dashboard.conf

```

## 启动服务

```
//三台服务器都需执行
# /usr/local/codis/codis-server /data/redis/config/redis_6379.conf
# /usr/local/codis/codis-server /data/redis/config/redis_6380.conf
# nohup /usr/local/codis/codis-proxy --ncpu=4 --config=/data/redis/config/proxy.conf --log=/data/redis/logs/proxy.log &

//只需在其他一台上执行即可
# nohup /usr/local/codis/codis-dashboard --ncpu=4 --config=/data/redis/config/dashboard.conf --log=/data/redis/logs/codis_dashboard.log --log-level=WARN &
# nohup /usr/local/codis/codis-fe --ncpu=4 --log=/data/redis/logs/fe.log --log-level=WARN --dashboard-list=/data/redis/config/codis.json --listen=0.0.0.0:8090 &


```



## 问题
### codis-fe看不到集群信息

一天，登录http://ip:8090,发现Dashboard上的信息都不见了，/(ㄒoㄒ)/~~
突然想起，改了hostname,而codis-fe的配置文件使用到了hostname，所以就出现问题了
解决办法，只要把codis.json中hostname改好并重启codis-fe就行了
```
# vim codis.josn
由
[
    {
        "name": "codis-test",
        "dashboard": "iZwz96lf5qxtmkbqoz5iyeZ:18080"
    }
]


改成

[
    {
        "name": "codis-test",
        "dashboard": "redis1:18080"
    }
]

//重启服务
# nohup /usr/local/codis/codis-fe --ncpu=4 --log=/data/redis/logs/fe.log --log-level=WARN --dashboard-list=/data/redis/config/codis.json --listen=0.0.0.0:8090 &
```