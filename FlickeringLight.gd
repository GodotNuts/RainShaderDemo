extends Light2D

export (float) var MaxEnergy
export (float) var MinEnergy
export (float) var FlashCount
export (int) var TimeBetweenFlashes

onready var _tween := $Tween

func _ready() -> void:
    randomize()
    for flash in FlashCount:
        _tween.interpolate_property(self, "energy", MaxEnergy, MinEnergy, randf() * 1.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT, (randi() % TimeBetweenFlashes) + 1)
        _tween.start()
        yield(_tween, "tween_all_completed")
    
