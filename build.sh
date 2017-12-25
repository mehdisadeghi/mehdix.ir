#! /bin/bash
# The purpose of this shell script is mainly building the static comments.

# Exit on any error
set -e

echo "Install python deps for building comments."
pip install requests pyyaml

echo "Build static comments if there are any."
python rebuild_comments.py

echo "Set git credentials."
git config --global user.email "netlify@netlify.com"
git config --global user.name "Netlify"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials


# Disable exiting on errors automatically
set +e

git add ./_data/comments
git commit --message "Netlify - Update static comments." > /dev/null

if [ $? -eq 0 ]; then
	echo "Pushing new comments."
	git push origin HEAD:master
fi

echo "Building the website."
jekyll build

