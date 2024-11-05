import os

# Directory structure
os.makedirs("my_mock_project/src/my_mock_package", exist_ok=True)

# Write pyproject.toml
pyproject_content = """
[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my_mock_package"
version = "0.1.0"
description = "A mock package for testing purposes"
authors = [{name = "Your Name", email = "your.email@example.com"}]
dependencies = []

[tool.setuptools.packages.find]
where = ["src"]
"""

with open("my_mock_project/pyproject.toml", "w") as f:
    f.write(pyproject_content)

# Write setup.py
setup_content = """
from setuptools import setup

setup()
"""

with open("my_mock_project/setup.py", "w") as f:
    f.write(setup_content)

# Write __init__.py
init_content = """from .module import add, subtract"""

with open("my_mock_project/src/my_mock_package/__init__.py", "w") as f:
    f.write(init_content)

# Write module.py
module_content = """
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b
"""

with open("my_mock_project/src/my_mock_package/module.py", "w") as f:
    f.write(module_content)
