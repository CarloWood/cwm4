# Default submodule configure.m4, included from the generated submodules.m4.
# Before inclusion, cwm4_submodule_path is set to the submodules `path',
# cwm4_submodule_dirname is set to the dirname of path and cwm4_submodule_basename
# is set to the basename of path.
#
# This file should append cwm4_submodule_basename to CW_SUBMODULE_SUBDIRS
# iff cwm4_submodule_dirname is empty (this is done in the first line below).
#
# If this submodule depends on sibling submodules (having their path in
# the same parent directory) then this file must be editted: duplicate
# the first line as often as necessary and add the submodules as necessary,
# replacing cwm4_submodule_basename with the basename of those submodules.

m4_if(cwm4_submodule_dirname, [], [m4_append_uniq([CW_SUBMODULE_SUBDIRS], cwm4_submodule_basename, [ ])])
m4_append_uniq([CW_SUBMODULE_CONFIG_FILES], cwm4_quote(cwm4_submodule_path[/Makefile]), [ ])

dnl vim: filetype=config
