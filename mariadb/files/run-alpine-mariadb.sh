#!/bin/sh

source /scripts/init-alpine.sh

# mysql默认用户和用户组与ID设置 默认 mysql:mysql  100:101
MYSQL_DATA_USER=${MYSQL_DATA_USER:-"mysql"}
MYSQL_DATA_USER_UID=${MYSQL_DATA_USER_UID:-"100"}
MYSQL_DATA_GROUP=${MYSQL_DATA_GROUP:-"mysql"}
MYSQL_DATA_GROUP_UID=${MYSQL_DATA_GROUP_UID:-"101"}
# mysql默认编码设置 utf8mb4
MYSQL_CHARSET=${MYSQL_CHARSET:-"utf8mb4"}
MYSQL_COLLATION=${MYSQL_COLLATION:-"utf8mb4_general_ci"}
# mysql初始用户和密码设置
MYSQL_DATABASE=${MYSQL_DATABASE:-"demo"}
MYSQL_USER=${MYSQL_USER:-"demo"}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}
MYSQL_PASSWORD_LENGTH=${MYSQL_PASSWORD_LENGTH:-30}
# mysql管理员root设置
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-""}
MYSQL_ROOT_PASSWORD_LENGTH=${MYSQL_ROOT_PASSWORD_LENGTH:-30}

echo "MYSQL_DATA_USER: ${MYSQL_DATA_USER}"
echo "MYSQL_DATA_USER_UID: ${MYSQL_DATA_USER_UID}"
echo "MYSQL_DATA_GROUP: ${MYSQL_DATA_GROUP}"
echo "MYSQL_DATA_GROUP_UID: ${MYSQL_DATA_GROUP_UID}"

#Create Group (if not exist)  grep 匹配命令, wc -l统计匹配的行数
CHECK=$(cat /etc/group | grep $MYSQL_DATA_GROUP | wc -l)
if [ ${CHECK} == 0 ]; then
    echo "Create group $MYSQL_DATA_GROUP with uid $MYSQL_DATA_GROUP_UID"
    addgroup -g ${MYSQL_DATA_GROUP_UID} ${MYSQL_DATA_GROUP}
else
    echo -e "Skipping,group $MYSQL_DATA_GROUP exist"
fi

#Create User (if not exist)
CHECK=$(cat /etc/passwd | grep $MYSQL_DATA_USER | wc -l)
if [ ${CHECK} == 0 ]; then
    echo "Create User $MYSQL_DATA_USER with uid $MYSQL_DATA_USER_UID"
    adduser -s /bin/false -H -u ${MYSQL_DATA_USER_UID} -D ${MYSQL_DATA_USER}
else
    echo -e "Skipping,user $MYSQL_DATA_USER exist"
fi


# 设置默认编码
# 这里直接替换了,原来的文件备份为 /etc/my.cnf.d/mariadb-server.cnf.bk
cat << EOF > /etc/my.cnf.d/mariadb-server.cnf
#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see

# this is read by the standalone daemon and embedded servers
[server]

# this is only for the mysqld standalone daemon
[mysqld]
#skip-networking

character-set-server  = '${MYSQL_CHARSET}'
collation-server      = '${MYSQL_COLLATION}'


#
# * InnoDB
#
# InnoDB is enabled by default with a 10MB datafile in /var/lib/mysql/.
# Read the manual for more InnoDB related options. There are many!
# Most important is to give InnoDB 80 % of the system RAM for buffer use:
# https://mariadb.com/kb/en/innodb-system-variables/#innodb_buffer_pool_size
innodb_buffer_pool_size=128M
performance_schema=OFF

# log config
log_output=FILE

# general_log
general_log_file=/var/log/mysql/general.log
expire_logs_days        = 10
max_binlog_size        = 100M

# slow_query_log
slow_query_log_file=/var/log/mysql/slow.log
long_query_time=3

log_error=/var/log/mysql/error.log
log_warnings=2


