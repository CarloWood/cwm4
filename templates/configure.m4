# Default submodule configure.m4, included from the generated submodules.m4.
# Before inclusion, the macro cwm4_rel_top_srcdir is set to the path relative
# to $top_scrdir containing the submodule directory, and cwm4_submodule_path
# is set to the submodule `path'. Finally, cwm4_submodule_relpath is defined
# as [cwm4_rel_top_srcdir/]cwm4_submodule_path/ (see submodules.m4).
#
# This file should append cwm4_submodule_path to CW_SUBMODULE_SUBDIRS
# iff cwm4_rel_top_srcdir is empty (this is done in the first line below).
#
# If this submodule depends on sibling submodules (having their path in
# the same parent directory) then this file must be editted: duplicate
# the first line as often as necessary and add the submodules as necessary,
# replacing cwm4_submodule_path with the `path' of those submodules.

m4_if(cwm4_rel_top_srcdir, [], [m4_append_uniq([CW_SUBMODULE_SUBDIRS], cwm4_submodule_path, [ ])])
m4_append_uniq([CW_SUBMODULE_CONFIG_FILES], cwm4_quote(cwm4_submodule_relpath[Makefile]), [ ])
