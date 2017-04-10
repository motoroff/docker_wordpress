#!/bin/bash
FILE=/usr/local/mysql/`date +"%Y%m"`.sql
USER=root
PASS=

/usr/bin/mysqldump --host mysql --all-databases --user=${USER} --password=${PASS} > ${FILE}
