#! /bin/bash

# A bash shell script that replaces 'm4'
# such that what libtoolize pipes into
# $M4 is corrected NOT to ignore m4_include's.
#
# Written by Carlo Wood, 2017.

# Redirect stdin to fd 3.
exec 3<&0 0<&-

cat - <&3 | /bin/sed -s 's/m4_undefine(\[m4_s\?include\])//' | /usr/bin/m4 "$@"

exit $?
