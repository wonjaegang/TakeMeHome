extends Control
class_name BoardManager

# 퍼즐 보드 데이터
var road_direction = []
var cars = []
var bridges = []
var bridge_state = []

# 애니메이션 관련
var animating = false

# 결과 콜백 시그널
signal puzzle_finished(success: bool)


func _ready():
    # JSON 데이터 로드
    _load_board_data("res://data/board_data.json")


func _load_board_data(path: String) -> void:
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var json_data = JSON.parse_string(file.get_as_text())
        if typeof(json_data) == TYPE_DICTIONARY:
            road_direction = json_data.get("roadDirection", [])
            cars = json_data.get("Cars", [])
            bridges = json_data.get("Bridges", [])
            bridge_state = json_data.get("BridgeState", [])
            print("Board initialized ✅")
        else:
            push_error("Invalid JSON format in %s" % path)
    else:
        push_error("Failed to load JSON file: %s" % path)


# 사용자가 '제출' 버튼을 눌렀을 때 호출
func on_submit_pressed():
    if animating:
        return
    animating = true
    print("Playing solution animation...")

    # 예시: 애니메이션 재생 후 결과 판정
    await _play_solution_animation()
    var success = _check_solution()

    # 결과 표시
    if success:
        print("🎉 Puzzle Solved!")
    else:
        print("❌ Puzzle Failed.")

    emit_signal("puzzle_finished", success)
    animating = false


# 유저 풀이 애니메이션 재생 (단순 예시)
func _play_solution_animation() -> void:
    for car in cars:
        # 실제로는 Tween이나 AnimationPlayer를 이용
        print("Car moving: ", car)
        await get_tree().create_timer(0.3).timeout


# 성공/실패 판정 (간단한 예시)
func _check_solution() -> bool:
    # 예: 모든 bridge_state가 true면 성공
    for state in bridge_state:
        if not state:
            return false
    return true
