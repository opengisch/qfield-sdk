#!/bin/bash


# version of your package
VERSION_proj=9.0.0

# dependencies of this recipe
DEPS_proj=(sqlite3 curl)

# url of the package
URL_proj=https://github.com/OSGeo/PROJ/releases/download/$VERSION_proj/proj-$VERSION_proj.tar.gz

# md5 of the package
MD5_proj=180f9c60f74526690d059219fc7871e0

# default build path
BUILD_proj=$BUILD_PATH/proj/$(get_directory $URL_proj)

# default recipe path
RECIPE_proj=$RECIPES_PATH/proj

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_proj() {
  cd $BUILD_proj

  # check marker
  if [ -f .patched ]; then
    return
  fi

  try cp $ROOT_OUT_PATH/.packages/config.sub "$BUILD_proj"
  try cp $ROOT_OUT_PATH/.packages/config.guess "$BUILD_proj"

  touch .patched
}

function shouldbuild_proj() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/proj/build-$ARCH/lib/libproj.a -nt $BUILD_proj/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_proj() {
  try mkdir -p $BUILD_PATH/proj/build-$ARCH
  try cd $BUILD_PATH/proj/build-$ARCH

  push_arm

  echo "using native sqlite3"
  which sqlite3

  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DPROJ_CMAKE_SUBDIR=share/cmake/proj4 \
    -DPROJ_DATA_SUBDIR=share/proj \
    -DPROJ_INCLUDE_SUBDIR=include \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DEXE_SQLITE3=`which sqlite3` \
    -DBUILD_APPS=OFF \
    -DENABLE_TIFF=OFF \
    -DENABLE_CURL=OFF \
    $BUILD_proj
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_proj() {
  LIB_ARCHS=`lipo -archs ${STAGE_PATH}/lib/libproj.a`
  if [[ $LIB_ARCHS != *"$ARCH"* ]]; then
    error "Library was not successfully build for ${ARCH}"
    exit 1;
  fi
}
