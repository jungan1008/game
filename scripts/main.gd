extends Control

const GRID_SIZE := 7
const EMPTY := 0
const PATH := 1
const SAFE := 2
const OBSTACLE := 3
const HAZARD := 4
const START := 5
const GOAL := 6

var grid_data: Array = []
var selected_tile := PATH
var cell_buttons: Array = []
var status_label: Label
var selected_tile_label: Label
var timer_label: Label
var timer_seconds := 45.0
var is_game_over := false

func _ready() -> void:
	setup_ui()
	build_board()
	update_selected_tile_label()
	update_status("첫 번째 보호 경로를 연결해 동물이 안전하게 이동하게 해주세요.")
	print("Stage 1 prototype initialized")

func setup_ui() -> void:
	custom_minimum_size = Vector2(980, 680)
	anchors_preset = PRESET_FULL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var root = VBoxContainer.new()
	root.name = "Root"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.set_anchors_preset(Control.PRESET_FULL)
	root.offset_left = 20
	root.offset_top = 20
	root.offset_right = -20
	root.offset_bottom = -20
	add_child(root)
	
	var title = Label.new()
	title.text = "입구 보호 터 - 경로 정리 퍼즐"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	
	var top_bar = HBoxContainer.new()
	top_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(top_bar)
	
	status_label = Label.new()
	status_label.text = "상태"
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_bar.add_child(status_label)
	
	timer_label = Label.new()
	timer_label.text = "남은 시간: 45.0s"
	timer_label.add_theme_font_size_override("font_size", 18)
	top_bar.add_child(timer_label)
	
	var middle = HBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(middle)
	
	var palette = VBoxContainer.new()
	palette.custom_minimum_size = Vector2(220, 0)
	palette.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_child(palette)
	
	var palette_title = Label.new()
	palette_title.text = "타일 선택"
	palette_title.add_theme_font_size_override("font_size", 18)
	palette.add_child(palette_title)
	
	var path_button = Button.new()
	path_button.text = "통로 타일"
	path_button.pressed.connect(_on_select_tile.bind(PATH))
	palette.add_child(path_button)
	
	var safe_button = Button.new()
	safe_button.text = "안전 타일"
	safe_button.pressed.connect(_on_select_tile.bind(SAFE))
	palette.add_child(safe_button)
	
	var erase_button = Button.new()
	erase_button.text = "지우기"
	erase_button.pressed.connect(_on_select_tile.bind(EMPTY))
	palette.add_child(erase_button)
	
	selected_tile_label = Label.new()
	selected_tile_label.text = "선택: 통로 타일"
	palette.add_child(selected_tile_label)
	
	var check_button = Button.new()
	check_button.text = "경로 검사"
	check_button.pressed.connect(_on_check_path)
	palette.add_child(check_button)
	
	var reset_button = Button.new()
	reset_button.text = "초기화"
	reset_button.pressed.connect(_on_reset_board)
	palette.add_child(reset_button)
	
	var board_panel = Panel.new()
	board_panel.custom_minimum_size = Vector2(520, 520)
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_child(board_panel)
	
	var board_container = GridContainer.new()
	board_container.name = "BoardGrid"
	board_container.columns = GRID_SIZE
	board_container.set_anchors_preset(Control.PRESET_FULL)
	board_container.offset_left = 20
	board_container.offset_top = 20
	board_container.offset_right = -20
	board_container.offset_bottom = -20
	board_panel.add_child(board_container)
	cell_buttons.clear()
	self.call_deferred("_assign_board_container", board_container)

func _assign_board_container(board_container: GridContainer) -> void:
	for child in board_container.get_children():
		child.queue_free()
	
	for r in range(GRID_SIZE):
		for c in range(GRID_SIZE):
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(52, 52)
			btn.flat = false
			btn.focus_mode = Control.FOCUS_NONE
			btn.pressed.connect(_on_cell_pressed.bind(r, c, btn))
			board_container.add_child(btn)
			cell_buttons.append(btn)
			update_cell_visual(btn, r, c)
	
func _on_select_tile(tile_type: int) -> void:
	selected_tile = tile_type
	update_selected_tile_label()
	update_status("타일을 선택했습니다. 빈칸에 배치해 경로를 완성하세요.")

func update_selected_tile_label() -> void:
	if selected_tile_label == null:
		return
	if selected_tile == EMPTY:
		selected_tile_label.text = "선택: 지우기"
	elif selected_tile == PATH:
		selected_tile_label.text = "선택: 통로 타일"
	elif selected_tile == SAFE:
		selected_tile_label.text = "선택: 안전 타일"
	else:
		selected_tile_label.text = "선택: 타일"

