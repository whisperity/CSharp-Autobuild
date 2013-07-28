#!/bin/bash
# This is for computers running Windows operating system. Tested on Win7.
# To be ran from Git Bash (mingw32). Should work on cygwin, but not promising anything.
### Description ###
# Just a small script I put together to automatically build my C# projects from a remote repository.
#
# - Whisperity
### Usage ###
# - Put the shell file into an arbitrary folder
# - Check and set the configuration values below
# - Run the script by specifying which branch to build (e.g.: `AutoBuild.sh master`)
# - The built executable will be copied to the folder the script is in.

### Configuration ###
# BuildFolder is the name of the folder we are using to build
# It will contain the checked out source code and of course the built executable
BUILDFOLDER=build

# The URL of the remote the source code will be pulled from
REMOTEURL="file:///c/path/to/repository"

# The ABSOLUTE path to msbuild.exe used to build the solutions
MSBUILD="/c/Windows/Microsoft.NET/Framework/v4.0.30319/msbuild.exe"

# The solution file we will build (relative to BUILDFOLDER)
SOLUTION=Solution1.sln

# The path to the built executable (relative to BUILDFOLDER)
BUILTPATH=ConsoleApplication1/bin/Release

# The name of the built executable (relative to BUILTPATH, without '.exe')
BUILTNAME=ConsoleApplication1

cleanup()
{
    # Cleanup: remove the whole build folder
    cd "$SCRIPTDIRECTORY"
    rm -rf $BUILDFOLDER
}

### Entry point ###

# Saves the script's absolute location so cleanup works.
SCRIPTDIRECTORY=`pwd`

if [ -d $BUILDFOLDER ]
 then
    echo "The build folder $BUILDFOLDER already exists"
    cleanup
fi

# Of course, we specify what branch we want to build
BRANCH=$1

if [ "$BRANCH" == "" ]
 then
    BRANCH=master
fi

# Set up the build folder and add the information about the remote
mkdir $BUILDFOLDER
cd $BUILDFOLDER
git init --quiet .
git remote add origin "$REMOTEURL"

#echo "Cloning the remote repository..."
git fetch --quiet --all

# Check whether the branch we specified exists
## We check the remote for the specified branch,
## then count the number of lines in the output
if [ `git branch --list --no-color --no-column --remote | grep -w "$BRANCH" | wc | awk {'print $1'}` -eq 0 ]
 then
    if [ `git tag --list | grep -w "$BRANCH" | wc | awk {'print $1'}` -eq 0 ]
     then
        echo "The specified branch or tag '$BRANCH' does not exist on the remote"
        echo.
        echo "The following branches are available:"
        git branch --list --no-color --no-column --remote | sed 's/origin\///'

        echo "The following tags are available:"
        git tag --list | sed 's/^/  /'

        cleanup
        exit 2
    fi
fi

## Reaching this means the branch exists.

#echo "Checking out..."
CHECKOUT_FAILED=0
if [ `git branch --list --no-color --no-column --remote | grep -w "$BRANCH" | wc | awk {'print $1'}` -eq 1 ]
 then
    # We are checking out a branch
    # Note that there is "-eq 1" now!
    git checkout --force --quiet -B build origin/"$BRANCH"

    if [ $? -ne 0 ]
     then
       CHECKOUT_FAILED=1
    fi
else
    if [ `git tag --list | grep -w "$BRANCH" | wc | awk {'print $1'}` -eq 1 ]
     then
       # We try to check out a tag
       # Yet again, "-eq 1"!

       git checkout --force --quiet -B build "$BRANCH"

       if [ $? -ne 0 ]
        then
          CHECKOUT_FAILED=1
       fi
    else
        # Not a branch, not even a tag.
        # (We shouldn't have arrived here, but even if we do so, we need to fail.)
        CHECKOUT_FAILED=1
    fi
fi

if [ $CHECKOUT_FAILED -ne 0 ]
 then
   echo "Checkout failed"
   cleanup
   exit 4
fi

#echo "Checked out remote branch $BRANCH"
git --no-pager log HEAD -1 --date=short --format="%C(yellow)%H%Creset %s%n%Cgreen(%cr%Creset by %C(cyan)%an <%ae>%Cgreen) %C(bold blue)<%ad>%Creset%n%B"

$MSBUILD $SOLUTION "//nologo" "//noautoresponse" "//nodeReuse:false" "//verbosity:quiet" "//property:WarningLevel=0" "//property:Configuration=Release"

if [ $? -ne 0 ]
 then
    echo "BUILD FAILED!"
    cleanup
    exit 3
fi

# Copy the built file to the script's location
DESCRIBE=`git describe`

cd "$SCRIPTDIRECTORY"
cp $BUILDFOLDER/$BUILTPATH/$BUILTNAME.exe ./"$BUILTNAME"_"$BRANCH"_$DESCRIBE.exe
echo "Built as ${BUILTNAME}_${BRANCH}_${DESCRIBE}.exe"

cleanup

# End.
#echo "Finished"
exit 0
