#! /bin/bash

# Helps bootstrapping the application when checked out from git.
# Requires GNU autoconf, GNU automake and GNU which.
#
# Copyright (C) 2004 - 2016, by
#
# Carlo Wood, Run on IRC <carlo@alinoe.com>
# RSA-1024 0x624ACAD5 1997-01-26                    Sign & Encrypt
# Fingerprint16 = 32 EC A7 B6 AC DB 65 A6  F6 F6 55 DD 1C DC FF 61
#

# Demand we use configure.ac.
if test ! -f configure.ac; then
  if test -f configure.in; then
    echo "You're using 'configure.in' instead of 'configure.ac'. The autotools react different"
    echo "if you use that old, deprecated name. You should rename it (and fix it)."
  else
    echo -e "\nERROR: Cannot find 'configure.ac'. Run ./autogen.sh from the directory containing configure.ac."
  fi
  exit 1
fi

# Determine if this project uses libtool.
if grep '^[[:space:]]*A[CM]_PROG_LIBTOOL' configure.ac >/dev/null; then
  using_libtool="yes"
else
  using_libtool="no"
fi

# Determine if this project uses gettext.
if grep '^[[:space:]]*AM_GNU_GETTEXT_VERSION' configure.ac >/dev/null; then
  using_gettext="yes"
else
  using_gettext="no"
fi

# Determine if this project uses doxygen.
if grep '^[[:space:]]*CW_DOXYGEN' configure.ac >/dev/null; then
  using_doxygen="yes"
else
  using_doxygen="no"
fi

# Determine if this project uses gtk-doc.
if grep '^[[:space:]]*GTK_DOC_CHECK' configure.ac >/dev/null; then
  using_gtkdoc="yes"
else
  using_gtkdoc="no"
fi

AUTOMAKE=${AUTOMAKE:-automake}
GETTEXT=${GETTEXT:-gettext}
ACLOCAL=${ACLOCAL:-aclocal}
AUTOHEADER=${AUTOHEADER:-autoheader}
AUTOCONF=${AUTOCONF:-autoconf}
LIBTOOL=${LIBTOOL:-libtool}
LIBTOOLIZE=${LIBTOOLIZE:-`echo $LIBTOOL | sed -e 's/libtool/libtoolize/'`}
GTKDOCIZE=${GTKDOCIZE:-gtkdocize}

