set (pkgname PDFWriter)
set_cache (PDFWriter_BUILD_VERSION 1.0.0 "A placeholder version to make refind happy")


build_dependency_with_cmake(${pkgname}
    GIT_REPOSITORY  https://github.com/kubaroth/PDF-Writer.git
    GIT_TAG master  # 6b5a0db793157008dba97c0dcda1375322194b22
    )

set (${pkgname}_ROOT ${${pkgname}_LOCAL_INSTALL_DIR})
set(${pkgname}_DIR ${${pkgname}_LOCAL_INSTALL_DIR})

# Signal to caller that we need to find again at the installed location
set (${pkgname}_REFIND TRUE)
set (${pkgname}_REFIND_VERSION ${${pkgname}_BUILD_VERSION})

# Disable CONFIG as we provide FindPDFWriter.cmake module
# set (${pkgname}_REFIND_ARGS CONFIG)


# NOTE: if for some reason configuration fails, remove the following files to run clean build
# rm deps/dist/lib/libPDFWriter.a
# rm CMakeCache.txt
# cmake ..