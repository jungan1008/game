# AGENTS.md — Project Mask

GPT(Codex)와 Claude(Claude Code)가 **함께 읽는 단일 규칙 파일**이다.
Claude 는 `CLAUDE.md` 의 `@AGENTS.md` 로 같은 내용을 읽는다. 공용 규칙은 여기에만 쓴다 — 두 벌로 두면 반드시 어긋난다.

## 1. 프로젝트

| 항목 | 내용 |
|---|---|
| 장르 | 게임 |
| 엔진 | Godot 4.4+ · GDScript |
| 디자인 | GPT |
| 코딩 | Claude |
| 스토리 | GPT · Claude 둘 다 (브리프가 경합/단독 모드를 정한다) |
| 최종 결정권 | **producer = 사용자.** 채택·승인·커밋·배포·시크릿은 사용자만 한다 |

## 2. 역할 — 9개

| 에이전트 | 소속 | 책임 | 하지 않는 것 |
|---|---|---|---|
| `producer` | 사용자 | 브리프 작성, 경합 채택, ADR 승인, 플레이테스트, 커밋·배포, 시크릿 관리 | — |
| `story-gpt` | GPT | 스토리 초안 · 교차 리뷰 · (병합자 지정 시) 정본 반영 | 대사 데이터 파일, 채택 결정 |
| `art-director` | GPT | 비주얼·오디오 방향, 스타일 가이드, 에셋 명세·제작·배치(assets/) | 씬에 배치, UI 레이아웃 |
| `ui-designer` | GPT | 화면 흐름, 화면별 명세, HUD·메뉴 상태 정의 | 새 색 발명(스타일 가이드 소관), 씬 구현 |
| `story-claude` | Claude | story-gpt 와 동일 (Claude 쪽 작가) | 대사 데이터 파일, 채택 결정 |
| `game-architect` | Claude | 씬 구조·시그널 계약·데이터 스키마·autoload 허가·서버 필요성 ADR | **코드를 쓰지 않는다** |
| `gameplay-dev` | Claude | 씬·스크립트·게임 데이터·project.godot 구현 (**UI 구현 포함**) | 테스트, 설계 변경, 스토리 문장 |
| `narrative-dev` | Claude | 정본 스토리 → `data/narrative/` 데이터화 | 문장 수정, 대화 시스템 코드 |
| `backend-dev` | Claude | `server/` — **승인된 ADR 이 있을 때만** | 배포, 시크릿 값 다루기 |
| `qa` | Claude | 테스트·리뷰·비용/보안/중복 점검 | **코드를 고치지 않는다** (보고만) |

세부 프로세스는 각 정의 파일에 있다: `.claude/agents/*.md`, `.codex/agents/*.toml`.

## 3. 소유 경로 — 그레이존 0

`tools/ownership.tsv` 가 **단일 출처**이고, 커밋 훅(`tools/hooks/commit-msg`)이 커밋할 때마다 대조한다.
- 커밋 메시지의 `[에이전트]` 와 변경 파일의 소유자가 다르면 **커밋이 거부된다.**
- 표에 없는 경로는 **누구도 커밋할 수 없다.** 새 폴더가 필요하면 producer 가 표에 먼저 소유자를 넣는다.
- 읽기는 누구나 자유. 쓰기만 소유자.

| 경로 | 소유자 |
|---|---|
| `AGENTS.md` `CLAUDE.md` `README.md` `.claude/` `.codex/` `tools/` `templates/` `briefs/` | producer |
| `design/visual/` `design/audio/` `assets/` `icon.svg` | art-director |
| `design/ui/` | ui-designer |
| `collab/drafts/gpt/` `collab/reviews/gpt/` | GPT 쪽 에이전트 |
| `collab/drafts/claude/` `collab/reviews/claude/` | Claude 쪽 에이전트 |
| `collab/handoff/` `collab/decisions/` | 누구나 (형식 규칙 §4-4, §4-2 ⑤) |
| `story/canon/` | story-gpt · story-claude — **결정 기록에 병합자로 지정된 쪽만** |
| `docs/architecture/` `docs/adr/` | game-architect |
| `project.godot` `export_presets.cfg` `scenes/` `scripts/` `data/game/` `addons/` | gameplay-dev |
| `data/narrative/` | narrative-dev |
| `server/` | backend-dev |
| `tests/` `qa/` | qa |

### 헷갈리는 경계 판정

