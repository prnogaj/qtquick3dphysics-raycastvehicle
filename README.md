# RayCast3D vehicle

A raycast vehicle for Qt Quick 3D Physics, written entirely in QML. Each wheel
is a `RayCast3D` pointing down from the chassis. The distance to the ground
drives a spring-damper suspension. Tire friction and engine force are applied at
the same point.

![The vehicle driving across the terrain](doc/screenshot.webp)

## Requirements

Qt 6.13 with Qt Quick 3D and a patched Qt Quick 3D Physics.

The example uses `RayCast3D` and the `DynamicRigidBody.linearVelocity` and
`angularVelocity` properties. These are not in any Qt release yet. They are
under review in
[qt/qtquick3dphysics change 771502](https://codereview.qt-project.org/c/qt/qtquick3dphysics/+/771502).
Build Qt Quick 3D Physics from that change and install it into your Qt prefix.
The change's parent changes, listed in its relation chain, are included
automatically when you check it out.

## Build and run

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.13/gcc_64
cmake --build build
./build/raycastvehicle
```

| Key   | Action                      |
|-------|-----------------------------|
| W     | Accelerate                  |
| S     | Brake, then reverse         |
| A / D | Steer                       |
| Space | Brake                       |
| R     | Respawn                     |

## How it works

| File           | Contents                                          |
|----------------|---------------------------------------------------|
| `Main.qml`     | Window, keyboard input, follow camera             |
| `Hud.qml`      | Key hints that light up while a key is held       |
| `Vehicle.qml`  | Chassis body, automatic gearbox, steering         |
| `Wheel.qml`    | Suspension ray, spring, damper and tire forces    |
| `Terrain.qml`  | Height field and obstacles                        |

Every wheel owns a ray cast in its local space. The ray ignores the chassis it
belongs to:

```qml
RayCast3D {
    id: ray
    direction: Qt.vector3d(0, -1, 0)
    maxDistance: root.restLength + root.radius + 20
    excludeParentBody: true
}
```

`RayCast3D` updates its `hit` before `PhysicsWorld.frameDone` is emitted, so
the vehicle computes its forces from that signal. For each wheel that touches
the ground, `Wheel.applyForces()` takes the velocity of the chassis at the wheel
and splits it along the wheel's up, side and forward axes:

```qml
const compression = Math.max(0, root.restLength - (ray.hit.distance - root.radius));
const suspension = compression * root.stiffness - velocity.dotProduct(up) * root.damping;
const lateral = -velocity.dotProduct(side) * root.sideFriction;
const longitudinal = root.driveForce
        - velocity.dotProduct(forward) * (root.rollingFriction + root.brakeFriction);

const force = up.times(suspension).plus(side.times(lateral)).plus(forward.times(longitudinal));
body.applyForce(force, root.scenePosition);
```

The side and forward axes come from a child node rotated by the steering angle.
This way the front wheels push the chassis in the direction they point.

## License

[0BSD](LICENSE): use it for anything, no attribution required.
