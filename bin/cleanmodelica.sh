#!/bin/bash
# deletes temporary files and directories, if empty
# mwetter@lbl.gov                        2007-06-18
###################################################

# run to print output
find ./ \( -name 'buildlog.txt' -or -name 'dsfinal.txt' -or -name 'dsin.txt' -or -name 'dslog.txt' -or -name 'dsmodel*' -or -name 'dymosim' -or -name 'dymosim.exe' -or -name '*.mat' -or -name '*.bak-mo' -or -name 'request.' -or -name 'status' -or -name 'failure' \)

find ./ \( -name 'buildlog.txt' -or -name 'dsfinal.txt' -or -name 'dsin.txt' -or -name 'dslog.txt' -or -name 'dsmodel*' -or -name 'dymosim' -or -name 'dymosim.exe' -or -name '*.mat' -or -name '*.bak-mo' -or -name 'request.' -or -name 'status' -or -name 'failure' \) -delete
