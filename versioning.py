
"""Management of software versions and global tags via versioning git repository
"""

import sys
import os
import subprocess


def get_remote_versioning(repository):
    """Get versioning.py from central git repository"""

    if os.environ.get('BELLE2_NO_TOOLS_CHECK', False):
        return None

    devnull = open('/dev/null', 'w')
    command = ['git', 'archive', '--remote=' + repository, 'HEAD', 'versioning.py']
    git = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=devnull)
    tar = subprocess.Popen(['tar', '-xO', 'versioning.py'], stdin=git.stdout, stdout=subprocess.PIPE, stderr=devnull)
    git.stdout.close()
    versioning = tar.communicate()[0]
    devnull.close()
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
versioning = get_local_versioning('/cvmfs/belle.cern.ch')
if versioning is None:
    versioning = get_remote_versioning(os.environ['BELLE2_VERSIONING_REPOSITORY'])
    if versioning is None:
        versioning = get_local_versioning(os.environ['VO_BELLE2_SW_DIR'])

# if found, execute versioning.py, else define functions returning None
if versioning is not None:
    exec(versioning)
else:
    sys.stderr.write(
        'Warning: could not get versioning information. Check that you have ssh access to versioning repository.\n'
        ' - about ssh access: https://software.belle2.org/development/sphinx/online_book/prerequisites/git.html#belle-ii-specifics\n'
        ' - versioning repository: https://gitlab.desy.de/belle2/software/versioning')

    def supported_release(release=None):
        return None

    def recommended_global_tags_v2(release=None, base_tags=None, user_tags=None, metadata=None):
        return None

    def recommended_b2bii_analysis_global_tag():
        return None

    def upload_global_tag(task=None):
        return None

    def jira_global_tag_v2(task=None):
        return None

    def create_jupyter_kernels(target_dir=None, top_dir=None):
        return None
