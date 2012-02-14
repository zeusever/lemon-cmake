# add the cmake directory to the cmake module search path
list(APPEND CMAKE_MODULE_PATH ${LEMON_CMAKE_ROOT})

include(LemonTrace)
include(LemonFindPackage)
include(LemonParseArguments)
include(LemonGlobalSetting)
include(LemonSourceTree)
include(LemonSolution)