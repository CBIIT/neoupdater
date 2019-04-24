#!/bin/bash
export PERLBREW_ROOT=/home/ubuntu/perl5/perlbrew
export PERLBREW_HOME=/home/ubuntu/.perlbrew
source ${PERLBREW_ROOT}/etc/bashrc
SCHEMADIR=${SCHEMADIR:=/home/ubuntu/Code/gdcdictionary/gdcdictionary/schemas}
WORKDIR=${WORKDIR:=.}
P2NDIR=${P2NDIR:=.}

print_help() {
    echo "p2n : fast convert psql to neo4j raw data files"
}

OPTSTR=h
LONGOPTSTR=help,host:,user:,password:,dbname:,export_only,convert_only,workdir:,cleanup:
TEMP=`getopt -o $OPTSTR --long $LONGOPTSTR -- "$@"`
eval set -- "$TEMP"
if [ $? != 0 ] ; then print_help ; exit 2 ; fi 

make_table () {
    export NODE=$1
    if [[ -z $NODE ]]
    then 
	echo 'need table spec'
	exit 1
    fi
    SETUP="\C
\f '!'
\t
\a
"
    TABLE=node_${NODE//_/}
    STMT="select t.node_id, t._props, t._sysan from $TABLE t where not t._sysan @> '{\"to_delete\":true}';"
    cat <(echo $SETUP) <( echo $STMT ) | \
	psql -q postgresql://$user:$pass@$host/$dbname?sslmode=require 
}

dump_nodes () {
    export SCHEMADIR
    NODES=$( find $SCHEMADIR -maxdepth 1 -type f -name "*.yaml" | { while read n ; do basename $n .yaml ; done ; } | \
	grep -v ^_ | sort | grep -v metaschema
    )

    mkdir ./csv 2> /dev/null
    CT=0
    echo -n 0 > ./_start.txt

    for i in $NODES 
    do
	echo $i
	make_table $i > ./csv/$i.txt
	NUM=$(printf "%03d" $CT)
	$P2NDIR/helpers/tbl-cvt.pl --start $( cat _start.txt ) ./csv/$i.txt > ./csv/nodes$NUM.csv
	rm ./csv/$i.txt
    # check for zero-length file (will screw up the batch importer)
	if ((! $(stat --format=%s ./csv/nodes$NUM.csv) ))
	then
	    rm ./csv/nodes$NUM.csv
	fi
	((CT++))
    done
    rm ./_start.txt
}

dump_edges () {
    SETUP="\C
\f '\t'
\t
\a
"

    ls ./csv/nodes*.csv | { 
	while read f 
	do 
	    sed -e '1d' $f | perl -F"\t" -ane 'print "$F[1]\t$F[0]\n"' >> ./hash.txt 
	done 
    }
    
    SETUP="\C
\f '\t'
\t
\a
"
    $P2NDIR/helpers/edge-tbls.pl $SCHEMADIR | {
	while read tblname reln
	do
	    echo $tblname
	    STMT="select t.src_id, t.dst_id from $tblname t;"
	    cat <( echo $SETUP ) <( echo $STMT ) | \
		psql -q postgresql://$user:$pass@$host/$dbname?sslmode=require 2> /dev/null | \
		perl -ne "chomp; print \"\$_\t$reln\n\"" >> ./rels.txt
	done
    }
    
    echo convert ids
    perl -ne 'BEGIN{open $hf,"./hash.txt" or die $!; while (<$hf>){chomp;@a=split/\t/;$h{$a[0]}=$a[1];}' \
	-e 'print join("\t",qw/:START_ID :END_ID :TYPE/),"\n";}' \
	-e '@a = split/\t/;' \
	-e 'print join("\t",$h{$a[0]},$h{$a[1]},$a[2]) if ($h{$a[0]} && $h{$a[1]});' \
	./rels.txt > ./csv/rels.csv
    rm ./rels.txt
    rm ./hash.txt
}

batch_import () {
    mkdir $WORKDIR/data 2> /dev/null
    NODE_FILES=$(perl -Mv5.10 -e 'say "--nodes ",join(" --nodes ", @ARGV)' $WORKDIR/csv/node*.csv)
    EDGE_FILE="--relationships $WORKDIR/csv/rels.csv"
    JAVA_OPTS="-Xmx4G" /usr/local/share/neo4j/bin/neo4j-import --into $WORKDIR/data $NODE_FILES $EDGE_FILE --delimiter $'\t'
}

# start script
user=
host=
dbname=
pass=
DO_EXPORT=1
DO_CONVERT=1
CLEANUP=
while true ; do
    case "$1" in
	-h|--help) print_help ; exit 2 ;;
	--host) host=$2 ; shift 2 ;;
	--user) user=$2 ; shift 2 ;;
	--dbname) dbname=$2 ; shift 2 ;;
	--password) pass=$2 ; shift 2 ;;
	--workdir) WORKDIR=$2 ; shift 2 ;;
	--export_only) DO_CONVERT= ; shift 1 ;;
	--convert_only) DO_EXPORT= ; shift 1 ;;
	--cleanup)  CLEANUP=1 ; shift ;;
	--) shift ; break ;;
	*) echo Option not recognized : $1 ; print_help ; exit 2 ;;
    esac
done

if [ ! $host ]
then
    source /home/ubuntu/.cred/up
fi

pushd $WORKDIR > /dev/null

if [ $DO_CONVERT ]
then
    echo do nodes
    dump_nodes

    echo do edges
    dump_edges
fi

if [ $DO_EXPORT ]
then
    echo batch import
    batch_import
fi


popd > /dev/null
