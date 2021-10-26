cmake_minimum_required(VERSION 3.14)

set(CVPG_GUI_VERSION_MAJOR 0)
set(CVPG_GUI_VERSION_MINOR 1)
set(CVPG_GUI_VERSION_PATCH 0)
set(CVPG_GUI_VERSION "${CVPG_GUI_VERSION_MAJOR}.${CVPG_GUI_VERSION_MINOR}.${CVPG_GUI_VERSION_PATCH}")

project(cv-playground-gui VERSION ${CVPG_GUI_VERSION} LANGUAGES CXX)

include(FetchContent)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QML_IMPORT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/qml")

# fetch cv-playground library from GitHub
FetchContent_Declare(
    cv-playground
    GIT_REPOSITORY "https://github.com/franz-alt/cv-playground.git"
    GIT_TAG "0.1.0"
)

FetchContent_GetProperties(cv-playground)

# disable default enabled option to build libcvpg with FFmpeg support
set(BUILD_WITH_FFMPEG OFF CACHE BOOL "" FORCE)

if(NOT cv-playground_POPULATED)
    FetchContent_Populate(cv-playground)

    message(STATUS "libcvpg source dir: ${cv-playground_SOURCE_DIR}")
    message(STATUS "libcvpg binary dir: ${cv-playground_BINARY_DIR}")

    add_subdirectory(${cv-playground_SOURCE_DIR} ${cv-playground_BINARY_DIR})
endif()

FetchContent_MakeAvailable(cv-playground)

# fetch asynchronous library from GitHub
FetchContent_Declare(
    asynchronous
    GIT_REPOSITORY "https://github.com/henry-ch/asynchronous.git"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    #INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_BINARY_DIR}/boost/source/asynchronous" "${Boost_INSTALL_DIR}/include/boost/asynchronous"
)

FetchContent_MakeAvailable(asynchronous)

# add include files from asynchronous
include_directories(${asynchronous_SOURCE_DIR})

FetchContent_Declare(
    chaiscript
    GIT_REPOSITORY "https://github.com/ChaiScript/ChaiScript.git"
    GIT_TAG "v6.1.0"
)

FetchContent_MakeAvailable(chaiscript)

include_directories(SYSTEM ${chaiscript_SOURCE_DIR}/include)

find_package(PNG REQUIRED)
find_package(Boost REQUIRED COMPONENTS program_options system thread)

find_package(QT NAMES Qt6 Qt5 COMPONENTS Core Quick REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Quick REQUIRED)

# create a CMake definition for the build timestamp and project version
string(TIMESTAMP BUILD_TIMESTAMP "%Y-%m-%d, %H:%M:%S")
add_definitions(-DBUILD_TIMESTAMP="${BUILD_TIMESTAMP}" -DCVPG_GUI_VERSION="${CVPG_GUI_VERSION}")

set(PROJECT_SOURCES
    editor.qrc
    src/document_handler.cpp
    src/file_io.cpp
    src/filter_image_item.cpp
    src/main.cpp
    src/syntax_highlighter.cpp
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
else()
    add_executable(${PROJECT_NAME}
        ${PROJECT_SOURCES}
    )
endif()

add_library(Boost::asynchronous INTERFACE IMPORTED GLOBAL)
set_target_properties(Boost::asynchronous PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${Boost_INCLUDE_DIRS})

cmake_policy(SET CMP0071 NEW)  # allow automoc from 'generated' source, the boost installed headers in this case

set(ASYNC_QT_DIR "${asynchronous_SOURCE_DIR}/boost/asynchronous/extensions/qt/")
set(ASYNC_QT_HEADERS "${ASYNC_QT_DIR}/qt_servant.hpp")

add_custom_command(OUTPUT ${ASYNC_QT_HEADERS} DEPENDS libcvpg)

add_library(Boost_asynchronous_qt STATIC EXCLUDE_FROM_ALL ${ASYNC_QT_HEADERS})
set_target_properties(Boost_asynchronous_qt PROPERTIES AUTOMOC ON)
target_link_libraries(Boost_asynchronous_qt PUBLIC Boost::boost Qt5::Core Boost::asynchronous)
add_library(Boost::asynchronous::qt ALIAS Boost_asynchronous_qt)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${cv-playground_SOURCE_DIR}/src
)

target_link_directories(${PROJECT_NAME}
    PRIVATE
        ${cv-playground_BINARY_DIR}
)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        libcvpg
        png
        ${Boost_LIBRARIES}
        Boost::asynchronous::qt
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(${PROJECT_NAME})
    qt_finalize_executable(${PROJECT_NAME})
endif()
