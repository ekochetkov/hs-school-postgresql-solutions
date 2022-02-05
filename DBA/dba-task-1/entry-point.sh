#!/bin/bash

# Special version of entry-point script for create replication without recovery.conf

set -e
set -o xtrace

if [ "${1:0:1}" = '-' ]; then
    set -- postgres "$@"
fi

export PGDATA="/data"
export PATH="/opt/pgpro/std-12/bin/:$PATH"

## Prepare file system
mkdir -p $PGDATA 
chmod 700 $PGDATA
chown -R postgres $PGDATA

export POSTGRES_USER=${POSTGRES_USER:=postgres}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:=postgres}

if [ ! -s "$PGDATA/PG_VERSION" ]; then

	# Configure connecton for pg_basebackup and psql create replication slot
	echo "$PG_MASTER_HOST:5432:*:$POSTGRES_USER:$POSTGRES_PASSWORD" > ~/.pgpass
	chmod 0600 ~/.pgpass

	NUM_ATTEMPTS=20
	n=0
	until [ $n -ge $NUM_ATTEMPTS ]
	do
		pg_basebackup --pgdata=$PGDATA --format=p --no-password --wal-method=stream --checkpoint=fast --progress --verbose --username=$POSTGRES_USER --host=$PG_MASTER_HOST && export RESTORED=1 && break
	    n=$[$n+1]
	    echo "Not ready; Sleep $n"
	    sleep $n
	done

	# Create replication slot
	psql -h $PG_MASTER_HOST -U $POSTGRES_USER -w -c "SELECT pg_create_physical_replication_slot('$PG_SLOT');" || echo "may be exists"

	touch "$PGDATA/standby.signal"
	echo "primary_slot_name = '$PG_SLOT'" >> "$PGDATA/postgresql.conf"
	echo "primary_conninfo = 'host=$PG_MASTER_HOST port=5432 user=$POSTGRES_USER password=$POSTGRES_PASSWORD'" >> "$PGDATA/postgresql.conf"
	
	echo
	echo 'PostgreSQL clone process complete; ready for start up.'
	echo
	
	chmod 700 $PGDATA
	chown -R postgres $PGDATA
	
	exec gosu postgres postgres

fi

