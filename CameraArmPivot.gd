extends Node3D

@export var mouse_sensitivity = 0.05
@export var mouse_y_reversed = true

func rotate_camera(delta: float, input: Vector2) -> void:
  if input.length_squared() != 0:
    self.rotate_y(-input.x * delta * 2)
    $CameraArm.rotate_x(input.y * delta * 2)
    $CameraArm.rotation_degrees.x = clamp($CameraArm.rotation_degrees.x, -60, 60)

func get_input(delta: float):
  var joy_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
  var joy_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
  var joy_input = Vector2(joy_x if abs(joy_x) > .2 else 0, joy_y if abs(joy_y) > .2 else 0)
  
  if joy_input.length_squared() != 0:
    return joy_input
    
  var mouse_vel = Input.get_last_mouse_velocity() * delta * mouse_sensitivity
  if mouse_y_reversed:
    mouse_vel.y *= -1
  return mouse_vel

func _process(delta: float) -> void:
  rotate_camera(delta, get_input(delta))
