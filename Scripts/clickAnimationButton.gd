extends Button
class_name ClickAnimationButton

const PRESSED_SCALE: Vector2 = Vector2(0.85, 0.85)
const ORIGINAL_SCALE: Vector2 = Vector2(1.0, 1.0)
const ANIMATION_DURATION: float = 0.1

var _tween: Tween

func _ready() -> void:
    pivot_offset = size / 2
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)

func _on_button_down() -> void:
    if _tween:
        _tween.kill()
    _tween = create_tween()
    _tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    _tween.tween_property(self, "scale", PRESSED_SCALE, ANIMATION_DURATION)

func _on_button_up() -> void:
    if _tween:
        _tween.kill()
    _tween = create_tween()
    _tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    _tween.tween_property(self, "scale", ORIGINAL_SCALE, ANIMATION_DURATION)