set(LEMON_TRACE_LEVEL message CACHE STRING "the lemon cmake modules trace message level")

set_property(CACHE LEMON_TRACE_LEVEL PROPERTY STRINGS "error;warning;message;debug")

function(lemon_error)
   message(FATAL_ERROR "[Lemon Error]\t" ${ARGN})
endfunction(lemon_error)

function(lemon_warning)
   if(${LEMON_DEBUG_LEVEL} STREQUAL "warning" OR ${LEMON_DEBUG_LEVEL} STREQUAL "message" OR ${LEMON_DEBUG_LEVEL} STREQUAL "debug")
       message(WARNING "[Lemon Warning]\t" ${ARGN})
   endif()
endfunction(lemon_warning)

function(lemon_message)
   if(${LEMON_TRACE_LEVEL} STREQUAL "message" OR ${LEMON_TRACE_LEVEL} STREQUAL "debug")
       message(STATUS "[Lemon Message]\t" ${ARGN})
   endif()
endfunction(lemon_message)

function(lemon_debug)
   if(${LEMON_TRACE_LEVEL} STREQUAL "debug")
       message(STATUS "[Lemon Debug]\t" ${ARGN})
   endif()
endfunction(lemon_debug)


function(lemon_list_print_string RESULT)
  foreach(ARG ${ARGN})
    set(ARGS "${ARGS},${ARG}")
  endforeach()
  set(${RESULT} ${ARGS} PARENT_SCOPE)
endfunction()