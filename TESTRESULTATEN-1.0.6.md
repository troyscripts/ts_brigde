# Testresultaten — 22 oktober 2026

- 17 bridge Lua-tests: geslaagd.
- 12 hostage Lua-tests: geslaagd, inclusief gedeelde updatecontrole.
- JavaScript multipart/uploadtest: geslaagd (Node.js 24.19.0).
- 35 bridge manifest/runtime-verwijzingen, JSON-assets en versienummers: geslaagd.
- Git diff --check: geslaagd voor beide scripts.
- Lua-tests lokaal uitgevoerd met LuaTeX --luaonly; CI gebruikt Lua 5.4.
- Geen live FiveM-, ESX-, Discord- of productiedatabasetest uitgevoerd.

Drie oude hostage-tests verwezen nog naar de oude server_config.lua, lib.notify-alerts en directe Lua-upload. Deze zijn aangepast aan de huidige config/NUI en webhook-exportgrens. Transport, timeouts, wachtrijen en binaire uploads blijven gedekt door de bridge-tests.
