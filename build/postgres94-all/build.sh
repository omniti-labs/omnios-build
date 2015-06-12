if [ -z $1 ]; then
    echo "Usage: $0 <pg94 minor version number>"
    exit 1
fi

MINOR=$1

VER="9.4.$MINOR"
PGVER="94$MINOR"

echo "Building postgresql-$PGVER and all extensions..."

VER=$VER ../postgres94/build.sh
VER=$VER ../pg94-dblink/build.sh
VER=$VER ../pg94-pg_stat_statements/build.sh
PGVER=$PGVER ../pg94-pg_query_statsd/build.sh
PGVER=$PGVER ../pg94-mimeo/build.sh
PGVER=$PGVER ../pg94-pg_jobmon/build.sh
PGVER=$PGVER ../pg94-pg_partman/build.sh
VER=$VER ../pg94-plperl/build.sh -d 5.20
VER=$VER ../pg94-pgcrypto/build.sh
VER=$VER ../pg94-fuzzystrmatch/build.sh
VER=$VER ../pg94-hstore/build.sh
VER=$VER ../pg94-btree_gist/build.sh
VER=$VER ../pg94-pg_buffercache/build.sh
VER=$VER ../pg94-pg_upgrade/build.sh
PGVER=$PGVER ../pg94-pg_repack/build.sh
VER=$VER ../pg94-tablefunc/build.sh
