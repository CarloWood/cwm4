# CW_SYS_MALLOC_OVERHEAD cmake function -- this file is part of cwm4.
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

# CW_SYS_MALLOC_OVERHEAD
#
# Set CW_MALLOC_OVERHEAD to be the number of bytes extra
# allocated for a call to malloc.
#
# To use this, add the following line in config.h.in:
#
#     static constexpr size_t malloc_overhead_c = @CW_MALLOC_OVERHEAD@;
#

set(CW_SYS_MALLOC_OVERHEAD_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

function(CW_SYS_MALLOC_OVERHEAD)
  if (NOT DEFINED CACHE{CW_MALLOC_OVERHEAD})
    set(CMAKE_TRY_COMPILE_CONFIGURATION "Release")
    try_run(run_works
        compile_works
        ${CMAKE_CURRENT_BINARY_DIR}/cw_utils_sys_malloc_overhead
        ${CW_SYS_MALLOC_OVERHEAD_MODULE_PATH}/CW_SYS_MALLOC_OVERHEAD.c
        COMPILE_OUTPUT_VARIABLE compile_output
        RUN_OUTPUT_VARIABLE run_output)
    if (NOT compile_works)
      message(FATAL_ERROR "Failed to compile test program CW_SYS_MALLOC_OVERHEAD.c: ${compile_output}")
    elseif (NOT run_works EQUAL 0)
      message(FATAL_ERROR "Failed to run test program CW_SYS_MALLOC_OVERHEAD.c: ${run_output}")
    else ()
      set(CW_MALLOC_OVERHEAD ${run_output} CACHE INTERNAL "")
    endif ()
  endif ()
endfunction()
