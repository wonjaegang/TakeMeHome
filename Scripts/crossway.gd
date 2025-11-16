extends Node2D
class_name Crossway

## 책임:
##  - 차량이 들어오면 회전하도록 경로변경

var isDragging: bool = false

func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered)
    $TouchArea.input_event.connect(_on_input_event)
    
func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return
    
    var car: Car = body    
    var angle: float
    var radius: float
    
    var dPos: Vector2 = car.position - position
    radius = abs(dPos.y)
    if dPos.x >= 0 and dPos.y <= 0:
        angle = PI / 2
    elif dPos.x < 0 and dPos.y <= 0:
        angle = -PI / 2
    elif dPos.x < 0 and dPos.y > 0:
        angle = PI / 2
    else:
        angle = -PI / 2
        
    SignalBus.make_enteredCar_turn.emit(car, angle, radius)

func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
    if event is InputEventMouseButton:
        if event.pressed:
            _showPreviewCrossway()
            isDragging = true
        else:
            _showUserCrossway()
            
    if event is InputEventMouseMotion:
        if event.button_mask:
            _showPreviewCrossway()
            isDragging = true

func deactivate() -> void:
    $CarEnterArea.monitoring = false
    $CarEnterArea.monitorable = false
    
func _activate() -> void:
    $CarEnterArea.monitoring = true
    $CarEnterArea.monitorable = true

func showLevelCrossway() -> void:
    $TileMap/RoadOverlap.visible = true
    $TileMap/LevelCrossway.visible = true
    _activate()
    
func _showUserCrossway() -> void:
    $TileMap/RoadOverlap.visible = true
    $TileMap/UserCrossway.visible = true
    _activate()

func _showPreviewCrossway() -> void:
    $TileMap/RoadOverlap.visible = true
    $TileMap/PreviewCrossway.visible = true
