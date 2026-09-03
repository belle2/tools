#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Unit tests for setup_tools.py

These tests are executed by tests/00-setup_tools_tests.sh, which in turn is
run by tests/run.sh, but they can also be run on their own with

    b2anypython tests/setup_tools_tests.py

No release, externals or cvmfs installation is needed: fake externals are
created in a temporary directory. Only the standard library is used and the
tests run with any python version, from 2.7 to the most recent one.
"""

import contextlib
import os
import shutil
import sys
import tempfile
import unittest

# the tools have to work with any python version, so we don't rely on
# io.StringIO or contextlib.redirect_stdout, which are python 3 only
if sys.version_info[0] >= 3:
    from io import StringIO
else:
    from StringIO import StringIO

# make sure we test the setup_tools.py of this tools directory
BELLE2_TOOLS = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BELLE2_TOOLS)

import setup_tools  # noqa: E402


# minimal replacement of the externals.py which comes with an externals installation
FAKE_EXTERNALS = """
import os


def setup_externals(location):
    os.environ['TEST_SETUP_EXTERNALS'] = location


def unsetup_externals(location):
    os.environ['TEST_UNSETUP_EXTERNALS'] = location
"""


@contextlib.contextmanager
def captured_output():
    """context manager which collects everything printed on stdout and stderr"""

    saved_stdout, saved_stderr = sys.stdout, sys.stderr
    sys.stdout, sys.stderr = StringIO(), StringIO()
    try:
        yield sys.stdout, sys.stderr
    finally:
        sys.stdout, sys.stderr = saved_stdout, saved_stderr


class SetupToolsTestCase(unittest.TestCase):
    """Base class which takes care of the global state of setup_tools and of the environment"""

    def setUp(self):
        self.tmp_dir = tempfile.mkdtemp()
        self.saved_environ = dict(os.environ)
        self.saved_sys_path = list(sys.path)
        os.environ.clear()
        setup_tools.env_vars.clear()
        del setup_tools.source_scripts[:]

    def tearDown(self):
        os.environ.clear()
        os.environ.update(self.saved_environ)
        sys.path[:] = self.saved_sys_path
        # the fake externals modules must not leak into the next test
        sys.modules.pop('externals', None)
        setup_tools.env_vars.clear()
        del setup_tools.source_scripts[:]
        shutil.rmtree(self.tmp_dir, ignore_errors=True)

    def create_externals(self, directory):
        """create a directory containing a minimal externals.py and return it"""

        os.makedirs(directory)
        with open(os.path.join(directory, 'externals.py'), 'w') as externals_file:
            externals_file.write(FAKE_EXTERNALS)
        return directory

    def export(self, **kwargs):
        """call export_environment and return the list of printed lines"""

        with captured_output() as (stdout, stderr):
            setup_tools.export_environment(**kwargs)
        return stdout.getvalue().splitlines()

    def update(self, **kwargs):
        """call update_environment and return the list of printed lines

        Whatever is printed on stderr is available as self.stderr.
        """

        with captured_output() as (stdout, stderr):
            try:
                setup_tools.update_environment(**kwargs)
            finally:
                self.stderr = stderr.getvalue()
        return stdout.getvalue().splitlines()


class VersionTestCase(unittest.TestCase):
    """Tests of the conversion and comparison of externals versions"""

    def test_release_versions(self):
        self.assertEqual(setup_tools.externals_version_tuple('v01-10-00'), (1, 10, 0))
        self.assertEqual(setup_tools.externals_version_tuple('v02-04-00'), (2, 4, 0))
        self.assertEqual(setup_tools.externals_version_tuple('v10-00-12'), (10, 0, 12))

    def test_unusual_versions(self):
        # versions without the leading 'v' and with dots as separators
        self.assertEqual(setup_tools.externals_version_tuple('02-04-00'), (2, 4, 0))
        self.assertEqual(setup_tools.externals_version_tuple('02.04.00'), (2, 4, 0))
        # missing digits are zeros, so that the versions can be compared
        self.assertEqual(setup_tools.externals_version_tuple('v02'), (2, 0, 0))
        self.assertEqual(setup_tools.externals_version_tuple('v02-04'), (2, 4, 0))
        # a non numeric suffix is ignored, surrounding white space as well
        self.assertEqual(setup_tools.externals_version_tuple('v02-04-00-rc1'), (2, 4, 0))
        self.assertEqual(setup_tools.externals_version_tuple(' v02-04-00\n'), (2, 4, 0))

    def test_versions_without_number(self):
        """versions which cannot be ordered must give None instead of raising"""

        self.assertIsNone(setup_tools.externals_version_tuple('development'))
        self.assertIsNone(setup_tools.externals_version_tuple('head'))
        self.assertIsNone(setup_tools.externals_version_tuple(''))
        self.assertIsNone(setup_tools.externals_version_tuple(None))

    def test_needs_jupyter_config_dir(self):
        """the ROOT v6.24 bug affects the externals from v01-10-00 up to v02-04-00"""

        for version in ['v01-10-00', 'v01-10-02', 'v02-00-00', 'v02-03-99']:
            self.assertTrue(setup_tools.needs_jupyter_config_dir(version), version)
        for version in ['v01-00-00', 'v01-09-99', 'v02-04-00', 'v02-04-01', 'v03-00-00']:
            self.assertFalse(setup_tools.needs_jupyter_config_dir(version), version)

    def test_needs_jupyter_config_dir_without_number(self):
        """versions which cannot be ordered are not affected and must not raise

        This is the regression test for the crash of b2setup-externals with the
        development externals:
        TypeError: '<' not supported between instances of 'int' and 'str'
        """

        for version in ['development', 'head', '', None]:
            self.assertFalse(setup_tools.needs_jupyter_config_dir(version), version)


class VariableTestCase(SetupToolsTestCase):
    """Tests of the helper functions handling single environment variables"""

    def test_set_and_get_var(self):
        setup_tools.set_var('BELLE2_OPTION', 'opt')
        self.assertEqual(setup_tools.get_var('BELLE2_OPTION'), 'opt')
        self.assertEqual(os.environ['BELLE2_OPTION'], 'opt')

    def test_set_var_empty(self):
        """an empty value is removed from the environment but still exported as unset"""

        setup_tools.set_var('BELLE2_OPTION', 'opt')
        setup_tools.set_var('BELLE2_OPTION', '')
        self.assertEqual(setup_tools.get_var('BELLE2_OPTION'), '')
        self.assertNotIn('BELLE2_OPTION', os.environ)
        self.assertEqual(self.export(), ['unset BELLE2_OPTION'])

    def test_get_var_undefined(self):
        self.assertEqual(setup_tools.get_var('BELLE2_DOES_NOT_EXIST'), '')

    def test_copy_from_environment(self):
        os.environ['BELLE2_OPTION'] = 'opt'
        setup_tools.copy_from_environment('BELLE2_OPTION')
        self.assertEqual(setup_tools.get_var('BELLE2_OPTION'), 'opt')

    def test_copy_from_environment_default(self):
        setup_tools.copy_from_environment('BELLE2_OPTION', 'debug')
        self.assertEqual(setup_tools.get_var('BELLE2_OPTION'), 'debug')
        setup_tools.copy_from_environment('BELLE2_UNDEFINED')
        self.assertIsNone(setup_tools.get_var('BELLE2_UNDEFINED'))

    def test_copy_from_environment_path(self):
        """a variable containing colons is split into a list"""

        os.environ['PATH'] = '/usr/bin:/bin'
        setup_tools.copy_from_environment('PATH')
        self.assertEqual(setup_tools.get_var('PATH'), ['/usr/bin', '/bin'])

    def test_add_option(self):
        setup_tools.add_option('CXXFLAGS', '-g')
        self.assertEqual(setup_tools.get_var('CXXFLAGS'), '-g')
        setup_tools.add_option('CXXFLAGS', '-O2')
        self.assertEqual(setup_tools.get_var('CXXFLAGS'), '-g -O2')

    def test_add_option_from_environment(self):
        os.environ['CXXFLAGS'] = '-g'
        setup_tools.add_option('CXXFLAGS', '-O2')
        self.assertEqual(setup_tools.get_var('CXXFLAGS'), '-g -O2')

    def test_remove_option(self):
        os.environ['CXXFLAGS'] = '-g -O2'
        setup_tools.remove_option('CXXFLAGS', '-O2')
        self.assertEqual(setup_tools.get_var('CXXFLAGS'), '-g')
        setup_tools.remove_option('CXXFLAGS', '-g')
        self.assertEqual(setup_tools.get_var('CXXFLAGS'), '')

    def test_remove_option_undefined(self):
        """removing an option from an undefined variable must not define it"""

        setup_tools.remove_option('CXXFLAGS', '-O2')
        self.assertNotIn('CXXFLAGS', setup_tools.env_vars)


class PathTestCase(SetupToolsTestCase):
    """Tests of the helper functions handling path like environment variables"""

    def test_add_path_undefined(self):
        setup_tools.add_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/opt/bin'])

    def test_add_path_from_environment(self):
        os.environ['PATH'] = '/usr/bin:/bin'
        setup_tools.add_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/opt/bin', '/usr/bin', '/bin'])

    def test_add_path_single_entry(self):
        os.environ['PATH'] = '/usr/bin'
        setup_tools.add_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/opt/bin', '/usr/bin'])

    def test_add_path_twice(self):
        """an entry which is added again is moved to the front and not duplicated"""

        os.environ['PATH'] = '/usr/bin:/opt/bin:/bin'
        setup_tools.add_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/opt/bin', '/usr/bin', '/bin'])
        setup_tools.add_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/opt/bin', '/usr/bin', '/bin'])

    def test_remove_path(self):
        os.environ['PATH'] = '/opt/bin:/usr/bin:/opt/bin'
        setup_tools.remove_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/usr/bin'])

    def test_remove_path_missing_entry(self):
        os.environ['PATH'] = '/usr/bin:/bin'
        setup_tools.remove_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), ['/usr/bin', '/bin'])

    def test_remove_path_single_entry(self):
        os.environ['PATH'] = '/opt/bin'
        setup_tools.remove_path('PATH', '/opt/bin')
        self.assertEqual(setup_tools.get_var('PATH'), [])

    def test_remove_path_undefined(self):
        setup_tools.remove_path('PATH', '/opt/bin')
        self.assertIsNone(setup_tools.get_var('PATH'))


class ReleaseTestCase(SetupToolsTestCase):
    """Tests of the setup and unsetup of a release directory"""

    def setUp(self):
        super(ReleaseTestCase, self).setUp()
        os.environ['BELLE2_SUBDIR'] = 'Linux_x86_64/opt'
        self.location = os.path.join(self.tmp_dir, 'release-09-00-00')

    def test_setup_release(self):
        setup_tools.setup_release(self.location)
        self.assertEqual(setup_tools.get_var('PATH'),
                         [os.path.join(self.location, 'bin', 'Linux_x86_64/opt')])
        self.assertEqual(setup_tools.get_var(setup_tools.lib_path_name),
                         [os.path.join(self.location, 'lib', 'Linux_x86_64/opt')])
        self.assertEqual(setup_tools.get_var('PYTHONPATH'),
                         [os.path.join(self.location, 'lib', 'Linux_x86_64/opt')])
        # for root6 both the location and its include directory are needed,
        # each new entry is prepended so the include directory comes first
        self.assertEqual(setup_tools.get_var('ROOT_INCLUDE_PATH'),
                         [os.path.join(self.location, 'include'), self.location])

    def test_setup_release_externals_version(self):
        """the externals version of a release is taken from its .externals file"""

        os.makedirs(self.location)
        with open(os.path.join(self.location, '.externals'), 'w') as externals_file:
            externals_file.write('v02-02-00\n')
        setup_tools.setup_release(self.location)
        self.assertEqual(setup_tools.get_var('BELLE2_EXTERNALS_VERSION'), 'v02-02-00')

    def test_unsetup_release(self):
        """unsetup_release removes exactly what setup_release added"""

        os.environ['PATH'] = '/usr/bin'
        setup_tools.setup_release(self.location)
        setup_tools.unsetup_release(self.location)
        self.assertEqual(setup_tools.get_var('PATH'), ['/usr/bin'])
        self.assertEqual(setup_tools.get_var(setup_tools.lib_path_name), [])
        self.assertEqual(setup_tools.get_var('PYTHONPATH'), [])
        self.assertEqual(setup_tools.get_var('ROOT_INCLUDE_PATH'), [])


class ExportEnvironmentTestCase(SetupToolsTestCase):
    """Tests of the generation of the shell commands"""

    def test_export_sh(self):
        setup_tools.env_vars['BELLE2_OPTION'] = 'opt'
        setup_tools.env_vars['PATH'] = ['/opt/bin', '/usr/bin']
        setup_tools.env_vars['BELLE2_RELEASE'] = ''
        self.assertEqual(sorted(self.export()),
                         sorted(['export BELLE2_OPTION="opt"',
                                 'export PATH="/opt/bin:/usr/bin"',
                                 'unset BELLE2_RELEASE']))

    def test_export_csh(self):
        setup_tools.env_vars['BELLE2_OPTION'] = 'opt'
        setup_tools.env_vars['PATH'] = ['/opt/bin', '/usr/bin']
        setup_tools.env_vars['BELLE2_RELEASE'] = ''
        self.assertEqual(sorted(self.export(csh=True)),
                         sorted(['setenv BELLE2_OPTION "opt"',
                                 'setenv PATH "/opt/bin:/usr/bin"',
                                 'unsetenv BELLE2_RELEASE']))

    def test_export_source_scripts(self):
        setup_tools.source_scripts.append(('/opt/setup.sh', '/opt/setup.csh'))
        lines = self.export()
        self.assertIn('cd /opt', lines)
        self.assertIn('source ./setup.sh > /dev/null', lines)
        lines = self.export(csh=True)
        self.assertIn('cd /opt', lines)
        self.assertIn('source ./setup.csh > /dev/null', lines)

    def test_jupyter_config_dir(self):
        """the ROOT v6.24 bug is worked around for the affected externals versions"""

        os.environ['HOME'] = '/home/belle2'
        setup_tools.env_vars['BELLE2_EXTERNALS_VERSION'] = 'v02-02-00'
        self.assertIn('export JUPYTER_CONFIG_DIR="/home/belle2/.jupyter"', self.export())
        self.assertIn('setenv JUPYTER_CONFIG_DIR "/home/belle2/.jupyter"', self.export(csh=True))

    def test_jupyter_config_dir_not_needed(self):
        os.environ['HOME'] = '/home/belle2'
        for version in ['v02-04-00', 'development', '']:
            setup_tools.env_vars['BELLE2_EXTERNALS_VERSION'] = version
            self.assertFalse([line for line in self.export() if 'JUPYTER_CONFIG_DIR' in line], version)

    def test_jupyter_config_dir_conda(self):
        """the conda based externals are never affected by the ROOT v6.24 bug"""

        os.environ['HOME'] = '/home/belle2'
        setup_tools.env_vars['BELLE2_EXTERNALS_VERSION'] = 'v02-02-00'
        self.assertFalse([line for line in self.export(conda_externals=True)
                          if 'JUPYTER_CONFIG_DIR' in line])

    def test_jupyter_config_dir_without_home(self):
        setup_tools.env_vars['BELLE2_EXTERNALS_VERSION'] = 'v02-02-00'
        lines = self.export()
        self.assertTrue([line for line in lines if line.startswith('echo "Info: HOME')])
        self.assertFalse([line for line in lines if 'export JUPYTER_CONFIG_DIR' in line])

    def test_export_without_externals_version(self):
        """exporting must work even if no externals version is defined at all"""

        setup_tools.env_vars['BELLE2_OPTION'] = 'opt'
        self.assertEqual(self.export(), ['export BELLE2_OPTION="opt"'])


class UpdateEnvironmentTestCase(SetupToolsTestCase):
    """Tests of the setup of externals and releases"""

    def setUp(self):
        super(UpdateEnvironmentTestCase, self).setUp()
        self.top_dir = os.path.join(self.tmp_dir, 'externals')
        self.sw_dir = os.path.join(self.tmp_dir, 'sw_dir')
        os.environ['BELLE2_EXTERNALS_TOPDIR'] = self.top_dir
        os.environ['VO_BELLE2_SW_DIR'] = self.sw_dir
        os.environ['BELLE2_ARCH'] = 'Linux_x86_64'
        os.environ['BELLE2_SUBDIR'] = 'Linux_x86_64/opt'
        os.environ['HOME'] = '/home/belle2'

    def test_externals(self):
        externals_dir = self.create_externals(os.path.join(self.top_dir, 'v02-04-00'))
        lines = self.update(externals_version='v02-04-00')
        self.assertEqual(setup_tools.get_var('BELLE2_EXTERNALS_DIR'), externals_dir)
        self.assertEqual(os.environ.get('TEST_SETUP_EXTERNALS'), externals_dir)
        self.assertIn('export BELLE2_EXTERNALS_VERSION="v02-04-00"', lines)
        self.assertIn('export BELLE2_EXTERNALS_DIR="%s"' % externals_dir, lines)
        self.assertIn('unset BELLE2_EXTERNALS_USE_CONDA', lines)

    def test_externals_in_sw_dir(self):
        """if the externals are not in the top directory they are taken from cvmfs"""

        externals_dir = self.create_externals(os.path.join(self.sw_dir, 'externals', 'v02-04-00'))
        self.update(externals_version='v02-04-00')
        self.assertEqual(setup_tools.get_var('BELLE2_EXTERNALS_DIR'), externals_dir)

    def test_externals_development(self):
        """setting up the development externals must not fail

        This is the regression test for the crash of b2setup-externals:
        TypeError: '<' not supported between instances of 'int' and 'str'
        """

        externals_dir = self.create_externals(os.path.join(self.top_dir, 'development'))
        lines = self.update(externals_version='development')
        self.assertEqual(setup_tools.get_var('BELLE2_EXTERNALS_DIR'), externals_dir)
        self.assertIn('export BELLE2_EXTERNALS_VERSION="development"', lines)
        self.assertFalse([line for line in lines if 'JUPYTER_CONFIG_DIR' in line])

    def test_externals_jupyter_config_dir(self):
        self.create_externals(os.path.join(self.top_dir, 'v02-02-00'))
        lines = self.update(externals_version='v02-02-00')
        self.assertIn('export JUPYTER_CONFIG_DIR="/home/belle2/.jupyter"', lines)

    def test_externals_missing(self):
        with self.assertRaises(SystemExit) as context:
            self.update(externals_version='v02-04-00')
        self.assertEqual(context.exception.code, 1)
        self.assertIn('The externals version v02-04-00 does not exist.', self.stderr)

    def test_externals_no_version(self):
        os.environ['BELLE2_EXTERNALS_VERSION'] = ''
        with self.assertRaises(SystemExit) as context:
            self.update()
        self.assertEqual(context.exception.code, 1)
        self.assertIn('No externals version is defined.', self.stderr)

    def test_externals_version_from_environment(self):
        """without arguments the externals version is taken from the environment"""

        externals_dir = self.create_externals(os.path.join(self.top_dir, 'v02-04-00'))
        os.environ['BELLE2_EXTERNALS_VERSION'] = 'v02-04-00'
        self.update()
        self.assertEqual(setup_tools.get_var('BELLE2_EXTERNALS_DIR'), externals_dir)

    def test_conda_externals(self):
        conda_dir = self.create_externals(os.path.join(self.tmp_dir, 'conda_env'))
        # the externals.py of the conda externals is in the top directory
        self.create_externals(self.top_dir)
        os.environ['CONDA_PREFIX'] = conda_dir
        os.environ['BELLE2_EXTERNALS_VERSION'] = 'v02-02-00'
        lines = self.update(conda_externals=True)
        self.assertEqual(setup_tools.get_var('BELLE2_EXTERNALS_DIR'), conda_dir)
        self.assertIn('export BELLE2_EXTERNALS_USE_CONDA="1"', lines)
        # the conda externals don't suffer from the ROOT v6.24 bug
        self.assertFalse([line for line in lines if 'JUPYTER_CONFIG_DIR' in line])

    def test_conda_externals_without_conda(self):
        os.environ['BELLE2_EXTERNALS_VERSION'] = 'v02-02-00'
        with self.assertRaises(SystemExit) as context:
            self.update(conda_externals=True)
        self.assertEqual(context.exception.code, 1)
        self.assertIn('no conda/mamba environment is active', self.stderr)

    def test_release(self):
        self.create_externals(os.path.join(self.top_dir, 'v02-02-00'))
        release_dir = os.path.join(self.sw_dir, 'releases', 'release-09-00-00')
        os.makedirs(release_dir)
        with open(os.path.join(release_dir, '.externals'), 'w') as externals_file:
            externals_file.write('v02-02-00\n')
        lines = self.update(release='release-09-00-00')
        self.assertIn('export BELLE2_RELEASE="release-09-00-00"', lines)
        self.assertIn('export BELLE2_RELEASE_DIR="%s"' % release_dir, lines)
        # the externals version of the release is used
        self.assertIn('export BELLE2_EXTERNALS_VERSION="v02-02-00"', lines)
        self.assertIn('export PATH="%s"' % os.path.join(release_dir, 'bin', 'Linux_x86_64/opt'), lines)

    def test_local_directory(self):
        self.create_externals(os.path.join(self.top_dir, 'v02-04-00'))
        local_dir = os.path.join(self.tmp_dir, 'my_release')
        os.makedirs(local_dir)
        with open(os.path.join(local_dir, '.externals'), 'w') as externals_file:
            externals_file.write('v02-04-00\n')
        lines = self.update(local_dir=local_dir)
        self.assertIn('export BELLE2_LOCAL_DIR="%s"' % local_dir, lines)
        self.assertIn('unset BELLE2_RELEASE', lines)

    def test_options(self):
        self.create_externals(os.path.join(self.top_dir, 'v02-04-00'))
        lines = self.update(externals_version='v02-04-00', option='debug', externals_option='opt')
        self.assertIn('export BELLE2_OPTION="debug"', lines)
        self.assertIn('export BELLE2_SUBDIR="Linux_x86_64/debug"', lines)
        self.assertIn('export BELLE2_EXTERNALS_OPTION="opt"', lines)
        self.assertIn('export BELLE2_EXTERNALS_SUBDIR="Linux_x86_64/opt"', lines)

    def test_unsetup_old_release(self):
        """an already set up release is removed from the environment"""

        self.create_externals(os.path.join(self.top_dir, 'v02-04-00'))
        old_dir = os.path.join(self.tmp_dir, 'old_release')
        os.environ['BELLE2_RELEASE_DIR'] = old_dir
        os.environ['BELLE2_RELEASE'] = 'release-08-00-00'
        os.environ['PATH'] = ':'.join([os.path.join(old_dir, 'bin', 'Linux_x86_64/opt'), '/usr/bin'])
        lines = self.update(release='', externals_version='v02-04-00')
        self.assertIn('unset BELLE2_RELEASE_DIR', lines)
        self.assertIn('unset BELLE2_RELEASE', lines)
        self.assertIn('export PATH="/usr/bin"', lines)

    def test_unsetup_old_externals(self):
        old_dir = self.create_externals(os.path.join(self.top_dir, 'v02-02-00'))
        externals_dir = self.create_externals(os.path.join(self.top_dir, 'v02-04-00'))
        os.environ['BELLE2_EXTERNALS_DIR'] = old_dir
        self.update(externals_version='v02-04-00')
        self.assertEqual(os.environ.get('TEST_UNSETUP_EXTERNALS'), old_dir)
        self.assertEqual(os.environ.get('TEST_SETUP_EXTERNALS'), externals_dir)

    def test_broken_externals(self):
        """a failing setup of the externals is reported and raises"""

        os.makedirs(os.path.join(self.top_dir, 'v02-04-00'))
        with self.assertRaises(ImportError):
            self.update(externals_version='v02-04-00')
        self.assertIn('Setup of externals at', self.stderr)


class ArgumentParserTestCase(SetupToolsTestCase):
    """Tests of the argument parser used by the b2setup and b2code-option scripts"""

    def parse(self, parser, arguments):
        """parse the arguments and return the namespace and what was printed on stderr"""

        with captured_output() as (stdout, stderr):
            args = parser.parse_args(arguments)
        return args, stdout.getvalue(), stderr.getvalue()

    def test_error(self):
        """the error message contains the state of the environment variable and the extra message"""

        os.environ['BELLE2_OPTION'] = 'opt'
        parser = setup_tools.SetupToolsArgumentParser(prog='b2code-option',
                                                      state_env_var='BELLE2_OPTION',
                                                      error_message='Try b2code-option --help.\n',
                                                      add_help=False)
        parser.add_argument('option', choices=['opt', 'debug'])
        with captured_output() as (stdout, stderr):
            with self.assertRaises(SystemExit) as context:
                parser.parse_args(['invalid'])
        self.assertEqual(context.exception.code, 2)
        self.assertIn('The current option is opt.', stderr.getvalue())
        self.assertIn('Try b2code-option --help.', stderr.getvalue())

    def test_help_goes_to_stderr(self):
        """the help must not end up on stdout, which is evaluated by the shell wrapper"""

        parser = setup_tools.SetupToolsArgumentParser(prog='b2code-option', add_help=False)
        parser.add_argument('--help', '-h', '-?', nargs=0, action=setup_tools.NoExitHelpAction)
        args, stdout, stderr = self.parse(parser, ['--help'])
        # NoExitHelpAction prints the help without exiting and sets args.help
        self.assertTrue(args.help)
        self.assertEqual(stdout, '')
        self.assertIn('usage: b2code-option', stderr)


if __name__ == '__main__':
    unittest.main(verbosity=2)
