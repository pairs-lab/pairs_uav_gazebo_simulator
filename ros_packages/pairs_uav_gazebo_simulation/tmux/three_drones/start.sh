#!/bin/bash
# Plain-tmux session script (one window per section below; panes are split and
# their commands typed via send-keys). Edit the send-keys lines to change what
# runs in each pane; ./kill.sh stops everything.

SESSION_NAME=simulation

# absolute path to this script's directory; every pane starts here
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# commands executed first in every pane
PRE_WINDOW='export RUN_TYPE=simulation; export UAV_TYPE=f450; export PLATFORM_CONFIG=`rospack find pairs_uav_gazebo_simulation`/config/pairs_uav_system/$UAV_TYPE.yaml; export CUSTOM_CONFIG=./config/custom_config.yaml; export WORLD_CONFIG=./config/world_config.yaml; export NETWORK_CONFIG=./config/network_config.yaml'
SETUP="cd $SCRIPTPATH; $PRE_WINDOW"

if [ -n "$TMUX" ]; then
  echo "Already inside tmux, detach first."
  exit 1
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Session $SESSION_NAME already exists; attach with 'tmux a -t $SESSION_NAME' or stop it with ./kill.sh."
  exit 1
fi

# ---------------- window: roscore ----------------
read W_roscore P <<< "$(tmux new-session -d -s "$SESSION_NAME" -n "roscore" -x 250 -y 50 -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'roscore' Enter
tmux select-layout -t "$W_roscore" tiled

# ---------------- window: gazebo ----------------
read W_gazebo P <<< "$(tmux new-window -t "$SESSION_NAME" -n "gazebo" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForRos; roslaunch pairs_uav_gazebo_simulation simulation.launch world_name:=grass_plane gui:=true' Enter
P=$(tmux split-window -t "$W_gazebo" -P -F '#{pane_id}')
tmux select-layout -t "$W_gazebo" tiled
tmux send-keys -t "$P" "$SETUP; "'waitForGazebo; waitForSpawn; rosservice call /pairs_drone_spawner/spawn "1 2 3 --$UAV_TYPE --enable-rangefinder"' Enter
P=$(tmux split-window -t "$W_gazebo" -P -F '#{pane_id}')
tmux select-layout -t "$W_gazebo" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForControl; gz camera -c gzclient_camera -f $UAV_NAME; history -s gz camera -c gzclient_camera -f $UAV_NAME' Enter
tmux select-layout -t "$W_gazebo" tiled

# ---------------- window: status ----------------
read W_status P <<< "$(tmux new-window -t "$SESSION_NAME" -n "status" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForHw; roslaunch pairs_uav_status status.launch' Enter
P=$(tmux split-window -t "$W_status" -P -F '#{pane_id}')
tmux select-layout -t "$W_status" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav2; waitForHw; roslaunch pairs_uav_status status.launch' Enter
P=$(tmux split-window -t "$W_status" -P -F '#{pane_id}')
tmux select-layout -t "$W_status" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav3; waitForHw; roslaunch pairs_uav_status status.launch' Enter
tmux select-layout -t "$W_status" tiled

# ---------------- window: hw_api ----------------
read W_hw_api P <<< "$(tmux new-window -t "$SESSION_NAME" -n "hw_api" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForTime; roslaunch pairs_uav_px4_api api.launch' Enter
P=$(tmux split-window -t "$W_hw_api" -P -F '#{pane_id}')
tmux select-layout -t "$W_hw_api" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav2; waitForTime; roslaunch pairs_uav_px4_api api.launch' Enter
P=$(tmux split-window -t "$W_hw_api" -P -F '#{pane_id}')
tmux select-layout -t "$W_hw_api" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav3; waitForTime; roslaunch pairs_uav_px4_api api.launch' Enter
tmux select-layout -t "$W_hw_api" tiled

# ---------------- window: core ----------------
read W_core P <<< "$(tmux new-window -t "$SESSION_NAME" -n "core" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForHw; roslaunch pairs_uav_core core.launch' Enter
P=$(tmux split-window -t "$W_core" -P -F '#{pane_id}')
tmux select-layout -t "$W_core" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav2; waitForHw; roslaunch pairs_uav_core core.launch' Enter
P=$(tmux split-window -t "$W_core" -P -F '#{pane_id}')
tmux select-layout -t "$W_core" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav3; waitForHw; roslaunch pairs_uav_core core.launch' Enter
tmux select-layout -t "$W_core" tiled

