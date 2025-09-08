-- Server-bound
EVENTS = {
  REQ_META        = 'authority:server:reqMeta',
  SET_PATH        = 'authority:server:setPath',
  ADD_STANDING    = 'authority:server:addStanding',
  SET_STANDING    = 'authority:server:setStanding',
  ONBOARDING_DONE = 'authority:server:onboardingDone',
  TICK_PLAYTIME   = 'authority:server:tickPlaytime',
  ZONE_HEAT_APPLY = 'authority:server:zoneHeatApply',
}

-- Client-bound
CLIENT = {
  META_PUSH   = 'authority:client:metaPush',
  HUD_FLASH   = 'authority:client:hudFlash',
  HEAT_UPDATE = 'authority:client:heatUpdate',
  HEAT_ZONES_INIT = 'authority:client:heatZonesInit',
}


