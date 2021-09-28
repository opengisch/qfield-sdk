#!/bin/bash

# dependencies of this recipe
DEPS_qgis=(protobuf libtasn1 gdal qca proj libspatialite libspatialindex expat postgresql libzip libzstd qtkeychain exiv2 qtlocation)

# url of the package
URL_qgis=https://github.com/3nids/QGIS/archive/61a34154e0.tar.gz

# md5 of the package
MD5_qgis=4559bf40b85a55176997834ff30ec0c6

# default build path
BUILD_qgis=$BUILD_PATH/qgis/$(get_directory $URL_qgis)

# default recipe path
RECIPE_qgis=$RECIPES_PATH/qgis

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_qgis() {
  cd $BUILD_qgis
  # check marker
  if [ -f .patched ]; then
    return
  fi

  module_dir=$(eval "echo \$O4iOS_qgis_DIR")
  if [ "$module_dir" ]
  then
    echo "\$O4iOS_qgis_DIR is not empty, manually patch your files if needed!"
  else
    echo "no patch"
    # try patch -p1 < $RECIPE_qgis/patches/qgis-printer.patch
  fi

  touch .patched
}

function shouldbuild_qgis() {
 # If lib is newer than the sourcecode skip build
 if [ ${STAGE_PATH}/QGIS.app/Contents/Frameworks/qgis_core.framework/qgis_core -nt $BUILD_qgis/.patched ]; then
   DO_BUILD=0
 fi
}


