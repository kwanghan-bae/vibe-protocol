# 🤖 Agent Instructions System

터미널 기반 AI 코딩 에이전트(Gemini CLI, GitHub Copilot, Claude 등)를 위한 **중앙 집중식 지침 관리 시스템**

---

## 🤷‍♂️ 왜 만들었나?

### 문제
- 여러 프로젝트에서 각각 다른 에이전트 지침을 관리하면 **중복과 불일치** 발생
- 하나의 규칙을 바꾸려면 모든 프로젝트를 일일이 수정해야 함
- 에이전트가 환각, 게으름, 불안전한 응답을 하는 경우가 빈번

### 해결
- **단일 원본(SSOT)**: 한 곳에서 지침을 관리하고 심볼릭 링크로 모든 곳에 배포
- **프롬프트 엔지니어링 기법 적용**: 환각 방지, 게으름 방지, Jailbreak 방어 등

---

## 📁 디렉토리 구조

```
agent/
├── instructions/           # 📜 행동 원칙 (What to do)
│   ├── 00_constitution.md  #    헌법 - 10개 절대 규칙
│   ├── 01_persona.md       #    페르소나 - 정체성과 태도
│   ├── 02_workflow.md      #    워크플로우 - TDD, 응답 포맷
│   ├── 03_verification.md  #    검증 체크리스트 - 전/후/커밋 전
│   ├── 04_anti_patterns.md #    안티 패턴 - 금지 행동 목록
│   └── 05_action_modes.md  #    작업 모드 - READ/WRITE 구분, 급발전 방지
│
├── core/                   # 🛠️ 공통 스킬 (Common Skills)
│   ├── 10_tools.md         #    Modern Unix 도구 + GitHub Enterprise
│   └── 11_memory.md        #    단기/장기 메모리 관리
│
├── modes/                  # 🎭 모드별 지침 (Mode-specific Instructions)
│   ├── plan/               #    기획/아키텍처 모드 (00_instruction.md)
│   ├── dev/                #    개발/구현 모드 (00_constitution.md)
│   ├── code-review/        #    코드 리뷰/보안 감사 모드
│   ├── test/               #    테스트/QA 모드
│   └── doc/                #    문서화 모드
│
├── build/                  # 📦 빌드 결과물 (자동 생성, 수정 금지!)
│   ├── master_plan.md      #    기획 모드 마스터 파일
│   ├── master_dev.md       #    개발 모드 마스터 파일
│   ├── master_review.md    #    리뷰 모드 마스터 파일
│   ├── master_test.md      #    테스트 모드 마스터 파일
│   └── master_doc.md       #    문서화 모드 마스터 파일
│
├── scripts/                # 📜 설정 및 유틸리티 스크립트 (setup, sync)
├── install.sh              # � 통합 설치 스크립트 (One-Shot)
└── README.md               # 💬 이 파일
```

---

## 🚀 3. 철학 및 도구 (Philosophy & Toolchain)

이 프로젝트는 **"현대적인 개발자의 시간은 소중하다"**는 철학 하에, 가장 효율적인 Open Source 도구들을 엄선하여 사용합니다.
`setup.sh`를 실행하면 아래 도구들이 자동으로 설치되어, 당신의 터미널을 슈퍼카로 업그레이드합니다.

### 🌟 왜 Modern Unix Tools인가?
기존의 낡은 Unix 명령어(`ls`, `cat`, `find`) 대신, Rust 등으로 새로 짜여진 도구들은 **더 빠르고, 더 예쁘고, 더 똑똑합니다.**

| 도구 | 대체 대상 | 역할 | 설치해야 하는 이유 (Benefit) |
|:---|:---|:---|:---|
| **`lazygit`** | `git` CLI | **Git GUI** | 복잡한 Git 명령어를 직관적인 UI로 해결. 충돌 해결과 리베이스가 미친듯이 빨라집니다. |
| **`btm`** | `top` | **모니터링** | `htop`보다 가볍고 예쁩니다. 내 맥북이 왜 뜨거운지 1초 만에 파악하세요. |
| **`dust`** | `du` | **용량 분석** | 디스크 용량이 어디서 세는지 트리맵으로 시각화해 줍니다. |
| **`duf`** | `df` | **디스크 확인** | 파티션 정보를 엑셀 표처럼 깔끔하게 보여줍니다. |
| **`curlie`** | `curl` | **API 테스트** | `curl`의 강력함 + `httpie`의 편의성. JSON 응답을 컬러로 봅니다. |
| **`zoxide`** | `cd` | **이동** | 자주 가는 폴더를 기억합니다. `z work` 입력만으로 `/Users/me/git/work`로 점프! |
| **`bat`** | `cat` | **읽기** | 코드 하이라이팅, Git 변경점 표시. 그냥 텍스트 파일이 코드로 보입니다. |
| **`eza`** | `ls` | **목록** | 아이콘 표시, Git 상태 표시. 폴더 구조가 한눈에 들어옵니다. |
| **`rg`** | `grep` | **검색** | `.gitignore`를 자동 인식하여 쓸데없는 파일을 검색하지 않습니다. 엄청 빠릅니다. |
| **`fd`** | `find` | **찾기** | `find`의 복잡한 문법을 잊으세요. 빠르고 직관적입니다. |

