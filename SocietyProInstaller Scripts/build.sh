#! /bin/bash
cd /Users/Rafa/Desktop/MenuBarTest
/Users/Rafa/Qt/5.3/clang_64/bin/qmake /Users/Rafa/Desktop/MenuBarTest/MenuBarTest.pro -r -spec macx-clang CONFIG+=x86_64
make -f Makefile
mv MenuBarTest.app /Users/Rafa/Desktop/MenuBarTest-64bit-Release/MenuBarTest.app
make clean


