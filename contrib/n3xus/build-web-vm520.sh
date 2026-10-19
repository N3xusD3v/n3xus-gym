#!/usr/bin/env bash
# Builda a imagem web do N3XUS Gym na VM 520 (Docker do Coolify), a partir do commit atual.
# Uso, da raiz do repo: ./contrib/n3xus/build-web-vm520.sh [tag]   (padrão: 1.4.1-n3x<sha>)
# O serviço Coolify n3xus-gym-stack usa a imagem com pull_policy: never; depois do build, trocar a
# tag no compose do serviço (ver trocar-imagem-web.sh) e reiniciar.
set -euo pipefail
cd "$(dirname "$0")/../.."
VM=${VM:-samurai@192.168.52.2}
SHA=$(git rev-parse --short HEAD)
TAG=${1:-1.4.1-n3x-$SHA}
[ -z "$(git status --porcelain -- frontend api web catalogue)" ] || { echo "há mudanças não commitadas"; exit 1; }
echo "== build n3xus-gym-web:$TAG ($SHA) em $VM"
CMD=(docker build -f web/Dockerfile -t "n3xus-gym-web:$TAG"
  --build-arg APP_BUILD="n3x.$SHA" --build-arg VERSION="$TAG" --build-arg VCS_REF="$SHA"
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  --label org.opencontainers.image.title=n3xus-gym-web
  --label org.opencontainers.image.source=https://github.com/N3xusD3v/n3xus-gym
  --label org.opencontainers.image.url=https://github.com/N3xusD3v/n3xus-gym
  --label org.opencontainers.image.documentation=https://github.com/N3xusD3v/n3xus-gym/tree/n3xus/contrib/n3xus
  --label "org.opencontainers.image.description=N3XUS Gym (fork do openGym) - frontend" -)
# ssh junta os argumentos numa linha de shell remota: %q mantém as aspas
git archive --format=tar HEAD frontend api/coach/core web catalogue/media .dockerignore \
  | ssh "$VM" "$(printf '%q ' "${CMD[@]}")"
ssh "$VM" docker image inspect "n3xus-gym-web:$TAG" --format '{{.Id}} {{.Size}}'
echo "OK n3xus-gym-web:$TAG"
