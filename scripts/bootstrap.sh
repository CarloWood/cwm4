#! /bin/bash

# Helps bootstrapping the application when checked out from git.
# Requires GNU autoconf, GNU automake and GNU which.
#
# Copyright (C) 2004 - 2017, by
#
# Carlo Wood, Run on IRC <carlo@alinoe.com>
# RSA-1024 0x624ACAD5 1997-01-26                    Sign & Encrypt
# Fingerprint16 = 32 EC A7 B6 AC DB 65 A6  F6 F6 55 DD 1C DC FF 61
#

# Demand we use configure.ac.
generate_configure_ac="no"
if test ! -f configure.ac; then
  if test -f configure.in; then
    echo "You're using 'configure.in' instead of 'configure.ac'. The autotools react different"
    echo "if you use that old, deprecated name. You should rename it (and fix it)."
    exit 1
  else
    generate_configure_ac="yes"
  fi
fi

if ! grep '^m4_include(\[cwm4/configure_ac_top\.m4\])' configure.ac >/dev/null; then
  echo "Missing 'm4_include([cwm4/configure_ac_top.m4])' in configure.ac."
  generate_configure_ac="yes"
fi

if ! grep '^m4_include(\[cwm4/configure_ac_bottom\.m4\])' configure.ac >/dev/null; then
  echo "Missing 'm4_include([cwm4/configure_ac_bottom.m4])' in configure.ac."
  generate_configure_ac="yes"
fi

if test "$generate_configure_ac" = "yes"; then
  if test -e configure.ac; then
    echo "WARNING: Replacing your configure.ac with a new one. Please edit it! The old configure.ac was renamed to configure.ac.bak."
    mv configure.ac configure.ac.bak
  fi
  CW_PACKAGE_NAME="$(basename $(pwd))"
  CW_BUGREPORT="$GIT_AUTHOR_EMAIL"
  sed -e 's/@CW_PACKAGE_NAME@/'"$CW_PACKAGE_NAME"'/;s/@CW_BUGREPORT@/'"$CW_BUGREPORT"'/' cwm4/templates/configure.ac > configure.ac
else
  if test $(egrep '^[[:space:]]*define[[:space:]]*\([[:space:]]*CW_(VERSION_MAJOR|VERSION_MINOR|VERSION_REVISION|PACKAGE_NAME|BUGREPORT|COMPILE_FLAGS|THREADS)[[:space:]]*,' configure.ac | sort -u | wc --lines) != 7; then
    echo '*** ERROR: The follow macros should be defined at the top of configure.ac:'
    echo '***        CW_VERSION_MAJOR, CW_VERSION_MINOR, CW_VERSION_REVISION,'
    echo '***        CW_PACKAGE_NAME, CW_BUGREPORT, CW_COMPILE_FLAGS and CW_THREADS.'
    echo '***        Please see cwm4/templates/configure.ac for an example.'
    exit 1
  fi
  count="$(egrep '^[[:space:]]*define[[:space:]]*\([[:space:]]*CW_INTERFACE_(VERSION_REVISION|VERSION|AGE)[[:space:]]*,' configure.ac | sort -u | wc --lines)"
  if test "$count" != 0 -a "$count" != 3; then
    echo '*** ERROR: The follow macros should be defined at the top of configure.ac for a library project:'
    echo '***        CW_INTERFACE_VERSION_REVISION, CW_INTERFACE_VERSION and CW_INTERFACE_AGE.'
    echo '***        Please see cwm4/templates/configure.ac for an example.'
    exit 1
  fi
fi

# Determine if this project uses libtool.
RESULT=$(find . -type d \( -name '.git' -o -name 'cwm4' \) -prune -o -name Makefile.am -exec egrep -l '^[[:alnum:]_]*_LTLIBRARIES[[:space:]]*=' {} \;)
if test -n "$RESULT"; then
  using_libtool="yes"
else
  using_libtool="no"
fi

# Determine if this project uses gettext.
if m4 -P cwm4/sugar.m4 configure.ac | egrep '^[[:space:]]*AM_GNU_GETTEXT_VERSION' >/dev/null; then
  using_gettext="yes"
