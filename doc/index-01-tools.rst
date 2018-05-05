.. highlight:: shell

Installation and Setup
======================

The Belle II Software is meant to work an any recent 64 bit Linux system but it is only
tested and provided in binary form for a few select distributions

.. include:: supported-distributions.rst-fragment

If you run on one of these distributions the most convenient way to obtain the
Belle II Software is to use it via CVMFS_ which is readily available on KEKCC and
many HEP specific software resources.  It can also easily be installed on your
local machine following the `CVMFS Client Quick Start`_ guide.

.. note:: In the following it is assumed that you have configured your `access to the code repository`_

If you want to install the Belle II Software without CVMFS please have a look at
the following documents, otherwise if you have CVMFS available please continue with the :ref:`cvmfs-setup`

.. toctree:: 
   :maxdepth: 1

   installation-tools
   installation-local

Alternatively you can use `Jan's docker container`_ to get the Belle II software, for example on Mac or Windows machines.


.. _cvmfs-setup:

Setup of the Belle II Software
------------------------------

The command ::

  $ source /cvmfs/belle.cern.ch/tools/b2setup release-XX-YY-ZZ

sets up the :ref:`belle2-tools` and the Belle II software version release-XX-YY-ZZ.

.. note:: If you use the software without CVMFS please replace /cvmfs/belle.cern.ch/tools by the path
  where you :ref:`installed the Belle II Software tools <belle2-tools-installation>`.

.. hint:: There are some :ref:`extra environment variables
   <belle2-tools-setup>` which can be set to customize the setup

After that all the :ref:`command-line-tools` will be setup correctly and ready to use.

When the tools are already set up one can set up a Belle II software version directly with ::

  $ b2setup release-XX-YY-ZZ

To only set up the tools without a release use ::

  $ source /cvmfs/belle.cern.ch/tools/b2setup

.. hint:: To get a list of the available releases run ``b2install-release`` after the tools have been set up.

.. warning:: The setup of tools and releases has to be done in every shell you plan on using the Belle II Software.


Physics Analysis Setup
......................

If you want to develop your analysis you can setup your own analysis project with ::

  $ b2analysis-create analysis_name release_version

where you should replace the ``analysis_name`` with a meaningful name for your
analysis. This will be the directory name for your project as well as the name
of the git repository on the server. ``release_version`` should be replaced
with the release version your analysis will be based on. After this you can ::

  $ cd analysis_name
  $ b2setup

to setup your analysis project. You can add your own basf2 `Module` to this
analysis by running ::

  $ b2code-module ModuleName

where ``ModuleName`` is the name of the module you want to create. The command
will ask you a few questions that should be more or less self-explanatory. The
requested information includes your name, module parameters, input and output
objects, methods, and descriptions for doxygen comments. If unsure you can
usually just hit enter. The ``b2code-module`` command will create a skeleton header
and source file of your module and include them in the files known to git.

To compile your code simply type ::

  $ scons

in your analysis working directory,

An advantage of having the analysis code in git is that you can check it out at
any other location and continue your work there. The git repository takes care
of synchronizing the multiple local version of the code. To get the code of an
existing analysis with a certain name type ::

  $ b2analysis-get <analysis name> 
  
Again, changes can be submitted to the git repository with git commit followed
by git push. To get the changes made in a different local version and
committed to the central repository to your current local analysis working
directory, use the command  ::

  $ git pull --rebase

Development Setup
.................

If you plan on developing code you should consider checking out the development
version locally instead of using a pre compiled release::

  $ b2code-create development

This will obtain the latest version from git. Once this is done you can setup
this version using ::

  $ cd development
  $ b2setup

And you can compile the code with  ::

  $ scons

.. _CVMFS: https://cernvm.cern.ch/portal/filesystem
.. _CVMFS Client Quick Start: https://cernvm.cern.ch/portal/filesystem/quickstart
.. _access to the code repository: https://confluence.desy.de/x/2o4iAg
.. _Jan's docker container: https://confluence.desy.de/display/BI/How+to+run+basf2+on+a+laptop
