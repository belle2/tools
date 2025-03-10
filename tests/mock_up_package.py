import os

# Directory structure
mock_up_path = os.getenv('BELLE2_MOCK_UP_PROJECT', 'my_mock_project')
mock_up_project = os.getenv('BELLE2_MOCK_UP_PACKAGE', 'my_mock_package')
os.makedirs(f"{mock_up_path}/src/{mock_up_project}", exist_ok=True)

# Write pyproject.toml
pyproject_content = f"""
[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "{mock_up_project}"
version = "0.1.0"
description = "A mock package for testing purposes"
authors = [{{name = "Your Name", email = "your.email@example.com"}}]
dependencies = []

[tool.setuptools.packages.find]
where = ["src"]
"""

with open(f"{mock_up_path}/pyproject.toml", "w") as f:
    f.write(pyproject_content)

# Write setup.py
setup_content = """
from setuptools import setup

setup()
"""

with open(f"{mock_up_path}/setup.py", "w") as f:
    f.write(setup_content)

# Write __init__.py
init_content = """from .module import add, subtract"""

with open(f"{mock_up_path}/src/{mock_up_project}/__init__.py", "w") as f:
    f.write(init_content)

# Write module.py
module_content = """
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b
"""

with open(f"{mock_up_path}/src/{mock_up_project}/module.py", "w") as f:
    f.write(module_content)
