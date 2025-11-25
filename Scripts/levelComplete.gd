extends Control

var _totalCarNum: int
var _minimunCrosswayNum: int

var _arrivedCarNum: int = 0
var _succeededCarNum: int = 0
var _generatedCrosswayNum: int = 0

@onready var stars: Array[Sprite2D] = [$Stars/Star1, $Stars/Star2, $Stars/Star3]
    
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    SignalBus.car_arrived_home.connect(_on_car_arrived_home)
    SignalBus.reset_simulation.connect(func() -> void:
        _arrivedCarNum = 0
        _succeededCarNum = 0
    )
    SignalBus.Crossway_generated.connect(func() -> void: _generatedCrosswayNum += 1)
    SignalBus.Crossway_eliminated.connect(func() -> void: _generatedCrosswayNum -= 1)
    SignalBus.clear_User_Crossway.connect(func() -> void: _generatedCrosswayNum = 0)
    _displayStars(0)
    visible = false

func initializeLevel(totalCarNum: int, minimumCrosswayNum: int) -> void:
    _totalCarNum = totalCarNum
    _minimunCrosswayNum = minimumCrosswayNum

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

func _displayStars(starNum) -> void:
    for i in range(starNum):
        if i >= 3:
            break
        stars[i].visible = true
    

        
