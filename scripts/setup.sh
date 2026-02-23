#!/bin/zsh

# ==============================================================================
# 🛠️ Vibe Protocol - Environment Setup Script (Bootstrap)
# ==============================================================================
# 이 스크립트는 Vibe Protocol 에이전트 구동에 필요한 필수 도구들을 점검하고 설치합니다.
#
# [점검 항목]
# 1. 패키지 매니저: Homebrew (macOS)
# 2. 필수 도구: git, gh, fd, rg, bat, eza, sqlite3
# 3. 설정 점검: gh 인증 상태
# ==============================================================================

# 색상 설정
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=== 🛠️  Vibe Protocol Environment Setup ===${NC}\n"

# ------------------------------------------------------------------------------
# 1. Homebrew 점검 (macOS)
# ------------------------------------------------------------------------------
echo -n "🔍 Checking Package Manager (Homebrew)... "
if command -v brew &> /dev/null; then
    echo -e "${GREEN}✅ Found${NC}"
    HAS_BREW=true
else
    echo -e "${YELLOW}⚠️  Not Found${NC}"
    echo -e "    Brew가 없으면 자동 설치 기능을 사용할 수 없습니다."
    HAS_BREW=false
fi

# ------------------------------------------------------------------------------
# 2. 필수 도구 점검 및 설치
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 2. 필수 도구 점검 및 설치
# ------------------------------------------------------------------------------
# Format: "command:Display Name:package_name"
TOOLS=(
    "git:Git:git"
    "gh:GitHub CLI:gh"
    "sqlite3:SQLite3:sqlite"
    "fd:fd (Find Alternative):fd"
    "rg:ripgrep (Grep Alternative):ripgrep"
    "bat:bat (Cat Alternative):bat"
    "eza:eza (Ls Alternative):eza"
    "sg:ast-grep (Structural Search):ast-grep"
    "jq:jq (JSON Processor):jq"
    "yq:yq (YAML Processor):yq"
    "fzf:fzf (Fuzzy Finder):fzf"
    "delta:delta (Git Diff Enhanced):git-delta"
    "tldr:tldr (Simplified Man Pages):tldr"
    "zoxide:zoxide (Smarter cd):zoxide"
    "lazygit:Lazygit (Git UI):lazygit"
    "btm:Bottom (System Monitor):bottom"
    "dust:Dust (Disk Usage):dust"
    "duf:Duf (Disk Free):duf"
    "curlie:Curlie (HTTP Client):curlie"
)

echo -e "\n🔍 Checking Required Tools..."

check_and_install() {
    local cmd=$1
    local name=$2
    local pkg=$3

    echo -n "   - $name ($cmd)... "
    
    # sg (ast-grep) 등 커맨드명과 패키지명이 다른 경우 처리
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✅ Installed${NC}"
    else
        echo -e "${RED}❌ Missing${NC}"
        if [[ "$HAS_BREW" == "true" ]]; then
            echo -n "     👉 Installing $pkg via Brew... "
            brew install $pkg
            if [ $? -eq 0 ]; then
                 echo -e "${GREEN}✅ Success${NC}"
            else
                 echo -e "${RED}❌ Failed${NC}"
            fi
        else
            echo -e "     ⚠️  Please install manually: brew install $pkg"
        fi
    fi
}

for tool in "${TOOLS[@]}"; do
    IFS=':' read -r cmd name pkg <<< "$tool"
    check_and_install "$cmd" "$name" "$pkg"
done

# ------------------------------------------------------------------------------
# 3. 추가 설정 점검
# ------------------------------------------------------------------------------
echo -e "\n🔍 Checking Configurations..."

# GitHub Auth Check (Host 설정은 .env에 의존하므로 여기선 기본 로그인 여부만 체크)
echo -n "   - GitHub Auth Status... "
if gh auth status &> /dev/null; then
    echo -e "${GREEN}✅ Authenticated${NC}"
else
    echo -e "${YELLOW}⚠️  Not Logged In${NC}"
    echo -e "     👉 실행 필요: ${YELLOW}gh auth login${NC}"
fi

# .env Check
echo -n "   - Environment Config (.env)... "
if [[ -f ".env" ]]; then
    echo -e "${GREEN}✅ Found${NC}"
else
    echo -e "${YELLOW}⚠️  Missing${NC}"
    echo -e "     👉 실행 필요: ${YELLOW}cp .env.example .env${NC} 후 설정 수정"
fi

# ------------------------------------------------------------------------------
# 4. MCP 자동 설정 (Auto-Configuration)
# ------------------------------------------------------------------------------
if [[ -f "$SCRIPT_DIR/setup_mcp.sh" ]]; then
    "$SCRIPT_DIR/setup_mcp.sh"
fi

echo -e "\n${BLUE}=== Setup Complete ===${NC}"
echo -e "모든 항목이 ✅로 표시되었다면, 이제 ${GREEN}./install.sh${NC} (또는 scripts/sync_agent.sh)를 실행할 준비가 되었습니다."
