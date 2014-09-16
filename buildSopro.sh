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
PROJECT_PATH=~/centraldev/societypro/repo/Cambrian-src
PROJECT=Cambrian.pro
#Mac App Name
APP=SocietyPro.app
#Apps Directory Name
APPS_DIR=SocietyPro-Apps
#DMG name
DMG=SocietyPro.dmg
DMG_VOLNAME=SocietyPro
# SocietyPro Distribution Files
SOPRO_DIST=~/centraldev/societypro/repo/Cambrian-src/sopro-dist-root
#repo BRANCH
REPO=test-dist
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
#
# Move the apps file to output
#
echo Updating repository...
cd $PROJECT_PATH
git checkout $REPO
git pull
CD $WD
echo Copying Apps existing in $SOPRO_DIST repository...
cp -r $SOPRO_DIST $OUTPUT/$APPS_DIR

echo Compiling Cambrian...
# Build Cambrian and put it on output directory to be added to the dmg
cd $PROJECT_PATH
$QMAKE/qmake $PROJECT_PATH/$PROJECT -r -spec macx-clang CONFIG+=x86_64 CONFIG+=silent CONFIG+=warn_off
F# Make the app
make -f Makefile

# move the app to the output directory
mv $APP $OUTPUT/$APP
# create symbolic link to /Applications
ln -s /Applications Applications
cp -R Applications $OUTPUT/Applications


# Clean all the objective code
make clean

#Create the dmg Disk
echo Creating Installer...
hdiutil create -volname $DMG_VOLNAME -srcfolder $OUTPUT -ov -format UDZO $OUTPUT/$DMG

#Cleanup
cd $OUTPUT
rm -r $APPS_DIR
rm -r $APP
rm Applications
#return to the current directory
cd $WD
echo Finished.  Installer available at $OUTPUT directory





