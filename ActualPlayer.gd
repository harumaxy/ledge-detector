extends MeshInstance3D


# copy visual position
func snap_to_visual_pos():
  var visual_pos = $Visual.global_position
  $Visual.position = Vector3.ZERO
  self.position = visual_pos


func _ready() -> void:
  $AnimationPlayer.play("Climb")
