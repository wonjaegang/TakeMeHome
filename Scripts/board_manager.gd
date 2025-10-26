extends Control
class_name BoardManager

## 책임:
##  - 게임보드의 시작 및 종료를 관리

# 현재 레벨 정보
var _chapter: int = 1
var _level: int = 1

# 현재 보드 정보
var _roads: Array[Road] = []
var _crossways: Array[Crossway] = []
var _cars: Array[Car] = []
var _homes: Array[Home] = []

func _init(chapter: int, level: int) -> void:
    _chapter = chapter
    _level = level

func _ready() -> void:
    var jsonDict = _loadLevelData("res://Config/chapter%d.json" % _chapter)
    _createBoard(jsonDict)
    
func _loadLevelData(file_path: String) -> Dictionary:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("❌ JSON 파일을 열 수 없습니다: %s" % file_path)
        return {}
  
    var content = file.get_as_text()
    file.close()

    var json = JSON.new()
    var result = json.parse(content)
    if result != OK:
        push_error("❌ JSON 파싱 실패: %s" % file_path)
        return {}    

    var data = json.get_data()
    return data

func _createBoard(jsonDict: Dictionary) -> void:
    var currentLevelData = jsonDict['levels'][currentLevel - 1]    
    
