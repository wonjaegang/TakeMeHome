extends Node2D
class_name Road

## 책임:
## - 도로의 방향 저장

enum Direction {
    UP,
    DOWN,
}
const TOTAL_POINT: int = 12  # 상단, 하단 점을 포함한 총 point 수
var _direction: Direction
    
func _ready() -> void:
    pass # Replace with function body.      

func setDirection(direction: String) -> void:
    _direction = Direction.UP if direction == "up" else Direction.DOWN
    
func getDirection() -> Direction:
    return _direction
