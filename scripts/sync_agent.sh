#!/bin/zsh
# ==============================================================================
# 🚀 vibe-protocol v6.0 - Ultra-Lean Sync Agent
# ==============================================================================
# 1. CORE.md를 기반으로 변수 치환 후 배포용 파일 생성
# 2. 로컬의 모든 에이전트(Cursor, Windsurf, Gemini 등) 지침 동기화
# ==============================================================================

# 1. 경로 및 환경 설정
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$AGENT_ROOT/build"
SOURCE_FILE="$AGENT_ROOT/instructions/CORE.md"
DIST_FILE="$BUILD_DIR/CORE_DIST.md"

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== 🚀 vibe-protocol Ultra-Lean Sync Start ===${NC}"

# 2. .env 로드 및 변수 설정
[[ -f "$AGENT_ROOT/.env" ]] && source "$AGENT_ROOT/.env"
GH_HOST="${GH_HOST:-github.com}"
SCAN_PATH="${SCAN_PATH:-$HOME/git}"

# 3. 배포용 파일 생성 (Substitution Only)
mkdir -p "$BUILD_DIR"
sed "s|{{GH_HOST}}|$GH_HOST|g" "$SOURCE_FILE" > "$DIST_FILE"
echo -e "    ✅ Artifact Created: ${YELLOW}$DIST_FILE${NC}"

# 4. 배포 함수 (심볼릭 링크 및 .gitignore 처리)
update_link() {
    local target=$1
    local project_root=$2
    local target_dir=$(dirname "$target")

    [[ ! -d "$target_dir" ]] && mkdir -p "$target_dir"
    rm -f "$target"
    ln -s "$DIST_FILE" "$target"
    
    # .gitignore에 추가하여 에이전트 지침이 커밋되지 않도록 보호
    if [[ -n "$project_root" && -f "$project_root/.gitignore" ]]; then
        local rel_path=${target#$project_root/}
        if ! grep -qFx "$rel_path" "$project_root/.gitignore"; then
            echo "$rel_path" >> "$project_root/.gitignore"
        fi
    fi
}

# 5. 전역 에이전트 업데이트
echo -e "    🌐 Updating Global Agents..."
update_link "$HOME/.gemini/GEMINI.md"
update_link "$HOME/.config/opencode/AGENTS.md"

# 6. 프로젝트별 에이전트 업데이트 (Git 스캔)
if [[ -d "$SCAN_PATH" ]]; then
    echo -e "    🔍 Scanning projects in ${YELLOW}$SCAN_PATH${NC}..."
    COUNT=0
    
    # fd가 있으면 사용, 없으면 find 사용
    if command -v fd &> /dev/null; then
        fd -H -t d "^\.git$" "$SCAN_PATH" --prune --exclude ".Trash" | while read git_dir; do
            project_root="${git_dir:h}"
            targets=(".github/copilot-instructions.md" ".cursorrules" ".clinerules" ".windsurfrules" ".opencode/AGENTS.md")
            for t in $targets; do update_link "$project_root/$t" "$project_root"; done
            ((COUNT++))
        done
    fi
    echo -e "    ✅ Updated ${GREEN}$COUNT${NC} projects with new CORE directives."
fi

# 7. 자기 자신 업데이트 (Dogfooding)
project_root="$AGENT_ROOT"
targets=(".github/copilot-instructions.md" ".cursorrules" ".clinerules" ".windsurfrules" ".opencode/AGENTS.md")
for t in $targets; do update_link "$project_root/$t" "$project_root"; done

echo -e "\n${BLUE}=== 🎉 Sync Complete ===${NC}"
echo -e "모든 에이전트가 CORE.md 기반의 새로운 지침으로 업데이트되었습니다."
