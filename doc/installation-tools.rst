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

   .. warning:: If you set this on your machine please check regularely that
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


Provided Scripts
----------------

The Belle II Software Tools provide a number of scripts common to all software
versions to setup and use the Belle II Software.

For users
+++++++++

.. describe:: b2analysis-create

  ::

      Usage: b2analysis-create directory release

  This command creates a local directory with the given name for the development
  of analysis code.  It also prepares the build system and adds the analysis
  directory to git.

  The second argument specifies the central release on which the analysis should
  be based.

.. describe:: b2analysis-get

  ::

      Usage: b2analysis-get directory [username]

  This command checks out the analysis code from the given repository name in
  git.  It also prepares the build system.

  The optional second argument can be used to specify a user name e.g. to check 
  out the analysis code created by somebody else.

.. describe:: b2analysis-update

  ::

      Usage: b2analysis-update [release]

  This command changes the central release version for the currently set up
  analysis. If no central release version is given as argument the recommended
  release version is taken.

.. describe:: b2setup

   ::

      Usage: b2setup release

   This command sets up the environment for the given central release
   of the Belle II software.

   .. hint:: The b2setup command is also used to set up local relases for developers.

.. describe:: b2setup-externals

   ::

     Usage: b2setup-externals [externals_version]

   This command sets up the Belle II externals to be used without any specific release
   of the Belle II software. It's useful if you just want to enable the software
   included in the Belle II externals like an updated ROOT or git version. Without an
   argument it will setup the latest version it can find, otherwise it will setup
   the specified version

.. describe:: b2help-releases

   ::

     Usage: b2help-releases [release_to_check]

   This command just prints the current recommended release of the Belle II software.
   If you provide release_to_check, it will check if you should be using a more recent version.

.. describe:: b2install-release

  ::

      Usage: b2install-release [version [system]]

  This command installs the given release or build version of basf2 in the
  directory :file:`{$VO_BELLE2_TOPDIR}/releases`. If the operating system is
  specified it tries to install the corresponding precompiled binary version,
  otherwise it will try to automatically determine the correct operating
  system. If no precompiled binary version is available for the given or determined
  operating system it attempts to compile from source.

  If no version is given it lists the available versions.

.. describe:: b2install-externals

  ::

      Usage: b2install-externals [version [system]]

  This command installs the given version of the externals in the directory given
  by the environment variable :envvar:`BELLE2_EXTERNALS_TOPDIR`. If the operating
  system is specified it tries to install the corresponding precompiled binary
  version otherwise it will try to automatically determine the correct operating
  system. If no precompiled binary version is available for the given or determined
  operating system it attempts to compile the externals from source.

  If no version is given it lists the available externals versions.

.. describe:: b2install-data

  :: 
   
      Usage:: b2install-data datatype

  This command installs or updates the given type of basf2 data.
  Supported data types are 'validation' and 'examples'.

For developers
++++++++++++++

.. describe:: b2code-create

   ::

      Usage: b2code-create directory [release]

   This command creates a local directory with the given name
   as basis for a working copy of the Belle II software.
   It also prepares the build system.

   If the basis for the code development should be a particular release,
   the version can be given as second argument.
   If no second argument is given, the latest version of the code
   (head of git main) is taken.

.. describe:: b2setup

   ::

      Usage: b2setup [release]

   Execute the b2setup command in a local release directory to set it up. If a centrally
   installed release with the same version as the local one exists, it is set
   up, too. If a release version is given as argument this is used as version
   for the central release instead of the one matching the local release.


.. describe:: b2code-style-check

  The b2code-style-check tool checks the layout of C++ and python code and reports
  changes that the b2code-style-fix tool would apply.

  By default it checks all C++ and python files in the current directory and
  its subfolders recursively. Individual files can be checked explicitly by
  giving them as argument.

  .. note:: No commits can be pushed to the server if b2code-style-check or b2code-style-fix
     report any problems.


.. describe:: b2code-style-fix

  ::

    Usage: b2code-style-fix [-n|-p [-d command]] [files]

  The b2code-style-fix tool formats the layout of C++ and python code.  It helps
  developers to achieve a common style of all Belle II software.

  By default it checks all C++ and python files in the current directory and
  its subfolders recursively.  Individual files can be checked explicitly by
  giving them as argument.

  -n
     If this option is given b2code-style-fix only prints the changes which would be
     applied but the files are not modified. The return code indicates the
     number of files that would be changed.
  -p
     This option is equivalent to ``-n`` except that it will print the
     pep8 output instead of the code changes.
  -d command
     This option can be used to specify the diff command that is called to
     report changes. Has to be given after the ``-n`` or ``-p``
     option.

  .. note:: No commits can be pushed to the server if b2code-style-check or b2code-style-fix
     report any problems.


.. describe:: b2code-clean

  This command deletes all built includes, object files, libraries, modules,
  and executables of your current local release.  The prompt for confirmation
  can be disabled with the -f option.

  -f
     Don't ask for confirmation


.. describe:: b2code-package-list

  ::

      Usage: b2code-package-list [-l] [-s]

  This command lists the available packages.
  It has to be called in the local release directory.

  -l
    Also print the responsible librarians.
  -s
    Exclude locally installed packages


.. describe:: b2code-package-add

  ::

      Usage: b2code-package-add package

  This command adds the source code of the given package from the code
  repository to the local release directory. It has to be called in the local
  release directory with the name of one package.


.. describe:: b2code-package-tag

   ::

      Usage: b2code-package-tag ["major"/"minor"/"patch"(=default)/tag]

   - This command tags the current version of the source code of a package
     and pushes the tag to the central repository.  It has to be called in the
     package directory of the local release.  There should be no locally
     modified files.
   - If no argument is given, the tag name is chosen automatically by
     increasing the patch level number, e.g. from ``v01-01-01`` to ``v01-01-02``.
   - If "minor" is given as argument, the minor version number is increased,
     e.g. from ``v01-01-01`` to ``v01-02-01``.
   - If "major" is given as argument, the major version number is increased,
     e.g. from ``v01-01-01`` to ``v02-01-01``.
   - Alternatively the name of the tag can be given explicitly as argument.


.. describe:: b2install-prepare

   ::

      Usage: b2install-prepare [--non-interactive] [--optionals]

   If executed without arguments it will check if all necessary packages are
   installed and if not it will ask the user if it should do it.

   If --non-interactive is given it will not ask but just install the necessary
   packages but not the optional ones. If --optionals is given as well it will
   install everything without asking.

.. _access to the code repository: https://confluence.desy.de/x/2o4iAg
.. _Git/Stash Introduction: https://confluence.desy.de/x/2o4iAg
