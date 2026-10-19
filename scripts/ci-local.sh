#!/usr/bin/env bash
# Checagens locais em Docker (sem CI hospedado de propósito). Rodar da raiz: ./scripts/ci-local.sh
# Mesmo Node 22 do web/Dockerfile: textos (marca N3XUS Gym), locales e a suíte vitest do frontend,
# depois o build da imagem web, que é o que vai para o Coolify.
set -euo pipefail
cd "$(dirname "$0")/.."
NODE=node:22-alpine

echo "== marca: nenhum 'openGym' sobrando em texto visível"
docker run --rm -v "$PWD:/repo" -w /repo python:3.13-slim sh -c \
  'cp -r frontend/src /tmp/src && python3 -I contrib/n3xus/rebrand.py /tmp/src | tail -1 | grep -qx "0 arquivos"' \
  || { echo "rebrand.py ainda mudaria arquivos: rode python3 contrib/n3xus/rebrand.py frontend/src"; exit 1; }

echo "== locales + vitest (frontend)"
docker run --rm -v "$PWD:/repo" -w /repo/frontend "$NODE" sh -c \
  'npm ci --ignore-scripts --no-audit --no-fund >/dev/null && node scripts/check-locales.mjs && npx vitest run'

echo "== build da imagem web"
docker build -f web/Dockerfile -t n3xus-gym-web:ci .

echo "OK"
