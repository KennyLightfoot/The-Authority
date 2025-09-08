-- Placeholder UI hook for season pass
RegisterNetEvent('authority_season:client:update', function(level, xp)
  SendNUIMessage({ type = 'season:update', data = { level = level, xp = xp, maxLevel = SeasonConfig.MaxLevel, xpPerLevel = SeasonConfig.XpPerLevel } })
end)


