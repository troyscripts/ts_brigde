# ts_bridge 1.0.5 — één configuratiebestand

Deze update is gebaseerd op 1.0.3. De geannuleerde okok-uitbreiding uit 1.0.4 is NIET meegenomen. 1.0.5 voorkomt verwarring met dat vervallen pakket.

## Installeren

1. Maak een kopie van je bestaande config.lua, server_config.lua, vehicle_config.lua en audit_config.lua.
2. Plaats de updatebestanden in je bestaande ts_bridge-map.
3. Neem jouw eigen waarden over in de nieuwe config.lua: algemene instellingen bovenaan; oude vehicle_config-instellingen onder Vehicles; oude server_config-instellingen onder Server; audit Enabled onder Audit. InventoryResource hoef je nog maar eenmaal bovenaan in te stellen.
4. Kopieer bestaande URLs uit server_config.lua (Webhooks) en audit_config.lua (Webhooks) naar de overeenkomstige tabellen in webhook_config.lua.
5. Verwijder de oude server_config.lua, vehicle_config.lua en audit_config.lua. Ze worden niet meer geladen. Zie VERWIJDERD-1.0.5.txt.
6. Herstart je server en controleer ts_bridge_check in de console.

De meegeleverde config bevat de waarden uit het aangeleverde pakket. Wijzigingen die je daarna zelf op je server hebt gedaan zijn niet bekend en moeten bij stap 3 worden overgenomen. Webhook-URLs zijn leeg totdat je ze kopieert.

Alle algemene instellingen staan nu in config.lua, ook updates, banking/billing, societyrekeningen, screenshots, wachtrijlimieten en de audit-aan/uit-schakelaar. Alleen de URLs staan apart en worden nooit als clientbestand geladen. De map locales blijft de vertaalteksten bevatten; de taal selecteer je in config.lua.

Scriptversie 1.0.5; configschema 0.0.7 omdat de configindeling gewijzigd is. Interne TSBridgeServer/TSBridgeVehicles/TSBridgeAuditConfig-namen blijven voor bestaande code beschikbaar. Geen SQL-update nodig.

Lokaal gecontroleerd met de bestaande Lua-tests en een configuratielaadtest; geen live FiveM-test uitgevoerd.
