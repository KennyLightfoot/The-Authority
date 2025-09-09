RegisterNetEvent('onboarding:setPath', function(path)
  local src = source
  if path ~= 'pioneer' and path ~= 'rebel' and path ~= 'undecided' then return end
  -- TODO: persist to DB via qbx_core bridge
  TriggerClientEvent('onboarding:ack', src, path)
end)


