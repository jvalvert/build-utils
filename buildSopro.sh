#!/bin/sh
#  Purpose:  - Build Society Pro App in mac OS X and package on a Disk Image File (DMG) automaticaly
#            - Show all the apps in Society Pro DMG
#
#  Requeriments:
# - Have QT environment installed on a Mac OS X
# - Set the path to C++ compiler $QTINSTALLDIR/<version>/clang_64/bin
# - to upload the file check that the Dropbox App is running with the following credentials:
#   user: jorge@societypro.org
#   password: C@mbrian

#
echo Cambrian Installer for Mac 1.0 by Central Services. 2014
echo
echo Initializing...
################################## PARAMETERS###############################################
#
# NOTE:Modify this PARAMETERS to point to the correct project path REPO and customize app output
#
# Set the full QMAKE location path
QMAKE=~/Qt/5.3/clang_64/bin/
# Project Path: (the local repo directory)
PROJECT_PATH=~/repo/Cambrian-src
PROJECT=Cambrian.pro
#Mac App Name
APP=SocietyPro.app
APP_ICON=SocietyPro.icns
#Apps Directory Name
APPS_DIR=Apps
#DMG name put the correct version here
DMG=SocietyPro.dmg
DMG_TMP=Temp.dmg
DMG_VOLNAME=SocietyPro-0.1.6.8
DMG_BACKGROUND_IMG="SocietyPro_logo.png"
# SocietyPro Distribution Files
SOPRO_DIST=~repo/Cambrian-src/sopro-dist-root
#repo Cambrian-src branch master
BRANCH=master
# Output Directory
OUTPUT=~/Desktop/sopro-dmg
# Location of the local dropbox folder that sincronizes files to the cloud
DROPBOX=~/Dropbox
# Remember the original working directory
WD=$(pwd)
#
######################################################################################################
## Copy the apps to the build directory before build
#
# Create the output directory if it does not exist and ensure is empty:
#
mkdir -p $OUTPUT
rm -r $OUTPUT
mkdir $OUTPUT
#
# Update the repository
echo Updating repository...
# Enter to the repo where the project is located
cd $PROJECT_PATH
# checkout and checkin the correct branch
git checkout  $BRANCH
#ensure that all the changes in the branch master are pulled
git pull
git submodule update --init --recursive
echo Compiling Cambrian...
# Build Cambrian and put it on output directory to be added to the dmg
cd $PROJECT_PATH
$QMAKE/qmake $PROJECT_PATH/$PROJECT -r -spec macx-clang CONFIG+=x86_64 CONFIG+=silent CONFIG+=warn_off
# Make the app
make -f Makefile
# Clean all the objective code
make clean
# Deploy QT libraries to the release (avoid absolute path to dinamic libraries with @excecutable_path)
# Its ok if you see the next message:  ERROR: no file at "/opt/local/lib/mysql55/lib/libmysqlclient.18.dylib"
# This is because the process tries to add an Mysqlclient library.  If you want you can install mysqlclient but is not necesary.
echo Adding Qt Libraries to the app.  If you see an Mysql error just ignore it.
macdeployqt $APP

# move the app to the output directory
mv $APP $OUTPUT/$APP
# create symbolic link to /Applications
ln -s /Applications Applications
cp -R Applications $OUTPUT/Applications

#
# Move the apps file to the app
echo Copying Apps existing in $SOPRO_DIST repository to $APP/CONTENT/MACOS/APPS...
cp -r $SOPRO_DIST $OUTPUT/$APP/Contents/MacOS/$APPS_DIR
#Add icon to resources from icon located in
cp $WD/$APP_ICON $OUTPUT/$APP/Contents/Resources/SocietyPro.icns
#Overwrite the default Info.plist from the Info.plist located in script files
cp $WD/Info.plist $OUTPUT/$APP/Contents/Info.plist
CD $WD



#Create the dmg Disk
echo Creating Installer...
# Unmount the dmg if its loaded previously
hdiutil detach /Volumes/"${DMG_VOLNAME}"
#Customizations of the installer
# Modify the volume by mounting in readwrite

echo creating Temporal DMG to customize the installer...
cd $OUTPUT
hdiutil create -srcfolder $OUTPUT -volname $DMG_VOLNAME -fs HFS+ \
-fsargs "-c c=64,a=16,e=16" -format UDRW  $DMG_TMP

sleep 2

#Mount the device in readwrite mode
DEVICE=$(hdiutil attach -readwrite -noverify $DMG_TMP)


# Copy image background
cp $WD/$DMG_BACKGROUND_IMG $OUTPUT/$DMG_BACKGROUND_IMG

#Prepare the background image, so if the background image changes, it will be adapted
# Check the background image DPI and convert it if it isn't 72x72

_BACKGROUND_IMAGE_DPI_H=`sips -g dpiHeight ${OUTPUT}/${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`
_BACKGROUND_IMAGE_DPI_W=`sips -g dpiWidth ${OUTPUT}/${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`

if [ $(echo " $_BACKGROUND_IMAGE_DPI_H != 72.0 " | bc) -eq 1 -o $(echo " $_BACKGROUND_IMAGE_DPI_W != 72.0 " | bc) -eq 1 ]; then
echo "WARNING: The background image's DPI is not 72.  This will result in distorted backgrounds on Mac OS X 10.7+."
echo "         I will convert it to 72 DPI..."
cd $OUTPUT
_DMG_BACKGROUND_TMP="${DMG_BACKGROUND_IMG%.*}"_dpifix."${DMG_BACKGROUND_IMG##*.}"

sips -s dpiWidth 72 -s dpiHeight 72 ${DMG_BACKGROUND_IMG} --out ${_DMG_BACKGROUND_TMP}
#image modified by 72x72
DMG_BACKGROUND_IMG="${_DMG_BACKGROUND_TMP}"
fi

# add a background image to dmg
mkdir /Volumes/"${DMG_VOLNAME}"/.background

cp "${DMG_BACKGROUND_IMG}" /Volumes/"${DMG_VOLNAME}"/.background/
# tell the Finder to resize the window, set the background,
#  change the icon size, place the icons in the right position, etc.
echo '
tell application "Finder"
tell disk "'${DMG_VOLNAME}'"
open
set current view of container window to icon view
set toolbar visible of container window to false
set statusbar visible of container window to false
set the bounds of container window to {200,100, 800, 600}
set viewOptions to the icon view options of container window
set arrangement of viewOptions to not arranged
set icon size of viewOptions to 72
set background picture of viewOptions to file ".background:'${DMG_BACKGROUND_IMG}'"
set position of item "'${APP}'" of container window to {475, 1}
set position of item "Applications" of container window to {475,350}
close
open
update without registering applications
delay 2
end tell
end tell
' | osascript

sync

# unmount it
hdiutil detach /Volumes/"${DMG_VOLNAME}"

#final image a compressed disk image
echo "Creating compressed image and put it at output"
hdiutil convert "${DMG_TMP}" -format UDZO -imagekey zlib-level=9 -o $OUTPUT/$DMG


#Cleanup
cd $OUTPUT
rm -r $APP
rm $DMG_BACKGROUND_IMG
rm $DMG_TMP
rm -r Applications
# Move the installer to the cloud. Check if your dropbox folder is working
cp $OUTPUT/$DMG $DROPBOX/$DMG
#return to the current directory
cd $WD
echo Finished.  Installer available at $OUTPUT directory and upload to DROPBOX . Check if your dropbox app is running








