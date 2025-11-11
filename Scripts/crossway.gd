extends Node2D
class_name Crossway

## 책임:
##  - 차량이 들어오면 회전하도록 경로변경

signal makeEnteredCarTurn(car: Car, angle: float, radius: float)

func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return
        
    var car: Car = body    
    var angle: float = car.position.x - position.x
    var radius: float = 30
    
    var dPos: Vector2 = car.position - position
    if dPos.x >= 0 and dPos.y <= 0:
        angle = 90
    elif dPos.x < 0 and dPos.y <= 0:
        angle = -90
    elif dPos.x < 0 and dPos.y > 0:
        angle = 90
    else:
        angle = -90
        
    makeEnteredCarTurn.emit(car, angle, radius)
    
 
    
    
    
    
