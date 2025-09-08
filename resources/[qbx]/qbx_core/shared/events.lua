-- Server-bound
EVENTS = {
  REQ_META          = 'authority:server:reqMeta',          -- client → server (fetch meta)
  SET_PATH          = 'authority:server:setPath',          -- client chooses path
  ADD_STANDING      = 'authority:server:addStanding',      -- server-only mutations; client calls require validation
  SET_STANDING      = 'authority:server:setStanding',
  ONBOARDING_DONE   = 'authority:server:onboardingDone',
  TICK_PLAYTIME     = 'authority:server:tickPlaytime',     -- server timer adds minutes
  ZONE_HEAT_APPLY   = 'authority:server:zoneHeatApply',    -- internal
}

-- Client-bound
CLIENT = {
  META_PUSH         = 'authority:client:metaPush',         -- server → client state push
  HUD_FLASH         = 'authority:client:hudFlash',
  HEAT_UPDATE       = 'authority:client:heatUpdate',
  HEAT_ZONES_INIT   = 'authority:client:heatZonesInit',
}
