extends Node3D
class_name LedgeDetector

func enable():
  $UpRay.enabled = true
  $DownRay.enabled = true
  $FloorRay.enabled = true

func disable():
  $UpRay.enabled = false
  $DownRay.enabled = false
  $FloorRay.enabled = false

func can_grab_ledge():
  var is_coliding = (not $UpRay.is_colliding()) and $DownRay.is_colliding() and $FloorRay.is_colliding()
  if not is_coliding:
    return false
  var is_same_body = $DownRay.get_collider() == $FloorRay.get_collider()
  return is_same_body

func get_ledge_point():
  var h = $DownRay.get_collision_point()
  var v = $FloorRay.get_collision_point()
  return Vector3(h.x, v.y, h.z)
  
func get_wall_nomal() -> Vector3:
  return $DownRay.get_collision_normal()
  
func can_move(x_axis_value: float):
  return $CanMoveRay.is_colliding()

func can_climb():
  return $CanClimbRay.is_colliding()

func set_can_move_ray_pos_x(x):
  $CanMoveRay.position.x = x

