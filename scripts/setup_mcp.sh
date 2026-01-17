#!/bin/bash

# ==============================================================================
# 🔌 MCP Auto-Configuration Injector (Polyglot Edition v3)
# ==============================================================================
# "Do it right" - Handles Node.js and Python servers.
# - Clones reference servers.
# - Builds Node.js servers via npm.
# - Runs Python servers via uv (auto-installed).
# - Falls back to npx for missing sources.
# - Uses ABSOLUTE PATHS for everything to prevent "Connection closed".
# ==============================================================================

# 색상 설정
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure required paths are in PATH
export PATH="/bin:/usr/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo -e "\n${BLUE}=== 🔌 MCP Setup & Configuration ===${NC}"

# 0. Environment Check & Tool Installation
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_ROOT="$HOME/.agent_store/mcp-servers"

# Verify Bun/Node
if ! command -v bun &> /dev/null && ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js or Bun is required.${NC}"
    exit 1
fi

# Detect/Install UV (for Python servers)
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}📦 Installing tool: uv (required for Python MCP servers)...${NC}"
    if command -v brew &> /dev/null; then
        brew install uv
    else
        echo -e "${RED}❌ 'uv' not found and 'brew' missing. Please install uv manually: curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
        exit 1
    fi
fi

# Detect Absolute Path for Node/Npx (CRITICAL for Agent Environment)
NODE_BIN=$(which node)
if [[ -z "$NODE_BIN" ]]; then
    NODE_BIN=$(which bun)
fi

NPX_BIN=$(which npx)
if [[ -z "$NPX_BIN" ]]; then
    echo -e "${RED}❌ npx not found.${NC}"
    exit 1
fi

echo "Running with Node: $NODE_BIN"
echo "Running with Npx:  $NPX_BIN"

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is required.${NC}"
    exit 1
fi

# Check JQ/MV Absolute Paths
JQ="/usr/bin/jq"
if [[ ! -x "$JQ" ]]; then JQ=$(which jq); fi
MV="/bin/mv"

# 1. Clone & Build
echo -e "\n${YELLOW}1. Fetching Reference Servers...${NC}"

if [[ ! -d "$MCP_ROOT" ]]; then
    git clone https://github.com/modelcontextprotocol/servers.git "$MCP_ROOT"
else
    echo "   - Updating existing repository..."
    cd "$MCP_ROOT" && git pull --rebase
fi

echo -e "\n${YELLOW}2. Building Node.js Servers...${NC}"
cd "$MCP_ROOT"

# Clean environment for NPM
unset NPM_TOKEN
unset NODE_AUTH_TOKEN
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org/

# Install & Build (Only builds Node workspaces, ignores Python)
npm install
npm run build


# 3. Define Wrappers (MUST BE DONE BEFORE CONFIG DEFINITIONS)

# NPX Wrapper (for Fallbacks) - Uses ABSOLUTE PATH to npx
NPX_WRAPPER="$HOME/.agent_store/npx_clean.sh"
cat > "$NPX_WRAPPER" <<EOF
#!/bin/bash
export NPM_CONFIG_USERCONFIG=/dev/null
export NPM_CONFIG_GLOBALCONFIG=/dev/null
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
EMPTY_RC_USER=\$(mktemp)
EMPTY_RC_GLOBAL=\$(mktemp)
export NPM_CONFIG_USERCONFIG=\$EMPTY_RC_USER
export NPM_CONFIG_GLOBALCONFIG=\$EMPTY_RC_GLOBAL
exec "$NPX_BIN" -y "\$@"
EOF
chmod +x "$NPX_WRAPPER"


# Memory Wrapper (Local Node) - Uses ABSOLUTE PATH to node
mkdir -p "$HOME/.agent_store"
MEMORY_WRAPPER="$HOME/.agent_store/start_memory_server.sh"
cat > "$MEMORY_WRAPPER" <<EOF
#!/bin/bash
TODAY=\$(date +%F)
MEMORY_FILE="\$HOME/.agent_store/memory_\$TODAY.jsonl"
export MEMORY_FILE_PATH="\$MEMORY_FILE"
exec "$NODE_BIN" "$MCP_ROOT/src/memory/dist/index.js"
EOF
chmod +x "$MEMORY_WRAPPER"


