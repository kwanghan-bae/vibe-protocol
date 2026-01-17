# 🛠️ Skill: Modern Toolchain & Environment

---

## 1. Modern Unix Tools

### 1-1. 🤖 Agent Tools (무인 자동화)
에이전트는 아래의 **CLI 도구**를 사용하여 코드를 분석하고 조작한다. **절대 대화형(Interactive) 도구를 실행하지 않는다.**

| 역할 | 명령어 | 설명 | 필수 옵션 |
|:---|:---|:---|:---|
| 👀**읽기** | `bat` | `cat` 대체. Syntax Highlight 지원. | `--style=plain` |
| 📂**목록** | `eza` | `ls` 대체. 아이콘 및 Git 상태 표시. | `--icons --git` |
| 🔍**검색** | `rg` | `grep` 대체. `.gitignore` 자동 준수. | (기본값 사용) |
| 🔦**찾기** | `fd` | `find` 대체. 빠르고 간결함. | (기본값 사용) |
| 🏗️**구조** | `sg` | `ast-grep`. 코드 구조 기반 정밀 검색. | `-p` 패턴 사용 |
| 📦**분석** | `repomix`| 전체 코드베이스를 하나의 컨텍스트로 압축. | `--style xml` |
| 🔧**JSON** | `jq` | 커맨드라인 JSON 프로세서. | (스크립트용) |
| 🔧**YAML** | `yq` | 커맨드라인 YAML 프로세서. | (설정파일용) |
| 🌐**HTTP** | `curlie`| `curl` 대체. API 테스트. | (자동화 가능 시) |

### 1-2. 👤 User Tools (사용자 전용 - 에이전트 사용 금지)
아래 도구는 **사용자(Top-Tier Developer)**의 효율성을 위한 **TUI(Terminal UI)** 도구이다.
에이전트는 이 도구들이 존재함을 인지하되, **직접 실행해서는 안 된다.** (행 걸림 방지)

| 도구 | 역할 | 비고 |
|:---|:---|:---|
| `lazygit` | Git GUI | 사용자가 Git 작업을 편하게 하기 위함 |
| `btm` | 시스템 모니터 | 사용자가 리소스를 확인하기 위함 |
| `dust` | 용량 분석 | 사용자가 디스크를 정리하기 위함 |
| `duf` | 디스크 확인 | 사용자가 파티션을 확인하기 위함 |
| `fzf` | 퍼지 검색 | 사용자가 파일을 빠르게 찾기 위함 |
| `zoxide`| 스마트 이동 | 사용자가 디렉토리를 점프하기 위함 |

> [!WARNING] **CRITICAL CONSTRAINT**
> 에이전트는 `lazygit`, `btm`, `fzf` 등 **User Tools를 절대 호출하지 않는다.**
> 오직 `Agent Tools`(`rg`, `fd`, `jq` 등)의 Non-interactive 모드만 사용한다.

## 2. GitHub Enterprise Policy

- **Host**: `{{GH_HOST}}` (설정: `.env`)
- **CLI**: `gh` 명령어 사용 시 반드시 `--hostname {{GH_HOST}}` 옵션 또는 `GH_HOST` 환경변수를 사용한다.
- **Auth**: 작업 시작 전 `gh auth status --hostname {{GH_HOST}}`으로 인증 상태를 확인해야 한다.
  > ⚠️ "You are not logged into..." 에러 발생 시, 즉시 `gh auth login`을 실행하여 인증한다.
- **Commit**: 커밋 메시지는 한국어로 작성하며, `feat:`, `fix:`, `refactor:` 등의 컨벤션을 준수한다.

---

## ⚠️ REMINDER

- 도구 실행 전 반드시 경로와 파일 존재 여부를 확인한다.
- 검색 결과 없이 파일 경로나 API를 언급하지 않는다.
- `gh` 명령어 시 `--hostname` 옵션을 절대 빼먹지 않는다.

---

## 3. MCP Capabilities (Expanded via setup_mcp.sh)

에이전트는 MCP 프로토콜을 통해 다음 외부 도구들을 함수처럼 호출할 수 있습니다.

### 3-1. 핵심 도구 (Core)
*   `context7`: **문서 검색 (Docs RAG)**. 라이브러리 사용법을 모를 때 최우선 사용. (`query-docs`)
*   `sequential-thinking`: **사고력 (CoT)**. 복잡한 문제 해결 시 논리적 단계 분해.
*   `memory`: **지식 그래프**. 사용자 성향, 프로젝트 구조 등 '맥락' 저장.
*   `sqlite`: **Fact DB**. 로그, 에러 패턴, 통계 데이터 저장.
*   `fetch`: **웹 스크래핑**. 블로그, 튜토리얼 등 일반 텍스트 수집.
*   `time`: **시간 확인**. 현재 시각이 필요할 때 사용.

### 3-2. 브라우저/테스트 (Browser & Test)
*   `playwright`: **브라우저 제어**. UI 테스트, 스크린샷 캡처, 동적 웹페이지 탐색.

> [!IMPORTANT] **Context7 사용 전략**
> - **모르는 라이브러리 등장**: 즉시 `query-docs`로 공식 문서 조회.
> - **버전 호환성 확인**: 최신 문서를 통해 Deprecated API 확인.
> - **환각 방지**: "아마 이럴 것이다"라고 추측하지 말고 문서를 근거로 코딩.
