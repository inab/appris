#!/bin/bash

# First we need to load environmental variables in order to use perl
source /etc/profile


# Input parameters
DATABASE=${1}
HOST=${2}
USER=${3}
PWD=${4}
DATABASE_SCHEMA_FILE="apprisdb.sql"


# If there is a password
if [ "${PWD}" != "" ];
then
	PWD="-p${PWD}"
fi


# Create database
echo "---------------------------"
echo "Create database"
echo "mysqladmin -h ${HOST} -u ${USER} ${PWD} create ${DATABASE}"
mysqladmin -h ${HOST} -u ${USER} ${PWD} create ${DATABASE}

# Create tables
echo "---------------------------"
echo "Create tables"
echo "mysql ${DATABASE} -h ${HOST} -u ${USER} ${PWD} < ${DATABASE_SCHEMA_FILE}"
mysql ${DATABASE} -h ${HOST} -u ${USER} ${PWD} < ${DATABASE_SCHEMA_FILE}
