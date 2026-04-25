#!/bin/bash
FOLDERS=$(find . -name init.sh -type f -print | rev | cut -d/ -f2- | rev)
for i in $FOLDERS;
do
   OLD_DIR=$(pwd)
   cd $i
   echo "running at $i"
   ./init.sh
   cd $OLD_DIR
   echo
done
