.. _cvmfs_setup:

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

.. warning:: The setup of tools and releases has to be done in every shell you plan on using the Belle II Software.

.. _choosing_a_release:

Choosing a release
..................

You can see available releases of ``basf2``::

  $ b2setup --help

after the tools have been set up.

Some releases are old, but left available for legacy reasons.
If you try to setup an old/unsupported release, you will get a message advising you to move to a newer (supported) release.
You can check if a given release is supported with::

  $ b2help-releases your_release_version

Releases come in three kinds:

1) A full release, name of the form ``release-AA-BB-CC``.
2) A light release, name of the form ``light-YYMM-CODENAME``.
3) A prerelease, name of the form ``prerelease-AA-00-00abc``.

Pre-releases are for testing and validation before a full release.

.. warning::
       Prereleases are not supported for use in analysis.
       They are not recommended for anything other than software validation.
       They can disappear without warning.


Full release
************

A full release (``release-AA-BB-CC``) is a complete version of ``basf2`` that has undergone extensive testing and valiation.
Real data production and Monte Carlo simulation campaigns are always based on a full release.
With a full release you are able to perform the full reconstruction chain, including analysis.

The numbering of releases follows `semantic versioning`_, ``AA`` is the major release number, ``BB`` the minor, and ``CC`` the patch.
A major version of the software may contain non-backward-compatible changes to the user interface.

.. tip::
        If you do not know what release you need to use, then the newest supported full release should be your default choice.
        The command ``b2help-releases`` with no arguments, shows this.

.. tip:: We support the most recent patch to the last two major releases.

.. _light_releases:

Light releases
**************

A light release (``light-YYMM-CODENAME``) is a release made from only the ``analysis``, ``b2ii``, ``framework``, ``geometry``, ``online_book``, ``mdst``, ``mva``, and ``skim`` packages.

They are suitable for doing high-level analysis tasks which do not require the generation or reconstruction of data.
If you are running over some MC or data that already exists (e.g. was produced by the data production group)
and want access to newer features, you should consider using a light release.

.. warning::
        By construction, a light release can only be used to process files in the **mdst** and **udst** format.
	Reading any other file format (e.g., cdst) will cause a crash.

.. warning::
        Unfortunately from light release to light release the syntax may change and you might have to update your analysis scripts.

.. tip:: We support the last two light releases.

For more technical information about light releases, see `BELLE2-NOTE-TE-2018-013 <https://docs.belle2.org/record/1114>`_.


Physics Analysis Setup
......................

If you want to develop your analysis you can setup your own *analysis project* with ::

  $ b2analysis-create analysis_name release_version

where you should replace the ``analysis_name`` with a meaningful name for your
analysis. This will be the directory name for your project as well as the name
of the git repository on the server. ``release_version`` should be replaced
with the release version your analysis will be based on. After this you can ::

  $ cd analysis_name
  $ b2setup

to setup your analysis project. You can add your own basf2 `Module <basf2.Module>` to this
analysis by running ::

  $ b2code-module ModuleName

where ``ModuleName`` is the name of the module you want to create. The command
will ask you a few questions that should be more or less self-explanatory. The
requested information includes your name, module parameters, input and output
objects, methods, and descriptions for doxygen comments. If unsure you can
usually just hit enter. The ``b2code-module`` command will create a skeleton header
and source file of your module and include them in the files known to git.

To :ref:`compile your code <using_scons>` simply type ::

  $ scons

in your analysis working directory,

An advantage of having the analysis code in git is that you can check it out at
any other location and continue your work there. The git repository takes care
of synchronizing the multiple local version of the code. To get the code of an
existing analysis with a certain name type ::

  $ b2analysis-get <analysis name>

Again, changes can be submitted to the git repository with ``git commit`` followed
by ``git push``. To get the changes made in a different local version and
committed to the central repository to your current local analysis working
directory, use the command  ::

  $ git pull --rebase

.. note:: After any update to your analysis code you must recompile it by
    running ``scons`` again.


Keeping your analysis up-to-date
********************************

Periodically you should update the release version of the software that your
analysis is based upon. You will want to keep on top of improvements and
bug fixes. At the very least, you should update before your current release
becomes unsupported. See :ref:`choosing_a_release` for detailed explanation.

You can update your analysis project to a newer release using ::

  $ b2analysis-update newer_release_version

after setting up your analysis (``b2setup`` from your analysis directory).
If no ``newer_release_version`` is specified the currently recommended one is
taken.

.. note:: After updating the release version you may have to adjust
    your analysis code to the new release.

    A newer major release, or newer light release may contain
    non-backward-compatible changes to the user interface.


Development Setup
.................

If you plan on developing code you should consider checking out the development
version locally instead of using a pre-compiled release::

  $ b2code-create development

