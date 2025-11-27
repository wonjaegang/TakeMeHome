extends Node2D
class_name LevelComplete

const STAR_ANIMATION_DURATION: float = 0.3

var _totalCarNum: int
var _minimunCrosswayNum: int

var _arrivedCarNum: int = 0
var _succeededCarNum: int = 0
var _generatedCrosswayNum: int = 0

@onready var _stars: Array[Sprite2D] = [$Stars/Star1, $Stars/Star2, $Stars/Star3]
@onready var _playAgainButton: ClickAnimationButton = $PlayAgainButton
@onready var _nextLevelButton: ClickAnimationButton = $NextLevelButton

var _starInitialScales: Array[Vector2] = []
    
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for star in _stars:
        _starInitialScales.append(star.scale)
        
    SignalBus.Crossway_generated.connect(_on_crossway_generated)
    SignalBus.Crossway_eliminated.connect(_on_crossway_eliminated)
    SignalBus.clear_User_Crossway.connect(_on_clear_user_crossway)
    SignalBus.reset_simulation.connect(_on_reset_simulation)
    SignalBus.car_arrived_home.connect(_on_car_arrived_home)
    _playAgainButton.pressed.connect(_on_play_again_button_pressed)
    _nextLevelButton.pressed.connect(_on_next_level_button_pressed)
    visible = false

func _on_crossway_generated() -> void:
    _generatedCrosswayNum += 1

func _on_crossway_eliminated() -> void:
    _generatedCrosswayNum -= 1

func _on_clear_user_crossway() -> void:
    _generatedCrosswayNum = 0

func initializeLevel(totalCarNum: int, minimumCrosswayNum: int) -> void:
    _totalCarNum = totalCarNum
    _minimunCrosswayNum = minimumCrosswayNum

func _on_reset_simulation() -> void:
    _arrivedCarNum = 0
    _succeededCarNum = 0

func _on_car_arrived_home(_car: Car, isSucceeded: bool) -> void:
    _arrivedCarNum += 1
    if isSucceeded:
        _succeededCarNum += 1

    if _arrivedCarNum < _totalCarNum:
        return
    
    if _succeededCarNum >= _totalCarNum:
        _showLevelCompletePopup()
    else:
        SignalBus.reset_simulation.emit()

func _showLevelCompletePopup() -> void:
    var starNum: int = _calcualteStarNum()
    _displayStars(starNum)
    visible = true

func _calcualteStarNum() -> int:
    var difference : int = _generatedCrosswayNum - _minimunCrosswayNum
    if difference >= 3:
        return 1
    elif difference >= 1:
        return 2
    elif difference >= 0:
        return 3
    else:
        return 4

func _displayStars(starNum: int) -> void:
    for star in _stars:
        star.scale = Vector2.ZERO
        
    var tween = create_tween()
    for i in range(starNum):
        if i >= _stars.size():
            break
            
        var star = _stars[i]
        var target_scale = _starInitialScales[i]        
        tween.tween_property(star, "scale", target_scale, STAR_ANIMATION_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_play_again_button_pressed() -> void:
    get_tree().reload_current_scene()

func _on_next_level_button_pressed() -> void:
    pass
    

        
