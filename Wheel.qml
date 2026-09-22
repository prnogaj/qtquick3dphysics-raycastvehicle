// Copyright (C) 2026 Przemyslaw Nogaj
// SPDX-License-Identifier: 0BSD

import QtQuick
import QtQuick3D
import QtQuick3D.Physics

Node {
    id: root

    property real radius: 36
    property real thickness: 18
    property real restLength: 50
    property real stiffness: 30000
    property real damping: 3500
    property real sideFriction: 5000
    property real rollingFriction: 20
    property real brakeFriction: 0
    property real driveForce: 0
    property real steeringAngle: 0
    property real distanceTravelled: 0
    property alias color: material.baseColor

    Raycaster {
        id: ray
        direction: Qt.vector3d(0, -1, 0)
        maxDistance: root.restLength + root.radius + 20
        excludeParentBody: true
    }

    Node {
        id: hub
        y: root.radius - (ray.isColliding ? ray.hit.distance : ray.maxDistance)
        eulerRotation.y: root.steeringAngle

        Model {
            source: "#Cylinder"
            eulerRotation: Qt.vector3d(-root.distanceTravelled / root.radius * 180 / Math.PI, 0, 90)
            scale: Qt.vector3d(root.radius / 50, root.thickness / 100, root.radius / 50)
            materials: PrincipledMaterial {
                id: material
                baseColorMap: Texture {
                    source: "grid.png"
                }
                roughness: 0.8
            }
        }
    }

    function applyForces(body: DynamicRigidBody) {
        if (!ray.isColliding)
            return;

        const up = hub.up;
        const side = hub.right;
        const forward = hub.forward;

        const centerOfMass = body.mapPositionToScene(body.centerOfMassPosition);
        const velocity = body.linearVelocity.plus(
                    body.angularVelocity.crossProduct(root.scenePosition.minus(centerOfMass)));

        const compression = Math.max(0, root.restLength - (ray.hit.distance - root.radius));
        const suspension = compression * root.stiffness - velocity.dotProduct(up) * root.damping;
        const lateral = -velocity.dotProduct(side) * root.sideFriction;
        const longitudinal = root.driveForce
                - velocity.dotProduct(forward) * (root.rollingFriction + root.brakeFriction);

        const force = up.times(suspension).plus(side.times(lateral)).plus(forward.times(longitudinal));
        body.applyForce(force, root.scenePosition);
    }
}
