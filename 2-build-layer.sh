#!/bin/bash

# Copy only the desired files over from the compiler /TODO
# Clone repo
#cp lattice-surgery-compiler/*.py function
#cp lattice-surgery-compiler/requirements.txt function

set -eo pipefail
rm -rf package
cd function
pip install --target ../package/python -r requirements.txt
