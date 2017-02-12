#! /bin/sh

# Make sure we use the same environment as bootstrap.sh.
AUTOMAKE=${AUTOMAKE:-automake}
ACLOCAL=${ACLOCAL:-`echo $AUTOMAKE | sed -e 's/automake/aclocal/'`}
AUTOCONF=${AUTOCONF:-autoconf}
AUTOHEADER=${AUTOHEADER:-`echo $AUTOCONF | sed -e 's/autoconf/autoheader/'`}
AUTOM4TE=${AUTOM4TE:-`echo $AUTOCONF | sed -e 's/autoconf/autom4te/'`}

export AUTOMAKE ACLOCAL AUTOCONF AUTOHEADER AUTOM4TE

MISSING_SUBMODULES="maybe"
while test -n "$MISSING_SUBMODULES"; do

  # (Re)generate submodules.m4.
  cwm4/scripts/generate_submodules_m4.sh || exit 1

  # Check dependencies.
  MISSING_SUBMODULES=
  SUBDIRS="$($AUTOM4TE -l M4sugar cwm4/submodules.m4)"
  # Returned "CW_SUBMODULE_SUBDIRS" when there are no submodules.
  for dir in ${SUBDIRS#CW_SUBMODULE_SUBDIRS}; do
    if ! test -f "$dir/configure.m4"; then
      MISSING_SUBMODULES="$MISSING_SUBMODULES $dir"
    fi
  done
  for dir in $MISSING_SUBMODULES; do
    echo "  Adding submodule dependency $dir"
    #git submodule URL $dir
  done
done
