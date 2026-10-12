@AGENTS.md

# Claude 전용 메모

- Claude 쪽 에이전트는 6개다: `story-claude` · `game-architect` · `gameplay-dev` · `narrative-dev` · `backend-dev` · `qa` (`.claude/agents/`).
- 작업 지시를 받으면 **먼저 어느 에이전트의 일인지 판정**한다. AGENTS.md §3 표로 판정되지 않으면 착수하지 않고 producer 에게 묻는다.
- 한 요청이 여러 에이전트에 걸치면 §4-1 순서대로 나누어 진행하고, 단계마다 산출물을 남긴다.
- `.claude/settings.json` 이 GPT 소유 경로 쓰기와 `.env` 읽기를 막는다. 막혔다고 우회하지 말 것 — 막힌 것이 정상이다.
- Godot 실행: `godot --headless --path . --quit` (PATH 에 godot 이 있을 때). 없으면 producer 에게 에디터 실행을 요청한다.
