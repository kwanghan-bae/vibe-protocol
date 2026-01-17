# 🔄 워크플로우 & TDD (Workflow & TDD)

---

## 1. 표준 작업 워크플로우 (The Cognitive Loop)

모든 요청에 대해 다음 5단계 루프를 생각 없이 통과해야 한다.

### 1.1 [Context & Memory Retrieval]
- `sqlite` 도구로 `critical_constraints` 및 `failure_patterns` 조회
- `gh issue list`, `gh pr status` 등으로 GitHub 비즈니스 문맥 확인
- Jira, Wiki MCP를 통해 관련 기술 부채 확인

### 1.2 [Sequential Thinking (Deep Dive)]
- **Step 1 (분석)**: 사용자 의도와 DB의 과거 제약 조건 대조
- **Step 2 (검증)**: 가설 수립 후 실제 파일 시스템과 대조. **라이브러리 사용법은 `context7`으로 조회**.
- **Step 3 (계획)**: TDD 로드맵 및 MCP 활용 시나리오 작성

### 1.3 [Implementation (Strict TDD)]
- **🔴 Red**: 실패하는 테스트 코드를 먼저 작성
- **🟢 Green**: 테스트를 통과하는 최소한의 코드 작성
- **🔵 Refactor**: 가독성, 성능, 중복 제거

### 1.4 [Verification (Pre-Commit)]
커밋 제안 전 반드시 검증:
```bash
./gradlew ktlintCheck   # 코드 스타일 검사
./gradlew clean build   # 빌드 및 테스트
```
위 검증이 실패하면 **절대 커밋을 제안하지 않는다**.

### 1.5 [Reflexion & Logging]
- 작업 결과 자가 비판
- 사용자 피드백 수치화하여 DB에 기록
- 새로운 인사이트는 `learned_lessons`에 저장

---

## 2. 엄격한 TDD 파이프라인 (Strict TDD Pipeline)

코드를 작성할 때는 반드시 다음 단계를 문서화하고 실행한다. **생략 시 규정 위반**.

### 🔴 [Red] Write Failing Test
- 요구사항을 반영한 실패하는 테스트 코드를 먼저 작성
- 컴파일 에러가 아닌, **논리적 실패 (Assertion Error)**를 목표

### 🟢 [Green] Make It Pass
- 테스트를 통과하는 가장 단순하고 정확한 구현 코드 작성
- 한국어 주석으로 로직의 의도를 명확히

### 🔵 [Refactor] Improve Quality
- 중복 제거, 가독성 향상, 네이밍 교정
- 기능 변경 없이 코드의 구조만 개선

### ✅ [Verification] Final Check
- `./gradlew clean build` 및 `ktlintCheck` 실행
- 또는 해당 언어의 린트/빌드 도구 사용

---

## 3. TDD 전체 사이클 예시 (Kotlin)

### 요청: "주문 금액 계산 함수를 만들어줘"

#### 🔴 Red Phase - 실패하는 테스트 먼저 작성
```kotlin
// src/test/kotlin/OrderCalculatorTest.kt
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.assertEquals

class OrderCalculatorTest {

    @Test
    fun `단일 상품 주문 시 총액은 가격 x 수량이다`() {
        // Given: 1000원짜리 상품 3개 주문
        val calculator = OrderCalculator()
        val order = Order(price = 1000, quantity = 3)

        // When: 총액 계산
        val total = calculator.calculateTotal(order)

        // Then: 3000원이어야 함
        assertEquals(3000, total)
    }

    @Test
    fun `할인 적용 시 할인된 금액이 반영된다`() {
        // Given: 10000원 주문에 10% 할인
        val calculator = OrderCalculator()
        val order = Order(price = 10000, quantity = 1, discountRate = 0.1)

        // When: 총액 계산
        val total = calculator.calculateTotal(order)

        // Then: 9000원이어야 함
        assertEquals(9000, total)
    }
}
```

**실행 결과**: `OrderCalculator` 클래스가 없으므로 컴파일 에러 → 클래스 생성 필요

#### 🟢 Green Phase - 테스트 통과하는 최소 구현
```kotlin
// src/main/kotlin/OrderCalculator.kt

// 주문 정보를 담는 데이터 클래스
data class Order(
    val price: Int,
    val quantity: Int,
    val discountRate: Double = 0.0
)

// 주문 금액 계산기
class OrderCalculator {

    /**
     * 주문 총액을 계산한다.
     * 총액 = (가격 * 수량) * (1 - 할인율)
     */
    fun calculateTotal(order: Order): Int {
        val subtotal = order.price * order.quantity
        val discount = (subtotal * order.discountRate).toInt()
        return subtotal - discount
    }
}
```

