lemon_package_include(iconv.h)

if(APPLE)
	lemon_project_link_libs(iconv)
endif(APPLE)

