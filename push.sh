#!/bin/sh

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

echo PWD: `pwd`
echo Git branch: `git branch`
echo Git adding: $COMMENT_DIR
git checkout master
git add $COMMENT_DIR
git commit --message "Travis static comment build: $TRAVIS_BUILD_NUMBER"

git remote add origin https://${GH_TOKEN}@github.com/$GH_USERNAME/$GH_REPO.git
git push --quiet --set-upstream origin master
