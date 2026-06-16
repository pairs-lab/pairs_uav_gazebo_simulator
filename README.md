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

## Flying the UAV

Switch between tmux windows with `Ctrl-b` then the window number shown in the
green status bar (`5:takeoff`, `6:goto`, `2:status`, `7:rviz`, …).

**1. Take off.** The session arms, switches to OFFBOARD, and takes off on its own
once everything is up (window `5:takeoff`). Wait until the drone is hovering —
the status panel shows the active tracker as `MpcTracker` (not `NullTracker`).
Nothing below works until the UAV is actually airborne.

**2. Command it.** Any of:

- **Status window (`2:status`)** — a keyboard cockpit:
  - `m` → menu: Takeoff / Land / Land Home
  - `g` → goto: type `x y z heading` (world frame, metres + radians)
  - `R` → remote keyboard flight: `w a s d` move, `r`/`f` up/down, `q`/`e` yaw, `Esc` to exit
- **`goto` service** from any sourced shell:
  ```bash
  rosservice call /uav1/control_manager/goto "goal: [5.0, 0.0, 3.0, 0.0]"   # x y z heading
  ```
- **RViz tools** (window `7:rviz`) — see [RViz control tools](#rviz-control-tools) below:
  - **Control Tool** — select a drone and fly it with the keyboard
  - **Plan path** — fly a smooth multi-waypoint trajectory
  - **Custom Goal** — publish a clicked pose to a topic (a hook for your own nodes)

### RViz control tools

**Control Tool** — fly the UAV directly from RViz. Select it, then:

1. **Click / drag a box over the drone** in the 3D view to select it (you can
   select several drones at once).
2. **Right-click the drone → `Takeoff` / `Land` / `Land Home`** to call that service.
3. Press **`R`** for *remote mode*, then fly with the keyboard:
   `w a s d` (or `h j k l`) move · `q`/`e` yaw · `r`/`f` up/down · `G` toggle
   global frame · `R` exit. The current mode and keys are shown at the bottom of
   the RViz window.

**Custom Goal** — click + drag a pose (like *2D Nav Goal*) and publish it as a
`geometry_msgs/PoseStamped` on the `goal` topic (topic/name editable in the tool's
properties). Nothing in the sim subscribes to `goal` by default, so it does not
move the drone on its own — it is a hook for your own node/planner to listen on.

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