# Galera-related settings
[galera]
# Mandatory settings
#wsrep_on=ON
#wsrep_provider=
#wsrep_cluster_address=
#binlog_format=row
#default_storage_engine=InnoDB
#innodb_autoinc_lock_mode=2
#
# Allow server to accept connections on all interfaces.
#
#bind-address=0.0.0.0
#
# Optional setting
#wsrep_slave_threads=1
#innodb_flush_log_at_trx_commit=0

# this is only for embedded server
[embedded]

# This group is only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]

# This group is only read by MariaDB-10.5 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
[mariadb-10.5]


EOF

# 如果MYSQL数据目录的用户非mysql ,则在/etc/my.cnf.d/mariadb-server.cnf中追加配置
if [ "${MYSQL_DATA_USER}" != "mysql" ]; then
    # echo "[mysqld]" >> /etc/my.cnf.d/mariadb-server.cnf
    echo "innodb_use_native_aio=0" >> /etc/my.cnf.d/mariadb-server.cnf
fi

# execute any pre-init scripts
for i in /scripts/pre-init.d/*sh
do
    if [ -e "${i}" ]; then
        echo "[i] pre-init.d - processing $i"
        . "${i}"
    fi
done

if [ -d "/run/mysqld" ]; then
    echo "[i] mysqld already present, skipping creation"
    chown -R $MYSQL_DATA_USER:$MYSQL_DATA_GROUP /run/mysqld
else
    echo "[i] mysqld not found, creating...."
    mkdir -p /run/mysqld
    chown -R $MYSQL_DATA_USER:$MYSQL_DATA_GROUP /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
    echo "[i] MySQL directory already present, skipping creation"
    chown -R $MYSQL_DATA_USER:$MYSQL_DATA_GROUP /var/lib/mysql
else
    echo "[i] MySQL data directory not found, creating initial DBs"

    chown -R $MYSQL_DATA_USER:$MYSQL_DATA_GROUP /var/lib/mysql

    mysql_install_db --user=$MYSQL_DATA_USER --ldata=/var/lib/mysql

    if [ "$MYSQL_ROOT_PASSWORD" == "" ]; then
        # 生成随机root密码
        MYSQL_ROOT_PASSWORD=`pwgen -s $MYSQL_ROOT_PASSWORD_LENGTH 1`
        echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
    fi

    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1
    fi

    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF

    if [ "$MYSQL_DATABASE" != "" ]; then
        echo "[i] Creating database: $MYSQL_DATABASE"
        echo "[i] with character set [$MYSQL_CHARSET] and collation [$MYSQL_COLLATION]"

        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET $MYSQL_CHARSET COLLATE $MYSQL_COLLATION;" >> $tfile

        if [ "$MYSQL_PASSWORD" == "" ]; then
            MYSQL_PASSWORD=`pwgen -s $MYSQL_PASSWORD_LENGTH 1`
            echo "[i] MySQL User Password: $MYSQL_PASSWORD"
        fi

        if [ "$MYSQL_USER" != "" ]; then
            echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
            echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USER\`@\`localhost\` IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
            echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USER\`@\`%\` IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
            echo "FLUSH PRIVILEGES ;" >> $tfile
        fi
    fi
    # 执行初始数据库临时脚本文件
    /usr/bin/mysqld --user=$MYSQL_DATA_USER --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
    # 删除初始临时脚本文件
    rm -f $tfile
    # 循环执行目录中的初始数据库脚本
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sql)    echo "$0: running $f"; /usr/bin/mysqld --user=$MYSQL_DATA_USER --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "$f"; echo ;;
            *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < "$f"; echo ;;
            *)        echo "$0: ignoring or entrypoint initdb empty $f" ;;
        esac
        echo
    done

    echo
    echo 'MySQL init process done. Ready for start up.'
    echo

    echo "exec /usr/bin/mysqld --user=$MYSQL_DATA_USER --console --skip-name-resolve --skip-networking=0" "$@"
fi

# execute any pre-exec scripts
for i in /scripts/pre-exec.d/*sh
do
    if [ -e "${i}" ]; then
        echo "[i] pre-exec.d - processing $i"
        . ${i}
    fi
done

exec /usr/bin/mysqld --user=$MYSQL_DATA_USER --console --skip-name-resolve --skip-networking=0 $@