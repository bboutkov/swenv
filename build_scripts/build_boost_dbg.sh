#!/bin/sh
set -e # Fail on first error

export BOOST_VERSION=1.71.0

export BOOST_MAJOR=`echo $BOOST_VERSION | cut -d . -f 1`
export BOOST_MINOR=`echo $BOOST_VERSION | cut -d . -f 2`
export BOOST_MICRO=`echo $BOOST_VERSION | cut -d . -f 3`

export BOOST_FILENAME=${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_MICRO}

CURRENT_DIR=$PWD

mkdir -p ${UBCESLAB_SWENV_PREFIX:?undefined}/sourcesdir/boost

(cd $UBCESLAB_SWENV_PREFIX/sourcesdir/boost
if [ ! -f boost_$BOOST_FILENAME.tar.bz2 ]; then
  wget --output-document=boost_$BOOST_FILENAME.tar.bz2 https://dl.bintray.com/boostorg/release/$BOOST_VERSION/source/boost_$BOOST_FILENAME.tar.bz2
fi
)

TOPDIR=${UBCESLAB_SWENV_PREFIX:?undefined}/libs/boost-dbg
export BOOST_DIR=$TOPDIR/$BOOST_VERSION/${COMPILER:?undefined}/${COMPILER_VERSION:?undefined}

mkdir -p $UBCESLAB_SWENV_PREFIX/builddir
BUILDDIR=`mktemp -d $UBCESLAB_SWENV_PREFIX/builddir/boost-XXXXXX`
cd $BUILDDIR
tar xjf $UBCESLAB_SWENV_PREFIX/sourcesdir/boost/boost_$BOOST_FILENAME.tar.bz2
cd boost_$BOOST_FILENAME

TOOLSET=$COMPILER
if test "$COMPILER" = intel; then
  TOOLSET=intel-linux
fi

./bootstrap.sh --with-toolset=${TOOLSET} --prefix=$BOOST_DIR --with-libraries=program_options,system,filesystem,chrono,regex,serialization,date_time,thread

rm -rf $BOOST_DIR

./b2 -j ${NPROC:-1} cxxflags="-D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC" install

cd $UBCESLAB_SWENV_PREFIX
rm -rf $BUILDDIR || true

cd $CURRENT_DIR
MODULEDIR=$UBCESLAB_SWENV_PREFIX/apps/lmod/derived_modulefiles/${COMPILER:?undefined}/${COMPILER_VERSION:?undefined}/modulefiles/boost-dbg
mkdir -p $MODULEDIR

echo "local version = \"$BOOST_VERSION\"" > $MODULEDIR/$BOOST_VERSION.lua
echo "local libs_dir = \"$UBCESLAB_SWENV_PREFIX/libs\"" >> $MODULEDIR/$BOOST_VERSION.lua
echo "local name = \"boost-dbg\"" >> $MODULEDIR/$BOOST_VERSION.lua
cat ../modulefiles/boost.lua >> $MODULEDIR/$BOOST_VERSION.lua
