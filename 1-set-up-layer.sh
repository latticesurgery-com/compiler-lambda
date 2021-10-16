#!/bin/bash


set -eo pipefail

echo "Updating submodules"
git submodule update --remote

echo "Moving the files from the handler and the lattice-surgery-compiler into a single folder"

mv function/env .tmp.function.env
rm -r function/*
mv .tmp.function.env function/env

cp -r handler/* function
rm function/requirements.txt

cp -r lattice-surgery-compiler/* function
rm function/requirements.txt
rm -r function/web
rm -r function/webgui


echo "Creating the layer. This might take some time"
merge_requirements  lattice-surgery-compiler/requirements.txt handler/requirements.txt
mv requirements-merged.txt function/requirements.txt
cd function
    echo "Pip installing"
    pip install --target env -r requirements.txt
    echo "Patching Qiskit"
    patch -d env -uN -i ../../qiskit-disable-default-aer-patch.diff -p 0
cd ..


