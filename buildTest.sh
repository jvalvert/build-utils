#!/bin/sh
#  Purpose:  - Build Society Pro App in mac OS X and package on a Disk Image File (DMG) automaticaly
#            - Show all the apps in Society Pro DMG
#
#  Requeriments:
# - Have QT environment installed on a Mac OS X
# - Set the path to C++ compiler $QTINSTALLDIR/<version>/clang_64/bin
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
PROJECT_PATH=~/Desktop/MenuBarTest
PROJECT=Cambrian.pro
#Mac App Name
APP=MenuBarTest.app
#Apps Directory Name
APPS_DIR=Apps
#DMG name
DMG=SocietyPro.dmg
DMG_VOLNAME=SocietyPro
# SocietyPro Distribution Files
SOPRO_DIST=~/Desktop/MenuBarTest/sopro-dist-root
#repo BRANCH
REPO=mac-test-dev
# Output Directory
OUTPUT=~/Desktop/sopro-dmg
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


echo Compiling Cambrian...
# Build Cambrian and put it on output directory to be added to the dmg
cd $PROJECT_PATH
$QMAKE/qmake $PROJECT_PATH/$PROJECT -r -spec macx-clang CONFIG+=x86_64 CONFIG+=silent CONFIG+=warn_off
# Make the app
make -f Makefile
# Clean all the objective code
make clean

# move the app to the output directory
mv $APP $OUTPUT/$APP
# create symbolic link to /Applications
ln -s /Applications Applications
cp -R Applications $OUTPUT/Applications

#
# Move the apps file to the app
#
#echo Updating repository...
#cd $PROJECT_PATH
#git checkout $REPO
#git pull
echo Copying Apps existing in $SOPRO_DIST repository to $APP/CONTENT/MACOS/APPS...

#Copy Apps
cp -r $SOPRO_DIST $OUTPUT/$APP/Contents/MacOS/$APPS_DIR
#Add icon to resources
cp $WD/SocietyPro.icns $OUTPUT/$APP/Contents/Resources/SocietyPro.icns
#Overwrite the default Info.plist
cp $WD/Info.plist $OUTPUT/$APP/Contents/Info.plist
CD $WD


#Create the dmg Disk
echo Creating Installer...
#hdiutil create -volname $DMG_VOLNAME -srcfolder $OUTPUT -ov -format UDZO $OUTPUT/$DMG

#Cleanup
cd $OUTPUT
#rm -r $APP
rm Applications
#return to the current directory
cd $WD
echo Finished.  Installer available at $OUTPUT directory





