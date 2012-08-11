include(LemonOptions)
#declare the lemon_option
lemon_option(
  LEMON_BUILD_TARGET
  DEFAULT WXP
  VALUES WIN7 WLH WXP
  DESCRIPTION "the win32 build target version by default."
  )

lemon_option(
  LEMON_LIBRARY_TYPE
  DEFAULT STATIC
  VALUES SHARED STATIC
  DESCRIPTION "the library build type,for lemon_library_project function"
  )

# set the project build target directory
set(LEMON_BUILD_TARGET_DIR ${PROJECT_BINARY_DIR}/build/)

# open the ide folder filter
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# set the lemon-rc script directory
if(NOT LEMON_RC_SCRIPT_DIR)
	set(LEMON_RC_SCRIPT_DIR ${PROJECT_SOURCE_DIR}/tools/lemon/rc/scripts)
endif()