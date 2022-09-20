.. _belle2-tools:

Belle II Software Tools
=======================

The Belle II Software Tools is a collection of script to prepare your
environment for the execution of the Belle II software.

.. _belle2-tools-installation:

Installation
------------

In case you don't have a centrally provided Belle II Software you need to
install the tools locally.  Once you have configured your `access to the code repository`_ you can obtain the
software tools from the central Belle II code repository with the following
command::

    $ git clone ssh://git@stash.desy.de:7999/b2/tools.git

.. note:: We strongly recommend to setup connection over ssh but if you cannot
    do so you can also obtain the tools using ::

        $ git clone https://username@stash.desy.de/scm/b2/tools.git

    where you need to replace ``username`` with your DESY username.


After first time installation of the tools you need to run ::

    $ tools/b2install-prepare

to make sure that all software requirements for installing the Belle II Software
are met on your Machine.

.. note:: This will require root permissions


.. _belle2-tools-setup:

Setup
-----

Once the tools are installed you need to setup the Belle II environment by
sourcing ``tools/setup_belle2``::

    $ source tools/b2setup

.. warning:: This has to be done in every shell you plan on using the Belle II Software.

The behavior of the tools can be customized by setting the following
environment variables before sourcing ``tools/setup_belle2``:

.. envvar:: BELLE2_USER

   This variable allows you to set the username for any communication to the
   servers. By default it will be set to the local username.

   This variable is helpful if your local username is different to your DESY username.

.. envvar:: BELLE2_GIT_ACCESS

   This variable can be set to either ``http`` or ``ssh`` to specify the
   protocol to be used for git commands. Please have a look at `Git/Stash
   Introduction`_ for details on the meanings.

   ``ssh``
      This will use ssh connection to the DESY git server. This is the default and the
      preferred method but requires that you upload your ssh key to
      https://stash.desy.de and that TCP port 7999 is not blocked for outgoing
      connections by your local firewall.

   ``http``
      Use https to access the DESY git servers. This works in all cases but
      will require frequent entering of your desy password.

.. envvar:: BELLE2_NO_TOOLS_CHECK

   If set to a non-empty value sourcing the tools will not try to check if the
   tools version is up to date. This option is useful for laptops without
   permanent internet connection.

   .. warning:: If you set this on your machine please check regularly that
      the tools are up to date by running ``git pull`` in the tools directory.

.. envvar:: VO_BELLE2_SW_DIR

   This should point to the parent directory of the tools directory and
   indicates where the tools and installed releases are to be found.

.. envvar:: BELLE2_EXTERNALS_TOPDIR

   Where to look for the external software. This only needs to be set if you
   installed the software externals in a different directory. The default is
   :file:`${VO_BELLE2_SW_DIR}/externals`

.. envvar:: BELLE2_EXAMPLES_DATA_DIR

   Where to look for the official examples data. This is assumed to be
   :file:`${VO_BELLE2_SW_DIR}/examples` but can be set to any location where
   the data is installed using :program:`b2install-data`

.. envvar:: BELLE2_VALIDATION_DATA_DIR

   Where to look for the official examples data. This is assumed to be
   :file:`${VO_BELLE2_SW_DIR}/examples` but can be set to any location where
   the data is installed using :program:`b2install-data`

.. envvar:: BELLE2_BACKGROUND_DIR

   Where to look for background files.


In addition the tools will set or honor the following environment variables

.. envvar:: BELLE2_TOOLS
   
   Directory where the tools are located.

.. envvar:: BELLE2_LOCAL_DIR
   
   If a local release is setup this variable will be set to the directory
   containing this local release

.. envvar:: BELLE2_RELEASE_DIR

   If a central release is setup this variable will be set to the directory
   containing the central release

.. envvar:: BELLE2_EXTERNALS_DIR

   Directory containing the external software package necessary for the
   currently setup software version (or standalone if using
   :program:`b2setup-externals`

.. include:: provided-scripts.rst

.. _access to the code repository: https://confluence.desy.de/x/2o4iAg
.. _Git/Stash Introduction: https://confluence.desy.de/x/2o4iAg
