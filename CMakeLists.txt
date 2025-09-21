cmake_minimum_required(VERSION 4.0)
project(SC_AirPods)
set(CMAKE_CXX_STANDARD 17)

if(APPLE OR WIN32)
  set(CMAKE_SHARED_MODULE_SUFFIX ".scx")
else()
  set(CMAKE_SHARED_MODULE_PREFIX "")
endif()

add_library(
  SC_AirPods MODULE
  src/SC_AirPods.h
  src/SC_AirPods.mm
)

set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")

# link apple APIs
find_library(COREMOTION_LIBRARY CoreMotion)
if(COREMOTION_LIBRARY)
  target_link_libraries(SC_AirPods PRIVATE ${COREMOTION_LIBRARY})
else()
  message(FATAL_ERROR "CoreMotion framework not found!")
endif()
find_library(FOUNDATION_LIBRARY Foundation)
target_link_libraries(SC_AirPods PRIVATE ${FOUNDATION_LIBRARY})

target_include_directories(SC_AirPods PUBLIC ${SC_SRC_PATH}/include/plugin_interface)
target_include_directories(SC_AirPods PUBLIC ${SC_SRC_PATH}/include/common)
target_include_directories(SC_AirPods PUBLIC ${SC_SRC_PATH}/common)

install(TARGETS SC_AirPods LIBRARY DESTINATION ${PROJECT_NAME})

file(GLOB_RECURSE SC_FILES "${CMAKE_SOURCE_DIR}/src/Classes/*.sc")
install(FILES ${SC_FILES} DESTINATION ${PROJECT_NAME}/Classes)

file(GLOB_RECURSE SCHELP_FILES "${CMAKE_SOURCE_DIR}/src/HelpSource/*.schelp")
install(FILES ${SCHELP_FILES} DESTINATION ${PROJECT_NAME}/HelpSource)
