include(CTest)
include(CheckCXXCompilerFlag)
include(LemonSourceTree)
include(LemonGlobalSetting)
include(LemonProjectConfig)

if(MSVC)
    foreach(flag_var CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_RELWITHDEBINFO) 
        string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
        string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
    endforeach(flag_var)
    SET (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "MSVC C Debug MT flags " FORCE)    
    SET (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}" CACHE STRING "MSVC CXX Debug MT flags " FORCE)
    SET (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "MSVC C Release MT flags " FORCE)
    SET (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "MSVC CXX Release MT flags " FORCE)
    SET (CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}" CACHE STRING "MSVC C Debug MT flags " FORCE)    
    SET (CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}" CACHE STRING "MSVC C Release MT flags " FORCE)
    SET (CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "MSVC CXX Debug MT flags " FORCE)    
    SET (CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "MSVC CXX Release MT flags " FORCE)
else()
    CHECK_CXX_COMPILER_FLAG(-std=c++0x LEMON_CXX_COMPILER_0X)

    if(LEMON_CXX_COMPILER_0X)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")    
    endif()
    
endif()

function(lemon_solution NAME)
  if(ARGN)    
    lemon_parse_arguments(
      lemon_solution
      LEMON_SOLUTION
      LEMON_ONE_VALUE_KEY VERSION
      LEMON_INPUT_ARGS ${ARGN})
  endif()
  project(${NAME})

  if(NOT LEMON_SOLUTION_VERSION)
    set(LEMON_SOLUTION_VERSION "1.0.*")
  endif()

  set(LEMON_SOLUTION_VERSION ${LEMON_SOLUTION_VERSION} CACHE STRING "the versions tring")
  
  # scan the tools directory
  include_directories(${PROJECT_SOURCE_DIR}/thirdpart ${LEMON_BUILD_TARGET_DIR}/thirdpart)  
  lemon_scan_project("thirdpart" ${PROJECT_SOURCE_DIR}/thirdpart)

  # scan the sources directory
  include_directories(${PROJECT_SOURCE_DIR}/sources ${LEMON_BUILD_TARGET_DIR}/sources)
  lemon_scan_project("libraries" ${PROJECT_SOURCE_DIR}/sources)
  
  
  include_directories(${PROJECT_SOURCE_DIR} ${LEMON_BUILD_TARGET_DIR})
  lemon_scan_project("tools" ${PROJECT_SOURCE_DIR}/tools PREFIX tools)
  lemon_scan_project("unittest" ${PROJECT_SOURCE_DIR}/unittest PREFIX unittest)
endfunction()

#################################################################################
# get the project prefix string
# function name : lemon_project_prefix 
# function arg  : 
#                 *NAME               ; the project name
#                 *RESULT             ; the project prefix
#################################################################################
function(lemon_project_prefix NAME RESULT)
  string(REPLACE "-" "_" PREFIX ${NAME})
  string(REPLACE "+" "x" PREFIX ${PREFIX})
  string(TOUPPER ${PREFIX} PREFIX)
  set(${RESULT} ${PREFIX} PARENT_SCOPE)
endfunction()

function(lemon_set_project_output_dir TARGET)
 #redirect the output directory 
   SET_TARGET_PROPERTIES(
    ${TARGET} PROPERTIES 
    
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${PROJECT_BINARY_DIR}/build/lib/
    
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ${PROJECT_BINARY_DIR}/build/lib/
    
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${PROJECT_BINARY_DIR}/build/bin/
    )
  SET_TARGET_PROPERTIES(
    ${TARGET} PROPERTIES 
    
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${PROJECT_BINARY_DIR}/build/lib/
    
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${PROJECT_BINARY_DIR}/build/lib/
    
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${PROJECT_BINARY_DIR}/build/bin/
    )
  SET_TARGET_PROPERTIES(
    ${TARGET} PROPERTIES 
    
    ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/build/lib/
    
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/build/lib/
    
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/build/bin/
    )

  #if(PROJECT_RENAME)
    #SET_TARGET_PROPERTIES(${TARGET} PROPERTIES OUTPUT_NAME ${PROJECT_RENAME})
  #endif()
endfunction()

