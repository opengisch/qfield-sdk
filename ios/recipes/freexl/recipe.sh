#!/bin/bash
# a library to extract valid data from within an Excel (.xls) spreadsheet

# version of your package
VERSION_freexl=1.0.2

# dependencies of this recipe
DEPS_freexl=(iconv)

# url of the package
URL_freexl=http://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-${VERSION_freexl}.tar.gz

# md5 of the package
MD5_freexl=9954640e5fed76a5d9deb9b02b0169a0

# default build path
BUILD_freexl=$BUILD_PATH/freexl/$(get_directory $URL_freexl)

# default recipe path
RECIPE_freexl=$RECIPES_PATH/freexl

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_freexl() {
  cd $BUILD_freexl

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_OUT_PATH/.packages/config.sub $BUILD_freexl
  try cp $ROOT_OUT_PATH/.packages/config.guess $BUILD_freexl

  touch .patched
}

function shouldbuild_freexl() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/freexl/build-$ARCH/src/.libs/libfreexl.a -nt $BUILD_freexl/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_freexl() {
  try mkdir -p $BUILD_PATH/freexl/build-$ARCH
  try cd $BUILD_PATH/freexl/build-$ARCH
  push_arm
  export LDFLAGS="$LDFLAGS -liconv"
  try $BUILD_freexl/configure --prefix=$STAGE_PATH --host=${TOOLCHAIN_PREFIX} --disable-shared
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_freexl() {
  LIB_ARCHS=`lipo -archs ${STAGE_PATH}/lib/libfreexl.a`
  if [[ $LIB_ARCHS != *"$ARCH"* ]]; then
    error "Library was not successfully build for ${ARCH}"
    exit 1;
  fi
}
