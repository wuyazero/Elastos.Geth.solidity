#!/usr/bin/env sh

set -e

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD";
version=$($(dirname "$0")/get_version.sh)
if [ "$TRAVIS_BRANCH" = "develop" ]
then
    docker tag wuyazero/solc:build wuyazero/solc:nightly;
    docker tag wuyazero/solc:build wuyazero/solc:nightly-"$version"-"$TRAVIS_COMMIT"
    docker push wuyazero/solc:nightly-"$version"-"$TRAVIS_COMMIT";
    docker push wuyazero/solc:nightly;
elif [ "$TRAVIS_TAG" = v"$version" ]
then
    docker tag wuyazero/solc:build wuyazero/solc:stable;
    docker tag wuyazero/solc:build wuyazero/solc:"$version";
    docker push wuyazero/solc:stable;
    docker push wuyazero/solc:"$version";
else
    echo "Not publishing docker image from branch $TRAVIS_BRANCH or tag $TRAVIS_TAG"
fi
