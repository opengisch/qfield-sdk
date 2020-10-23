#!/bin/bash

# version of your package
# NOTE: if changed, update also qgis's recipe
VERSION_gdal=3.1.3

# dependencies of this recipe
DEPS_gdal=(iconv geos postgresql expat)

# url of the package
URL_gdal=http://download.osgeo.org/gdal/$VERSION_gdal/gdal-${VERSION_gdal}.tar.gz

# md5 of the package
MD5_gdal=4094633f28a589a7b4b483aa51beb37c

# default build path
BUILD_gdal=$BUILD_PATH/gdal/$(get_directory $URL_gdal)

# default recipe path
RECIPE_gdal=$RECIPES_PATH/gdal

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_gdal() {
  cd $BUILD_gdal

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_OUT_PATH/.packages/config.sub $BUILD_gdal
  try cp $ROOT_OUT_PATH/.packages/config.guess $BUILD_gdal

  touch .patched
}

function shouldbuild_gdal() {
  # If lib is newer than the sourcecode skip build
  if [ $STAGE_PATH/lib/libgdal.a -nt $BUILD_gdal/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_gdal() {
  try rsync -a $BUILD_gdal/ $BUILD_PATH/gdal/build-$ARCH/
  try cd $BUILD_PATH/gdal/build-$ARCH

  push_arm

  export LDFLAGS="${LDFLAGS} -liconv"
  export CFLAGS="${CFLAGS} -Wno-error=implicit-function-declaration"

  GDAL_FLAGS="--disable-shared"
  if [ $DEBUG -eq 1 ]; then
    info "Building DEBUG version of GDAL!!"
    GDAL_FLAGS="$GDAL_FLAGS --enable-debug"
  fi

  # png. by default -lpng is not found and internal is build. this causes crash in routine png_read_info
  # during loading of Qt's components like CheckBox, ComboBox, etc, since the gdal's internal png lib is
  # incompatible with Qt's required lib
  # we can use /opt/Qt/5.13.1/ios//lib/libqtlibpng*, but there are no png.h headers in Qt's installation

  # at runtime: Wrong JPEG library version: library is 62, caller expects 80
  # (GDAL tries to build internal JPEG library incompatible with Qt's internal JPEG lib)
  # /opt/Qt/5.13.1/ios//plugins/imageformats/libqjpeg.a ... maybe use Qt's one?
  # with-mrf=no \ # depends on jpeg

  try ./configure \
    --prefix=$STAGE_PATH \
    --host=${TOOLCHAIN_PREFIX} \
    --with-sqlite3=$SYSROOT \
    --with-geos=$STAGE_PATH/bin/geos-config \
    --with-pg=no \
    --with-expat=$STAGE_PATH \
    --with-rename-internal-libtiff-symbols=yes \
    --with-rename-internal-libgeotiff-symbols=yes \
    --with-rename-internal-shapelib-symbols=yes \
    --with-poppler=no \
    --with-podofo=no \
    --with-pdfium=no \
    --disable-driver-mrf \
    --with-jpeg=no \
    --with-proj=$STAGE_PATH \
    --with-png=no \
    $GDAL_FLAGS

  try $MAKESMP
  try make install &> install.log

  pop_arm
}

# function called after all the compile have been done
function postbuild_gdal() {
  LIB_ARCHS=`lipo -archs ${STAGE_PATH}/lib/libgdal.a`
  if [[ $LIB_ARCHS != *"$ARCH"* ]]; then
    error "Library was not successfully build for ${ARCH}"
    exit 1;
  fi
}