This will obtain the latest version from git. Once this is done you can setup
this version using ::

  $ cd development
  $ b2setup

If you want to do the development from a certain version or branch just use
``git checkout`` to obtain it and run ``b2setup`` to make sure the correct
externals version is set up, e.g. ::

  $ git checkout release-XX-YY-ZZ
  $ b2setup

After creating a development setup or switching to a different release you have
to :ref:`compile it <using_scons>`.

.. note:: after any update to your analysis code you must recompile it by
    running ``scons`` again.

.. _using_scons:

Compiling your Code
...................

To compile the code we use the `SCons <https://scons.org>`_ build system.
Usually you can simply compile the code by running ::

  $ scons

.. warning:: You have to recompile your code every time you modify, add or
   remove a file. If in doubt just run ``scons`` to be safe.

You can tell the build system how many CPUs to use in parallel by using the
``-j`` parameter::

  $ scons -j 4

will compile the code with four jobs in parallel.


.. note:: By default, scons will use as many parallel jobs as there are CPUs
    available on the system. This is fine on a local system but might not be
    desirable on a shared system like KEKCC or DESY NAF. Please adjust the
    amount of jobs to not block the whole machine if there are others using it.

    To find out how many CPUs are available you can run ::

        $ nproc

To find out what other options you can use please run ::

    $ scons --help

Some of the parameters you can use are

--help         Show a list of all available options.
-j N           Allow N jobs at once.
-D             search of the directory tree for the ``SConstruct`` file. Use
               this to run scons from a sub directory of your code
-Q             be more quiet which will omit some status messages
--verbose      show full commands passed to the compiler
--color=color  change the color of the log messages. Possible values are: off, light, dark
--light        build a :ref:`light release <light_releases>`. Useful to speed
               up compilation if you are developing high level analysis tools.
--sphinx       also build the sphinx documentation in the ``build/html`` sub directory.
--check-extra-libraries     if given all libraries will be checked for
                            dependencies in the SConscript which are not
                            actually needed
--check-missing-libraries   if given all libraries will be checked for
                            missing direct dependencies after build

.. note:: if you change any of the arguments ``--light``, ``--extra-libpath``
    or ``--extra-ccflags`` scons will recompile most of the code. So best keep
    the arguments consistent to avoid lengthy recompiles.

You can also supply a package name to only build the given package. For example
if you know you only modified a file in the ``pxd`` package you can run ``scons
pxd`` to only compile the pxd package. This is faster but will ignore some
dependencies.

.. warning:: Always run a full ``scons`` before committing anything

.. _pr_best_practices:

Opening a merge request
.......................

To make your development part of the official software, you have to open a
merge request. Before you can do this, you have to create a branch prefixed
``bugfix/`` or ``feature/``. Ideally, you should have created a GitLab issue for
your development. Then, you can directly create a branch from there. If you
already have local changes, execute the following sequence of git commands:

1. git stash
2. git pull
3. git checkout <branchname>
4. git stash pop
5. git add
6. git commit
7. git push

Usually, it's best to open the merge request only after you think
that all the work has been completed and it is ready for review. However,
there might be situations where you would like to get input from others. In
that case, you can already open a merge request in an earlier stage and mark
it as draft. Before you'll be able to merge it, you must unset the tick mark
to indicate that it's ready.

Before the merge request can be merged, the librarians of all packages that
you touched must approve it. The Belle II Software bot automatically
determines the librarians and lists them in a comment of your merge request.
You can also trigger this determination by commenting ``Check``. However, the
librarians are not notified automatically. You can comment ``Tag`` in the merge
request which will send an email to the missing librarians and
will add them to the list of people who receive notifications for every
future action in the merge request.

The second requirement that must be fulfilled before the merge request can be
merged, is that the pipeline has to be successful. After you opened a merge
request, each time you push new commits to your branch, a new pipeline is
initiated.

If the pipeline is successful, all approvals are given, and all review threads
are resolved you can merge by commenting ``Merge``. If the last pipeline is
more than one week old, a new one will be triggered internally. This is
supposed to limit the risk that two merge requests are merged that interfere
with each other and in combination break the main branch.

Finally, here is a list of best practices to make the review as smooth as
possible:

* Split changes of different issues into different commits.
* Provide meaningful commit messages so that the reviewers know what was
  intended with those changes.
* It should go without saying that the commit message must not contain
  inappropriate or even offensive language.
* Make sure that your code compiles before pushing it.
* Run at least the unit-tests of the packages that you touched (see
  :ref:`framework/doc/tools/03-b2test:Testing Tools`)
* Once you have opened a merge request, try not to push commits individually.
  Instead, make commits locally and push them at the end of the day or when you
  have finished all of your work.

.. _semantic versioning: https://semver.org
.. _CI: https://en.wikipedia.org/wiki/Continuous_integration
