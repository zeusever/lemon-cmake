include(LemonLua)
include(LemonTrace)
include(LemonParseArguments)
include(LemonGlobalSetting)
include(LemonSourceTree)


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
############################################################
# get the project configure files output directory
#
############################################################
function(lemon_project_configure_dir PATH RESULT)
  string(REPLACE ${PROJECT_SOURCE_DIR} ${LEMON_BUILD_TARGET_DIR} IM ${PATH}/)
  set(${RESULT} ${IM} PARENT_SCOPE)
endfunction()

############################################################
# add the win32 version macro to compiler /D 
###########################################################
function(lemon_target_flags NAME)
  lemon_project_prefix(${NAME} PREFIX)

  if(WIN32)
    if(LEMON_BUILD_TARGET_WXP)
      add_definitions(/D_WIN32_WINNT=0x0501 /D_WIN32_WINDOWS=0x0501 /DNTDDI_VERSION=NTDDI_WINXPSP3 /D_WIN32_IE=0x0603)
    elseif(LEMON_BUILD_TARGET_WNET)
      add_definitions(/D_WIN32_WINNT=0x0502 /D_WIN32_WINDOWS=0x0502 /DNTDDI_VERSION=NTDDI_WS03SP2 /D_WIN32_IE=0x0603)
    elseif(LEMON_BUILD_TARGET_WLH)
      add_definitions(/D_WIN32_WINNT=0x0600 /D_WIN32_WINDOWS=0x0600 /DNTDDI_VERSION=NTDDI_VISTASP1 /D_WIN32_IE=0x0700)
    elseif(LEMON_BUILD_TARGET_WIN7)
      add_definitions(/D_WIN32_WINNT=0x0601 /D_WIN32_WINDOWS=0x0601 /DNTDDI_VERSION=NTDDI_WIN7 /D_WIN32_IE=0x0800)
    endif()

    add_definitions(/D${PREFIX}_BUILD /WX /W4)
  else()
    add_definitions(-D${PREFIX}_BUILD)
  endif()
endfunction()

