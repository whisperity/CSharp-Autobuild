#!/bin/bash
# This is for computers running Windows operating system. Tested on Win7.
# To be ran from Git Bash (mingw32). Should work on cygwin, but not promising anything.
### Description ###
# A lightened edition of AutoBuild.sh.
# This script only builds the specified solution but removes the built executable.
#
# It returns 0 if the build was successful and non-zero if there were problems building.
#
# - Whisperity
### Usage ###
# - Put the shell file into an arbitrary folder
# - Check and set the configuration values below
# - Run the script by specifying which branch to build (e.g.: `TestBuild.sh`)
#
# Used by the hooks posted.

### Configuration ###
# BuildFolder is the name of the folder we are using to build
# It will contain the checked out source code and of course the built executable
BUILDFOLDER=precommit_test

# The ABSOLUTE path to msbuild.exe used to build the solutions
MSBUILD="/c/Windows/Microsoft.NET/Framework/v4.0.30319/msbuild.exe"

# The solution file we will build (relative to BUILDFOLDER)
SOLUTION=Solution1.sln

# The path to the built executable (relative to BUILDFOLDER)
BUILTPATH=ConsoleApplication1/bin/Release

# The name of the built executable (relative to BUILTPATH, without '.exe')
BUILTNAME=ConsoleApplication1

### Entry point ###
# Saves the script's absolute location so cleanup works.
SCRIPTDIRECTORY=`pwd`

if [ ! -d $BUILDFOLDER ]
 then
    echo "The build folder $BUILDFOLDER does not exist"
    exit 1
fi

cd $BUILDFOLDER

# Build the current solution and report the result
$MSBUILD $SOLUTION "//nologo" "//noautoresponse" "//nodeReuse:false" "//verbosity:quiet" "//property:WarningLevel=0" "//property:Configuration=Release"

if [ $? -ne 0 ]
 then
    exit 3
fi

rm $BUILTPATH/$BUILTNAME.exe

# End.
exit 0
