# FindPDFWriter.cmake - Find PDFWriter library in build directory
# Looks for libPDFWriter.a in deps/dist/lib and headers in deps/dist/include/PDFWriter

# Set search paths relative to current build directory
set(PDFWriter_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/deps/dist")

# Find the header directory
find_path(PDFWriter_INCLUDE_DIR
    NAMES PDFWriter.h
    PATHS "${PDFWriter_ROOT_DIR}/include/PDFWriter"
    NO_DEFAULT_PATH
    DOC "PDFWriter include directory"
)

# Find the library
find_library(PDFWriter_LIBRARY
    NAMES PDFWriter
    PATHS "${PDFWriter_ROOT_DIR}/lib"
    NO_DEFAULT_PATH
    DOC "PDFWriter library"
)

# Handle standard arguments and set PDFWriter_FOUND
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PDFWriter
    FOUND_VAR PDFWriter_FOUND
    REQUIRED_VARS PDFWriter_LIBRARY PDFWriter_INCLUDE_DIR
    FAIL_MESSAGE "Could not find PDFWriter library in ${PDFWriter_ROOT_DIR}"
)

# Create imported target if found
if(PDFWriter_FOUND AND NOT TARGET PDFWriter::PDFWriter)
    add_library(PDFWriter::PDFWriter STATIC IMPORTED)
    set_target_properties(PDFWriter::PDFWriter PROPERTIES
        IMPORTED_LOCATION "${PDFWriter_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${PDFWriter_INCLUDE_DIR}"
    )
    
    # Set standard variables for backwards compatibility
    set(PDFWriter_LIBRARIES "${PDFWriter_LIBRARY}")
    set(PDFWriter_INCLUDE_DIRS "${PDFWriter_INCLUDE_DIR}")
    
    # Debug output
    message(STATUS "Found PDFWriter:")
    message(STATUS "  Library: ${PDFWriter_LIBRARY}")
    message(STATUS "  Include: ${PDFWriter_INCLUDE_DIR}")
endif()

# Mark cache variables as advanced
mark_as_advanced(PDFWriter_INCLUDE_DIR PDFWriter_LIBRARY)