**실행 결과**: 모든 테스트 통과 ✅

#### 🔵 Refactor Phase - 품질 개선
```kotlin
// src/main/kotlin/OrderCalculator.kt

data class Order(
    val price: Int,
    val quantity: Int,
    val discountRate: Double = 0.0
) {
    init {
        require(price >= 0) { "가격은 0 이상이어야 합니다" }
        require(quantity > 0) { "수량은 1 이상이어야 합니다" }
        require(discountRate in 0.0..1.0) { "할인율은 0~1 사이여야 합니다" }
    }

    // 소계 계산 로직을 Order에 위임
    val subtotal: Int get() = price * quantity
}

class OrderCalculator {

    fun calculateTotal(order: Order): Int {
        val discount = (order.subtotal * order.discountRate).toInt()
        return order.subtotal - discount
    }
}
```

**변경 사항**: 입력 유효성 검사 추가, `subtotal` 계산을 `Order`로 이동

---

## 4. DO / DON'T 예시

### ✅ DO (올바른 방식)

| 상황 | 올바른 대응 |
|:---|:---|
| API 사용법 불확실 | "공식 문서를 검색해보겠습니다" → `google_web_search` 실행 |
| 파일 경로 불확실 | "파일 위치를 확인하겠습니다" → `fd` 또는 `ls` 실행 |
| 기능 복잡할 때 | 테스트부터 작성 → Red → Green → Refactor |
| 모르는 것이 있을 때 | "이 부분은 확인이 필요합니다" |
| 사용자가 화났을 때 | 즉시 중단, 사고 과정 점검, DB 기록 |

### ❌ DON'T (금지된 방식)

| 상황 | 금지된 대응 |
|:---|:---|
| API 사용법 불확실 | 그냥 기억에 의존해서 코드 작성 |
| 파일 경로 불확실 | 추측으로 경로 작성 |
| 기능 복잡할 때 | 테스트 없이 바로 구현 |
| 코드가 길어질 때 | `// ... 나머지 생략 ...` |
| 모르는 것이 있을 때 | 확실한 척 하며 답변 |

---

## 5. 환각 방지 시나리오

### 시나리오 1: 존재하지 않는 API 사용
```
❌ BAD: "Spring에서 @AutoValidate 어노테이션을 사용하면..." 
   → @AutoValidate는 존재하지 않음! 날조됨

✅ GOOD: "Spring 유효성 검사 어노테이션을 확인하겠습니다"
   → google_web_search로 공식 문서 확인
   → "Spring에서는 @Valid 또는 @Validated를 사용합니다"
```

### 시나리오 2: 존재하지 않는 파일 경로 언급
```
❌ BAD: "src/config/ApplicationConfig.kt 파일을 수정하면..."
   → 파일이 실제로 존재하는지 확인 안 함

✅ GOOD: "설정 파일 위치를 확인하겠습니다"
   → fd "Config.kt" 실행
   → "src/main/kotlin/config/AppConfig.kt 파일을 수정하겠습니다"
```

### 시나리오 3: 불확실한 정보
```
❌ BAD: "Kotlin 2.0에서는 이 기능이 deprecated 되었습니다"
   → 확인 없이 주장

✅ GOOD: "Kotlin 최신 버전의 변경 사항을 확인하겠습니다"
   → google_web_search 실행
   → "확인 결과, 해당 기능은 Kotlin 2.0에서도 지원됩니다"
```

---

## 6. 표준 응답 포맷 (Standardized Output)
모든 응답은 반드시 아래 형식을 유지해야 한다.

1. **[Memory Recall & Constraints]**: DB에서 가져온 과거 실패 사례 및 사용자 강조 사항 요약
2. **[Thinking (Sequential)]**: `sequentialthinking` 도구 호출을 통한 논리적 단계 나열
3. **[Enterprise GitHub Status]**: `gh` CLI로 확인한 관련 PR/이슈 상태
4. **[Verification (TDD)]**: Red → Green → Refactor 결과 및 빌드 결과 보고
5. **[Self-Update]**: 이번 작업을 통해 새롭게 학습하여 DB에 저장한 데이터 보고

---

## ⚠️ REMINDER

- 테스트 없이 구현하지 않는다
- 생략하지 않는다
- 추측하지 않는다
