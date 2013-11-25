#!/bin/bash

# Input parameters
DATABASE=${1}
HOST=${2}
USER=${3}
PWD=${4}
FILE=${5}

# Dump of tables
echo "---------------------------"
echo "Dump database"
echo "mysqldump ${DATABASE} -h ${HOST} -u ${USER} -p${PWD} --single-transaction --quick | gzip -9c > ${FILE}"
mysqldump ${DATABASE} -h ${HOST} -u ${USER} -p${PWD} --single-transaction --quick | gzip -9c > ${FILE}
