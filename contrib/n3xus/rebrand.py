#!/usr/bin/env python3
"""Troca o nome exibido "openGym" por "N3XUS Gym" nos textos do frontend.

Só mexe em literais de string (chaves e traduções do i18n, t('...')), nunca em comentários,
identificadores (openGymSheet), caminhos (Documents/openGym) ou URLs (github.com/.../openGym).
Idempotente: rodar de novo depois de um merge do upstream re-aplica a marca.
Uso: python3 -I contrib/n3xus/rebrand.py frontend/src
"""
import pathlib, re, sys

BRAND = 'N3XUS Gym'
# palavra solta: sem letra/dígito/_ antes ou depois, sem "/" colado (caminho ou URL)
WORD = re.compile(r'(?<![A-Za-z0-9_/])openGym(?![A-Za-z0-9_/])')  # sufixo não-ASCII (ko: openGym을) troca
# linhas que citam nomes reais fora do app: pasta do auto-backup e arquivos .apk do upstream
SKIP = re.compile(r'AUTO_BACKUP_DIR|\.apk')
STR = re.compile(r"""'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*\"""")
COMMENT = re.compile(r'^\s*(//|/\*|\*)')

def fix_line(line):
    if COMMENT.match(line) or SKIP.search(line):
        return line
    code, sep, tail = line, '', ''
    # comentário no fim da linha (fora de string) fica como está
    m = re.search(r"\s//\s", line)
    if m and not STR.search(line[m.start():]) and line[:m.start()].count("'") % 2 == 0:
        code, tail = line[:m.start()], line[m.start():]
    return STR.sub(lambda s: WORD.sub(BRAND, s.group(0)), code) + tail

def main(root):
    changed = 0
    for p in sorted(pathlib.Path(root).rglob('*')):
        if p.suffix not in ('.js', '.jsx') or not p.is_file():
            continue
        src = p.read_text(encoding='utf-8')
        out = ''.join(fix_line(l) for l in src.splitlines(keepends=True))
        if out != src:
            p.write_text(out, encoding='utf-8')
            changed += 1
            print('ok', p)
    print(changed, 'arquivos')

main(sys.argv[1] if len(sys.argv) > 1 else 'frontend/src')
