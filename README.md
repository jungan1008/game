# game
# Project Mask

Godot 게임 프로젝트. 디자인은 GPT, 코딩은 Claude, 스토리는 둘 다 한다.
규칙 전문은 [AGENTS.md](AGENTS.md). 이 파일은 **사용자(producer) 운영 안내서**다.

## 1. 최초 설정 (1회)

1. **Godot 4.4 이상** 설치 → 에디터에서 `project.godot` 열기
2. **VS Code 확장**: Claude Code · Codex (OpenAI) · godot-tools (GDScript 자동완성)
3. 커밋 훅 활성화 (이미 적용됨, 새로 clone 했을 때만): `git config core.hooksPath tools/hooks`

## 2. 역할을 부르는 법

에이전트 이름을 앞에 붙여 말한다.

| 하고 싶은 일 | 어디에 | 말하는 예 |
|---|---|---|
| 스타일 가이드·에셋 | GPT 패널 | `art-director 로 briefs/001 스타일 가이드 만들어줘` |
| 화면 설계 | GPT 패널 | `ui-designer 로 타이틀 화면 명세 써줘` |
| 구조 설계 | Claude 패널 | `game-architect 로 briefs/001 설계해줘` |
| 구현 | Claude 패널 | `gameplay-dev 로 docs/architecture/001 구현해줘` |
| 대사 데이터화 | Claude 패널 | `narrative-dev 로 handoff 007 처리해줘` |
| 검증 | Claude 패널 | `qa 로 handoff 008 검증해줘` |
| 상대에게 전달 | 받는 쪽 패널 | `collab/handoff/012 응답해줘` |

## 3. 스토리 경합 진행 (예: 메인 플롯)

1. `templates/brief.md` 를 복사해 `briefs/002-main-plot.md` 작성 (모드: 경합)
2. GPT 패널: `story-gpt 로 briefs/002 초안 써줘` · Claude 패널: `story-claude 로 briefs/002 초안 써줘` — **동시에 시켜도 된다** (서로 다른 폴더에 쓴다)
3. 둘 다 끝나면 양쪽에: `교차 리뷰 해줘`
4. 리뷰를 읽고 `templates/decision.md` 로 `collab/decisions/main-plot.md` 작성 — 병합자 지정
5. 병합자 쪽 패널: `decisions/main-plot 대로 정본에 반영해줘`

## 4. 커밋

AI 는 스스로 커밋하지 않는다. 확인 후 "커밋해줘" 라고 하면 해당 에이전트가 자기 경로만 커밋한다.
직접 커밋할 때는 `[producer] 내용` — producer 는 모든 경로를 커밋할 수 있다.

훅이 거부하는 경우:
- `영역 침범` → 다른 에이전트 파일을 건드렸다. 되돌리고 handoff 로 요청할 것
- `소유자 미지정(그레이존)` → 새 경로다. `tools/ownership.tsv` 와 AGENTS.md §3 에 소유자를 먼저 정할 것

## 5. 사용자만 하는 일

브리프 작성 · 경합 채택 · ADR 승인 · 플레이테스트 · 커밋 승인 · 서버 배포 · 시크릿(API 키) 등록

## 6. 현재 프로젝트 메모

이 저장소는 동물 보호·복원 구역을 배경으로 하는 게임 기획 프로젝트를 관리한다.
현재 핵심 컨셉은 정원/농장 관리 게임이 아니라, 보호 구역을 복원하고 확장하는 생태 보호 게임이다.

주요 문서:
- [briefs/002-shelter-reborn.md](briefs/002-shelter-reborn.md)
- [briefs/001-mask-chapter-one.md](briefs/001-mask-chapter-one.md)