| 상황 | 담당 |
|---|---|
| UI 시안·상태 정의 / UI 씬·테마 구현 | ui-designer / gameplay-dev |
| 이미지 제작·`assets/` 배치 / 그 이미지를 씬에 붙이기 | art-director / gameplay-dev |
| 셰이더 효과의 시각 명세 / 셰이더 코드 | art-director / gameplay-dev |
| 대사 문장 / 대사 데이터 파일 | 정본(story) / narrative-dev — **데이터화 중 문장을 고치지 않는다** |
| 버그 발견 / 버그 수정 | qa / gameplay-dev |
| 구조 변경 | game-architect ADR → producer 승인 → gameplay-dev |
| 서버 필요 여부 / 서버 구현 | game-architect ADR / backend-dev |
| 애드온(테스트 프레임워크 포함) 설치 | gameplay-dev (qa 는 handoff 로 요청) |
| Godot 가 만드는 `.import` `.uid` 파일 | 원본 리소스의 소유자 |
| 규칙 파일 변경 | producer. AI 는 handoff 로 제안 |
| 이 표로도 판정이 안 되는 일 | **착수하지 않고 producer 에게 묻는다.** 임의 배정 금지 |

**남의 경로를 고쳐야 하면 고치지 않는다.** handoff 를 쓴다.

## 4. 작업 흐름

### 4-1. 기능 개발

```
① producer      briefs/NNN-<topic>.md (templates/brief.md)
        │
   ┌────┴─────────────────┐                      ← 병렬 (경로가 겹치지 않음)
② art-director·ui-designer   ③ game-architect
   design/ 명세                 docs/architecture/ 설계 (+ 서버 필요 시 ADR)
   └────┬─────────────────┘
④ 계약 확인    game-architect 가 설계의 "디자인 의존" 항목과 design/ 명세를 대조 → 불일치는 handoff
        │
   ┌────┴────────────┐                           ← 병렬
⑤ gameplay-dev      ⑥ narrative-dev
   씬·스크립트          data/narrative/
   └────┬────────────┘
⑦ qa           qa/reports/ — Blocking 0 이어야 통과
⑧ producer     플레이테스트 → 커밋
```

### 4-2. 스토리 — 경합 모드 (GPT·Claude 동시 작업)

```
① producer      브리프 (모드: 경합)
② 독립 초안      story-gpt → collab/drafts/gpt/<topic>.md
                story-claude → collab/drafts/claude/<topic>.md
                ※ 상대 초안을 보지 않고 쓴다 — 먼저 본 쪽이 따라가면 두 안을 받는 의미가 없다
③ 교차 리뷰      각자 상대 초안 + 자기 초안을 같은 기준표로 채점 → collab/reviews/<쪽>/<topic>.md
④ 반론 (1회)    상대 리뷰가 내 초안을 오독·사실 오류로 평가했을 때만, 자기 리뷰 파일 끝에. 1회로 끝
⑤ producer 결정  collab/decisions/<topic>.md — 채택안 / 접목할 요소 / 병합자
⑥ 병합          병합자만 story/canon/ 에 반영. 결정에 없는 개선 금지
⑦ narrative-dev 데이터화
```

**평가 기준표** (각 1–5점, 점수마다 근거 한 줄)

| 기준 | 질문 |
|---|---|
| 브리프 부합 | 브리프의 요구 항목을 빠짐없이 충족하는가 |
| 정본 일관성 | 기존 `story/canon/` 과 모순이 없는가 |
| 플레이 동기 | 플레이어가 다음으로 가고 싶어지는가 (읽는 재미 ≠ 하는 재미) |
| 구현 비용 | 새 씬·캐릭터·에셋이 몇 개 필요한가 (적을수록 높은 점수) |
| 독창성 | 흔한 전개를 피했는가 |

**경합은 비용이 두 배다.** 세계관·메인 플롯·챕터 구성·주요 캐릭터처럼 되돌리기 어려운 결정에만 쓴다.

### 4-3. 스토리 — 단독 모드

브리프의 `작가` 가 초안 → 다른 쪽 작가가 리뷰 1회 → 작가 반영 → producer 승인 → 작가가 정본 반영.
대사 다듬기·서브 이벤트·아이템 설명은 단독 모드.

### 4-4. 의견 교환 — handoff

GPT 와 Claude 는 서로 직접 말할 수 없다. **파일로 주고받고, 사용자가 전달한다.**

- 파일: `collab/handoff/NNN-<보낸이>-to-<받는이>-<제목>.md` (templates/handoff.md). NNN = 기존 최대 번호 + 1
- 보낸이는 `## 요청` 만, 받는이는 `## 응답` 만 쓴다. 상대 섹션을 고치지 않는다
- 받는이가 거절할 수 있다. 거절에는 이유와 대안을 쓴다. 합의가 안 되면 `## 결정 필요` 로 producer 에게
- 사용자 전달 예: GPT 패널에 "collab/handoff/012 응답해줘"

