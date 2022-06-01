#! /bin/bash

# A bash shell script that replaces 'sed'
# such that an input file called 'configure.ac'
# is first properly parsed with m4.
#
# Written by Carlo Wood, 2017.

# Redirect stdin to fd 3.
exec 3<&0 0<&-

# Build two bash arrays: args that holds all options and their arguments,
# and params, that will hold all non-options.
args=()
params=()
# If an option -e, --expression, -f or --file is present then
# no_script is set to 0 to indicate that the first non-option parameter
# is not a script.
no_script=1
# This is set to point to the 'configure.ac' input file in params, if any.
configure_ac_idx=-1
# This is set to point to the '-' input file in params, if any.
stdin_idx=-1

while [ $# -ge 1 ]; do
  case $1 in
    -e|--expression|-f|--file) args+=("$1" "$2"); shift; no_script=0 ;;
    -l|--line-length) args+=("$1" "$2"); shift ;;
    --) shift; params+=("$@"); break ;;
    -) stdin_idx=${#params[@]}; params+=(-) ;;
    --file=?*|--expression=?*) args+=("$1"); no_script=0 ;;
    -*) args+=("$1") ;;
    configure.ac) configure_ac_idx=${#params[@]}; params+=(-) ;;
    *) params+=("$1") ;;
  esac
  shift
done

#echo "Option arguments:"
#for opt in "${args[@]}"; do printf -- "'%s'\n" "${opt}"; done

#echo "Non-option arguments:"
#for param in "${params[@]}"; do printf -- "'%s'\n" "${param}"; done

# Since we replaced 'configure.ac' in params with a '-',
# remove the '-' when it was found as an input file.
if [ $stdin_idx -ge 0 -a $configure_ac_idx -ge 0 ]; then
  unset -v params[$stdin_idx]
  # This script doesn't handle the case where '-' and 'configure.ac'
  # are separated by yet another input file (because we catenate
  # both together to be read by sed from stdin).
  res=$(($stdin_idx - $configure_ac_idx))
  if [ ${res#-} -gt 1 ]; then
    echo "WARNING: SED is being used with three or more input files including 'configure.ac' AND '-'; reading stdin out of sequence!" >&2
  fi
fi

# A string that doesn't occur in input sent to sed by libtoolize,
# unless it does... in which case something (nasty) will happen.
magic="xyzzy"

# Start a sub-shell that prints out what we want sed to read
# from stdin, if anything, and pipe that into a filter that
# can be processed by m4 in a safe way (only doing m4_include's)
# the output of which is finally piped into the real sed.
(
  # First write stdin to the pipe when both 'configure.ac' and '-' where found and the latter occured first,
  # or when no input file was given.
  if [ $configure_ac_idx -ge 0 -a $stdin_idx -ge 0 -a $stdin_idx -lt $configure_ac_idx -o ${#params[@]} -eq $no_script ]; then
    cat - <&3
  fi
  # Write a properly processed configure.ac to the pipe when 'configure.ac' was found.
  if [ $configure_ac_idx -ge 0 ]; then
    cat configure.ac
  fi
  # Write stdin to the pipe last when '-' was found and 'configure.ac' wasn't or occured first.
  if [ $stdin_idx -gt $configure_ac_idx ]; then
    cat - <&3
  fi
  ) | /bin/sed "s/m4_/$magic/g;s/$magic""include(\[\([^]]*\)\])/m4_changequote([,])m4_include(\1)m4_changequote(,)/g;1s/^/m4_changequote(,)/" \
  | m4 -P - \
  | /bin/sed "s/$magic/m4_/g" \
  | /bin/sed "${args[@]}" -- "${params[@]}"
exit $?
