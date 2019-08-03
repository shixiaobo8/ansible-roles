#!/bin/bash
rm -rf /usr/bin/my*
if [ -d /usr/local/mysql-5.7.27-el7-x86_64 ];then 
	mv /usr/local/mysql-5.7.27-el7-x86_64 /usr/local/mysql 
fi
if [ -d /usr/local/mysql ];then
	chown -R mysql:mysql /usr/local/mysql && ln -sf /usr/local/mysql/bin/* /usr/bin/
fi

rm -rf /www/mysql_datas/*
chown mysql:mysql -R /www/mysql_datas/
