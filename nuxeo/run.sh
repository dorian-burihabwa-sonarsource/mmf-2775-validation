#! /usr/bin/env bash


main() {
    # Main branch no cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh false
    # Main branch with cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh true
    # New branch no cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh false empty-branch-no-cache
    # New branch with cache
    docker run -it --rm --env-file=./secrets.env --volume="${PWD}"/reports:/reports:rw --add-host=host.docker.internal:host-gateway nuxeo ./analyze.sh true empty-branch-with-cache
}

main