function(lemon_project NAME)
   lemon_parse_arguments(
    lemon_project
    PROJECT 
    LEMON_OPTION_ARGS SHARED STATIC EXE BOOTSTRAP BOOTSTRAP1
    LEMON_ONE_VALUE_KEY VERSION  RENAME
    LEMON_INPUT_ARGS ${ARGN})

  if(NOT PROJECT_VERSION)
    set(PROJECT_VERSION ${LEMON_SOLUTION_VERSION})
  endif()
  
  if(PROJECT_BOOTSTRAP)
	if(PROJECT_SHARED)
		lemon_project_config(FILES ${NAME} SHARED BOOTSTRAP)
	else()
		lemon_project_config(FILES ${NAME} BOOTSTRAP)
	endif()
  
	if(NOT PROJECT_STATIC AND WIN32)
		lemon_project_info(INFO_FILES ${NAME} ${PROJECT_VERSION} BUILD_RC)
	else()
		lemon_project_info(INFO_FILES ${NAME} ${PROJECT_VERSION})
	endif()
  else()
  
	if(PROJECT_SHARED)
		lemon_project_config(FILES ${NAME} SHARED)
	else()
		lemon_project_config(FILES ${NAME})
	endif()
	
	if(NOT PROJECT_STATIC AND WIN32)
		lemon_rc(INFO_FILES ${NAME} ${PROJECT_VERSION} ${PROJECT_BOOTSTRAP1} BUILD_RC)
	else()
		lemon_rc(INFO_FILES ${NAME} ${PROJECT_VERSION} ${PROJECT_BOOTSTRAP1})
	endif()
  
	
  endif()
  
  lemon_project_infoc(PO_FILES)

  if(LEMON_PROJECT_INCLUDES)
    include_directories(${LEMON_PROJECT_INCLUDES})
  endif()

  if(LEMON_PROJECT_LIB_DIRS)
    link_directories(${LEMON_PROJECT_LIB_DIRS})
  endif()

  if(PROJECT_SHARED)
    add_library(${NAME} SHARED ${FILES} ${INFO_FILES} ${PO_FILES} ${PROJECT_UNPARSED_ARGUMENTS})
  elseif(PROJECT_STATIC)
    add_library(${NAME} STATIC ${FILES} ${INFO_FILES} ${PO_FILES} ${PROJECT_UNPARSED_ARGUMENTS})
  else()
    add_executable(${NAME} ${PROJECT_UNPARSED_ARGUMENTS} ${FILES} ${INFO_FILES} ${PO_FILES})
  endif()
  
  
  if(PO_FILES)
	target_link_libraries(${NAME} lemon-lua)
  endif()
  
  if(NOT PROJECT_BOOTSTRAP)
	if(PROJECT_BOOTSTRAP1)
		add_dependencies(${NAME} tools-lemon-boostrap-rc)
	else()
		add_dependencies(${NAME} tools-lemon-rc)
	endif()
  endif()

  if(LEMON_PROJECT_LIBS)
    target_link_libraries(${NAME} ${LEMON_PROJECT_LIBS})
  endif()

  lemon_set_project_output_dir(${NAME})
  
  if(PROJECT_RENAME)
	set_target_properties(${NAME} PROPERTIES OUTPUT_NAME ${PROJECT_RENAME})
  endif()
 
endfunction()

function(lemon_dll_project NAME)
  lemon_project(${NAME} SHARED ${ARGN})
endfunction()

function(lemon_static_project NAME)
  lemon_project(${NAME} STATIC ${ARGN})
endfunction()

function(lemon_library_project NAME)
  if(LEMON_LIBRARY_TYPE_STATIC)
    lemon_static_project(${NAME} ${ARGN})
  else()
    lemon_dll_project(${NAME} ${ARGN})
  endif()
endfunction()

#################################################################################
# the exe project
#
#
#################################################################################
function(lemon_exe_project NAME)
  lemon_project(${NAME} EXE ${ARGN})
endfunction()

function(lemon_win32_project NAME)
  lemon_project(${NAME} WIN32 ${ARGN})
endfunction()

function(lemon_unittest_project NAME)
  #get the generate dir
  lemon_project_configure_dir(${CMAKE_CURRENT_SOURCE_DIR} DIR)
  set(MAIN_CPP ${DIR}/unittest-main.cpp)
  configure_file(${LEMON_CMAKE_ROOT}/unittest-main.cpp.in ${MAIN_CPP})
  lemon_project(${NAME} EXE ${MAIN_CPP} ${ARGN})
  # get the test target library name
  string(REPLACE "unittest-" "" TESTLIBRARY ${NAME})
  lemon_message("add unittest project for library :${TESTLIBRARY}")
  target_link_libraries(${NAME} ${TESTLIBRARY} lemonxx)
  add_test(NAME ${NAME} COMMAND ${PROJECT_BINARY_DIR}/build/bin/${NAME}${CMAKE_EXECUTABLE_SUFFIX})
endfunction()