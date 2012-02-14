include(LemonTrace)

# the lua binary install directory
set(LEMON_LUA_DIRECTORY ${PROJECT_BINARY_DIR}/lua/)
# the lua executable programe full path
set(LEMON_LUA ${LEMON_LUA_DIRECTORY}/bin/lua${CMAKE_EXECUTABLE_SUFFIX} CACHE STRING "the lua vm")

if(EXISTS ${LEMON_LUA})
  return()
endif()

lemon_message("build cmake lua extension configure tools ...")

# try compile the lua vm
try_compile(
  COMPILE_RESULT
  ${PROJECT_BINARY_DIR}/cmake/lua/sources
  ${LEMON_CMAKE_ROOT}/sources/lua/
  lua install
  CMAKE_FLAGS -DCMAKE_INSTALL_PREFIX=${LEMON_LUA_DIRECTORY} -DLEMON_CMAKE_LUA_EXTENSION=${LEMON_CMAKE_PATH}/extension/
  OUTPUT_VARIABLE COMPILER_OUTPUT_MESSAGE
  )

if(NOT COMPILE_RESULT)
  lemon_error("build cmake lua extension configure tools -failure\n${COMPILER_OUTPUT_MESSAGE}")
else()
  lemon_message("build cmake lua extension configure tools -success\n")
endif()

mark_as_advanced(LEMON_LUA)

