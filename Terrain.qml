// Copyright (C) 2026 Przemyslaw Nogaj
// SPDX-License-Identifier: 0BSD

import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.Physics

Node {
    component Block: StaticRigidBody {
        id: block
        property vector3d size: Qt.vector3d(100, 100, 100)
        property color color: "#886644"

        collisionShapes: BoxShape {
            extents: block.size
        }
        Model {
            source: "#Cube"
            scale: block.size.times(0.01)
            materials: DefaultMaterial {
                diffuseColor: block.color
            }
        }
    }

    StaticRigidBody {
        collisionShapes: HeightFieldShape {
            id: heightField
            source: "terrain_heightmap.png"
            extents: Qt.vector3d(20000, 700, 20000)
        }
        Model {
            geometry: HeightFieldGeometry {
                source: heightField.source
                extents: heightField.extents
            }
            materials: PrincipledMaterial {
                baseColor: "#886644"
                roughness: 1
            }
        }
    }

    Block {
        y: -100
        size: Qt.vector3d(20000, 200, 20000)
        color: "#4a7c23"
    }

    Block {
        position: Qt.vector3d(300, 50, 300)
    }

    Block {
        position: Qt.vector3d(800, 50, 900)
    }

    Block {
        position: Qt.vector3d(1000, -200, -1000)
        eulerRotation.x: -15
        size: Qt.vector3d(700, 500, 800)
        color: "#666666"
    }
}
