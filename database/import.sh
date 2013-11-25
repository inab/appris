#!/bin/bash

# Input parameters
DATABASE=${1}
HOST=${2}
USER=${3}
PWD=${4}
BACKUP_FILE=${5}


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

# Import database
echo "---------------------------"
echo "Import database"
echo "gunzip < ${BACKUP_FILE} | mysql ${DATABASE} -h ${HOST} -u ${USER} ${PWD}"
gunzip < ${BACKUP_FILE} | mysql ${DATABASE} -h ${HOST} -u ${USER} ${PWD}

