extends Node
## 진입 씬. 화면 구성은 docs/architecture/overview.md 확정 후 gameplay-dev 가 채운다.
## 매 프레임 할 일이 없으므로 _process 를 정의하지 않는다 (AGENTS.md §6-2).


func _ready() -> void:
	print("Project Mask 시작")
