extends CharacterBody3D

class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 9

@export var camera: Camera3D
@export var camera_arm: Node3D
@export var camera_arm_pivot: Node3D
@onready var ledge_detector := $LedgeDetector as LedgeDetector

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {Ground, GrabLedge, Climb, ClimbHalf}
var state := Ground

func rotate_camera(delta: float) -> void:
  var x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
  var y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
  var rs_dir = Vector2(x if abs(x) > .2 else 0, y if abs(y) > .2 else 0)
  if rs_dir.length_squared() != 0:
    camera_arm_pivot.rotate_y(-rs_dir.x * delta * 2)
    camera_arm.rotate_x(rs_dir.y * delta * 2)
    camera_arm.rotation_degrees.x = clamp(camera_arm.rotation_degrees.x, -60, 60)

func ground_move(delta: float):
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
  # Update State
  if ledge_detector.can_grab_ledge():
    self.velocity.y = 0
    var wall_nomal = ledge_detector.get_wall_nomal()
    var tw = create_tween()
    tw.tween_property(self, "position", self.position + ledge_detector.get_ledge_point() - $LedgeDetector/HandPoint.global_position, .1)
    tw.parallel().tween_property(self, "basis", self.basis.looking_at(-wall_nomal), .1)
    state = GrabLedge
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
  rotate_camera(delta)
  match state:
    Ground:
      ground_move(delta)
    GrabLedge:
      grab_ledge_move(delta)
      
  
