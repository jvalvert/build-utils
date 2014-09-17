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
echo Cambrian Installer 1.0 by Central Services. 2014
echo
echo Initializing...
################################## PARAMETERS###############################################
#
# NOTE:Modify this PARAMETERS to point to the correct project path REPO and customize app output
#
# Set the full QMAKE location path
QMAKE=~/Qt/5.3/clang_64/bin/
# Project Path: (the local repo directory)
PROJECT_PATH=~/centraldev/societypro/repo/Cambrian-src
PROJECT=Cambrian.pro
#Mac App Name
APP=SocietyPro.app
APP_ICON=SocietyPro.icns
#Apps Directory Name
APPS_DIR=Apps
#DMG name
DMG=SocietyPro.dmg
DMG_VOLNAME=SocietyPro
# SocietyPro Distribution Files
SOPRO_DIST=~/centraldev/societypro/repo/Cambrian-src/sopro-dist-root
#repo BRANCH
REPO=master
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
git checkout  $REPO
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
CD $WD


#Create the dmg Disk
echo Creating Installer...
hdiutil create -volname $DMG_VOLNAME -srcfolder $OUTPUT -ov -format UDZO $OUTPUT/$DMG

#Cleanup
cd $OUTPUT
rm -r $APP
rm Applications
# Move the installer to the cloud. Check if your dropbox folder is working
cp $OUTPUT/$DMG $DROPBOX/$DMG
#return to the current directory
cd $WD
echo Finished.  Installer available at $OUTPUT directory and upload to DROPBOX . Check if your dropbox app is running








