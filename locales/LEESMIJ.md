# Vertalingen

Kies `Locale = 'nl'` of `Locale = 'en'` in `config/config.lua`. Nederlands is standaard en fallback. `locale.lua` bevat de loader; `nl.lua` en `en.lua` bevatten teksten.

Bewerk bestanden met UTF-8. Behoud sleutels, formattekens (%s, %d, %.1f), kleurcodes en \n. Voor een extra taal kopieer je nl.lua, wijzig je zowel Locales['nl'] als Locales.nl en voeg je het bestand vóór de config toe aan shared_scripts in fxmanifest.lua.

Ontbrekende talen en sleutels vallen terug op Nederlands. Exports, commands, resourcenamen en technische foutcodes blijven ongewijzigd. Eigen tekstinstellingen en teksten van aanroepende scripts worden niet automatisch vertaald. Herstart na wijzigen; fallback herstelt geen Lua-syntaxfouten.


De optionele werkpaskoppeling gebruikt jobcards_title en jobcards_unavailable in beide locales. Zie ../JOBCARDS.md.
