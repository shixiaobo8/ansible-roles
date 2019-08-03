# NSQ集群部署
[toc]

## 环境

* centos
* 有赞nsq
* 目录
```
  /usr/local/nsq
    bin
 /data/nsq
    conf
    logs
        nsqadmin 
        nsqd 
        nsqlookupd
```

## 准备工作
* 安装etcd(参考etcd 集群部署)


## 服务器规划
ip | 安装服务|端口
---|---|---
192.168.199.23 | nsq、nsqlookup、nsqadmin | 4150/4151、4160/4161、4171
192.168.199.24 | nsq、nsqlookup | 4150/4151、4160/4161
192.168.199.25 | nsq、nsqlookup | 4150/4151、4160/4161



## 安装

```
//下载nsq二进制包
 # wget https://github.com/youzan/nsq/releases/download/v0.3.7-HA.1.9.4/nsq-0.3.7-HA.1.9.4.linux-amd64.go1.10.8.tar.gz
 # tar xzf nsq-0.3.7-HA.1.9.4.linux-amd64.go1.10.8.tar.gz
 //移动并创建软连接
# mv nsq-0.3.7-HA.1.9.4.linux-amd64.go1.10.8 /usr/local/
#ln -sf nsq-0.3.7-HA.1.9.4.linux-amd64.go1.10.8 nsq
 
 # cd /data 
 # mkdir conf logs
 # cd conf/
 //下载配置
# wget https://raw.githubusercontent.com/youzan/nsq/master/contrib/nsqadmin.cfg.example
# wget https://raw.githubusercontent.com/youzan/nsq/master/contrib/nsqd.cfg.example
# wget https://raw.githubusercontent.com/youzan/nsq/master/contrib/nsqlookupd.cfg.example
# mv nsqd.cfg.example nsqd.cfg
# mv nsqadmin.cfg.example nsqadmin.cfg
# mv nsqlookupd.cfg.example nsqlookupd.cfg
# cd logs/
# mkdir nsqadmin nsqd nsqlookupd
```

## 配置
未列出的配置项为默认值

* nsqlookupd.cfg
```
[root@wy23 conf]# vim /usr/local/nsq/conf/nsqlookupd.cfg

cluster_id = "im-nsq-cluster-1"
cluster_leadership_addresses = "http://192.168.199.23:2379,http://192.168.199.24:2379,http://192.168.199.25:2379"
broadcast_interface = "ens160"
log_dir = "/data/nsq/logs/nsqlookupd"

```

* nsqd.cfg
```
[root@wy23 conf]# vim /usr/local/nsq/conf/nsqd.cfg

cluster_id = "im-nsq-cluster-1"
cluster_leadership_addresses = "http://192.168.199.23:2379,http://192.168.199.24:2379,http://192.168.199.25:2379"
broadcast_interface = "ens160"
log_dir = "/data/nsq/logs/nsqd"
data_path = "/data/nsq/data"

```

* nsqadmin.cfg
```
[root@wy23 conf]# vim /usr/local/nsq/conf/nsqadmin.cfg

log_dir = "/data/nsq/logs/nsqadmin"
```


## 启动服务
```
# nohup /usr/local/nsq/bin/nsqlookupd -config=/data/nsq/conf/nsqlookupd.cfg &
# nohup /usr/local/nsq/bin/nsqd -config=/data/nsq/conf/nsqd.cfg &
# nohup /usr/local/nsq/bin/nsqadmin -config=/data/nsq/conf/nsqadmin.cfg &

```

注意：使用shell连接服务器，nohup+&启动服务后，如果直接点"x"关闭shell,会导致服务也会中断，正确方式是：使用exit退出



## 登录管理后台

http://ip:4171



## 测试
```
//创建topic
# curl -X POST http://127.0.0.1:4151/topic/create?topic=test

//创建channel
curl 'http://127.0.0.1:4161/channel/create?topic=test&channel=ch1' -d ''

//消费topic


//消费channel


```
