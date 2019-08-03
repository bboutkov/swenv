#!/bin/sh
set -e

PARAVIEW_VERSION=ParaView-5.7.0-RC1-MPI-Linux-64bit

echo "Building all paraview for ${UBCESLAB_SYSTEMTYPE:?undefined}"

CURRENT_DIR=$PWD

mkdir -p ${UBCESLAB_SWENV_PREFIX:?undefined}/sourcesdir/paraview

(cd $UBCESLAB_SWENV_PREFIX/sourcesdir/paraview

 if [ ! -f $PARAVIEW_VERSION.tar.gz ]; then
     wget  --output-document=$PARAVIEW_VERSION.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.7&type=binary&os=Linux&downloadFile=$PARAVIEW_VERSION.tar.gz"
 fi
)

TOPDIR=${UBCESLAB_SWENV_PREFIX:?undefined}/apps/paraview
export PARAVIEW_DIR=$TOPDIR/$PARAVIEW_VERSION
rm -rf $PARAVIEW_DIR

# For the ParaView tar ball, we just need to untar in the right place
mkdir -p $TOPDIR
cd $TOPDIR
tar xvf $UBCESLAB_SWENV_PREFIX/sourcesdir/paraview/$PARAVIEW_VERSION.tar.gz

cd $CURRENT_DIR
MODULEDIR=$UBCESLAB_SWENV_PREFIX/apps/lmod/modulefiles/paraview
mkdir -p $MODULEDIR

echo "local version = \"$PARAVIEW_VERSION\"" > $MODULEDIR/$PARAVIEW_VERSION.lua
echo "local apps_dir = \"$UBCESLAB_SWENV_PREFIX/apps\"" >> $MODULEDIR/$PARAVIEW_VERSION.lua
echo "local libs_dir = \"$UBCESLAB_SWENV_PREFIX/libs\"" >> $MODULEDIR/$PARAVIEW_VERSION.lua
cat ../modulefiles/paraview.lua >> $MODULEDIR/$PARAVIEW_VERSION.lua
