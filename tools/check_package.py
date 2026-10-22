#!/usr/bin/env python3
"""Check a clean checkout before distributing a FiveM resource."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = (root / 'fxmanifest.lua').read_text()
manifest = re.sub(r'--[^\n]*', '', manifest)
errors = []
patterns = []
for block in re.findall(r'\b(?:shared_scripts|client_scripts|server_scripts|files)\s*\{([^}]+)\}', manifest):
    patterns += re.findall(r"['\"]([^'\"]+)['\"]", block)
patterns += re.findall(r"\b(?:shared_script|client_script|server_script|ui_page)\s*['\"]([^'\"]+)['\"]", manifest)
patterns += ['server/document_image.js', 'server/document_font.json', 'server/DOCUMENT_FONT_LICENSE.txt']
for pattern in patterns:
    if not pattern.startswith('@') and not any(p.is_file() for p in root.glob(pattern)):
        errors.append('Missing manifest/runtime file: ' + pattern)
version = re.search(r"\bversion\s*['\"]([^'\"]+)['\"]", manifest)
if not version or json.loads((root / 'version.json').read_text())['version'] != version[1]:
    errors.append('Manifest and version.json disagree')
for path in root.rglob('*.json'):
    if '.git' not in path.parts:
        try:
            json.loads(path.read_text())
        except (ValueError, UnicodeError) as exc:
            errors.append(str(path.relative_to(root)) + ': ' + str(exc))
if errors:
    raise SystemExit('\n'.join(errors))
print(f'PASS: {len(patterns)} manifest/runtime references, JSON assets and version consistency')
