# pairs_uav_gazebo_simulator

Gazebo simulation for the **PAIRS UAV System** — spawns one or more multirotors
in a Gazebo world wired to the full PAIRS control, estimation, and PX4 SITL
stack, so you can fly in simulation exactly as you would on real hardware.

The ROS package built from this repo is **`pairs_uav_gazebo_simulation`**.

## Branches
- `ros1` — ROS 1 Noetic (catkin)
- `ros2` — ROS 2 Jazzy (ament_cmake)

## Install (ROS 1 Noetic)
```bash
sudo apt install ros-noetic-pairs-uav-gazebo-simulation
```
This pulls in the whole flight stack (control, estimation, PX4 API, trackers,
controllers), so nothing else is needed to fly in simulation.

## Run

Each scenario is a plain-tmux session under `tmux/`. Start one with its
`start.sh`; stop it with `kill.sh` (or `Ctrl-b k`):

```bash
roscd pairs_uav_gazebo_simulation/tmux/one_drone
./start.sh
```

| Session               | Scenario                                             |
|-----------------------|------------------------------------------------------|
| `one_drone`           | single UAV — the default starting point              |
| `one_drone_realsense` | single UAV with a RealSense depth camera             |
| `one_drone_3dlidar`   | single UAV with a 3D LiDAR                            |
| `one_drone_vio`       | single UAV with a visual-inertial odometry rig       |
| `three_drones`        | three UAVs for multi-robot experiments               |

The session brings up Gazebo, PX4 SITL, and the control/estimation pipeline,
then waits in a tmux window with the takeoff/goto service calls prepared. Detach
with `Ctrl-b d`; re-attach with `tmux a`.

### Configuration

Override the defaults via environment variables before `./start.sh`:

| Variable   | Default      | Meaning                         |
|------------|--------------|---------------------------------|
| `UAV_NAME` | `uav1`       | ROS namespace of the UAV        |
| `UAV_TYPE` | `x500`       | airframe model to spawn         |
| `RUN_TYPE` | `simulation` | simulation vs. real-hardware    |

Per-session overrides live in each session's `config/` directory.

## License
BSD 3-Clause. Derived from the CTU-MRS `pairs_uav_gazebo_simulator` package; the original
copyright is retained in [LICENSE](LICENSE).
