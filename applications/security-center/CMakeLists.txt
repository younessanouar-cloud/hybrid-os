cmake_minimum_required(VERSION 3.16)
project(hybrid-security-center LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_executable(hybrid-security-center
    src/main.cpp
    src/securitybridge.cpp
)
target_link_libraries(hybrid-security-center PRIVATE Qt6::Quick)

# Module QML embarqué dans l'exécutable (ressources qrc — Qt 6.5+)
qt_add_qml_module(hybrid-security-center
    URI org.hybridos.securitycenter
    VERSION 1.0
    QML_FILES qml/Main.qml
)

install(TARGETS hybrid-security-center DESTINATION bin)
