TSBridgeConfig = {
    Locale = 'nl', -- Hoofdtaal; teksten staan in locales/nl.lua
    NotificationTitle = TSL('config_troy_scripts'),
    NotificationDuration = 5000,
    WaypointKey = 'G',
    InventoryResource = 'ox_inventory', -- client useItem; gelijk houden aan server_config.lua
    TargetResource = 'ox_target', -- alleen een ox_target-compatibele resource
    DeadStateKeys = { 'dead', 'isDead', 'laststand' }
}