###########################################################
# @arg FILES[out]
###########################################################
function(lemon_project_info FILES NAME VERSION)
  lemon_parse_arguments(
    lemon_project_info
    PROJECT
    LEMON_ONE_VALUE_KEY PATH
    LEMON_INPUT_ARGS ${ARGN})
  if(NOT PROJECT_PATH)
    set(PROJECT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
  endif()

  set(ASSEMBLYINFO_FILE ${PROJECT_PATH}/assemblyinfo.lua)

  lemon_c_cxx_files(SRC PATH ${PROJECT_PATH})

  set(COMPILER ${LEMON_CMAKE_ROOT}/extension/assemblyinfoc.lua)

  lemon_project_configure_dir(${PROJECT_PATH} PROJECT_CONFIGURE_DIR)

  if(EXISTS ${ASSEMBLYINFO_FILE})

    set(GEN_FILES ${PROJECT_CONFIGURE_DIR}/assembly.h ${PROJECT_CONFIGURE_DIR}/assembly.cpp ${PROJECT_CONFIGURE_DIR}/errorcode.h)

    set(${FILES} ${GEN_FILES} ${ASSEMBLYINFO_FILE} PARENT_SCOPE)

    add_custom_command(
      OUTPUT ${GEN_FILES}
      #       lua.exe      compiler    metadata file        version     c/c++ output directory   
      COMMAND ${LEMON_LUA} ${COMPILER} ${ASSEMBLYINFO_FILE} ${VERSION}  ${PROJECT_CONFIGURE_DIR} ${NAME}
      DEPENDS ${COMPILER} ${SRC} ${ASSEMBLYINFO_FILE}
      COMMENT "run assembly info compiler ...")
    source_group("Include Files" FILES ${PROJECT_CONFIGURE_DIR}/assembly.h ${PROJECT_CONFIGURE_DIR}/errorcode.h)
    source_group("Source Files" FILES ${PROJECT_CONFIGURE_DIR}/assembly.cpp  ${ASSEMBLYINFO_FILE})
  endif()
endfunction()

macro(lemon_project_include)
  set(LEMON_PROJECT_INCLUDES "${LEMON_PROJECT_INCLUDES};${ARGN}" PARENT_SCOPE)
endmacro()

macro(lemon_project_link_dirs)
  set(LEMON_PROJECT_LIB_DIRS "${LEMON_PROJECT_LIB_DIRS};${ARGN}" PARENT_SCOPE)
endmacro()

macro(lemon_project_link_libs)
  set(LEMON_PROJECT_LIBS "${LEMON_PROJECT_LIBS};${ARGN}" PARENT_SCOPE)
  set(LEMON_PROJECT_LIBS "${LEMON_PROJECT_LIBS};${ARGN}")
endmacro()

############################################################
#@arg FILES[out]  the addition file add to project provide by 
#                 configure script file
#
############################################################
function(lemon_project_config FILES NAME)

  lemon_message("do lemon project<${NAME}> configure action ...")
  
  #parse the args
  lemon_parse_arguments(
    lemon_project_config
    PROJECT
    LEMON_OPTION_ARGS SHARED
    LEMON_ONE_VALUE_KEY PATH 
    LEMON_INPUT_ARGS ${ARGN})

  if(NOT PROJECT_PATH)
    set(PROJECT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  # get the current project configure file output directory
  lemon_project_configure_dir(${PROJECT_PATH} PROJECT_CONFIGURE_DIR)
  lemon_project_prefix(${NAME} PROJECT_PREFIX)

  #add the target flags
  lemon_target_flags(${NAME})

  # check if the project is a shared library project
  if(PROJECT_SHARED)
    set(${PROJECT_PREFIX}_BUILD_AS_DLL TRUE)
  endif()
  
  set(PROJECT_CONFIGURE_CMAKE ${PROJECT_PATH}/configure.cmake)
  set(PROJECT_CONFIGURE_H_IN ${PROJECT_PATH}/configure.h.in)
  set(PROJECT_CONFIGURE_H ${PROJECT_CONFIGURE_DIR}/configure.h)
  lemon_debug("generate configure.h file for project <${NAME}> :${PROJECT_CONFIGURE_H}")
  #first check if the configure.cmake exists
  if(EXISTS ${PROJECT_CONFIGURE_CMAKE})
    include(${PROJECT_CONFIGURE_CMAKE})
    lemon_debug("found configure.cmake file for project <${NAME}>")
  endif()
  file(WRITE ${PROJECT_CONFIGURE_H} "#ifndef ${PROJECT_PREFIX}_CONFIGURE_H\n")
  file(APPEND ${PROJECT_CONFIGURE_H} "#define ${PROJECT_PREFIX}_CONFIGURE_H\n\n")
  file(APPEND ${PROJECT_CONFIGURE_H} "#cmakedefine ${PROJECT_PREFIX}_BUILD_AS_DLL\n\n")
  # read the standard configure.h.in
  file(STRINGS ${LEMON_CMAKE_ROOT}/configure.h.in BUFFER NEWLINE_CONSUME)
  file(APPEND ${PROJECT_CONFIGURE_H} ${BUFFER})
  if(EXISTS ${PROJECT_CONFIGURE_H_IN})
    lemon_debug("found local configure.h.in file :${PROJECT_CONFIGURE_H_IN}")
    file(STRINGS ${PROJECT_CONFIGURE_H_IN} BUFFER NEWLINE_CONSUME)    
    file(APPEND ${PROJECT_CONFIGURE_H} ${BUFFER})
  endif()
  file(APPEND ${PROJECT_CONFIGURE_H} "#endif //${PROJECT_PREFIX}_CONFIGURE_H\n")
  configure_file(${PROJECT_CONFIGURE_H} ${PROJECT_CONFIGURE_H} IMMEDIATE)
  source_group("Include Files" FILES ${PROJECT_CONFIGURE_H})
  set(${FILES} ${PROJECT_CONFIGURE_H} ${ASSEMBLY_FILES} PARENT_SCOPE)
  lemon_message("do lemon project<${NAME}> configure action -- success")
  set(LEMON_PROJECT_INCLUDES "${LEMON_PROJECT_INCLUDES}" PARENT_SCOPE)
  set(LEMON_PROJECT_LIB_DIRS "${LEMON_PROJECT_LIB_DIRS}" PARENT_SCOPE)
  set(LEMON_PROJECT_LIBS "${LEMON_PROJECT_LIBS}" PARENT_SCOPE)

endfunction()