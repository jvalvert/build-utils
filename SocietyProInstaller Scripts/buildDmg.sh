#! /bin/bash

#deploy the dmgfile by using macdeployqt utility from Qt Creator
macdeployqt /Users/Rafa/Desktop/MenuBarTest-64bit-Release/MenuBarTest.app -dmg

#move the dmg to the output directory
mv /Users/Rafa/Desktop/MenuBarTest-64bit-Release/MenuBarTest.dmg /Users/Rafa/Desktop/sopro-dmg/MenuBarTest.dmg
