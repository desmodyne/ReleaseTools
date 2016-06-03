# CMakeLists.txt
#
# top-level cmake project configuration
#
# author  : stefan schablowski
# contact : stefan.schablowski@desmodyne.com
# created : 2016-06-01

cmake_minimum_required(VERSION 2.6)

# TODO: get project name from project root folder ?
# see .../code/bin/build-package for bash approach
project(dd-release)

get_filename_component(PROJECT_ROOT "${PROJECT_SOURCE_DIR}/.." REALPATH)

set(CPACK_GENERATOR                     "DEB")
set(CPACK_PACKAGE_NAME                  ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION_MAJOR         "0")
set(CPACK_PACKAGE_VERSION_MINOR         "0")
set(CPACK_PACKAGE_VERSION_PATCH         "1")

set(CPACK_PACKAGE_FILE_NAME             "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY   "DesmoDyne ReleaseTools")
set(CPACK_PACKAGE_CONTACT               "DesmoDyne <contact@desmodyne.com>")
set(CPACK_PACKAGE_DESCRIPTION_FILE      "${PROJECT_ROOT}/deploy/PackageDescription.txt")

set(CPACK_INSTALL_CMAKE_PROJECTS        "${CMAKE_CURRENT_BINARY_DIR};${PROJECT_NAME};ALL;/")
set(CPACK_OUTPUT_CONFIG_FILE            "${CMAKE_CURRENT_BINARY_DIR}/CPack${PROJECT_NAME}Config.cmake")
set(CPACK_OUTPUT_FILE_PREFIX            "${CMAKE_BINARY_DIR}/packages")

set(CPACK_DEBIAN_PACKAGE_DEPENDS        "bash, git-flow, realpath")
set(CPACK_DEBIAN_PACKAGE_SECTION        "non-free/devel")

install(DIRECTORY ${PROJECT_ROOT}/data/mirror/ DESTINATION / USE_SOURCE_PERMISSIONS)

include(CPack)

add_custom_target("${PROJECT_NAME}-package"
                  COMMAND cpack --config "${CMAKE_CURRENT_BINARY_DIR}/CPack${PROJECT_NAME}Config.cmake")
