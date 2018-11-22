#!/usr/bin/env sh

set -e

if [ -z "$1" ]
then
    echo "Usage: $0 <tag/branch>"
    exit 1
fi
branch="$1"

#docker login

DIR=$(mktemp -d)
(
cd "$DIR"

git clone --depth 2 https://github.com/wuyazero/solidity.git -b "$branch"
cd solidity
commithash=$(git rev-parse --short=8 HEAD)
echo -n "$commithash" > commit_hash.txt
version=$($(dirname "$0")/get_version.sh)
if [ "$branch" = "release" -o "$branch" = v"$version" ]
then
    echo -n > prerelease.txt
else
    date -u +"nightly.%Y.%-m.%-d" > prerelease.txt
fi

rm -rf .git
docker build -t wuyazero/solc:build -f scripts/Dockerfile .
tmp_container=$(docker create wuyazero/solc:build sh)
if [ "$branch" = "develop" ]
then
    docker tag wuyazero/solc:build wuyazero/solc:nightly;
    docker tag wuyazero/solc:build wuyazero/solc:nightly-"$version"-"$commithash"
    docker push wuyazero/solc:nightly-"$version"-"$commithash";
    docker push wuyazero/solc:nightly;
elif [ "$branch" = v"$version" ]
then
    docker tag wuyazero/solc:build wuyazero/solc:stable;
    docker tag wuyazero/solc:build wuyazero/solc:"$version";
    docker push wuyazero/solc:stable;
    docker push wuyazero/solc:"$version";
else
    echo "Not publishing docker image from branch or tag $branch"
fi
)
rm -rf "$DIR"
