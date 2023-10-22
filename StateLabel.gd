extends Label

@export var player : Player


func _process(delta: float) -> void:
  match player.state:
    Player.Ground:
      if player.is_on_floor():
        self.text = "Ground"
      else:
        self.text = "Air"
    Player.GrabLedge:
      self.text = "GrabLedge"
    Player.Climb:
      self.text = "Climb"
    Player.ClimbHalf:
      self.text = "ClimbHalf"
