# 🧠 에이전트 기억 관리 시스템 (Hybrid Memory System)

Vibe Skills 에이전트는 **비정형 연상 기억(Graph)**과 **정형 사실 기억(SQL)**을 결합한 하이브리드 메모리 시스템을 사용합니다.

---

## 1. 🕸️ 연상 기억 (Associative Memory) - `Knowledge Graph`

인간의 뇌처럼 **개념과 관계**를 중심으로 기억을 저장합니다.

*   **Technology**: `@modelcontextprotocol/server-memory`
*   **Storage**: `~/.agent_store/memory_YYYY-MM-DD.jsonl` (JSON Lines)
*   **Role**: 단기/중기 작업 컨텍스트, 사용자 선호도, 프로젝트 구조 이해.
*   **특징**: 매일 새로운 파일로 회전(Rotation)되어 비대해짐을 방지합니다.

### 🔄 일별 회전 및 검색 전략 (Daily Rotation Strategy)

1.  **Active Memory (오늘)**
    *   **접근**: MCP `memory` 도구 (`read_graph`, `create_entities`, `search_nodes`)
    *   **자동 로드**: `setup_mcp.sh`가 생성한 래퍼 스크립트가 실행 시점의 **오늘 날짜 파일**을 자동으로 로드합니다.
    *   **행동 수칙**: 작업을 시작할 때 습관적으로 `read_graph`를 호출하여 오늘의 맥락을 파악합니다.

2.  **Archived Memory (과거)**
    *   **접근**: 파일 시스템 도구 (`rg`, `grep`)
    *   **위치**: `~/.agent_store/*.jsonl`
    *   **검색**: 과거의 문맥이 필요하면 에이전트가 직접 `rg "키워드" ~/.agent_store/` 명령을 수행하여 "죽은 기억"을 발굴합니다.

---

## 2. 🗄️ 정형 기억 (Structured Memory) - `SQLite`

로그, 통계, 명시적인 규칙 등 **변하지 않는 사실**을 저장합니다.

*   **Technology**: `@modelcontextprotocol/server-sqlite`
*   **Storage**: `~/.agent_store/memory.db` (단일 파일 유지)
*   **Role**: 핵심 제약 조건(Constitution), 실패/성공 패턴 학습, 세션 로그.

### Database Schema (SSOT)

```sql
-- 1. 프로젝트 핵심 컨텍스트 (환경, 언어, 프레임워크 정보)
CREATE TABLE IF NOT EXISTS project_context (
    key TEXT PRIMARY KEY,
    value TEXT,
    last_verified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 사용자 핵심 규칙 및 제약 (분노, 반복 지적, 강조 사항)
CREATE TABLE IF NOT EXISTS critical_constraints (
    id INTEGER PRIMARY KEY,
    rule TEXT NOT NULL,
    repetition_count INTEGER DEFAULT 1,
    intensity TEXT, -- 'Normal', 'High', 'Critical'
    last_notified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 세션 히스토리 (작업 이력 및 맥락)
CREATE TABLE IF NOT EXISTS session_history (
    id INTEGER PRIMARY KEY,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    summary TEXT,
    key_topics TEXT,
    next_steps TEXT
);

-- 4. 실패 패턴 및 학습 (재발 방지)
CREATE TABLE IF NOT EXISTS failure_patterns (
    id INTEGER PRIMARY KEY,
    context TEXT,
    error_message TEXT,
    failed_approach TEXT,
    successful_fix TEXT,
    prevention_logic TEXT
);

-- 5. 학습된 인사이트 (성공 경험 및 노하우)
CREATE TABLE IF NOT EXISTS learned_lessons (
    id INTEGER PRIMARY KEY,
    topic TEXT,
    insight TEXT,
    importance_score INTEGER DEFAULT 1
);
```

---

## ⚠️ 메모리 관리 원칙 (Constitution)

1.  **이원화 원칙**:
    *   "사용자가 TDD를 좋아한다" -> **Graph** (성향/관계)
    *   "TDD 실패 횟수: 5회" -> **SQL** (수치/팩트)
    *   "로그인 모듈 구조" -> **Graph** (개념 연결)
    *   "로그인 에러 로그" -> **SQL** (기록)

2.  **검색 우선**:
    *   질문하기 전에 먼저 **Graph**를 검색하고, 없으면 **Archived Graph**를 `grep`하고, 그래도 없으면 질문한다.

3.  **지속적 갱신**:
    *   새로운 사실을 알게 되면 즉시 적절한 저장소(Graph/SQL)에 기록한다.
