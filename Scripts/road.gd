extends Node2D
class_name Road

## 책임:
## - 도로의 방향 저장
##  - 차량이 들어오면 회전하도록 경로변경

enum Direction {
    UP,
    DOWN,
}
const TOTAL_POINT: int = 12  # Crossway를 만들 수 있는 총 point 수
var _direction: Direction
    
func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered) # Replace with function body.      

func setDirection(direction: String) -> void:
    if direction == "up":
        _direction = Direction.UP
        rotation = PI
    elif direction == "down":
        _direction = Direction.DOWN
        rotation = 0
    else:       
        push_error("UP/DOWN 외의 방향이 입력됨")
    print(rotation)
    
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
    
