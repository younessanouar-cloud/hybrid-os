cmake_minimum_required(VERSION 3.16)
project(hybrid-showcase LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_add_executable(hybrid-showcase
    src/main.cpp
)
target_link_libraries(hybrid-showcase PRIVATE Qt6::Quick Qt6::QuickControls2)

qt_add_qml_module(hybrid-showcase
    URI org.hybridos.showcase
    VERSION 1.0
    QML_FILES qml/Main.qml
)

install(TARGETS hybrid-showcase DESTINATION bin)
