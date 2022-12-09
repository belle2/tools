.. highlight:: shell

Installation and Setup
======================

The Belle II Software is meant to work on any recent 64 bit Linux system but it is only
tested and provided in binary form for a few select distributions

.. include:: supported-distributions.rst-fragment

If you run on one of these distributions the most convenient way to obtain the
Belle II Software is to use it via CVMFS_, which is readily available on KEKCC and
many HEP specific software resources.  It can also easily be installed on your
local machine following the `CVMFS Client Quick Start`_ guide.

.. note:: In the following it is assumed that you have configured your `access to the code repository`_

If you have CVMFS available, please continue with

.. toctree::
   :maxdepth: 1

   cvmfs_setup

If you want to install the Belle II Software without CVMFS please have a look at
the following documents:

.. toctree::
   :maxdepth: 1

   installation-tools
   installation-local

Alternatively you can use a docker container to get the Belle II software
(instructions `here <https://confluence.desy.de/display/BI/How+to+run+basf2+on+a+laptop>`_),
for example on Mac or Windows machines.

.. _CVMFS: https://cernvm.cern.ch/portal/filesystem
.. _CVMFS Client Quick Start: https://cernvm.cern.ch/portal/filesystem/quickstart
.. _access to the code repository: https://confluence.desy.de/x/2o4iAg
