CSharp-Autobuild
================

This thing is a small shell script I put together to automatically build
C# projects after each and every commit made to the system.

It also provides a lightened and edited version which checks build success
**before** making a commit.

How to install?
---------------

 * Put the files `pre-commit` and `post-commit` into the `.git/hooks` folder
   of your project.

 * Then, make a folder called `builds` in the project's root (where `.git`
   is) and put `AutoBuild.sh` into it.

 * `TestBuild.sh` is to be put in the root of the project.

 * Edit the configuration values `SOLUTION`, `BUILTPATH` and `BUILTNAME`
   in the two Shell scripts. (You usually only have to set the solution
   and filenames, the format is most of the time sufficient.)
 
And that's just it, the hooks are installed. Next time you run a commit,
the solution will be checked, committed and then built.
