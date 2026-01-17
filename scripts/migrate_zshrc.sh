#!/bin/bash

# ===================================
# 🔄 .zshrc 마이그레이션 스크립트
# ===================================
# 기존 .zshrc의 환경변수를 유지하면서 새 설정 적용

set -e

echo "🔍 기존 .zshrc 분석 중..."

BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
NEW_ZSHRC="$HOME/.zshrc.new"
CURRENT_ZSHRC="$HOME/.zshrc"
MERGED_ZSHRC="$HOME/.zshrc.merged"

# 1. 백업
echo "📦 기존 .zshrc 백업: $BACKUP_FILE"
cp "$CURRENT_ZSHRC" "$BACKUP_FILE"

# 2. 기존 .zshrc에서 사용자 정의 환경변수 추출
echo "🔍 사용자 정의 환경변수 추출 중..."

# oh-my-zsh 관련 제외하고 사용자가 추가한 export만 추출
grep -v "^#" "$CURRENT_ZSHRC" | \
  grep -v "oh-my-zsh" | \
  grep -v "ZSH_THEME" | \
  grep "^export" | \
  grep -v "PATH.*brew" | \
  grep -v "NVM_DIR" | \
  grep -v "BUN_INSTALL" > /tmp/user_exports.txt 2>/dev/null || true

# 3. 기존 .zshrc에서 사용자 정의 alias 추출
echo "🔍 사용자 정의 alias 추출 중..."

grep -v "^#" "$CURRENT_ZSHRC" | \
  grep "^alias" | \
  grep -v "ls=" | \
  grep -v "cat=" | \
  grep -v "python=" > /tmp/user_aliases.txt 2>/dev/null || true

# 4. 새 .zshrc.new를 기반으로 병합
echo "🔧 새 설정으로 병합 중..."

cp "$NEW_ZSHRC" "$MERGED_ZSHRC"

# 사용자 정의 환경변수가 있다면 추가
if [ -s /tmp/user_exports.txt ]; then
  echo -e "\n# ---------- 기존 .zshrc에서 마이그레이션된 환경변수 ----------" >> "$MERGED_ZSHRC"
  cat /tmp/user_exports.txt >> "$MERGED_ZSHRC"
fi

# 사용자 정의 alias가 있다면 추가
if [ -s /tmp/user_aliases.txt ]; then
  echo -e "\n# ---------- 기존 .zshrc에서 마이그레이션된 alias ----------" >> "$MERGED_ZSHRC"
  cat /tmp/user_aliases.txt >> "$MERGED_ZSHRC"
fi

# 5. 미리보기
echo ""
echo "✅ 병합 완료! ~/.zshrc.merged 파일이 생성되었습니다."
echo ""
echo "📋 변경 사항 미리보기:"
echo "===================="

if [ -s /tmp/user_exports.txt ]; then
  echo ""
  echo "📌 추가된 환경변수:"
  cat /tmp/user_exports.txt
fi

if [ -s /tmp/user_aliases.txt ]; then
  echo ""
  echo "📌 추가된 alias:"
  cat /tmp/user_aliases.txt
fi

echo ""
echo "===================="
echo ""
echo "다음 단계:"
echo "1. 병합된 파일 확인:"
echo "   code ~/.zshrc.merged"
echo ""
echo "2. 문제 없으면 적용:"
echo "   mv ~/.zshrc.merged ~/.zshrc"
echo "   source ~/.zshrc"
echo ""
echo "3. 문제 발생 시 복구:"
echo "   cp $BACKUP_FILE ~/.zshrc"
echo ""

# 정리
rm -f /tmp/user_exports.txt /tmp/user_aliases.txt
