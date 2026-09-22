// Copyright (C) 2026 Przemyslaw Nogaj
// SPDX-License-Identifier: 0BSD

import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.Physics

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("Raycaster vehicle")

    property bool respawnPressed: false

    function handleKey(key: int, pressed: bool) {
        switch (key) {
        case Qt.Key_W:
            vehicle.throttle = pressed;
            break;
        case Qt.Key_S:
            vehicle.reverse = pressed;
            break;
        case Qt.Key_A:
            vehicle.steerLeft = pressed;
            break;
        case Qt.Key_D:
            vehicle.steerRight = pressed;
            break;
        case Qt.Key_Space:
            vehicle.brake = pressed;
            break;
        case Qt.Key_R:
            window.respawnPressed = pressed;
            if (pressed)
                vehicle.respawn(Qt.vector3d(0, 400, 0));
            break;
        }
    }

    View3D {
        anchors.fill: parent
        camera: camera
        focus: true
        Keys.onPressed: event => window.handleKey(event.key, true)
        Keys.onReleased: event => window.handleKey(event.key, false)

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.SkyBox
            lightProbe: Texture {
                textureData: ProceduralSkyTextureData {
                    sunLongitude: -115
                }
            }
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 800, 2000)
            eulerRotation.x: -45
            clipFar: 25000
        }

        PhysicsWorld {
            scene: scene
            gravity: Qt.vector3d(0, -981, 0)

            onFrameDone: timestep => {
                vehicle.updatePhysics(timestep);

                const target = vehicle.mapPositionToScene(Qt.vector3d(0, 600, 1500));
                const t = Math.min(1, timestep / 1000);
                camera.position = camera.position.times(1 - t).plus(target.times(t));
                camera.lookAt(vehicle.scenePosition);
            }
        }

        Node {
            id: scene

            DirectionalLight {
                eulerRotation.x: -45
                castsShadow: true
                shadowMapQuality: Light.ShadowMapQualityVeryHigh
                softShadowQuality: Light.PCF8
            }

            DirectionalLight {
                eulerRotation: Qt.vector3d(-45, 180, 0)
                brightness: 0.4
                color: "#cceeff"
            }

            DirectionalLight {
                eulerRotation: Qt.vector3d(-30, -30, 0)
            }

            Terrain {}

            Vehicle {
                id: vehicle
                position: Qt.vector3d(0, 200, 0)
            }
        }
    }

    Hud {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        vehicle: vehicle
        respawnPressed: window.respawnPressed
    }
}
