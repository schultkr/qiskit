#!/bin/bash

# This code is part of Qiskit.
#
# (C) Copyright IBM 2018, 2019.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

# Script for pushing the translatable messages to poBranch.


# Non-travis variables used by this script.
TARGET_REPOSITORY="git@github.com:Qiskit/qiskit.org.git"
TARGET_DOC_DIR="documentation"
SOURCE_DOC_DIR="docs/_build/html"
SOURCE_DIR=`pwd`
SOURCE_LANG='en'

SOURCE_REPOSITORY="git@github.com:Qiskit/qiskit.git"
TARGET_BRANCH_PO="poBranch"
DOC_DIR_PO="docs/locale"

echo "show current dir: "
pwd

pushd docs

# Extract document's translatable messages into pot files
# https://sphinx-intl.readthedocs.io/en/master/quickstart.html
echo "Extract document's translatable messages into pot files and generate po   files"
tox -egettext -- -D language=$SOURCE_LANG


# Clone to the working repository for .po and pot files
popd
pwd
echo "git clone for working repo"
git clone --depth 1 $SOURCE_REPOSITORY temp --single-branch --branch $TARGET_BRANCH_PO
pushd temp
git branch
git config user.name "Qiskit Autodeploy"
git config user.email "qiskit@qiskit.org"

echo "git rm -rf for the translation po files"
git rm -rf --ignore-unmatch $DOC_DIR_PO/$SOURCE_LANG/LC_MESSAGES/*.po \
    $DOC_DIR_PO/$SOURCE_LANG/LC_MESSAGES/api \
    $DOC_DIR_PO/$SOURCE_LANG/LC_MESSAGES/apidoc \
    $DOC_DIR_PO/$SOURCE_LANG/LC_MESSAGES/apidoc_legacy \
    $DOC_DIR_PO/$SOURCE_LANG/LC_MESSAGES/theme \
    $DOC_DIR_PO/$SOURCE_LANG/LC_MESSAGES/_*

# Remove api/ and apidoc/ to avoid confusion while translating
rm -rf $SOURCE_DIR/$DOC_DIR_PO/en/LC_MESSAGES/api/ \
    $SOURCE_DIR/$DOC_DIR_PO/en/LC_MESSAGES/apidoc/ \
    $SOURCE_DIR/$DOC_DIR_PO/en/LC_MESSAGES/apidoc_legacy/ \
    $SOURCE_DIR/$DOC_DIR_PO/en/LC_MESSAGES/stubs/ \
    $SOURCE_DIR/$DOC_DIR_PO/en/LC_MESSAGES/theme/

# Copy the new rendered files and add them to the commit.
echo "copy directory"
cp -r $SOURCE_DIR/$DOC_DIR_PO/ docs/
cp $SOURCE_DIR/setup.py .
cp $SOURCE_DIR/requirements-dev.txt .

# git checkout translationDocs
echo "add to po files to target dir"
git add $DOC_DIR_PO
git add setup.py
git add requirements-dev.txt

# Commit and push the changes.
git commit -m "Automated documentation update to add .po files from meta-qiskit" -m "[skip travis]" -m "Commit: $TRAVIS_COMMIT" -m "Travis build: https://travis-ci.com/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
echo "git push"
git push --quiet origin $TARGET_BRANCH_PO
echo "********** End of pushing po to working repo! *************"
popd
