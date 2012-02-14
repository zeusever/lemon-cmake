include(LemonTrace)
include(LemonParseArguments)

function(lemon_option_name_check NAME)
  string(REGEX MATCH "[^a-zA-Z0-9_]" FOUND ${NAME})
  if(FOUND)
    lemon_error("invalid lemon_option NAME arg :${NAME}")
  endif()
endfunction()

function(lemon_option NAME)

  lemon_option_name_check(${NAME})

  lemon_parse_arguments(
    lemon_option
    LEMON_OPTION
    LEMON_ONE_VALUE_KEY DEFAULT DESCRIPTION
    LEMON_MULTI_VALUE_KEY VALUES
    LEMON_REQUIRED_KEYS DESCRIPTION VALUES
    LEMON_INPUT_ARGS ${ARGN}
    )

  lemon_message("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  lemon_message("~ the lemon option value")
  lemon_message("~ NAME :${NAME}")
  lemon_message("~ DESCRIPTION :${LEMON_OPTION_DESCRIPTION}")
  lemon_list_print_string(RESULT ${LEMON_OPTION_VALUES})
  lemon_message("~ VALUES :${RESULT}")
  lemon_message("~ DEFAULT VALUE :${LEMON_OPTION_DEFAULT}")
  lemon_message("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

  if(NOT ${NAME})#first check if the cmake value defined
    if($ENV${${NAME}})
      set(${NAME} $ENV{${NAME}} CACHE STRING "${LEMON_OPTION_DESCRIPTION}")
    elseif(LEMON_OPTION_DEFAULT)
      list(FIND LEMON_OPTION_VALUES ${LEMON_OPTION_DEFAULT} FOUND)
      if(-1 EQUAL FOUND)
	lemon_error("the lemon_opton<${NAME}> default value must one of those values:${LEMON_OPTION_VALUES}")
      endif()
      set(${NAME} ${LEMON_OPTION_DEFAULT} CACHE STRING "${LEMON_OPTION_DESCRIPTION}")
    else()
      list(GET LEMON_OPTION_VALUES 0 RESULT)
      set(${NAME} ${DEFAULT} CACHE STRING "${LEMON_OPTION_DESCRIPTION}")
    endif()

    set_property(CACHE ${NAME} PROPERTY STRINGS "${LEMON_OPTION_VALUES}")
  endif()

  lemon_message("the global lemon_option <${NAME}>'s value is :${${NAME}}")

  set(${NAME}_${${NAME}} TRUE PARENT_SCOPE)
  
endfunction()