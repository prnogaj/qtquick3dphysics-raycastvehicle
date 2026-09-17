# Copyright (C) 2026 Przemyslaw Nogaj
# SPDX-License-Identifier: 0BSD

cmake_minimum_required(VERSION 3.16)
project(raycastvehicle LANGUAGES CXX)

find_package(Qt6 6.13 REQUIRED COMPONENTS Quick Quick3D Quick3DPhysics)
qt_standard_project_setup(REQUIRES 6.13)

qt_add_executable(raycastvehicle
    main.cpp
)

qt_add_qml_module(raycastvehicle
    URI RayCastVehicleExample
    QML_FILES
        Hud.qml
        Main.qml
        Terrain.qml
        Vehicle.qml
        Wheel.qml
    RESOURCES
        grid.png
        terrain_heightmap.png
)

set_target_properties(raycastvehicle PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(raycastvehicle PRIVATE
    Qt::Quick
    Qt::Quick3D
    Qt::Quick3DPhysics
)
