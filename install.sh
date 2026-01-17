#!/bin/bash

# ==============================================================================
# 🚀 Vibe Skills - Unified Installer (One-Shot Setup)
# ==============================================================================
# 이 스크립트는 다음 단계를 순차적으로 실행하여 환경을 완벽하게 구성합니다.
# 1. 환경 변수 설정 (.env)
# 2. 필수 도구 설치 (setup.sh -> setup_mcp.sh)
# 3. 에이전트 빌드 및 배포 (sync_agent.sh)
#
# 사용법: ./install.sh
# ==============================================================================

# 색상 설정
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== 🚀 Vibe Skills All-in-One Installer ===${NC}\n"

# 0. Root 실행 방지 (Homebrew 등 문제 방지)
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}❌ Do not run as root (sudo). Homebrew and local paths may break.${NC}"
  echo -e "Please run as a normal user: ${YELLOW}./install.sh${NC}"
  exit 1
fi

# 1. 환경 변수 준비
echo -e "${BLUE}[Step 1] Environment Config (.env)${NC}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env from .env.example${NC}"
        echo -e "${YELLOW}⚠️  Please manually check .env later to configure GH_HOST/SCAN_PATH.${NC}"
    else
        echo -e "${RED}❌ .env.example not found.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ .env exists${NC}"
fi

# 2. 도구 및 MCP 설정 (setup.sh가 setup_mcp.sh를 내부적으로 호출함)
echo -e "\n${BLUE}[Step 2] Tools & MCP Setup (scripts/setup.sh)${NC}"
chmod +x scripts/setup.sh
scripts/setup.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Setup failed.${NC}"
    exit 1
fi

# 3. 에이전트 빌드 및 배포
echo -e "\n${BLUE}[Step 3] Agent Build & Deploy (scripts/sync_agent.sh)${NC}"
chmod +x scripts/sync_agent.sh
scripts/sync_agent.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Agent Sync failed.${NC}"
    exit 1
fi

echo -e "\n${BLUE}=== 🎉 Installation Complete! ===${NC}"
echo -e "모든 설정이 완료되었습니다. 에이전트가 준비되었습니다."
