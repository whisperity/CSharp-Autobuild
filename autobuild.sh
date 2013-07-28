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
# - Create an empty .git folder by using `git init .` in a folder
# - Add the remote repository to this repo as 'origin' by using
#   `git remote add origin url_to_repository`
#   (In case you wish to build from a local repository, you can use
#   file:///c/path/to/local/repository
#   as the remote's URL.)
# - Pack this folder (with the '.git' inside) into a TAR file
#   specified in the BuildArchive config variable by running
#   `tar cf folder clean_build.git.tar`
# - Put the resulting TAR file next to this script
# - Run the script by specifying which branch to build (e.g.: `AutoBuild.sh master`)
# - The built executable will be copied to the folder the script is in.

### Configuration ###
# BuildFolder is the name of the folder we are using to build
# It will contain the checked out source code and of course the built executable
BUILDFOLDER=build

# BuildArchive is the TAR file containing the "pre-build" data
# In our case, this is a clean, but set up .git folder.
BUILDARCHIVE=clean_build.git.tar

# The ABSOLUTE path to msbuild.exe used to build the solutions
MSBUILD="/c/Windows/Microsoft.NET/Framework/v4.0.30319/msbuild.exe"

# The solution file we will build (relative to BUILDFOLDER)
SOLUTION=Solution1.sln

# The name of the built executable (relative to BUILDFOLDER)
BUILTFILE=Solution1/bin/Release/Solution1.exe

### Entry point ###
if [ -d $BUILDFOLDER ]
 then
  echo "The build folder $BUILDFOLDER already exists"
  echo "Please remove it first!"

  # If you want autoremove, just uncomment.
  # !BE EXTREMELY CAREFUL WITH THIS!
  #rm -rf $BUILDFOLDER

  # Also comment this line if you want autoremoval
  exit 1
fi

if [ ! -f $BUILDARCHIVE ]
 then
  echo "The prebuild file $BUILDARCHIVE does not exist"
  exit 1
fi

# Of course, we specify what branch we want to build
BRANCH=$1

if [ "$BRANCH" == "" ]
 then
	echo "You did not specify the branch to build"
	exit 1
fi

# Unpack the prebuild archive
mkdir $BUILDFOLDER
tar xf $BUILDARCHIVE -C $BUILDFOLDER

cd $BUILDFOLDER
echo "Cloning the remote repository..."
git fetch --quiet --all

# Check whether the branch we specified exists
## We check the remote for the specified branch,
## then count the number of lines in the output
if [ `git branch --list --no-color --no-column --remote | grep "$BRANCH" | wc | awk {'print $1'}` -eq 0 ]
 then
	echo "The specified branch does not exist on the remote"
	echo.
	echo "The following branches would be available:"
	git branch --list --no-color --no-column --remote | sed 's/origin\///'
	
	exit 2
fi

## Reaching this means the branch exists.

echo "Checking out..."
git checkout --force --quiet -B build origin/"$BRANCH"

echo "Checked out remote branch $BRANCH"
git log HEAD -1 --date=short --format="%C(yellow)%H%Creset %s%n%Cgreen(%cr%Creset by %C(cyan)%an <%ae>%Cgreen) %C(bold blue)<%ad>%Creset%n%B"

$MSBUILD $SOLUTION "//nologo" "//noautoresponse" "//nodeReuse:false" "//verbosity:quiet" "//property:WarningLevel=0" "//property:Configuration=Release"

if [ $? -ne 0 ]
 then
	echo "The build failed. The error details should be above."
	
	exit 3
else
	echo "Successful build"
fi

# Copy the built file to the script's location
cd ..
cp -v $BUILDFOLDER/$BUILTFILE .
echo "Built file copied"

# Cleanup: remove the whole build folder
echo "Cleaning up..."
echo "(In case prompted, answer 'y' to file deletion prompts.)"
rm -r $BUILDFOLDER

# End.
echo "Finished"
exit 0