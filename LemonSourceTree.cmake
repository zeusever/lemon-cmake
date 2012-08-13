include(LemonTrace)
include(LemonParseArguments)
######################################################
# this function add the source group to the input file
#
######################################################
function(lemon_file_source_group ROOT_NAME PATH FILE)
  get_filename_component(NAME ${FILE} NAME)
  string(REPLACE ${NAME} "" DIRECTORY ${FILE})
  file(RELATIVE_PATH DIRECTORY ${PATH} ${DIRECTORY})
  file(TO_NATIVE_PATH "${DIRECTORY}" DIRECTORY)
  lemon_debug("${FILE} source_group :${ROOT_NAME}\\${DIRECTORY}")
  source_group("${ROOT_NAME}\\${DIRECTORY}" FILES ${FILE})
endfunction()

###########################################
# scan the path to find files
#
##########################################
function(lemon_scan_files RESULT NAME PATH)

  lemon_parse_arguments(
    lemon_scan_files 
    SCAN
    LEMON_ONE_VALUE_KEY IGNORE_REGULAR_EXPRESSION
    LEMON_MULTI_VALUE_KEY PATTERNS
    LEMON_INPUT_ARGS ${ARGN})
  if(NOT SCAN_PATTERNS)
    set(SCAN_PATTERNS *.*)
  endif()

  unset(FILES)
  unset(FOUND)
  unset(OUTPUT)

  foreach(PATTERN ${SCAN_PATTERNS})
    file(GLOB_RECURSE FOUND ${PATH}/${PATTERN})
    list(APPEND FILES ${FOUND})
  endforeach()

  foreach(FILE ${FILES})
    if(SCAN_IGNORE_REGULAR_EXPRESSION)
      string(REGEX MATCH ${SCAN_IGNORE_REGULAR_EXPRESSION} FOUND ${FILE})
      if(NOT FOUND)
	list(APPEND OUTPUT ${FILE})
	lemon_file_source_group(${NAME} ${PATH} ${FILE})
      endif()
    else()
      list(APPEND OUTPUT ${FILE})
      lemon_file_source_group(${NAME} ${PATH} ${FILE})
    endif()
   
  endforeach()

  # set the output files
  set(${RESULT} ${OUTPUT} PARENT_SCOPE)
  
endfunction()

function(lemon_c_cxx_files RESULT)
  #parse the input args
  lemon_parse_arguments(
    lemon_c_cxx_files
    FILES 
    LEMON_ONE_VALUE_KEY PATH DIR
    LEMON_INPUT_ARGS ${ARGN})
  # if not supply PATH arg,then set FILES_PATH to ${CMAKE_CURRENT_SOURCE_DIR}
  if(NOT FILES_PATH)
    set(FILES_PATH ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
 
  # 
  lemon_scan_files(FILES "Include Files\\${FILES_DIR}" ${FILES_PATH} PATTERNS *.h *.hpp *.hxx)

  list(APPEND TEMP  "${FILES}")
  lemon_scan_files(FILES "Source Files\\${FILES_DIR}" ${FILES_PATH} PATTERNS  *.c *.cpp *.cc *.cxx)
  list(APPEND TEMP  "${FILES}")

  set(${RESULT} ${TEMP} PARENT_SCOPE)

endfunction()

function(lemon_scan_project NAME PATH)
  lemon_parse_arguments(
    lemon_scan_project 
    PROJECT
    LEMON_ONE_VALUE_KEY PREFIX
    LEMON_INPUT_ARGS ${ARGN})
  # first search CMakeLists.txt files
  file(GLOB_RECURSE PROJECTS ${PATH}/CMakeLists.txt)
  # check if there are valid projects
  foreach(PROJECT ${PROJECTS})
    # get the directory of CMakeLists.txt file 
    string(REPLACE "CMakeLists.txt" "" DIRECTORY ${PROJECT})
    lemon_debug("found CMakeLists.txt file in directory :${DIRECTORY}")
    # add the directory
    add_subdirectory(${DIRECTORY})
    # get project name
    file(RELATIVE_PATH PROJECT_NAME ${PATH} ${DIRECTORY})
    # get the filter string
    file(RELATIVE_PATH FILTER ${PATH} ${DIRECTORY})

    string(REGEX REPLACE "/[^/]*$" "" FILTER ${FILTER})

    if(NOT PROJECT_PREFIX)
      string(REGEX REPLACE "[/\\]" "-" PROJECT_NAME ${PROJECT_NAME})
    else()
      string(REGEX REPLACE "[/\\]" "-" PROJECT_NAME ${PROJECT_PREFIX}-${PROJECT_NAME})
    endif()
    lemon_debug("project <${PROJECT_NAME}> filter name <${FILTER}>")
    # set the target filter folder
    if(TARGET ${PROJECT_NAME})
      lemon_debug("library filter <${PROJECT_NAME}> :${NAME}/${FILTER}")
      set_property(TARGET ${PROJECT_NAME} PROPERTY FOLDER ${NAME}/${FILTER})
    endif()
  endforeach()
endfunction()