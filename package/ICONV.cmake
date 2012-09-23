lemon_package_check_files(iconv.h)

if(APPLE)
	lemon_package_check_libraries(iconv)
endif(APPLE)

