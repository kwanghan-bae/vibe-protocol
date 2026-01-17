# 🗺️ 기술 및 모드 지도 (Capability & Mode Map)

이 섹션은 에이전트가 현재 상황에 맞는 전문 지침을 스스로 찾아 읽을 수 있도록 안내하는 **네비게이션 맵**입니다.
사용자가 명시적으로 모드를 전환하지 않아도, 아래 파일들을 참조하여 필요한 전문성을 획득하세요.

---

## 🎭 전문 모드 (Specialized Modes)
상황에 따라 아래 지침 파일(`build/master_*.md`)의 내용을 읽고 행동하세요.

| 상황 (Context) | 모드명 (Aliases) | 파일 경로 (Absolute Path) | 설명 |
|:---|:---|:---|:---|
| **기획, 아키텍처, 요구사항** | **Plan** (기획, Design) | `{{AGENT_ROOT}}/build/master_plan.md` | 구현 전 설계 단계, 기술 스택 선정 |
| **코드 구현, 디버깅** | **Dev** (개발, Coding) | `{{AGENT_ROOT}}/build/master_dev.md` | (기본값) 실제 코딩, TDD 사이클 |
| **코드 리뷰, 보안 감사** | **Review** (리뷰, Audit) | `{{AGENT_ROOT}}/build/master_review.md` | 코드 품질 검사, 보안 점검 |
| **테스트, QA** | **Test** (테스트, QA) | `{{AGENT_ROOT}}/build/master_test.md` | 테스트 케이스 작성, E2E |
| **문서 작성, 번역** | **Doc** (문서, Docs) | `{{AGENT_ROOT}}/build/master_doc.md` | README 작성, 가이드 |

---

## 🛠️ 도구 및 메모리 (Tools & Memory)
아라 파일들은 에이전트의 물리적 능력(도구)과 기억을 정의합니다.

| 종류 | 파일 경로 | 설명 |
|:---|:---|:---|
| **도구 목록** | `{{AGENT_ROOT}}/core/10_tools.md` | 설치된 Modern Unix 도구 및 MCP 서버 목록 |
| **메모리 전략** | `{{AGENT_ROOT}}/core/11_memory.md` | 장기/단기 기억 관리 전략 |

---

## 🧭 사용 가이드 (Usage Guide)
1. 사용자의 요청이 복잡하거니 특정 전문성이 필요하다고 판단되면, 위 **파일 경로**를 `view_file` 또는 `read_file` 도구로 읽으세요.
2. 읽은 내용은 현재 컨텍스트에 로드되어, 해당 모드의 전문가처럼 행동할 수 있게 해줍니다.
3. 작업이 끝나면 다시 일반(Dev) 모드나 상위 컨텍스트로 복귀하세요.
