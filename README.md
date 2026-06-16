# pairs_uav_gazebo_simulator

Gazebo simulation for the **PAIRS UAV System** — spawns one or more multirotors
in a Gazebo world wired to the full PAIRS control, estimation, and PX4 SITL
stack, so you can fly in simulation exactly as you would on real hardware.

This is the **ros2** branch (ROS 2 Jazzy, ament_cmake). For the ROS 1 Noetic
version, see the [`ros1` branch](https://github.com/pairs-lab/pairs_uav_gazebo_simulator/tree/ros1).

## Install (ROS 2 Jazzy)

```bash
# add the signed PAIRS repository (once)
curl -fsSL https://thanhnguyencanh.github.io/apt/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/pairs.gpg
echo "deb [signed-by=/usr/share/keyrings/pairs.gpg] https://thanhnguyencanh.github.io/apt jazzy main" \
  | sudo tee /etc/apt/sources.list.d/pairs.list
sudo apt update

sudo apt install ros-jazzy-pairs-uav-gazebo-simulator
```

This pulls in the whole flight stack (control, estimation, PX4 API, trackers,
controllers), so nothing else is needed to fly in simulation.

## Run

Each scenario is a tmux session under `tmux/`. Start one with its `start.sh`:

```bash
cd /opt/ros/jazzy/share/pairs_uav_gazebo_simulator/tmux/one_drone
./start.sh
```

| Session            | Scenario                                          |
|--------------------|---------------------------------------------------|
| `one_drone`        | single UAV — the default starting point           |
| `one_drone_lidar`  | single UAV with a 3D LiDAR                         |
| `two_drones`       | two UAVs for multi-robot experiments              |

The session brings up Gazebo, PX4 SITL, and the control/estimation pipeline,
then waits in a tmux window with the takeoff/goto service calls prepared. Detach
with `Ctrl-b d`; re-attach with `tmux a`.

### Configuration

Override the defaults via environment variables before `./start.sh`:

| Variable   | Default      | Meaning                      |
|------------|--------------|------------------------------|
| `UAV_NAME` | `uav1`       | ROS namespace of the UAV     |
| `UAV_TYPE` | `x500`       | airframe model to spawn      |
| `RUN_TYPE` | `simulation` | simulation vs. real-hardware |

## Flying the UAV

Switch between tmux windows with `Ctrl-b` then the window number shown in the
status bar (`takeoff`, `status`, `rviz`, …).

**1. Take off.** The session arms, switches to OFFBOARD, and takes off on its own
once everything is up. Wait until the drone is hovering — the status panel shows
the active tracker as `MpcTracker` (not `NullTracker`). Nothing below works until
the UAV is actually airborne.

**2. Command it.** Any of:

- **Status window** — a keyboard cockpit (`pairs_uav_status`):
  - `m` → menu: Takeoff / Land / Land Home
  - `g` → goto: type `x y z heading` (world frame, metres + radians)
  - `R` → remote keyboard flight: `w a s d` move, `r`/`f` up/down, `q`/`e` yaw, `Esc` to exit
- **`goto` service** from any sourced shell:
  ```bash
  ros2 service call /uav1/control_manager/goto pairs_msgs/srv/Vec4 "{goal: [5.0, 0.0, 3.0, 0.0]}"   # x y z heading
  ```
- **RViz tools**:
  - **Plan path** — fly a smooth multi-waypoint trajectory (see below)
  - **Control Tool** — click-drag a single goto in the 3D view

### Plan path (waypoint trajectories)

The **Plan path** RViz tool (the `WaypointPlanner`) lets you draw a path and have
the UAV fly the smoothed trajectory through it. To use it:

1. Make sure the UAV is **hovering** (see step 1 above).
2. Select **Plan path** in the RViz toolbar.
3. Click **several distinct waypoints** in the 3D view — each appears as an axes
   marker. The tool publishes to `<uav>/trajectory_generation/path` with *fly now*,
   so the UAV starts flying as soon as the path is sent.
4. Keep every waypoint inside the **safety area** — the default world box is
   ±50 m horizontally and `0.5–15 m` in height (`config/world_config.yaml`).

Tips:
- Place **at least two distinct waypoints away from the current position.** A
  single waypoint dropped on top of the hovering drone is a degenerate path and
  is rejected (`failed to find trajectory`).
- A goto/path is rejected with *"the path is going outside the safety area"* if
  any point leaves the box above — move the waypoints in, or widen the area in
  `world_config.yaml`.

## License
BSD 3-Clause. Derived from the CTU-MRS `pairs_uav_gazebo_simulator` package; the original
copyright is retained in [LICENSE](LICENSE).
