#!/bin/bash
#  Purpose:  - Build Society Pro App in mac OS X and package on a Disk Image File (DMG) automatically
#            - Show all the apps in Society Pro DMG
#
#  Requeriments:
# - Have QT environment installed on a Mac OS X
# - Set the path to C++ compiler $QTINSTALLDIR/<version>/clang_64/bin
#

# make sure we are in the correct dir when we double-click a .command file
dir=${0%/*}
if [ -d "$dir" ]; then
  cd "$dir"
fi

# Setting up  variables
#
# NOTE:Modify this paths to point to the correct project path in your mac OS X box
#
# Set the full QMAKE location path
QMAKE=/Users/Rafa/Qt/5.3/clang_64/bin/
# Project Path: (the local repo directory)
PROJECT_PATH=/Users/Rafa/centraldev/societypro/repo/Cambrian-src
PROJECT=Cambrian
# SocietyPro Distribution Files
SOPRO_DIST=/Users/Rafa/centraldev/societypro/repo/Cambrian-src/sopro-dist-root
# Output Directory
OUTPUT=/Users/Rafa/Desktop/sopro-dmg
#  App name, version number, and background image file name
APP_NAME="SocietyPro"
VERSION="0.0.20"
DMG_BACKGROUND_IMG="SocietyPro_logo.png"
# Remember the original working directory
WD=$(pwd)
#
# Copy the apps to the build directory before build
#
# Create the output directory if it does not exist and ensure is empty:
#
mkdir -p $OUTPUT
rm -r $OUTPUT
mkdir $OUTPUT
#
# Move the apps file to output
#
#cp -r $SOPRO_DIST $OUTPUT/sopro-dist

# Build Cambrian and put it on output directory to be added to the dmg
#cd $PROJECT_PATH
echo Compiling Societypro C++ Code. Please Wait....

#$QMAKE/qmake $PROJECT_PATH/$PROJECT.pro -r -spec macx-clang CONFIG+=x86_64
# Make the app
#make -f Makefile



# move the app to the output directory
#mv $APP_NAME $OUTPUT/$APP_NAME $VERSION.app

# Clean all the objective code
#make clean
#cp SocietyPro.
cd OUTPUT
# you should not need to change these
APP_EXE=$"${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
VOL_NAME="${APP_NAME} ${VERSION}"   # volume name will be "SocietyPro 1.0.0"
DMG_TMP="${VOL_NAME}-temp.dmg"
DMG_FINAL="${VOL_NAME}.dmg"         # final DMG name will be "SuperCoolApp 1.0.0.dmg"
STAGING_DIR="./Install"             # we copy all our stuff into this dir

# Check the background image DPI and convert it if it isn't 72x72
_BACKGROUND_IMAGE_DPI_H=`sips -g dpiHeight ${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`
_BACKGROUND_IMAGE_DPI_W=`sips -g dpiWidth ${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`

if [ $(echo " $_BACKGROUND_IMAGE_DPI_H != 72.0 " | bc) -eq 1 -o $(echo " $_BACKGROUND_IMAGE_DPI_W != 72.0 " | bc) -eq 1 ]; then
   echo "WARNING: The background image's DPI is not 72.  This will result in distorted backgrounds on Mac OS X 10.7+."
   echo "         I will convert it to 72 DPI for you."
   
   _DMG_BACKGROUND_TMP="${DMG_BACKGROUND_IMG%.*}"_dpifix."${DMG_BACKGROUND_IMG##*.}"

   sips -s dpiWidth 72 -s dpiHeight 72 ${DMG_BACKGROUND_IMG} --out ${_DMG_BACKGROUND_TMP}
   
   DMG_BACKGROUND_IMG="${_DMG_BACKGROUND_TMP}"
fi

# clear out any old data
rm -rf "${STAGING_DIR}" "${DMG_TMP}" "${DMG_FINAL}"

# copy over the stuff we want in the final disk image to our staging dir
mkdir -p "${STAGING_DIR}"
cp -rpf "${APP_NAME}.app" "${STAGING_DIR}"
# ... cp anything else you want in the DMG - documentation, etc.

pushd "${STAGING_DIR}"

# strip the executable
echo "Stripping ${APP_EXE}..."
strip -u -r "${APP_EXE}"

# compress the executable if we have upx in PATH
#  UPX: http://upx.sourceforge.net/
if hash upx 2>/dev/null; then
   echo "Compressing (UPX) ${APP_EXE}..."
   upx -9 "${APP_EXE}"
fi

# ... perform any other stripping/compressing of libs and executables

popd

# figure out how big our DMG needs to be
#  assumes our contents are at least 1M!
SIZE=`du -sh "${STAGING_DIR}" | sed 's/\([0-9\.]*\)M\(.*\)/\1/'` 
SIZE=`echo "${SIZE} + 1.0" | bc | awk '{print int($1+0.5)}'`

if [ $? -ne 0 ]; then
   echo "Error: Cannot compute size of staging dir"
   exit
fi

# create the temp DMG file
hdiutil create -srcfolder "${STAGING_DIR}" -volname "${VOL_NAME}" -fs HFS+ \
      -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${SIZE}M "${DMG_TMP}"

echo "Created DMG: ${DMG_TMP}"

# mount it and save the device
DEVICE=$(hdiutil attach -readwrite -noverify "${DMG_TMP}" | \
         egrep '^/dev/' | sed 1q | awk '{print $1}')

sleep 2

# add a link to the Applications dir
echo "Add link to /Applications"
pushd /Volumes/"${VOL_NAME}"
ln -s /Applications
popd

# add a background image
mkdir /Volumes/"${VOL_NAME}"/.background
cp "${DMG_BACKGROUND_IMG}" /Volumes/"${VOL_NAME}"/.background/

# tell the Finder to resize the window, set the background,
#  change the icon size, place the icons in the right position, etc.
echo '
   tell application "Finder"
     tell disk "'${VOL_NAME}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 100, 920, 440}
           set viewOptions to the icon view options of container window
           set arrangement of viewOptions to not arranged
           set icon size of viewOptions to 72
           set background picture of viewOptions to file ".background:'${DMG_BACKGROUND_IMG}'"
           set position of item "'${APP_NAME}'.app" of container window to {160, 205}
           set position of item "Applications" of container window to {360, 205}
           close
           open
           update without registering applications
           delay 2
     end tell
   end tell
' | osascript

sync

# unmount it
hdiutil detach "${DEVICE}"

# now make the final image a compressed disk image
echo "Creating compressed image"
hdiutil convert "${DMG_TMP}" -format UDZO -imagekey zlib-level=9 -o "${DMG_FINAL}"

# clean up
rm -rf "${DMG_TMP}"
rm -rf "${STAGING_DIR}"

echo 'Done.'

exit