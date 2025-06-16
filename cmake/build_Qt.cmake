# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO

######################################################################
# Qt from source
######################################################################

message(STATUS "########## build_dependency_from_archive - Qt ##########")

set_cache (Qt_BUILD_VERSION 6.9.1 "Imath version for local builds")
set (Imath_GIT_REPOSITORY "https://github.com/AcademySoftwareFoundation/Imath")
set (Imath_GIT_TAG "v${Imath_BUILD_VERSION}")
set_cache (Imath_BUILD_SHARED_LIBS ${LOCAL_BUILD_SHARED_LIBS_DEFAULT}
           DOC "Should a local Imath build, if necessary, build shared libraries" ADVANCED)

build_dependency_from_archive(Qt
    # VERSION 6.9.1
    GIT_REPOSITORY "https://download.qt.io/archive/qt/6.9/6.9.1/single/qt-everywhere-src-6.9.1.zip"
)

# Signal to caller that we need to find again at the installed location
set (Qt_REFIND TRUE)
set (Qt_REFIND_ARGS CONFIG)
set (Qt_REFIND_VERSION ${Qt_BUILD_VERSION})
