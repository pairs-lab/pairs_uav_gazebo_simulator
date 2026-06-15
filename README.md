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

## License
BSD 3-Clause. Derived from the CTU-MRS `pairs_uav_gazebo_simulator` package; the original
copyright is retained in [LICENSE](LICENSE).
