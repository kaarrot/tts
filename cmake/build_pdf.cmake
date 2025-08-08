set (pkgname pdf)
set_cache (pdf_BUILD_VERSION 1.0.0 "A placeholder version to make refind happy")

# set (_pkg_GIT_REPOSITORY https://github.com/kubaroth/pdf.git)
# set (_pkg_GIT_TAG master)
# set (_pkg_VERSION 18a3164474de38c331936146afdf9db5c9ea0db7)

# message (STATUS "Building local ${pkgname} ${_pkg_VERSION} from ${_pkg_GIT_REPOSITORY}")

# set (${pkgname}_LOCAL_SOURCE_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}")
# set (${pkgname}_LOCAL_BUILD_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}-build")
set (${pkgname}_LOCAL_INSTALL_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/dist")

set(_pkg_NOINSTALL TRUE) 

build_dependency_with_cmake(${pkgname}
    GIT_REPOSITORY  https://github.com/kubaroth/pdf.git
    GIT_TAG master  # 18a3164474de38c331936146afdf9db5c9ea0db7
    NOINSTALL   # This project has not install rule
    CMAKE_ARGS 
    -D HUMMUS_PATH=${${pkgname}_LOCAL_INSTALL_DIR}
    # to fix Catch related issues 
    -D CMAKE_CXX_FLAGS="-DCATCH_CONFIG_NO_POSIX_SIGNALS"
    )

set (${pkgname}_ROOT ${${pkgname}_LOCAL_INSTALL_DIR})
set(${pkgname}_DIR ${${pkgname}_LOCAL_INSTALL_DIR})

# Signal to caller that we need to find again at the installed location
set (${pkgname}_REFIND TRUE)
set (${pkgname}_REFIND_VERSION ${${pkgname}_BUILD_VERSION})

# set (${pkgname}_REFIND_ARGS CONFIG)

# Once the library is built Cmake looks for a module 
# Findpdf.cmake to which sets pdf_FOUND TRUE
