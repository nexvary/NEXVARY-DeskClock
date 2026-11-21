cmake_minimum_required(VERSION 3.22)
project(NexvaryDeskClock VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(CTest)

# --- Core simulation library (zero Qt dependency) ---
add_library(aeroradar_core STATIC
    core/simulation/src/Simulator.cpp
)
target_include_directories(aeroradar_core PUBLIC core/simulation/include)
target_compile_features(aeroradar_core PUBLIC cxx_std_20)

if(MSVC)
    target_compile_options(aeroradar_core PRIVATE /W4)
else()
    target_compile_options(aeroradar_core PRIVATE -Wall -Wextra -Wpedantic)
endif()

# --- CLI app ---
add_executable(aeroradar_cli apps/cli/main.cpp)
target_link_libraries(aeroradar_cli PRIVATE aeroradar_core)

# --- Unit tests ---
# AERO_REQUIRE macros survive NDEBUG; run in both Debug and Release.
if(BUILD_TESTING)
    add_executable(simulator_tests tests/unit/SimulatorTests.cpp)
    target_link_libraries(simulator_tests PRIVATE aeroradar_core)
    target_include_directories(simulator_tests PRIVATE tests)
    add_test(NAME simulator_tests COMMAND simulator_tests)
endif()

# --- Desktop Qt app (requires Qt 6.5+, disabled by default) ---
option(AERORADAR_BUILD_DESKTOP "Build optional Qt desktop shell" OFF)
if(AERORADAR_BUILD_DESKTOP)
    find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2)
    qt_standard_project_setup(REQUIRES 6.5)

    qt_add_executable(aeroradar_desktop
        apps/desktop/main.cpp
        apps/desktop/SimulatorModel.cpp
    )
    target_include_directories(aeroradar_desktop PRIVATE apps/desktop)
    qt_add_qml_module(aeroradar_desktop URI AeroRadar VERSION 1.0
        QML_FILES ui/qml/Main.qml)
    target_link_libraries(aeroradar_desktop PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        aeroradar_core)

    if(MSVC)
        target_compile_options(aeroradar_desktop PRIVATE /W4)
    else()
        target_compile_options(aeroradar_desktop PRIVATE -Wall -Wextra)
    endif()
endif()
