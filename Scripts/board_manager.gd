extends Control
class_name BoardManager

# 현재 레벨 정
var currentChapter = 1
var currentLevel = 1

# 현재 보드 정보
var cars = []
var roads = []
var crossways = []

func _ready():
    var jsonDict = _loadLevelData("res://Config/chapter%d.json" % currentChapter)
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
    
