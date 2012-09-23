include(LemonTrace)
include(LemonParseArguments)
include(LemonProjectConfig)

macro(lemon_package_check_files)
  set(LEMON_PACKAGE_CHECK_FILES "${LEMON_PACKAGE_CHECK_FILES};${ARGN}")
endmacro()

macro(lemon_package_check_libraries)
  set(LEMON_PACKAGE_CHECK_LIBRARIES "${LEMON_PACKAGE_CHECK_LIBRARIES};${ARGN}")
endmacro()

function(lemon_find_package NAME)
  #parse the input args
  lemon_parse_arguments(
  lemon_find_package 
  LEMON_PACKAGE 
  LEMON_OPTION_ARGS REQUIRED
  LEMON_ONE_VALUE_KEY SCRIPT
  LEMON_INPUT_ARGS ${ARGN})

  # set the package find script
  if(NOT LEMON_PACKAGE_SCRIPT)
    set(LEMON_PACKAGE_SCRIPT ${LEMON_CMAKE_ROOT}/package/${NAME}.cmake)
  endif()

  set(LEMON_PACKAGE_ROOT ${NAME}_ROOT)

  lemon_message("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  lemon_message("~ try find library package ${NAME}")
  lemon_message("~ package configure file path :${LEMON_PACKAGE_SCRIPT}")
  lemon_message("~ set env ${LEMON_PACKAGE_ROOT} to change the package search path")
  lemon_message("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

  # check if the package script file exist
  if(NOT EXISTS ${LEMON_PACKAGE_SCRIPT})
    lemon_error("not found package config file :${LEMON_PACKAGE_SCRIPT}")
  endif()

  if(${LEMON_PACKAGE_ROOT})
    set(LEMON_PACKAGE_SEARCH_PATH ${${LEMON_PACKAGE_ROOT}})
  elseif($ENV{LEMON_PACKAGE_ROOT})
    set(LEMON_PACKAGE_SEARCH_PATH $ENV{${LEMON_PACKAGE_ROOT}})
  endif()

  # load configure file
  include(${LEMON_PACKAGE_SCRIPT})

  # check the header files
  if(LEMON_PACKAGE_CHECK_FILES)
    
    if(LEMON_PACKAGE_SEARCH_PATH)
      
      find_path(
        PACKAGE_${NAME}_INCLUDE_DIR
        NAMES LEMON_PACKAGE_CHECK_FILES
        PATHS ${LEMON_PACKAGE_SEARCH_PATH}/include/
        NO_DEFAULT_PATH
        NO_CMAKE_ENVIRONMENT_PATH
        NO_CMAKE_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
        NO_CMAKE_SYSTEM_PATH)

    else(LEMON_PACKAGE_SEARCH_PATH)

       find_path(
        PACKAGE_${NAME}_INCLUDE_DIR
        NAMES LEMON_PACKAGE_CHECK_FILES)

    endif(LEMON_PACKAGE_SEARCH_PATH)

    if(LEMON_PACKAGE_REQUIRED AND NOT PACKAGE_${NAME}_INCLUDE_DIR)
      lemon_error("not found package ${NAME} header files: ${LEMON_PACKAGE_CHECK_FILES}")
    endif()

  endif(LEMON_PACKAGE_CHECK_FILES)

  # check the link libraries
  if(LEMON_PACKAGE_CHECK_LIBRARIES)

    if(LEMON_PACKAGE_SEARCH_PATH)
      find_library(
        PACKAGE_${NAME}_LIB_DIRS
        NAMES ${LEMON_PACKAGE_CHECK_LIBRARIES}
        PATHS ${LEMON_PACKAGE_SEARCH_PATH}/lib/
        NO_DEFAULT_PATH
        NO_CMAKE_ENVIRONMENT_PATH
        NO_CMAKE_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
        NO_CMAKE_SYSTEM_PATH)

    else()

      find_library(
        PACKAGE_${NAME}_LIB_DIRS
        NAMES ${LEMON_PACKAGE_CHECK_LIBRARIES})

    endif()

    if(LEMON_PACKAGE_REQUIRED AND NOT PACKAGE_${NAME}_LIB_DIRS)
      lemon_error("not found package ${NAME} link libraries: ${LEMON_PACKAGE_CHECK_LIBRARIES}")
    endif()

  endif(LEMON_PACKAGE_CHECK_LIBRARIES)

  lemon_project_include(${PACKAGE_${NAME}_INCLUDE_DIR})

  lemon_project_link_dirs(${PACKAGE_${NAME}_LIB_DIRS})

  lemon_project_link_libs(${LEMON_PACKAGE_CHECK_LIBRARIES})

  lemon_message("try find library package [${NAME}] -- success")

endfunction()