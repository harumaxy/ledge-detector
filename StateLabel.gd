extends Label




func update(state: int) -> void:
  match state:
    Player.Ground:  
      self.text = "Ground"
    Player.Air:
      self.text = "Air"
    Player.GrabLedge:
      self.text = "GrabLedge"
    Player.Climb:
      self.text = "Climb"
    Player.ClimbHalf:
      self.text = "ClimbHalf"
