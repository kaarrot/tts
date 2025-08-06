# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO

######################################################################
# Qt from source
######################################################################

macro (build_dependency_from_archive pkgname)
    cmake_parse_arguments(_pkg   # prefix
        # noValueKeywords:
        "NOINSTALL"
        # singleValueKeywords:
        "URL_PATH;VERSION"
        # multiValueKeywords:
        "CMAKE_ARGS"
        # argsToParse:
        ${ARGN})

    message (STATUS "Building local ${pkgname} ${_pkg_VERSION} from ${_pkg_URL_PATH}")

    if (MSVC)
        set(archive_ext "zip")
        set(unzip_flags "-xzf")
        set(archive_extension_regex ".*\\.zip$")
        set(NPROC 16)

      else()
        set(archive_ext "tar.xz")
        set(unzip_flags "-xf")
        set(archive_extension_regex ".*\\.tar\\.xz$")
        set(NPROC 4)
    endif()

    
    set (${pkgname}_ARCHIVE "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}.${archive_ext}")
    set (${pkgname}_LOCAL_SOURCE_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}")
    set (${pkgname}_LOCAL_BUILD_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}-build")
    set (${pkgname}_LOCAL_INSTALL_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/dist")
    message (STATUS "Downloading local ${_pkg_URL_PATH}")

    set (_pkg_quiet OUTPUT_QUIET)

    message(STATUS "Downloading local${${pkgname}_LOCAL_SOURCE_DIR}")

    if(NOT EXISTS ${${pkgname}_ARCHIVE})
        file(DOWNLOAD ${_pkg_URL_PATH} ${${pkgname}_ARCHIVE} SHOW_PROGRESS STATUS status LOG log)
        if(NOT status EQUAL 0)
            message(FATAL_ERROR "Failed to download ${_pkg_URL_PATH}: ${log}")
        endif()
    endif()
    
    if(NOT IS_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})
        message(STATUS "Extract into: ${${pkgname}_LOCAL_SOURCE_DIR}")

        execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar ${unzip_flags} ${${pkgname}_ARCHIVE}
          WORKING_DIRECTORY ${${PROJECT_NAME}_LOCAL_DEPS_ROOT}
          # ${${pkgname}_LOCAL_SOURCE_DIR}
          ${_pkg_quiet}
          )

        
        # TODO: this only works as we have one folder and one file in directory
        file(GLOB extracted_dirs "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/*")
        list(FILTER extracted_dirs EXCLUDE REGEX ${archive_extension_regex})
        message(STATUS "Rename: ${extracted_dirs} to ${${pkgname}_LOCAL_SOURCE_DIR}") # Qt
        
        file(RENAME ${extracted_dirs} ${${pkgname}_LOCAL_SOURCE_DIR})

        if(NOT IS_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})
            message(FATAL_ERROR "Failed to extract ${${pkgname}_ARCHIVE}")
        endif()
    endif()


    if (MSVC)
        MESSAGE(STATUS "Configure MSVC build with configure_msvc_x64.ps1")
      # Copy powershell environment setup and configuration script. Required to setup x64 environment
      execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/configure_msvc_x64.ps1 ${${pkgname}_LOCAL_SOURCE_DIR}
        ${_pkg_quiet}
        )
      # TODO: Find a better way to cleanup this
      message(STATUS "Future reconfigure will not remove the deps folder - this needs to be removed manually")
      message(STATUS "In order to rerun configuration step remove CMakeCache.txt and configure.summary")
      
      if(NOT EXISTS "${${pkgname}_LOCAL_SOURCE_DIR}/CMakeCache.txt")
        message(STATUS "Configure using configure_msvc_x64.ps1 ")

        execute_process(
          COMMAND powershell .\\configure_msvc_x64.ps1 "-InstallPrefix ${${pkgname}_LOCAL_INSTALL_DIR}"
          WORKING_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR}
          )
      endif()
      
    else()
      MESSAGE(STATUS "Configure Linux build with configure, install to: ${${pkgname}_LOCAL_INSTALL_DIR}")

      if(NOT EXISTS "${${pkgname}_LOCAL_SOURCE_DIR}/CMakeCache.txt")
        execute_process(
          COMMAND ${CMAKE_COMMAND} ${${pkgname}_LOCAL_SOURCE_DIR} -DCMAKE_BUILD_TYPE=Release -DCMAKE_BUILD_PARALLEL_LEVEL=4 -DBUILD_qtdeclarative=ON -DBUILD_qtmultimedia=ON -DBUILD_qtimageformats=ON -DFEATURE_alsa=ON -DFEATURE_pulseaudio=ON -DFEATURE_jpeg=ON -DFEATURE_png=ON -DFEATURE_gif=ON -DFEATURE_ico=ON -DFEATURE_sql=OFF -DFEATURE_network=OFF -DFEATURE_concurrent=OFF -DFEATURE_xml=OFF -DFEATURE_printsupport=OFF -DBUILD_qtwebengine=OFF -DBUILD_qtspeech=OFF -DBUILD_qt3d=OFF -DBUILD_qttools=OFF -DBUILD_qtdoc=OFF -DBUILD_qttranslations=OFF -DBUILD_qtnetworkauth=OFF -DBUILD_qtserialport=OFF -DBUILD_qtserialbus=OFF -DBUILD_qtpositioning=OFF -DBUILD_qtlocation=OFF -DBUILD_qtwebsockets=OFF -DBUILD_qtwebchannel=OFF -DBUILD_qtremoteobjects=OFF -DBUILD_qtscxml=OFF -DBUILD_qtsensors=OFF -DBUILD_qtcharts=OFF -DBUILD_qtdatavis3d=OFF -DBUILD_qtvirtualkeyboard=OFF -DBUILD_qtquick3d=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${${pkgname}_LOCAL_INSTALL_DIR}
          WORKING_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR}
          )
       endif()

    endif()

    message(STATUS "Run Qt insource build")
    # Run Qt in-source build
    execute_process (COMMAND
        ${CMAKE_COMMAND} --build ${${pkgname}_LOCAL_SOURCE_DIR} --parallel ${NPROC} --target install
        WORKING_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR}
    )

    set (${pkgname}_ROOT ${${pkgname}_LOCAL_INSTALL_DIR})
    set(Qt6_DIR ${pkgname}_ROOT)  # Important - used to find Qt installation
    list (APPEND CMAKE_PREFIX_PATH ${${pkgname}_LOCAL_INSTALL_DIR}/lib/cmake/Qt6)

endmacro ()


message(STATUS "########## build_dependency_from_archive - Qt ##########")

set_cache (Qt_BUILD_VERSION 6.9.1 "Imath version for local builds")
set (Imath_GIT_REPOSITORY "https://github.com/AcademySoftwareFoundation/Imath")
set (Imath_GIT_TAG "v${Imath_BUILD_VERSION}")
set_cache (Imath_BUILD_SHARED_LIBS ${LOCAL_BUILD_SHARED_LIBS_DEFAULT}
           DOC "Should a local Imath build, if necessary, build shared libraries" ADVANCED)

if(MSVC)
  set(archive_url "https://download.qt.io/archive/qt/6.9/6.9.1/single/qt-everywhere-src-6.9.1.zip")
else()
  set(archive_url "https://download.qt.io/archive/qt/6.9/6.9.1/single/qt-everywhere-src-6.9.1.tar.xz")
endif()

build_dependency_from_archive(Qt6
    # VERSION 6.9.1
    URL_PATH ${archive_url}
)

# Signal to caller that we need to find again at the installed location
set (Qt6_REFIND TRUE)
set (Qt6_REFIND_ARGS CONFIG)
set (Qt6_REFIND_VERSION ${Qt_BUILD_VERSION})

