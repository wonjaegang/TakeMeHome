extends Control
class_name LevelLoader

## 책임:
##  - 게임보드의 요소들 생성

const VIEW_X :float = 720
const VIEW_Y :float = 1280
const UPPER_OFFSET_Y : float = 50  # 보드의 중앙에서 위쪽 방향 오프셋
const ROAD_INTERVAL_X : float = 140
const ROAD_CAR_GAP : float = 40
const CROSSWAY_POINT_NUM: int = 12  # 한 road에 Crossway를 만들 수 있는 총 point 수
const CROSSWAY_INTERVAL_Y : float = 64

var _carScene : PackedScene = load("res://Scenes/CarScene.tscn")
var _roadScene : PackedScene = load("res://Scenes/RoadScene.tscn")
var _crosswayScene : PackedScene = load("res://Scenes/CrosswayScene.tscn")

var _levelData : Dictionary = {}

func _ready() -> void:    
    _createBoard(1, 2)
    
func _createBoard(chapter: int, level: int) -> void:
    _loadLevelData(chapter, level)
    _createRoads()
    _createCrossways()
    _createCars()
        
func _loadLevelData(chapter: int, level: int) -> void:
    var file_path : String = "res://Config/chapter%d.json" % chapter
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("❌ JSON 파일을 열 수 없음: %s" % file_path)
        return
  
    var content = file.get_as_text()
    file.close()

    var json = JSON.new()
    var result = json.parse(content)
    if result != OK:
        push_error("❌ JSON 파싱 실패: %s" % file_path)
        return

    _levelData = json.get_data().get('levelData')[level - 1]

func _createRoads() -> void:    
    var roadDirections : Array = _levelData.get('road')
    var roadNum = len(roadDirections)
    for index in range(roadNum):
        var road: Road = _roadScene.instantiate()
        road.setDirection(roadDirections[index])
        
        var firstRoadOffset :float = (VIEW_X - (roadNum - 1) * ROAD_INTERVAL_X) / 2
        road.position = Vector2(firstRoadOffset + ROAD_INTERVAL_X * index, VIEW_Y / 2 - UPPER_OFFSET_Y)
        if road.getDirection() == Road.Direction.DOWN:
            road.rotation = 0
        elif road.getDirection() == Road.Direction.UP:
            road.rotation = PI
        else:
            push_error('Unknown Direction')
        get_node('../Roads').add_child(road)

func _createCrossways() -> void:
    var crosswayInfos : Array = _levelData.get('crossway')
        
    for leftRoadIdx in range(get_node('../Roads').get_child_count() - 1):
        var leftRoad: Road = get_node('../Roads').get_child(leftRoadIdx)
        
        for crosswayPointIdx in range(CROSSWAY_POINT_NUM):
            var crossway: Crossway = _crosswayScene.instantiate()
            var crosswayPosX = leftRoad.position.x + ROAD_INTERVAL_X / 2
            var crosswayPosY = leftRoad.position.y - (CROSSWAY_POINT_NUM - 1) * CROSSWAY_INTERVAL_Y / 2 + crosswayPointIdx * CROSSWAY_INTERVAL_Y
            crossway.position = Vector2(crosswayPosX, crosswayPosY)
            crossway.deactivate()            
            get_node('../Crossways').add_child(crossway)
            
            for crosswayInfo: Dictionary in crosswayInfos:
                if crosswayInfo['connectedRoad'][0] == leftRoadIdx and crosswayInfo['point'] == crosswayPointIdx:
                    crossway.activateBy(Crossway.originType.SYSTEM)
    
func _createCars() -> void:
    var carPath : Array = _levelData.get('car')
    for index in range(len(carPath)):
        var car: Car = _carScene.instantiate()
        var startRoadIndex: int = carPath[index].get('start')
        var startRoad :Road = get_node('../Roads').get_child(startRoadIndex)
        
        var carPosY : float
        var carRotation : float
        var roadHalfLength : float = startRoad.get_node('CarEnterArea/CollisionShape2D').shape.extents.y
        if startRoad.getDirection() == Road.Direction.DOWN:
            carPosY = startRoad.position.y - (roadHalfLength + ROAD_CAR_GAP)
            carRotation = PI / 2
        elif startRoad.getDirection() == Road.Direction.UP:
            carPosY = startRoad.position.y + (roadHalfLength + ROAD_CAR_GAP)
            carRotation = -PI / 2
        else:
            push_error('Unknown Direction')
            
        car.position = Vector2(startRoad.position.x, carPosY)
        car.rotation = carRotation
        get_node('../Cars').add_child(car)
        
