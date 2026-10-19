# N3XUS Gym (fork do openGym)

Esta branch (`n3xus`) é o openGym v1.4.1 de Duarte Santos com o nome exibido trocado para
**N3XUS Gym**. O resto do app é o upstream; licença AGPL-3.0-or-later, créditos mantidos em
Ajustes → Sobre (link para este código e para o openGym original).

- `rebrand.py`: troca `openGym` por `N3XUS Gym` só em literais de texto do `frontend/src`
  (chaves do i18n, traduções, t('...')). Não toca em chaves internas (`gym_state_v1`,
  `openGymSheet`), na pasta do auto-backup (`Documents/openGym`), nos `.apk` do upstream nem em URLs.
  Depois de um merge do upstream: `python3 contrib/n3xus/rebrand.py frontend/src` e revisar o diff.
- Feito à mão (não é literal simples): títulos em `Login.jsx`/`MobileOnboarding.jsx`, rodapé de
  `Settings.jsx` (`SOURCE_URL` + crédito), `plan-share.js` (kicker/rodapé), README do backup em
  `backup-media.js`, chave nova `based on` em todos os locales.
- `index.html` e `manifest.json` ficam como no upstream: a camada nginx do Coolify (`coolify/n3x`)
  troca título, Open Graph, ícones e manifest por `sub_filter` e depende desse texto original.
- Testes: `./scripts/ci-local.sh` (Docker). `sheets.day-note.test.jsx` (calendário do dia
  anotado) já falha no upstream v1.4.1 nesta data; não é desta branch.
