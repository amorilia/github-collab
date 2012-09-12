#!/bin/bash

# confirm, as this script could revert uncommitted changes

echo "All uncommitted changes will be lost. Proceed with sync? [y/n]"
read ans
[ "$ans" != "y" ] && exit

# check that develop has no local commits that aren't in remote
# the coder may have forgotten to create a feature branch?

chk=`git log origin/develop..develop`

if [ -n "$chk" ]
then
    echo "Local develop branch and remote origin/develop branch have diverged."
    echo "Creating feature branch and reset develop to origin/develop? [y/n]"
    read ans
    [ "$ans" != "y" ] && exit
    echo "Name of feature branch (without feature/ prefix)?"
    read ans
    [ -z "$ans" ] && exit
    git checkout develop -b "feature/$ans" || exit
    git checkout develop
    git reset --hard origin/develop
fi

# now sync

git remote update --prune
git checkout develop
for REMOTE in `git remote`
do
	git merge $REMOTE/develop
done

echo Now check the status of your repository with gitk.
echo If all looks ok, type:
echo
echo   git push origin develop
echo
echo If not, revert to the previous state with:
echo
echo   git checkout develop
echo   git reset --hard origin/develop
