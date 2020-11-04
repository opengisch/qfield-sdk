#!/usr/bin/env bash


QGIS_DEPS_VER=0.5.5

wget https://qgis.org/downloads/macos/deps/install_qgis_deps-${QGIS_DEPS_VER}.bash
chmod +x install_qgis_deps-${QGIS_DEPS_VER}.bash
./install_qgis_deps-${QGIS_DEPS_VER}.bash