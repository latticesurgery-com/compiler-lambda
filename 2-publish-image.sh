#!/bin/bash


set -eo pipefail

echo "Updating submodules"
git submodule update --remote
echo "Moving the files from the handler and the lattice-surgery-compiler into a single folder"
rm -rf function
mkdir function
cp -r handler/* function
rm function/requirements.txt
cp -r lattice-surgery-compiler/* function
rm function/requirements.txt
rm -r function/web
rm -r function/webgui


if [ package -ot handler/requirements.txt ] || [ package -ot lattice-surgery-compiler/requirements.txt ]; then
    echo "Creating the layer. This might take some time"
    merge_requirements  lattice-surgery-compiler/requirements.txt handler/requirements.txt
    mv requirements-merged.txt function/requirements.txt
    rm -rf package
    cd function
    pip install --target ../package/python -r requirements.txt
else
    echo "Using existing layer"
fi