### 🤖 코딩 에이전트와의 협업
이 도구들은 **코딩 에이전트(Vibe Skills)**가 작업을 수행할 때도 사용됩니다.
- 에이전트는 `rg`와 `fd`, `sg`를 사용하여 당신의 코드를 0.1초 만에 파악합니다.
- `setup.sh`로 환경을 통일하면, 에이전트와 당신이 **같은 도구, 같은 문맥**을 공유하게 됩니다.

---

## 🚀 4. MCP Toolchain (Agent Capabilities)

이 프로젝트는 **Model Context Protocol (MCP)** 을 통해 에이전트의 능력을 물리적으로 확장합니다.
`setup_mcp.sh`를 실행하면 설치된 모든 코딩 도구(VS Code, Claude, Copilot 등)에 아래 도구들이 자동 연결됩니다.

| 도구 (Server) | 역할 | 비고 |
|:---|:---|:---|
| **Context7** 📚 | **문서/라이브러리 검색** | `@upstash/context7-mcp` - 최신 라이브러리 사용법 조회 (RAG) |
| **Fetch** 🌐 | 웹 페이지 콘텐츠 수집 | `mcp-server-fetch` (Python/uv) - 웹 페이지 텍스트 변환 |
| **Time** ⏰ | 정확한 현재 시간 제공 | `mcp-server-time` (Python/uv) - 스케줄링 및 로그 타임스탬프 |
| **Sqlite** 🗄️ | **정형 데이터 (Logs)** 저장소 | `mcp-server-sqlite` (Python/uvx) - `memory.db` 관리 |
| **Playwright** 🎭 | 웹 브라우저 제어 및 UI 테스트 | `@playwright/mcp` (Node/npx) - 일반 탐색용 |
| **Sequential** 🧠 | 사고력 강화 (Chain of Thought) | `sequential-thinking` (Node) - 복잡한 문제 해결 |
| **Memory** 💾 | **지식 그래프 (Graph)** 저장소 | `memory` (Node) - `memory_YYYY-MM-DD.jsonl` 관리 |

> [!TIP]
> **이미 모든 설정이 완료되었습니다.** 
> `./install.sh`를 실행하면 위 7개 서버가 자동으로 연결됩니다.
> (설정 파일: `~/.gemini/antigravity/mcp_config.json`, `~/.gemini/settings.json`)

---

## 5. 작동 원리 (How it works)

이 프로젝트는 **두 단계**의 아키텍처로 작동합니다: **빌드(Build)**와 **연결(Link)**.

1.  **빌드 단계 (Build Phase - `sync_agent.sh`)**:
    - `core/` (공통 스킬)와 `modes/` (모드별 지침)를 결합하여 `build/` 디렉토리에 정적 아티팩트를 생성합니다.
    - 생성물: `master_dev.md`, `master_plan.md`, `master_test.md` 등.

2.  **연결 단계 (Link Phase - `Global Deployment`)**:
    - `sync_agent.sh`가 `master_dynamic.md`를 `~/.gemini/GEMINI.md`에 자동으로 배포합니다.
    - `SCAN_PATH` 내의 모든 Git 프로젝트의 `.github/copilot-instructions.md`도 동적 마스터로 업데이트합니다.

## 6. 사용법 (Usage)

### 6.1 사전 준비 (Prerequisites)
이 프로젝트는 최신 에이전트 경험을 위해 Modern Unix 도구들을 사용합니다.
`setup.sh` 스크립트를 실행하여 필수 도구(`gh`, `fd`, `rg`, `bat`, `eza` 등)를 확인하고 자동으로 설치하세요.

```bash
# 1. 설치 스크립트 실행 (의존성 검사 및 설치)
chmod +x setup.sh
./setup.sh

# 2. GitHub 로그인 (필수)
# 로그인이 되어 있지 않다면 아래 명령어로 인증을 진행하세요.
gh auth login
# - Account: GitHub.com
# - Protocol: HTTPS
# - Authenticate Git: Yes
# - Login with a web browser
```

### 4.2 초기 설정 및 빌드
```bash
# 1. 환경 설정 (최초 1회)
cp .env.example .env
vi .env # SCAN_PATH, GH_HOST 수정

# 2. 아티팩트 빌드 (모든 모드 생성)
./sync_agent.sh
```

### 4.2 모드 전환 (Smart Context)
Vibe Skills는 **"Smart Context"** 시스템을 통해 작업 성격에 따라 필요한 기술을 동적으로 불러옵니다.
사용자가 별도로 모드를 전환할 필요가 없습니다. 에이전트가 `capability_map.md`를 참조하여 스스로 판단합니다.