경합이 아닌 기능 작업에서도 양쪽 의견이 갈리면(예: UI 명세 vs 구현 비용) 4-2 의 ②–⑤를 그대로 쓴다.

## 5. 충돌 방지

1. 자기 경로만 쓴다 → 같은 브랜치에서 동시에 일해도 같은 파일을 건드리지 않는다.
2. `git add` 는 **자기 경로만 지정**한다. `git add -A`·`git add .` 금지 — 상대의 미완성 작업이 섞인다.
3. 작업 시작 전 `git status` 로 다른 쪽 미커밋 변경을 확인하고 건드리지 않는다.
4. 커밋 메시지 첫 줄: `[에이전트명] 내용` — 예: `[gameplay-dev] 플레이어 이동 구현`
5. **커밋은 producer 가 요청할 때만.** AI 가 자율로 커밋·푸시하지 않는다.

## 6. 코딩 규칙 — 비용·보안·중복 (Claude 쪽 전부 적용)

### 6-1. 서버 비용

1. **서버 없음이 기본이다.** 세이브·설정은 `user://` 로컬에 둔다. 서버 기능은 ADR + producer 승인 없이 만들지 않는다.
2. 서버가 필요하면 **요청이 올 때만 실행되는 서버리스**로 만든다. 상시 구동 서버(VM·컨테이너) 금지.
3. **폴링 금지.** 주기적으로 서버를 부르지 않는다. 필요한 시점에 1회 부르고 결과를 캐시한다.
4. 전송은 모아서 한다. 플레이 중 이벤트마다 호출하지 않는다.
5. 실패 재시도는 지수 백오프 + 최대 횟수. 무한 재시도는 장애 때 요금 폭탄이 된다.
6. ADR 에 무료 티어 한도와 예상 호출 수를 적는다.

### 6-2. 안 쓰는 것은 실행되지 않게

1. `_process`·`_physics_process` 는 매 프레임 할 일이 있는 노드에만 정의한다. 일이 없는 동안은 `set_process(false)`.
2. 상태 확인을 매 프레임 반복하지 말고 **시그널**로 받는다.
3. 화면 밖·비활성 노드는 `process_mode = PROCESS_MODE_DISABLED` 또는 `VisibleOnScreenEnabler2D/3D`.
4. **autoload 는 game-architect 가 허가한 것만.** autoload 는 게임 내내 살아 있는 코드다.
5. 씬·리소스는 필요할 때 로드한다. 전부 `preload` 하지 않는다.
6. 쓰지 않는 코드·노드·리소스는 남기지 말고 지운다 (주석 처리 보관 금지 — git 에 이력이 있다).

### 6-3. 중복 금지

1. 새 함수·씬·리소스를 만들기 전에 검색한다. 같은 일을 하는 것이 있으면 재사용한다.
2. 공통 로직이 어디 사는지는 `docs/architecture/` 가 정한다. 거기 없는 공통 모듈을 임의로 만들지 않는다.
3. 밸런스 수치·상수는 `data/game/` 한 곳에. 코드 여기저기에 숫자를 박지 않는다.

### 6-4. 보안

1. **게임 빌드는 쉽게 풀린다** (.pck 추출·GDScript 복원). 클라이언트에 비밀 키를 넣지 않는다 — 암호화해도 푸는 키가 같이 들어 있다.
2. 키·토큰은 **서버 환경변수에만.** 코드·`data/`·`project.godot`·`export_presets.cfg`·커밋 메시지 어디에도 쓰지 않는다. `.env` 는 커밋 금지(.gitignore).
3. Export 스크립트 암호화 키는 `GODOT_SCRIPT_ENCRYPTION_KEY` 환경변수로만 넘긴다.
4. 서버는 클라이언트 값을 믿지 않는다. 점수·재화는 서버가 검증. 입력 검증·크기 제한·요청 빈도 제한 필수.
5. 서버 엔드포인트는 기본 거부. 인증 없는 쓰기 금지. CORS `*` 금지.
6. 세이브 파일은 조작될 수 있다고 가정한다. JSON 으로 저장하고, 읽을 때 필드·범위를 검증한다. 객체 역직렬화(`allow_objects = true`) 금지.
7. 외부 통신은 HTTPS 만. 허용 도메인 목록은 `docs/architecture/` 에 둔다.
8. 시크릿 값이 대화·로그에 나타나면 즉시 producer 에게 알리고 **키 교체**를 권한다. 지우는 것으로는 부족하다.

## 7. 산출물 템플릿

`templates/` — `brief.md` · `draft.md` · `review.md` · `decision.md` · `handoff.md` · `adr.md`
양식에 없는 항목을 만들거나 있는 항목을 빼지 않는다. 빈 항목은 "해당 없음" 으로 쓴다.
