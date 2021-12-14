# Tools Testing

This directory contains some scripts to test the functionality and consistency
of the tools on all supported platforms. The tests are intended to be run in
docker on machines with cvmfs installed and available.

To do this for a single platform one can just run directly in the tools directory

    docker run --volume $(pwd):/data --volume /cvmfs:/cvmfs:shared --workdir /data --rm centos:8 tests/run.sh

which will start a CentOS 8 container, mount the tools directory in /data and
share `/cvmfs`, run all tests and remove the container when after it stops. The
platform can be replaced by any of the supported platforms:

* `centos:7` for CentOS 7, compatible with enterprise linux 7
* `centos:8` for CentOS 8, compatible with enterprise linux 8
* `ubuntu:18.04` and `ubuntu:20.04` for the different ubuntu versions.

To debug problems one can directly start a shell in the container instead of
running the tests which is very similar to the command above:

    docker run -it --volume $(pwd):/data --volume /cvmfs:/cvmfs:shared --workdir /data --rm centos:8 bash

These tests are run on the CI for all distributions above and for each pull
request to the tools repository to make sure everything works as intended
