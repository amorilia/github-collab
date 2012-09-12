#!/bin/bash

# confirm, as this script could revert uncommitted changes
# TODO check programmatically that all changes are actually committed
#      instead of asking user

echo "All uncommitted changes will be lost. Proceed with sync? [y/n]"
read ans
[ "$ans" != "y" ] && exit

# check that develop has no local commits that aren't in remote
# the coder may have forgotten to create a feature branch?

git fetch origin # make sure we have latest origin/develop
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
    git submodule update --recursive
fi

# now sync

git remote update --prune
git checkout develop
for REMOTE in `git remote`
do
    git merge $REMOTE/develop
    git submodule update --recursive
done

gitk &

echo "Merge looks ok? [y/n]"
read ans
if [ "$ans" != "y" ]
then
    echo Resetting develop to origin/develop.
    git checkout develop
    git reset --hard origin/develop
    git submodule update --recursive
    exit
fi

git push origin develop

# check and erase merged feature branches

# TODO