else
  using_gettext="no"
fi

# Determine if this project uses doxygen.
CW_DOXYGEN_LINE=$(egrep '^[[:space:]]*CW_DOXYGEN' configure.ac)
if test -n "$CW_DOXYGEN_LINE"; then
  using_doxygen="yes"
  CW_DOXYGEN_PATHS="$(echo $CW_DOXYGEN_LINE | sed -r -e 's/^[[:space:]]*CW_DOXYGEN[[:space:]]*\(\[*//;s/\]*\).*//')"
else
  using_doxygen="no"
fi

# Determine if this project uses gtk-doc.
if m4 -P cwm4/sugar.m4 configure.ac | egrep '^[[:space:]]*GTK_DOC_CHECK' >/dev/null; then
  using_gtkdoc="yes"
else
  using_gtkdoc="no"
fi

AUTOMAKE=${AUTOMAKE:-automake}
ACLOCAL=${ACLOCAL:-`echo $AUTOMAKE | sed -e 's/automake/aclocal/'`}
AUTOCONF=${AUTOCONF:-autoconf}
AUTOHEADER=${AUTOHEADER:-`echo $AUTOCONF | sed -e 's/autoconf/autoheader/'`}
AUTOM4TE=${AUTOM4TE:-`echo $AUTOCONF | sed -e 's/autoconf/autom4te/'`}
LIBTOOL=${LIBTOOL:-libtool}
LIBTOOLIZE=${LIBTOOLIZE:-`echo $LIBTOOL | sed -e 's/libtool/libtoolize/'`}
GETTEXT=${GETTEXT:-gettext}
GTKDOCIZE=${GTKDOCIZE:-gtkdocize}

# Environment variables need to be exported. For example, aclocal uses AUTOM4TE to run the correct autom4te.
export AUTOMAKE ACLOCAL AUTOCONF AUTOHEADER AUTOM4TE LIBTOOL LIBTOOLIZE GETTEXT GTKDOCIZE

