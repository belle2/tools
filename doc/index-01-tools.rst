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

Alternatively, you can use Docker or Apptainer to run the Belle II software on macOS or Windows systems.
For more information, see the `Belle II Docker Images repository <https://github.com/belle2/docker-images>_`.

If you want to use the Belle II software in a virtual environment, please have a look at the
``b2venv`` documentation.

.. toctree::
   :maxdepth: 1

   b2venv

.. _CVMFS: https://cernvm.cern.ch/fs/
.. _CVMFS Client Quick Start: https://cvmfs.readthedocs.io/en/stable/cpt-quickstart.html
.. _access to the code repository: https://xwiki.desy.de/xwiki/bin/view/BI/Belle%20II%20Internal/Software/Software%20Basf2SoftwarePortal/GitGitLab%20Introduction/
