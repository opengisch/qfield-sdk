#!/bin/bash

# version of your package
VERSION_libzstd=v1.5.0

# dependencies of this recipe
DEPS_libzstd=()

# url of the package
#URL_libzstd=https://github.com/facebook/zstd/archive/${VERSION_libzstd}.zip
URL_libzstd=https://github.com/3nids/zstd/archive/6d09eff.zip

# md5 of the package
MD5_libzstd=20820ffe830a6ff8c85451cdf5ffdde9

# default build path
BUILD_libzstd=$BUILD_PATH/libzstd/$(get_directory $URL_libzstd)

# default recipe path
RECIPE_libzstd=$RECIPES_PATH/libzstd

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libzstd() {
  cd $BUILD_libzstd

  # check marker
  if [ -f .patched ]; then
    return
  fi
}

function shouldbuild_libzstd() {
  # If lib is newer than the sourcecode skip build
  if [ $BUILD_PATH/libzstd/build-$ARCH/lib/libzstd.a -nt $BUILD_libzstd/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_libzstd() {
  try mkdir -p $BUILD_PATH/libzstd/build-$ARCH
  try cd $BUILD_PATH/libzstd/build-$ARCH
  push_arm

  # configure
  try $CMAKECMD \
    -DCMAKE_INSTALL_PREFIX:PATH=$STAGE_PATH \
    -DIOS=TRUE \
    -DBUILD_SHARED_LIBS=FALSE \
    $BUILD_libzstd/build/cmake/

  # try $MAKESMP
  try $MAKESMP install

  pop_arm
}

# function called after all the compile have been done
function postbuild_libzstd() {
	true
}
