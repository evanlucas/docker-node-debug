#!/bin/bash

# These are bundled here since the llvm apt mirror is offline
# and compiling these stuff from source in a docker image is a nightmare
# and takes forever

# Note: The ordering here is important
FILES=(
  "/packages/libllvm3.8_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/llvm-3.8-runtime_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/llvm-3.8_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/llvm-3.8-dev_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/liblldb-3.8_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/lldb-3.8_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/liblldb-3.8-dev_3.8~svn271230-1~exp1_amd64.deb"
  "/packages/lldb-3.8-dev_3.8~svn271230-1~exp1_all.deb"
  "/packages/python-lldb-3.8_3.8~svn271230-1~exp1_amd64.deb"
)

for file in ${FILES[*]}; do
  echo "$file"
  dpkg -i "$file"
done