# ---------------- window: tf_connector ----------------
read W_tf_connector P <<< "$(tmux new-window -t "$SESSION_NAME" -n "tf_connector" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForTime; roslaunch pairs_tf_connector tf_connector.launch custom_config:=./config/tf_connector.yaml' Enter
tmux select-layout -t "$W_tf_connector" tiled

# ---------------- window: automatic_start ----------------
read W_automatic_start P <<< "$(tmux new-window -t "$SESSION_NAME" -n "automatic_start" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForHw; roslaunch pairs_uav_autostart automatic_start.launch' Enter
P=$(tmux split-window -t "$W_automatic_start" -P -F '#{pane_id}')
tmux select-layout -t "$W_automatic_start" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav2; waitForHw; roslaunch pairs_uav_autostart automatic_start.launch' Enter
P=$(tmux split-window -t "$W_automatic_start" -P -F '#{pane_id}')
tmux select-layout -t "$W_automatic_start" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav3; waitForHw; roslaunch pairs_uav_autostart automatic_start.launch' Enter
tmux select-layout -t "$W_automatic_start" tiled

# ---------------- window: takeoff ----------------
read W_takeoff P <<< "$(tmux new-window -t "$SESSION_NAME" -n "takeoff" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForControl; until rosservice call /$UAV_NAME/hw_api/arming 1 | grep -q "success: True"; do sleep 1; done; sleep 2; rosservice call /$UAV_NAME/hw_api/offboard' Enter
P=$(tmux split-window -t "$W_takeoff" -P -F '#{pane_id}')
tmux select-layout -t "$W_takeoff" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav2; waitForControl; until rosservice call /$UAV_NAME/hw_api/arming 1 | grep -q "success: True"; do sleep 1; done; sleep 2; rosservice call /$UAV_NAME/hw_api/offboard' Enter
P=$(tmux split-window -t "$W_takeoff" -P -F '#{pane_id}')
tmux select-layout -t "$W_takeoff" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav3; waitForControl; until rosservice call /$UAV_NAME/hw_api/arming 1 | grep -q "success: True"; do sleep 1; done; sleep 2; rosservice call /$UAV_NAME/hw_api/offboard' Enter
tmux select-layout -t "$W_takeoff" tiled

# ---------------- window: rviz ----------------
read W_rviz P <<< "$(tmux new-window -t "$SESSION_NAME" -n "rviz" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForControl; rosrun rviz rviz -d ./config/rviz.rviz' Enter
P=$(tmux split-window -t "$W_rviz" -P -F '#{pane_id}')
tmux select-layout -t "$W_rviz" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForControl; roslaunch pairs_rviz_plugins rviz_interface.launch' Enter
tmux select-layout -t "$W_rviz" tiled

# ---------------- window: rviz_uav_models ----------------
read W_rviz_uav_models P <<< "$(tmux new-window -t "$SESSION_NAME" -n "rviz_uav_models" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForControl; roslaunch pairs_rviz_plugins load_robot.launch' Enter
P=$(tmux split-window -t "$W_rviz_uav_models" -P -F '#{pane_id}')
tmux select-layout -t "$W_rviz_uav_models" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav2; waitForControl; roslaunch pairs_rviz_plugins load_robot.launch' Enter
P=$(tmux split-window -t "$W_rviz_uav_models" -P -F '#{pane_id}')
tmux select-layout -t "$W_rviz_uav_models" tiled
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav3; waitForControl; roslaunch pairs_rviz_plugins load_robot.launch' Enter
tmux select-layout -t "$W_rviz_uav_models" tiled

# ---------------- window: layout ----------------
read W_layout P <<< "$(tmux new-window -t "$SESSION_NAME" -n "layout" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'export UAV_NAME=uav1; waitForControl; sleep 3; ~/.i3/layout_manager.sh ./layout.json' Enter
tmux select-layout -t "$W_layout" tiled

# ---------------- window: kill (press enter inside to stop the session) ----------------
read W_kill P <<< "$(tmux new-window -t "$SESSION_NAME" -n "kill" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SCRIPTPATH/kill.sh"

# mouse support (select panes / scroll with the mouse)
tmux set-option -t "$SESSION_NAME" mouse on

tmux select-window -t "$W_status"
tmux -2 attach-session -t "$SESSION_NAME"
