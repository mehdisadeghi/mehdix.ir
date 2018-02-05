#! /bin/bash
# The purpose of this shell script is mainly building the static comments.

# Exit on any error
set -e

echo "Install python deps for building comments."
pip install requests pyyaml cryptography

echo "Build static comments if there are any."
python rebuild_comments.py

echo "Set git credentials."
git config --global user.email "msk1361@gmail.com"
git config --global user.name "Mehdi Sadeghi"
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials


# Disable exiting on errors automatically
set +e

git add ./_source/_data/comments
git commit --message "Netlify - Update static comments." > /dev/null

if [ $? -eq 0 ]; then
  git remote -v
  git status
	echo "Pushing new comments."
	git push origin HEAD:master
else
  echo "Something went wrong while committing"
  git status
fi

echo "Building the website."
jekyll build

