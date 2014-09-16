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
# Setting up variables
#
# NOTE:Modify this paths to point to the correct project path in your mac OS X box
#
# Set the full QMAKE location path

QMAKE=~/Qt/5.3/clang_64/bin/
# Project Path: (the local repo directory)
PROJECT=~/centraldev/societypro/repo/Cambrian-src
# SocietyPro Distribution Files
SOPRO_DIST=~/centraldev/societypro/repo/Cambrian-src/sopro-dist-root
#repo
REPO=test-dist
# Output Directory
OUTPUT=~/Desktop/sopro-dmg
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
echo Updating repository...
cd $PROJECT
git checkout $REPO
git pull
CD $WD
echo Copying Apps existing in $SOPRO_DIST repository...
cp -r $SOPRO_DIST $OUTPUT/sopro-dist-root

echo Compiling Cambrian...
# Build Cambrian and put it on output directory to be added to the dmg
cd $PROJECT
$QMAKE/qmake $PROJECT/Cambrian.pro -r -spec macx-clang CONFIG+=x86_64 CONFIG+=silent CONFIG+=warn_off
F# Make the app
make -f Makefile
echo Creating Installer...
# move the app to the output directory
mv SocietyPro.app $OUTPUT/SocietyPro.app
# create symbolic link to /Applications
ln -s /Applications Applications
cp -R Applications $OUTPUT/Applications
rm Applications

# Clean all the objective code
make clean
hdiutil create -volname SocietyPro -srcfolder $OUTPUT -ov -format UDZO $OUTPUT/SocietyPro.dmg

#Cleanup
cd $OUTPUT
rm -r sopro-dist-root
rm -r SocietyPro.app
#return to the current directory
cd $WD
echo Finished.  Installer available at $OUTPUT directory





