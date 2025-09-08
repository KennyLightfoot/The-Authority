Config = {
  Webhooks = { admin = GetConvar('admin_webhook', '') },
  Caps = {
    CashMax = 50000,
    CashMin = -50000,
    ItemMax = 50,
    ClearRadiusMax = 100.0
  },
  Cooldowns = { Economy = 30 }, -- seconds
  Whitelists = {
    Items = { 'water', 'sandwich', 'bandage', 'repairkit', 'radio' },
    Vehicles = { 'police', 'ambulance', 'sultan', 'buffalo' }
  },
  Features = { Billing = false }, -- hide until Phase 2
}

