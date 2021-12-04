# CW_CHECK_REQUIRED_INCLUDE_FILE_CXX cmake function -- this file is part of cwm4.
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
include(CheckIncludeFileCXX)

# CW_CHECK_REQUIRED_INCLUDE_FILE_CXX (<include_file> <error_message>)
#
# Check if the given <include_file> may be included in a CXX source file,
# if successful store the result in an internal cache entry named derived
# from <include_file>. Otherwise print a fatal error <error_message>.

function(CW_CHECK_REQUIRED_INCLUDE_FILE_CXX include_file error_message)
  string(MAKE_C_IDENTIFIER "HAVE_${include_file}" include_id)
  string(TOUPPER "${include_id}" upper_include_id)
  check_include_file_cxx("${include_file}" "${upper_include_id}")
  if (NOT ${upper_include_id})
    unset(${upper_include_id} CACHE)
    message(FATAL_ERROR "\n${error_message}\n")
  endif ()
endfunction ()
