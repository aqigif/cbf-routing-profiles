#!/bin/bash -e
#
# Create all profiles
#
#

if [ "x$1" = "x-c" ]; then
    shift
    COPYDATA=yes
else
    COPYDATA=no
fi

if [ "x$1" = "x" ] || [ ! -f "$1" ]; then
    echo "Usage: compile_profiles.sh [-c] <configfile>"
    exit -1
fi

. $1

if [ "x$OSMDATA" = "x" ] || [ ! -f "$OSMDATA" ]; then
    echo "Cannot access OSM data file $OSMDATA."
    exit -1
fi

if [ "x$BUILDDIR" = "x" ] || [ ! -d "$BUILDDIR" ]; then
    echo "Need build dir"
    exit -1
fi

osmdatafile=`basename $OSMDATA`
osmdatadir=`dirname $OSMDATA`
osmdatadir=`cd $osmdatadir; pwd`

scriptdir=`dirname $0`
scriptdir=`cd $scriptdir; pwd`

cd $OSRMPATH
rm -f $BUILDDIR/*
for OSRMTYPE in $PROFILES; do 
    osminbuild=$BUILDDIR/$OSRMTYPE.${osmdatafile#*.}
    ln -s $osmdatadir/$osmdatafile $osminbuild
    time LUA_PATH="$scriptdir/lib/?.lua" ./osrm-extract -p $scriptdir/$OSRMTYPE.lua $osminbuild 2>&1
    echo "time for $OSRMTYPE extract"
    time LUA_PATH="$scriptdir/lib/?.lua" ./osrm-contract $BUILDDIR/$OSRMTYPE.osrm --core 0.6 2>&1
    echo "time for $OSRMTYPE contract"
done

if [ $COPYDATA = "yes" ]; then
    cp $BUILDDIR/*.osrm* $DATADIR
fi
