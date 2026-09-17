// Copyright (C) 2026 Przemyslaw Nogaj
// SPDX-License-Identifier: 0BSD

import QtQuick
import QtQuick3D
import QtQuick3D.Physics

DynamicRigidBody {
    id: root

    property bool throttle: false
    property bool reverse: false
    property bool brake: false
    property bool steerLeft: false
    property bool steerRight: false

    readonly property vector3d chassisSize: Qt.vector3d(200, 50, 400)
    readonly property real wheelBase: 240
    readonly property real trackWidth: 220
    readonly property real wheelHeight: -20
    readonly property real maxSteeringAngle: 25
    readonly property real steeringSpeed: 120
    readonly property real brakeStrength: 3000
    readonly property real reverseForce: 400000
    readonly property var gears: [
        { force: 500000, maxSpeed: 1400 },
        { force: 350000, maxSpeed: 2800 },
        { force: 250000, maxSpeed: 4200 },
        { force: 180000, maxSpeed: 5600 },
        { force: 130000, maxSpeed: 8000 }
    ]

    property int gear: 0
    property real driveForce: 0
    property real brakeFriction: 0
    property real steeringAngle: 0
    property real distanceTravelled: 0
    property bool skipNextUpdate: false

    mass: 1500
    massMode: DynamicRigidBody.MassAndInertiaTensor
    inertiaTensor: {
        const s = chassisSize.times(chassisSize);
        return Qt.vector3d(s.y + s.z, s.x + s.z, s.x + s.y).times(mass / 12);
    }
    collisionShapes: BoxShape {
        extents: root.chassisSize
    }

    Model {
        source: "#Cube"
        scale: root.chassisSize.times(0.01)
        materials: PrincipledMaterial {
            baseColor: "lightblue"
            baseColorMap: Texture {
                source: "grid.png"
            }
            roughness: 0.5
        }
    }

    Wheel {
        id: frontLeft
        position: Qt.vector3d(root.trackWidth / 2, root.wheelHeight, -root.wheelBase / 2)
        steeringAngle: root.steeringAngle
        brakeFriction: root.brakeFriction
        distanceTravelled: root.distanceTravelled
        color: "red"
    }

    Wheel {
        id: frontRight
        position: Qt.vector3d(-root.trackWidth / 2, root.wheelHeight, -root.wheelBase / 2)
        steeringAngle: root.steeringAngle
        brakeFriction: root.brakeFriction
        distanceTravelled: root.distanceTravelled
        color: "red"
    }

    Wheel {
        id: rearLeft
        position: Qt.vector3d(root.trackWidth / 2, root.wheelHeight, root.wheelBase / 2)
        driveForce: root.driveForce
        brakeFriction: root.brakeFriction
        distanceTravelled: root.distanceTravelled
    }

    Wheel {
        id: rearRight
        position: Qt.vector3d(-root.trackWidth / 2, root.wheelHeight, root.wheelBase / 2)
        driveForce: root.driveForce
        brakeFriction: root.brakeFriction
        distanceTravelled: root.distanceTravelled
    }

    function respawn(position: vector3d) {
        root.reset(position, Qt.vector3d(0, 0, 0));
        root.skipNextUpdate = true;
    }

    function updatePhysics(timestep: real) {
        // reset() is applied during the next physics frame, after the rays and velocities have
        // been sampled at the old pose. Skip that frame instead of applying stale forces.
        if (root.skipNextUpdate) {
            root.skipNextUpdate = false;
            return;
        }

        const speed = root.linearVelocity.dotProduct(root.forward);
        root.distanceTravelled += speed * timestep / 1000;

        if (root.throttle && !root.reverse) {
            const gear = Math.max(root.gear, 1);
            if (gear < root.gears.length && Math.abs(speed) > root.gears[gear - 1].maxSpeed)
                root.gear = gear + 1;
            else if (gear > 1 && Math.abs(speed) < root.gears[gear - 2].maxSpeed * 0.7)
                root.gear = gear - 1;
            else
                root.gear = gear;
        }

        let force = 0;
        let braking = root.brake ? root.brakeStrength : 0;
        if (root.throttle && root.gear > 0) {
            force = root.gears[root.gear - 1].force;
        } else if (root.reverse && speed > 100) {
            braking += root.brakeStrength * 0.4;
            root.gear = Math.min(root.gear, 0);
        } else if (root.reverse && (root.gear === -1 || Math.abs(speed) < 100)) {
            root.gear = -1;
            force = -root.reverseForce;
        } else if (!root.throttle && !root.reverse) {
            root.gear = 0;
        }
        root.driveForce = force;
        root.brakeFriction = braking;

        const steering = (root.steerLeft ? 1 : 0) - (root.steerRight ? 1 : 0);
        const targetAngle = steering * root.maxSteeringAngle;
        const delta = targetAngle - root.steeringAngle;
        const step = root.steeringSpeed * timestep / 1000;
        root.steeringAngle = Math.abs(delta) < step ? targetAngle
                                                    : root.steeringAngle + Math.sign(delta) * step;

        frontLeft.applyForces(root);
        frontRight.applyForces(root);
        rearLeft.applyForces(root);
        rearRight.applyForces(root);
    }
}
