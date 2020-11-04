# MacOS builds

### Download Qt and QGIS deps
   
```
 sudo ./get-qgis-deps.sh
```

### Compile QGIS for QField

```
sudo ARCHES=clang_64 ./distribute.sh -m qgis
package.bash
```

4. upload to Dropbox "Lutra Consulting/_Support/input/input-sdks/mac-sdk" & share
5. tag the repo
6. update input to use new SDK version
