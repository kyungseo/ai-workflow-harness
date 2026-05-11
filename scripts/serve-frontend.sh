#!/bin/bash

# 스크립트 실행 위치에 상관없이 프로젝트 루트를 기준으로 경로 설정
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "Starting server for frontend/web-app at http://localhost:3000..."

# HTTP 서버 실행
python3 -m http.server 3000 --directory "$REPO_ROOT/frontend/web-app"
