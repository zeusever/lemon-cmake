include(LemonTrace)
include(LemonParseArguments)
include(LemonProjectConfig)

macro(lemon_package_include)
  set(LEMON_PACKAGE_INCLUDE_FILES "${LEMON_PACKAGE_INCLUDE_FILES};${ARGN}")
endmacro()

macro(lemon_package_lib)
  set(LEMON_PACKAGE_LIBS "${LEMON_PACKAGE_LIBS};${ARGN}" PARENT_SCOPE)
endmacro()

function(lemon_find_package NAME)
  #parse the input args
  lemon_parse_arguments(
    lemon_find_package
    LEMON_PACKAGE
    LEMON_ONE_VALUE_KEY REQUIRED
    LEMON_INPUT_ARGS ${ARGN}
    )
  #set the package load path
  set(LEMON_PACKAGE_CONFIG_FILE ${LEMON_CMAKE_ROOT}/package/${NAME}.cmake)

  set(LEMON_PACKAGE_ROOT ${NAME}_ROOT)

  lemon_message("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  lemon_message("~ try find library package ${NAME}")
  lemon_message("~ package configure file path :${LEMON_PACKAGE_CONFIG_FILE}")
  lemon_message("~ set env ${LEMON_PACKAGE_ROOT} to change the search path")
  lemon_message("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

  if(NOT EXISTS ${LEMON_PACKAGE_CONFIG_FILE})
    lemon_error("unknwon library package ${NAME},not found package config file")
  endif()

  if(${LEMON_PACKAGE_ROOT})
    set(LEMON_PACKAGE_SEARCH_PATH ${${LEMON_PACKAGE_ROOT}})
  elseif($ENV{LEMON_PACKAGE_ROOT})
    set(LEMON_PACKAGE_SEARCH_PATH $ENV{${LEMON_PACKAGE_ROOT}})
  endif()
  #load configure file
  include(${LEMON_PACKAGE_CONFIG_FILE})
  #try find include files
  if(LEMON_PACKAGE_INCLUDE_FILES)
    if(LEMON_PACKAGE_SEARCH_PATH)
      find_path(
	PACKAGE_${NAME}_INCLUDE_DIRS 
	NAMES ${LEMON_PACKAGE_INCLUDE_FILES}
	PATHS ${LEMON_PACKAGE_SEARCH_PATH}/include/
	NO_DEFAULT_PATH
	NO_CMAKE_ENVIRONMENT_PATH
	NO_CMAKE_PATH
	NO_SYSTEM_ENVIRONMENT_PATH
	NO_CMAKE_SYSTEM_PATH)
    else()
      find_path(
	PACKAGE_${NAME}_INCLUDE_DIRS
	NAMES ${LEMON_PACKAGE_INCLUDE_FILES})
    endif()
    #check result
    if(NOT PACKAGE_${NAME}_INCLUDE_DIRS)
      lemon_error("not found package [${NAME}] include files:${LEMON_PACKAGE_INCLUDE_FILES}")
    endif()
    lemon_message("found package [${NAME}] include files: ${PACKAGE_${NAME}_INCLUDE_DIRS}")
  endif()

  if(LEMON_PACKAGE_LIBS)
    if(LEMON_PACKAGE_SEARCH_PATH)

      find_library(
	PACKAGE_${NAME}_LIB_DIRS
	NAMES ${LEMON_PACKAGE_LIBS}
	PATHS ${LEMON_PACKAGE_SEARCH_PATH}/lib/
	NO_DEFAULT_PATH
	NO_CMAKE_ENVIRONMENT_PATH
	NO_CMAKE_PATH
	NO_SYSTEM_ENVIRONMENT_PATH
	NO_CMAKE_SYSTEM_PATH)
    else()

      find_library(
	LEMON_PACKAGE_INCLUDE_FOUND
	NAMES ${LEMON_PACKAGE_LIBS})

    endif()
    #check result
    if(NOT PACKAGE_${NAME}_LIB_DIRS)
      lemon_error("not found package [${NAME}] link libraries:${LEMON_PACKAGE_LIBS}")
    endif()    
    lemon_message("found package [${NAME}] link libraries [${LEMON_PACKAGE_LIBS}] in : ${PACKAGE_${NAME}_LIB_DIRS}")
  endif()

  set(LEMON_${NAME}_LIBS ${LEMON_PACKAGE_LIBS} PARENT_SCOPE)
  
  lemon_project_include(${PACKAGE_${NAME}_INCLUDE_DIRS})

  lemon_project_link_dirs(${PACKAGE_${NAME}_LIB_DIRS})

  lemon_project_link_libs(${LEMON_PACKAGE_LIBS})

  MARK_AS_ADVANCED(PACKAGE_${NAME}_INCLUDE_DIRS)

  MARK_AS_ADVANCED(PACKAGE_${NAME}_LIB_DIRS)

  #lemon_message("try find library package [${NAME}] -- failed")
  lemon_message("try find library package [${NAME}] -- success")
  
endfunction()