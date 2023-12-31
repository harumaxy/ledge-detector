extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 9

@export var camera: Camera3D
@export var camera_arm: Node3D
@export var camera_arm_pivot: Node3D
@export var state_label: Label
@onready var ledge_detector := $LedgeDetector as LedgeDetector

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {Ground, Air, GrabLedge, Climb, ClimbHalf}
var state := Ground:
  set(v):
    state = v
    state_label.update(state)

func ground_move(delta: float):
  # Update State
  if ledge_detector.can_grab_ledge():
    self.velocity.y = 0
    var wall_nomal = ledge_detector.get_wall_nomal()
    var grab_pos = Vector3(1, 0, 1) * (ledge_detector.get_ledge_point() + wall_nomal.normalized() * .5) + Vector3.UP * self.global_position.y
    var tw = create_tween()
    tw.tween_property(self, "basis", self.basis.looking_at(-wall_nomal), .2)
    tw.parallel().tween_property(self, "global_position",  grab_pos, .4)
    state = GrabLedge
    return
  if $CanClimbHalfRay.is_colliding() and Input.is_action_pressed("interact"):
    var height = $CanClimbHalfRay.get_collision_point().y - self.global_position.y
    var start = self.position
    var climb_up = start + Vector3.UP * height
    var climb_forward = climb_up + ($CollisionShape3D.shape as CapsuleShape3D).radius * 2 * (self.basis * Vector3(0, 0, -1)).normalized()
    state = ClimbHalf
    var tw = create_tween()
    tw.tween_property(self, "position", climb_up, .2)
    tw.tween_property(self, "position", climb_forward, .2)
    tw.tween_callback(func(): state = Ground)
    return
  
  state = Ground if self.is_on_floor() else Air
  
  
  if not is_on_floor():
    velocity.y -= gravity * delta
  if Input.is_action_just_pressed("jump") and is_on_floor():
    velocity.y = JUMP_VELOCITY
  var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  var direction := (camera_arm_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
  if direction:
    self.basis = Basis.looking_at(direction.normalized())
    velocity.x = direction.x * SPEED
    velocity.z = direction.z * SPEED
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)
    velocity.z = move_toward(velocity.z, 0, SPEED)
  
  move_and_slide()


func grab_ledge_move(delta: float):
  var input_x = sign(Input.get_axis("ui_left", "ui_right"))
  var vel_x = input_x * SPEED / 2
  var direction = self.basis * Vector3.RIGHT
  if input_x != 0:
    ledge_detector.set_can_move_ray_pos_x(vel_x * delta * 4)
  if ledge_detector.can_move(vel_x):
    velocity.x = direction.x * vel_x
    velocity.z = direction.z * vel_x
    move_and_slide()
  # Update state
  if not ledge_detector.can_grab_ledge():
    state = Ground
  if Input.is_action_just_pressed("jump"):
    self.velocity.y = JUMP_VELOCITY
    state = Ground
    ledge_detector.disable()
    get_tree().create_timer(0.2).timeout.connect(func(): ledge_detector.enable())
  if Input.is_action_pressed("canncel"):
    state = Ground
    ledge_detector.disable()
    get_tree().create_timer(0.2).timeout.connect(func(): ledge_detector.enable())
  if Input.is_action_just_pressed("interact"):
    if not ledge_detector.can_climb(): return
    var start = self.position
    var climb_up = self.position + $LedgeDetector/HandPoint.position.y * Vector3.UP
    var climb_foward = climb_up + ($CollisionShape3D.shape as CapsuleShape3D).radius * 2 * (self.basis * Vector3(0, 0, -1)).normalized() 
    state = Climb
    var tw = create_tween()
    tw.tween_property(self, "position", climb_up, .5)
    tw.tween_property(self, "position", climb_foward, .5)
    tw.tween_callback(func(): state = Ground)
  

func _physics_process(delta: float) -> void:
  match state:
    Ground:
      ground_move(delta)
    Air:
      ground_move(delta)
    GrabLedge:
      grab_ledge_move(delta)
      
  
