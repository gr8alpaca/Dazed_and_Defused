@tool
class_name TweenData extends Resource

@export_placeholder("rotation:y") var property_path: String

@export_range(0.001, 5.0, 0.05, "or_greater", "suffix:s") var duration_sec: float = 1.0
@export var start_val: float = 0.0
@export var end_val: float = 1.0

@export_group("Ease & Trans")
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var tween_trans: Tween.TransitionType = Tween.TRANS_LINEAR
