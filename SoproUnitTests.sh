#!/bin/sh

#  SoproUnitTests.sh
#  
#
#  Created by Central Services  on 27/11/14.
#
#  Have a good testing :)


#ENVIRONMENT VARIABLES

EXECUTABLE_PATH="/Users/Rafa/builds/googleTests-rel/googleTest.app/Contents/MacOS"
EXECUTABLE="googleTest"
XML_FILE="testsResult.xml"


# Perform the tests...

$EXECUTABLE_PATH/$EXECUTABLE --gtest_output=xml:$XML_FILE



