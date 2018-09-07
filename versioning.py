
"""Management of software versions and global tags via versioning git repository
"""

import sys, os, subprocess


def get_remote_versioning(repository):
    """Get versioning.py from central git repository"""

    if os.environ.get('BELLE2_NO_TOOLS_CHECK', False):
        return None

    command = ['git', 'archive', '--remote=' + repository, 'HEAD', 'versioning.py']
    git = subprocess.Popen(command, stdout=subprocess.PIPE)
    tar = subprocess.Popen(['tar', '-xO', 'versioning.py'], stdin=git.stdout, stdout=subprocess.PIPE)
    git.stdout.close() 
    versioning = tar.communicate()[0]
    if tar.returncode == 0:
        return versioning
    else:
        return None


def get_local_versioning(directory):
    """Get versioning.py from local repository clone"""

    filename = os.path.join(directory, 'versioning', 'versioning.py')
    if os.path.isfile(filename):
        return open(filename).read()
    else:
        return None


# try different sources of versioning.py
versioning = get_remote_versioning(os.environ['BELLE2_GIT_SERVER'] + '/b2/versioning.git')
if versioning is None:
    for directory in ['/cvmfs/belle.cern.ch', os.environ['VO_BELLE2_SW_DIR']]:
        versioning = get_local_versioning(directory)
        if versioning is not None:
            break

# if found, execute versioning.py, else define functions returning None
if versioning is not None:
    exec(versioning)
else:
    sys.stderr.write('Warning: Could not get versioning information\n')
    def supported_release(release):
        return None
    def recommended_global_tags(release, mc=False, analysis=True, input_tags=[]):
        return None
    def upload_global_tag(task):
        return None

