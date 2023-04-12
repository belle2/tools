# Tools Testing

This directory contains some scripts to test the functionality and consistency
of the tools on all supported platforms. The tests are intended to be run in
docker on machines with CernVM-FS installed and available.

To do this locally for a single platform one can just run directly in the `tools`
directory

    docker run --volume $(pwd):/data --volume /cvmfs:/cvmfs:shared --workdir /data --rm ubuntu:20.04 tests/run.sh

which will start a Ubuntu 20.04 container, mount the `tools` directory in `/data` and
share `/cvmfs`, run all tests and remove the container when after it stops. The
platform can be replaced by any of the supported platforms (see the documentation for
the full list).

To debug problems one can directly start a shell in the container instead of
running the tests which is very similar to the command above:

    docker run -it --volume $(pwd):/data --volume /cvmfs:/cvmfs:shared --workdir /data --rm ubuntu:20.04 bash

These tests are automatically run on the CI for all the supported distributions and for
each merge request to this repository to make sure everything works as intended.