# Sanity checks.
($AUTOCONF --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOCONF'. You need GNU autoconf to install from git (ftp://ftp.gnu.org/gnu/autoconf/)"; exit 1) || exit 1
($AUTOMAKE --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOMAKE'. You need GNU automake $required_automake_version or higher to install from git (ftp://ftp.gnu.org/gnu/automake/)"; exit 1) || exit 1
($ACLOCAL --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$ACLOCAL'. Please set the correct environment variable (ACLOCAL)."; exit 1) || exit 1
($AUTOHEADER --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: Cannot find '$AUTOHEADER'. Please set the correct environment variable (AUTOHEADER)."; exit 1) || exit 1
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

# Determine the version of automake.
automake_version=`$AUTOMAKE --version | head -n 1 | sed -e 's/[^12]*\([12]\.[0-9][^ ]*\).*/\1/'`

if test "$using_libtool" = "yes"; then
  # Determine the version of libtool.
  libtool_version=`$LIBTOOL --version | head -n 1 | sed -r -e 's/([^12]|[12][^.])*([12]\.[0-9]+(\.[0-9]+)*).*/\2/'`
  libtool_develversion=`$LIBTOOL --version | head -n 1 | grep '[12]\.[0-9].*([^ ]*' | sed -e 's/.*[12]\.[0-9].*(\([^ ]*\).*/\1/'`
fi

if test ! -f ./autogen_versions; then
  echo
  echo -n "ERROR: Missing file 'autogen_versions'. This file should define required_automake_version"
  if test "$using_libtool" = "yes"; then
    echo -n ", required_libtool_version and libtoolize_arguments"
  fi
  echo "."
  if test -n "$libtool_version"; then
    echo "For example, the file 'autogen_versions' could contain the following two lines:"
  else
    echo "For example, the file 'autogen_versions' could contain the following line:"
  fi
  echo "required_automake_version=\"$automake_version\""
  if test -n "$libtool_version"; then
    echo "required_libtool_version=\"$libtool_version\""
  fi
  exit 1
fi

. ./autogen_versions

if test "$using_libtool" = "yes"; then
  if test x"$required_libtool_version" = x; then
    echo -e "\nERROR: The file autogen_versions should define 'required_libtool_version'."
    exit 1
  fi
fi
if test x"$required_automake_version" = x; then
  echo -e "\nERROR: The file autogen_versions should define 'required_automake_version'."
  exit 1
fi

# Require requested version.
expr_automake_version=`echo "$automake_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
expr_required_automake_version=`echo "$required_automake_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
if expr "$expr_required_automake_version" \> "$expr_automake_version" >/dev/null; then
  $AUTOMAKE --version | head -n 1
  echo -e "\nERROR: automake $required_automake_version or higher is required. Please set \$AUTOMAKE"
  echo "to point to a newer automake, or upgrade."
  echo ""
  exit 1
fi

if test "$using_libtool" = "yes"; then

  # Require required_libtool_version.
  expr_libtool_version=`echo "$libtool_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  expr_required_libtool_version=`echo "$required_libtool_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  if expr "$expr_required_libtool_version" \> "$expr_libtool_version" >/dev/null; then
    $LIBTOOL --version
    echo -e "\nERROR: libtool version $required_libtool_version or higher is required."
    exit 1
  fi

  # Make effort to get the right libtool.m4 file.
  aclocal_ac_dir=`$ACLOCAL --print-ac-dir`
  aclocal_base=`basename $ACLOCAL`
  stripped_aclocal_ac_dir=`echo $aclocal_ac_dir | sed -e 's/'$aclocal_base'$/aclocal/'`
  aclocal_api=`echo $automake_version | sed -e 's/\([0-9]*\.[0-9]*\).*/\1/'`
  libtool_base=`basename $LIBTOOL`
  libtool_api=`echo $libtool_version | sed -e 's/\([0-9]*\.[0-9]*\).*/\1/'`
  need_copy="no"
  if test -f $aclocal_ac_dir-$aclocal_api/$libtool_base.m4; then
    libtool_m4=$aclocal_ac_dir-$aclocal_api/$libtool_base.m4
  elif test -f $aclocal_ac_dir-$aclocal_api/libtool-$libtool_api.m4; then
    libtool_m4=$aclocal_ac_dir-$aclocal_api/libtool-$libtool_api.m4
  elif test -f $aclocal_ac_dir-$aclocal_api/libtool.m4; then
    libtool_m4=$aclocal_ac_dir-$aclocal_api/libtool.m4
  elif test -f $aclocal_ac_dir/$libtool_base.m4; then
    libtool_m4=$aclocal_ac_dir/$libtool_base.m4
  elif test -f $aclocal_ac_dir/libtool-$libtool_api.m4; then
    libtool_m4=$aclocal_ac_dir/libtool-$libtool_api.m4
  elif test -f $aclocal_ac_dir/libtool.m4; then
    libtool_m4=$aclocal_ac_dir/libtool.m4
  # This is used on FreeBSD:
  elif test -f $stripped_aclocal_ac_dir/$libtool_base.m4; then
    libtool_m4=$stripped_aclocal_ac_dir/$libtool_base.m4
    need_copy="yes"
  elif test -f $stripped_aclocal_ac_dir/libtool-$libtool_api.m4; then
    libtool_m4=$stripped_aclocal_ac_dir/libtool-$libtool_api.m4
    need_copy="yes"
  elif test -f $stripped_aclocal_ac_dir/libtool.m4; then
    libtool_m4=$stripped_aclocal_ac_dir/libtool.m4
    need_copy="yes"
  fi
  if test "$need_copy" = "yes"; then
    test -d libtoolm4 && rm -f libtoolm4/libtool*
    mkdir -p libtoolm4 && cp $libtool_m4 libtoolm4
    ACLOCAL_LTFLAGS=${ACLOCAL_LTFLAGS:--I libtoolm4}
  fi

fi # using_libtool

if test "$using_gettext" = "yes"; then

  # Determine version of gettext.
  gettext_version=`$GETTEXT --version | head -n 1 | sed -e 's/[^0]*\(0\.[0-9][^ ]*\).*/\1/'`
  confver=`cat configure.ac | grep '^AM_GNU_GETTEXT_VERSION(' | sed -e 's/^AM_GNU_GETTEXT_VERSION(\([^()]*\))/\1/p' | sed -e 's/^\[\(.*\)\]$/\1/' | sed -e 1q`

  # Require version as specified in configure.ac.
  expr_confver=`echo "$confver" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  expr_gettext_version=`echo "$gettext_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  if expr "$expr_confver" \> "$expr_gettext_version" >/dev/null; then
    $GETTEXT --version | head -n 1
    echo -e "\nERROR: gettext version "$confver" or higher is required. Please set \$GETTEXT"
    echo "to point to a newer gettext, or upgrade."
    echo ""
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

# Do some git sanity checks.
if test -d .git; then
  PUSH_RECURSESUBMODULES="$(git config push.recurseSubmodules)"
  if test x"$PUSH_RECURSESUBMODULES" != x"on-demand"; then
    echo "You should use at least git version 2.7 and do:"
    echo "git config push.recurseSubmodules on-demand"
    echo "to prevent pushing a project that references unpushed submodules."
    echo "See http://stackoverflow.com/a/10878273/1487069"
    exit 1
  fi
fi

if test "$using_doxygen" = "yes"; then

if test -f "doc/doxygen.config.in"; then
  doc_path="doc"
elif test -f "docs/doxygen.config.in"; then
  doc_path="docs"
elif test -f "documentation/doxygen.config.in"; then
  doc_path="documentation"
elif test -d "doc"; then
  doc_path="doc"
elif test -d "docs"; then
  doc_path="docs"
elif test -d "documentation"; then
  doc_path="documentation"
else
  echo -e "\n*WARNING:**********************************************************"
  echo "* Creating non-existing directory 'doc'. Add it to your repository!"
  mkdir doc
  doc_path="doc"
  created_doc="yes"
fi

created_files=
if [ ! -f "$doc_path/Makefile.am" -a ! -f "$doc_path/Makefile.in" -a ! -f "$doc_path/Makefile" ]; then
  created_files="$created_files $doc_path/Makefile.am"
  cp cwm4/templates/doxygen/Makefile.am $doc_path
fi
if [ -f "$doc_path/Makefile.am" -a ! -f "$doc_path/main.css" ]; then
  created_files="$created_files $doc_path/main.css"
  cp cwm4/templates/doxygen/main.css $doc_path
fi
if [ -f "$doc_path/Makefile.am" -a ! -f "$doc_path/html.header.in" -a ! -f "$doc_path/html.header" ]; then
  created_files="$created_files $doc_path/html.header.in"
  cp cwm4/templates/doxygen/html.header.in $doc_path
fi
if [ -f "$doc_path/Makefile.am" -a ! -f "$doc_path/html.footer.in" -a ! -f "$doc_path/html.footer" ]; then
  created_files="$created_files $doc_path/html.footer.in"
  cp cwm4/templates/doxygen/html.footer.in $doc_path
fi
if [ -f "$doc_path/Makefile.am" -a ! -f $doc_path/mainpage.dox ]; then
  created_files="$created_files $doc_path/mainpage.dox"
  cp cwm4/templates/doxygen/mainpage.dox $doc_path
fi

if [ -f "$doc_path/Makefile.am" -a ! -f "$doc_path/doxygen.config.in" -a ! -f "$doc_path/doxygen.config" ]; then
  (doxygen --version) >/dev/null 2>/dev/null || (echo -e "\nERROR: You need the package 'doxygen' to generate documentation. Please install it (see http://www.doxygen.org/)."; exit 1) || exit 1
  created_files="$created_files $doc_path/doxygen.config.in"
  doxygen -g "$doc_path/doxygen.config.tmp" >/dev/null
  echo -e "# @""configure_input""@\n" > "$doc_path/doxygen.config.in";
  sed -e 's%^\(PROJECT_NAME[[:space:]=].*\)%\1@PACKAGE_NAME@%' \
      -e 's%^\(PROJECT_NUMBER[[:space:]=].*\)%\1@PACKAGE_VERSION@%' \
      -e 's%^\(OUTPUT_DIRECTORY[[:space:]=].*\)%\1.%' \
      -e 's%^\(INPUT[[:space:]=].*\)%\1@top_srcdir@/src @top_srcdir@/src/include%' \
      -e 's%^\(FILE_PATTERNS[[:space:]=].*\)%\1*.cc *.h *.dox%' \
      -e 's%^\(QUIET[[:space:]]*=\).*%\1 YES%' \
      -e 's%^\(PREDEFINED[[:space:]]*=\).*%\1 DOXYGEN protected_notdocumented=private%' \
      -e 's%^\(MACRO_EXPANSION[[:space:]]*=\).*%\1 YES%' \
      -e 's%^\(EXPAND_ONLY_PREDEF[[:space:]]*=\).*%\1 YES%' \
      -e 's%^\(HAVE_DOT[[:space:]]*=\).*%\1 @HAVE_DOT@%' \
      -e 's%^\(STRIP_FROM_PATH[[:space:]]*=\).*%\1 @DOXYGEN_STRIP_FROM_PATH@%' \
      -e 's%^\(IMAGE_PATH[[:space:]]*=\).*%\1 @top_srcdir@/doc/images%' \
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
                         "UNUSED(x)="' \
      "$doc_path/doxygen.config.tmp" >> "$doc_path/doxygen.config.in"
  rm "$doc_path/doxygen.config.tmp"
fi
#      -e 's%^\(CGI_NAME[[:space:]=].*\)%# Obsoleted: \1%' 

if test -n "$created_files"; then
  echo -e "\n*WARNING:**********************************************************"
  echo "* The following files were generated:"
  echo "* $created_files"
  echo "* Edit them and add them to your repository!"
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
  $1
}

# This is needed when someone just upgraded automake and this cache is still generated by an old version.
rm -rf autom4te.cache config.cache

if ! egrep '^[[:space:]]*CW_AUTOMACROS[[:space:]]*([[:space:]]dnl[[:space:]]|$)' configure.ac > /dev/null; then
  if ! egrep '^[[:space:]]*CW_AUTOMACROS(\(\[[[:digit:]]*\]\)|)[[:space:]]*([[:space:]]dnl[[:space:]]|$)' configure.ac > /dev/null; then
    echo -e "\nERROR: configure.ac must contain CW_AUTOMACROS. Put it for example at the top below AM_MAINTAINER_MODE."
  else
    echo -e "\nERROR: configure.ac: CW_AUTOMACROS has no arguments (anymore)."
  fi
  exit 1
fi

if test ! -f Makefile.am; then
  echo -e "\nERROR: Missing Makefile.am"
  exit 1
fi

if ! grep '^[[:space:]]*ACLOCAL_AMFLAGS[[:space:]]*=' Makefile.am >/dev/null; then
  echo -e "\nERROR: ACLOCAL_AMFLAGS not set in Makefile.am, it should contain \"-I cwm4/m4\".\nAdd the following line to Makefile.am: ACLOCAL_AMFLAGS = @ACLOCAL_CWFLAGS@"
  exit 1
fi

ACLOCAL_AMFLAGS=`grep '^[[:space:]]*ACLOCAL_AMFLAGS[[:space:]]*=' Makefile.am | sed -e 's/^[[:space:]]*ACLOCAL_AMFLAGS[[:space:]]*=[[:space:]]*//' -e 's%@ACLOCAL_CWFLAGS@%-I cwm4/m4%g'`

if ! echo "$ACLOCAL_AMFLAGS" | grep -- '-I cwm4/m4' >/dev/null; then
  echo "*** WARNING: ACLOCAL_AMFLAGS, in Makefile.am, should contain \"-I cwm4/m4\""
  echo "***          You can achieve this by adding ACLOCAL_AMFLAGS=@ACLOCAL_CWFLAGS@ to Makefile.am."
fi

run "$ACLOCAL $ACLOCAL_AMFLAGS $ACLOCAL_LTFLAGS"
if test "$using_gtkdoc" = "yes"; then
run "$GTKDOCIZE"
fi
run "$AUTOHEADER"
run "$AUTOCONF"
if test "$using_libtool" = "yes"; then
run "$LIBTOOLIZE --automake $libtoolize_arguments"
fi
if test ! -e depcomp; then
  ln -s cwm4/scripts/depcomp.sh depcomp
fi
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
