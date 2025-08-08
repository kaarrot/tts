cmake_minimum_required(VERSION 3.20)

project(TTSApp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable progress reporting
set(CMAKE_MESSAGE_LOG_LEVEL STATUS)

# Fix MSVC compiler flag conflicts
if(MSVC)
    # Remove conflicting flags
    string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    
    # Set consistent flags for different build types
    set(CMAKE_CXX_FLAGS_RELEASE "/O2 /DNDEBUG")
    set(CMAKE_CXX_FLAGS_DEBUG "/Od /D_DEBUG")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/O2 /DNDEBUG")
endif()

list(APPEND CMAKE_MODULE_PATH 
    "${CMAKE_SOURCE_DIR}/cmake"
    "${CMAKE_SOURCE_DIR}/cmake/modules"
)

include(dependency_utils)

checked_find_package(Qt6 REQUIRED)

# Set Qt6 paths
# set(Qt6_ROOT "C:/Users/kuba/PRJ/tts/__build_vscode_RelWithDebInfo_MSVC/deps/dist")
# set(CMAKE_PREFIX_PATH 
#     "${Qt6_ROOT}"
#     ${CMAKE_PREFIX_PATH}
# )

# Enable Qt MOC, RCC, and UIC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6 components
find_package(Qt6 REQUIRED COMPONENTS 
    Core 
    Gui 
    Qml 
    Quick 
    Multimedia
)

checked_find_package(PDFWriter REQUIRED)
checked_find_package(pdf)  # Just download to access text.h


# Add executable
add_executable(TTSApp
    main.cpp
    tts.h
    tts.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/deps/pdf/src/text_visitor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/deps/pdf/src/resources_visitor.cpp
   
)

# TODO
# if(CMAKE_SYSTEM_NAME STREQUAL "Android")

# TODO
# if(NOT EXISTS ${CEREVOICE_INCLUDE_DIR})


message(STATUS "pdf include dir:${CMAKE_CURRENT_BINARY_DIR}/deps/pdf/src"
)
target_include_directories(TTSApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/include  # cerevoice
    ${CMAKE_CURRENT_BINARY_DIR}/deps/pdf/src  # text.h
)

# Add CereProc TTS library directories
target_link_directories(TTSApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/static  # cerevoice
    ${CMAKE_CURRENT_BINARY_DIR}/deps/dist/lib # PDFWriter
)

message(STATUS "Qt6 found: ${Qt6_FOUND}")
message(STATUS "Qt6Core found: ${Qt6Core_FOUND}")
message(STATUS "Qt6Gui found: ${Qt6Gui_FOUND}")
message(STATUS "Qt6Qml found: ${Qt6Qml_FOUND}")
message(STATUS "Qt6Quick found: ${Qt6Quick_FOUND}")
message(STATUS "Qt6Multimedia found: ${Qt6Multimedia_FOUND}")

# Link Qt libraries
target_link_libraries(TTSApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
    # CereProc TTS libraries (order matters for static linking)
    -Wl,--start-group
    cerevoice_pmod
    cerevoice_eng
    cerevoice
    cerehts
    -Wl,--end-group
    # PDF libraries (required by text.h)
    -Wl,--start-group
    PDFWriter
    FreeType
    LibAesgm
    LibPng
    LibTiff
    LibJpeg
    Zlib
    -Wl,--end-group
)

# Copy main.qml to build directory
add_custom_command(
    TARGET TTSApp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/main.qml
        ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/main.qml
)

# Copy TTS data files to build directory
add_custom_command(
    TARGET TTSApp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/file_data/license_eng.lic
        ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/license_eng.lic
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/file_data/tts_eng.voice
        ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/tts_eng.voice
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/file_data/curious_character.pdf
        ${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/curious_character.pdf
)