# Sanity checks.
($AUTOCONF --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOCONF'. You need GNU autoconf to install from git (ftp://ftp.gnu.org/gnu/autoconf/)"; exit 1) || exit 1
($AUTOMAKE --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOMAKE'. You need GNU automake $required_automake_version or higher to install from git (ftp://ftp.gnu.org/gnu/automake/)"; exit 1) || exit 1
($ACLOCAL --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$ACLOCAL'. Please set the correct environment variable (ACLOCAL)."; exit 1) || exit 1
($AUTOHEADER --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOHEADER'. Please set the correct environment variable (AUTOHEADER)."; exit 1) || exit 1
($AUTOM4TE --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOM4TE'. Please set the correct environment variable (AUTOM4TE)."; exit 1) || exit 1
if test $using_libtool = "yes"; then
  ($LIBTOOL --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$LIBTOOL'. You need GNU libtool $required_libtool_version or higher to install from git (ftp://ftp.gnu.org/gnu/libtool/)"; exit 1) || exit 1
  ($LIBTOOLIZE --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$LIBTOOLIZE'. Please set the correct environment variable."; exit 1) || exit 1
fi
if test "$using_gettext" = "yes"; then
  ($GETTEXT --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$GETTEXT'. Please set the correct environment variable (GETTEXT)."; exit 1) || exit 1
fi
if test "$using_gtkdoc" = "yes"; then
  ($GTKDOCIZE --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$GTKDOCIZE'. Please set the correct environment variable (GTKDOCIZE)."; exit 1) || exit 1
fi

# Determine the version of autoconf.
autoconf_version=`$AUTOCONF --version | head -n 1 | sed -e 's%^[^ ]* [^0-9]*\([0-9.]*[^ ]*\).*%\1%'`

# Determine the version of autoheader.
autoheader_version=`$AUTOHEADER --version | head -n 1 | sed -e 's%^[^ ]* [^0-9]*\([0-9.]*[^ ]*\).*%\1%'`

# Determine the version of autom4te.
autom4te_version=`$AUTOM4TE --version | head -n 1 | sed -e 's%^[^ ]* [^0-9]*\([0-9.]*[^ ]*\).*%\1%'`

# Determine the version of automake.
automake_version=`$AUTOMAKE --version 2>/dev/null | head -n 1 | sed -e 's%^[^ ]* [^0-9]*\([0-9.]*[^ ]*\).*%\1%'`

# Determine the version of aclocal.
aclocal_version=`$ACLOCAL --version | head -n 1 | sed -e 's%^[^ ]* [^0-9]*\([0-9.]*[^ ]*\).*%\1%'`

if test "$using_libtool" = "yes"; then
  # Determine the version of libtool.
  libtool_version=`$LIBTOOL --version | head -n 1 | sed -e 's%^[^ ]* [^0-9]*\([0-9.]*[^ ]*\).*%\1%'`
  libtool_develversion=`$LIBTOOL --version | head -n 1 | sed -e 's%.*\(([^(]*$\)%\1%;s%(\([0-9.]*\).*%\1%'`
fi

if test ! -f ./autogen_versions; then
  echo
  echo -n "*** ERROR: Missing file 'autogen_versions'. This file should define required_automake_version"
  if test "$using_libtool" = "yes"; then
    echo -n ", required_libtool_version and libtoolize_arguments"
  fi
  echo "."
  echo "***        For example, the file 'autogen_versions' could contain the following `cat cwm4/templates/autogen_versions | wc --lines` lines (from cwm4/templates/autogen_versions):"
  echo
  cat cwm4/templates/autogen_versions
  echo
  exit 1
fi

source autogen_versions

# autogen.sh is supposed to recover from everything, so remove old files that might get in the way.
rm -f aclocal.m4 compile config.guess config.sub depcomp install-sh ltmain.sh missing
rm -rf autom4te.cache m4/aclocal

# ACLOCAL needs this to exist (and we need m4 to exist).
mkdir -p m4/aclocal

if test "$using_libtool" = "yes"; then
  if test x"$required_libtool_version" = x; then
    echo -e "\n*** ERROR: The file autogen_versions should define 'required_libtool_version'."
    source cwm4/templates/autogen_versions
    echo "The minimum required version for libtool (for cwm4) is currently $required_libtool_version. See cwm4/templates/autogen_versions."
    exit 1
  fi
  echo "LT_INIT" > m4/lt_init.m4
  echo "LT_PREREQ([$required_libtool_version])" >> m4/lt_init.m4
else
  rm -f m4/lt_init.m4
fi
if test x"$required_automake_version" = x; then
  echo -e "\n*** ERROR: The file autogen_versions should define 'required_automake_version'."
  source cwm4/templates/autogen_versions
  echo "The minimum required version for automake (for cwm4) is currently $required_automake_version. See cwm4/templates/autogen_versions."
  exit 1
fi
if test x"$required_autoconf_version" = x; then
  echo -e "\n*** ERROR: The file autogen_versions should define 'required_autoconf_version'."
  source cwm4/templates/autogen_versions
  echo "The minimum required version for autoconf (for cwm4) is currently $required_autoconf_version. See cwm4/templates/autogen_versions."
  exit 1
fi

echo "dnl This file is automatically generated, do not edit. Edit autogen_versions instead." > m4/min_automake_version.m4
echo "$required_automake_version dnl" >> m4/min_automake_version.m4
echo "dnl This file is automatically generated, do not edit. Edit autogen_versions instead." > m4/min_autoconf_version.m4
echo "$required_autoconf_version dnl" >> m4/min_autoconf_version.m4

version_compare() {
  if [[ $1 == $2 ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # Fill empty fields in ver1 with zeros.
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]} ]]; then
      # Fill empty fields in ver2 with zeros.
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

# Require requested version.
expr_automake_version=`echo "$automake_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
expr_required_automake_version=`echo "$required_automake_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
version_compare $automake_version $required_automake_version
if [ $? -eq 2 ]; then
  $AUTOMAKE --version 2>/dev/null | head -n 1
  echo -e "\n*** ERROR: automake $required_automake_version or higher is required."
  echo "***        Please set \$AUTOMAKE to point to a newer automake, or upgrade."
  exit 1
fi

if [ x"$autoheader_version" != x"$autoconf_version" -o x"$autom4te_version" != x"$autoconf_version" ]; then
  $AUTOCONF --version | head -n 1
  $AUTOHEADER --version | head -n 1
  $AUTOM4TE --version | head -n 1
  echo -e "\n*** ERROR: autoconf, autoheader autom4te should be the same version! Please set the environment variables AUTOCONF, AUTOHEADER and AUTOM4TE correctly."
  exit 1
fi

if [ "$aclocal_version" != "$automake_version" ]; then
  $AUTOMAKE --version 2>/dev/null | head -n 1
  $ACLOCAL --version | head -n 1
  echo -e "\n*** ERROR: automake and aclocal should be the same version!"
  exit 1
fi

if test "$using_libtool" = "yes"; then

  # Require required_libtool_version.
  expr_libtool_version=`echo "$libtool_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  expr_required_libtool_version=`echo "$required_libtool_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  if expr "$expr_required_libtool_version" \> "$expr_libtool_version" >/dev/null; then
    $LIBTOOL --version
    echo -e "\n*** ERROR: libtool version $required_libtool_version or higher is required."
    exit 1
  fi

fi # using_libtool

if test "$using_gettext" = "yes"; then

  # Determine version of gettext.
  gettext_version=`$GETTEXT --version | head -n 1 | sed -e 's/[^0]*\(0\.[0-9][^ ]*\).*/\1/'`
  confver=`m4 -P cwm4/sugar.m4 configure.ac | grep '^AM_GNU_GETTEXT_VERSION(' | sed -e 's/^AM_GNU_GETTEXT_VERSION(\([^()]*\))/\1/p' | sed -e 's/^\[\(.*\)\]$/\1/' | sed -e 1q`

  # Require version as specified in configure.ac.
  expr_confver=`echo "$confver" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  expr_gettext_version=`echo "$gettext_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  if expr "$expr_confver" \> "$expr_gettext_version" >/dev/null; then
    $GETTEXT --version | head -n 1
    echo -e "\n*** ERROR: gettext version "$confver" or higher is required."
    echo "***        Please set \$GETTEXT to point to a newer gettext, or upgrade."
    exit 1
  fi

  if [ ! -d intl ]; then
    echo "Setting up internationalization files."
    autopoint --force
    cat intl/Makefile.in | sed -e 's/CPPFLAGS/CXXFLAGS/g' > intl/Makefile.in.new && mv intl/Makefile.in.new intl/Makefile.in
    if [ -f Makefile -a -x config.status ]; then
      CONFIG_FILES=intl/Makefile CONFIG_HEADERS= /bin/sh ./config.status
    fi
  fi

fi # using_gettext

# Sanity check.
if test ! -e m4/submodules.m4; then
  echo "Generating missing m4/submodules.m4! This should only happen when you run cwm4/scripts/bootstrap.sh directly, instead of autogen.sh."
  cwm4/scripts/generate_submodules_m4.sh || exit 1
fi

version_compare $aclocal_version 1.10
if [ $? -eq 2 ]; then
  echo "Adding workaround for bug in aclocal $aclocal_version"
  # A bug in aclocal version 1.9 causes m4_include's to fail.
  # Add a workaround using symbolic links.
  SUBDIRS="$($AUTOM4TE -l M4sugar cwm4/submodules.m4)"
  cd m4
  for module in ${SUBDIRS#CW_SUBMODULE_SUBDIRS}; do
    ln -sf ../$module
  done
  cd ..
fi

# Do some git sanity checks.
if test -d .git; then
  PUSH_RECURSESUBMODULES="$(git config push.recurseSubmodules)"
  if test -z "$PUSH_RECURSESUBMODULES"; then
    # Use this as default for now.
    git config push.recurseSubmodules check
    echo -e "\n*** WARNING: git config push.recurseSubmodules was not set!"
    echo "***      To prevent pushing a project that references unpushed submodules,"
    echo "***      this config was set to 'check'. Use instead the command"
    echo "***      > git config push.recurseSubmodules on-demand"
    echo "***      to automatically push submodules when pushing a reference to them."
    echo "***      See http://stackoverflow.com/a/10878273/1487069 and"
    echo "***      http://stackoverflow.com/a/34615803/1487069 more more info."
    echo
  fi
fi

if test "$using_doxygen" = "yes"; then

if expr "$CW_DOXYGEN_LINE" : "^[[:space:]]*CW_DOXYGEN[[:space:]]*[^(]" > /dev/null ||
   expr "$CW_DOXYGEN_LINE" : "^[[:space:]]*CW_DOXYGEN[[:space:]]*$" > /dev/null; then
  echo -e "\n*ERROR:**********************************************************"
  echo "* Using CW_DOXYGEN without arguments. Please specify directories to generate documtation in."
  echo "* Use a dot (.) for the root directory. For example:"
  echo "* CW_DOXYGEN([. src utils])"
  exit 1
fi

doc_paths=
for dp in $CW_DOXYGEN_PATHS; do

  if test -f "$dp/doc/doxygen.config.in"; then
    doc_paths+=" $dp/doc"
  elif test -f "$dp/docs/doxygen.config.in"; then
    doc_paths+=" $dp/docs"
  elif test -f "$dp/documentation/doxygen.config.in"; then
    doc_paths+=" $dp/documentation"
  elif test -d "$dp/doc"; then
    doc_paths+=" $dp/doc"
  elif test -d "$dp/docs"; then
    doc_paths+=" $dp/docs"
  elif test -d "$dp/documentation"; then
    doc_paths+=" $dp/documentation"
  else
    echo -e "\n*ERROR:**********************************************************"
    echo "* Using $CW_DOXYGEN_LINE in configure.ac but no doc/docs/documentation directory could be found in '$dp'!"
    echo "* Please create a $dp/doc directory or remove $dp from the CW_DOXYGEN line configure.ac."
    exit 1
  fi

done

for dp in $doc_paths; do

  created_files=
  if [ ! -f "$dp/Makefile.am" -a ! -f "$dp/Makefile.in" -a ! -f "$dp/Makefile" ]; then
    created_files="$created_files $dp/Makefile.am"
    cp cwm4/templates/doxygen/Makefile.am $dp
  fi
  if [ -f "$dp/Makefile.am" -a ! -f "$dp/main.css" ]; then
    created_files="$created_files $dp/main.css"
    cp cwm4/templates/doxygen/main.css $dp
  fi
  if [ -f "$dp/Makefile.am" -a ! -f "$dp/html.header.in" -a ! -f "$dp/html.header" ]; then
    created_files="$created_files $dp/html.header.in"
    cp cwm4/templates/doxygen/html.header.in $dp
  fi
  if [ -f "$dp/Makefile.am" -a ! -f "$dp/html.footer.in" -a ! -f "$dp/html.footer" ]; then
    created_files="$created_files $dp/html.footer.in"
    cp cwm4/templates/doxygen/html.footer.in $dp
  fi
  if [ -f "$dp/Makefile.am" -a ! -f $dp/mainpage.dox ]; then
    created_files="$created_files $dp/mainpage.dox"
    cp cwm4/templates/doxygen/mainpage.dox $dp
  fi

  if [ -f "$dp/Makefile.am" -a ! -f "$dp/doxygen.config.in" -a ! -f "$dp/doxygen.config" ]; then
    (doxygen --version) >/dev/null 2>/dev/null || (echo -e "\n*** ERROR: You need the package 'doxygen' to generate documentation. Please install it (see http://www.doxygen.org/)."; exit 1) || exit 1
    created_files="$created_files $dp/doxygen.config.in"
    doxygen -g "$dp/doxygen.config.tmp" >/dev/null
    echo -e "# @""configure_input""@\n" > "$dp/doxygen.config.in";
    sed -e 's%^\(PROJECT_NAME[[:space:]]*=\).*%\1 @PACKAGE_NAME@%' \
        -e 's%^\(PROJECT_NUMBER[[:space:]]*=\).*%\1 @PACKAGE_VERSION@%' \
        -e 's%^\(OUTPUT_DIRECTORY[[:space:]]*=\).*%\1 .%' \
        -e 's%^\(INPUT[[:space:]]*=\).*%\1 @top_srcdir@/src @top_srcdir@/src/include%' \
        -e 's%^\(FILE_PATTERNS[[:space:]]*=\).*%\1 *.cxx *.h *.dox%' \
        -e 's%^\(QUIET[[:space:]]*=\).*%\1 YES%' \
        -e 's%^\(PREDEFINED[[:space:]]*=\).*%\1 DOXYGEN protected_notdocumented=private%' \
        -e 's%^\(MACRO_EXPANSION[[:space:]]*=\).*%\1 YES%' \
        -e 's%^\(EXPAND_ONLY_PREDEF[[:space:]]*=\).*%\1 YES%' \
        -e 's%^\(HAVE_DOT[[:space:]]*=\).*%\1 @HAVE_DOT@%' \
        -e 's%^\(STRIP_FROM_PATH[[:space:]]*=\).*%\1 @DOXYGEN_STRIP_FROM_PATH@%' \
        -e 's%^\(IMAGE_PATH[[:space:]]*=\).*%\1 @top_srcdir@/'"$dp"'/images%' \
        -e 's%^\(HTML_HEADER[[:space:]]*=\).*%\1 html.header%' \
        -e 's%^\(HTML_FOOTER[[:space:]]*=\).*%\1 html.footer%' \
        -e 's%^\(GENERATE_LATEX[[:space:]]*=\).*%\1 NO%' \
        -e '/^PREDEFINED[[:space:]]*=/ cPREDEFINED             = "DOXYGEN" \\\
                           "protected_notdocumented=private" \\\
                           "public_notdocumented=private" \\\
                           "@DOXYGEN_CWDEBUG@" \\\
                           "@DOXYGEN_DEBUG@" \\\
                           "DDCN(x)=" \\\
                           "DOXYGEN_STATIC=" \\\
                           "UNUSED_ARG(x)="' \
        "$dp/doxygen.config.tmp" >> "$dp/doxygen.config.in"
    rm "$dp/doxygen.config.tmp"
  fi

  DOC_NAME="$(basename $dp)"
  DIR_NAME="$(dirname $dp)"

  if ! $(grep -E "^[[:space:]]*SUBDIRS[[:space:]]*=.*\b$DOC_NAME\b" $DIR_NAME/Makefile.am >/dev/null); then
    echo -e "\n*** WARNING: Directory \"$DOC_NAME\" is missing from the SUBDIRS line in $DIR_NAME/Makefile.am!\n"
  fi

done

if test -n "$created_files"; then
  echo -e "\n*WARNING:**********************************************************"
  echo "* The following files were generated:"
  echo "* $created_files"
  echo "* Edit them and add them to your repository!"
  echo
fi

fi # using_doxygen

if test "$using_libtool" = "yes"; then

  # Check if bootstrap was run before and if the installed files are the same version.
  if test -f ltmain.sh; then
    installed_libtool=`grep '^VERSION=' ltmain.sh | sed -r -e 's/([^12]|[12][^.])*([12]\.[0-9]+(\.[0-9]+)*).*/\2/'`
    installed_timestamp=`grep '^TIMESTAMP=' ltmain.sh | sed -e 's/.*(\([0-9]*\.[^ ]*\).*/\1/;s/TIMESTAMP=""/no timestamp/'`
    if test "$installed_libtool" != "$libtool_version" -o \( X"$installed_timestamp" != X"$libtool_develversion" -a X"$installed_timestamp" != X"no timestamp" \); then
      echo "Re-installing new libtool files ($installed_libtool ($installed_timestamp) -> $libtool_version ($libtool_develversion))"
      rm -f config.guess config.sub ltmain.sh ltconfig
    fi
  fi

fi # using_libtool

run()
{
  echo "Running $1 ..."
  $1 || exit 1
}

# This is needed when someone just upgraded automake and this cache is still generated by an old version.
rm -rf autom4te.cache config.cache

if test ! -f Makefile.am; then
  echo -e "\n*** WARNING: Missing Makefile.am. Copying a default one. Edit it!"
  cp cwm4/templates/root_Makefile.am Makefile.am
fi

if ! egrep '^[[:space:]]*SUBDIRS[[:space:]]*=.*@CW_SUBDIRS@' Makefile.am >/dev/null; then
  echo -e "\n*** ERROR: SUBDIRS in Makefile.am must contain @CW_SUBDIRS@.\n***        For example: SUBDIRS = @CW_SUBDIRS@ src"
  exit 1
fi

if egrep '^[[:space:]]*EXTRA_DIST[[:space:]]*=' Makefile.am >/dev/null; then
  echo -e "\n*** ERROR: EXTRA_DIST should only append new files. Use 'EXTRA_DIST += ...' instead of 'EXTRA_DIST ='."
  exit 1
fi

if egrep '^[[:space:]]*MAINTAINERCLEANFILES[[:space:]]*=' Makefile.am >/dev/null; then
  echo -e "\n*** ERROR: MAINTAINERCLEANFILES should only append new files. Use 'MAINTAINERCLEANFILES += ...' instead of 'MAINTAINERCLEANFILES ='."
  exit 1
fi

generate_makefile_am="no"
if ! egrep '^[[:space:]]*include[[:space:]]+\$\(srcdir\)/cwm4/root_makefile_top\.am' Makefile.am >/dev/null; then
  echo "Missing 'include \$(srcdir)/cwm4/root_makefile_top.am' in Makefile.am."
  generate_makefile_am="yes"
fi

if ! egrep '^[[:space:]]*include[[:space:]]+\$\(srcdir\)/cwm4/root_makefile_bottom\.am' Makefile.am >/dev/null; then
  echo "Missing 'include \$(srcdir)/cwm4/root_makefile_bottom.am' in Makefile.am."
  generate_makefile_am="yes"
fi

if test "$generate_makefile_am" = "yes"; then
  if test -e Makefile.am; then
    echo "WARNING: Replacing your Makefile.am with a new one. Please edit it! The old Makefile.am was renamed to Makefile.am.bak."
    mv Makefile.am Makefile.am.bak
  fi
  cp cwm4/templates/root_Makefile.am Makefile.am
fi

if test "$using_libtool" = "yes"; then
  # Set SED and M4 to scripts that cause libtoolize to process configure.ac properly.
  export SED="$(pwd)/cwm4/scripts/SED.sh"
  export M4="$(pwd)/cwm4/scripts/M4.sh"
  run "$LIBTOOLIZE --force --automake $libtoolize_arguments"
  unset SED
  unset M4
  #if test ! -e depcomp; then
  #  ln -s cwm4/scripts/depcomp.sh depcomp
  #fi
fi
if test -n "$ACLOCAL_PATH"; then
  echo "ACLOCAL_PATH is set ($ACLOCAL_PATH)!"
fi
run "$ACLOCAL -I cwm4/aclocal -I m4/aclocal"
if test "$using_gtkdoc" = "yes"; then
  run "$GTKDOCIZE"
fi
run "$AUTOHEADER"
run "$AUTOCONF"
run "$AUTOMAKE --add-missing --foreign"

echo
project_name=`basename "$PWD"`

echo -n "Now you can do '"
if [ ! -d ../$project_name-objdir ]; then
  echo -n "mkdir ../$project_name-objdir; "
fi
echo -n "cd ../$project_name-objdir; "
if test -n "$CONFIGURE_OPTIONS"; then
  echo "configure'."
else
  echo "../$project_name/configure --enable-maintainer-mode [--help]'."
fi
