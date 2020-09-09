#!bin/bash
set $(date)
fname="backup_$1$2$3.tar.xz"
tar cfj ../$fname ../../test # target to destination