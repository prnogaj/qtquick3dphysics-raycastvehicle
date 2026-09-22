# Raycaster vehicle

A raycast vehicle for Qt Quick 3D Physics, written entirely in QML. Each wheel
is a `Raycaster` pointing down from the chassis. The distance to the ground
drives a spring-damper suspension. Tire friction and engine force are applied at
the same point.

![The vehicle driving across the terrain](doc/screenshot.webp)

## Requirements

Qt 6.13 from the dev branch with Qt Quick 3D, and Qt Quick 3D Physics with two
changes that are still under review:

| Change | Adds |
|--------|------|
| [771501](https://codereview.qt-project.org/c/qt/qtquick3dphysics/+/771501) Expose DynamicRigidBody velocity properties | `DynamicRigidBody.linearVelocity` and `angularVelocity` |
| [771502](https://codereview.qt-project.org/c/qt/qtquick3dphysics/+/771502) Add Raycaster scene query type | `Raycaster` |

The example needs both. They are separate changes, not one chain: 771501 is
based on dev, and 771502 is based on the scene queries change
[765878](https://codereview.qt-project.org/c/qt/qtquick3dphysics/+/765878).
Checking out one does not bring in the other, so check out 771502 and
cherry-pick 771501 on top of it:

```bash
git clone https://code.qt.io/qt/qtquick3dphysics.git
cd qtquick3dphysics
git fetch https://codereview.qt-project.org/qt/qtquick3dphysics refs/changes/02/771502/4
git checkout -b raycastvehicle FETCH_HEAD
git fetch https://codereview.qt-project.org/qt/qtquick3dphysics refs/changes/01/771501/4
git cherry-pick FETCH_HEAD
```

The number at the end of each ref is the patch set, which goes up as the
changes are revised. The Download menu on each change page shows the ref of
the latest one.

Then build Qt Quick 3D Physics and install it into your Qt prefix:

```bash
mkdir build && cd build
/path/to/Qt/6.13/gcc_64/bin/qt-configure-module ..
cmake --build . --parallel
cmake --install .
```

Qt Quick 3D Physics from dev uses internal Qt Quick 3D API that changed after
6.12, so the Qt Quick 3D in that prefix has to come from dev as well.

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
Raycaster {
    id: ray
    direction: Qt.vector3d(0, -1, 0)
    maxDistance: root.restLength + root.radius + 20
    excludeParentBody: true
}
```

`Raycaster` updates its `hit` before `PhysicsWorld.frameDone` is emitted, so
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
