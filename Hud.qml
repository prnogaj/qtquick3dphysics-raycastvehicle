// Copyright (C) 2026 Przemyslaw Nogaj
// SPDX-License-Identifier: 0BSD

import QtQuick

Rectangle {
    id: root

    required property Vehicle vehicle
    property bool respawnPressed: false

    implicitWidth: row.implicitWidth + 24
    implicitHeight: row.implicitHeight + 12
    radius: height / 2
    color: "#80000000"

    component KeyCap: Rectangle {
        id: keyCap
        property alias text: keyLabel.text
        property bool pressed: false

        implicitWidth: Math.max(implicitHeight, keyLabel.implicitWidth + 12)
        implicitHeight: 24
        radius: 4
        color: pressed ? "white" : "transparent"
        border.color: "white"

        Text {
            id: keyLabel
            anchors.centerIn: parent
            color: keyCap.pressed ? "black" : "white"
            font.pixelSize: 12
            font.bold: true
        }
    }

    component Caption: Text {
        height: 24
        rightPadding: 10
        verticalAlignment: Text.AlignVCenter
        color: "white"
        font.pixelSize: 12
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        KeyCap {
            text: "W"
            pressed: root.vehicle.throttle
        }
        Caption {
            text: qsTr("Throttle")
        }
        KeyCap {
            text: "S"
            pressed: root.vehicle.reverse
        }
        Caption {
            text: qsTr("Brake / reverse")
        }
        KeyCap {
            text: "A"
            pressed: root.vehicle.steerLeft
        }
        KeyCap {
            text: "D"
            pressed: root.vehicle.steerRight
        }
        Caption {
            text: qsTr("Steer")
        }
        KeyCap {
            text: qsTr("Space")
            pressed: root.vehicle.brake
        }
        Caption {
            text: qsTr("Brake")
        }
        KeyCap {
            text: "R"
            pressed: root.respawnPressed
        }
        Caption {
            text: qsTr("Respawn")
            rightPadding: 0
        }
    }
}
