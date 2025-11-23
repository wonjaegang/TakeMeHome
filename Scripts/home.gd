extends Node2D
class_name Home

## 책임:

var _homeIndex : int = -1

@onready var _wallSprite: Sprite2D = $Sprite/Wall
@onready var _carEnterArea: Area2D = $CarEnterArea

func _ready() -> void:
    _carEnterArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is Car:
        SignalBus.car_arrived_home.emit(body, _homeIndex)

func setHomeIndex(index: int) -> void:
    _homeIndex = index

func setWallTexture(texture: Texture2D) -> void:
    if _wallSprite:
        _wallSprite.texture = texture
    else:
        push_error('before setting texture, node should be added to scene tree')
