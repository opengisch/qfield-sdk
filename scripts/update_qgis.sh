#!/usr/bin/env bash

set -e

SHA=$1

# GNU prefix command for mac os support (gsed, gsplit)
GP=
if [[ "$OSTYPE" =~ darwin* ]]; then
  GP=g
fi

platforms=(android ios mac)
for platform in "${platforms[@]}"; do
  ${GP}sed -i -r "s@(^URL_qgis.*)/\w+\.(zip|tar.gz)@\1/${SHA}.tar.gz@" ${platform}/recipes/qgis/recipe.sh
done

URL=$(${GP}sed -n -r 's/^URL_qgis=(.*)$/\1/p' ios/recipes/qgis/recipe.sh)
echo $URL
SUM=$(wget $URL -O- | md5sum | cut -d ' ' -f 1)
echo $SUM

for platform in "${platforms[@]}"; do
  ${GP}sed -i -r "s/^MD5_qgis=.*/MD5_qgis=${SUM}/" ${platform}/recipes/qgis/recipe.sh
done