#### ⚡ 쾌속 전환 (Cheat Sheet)
에이전트에게 명시적으로 지시하여 모드를 전환할 수도 있습니다. (한국어 별칭 지원)

| 명령어 (Natural Language) | 전환되는 모드 |
|:---|:---|
| "기획 모드로 해줘", "Design Mode" | **Plan Mode** (설계/기획) |
| "개발 시작해", "Dev Mode" | **Dev Mode** (구현/코딩) |
| "리뷰 좀 해줘", "Audit" | **Review Mode** (감사/보안) |
| "테스트 작성해줘", "QA" | **Test Mode** (품질보증) |
| "문서 업데이트해", "Docs" | **Doc Mode** (문서화) |

> **참고**: 에이전트가 길을 잃거나 특정 전문성이 부족해 보이면, 위 키워드로 힌트를 주세요.
> 예: "이 작업은 보안 리뷰가 필요해. Review 모드 지침을 참고해줘."

### 새 프로젝트 추가
```bash
# SCAN_PATH 내에 새 Git 프로젝트 생성 후
./install.sh
# 자동으로 .github/copilot-instructions.md 링크 생성
```

---

## 🛡️ 적용된 프롬프트 엔지니어링 기법

이 시스템에는 최신 프롬프트 엔지니어링 연구와 Brex 가이드를 바탕으로 한 기법들이 적용되어 있습니다.

### 급발진 방지 (Anti-Runaway) 🛑
- **ReAct Pattern**: Reason(추론) → Act(실행) 2단계 프로토콜
- **Mode Separation**: READ(분석) vs WRITE(수정) 명확한 구분
- **Explicit Permission**: 분석 중 문제 발견 시 자동 수정 금지, 사용자 허가 필수
- **Self-Validation**: 도구 호출 전/중/후 3단계 체크포인트

### Jailbreak 방어 (Prompt Injection Defense) 🛡️
- **IMPORTANT REMINDER**: 문서 마지막에 핵심 규칙 반복
- **Constitutional AI**: 헌법 조항으로 절대 규칙 명시
- **Few-Shot Examples**: DO/DON'T 예시로 명확한 경계 설정

### 환각 방지 (Hallucination Prevention) 😵
- **Grounding**: 파일/API 존재 여부를 도구로 먼저 확인
- **Citation**: 외부 정보는 반드시 출처 명시
- **Self-Verification**: 코드 생성 후 자가 검증 체크리스트

### 게으름 방지 (Anti-Laziness) ⚡
- **No Placeholder**: `// TODO`, `...` 생략 표현 금지
- **Full Implementation**: 완전하고 실행 가능한 코드만 제공
- **Completeness Check**: 모든 메서드/함수 완전 구현 확인

### 거짓말 방지 (No Fabrication) 🤥
- **Admit Uncertainty**: 모르면 모른다고 인정
- **No Fake API**: 존재하지 않는 API/라이브러리 호출 금지
- **Verification First**: 추측 금지, 검증 우선

---

## ⚠️ 주의사항

### 🔴 절대 수정 금지
- `master_agent.md` - 자동 생성 파일. `.gitignore`에 포함됨. 수정해도 다음 동기화 시 덮어씌워짐.

### 🟡 수정 시 동기화 필요
- `instructions/*.md` 또는 `skills/*.md` 수정 후 반드시 `./sync_agent.sh` 실행

---

## 🗂️ 파일 번호 체계
번호 체계를 통해 파일이 병합되는 순서와 역할을 명확히 합니다.

| 범위 | 디렉토리 | 역할 |
|:---:|:---|:---|
| `00-09` | `instructions/` | 행동 원칙 | 헌법, 페르소나, 워크플로우 |
| `10-19` | `skills/` | 기술 명세 | 도구, 메모리, 부트스트랩 |

---

## 🔗 연결 위치

| 대상 | 경로 | 용도 |
|:---:|:---|:---|
| **Gemini CLI** | `~/.gemini/GEMINI.md` | 터미널 AI 에이전트 |
| **GitHub Copilot** | `{project}/.github/copilot-instructions.md` | VS Code AI 어시스턴트 |

---

## 📊 현재 상태
| 항목 | 값 |
|:---|:---|
| 지침 파일 수 | 9개 (6 instructions + 3 skills) |
| 연결된 프로젝트 수 | - |
| 마지막 업데이트 | 2026-01-15 |

---

## 🔮 향후 계획
- [ ] 프로젝트별 오버라이드 지침 지원 (`.agent_override.md`)
- [ ] 지침 버전 관리 (Git 태그 연동)
- [ ] 지침 효과 측정 대시보드
- [ ] 자동 린트 (지침 품질 검사)

---

## 📚 참고 자료
- [Brex Prompt Engineering Guide](https://github.com/brexhq/prompt-engineering)
- [Anthropic Claude Prompt Design](https://docs.anthropic.com/claude/docs/prompt-design)
- [OpenAI Best Practices](https://platform.openai.com/docs/guides/prompt-engineering)