# 4. Config Definitions
# - Python Servers: Use 'uv run'
# - Node Servers: Use '$NODE_BIN'
# - Missing: Use '$NPX_WRAPPER'

# Fetch (Python)
SERVER_FETCH='{
    "command": "uv",
    "args": ["--directory", "'$MCP_ROOT'/src/fetch", "run", "mcp-server-fetch"]
}'

# Time (Python)
SERVER_TIME='{
    "command": "uv",
    "args": ["--directory", "'$MCP_ROOT'/src/time", "run", "mcp-server-time"]
}'

# Filesystem (Node)
SERVER_FILESYSTEM='{
    "command": "'$NODE_BIN'",
    "args": ["'$MCP_ROOT'/src/filesystem/dist/index.js", "'$HOME'/Desktop", "'$HOME'/Documents"]
}'

# Sequential Thinking (Node)
SERVER_SEQUENTIAL='{
    "command": "'$NODE_BIN'",
    "args": ["'$MCP_ROOT'/src/sequentialthinking/dist/index.js"]
}'

# Memory (Node via Wrapper)
SERVER_MEMORY='{
    "command": "'$MEMORY_WRAPPER'",
    "args": []
}'


# Sqlite (Python via uvx - Verified)
SERVER_SQLITE='{
    "command": "uvx",
    "args": ["mcp-server-sqlite", "--db-path", "'$HOME'/.agent_store/memory.db"]
}'

# Playwright (NPM - Verified)
SERVER_PLAYWRIGHT='{
    "command": "'$NPX_WRAPPER'",
    "args": ["-y", "@playwright/mcp"]
}'

# Context7 (Docs & Libraries - Highly Recommended by User)
SERVER_CONTEXT7='{
    "command": "'$NPX_WRAPPER'",
    "args": ["-y", "@upstash/context7-mcp"]
}'


# 5. Injection Logic
TARGETS=(
    "$HOME/.gemini/antigravity/mcp_config.json|Antigravity Agent"
    "$HOME/.copilot/mcp-config.json|GitHub Copilot"
    "$HOME/.gemini/settings.json|Gemini Code Assist"
    "$HOME/Library/Application Support/Claude/claude_desktop_config.json|Claude Desktop"
    "$HOME/Library/Application Support/Cursor/User/globalStorage/mcp.json|Cursor Editor"
    "$HOME/.codeium/windsurf/mcp_config.json|Windsurf Editor"
)

inject_config() {
    local file=$1
    local name=$2
    local dir="${file%/*}"
    
    [[ ! -d "$dir" ]] && return
    
    echo -n "   - Configuring ${name}... "
    if [[ ! -f "$file" ]]; then
        mkdir -p "$dir"
        echo '{"mcpServers":{}}' > "$file"
    fi
    
    local tmp_file="${file}.tmp"
    
    # Check JQ
    if [[ ! -x "$JQ" ]]; then echo "jq missing ($JQ)"; return; fi

    # Ensure root
    "$JQ" '.mcpServers = (.mcpServers // {})' "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"

    # Remove unwanted servers (Git, Filesystem)
    "$JQ" 'del(.mcpServers.git, .mcpServers.filesystem)' "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"

    # Inject Servers
    for srv_key in "fetch=$SERVER_FETCH" "time=$SERVER_TIME" "sequential-thinking=$SERVER_SEQUENTIAL" "memory=$SERVER_MEMORY" "sqlite=$SERVER_SQLITE" "playwright=$SERVER_PLAYWRIGHT" "context7=$SERVER_CONTEXT7"; do
        key="${srv_key%%=*}"
        json="${srv_key#*=}"
        
        "$JQ" --argjson val "$json" ".mcpServers[\"$key\"] = \$val" "$file" > "$tmp_file" && "$MV" "$tmp_file" "$file"
        echo -n "$key "
    done
    
    echo -e "${GREEN}✅ Done.${NC}"
}

echo -e "\n${YELLOW}3. Injecting Configurations...${NC}"
for item in "${TARGETS[@]}"; do
    path="${item%%|*}"
    desc="${item##*|}"
    inject_config "$path" "$desc"
done

echo -e "\n${BLUE}=== MCP Configuration Complete ===${NC}"
