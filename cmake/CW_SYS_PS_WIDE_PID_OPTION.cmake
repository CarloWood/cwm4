# CW_SYS_PS_WIDE_PID_OPTION cmake function -- this file is part of cwm4.
# Copyright (C) 2020  Carlo Wood <carlo@alinoe.com>
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

# CW_SYS_PS_WIDE_PID_OPTION
#
# Determines the options needed for `ps' to print the full command of
# a specified PID.
#
# To use this, add the following line in config.h.in:
#
#     static char const* const PS_ARGUMENT = "@PS_ARGUMENT@";
#

set(CW_SYS_MALLOC_OVERHEAD_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

function(CW_SYS_PS_WIDE_PID_OPTION)
  if (NOT DEFINED CACHE{CW_PS_WIDE_PID_OPTION})
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo_append "-- Checking for (ultra) wide ps output option - ")
    execute_process(COMMAND "${CW_PATH_PROG_PS}" -ww
      RESULT_VARIABLE ww_result
      OUTPUT_FILE "/dev/null"
      ERROR_FILE "/dev/null"
    )
    if (ww_result EQUAL 0)
      set(ps_wide_pid_option "-ww")
    else ()
      execute_process(COMMAND "${CW_PATH_PROG_PS}" -w
        RESULT_VARIABLE w_result
        OUTPUT_FILE "/dev/null"
        ERROR_FILE "/dev/null"
      )
      if (w_result EQUAL 0)
        set(ps_wide_pid_option "-w")
      else ()
        set(ps_wide_pid_option "-f")
      endif ()
    endif ()
    file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/ps.out")
    execute_process(COMMAND "${CW_PATH_PROG_PS}" ${ps_wide_pid_option} 1
      RESULT_VARIABLE result
      OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/ps.out"
      ERROR_FILE "/dev/null"
    )
    file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/ps.out" RESULT REGEX "init")
    if (NOT RESULT)
      execute_process(COMMAND "${CW_PATH_PROG_PS}" ${ps_wide_pid_option}p 1
        RESULT_VARIABLE result
        OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/ps.out"
        ERROR_FILE "/dev/null"
      )
      file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/ps.out" RESULT REGEX "init")
      if (RESULT)
        set(ps_wide_pid_option ${ps_wide_pid_option}p)
      endif ()
    endif ()
    file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/ps.out")
    set(LONG_SCRIPT_NAME "${CMAKE_CURRENT_BINARY_DIR}/conf.test.this_is_a_very_long_executable_name_that_should_be_longer_than_any_other_name_including_full_path_than_will_reasonable_ever_happen_for_real_in_practise")
    file(WRITE "${LONG_SCRIPT_NAME}" "#! /bin/sh\n${CW_PATH_PROG_PS} ${ps_wide_pid_option} $$\n")
    execute_process(COMMAND chmod +x "${LONG_SCRIPT_NAME}")
    execute_process(COMMAND "${LONG_SCRIPT_NAME}"
      RESULT_VARIABLE script_result
      OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/ps.out"
      ERROR_FILE "/dev/null"
    )
    file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/ps.out" RESULT REGEX "real_in_practise")
    if (NOT RESULT)
      file(STRINGS "${CMAKE_CURRENT_BINARY_DIR}/ps.out" RESULT REGEX "that_should_be_longer")
      if (RESULT)
        message(WARNING "ps cuts off long path names, this will break executables with a long path or name that use libcwd!")
      else ()
        message(FATAL_ERROR "Cannot determine the correct ps arguments")
      endif ()
    endif ()
    file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/ps.out")
    file(REMOVE "${LONG_SCRIPT_NAME}")
    set(CW_PS_WIDE_PID_OPTION ${ps_wide_pid_option} CACHE STRING "Option argument(s) for ps to print the full command of a specified PID.")
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${CW_PS_WIDE_PID_OPTION}")
  endif ()
  set(PS_ARGUMENT ${CW_PS_WIDE_PID_OPTION} PARENT_SCOPE)
endfunction()