# function called to build the source code
function build_qgis() {
  try mkdir -p $BUILD_PATH/qgis/build-$ARCH
  try cd $BUILD_PATH/qgis/build-$ARCH

  push_arm

  try ${CMAKECMD} \
    -DBISON_EXECUTABLE=`which bison` \
    -DCHARSET_LIBRARY=$STAGE_PATH/lib/libcharset.a \
    -DCMAKE_DISABLE_FIND_PACKAGE_HDF5=TRUE \
    -DCMAKE_DISABLE_FIND_PACKAGE_QtQmlTools=TRUE \
    -DCMAKE_DISABLE_FIND_PACKAGE_ZSTD=TRUE \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DDISABLE_DEPRECATED=ON \
    -DENABLE_TESTS=OFF \
    -DEXIV2_INCLUDE_DIR=$STAGE_PATH/include \
    -DEXIV2_LIBRARY=$STAGE_PATH/lib/libexiv2.a \
    -DEXPAT_INCLUDE_DIR=$STAGE_PATH/include \
    -DEXPAT_LIBRARY=$STAGE_PATH/lib/libexpat.a \
    -DFLEX_EXECUTABLE=`which flex` \
    -DFORCE_STATIC_LIBS=TRUE \
    -DFREEXL_LIBRARY=$STAGE_PATH/lib/libfreexl.a \
    -DGDAL_CONFIG=$STAGE_PATH/bin/gdal-config \
    -DGDAL_CONFIG_PREFER_FWTOOLS_PAT=/bin_safe \
    -DGDAL_CONFIG_PREFER_PATH=$STAGE_PATH/bin \
    -DGDAL_INCLUDE_DIR=$STAGE_PATH/include \
    -DGDAL_LIBRARY=$STAGE_PATH/lib/libgdal.a \
    -DGDAL_VERSION=3.1.3 \
    -DGEOSCXX_LIBRARY=$STAGE_PATH/lib/libgeos.a \
    -DGEOS_CONFIG=$STAGE_PATH/bin/geos-config \
    -DGEOS_CONFIG_PREFER_PATH=$STAGE_PATH/bin \
    -DGEOS_INCLUDE_DIR=$STAGE_PATH/include \
    -DGEOS_LIBRARY=$STAGE_PATH/lib/libgeos_c.a \
    -DGEOS_LIB_NAME_WITH_PREFIX=-lgeos_c \
    -DGEOS_VERSION=3.9.1 \
    -DICONV_INCLUDE_DIR=$SYSROOT\
    -DICONV_LIBRARY=$SYSROOT/usr/lib/libiconv.tbd \
    -DIOS=TRUE \
    -DLIBTASN1_INCLUDE_DIR=$STAGE_PATH/include \
    -DLIBTASN1_LIBRARY=$STAGE_PATH/lib/libtasn1.a \
    -DLIBTIFFXX_LIBRARY=$STAGE_PATH/lib/libtiffxx.a \
    -DLIBTIFF_LIBRARY=$STAGE_PATH/lib/libtiff.a \
    -DLIBZIP_CONF_INCLUDE_DIR=$STAGE_PATH/include \
    -DLIBZIP_INCLUDE_DIR=$STAGE_PATH/include \
    -DLIBZIP_LIBRARY=$STAGE_PATH/lib/libzip.a \
    -DPOSTGRES_CONFIG= \
    -DPOSTGRES_CONFIG_PREFER_PATH= \
    -DPOSTGRES_INCLUDE_DIR=$STAGE_PATH/include \
    -DPOSTGRES_LIBRARY=$STAGE_PATH/lib/libpq.a \
    -DPROJ_INCLUDE_DIR=$STAGE_PATH/include \
    -DPROJ_LIBRARY=$STAGE_PATH/lib/libproj.a \
    -DProtobuf_INCLUDE_DIRS:PATH=$STAGE_PATH/include \
    -DProtobuf_LIBRARY=$STAGE_PATH/lib/libprotobuf.a \
    -DProtobuf_LITE_LIBRARY=$STAGE_PATH/lib/libprotobuf-lite.a \
    -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=$NATIVE_STAGE_PATH/bin/protoc \
    -DProtobuf_PROTOC_LIBRARY=$STAGE_PATH/lib/libprotoc.a \
    -DQCA_INCLUDE_DIR=$STAGE_PATH/include/QtCrypto \
    -DQCA_LIBRARY=$STAGE_PATH/lib/libqca-qt5.a \
    -DQCA_VERSION_STR=2.1.0 \
    -DQTKEYCHAIN_INCLUDE_DIR=$STAGE_PATH/include/qt5keychain \
    -DQTKEYCHAIN_LIBRARY=$STAGE_PATH/lib/libqt5keychain.a \
    -DQT_LRELEASE_EXECUTABLE=`which lrelease` \
    -DSPATIALINDEX_INCLUDE_DIR=$STAGE_PATH/include/spatialindex \
    -DSPATIALINDEX_LIBRARY=$STAGE_PATH/lib/libspatialindex.a \
    -DSPATIALITE_INCLUDE_DIR=$STAGE_PATH/include \
    -DSPATIALITE_LIBRARY=$STAGE_PATH/lib/libspatialite.a \
    -DSQLITE3_INCLUDE_DIR=$SYSROOT \
    -DSQLITE3_LIBRARY=$SYSROOT/usr/lib/libsqlite3.tbd \
    -DWITH_ANALYSIS=ON \
    -DWITH_APIDOC=OFF \
    -DWITH_ASTYLE=OFF \
    -DWITH_BINDINGS=OFF \
    -DWITH_DESKTOP=OFF \
    -DWITH_EPT=OFF \
    -DWITH_GSL=OFF \
    -DWITH_GRASS=OFF \
    -DWITH_GUI=OFF \
    -DWITH_INTERNAL_QWTPOLAR=OFF \
    -DWITH_INTERNAL_SPATIALITE=OFF \
    -DWITH_PDAL=OFF \
    -DWITH_QGIS_PROCESS=OFF \
    -DWITH_QT5SERIALPORT=OFF \
    -DWITH_QTMOBILITY=OFF \
    -DWITH_QTWEBKIT=OFF \
    -DWITH_QUICK=OFF \
    -DWITH_QWTPOLAR=OFF \
    -DQGIS_MACAPP_BUNDLE=-1 \
    -DWITH_AUTH=ON \
    $BUILD_qgis

  try $MAKESMP install

  # Why it is not copied by CMake?
  try cp $BUILD_PATH/qgis/build-$ARCH/src/core/qgis_core.h ${STAGE_PATH}/QGIS.app/Contents/Frameworks/qgis_core.framework/Headers/
  try cp $BUILD_PATH/qgis/build-$ARCH/src/analysis/qgis_analysis.h ${STAGE_PATH}/QGIS.app/Contents/Frameworks/qgis_analysis.framework/Headers/

  # bundle QGIS's find packages too
  try mkdir -p $STAGE_PATH/cmake/
  try cp -Rf $BUILD_qgis/cmake/* $STAGE_PATH/cmake/

  pop_arm
}

# function called after all the compile have been done
function postbuild_qgis() {
  # bundle QGIS's find packages too
  try mkdir -p $STAGE_PATH/cmake/
  try cp -Rf $BUILD_qgis/cmake/* $STAGE_PATH/cmake/
}
