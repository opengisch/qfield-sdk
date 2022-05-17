#!/bin/bash

# version of your package
VERSION_libspatialite=5.0.1

# dependencies of this recipe
# sqlite3 is already in iOS SDK dir
DEPS_libspatialite=(proj iconv freexl geos)

# url of the package
URL_libspatialite=http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${VERSION_libspatialite}.tar.gz

# md5 of the package
MD5_libspatialite=5f4a961afbb95dcdc715b5d7f8590573

# default build path
BUILD_libspatialite=$BUILD_PATH/libspatialite/$(get_directory $URL_libspatialite)

# default recipe path
RECIPE_libspatialite=$RECIPES_PATH/libspatialite

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libspatialite() {
  cd $BUILD_libspatialite

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_OUT_PATH/.packages/config.sub "$BUILD_libspatialite"
  try cp $ROOT_OUT_PATH/.packages/config.guess "$BUILD_libspatialite"

  try patch -p1 < $RECIPE_libspatialite/patches/config.patch
  try patch -p1 < $RECIPE_libspatialite/patches/make.patch

  touch .patched
}

function shouldbuild_libspatialite() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libspatialite/build-$ARCH/src/.libs/libspatialite.a -nt $BUILD_libspatialite/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libspatialite() {
  try mkdir -p $BUILD_PATH/libspatialite/build-$ARCH
  try cd $BUILD_PATH/libspatialite/build-$ARCH

  push_arm

  # Use Proj 6.0.0 compatibility headers.
  # Remove in libspatialite 5.0.0
  export CFLAGS="$CFLAGS -DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
  # so the configure script can check that proj library contains pj_init_plus
  export LDFLAGS="$LDFLAGS -lc++"

  try $BUILD_libspatialite/configure \
    --prefix=$STAGE_PATH \
    --host=${TOOLCHAIN_PREFIX} \
    --with-geosconfig=$STAGE_PATH/bin/geos-config \
    --enable-libxml2=no \
    --disable-shared \
    --disable-examples \
    --enable-proj=yes \
    --enable-rttopo=no \
    --enable-gcp=no \
    --enable-minizip=no \
    --enable-static=yes


  try $MAKESMP
  try make install &> install.log

  pop_arm
}

# function called after all the compile have been done
function postbuild_libspatialite() {
  LIB_ARCHS=`lipo -archs ${STAGE_PATH}/lib/libspatialite.a`
  if [[ $LIB_ARCHS != *"$ARCH"* ]]; then
    error "Library was not successfully build for ${ARCH}"
    exit 1;
  fi
}
