m4_changequote(`[',`]')m4_dnl
m4_define([m4_copy], [m4_define([$2], m4_defn([$1]))])m4_dnl
m4_define([m4_rename], [m4_copy([$1], [$2])m4_undefine([$1])])m4_dnl
m4_rename([m4_ifelse], [m4_if])m4_dnl
m4_rename([m4_regexp], [m4_bregexp])m4_dnl
