.. _local-install:

Local Installation
==================

If you run on one of the supported distributions

.. include:: supported-distributions.rst-fragment

the installation uses precompiled binaries and is rather quick.
Otherwise the code has to be compiled from source which takes
a lot of time.

.. hint:: To find which distribution you are running on you can use
  ``lsb_release -a``.

After you installing the :ref:`belle2-tools` you need only to download the
software and corresponding externals version.

Downloading the Software Release
--------------------------------

We can obtain a list of available releases by just calling ::

  $ b2install-release

This will give you a list of all release versions available for download. If
you don't know which version to use just take the one with the highest number
starting with ``release-``. You can then download this release by calling ::

  $ b2install-release <version> [<system>]

where ``<version>`` should be the version you want. The operating system is
automatically determined, but you can override this by giving the ``system``
argument which should be the short distribution name for the desired system 
from the list of supported distributions in the table above.  For example, to download
``release-01-00-00`` on an Ubuntu 16.04 machine you need to run ::

  $ b2install-release release-01-00-00 ubuntu1604

.. warning:: If you work on a system for which we do not provide precompiled binaries
  the b2install-release command will compile the release from source.
  This requires that the externals are already installed, see next section.

Downloading the Externals Software
----------------------------------

After downloading the software itself you will also need to download the
corresponding externals package which contains all external software required
by the Software. The easiest way to find out which externals version you need
is by trying to setup the software version you just downloaded. For example ::

  $ b2setup release-01-00-00

should print an error like

  The externals version v01-05-02 does not exist. You can use 'b2install-externals' to install them.

which tells us that we need externals version ``v01-05-02`` by calling ::

  $ b2install-externals v01-05-02 [<system>]

``system`` is again optional and can be the short distribution name for the desired system from the list of
supported distributions in the table above. For example, to download
externals ``v01-05-02`` on an Ubuntu 16.04 machine you need to run ::

  $ b2install-externals v01-05-02 ubuntu1604

Now everything should be installed and you can setup the software using ::

  $ b2setup release-01-00-00

(or any other version you installed).

.. warning:: If you work on a system for which we do not provide precompiled binaries
  the b2install-externals command will compile the externals from source.

