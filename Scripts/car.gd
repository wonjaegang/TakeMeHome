extends Node
class_name Car

## 책임:
##  - 차량의 현재 위치, 목적지 및 이동을 관리
##  - Crossway에 도달했을 때 이동요청

const SPEED: float = 1.0 
var _currentRoad: Road
var _currentPoint: int
var _home: Home
var _arrived: bool = false

func _init(startRoad: Road, home:Home) -> void:
    _currentRoad = startRoad
    _currentPoint = 0 if startRoad.getDirection() == Road.Direction.DOWN else Road.TOTAL_POINT
    _home = home
    
func _ready() -> void:
    pass # Replace with function body.

func getCurrentRoad() -> Road:
    return _currentRoad   
    
func getCurrentPosition() -> int:
    return _currentPoint 

func setNextLocation() -> void:
    pass
  
