# CW_DEFINE_TYPE cmake function -- this file is part of cwm4.
# Copyright (C) 2019  Carlo Wood <carlo@alinoe.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#
# As a special exception, the author gives unlimited permission to copy,
# distribute and modify the configure scripts that are the output of
# by a tool like cmake when using these functions as input.  You need
# not follow the terms of the GNU General Public License when using or
# distributing such scripts, even though portions of the text of this
# file appears in them. The GNU General Public License (GPL) does govern
# all other use of the material that constitutes the cwm4 project.

include_guard(GLOBAL)
set(CW_SYS_TYPEDEFS "")

# CW_DEFINE_TYPE(<old_type> <new_type>)
#
# Append 'using new_type = old_type;' to CW_SYS_TYPEDEFS.
#
# To use this, add the following line in config.h.in:
#
#     @CW_SYS_TYPEDEFS@
#

function(CW_DEFINE_TYPE old_type new_type)
  set(CW_SYS_TYPEDEFS "${CW_SYS_TYPEDEFS} using ${new_type} = ${old_type};" PARENT_SCOPE)
endfunction()
