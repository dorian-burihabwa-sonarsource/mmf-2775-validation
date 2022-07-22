#! /usr/bin/env bash


main() {
    # Main branch no cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh
    # Main branch with cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh --cache-enabled
    # New branch no cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh --branch empty-branch-no-cache
    # New branch with cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh --branch empty-branch-with-cache --cache-enabled
}

main