func build_board() -> void:
	grid_data.clear()
	for r in range(GRID_SIZE):
		var row: Array = []
		for c in range(GRID_SIZE):
			row.append(EMPTY)
		grid_data.append(row)
	
	# 고정된 장애물/위험 구역 생성
	var fixed_cells := {
		Vector2i(1, 3): OBSTACLE,
		Vector2i(3, 1): OBSTACLE,
		Vector2i(3, 3): OBSTACLE,
		Vector2i(3, 4): OBSTACLE,
		Vector2i(4, 5): OBSTACLE,
		Vector2i(5, 2): OBSTACLE,
		Vector2i(5, 4): OBSTACLE,
		Vector2i(2, 5): HAZARD,
		Vector2i(4, 1): HAZARD,
		Vector2i(4, 3): HAZARD,
		Vector2i(5, 5): HAZARD,
	}
	
	for pos in fixed_cells:
		var r := pos.x
		var c := pos.y
		grid_data[r][c] = fixed_cells[pos]
	
	grid_data[0][0] = START
	grid_data[6][6] = GOAL
	
	if cell_buttons.is_empty():
		return
	
	for idx in range(cell_buttons.size()):
		var r := idx / GRID_SIZE
		var c := idx % GRID_SIZE
		update_cell_visual(cell_buttons[idx], r, c)

func _on_cell_pressed(r: int, c: int, btn: Button) -> void:
	if is_game_over:
		return
	if grid_data[r][c] in [START, GOAL, OBSTACLE, HAZARD]:
		return
	if selected_tile == EMPTY:
		grid_data[r][c] = EMPTY
	else:
		grid_data[r][c] = selected_tile
	update_cell_visual(btn, r, c)
	update_status("타일을 배치했습니다. 경로를 검사해 안전 통로를 확인하세요.")

func update_cell_visual(btn: Button, r: int, c: int) -> void:
	var cell_type := grid_data[r][c]
	match cell_type:
		EMPTY:
			btn.text = ""
			btn.modulate = Color(0.9, 0.9, 0.9)
		PATH:
			btn.text = "" 
			btn.modulate = Color(0.2, 0.7, 0.9)
		SAFE:
			btn.text = ""
			btn.modulate = Color(0.2, 0.9, 0.5)
		OBSTACLE:
			btn.text = "X"
			btn.modulate = Color(0.45, 0.3, 0.25)
		HAZARD:
			btn.text = "!"
			btn.modulate = Color(0.9, 0.55, 0.2)
		START:
			btn.text = "S"
			btn.modulate = Color(0.95, 0.9, 0.35)
		GOAL:
			btn.text = "E"
			btn.modulate = Color(0.95, 0.4, 0.6)
		_:
			btn.text = ""
			btn.modulate = Color.WHITE

func _on_check_path() -> void:
	if is_valid_path():
		if safe_tile_count() >= 4 and path_tile_count() >= 6:
			update_status("안전 경로가 완성되었습니다! 보호 구역이 활성화됩니다.")
			is_game_over = true
			status_label.modulate = Color(0.2, 1.0, 0.4)
		else:
			update_status("경로는 연결되었지만, 안전 타일이 부족합니다. 더 안정적으로 연결해 주세요.")
	else:
		update_status("시작점에서 도착점까지 안전 경로가 연결되지 않았습니다. 장애물과 위험 구역을 피하세요.")
		status_label.modulate = Color(1.0, 0.5, 0.3)

func is_valid_path() -> bool:
	var queue: Array[Vector2i] = []
	var visited: Dictionary = {}
	var start_pos := Vector2i(0, 0)
	queue.append(start_pos)
	visited[start_pos] = true
	
	while not queue.is_empty():
		var current := queue.pop_front()
		if current == Vector2i(6, 6):
			return true
			
		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next_pos := current + dir
			if next_pos.x < 0 or next_pos.y < 0 or next_pos.x >= GRID_SIZE or next_pos.y >= GRID_SIZE:
				continue
			if visited.has(next_pos):
				continue
			var cell := grid_data[next_pos.x][next_pos.y]
			if cell in [OBSTACLE, HAZARD]:
				continue
			if cell in [EMPTY, PATH, SAFE, START, GOAL]:
				queue.append(next_pos)
				visited[next_pos] = true
	
	return false

func path_tile_count() -> int:
	var total := 0
	for r in range(GRID_SIZE):
		for c in range(GRID_SIZE):
			if grid_data[r][c] == PATH:
				total += 1
	return total

func safe_tile_count() -> int:
	var total := 0
	for r in range(GRID_SIZE):
		for c in range(GRID_SIZE):
			if grid_data[r][c] == SAFE:
				total += 1
	return total

func _on_reset_board() -> void:
	build_board()
	selected_tile = PATH
	update_selected_tile_label()
	is_game_over = false
	status_label.modulate = Color.WHITE
	update_status("보호 터를 다시 정리할 준비가 되었습니다.")

func update_status(text: String) -> void:
	if status_label == null:
		return
	status_label.text = text
	status_label.modulate = Color.WHITE

func _process(delta: float) -> void:
	if is_game_over:
		return
	timer_seconds -= delta
	if timer_seconds <= 0.0:
		timer_seconds = 0.0
		timer_label.text = "남은 시간: 0.0s"
		update_status("시간이 종료되었습니다. 다시 정리해 보세요.")
		is_game_over = true
		return
	timer_label.text = "남은 시간: %.1fs" % timer_seconds
