``b2venv``: Using basf2 in a virtual environment
------------------------------------------------

Working on analysis or tools with basf2 in Python can create the situation in which additional Python libraries are required that are not provided by the externals.
Just using ``pip`` to install these libraries can lead to conflicts of local setups and version conflicts.
To work in a cleaned and controlled Python envrionment, virtual environments are the way to go.
``b2venv`` is a tool that helps you to create a virtual environment with the externals python and the basf2 release you want to use.

After having sourced ``b2setup``, the command ::

  $ b2venv release-XX-YY-ZZ

creates a virtual environment directory with the externals Python and the basf2 release-XX-YY-ZZ.
For a local basf2 release provide the path to the direcotry of the release ::

  $ b2venv /path/to/local/basf2/

The venv directory is created at the location ``b2venv`` is executed and is called ``venv`` by default.
The name of the directory can by adjusted by passing the name as an optional argument to ``b2venv`` ::

  $ b2venv -n MyVenv release-XX-YY-ZZ

The created virtual environment can be activated by sourcing the ``activate`` script in the ``bin`` directory of the created virtual environment ::
    
  $ source venv/bin/activate

When restarting the work in a fresh shell, the only command to be executed for the virtual environment is the same.
There is no need to run ``b2setup`` since this is done by the virtual environments activation script.

Within the virtual environment, the Python interpreter is the externals Python and the basf2 release is available.
Installing new Python libraries can be done with ``pip`` and the installed libraries are only available in the virtual environment.
Dependencies for libraries always first consider libraries that are provided by the externals and only installs missing or updated libraries into the virtual environment.
For example, installing ``b2luigi`` which is not part of the externals looks like this::

  $ pip install b2luigi

The recommended way to use ``b2venv`` is to create a virtual environment for each project you are working on.
In these projects, define all the additional libraries with the help of a ``requirements.txt`` or within the ``pyproject.toml`` file.
Sharing the project with others is then as easy as sharing the project directory and the ``requirements.txt`` file.

For more information on how to use ``b2venv``, please refer to the help message of the command::

  $ b2venv --help
