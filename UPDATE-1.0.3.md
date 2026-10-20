# ts_bridge 1.0.3

Installeer de gewijzigde bestanden in je bestaande ts_bridge-map en herstart ts_bridge en afhankelijke scripts (bij voorkeur serverherstart).

Vul in audit_config.lua je Discord-webhook-URLs in:
- payments: geslaagde bij- en afschrijvingen bij spelers.
- societies: geslaagde bij- en afschrijvingen bij societies.
- invoices: succesvol aangemaakte facturen, niet de betaling ervan.
- errors: mislukte bovenstaande acties en mislukte saldo-/factuuropvragingen, inclusief onbeschikbare providers.

Lege URL schakelt die categorie uit. Enabled = false schakelt alle eigen auditlogs uit. Eén URL mag voor meerdere categorieën worden gebruikt. Alleen acties via de bridge worden gelogd, niet alle transacties van andere scripts. Het foutkanaal is geen algemene FiveM-consolelogger.

Logs bevatten het aanroepende script, betrokken server-IDs, bedrag/rekening, reden, waar beschikbaar saldo vooraf/achteraf, factuurreferentie en foutcode. Een onzekere uitkomst betekent dat de provider mogelijk al geld of een factuur heeft verwerkt; herhaal de actie niet blind.

Webhookfouten blokkeren geen transacties. De bestaande wachtrij is begrensd, niet permanent en kan logs overslaan bij drukte of serverstop. Geen automatische herhaling van onzekere POSTs. Discord-mentions zijn uitgeschakeld.

server_config.lua en config.lua hoef je niet te vervangen. Bestaande webhookroutes voor hostage/nlplates blijven werken. Gedeeld configschema blijft 0.0.6; het nieuwe losse auditbestand heeft versie 1.0.0. Geen SQL-wijziging nodig. Publiceer geen ingevulde webhook-URLs op GitHub.
