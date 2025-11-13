extends Node2D
class_name Road

## 책임:
## - 도로의 방향 저장
##  - 차량이 들어오면 회전하도록 경로변경

enum Direction {
    UP,
    DOWN,
}
var _direction: Direction
    
func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered) # Replace with function body.      

func setDirection(direction: String) -> void:
    _direction = Direction.UP if direction == "up" else Direction.DOWN
    
func getDirection() -> Direction:
    return _direction

func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return      
        
    var car: Car = body 
    if not car.getHasEnteredRoad():
        car.setHasEnteredRoad(true)
        return
       
    var angle: float
    var radius: float = 25
    
    var dPos: Vector2 = car.position - position
    if dPos.x >= 0 and _direction == Direction.UP:
        angle = PI / 2
    elif dPos.x >= 0 and _direction == Direction.DOWN:
        angle = -PI / 2
    elif dPos.x < 0 and _direction == Direction.UP:
        angle = -PI / 2
    elif dPos.x < 0 and _direction == Direction.DOWN:   
        angle = PI / 2
    else:
        return
        
    SignalBus.make_enteredCar_turn.emit(car, angle, radius)
    
