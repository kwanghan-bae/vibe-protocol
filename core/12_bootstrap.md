# 🚀 부트스트랩 & 세션 관리 (Bootstrap & Session)

---

## 1. 자가 초기화 (Self-Initialization)

에이전트가 새 환경에서 시작할 때 수행해야 하는 절차:

### 1.1 DB 생성
```python
import sqlite3
conn = sqlite3.connect('~/.agent_store/memory.db')
# 11_memory.md의 스키마 참조하여 테이블 생성
```

### 1.2 Deep Scan
- `fd`로 주요 파일 목록 확보
- 필요 시 `repomix`로 프로젝트 구조 요약 생성
- 결과를 `project_context` 테이블에 저장

### 1.3 Connectivity 확인
```bash
gh auth status --hostname {{GH_HOST}}
```

### 1.4 Maintenance
- 주기적으로 `VACUUM` 실행
- 오래된 로그 정리

---

## 2. 세션 전환 프로토콜 ('next' 키워드)

사용자가 `next`를 입력하면 아래 포맷으로 출력하고 DB에 저장한다:

```markdown
## 다음 세션 요약

### 완료된 작업
- ...

### 현재 상태 (repomix 요약)
- ...

### 다음 작업
1. ...

## 저장 위치
- `session_history` 테이블에 요약 기록
- `next_steps` 컬럼에 다음 작업 저장
```

---

## 3. 메모리 동기화 전략

### Read (세션 시작 시)
- `critical_constraints` 로드 (사용자 강조 사항)
- `failure_patterns` 로드 (과거 실패 사례)
- `project_context` 로드 (환경 정보)

### Write (세션 종료 시)
- `session_history`에 요약 기록
- 실패 발생 시 `failure_patterns`에 기록

### Update (실시간)
- 사용자 피드백 발생 시 즉시 `critical_constraints` 업데이트
- 새로운 인사이트는 `learned_lessons`에 추가

---

## ⚠️ REMINDER

- 세션 시작 시 반드시 메모리를 로드한다. 과거를 잊지 않는다.
- 세션 종료 시 반드시 요약을 저장한다. 다음 세션을 위해.
- `next` 키워드는 단순 종료가 아니라 인수인계 프로토콜이다.
