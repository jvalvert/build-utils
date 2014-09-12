#!/bin/sh
#  Purpose:  - Build Society Pro App in mac OS X and package on a Disk Image File (DMG) automaticaly
#            - Show all the apps in Society Pro DMG
#
#  Requeriments:
# - Have QT environment installed on a Mac OS X
# - Set the path to C++ compiler $QTINSTALLDIR/<version>/clang_64/bin
#
# Setting up environment variables
#
# NOTE:Modify this paths to point to the correct project path in your mac OS X box
#
# Set the full QMAKE location path
export QMAKE=/Users/Rafa/Qt/5.3/clang_64/bin/
# Project Path: (the local repo directory)
export PROJECT=/Users/Rafa/centraldev/societypro/repo/Cambrian-src
# SocietyPro Distribution Files
export SOPRO_DIST=/Users/Rafa/centraldev/societypro/repo/Cambrian-src/sopro-dist
# Output Directory
export OUTPUT=/Users/Rafa/Desktop/sopro-dmg
# Remember the original working directory
export WD=$(pwd)
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
cp -r $SOPRO_DIST $OUTPUT/sopro-dist

# Build Cambrian and put it on output directory to be added to the dmg
cd $PROJECT
$QMAKE/qmake $PROJECT/Cambrian.pro -r -spec macx-clang CONFIG+=x86_64
# Make the app
make -f Makefile
# move the app to the output directory
mv SocietyPro.app $OUTPUT/SocietyPro.app
# Clean all the objective code
make clean
hdiutil create -volname SocietyPro -srcfolder $OUTPUT -ov -format UDZO $OUTPUT/SocietyPro.dmg

#Cleanup
cd $OUTPUT
rm -r sopro-dist
rm SocietyPro.app
#return to the current directory
cd $WD





