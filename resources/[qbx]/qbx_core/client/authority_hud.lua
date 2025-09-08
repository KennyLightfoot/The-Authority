local meta = { authority = 0, heat = 0, path = 'undecided' }

RegisterNetEvent(CLIENT.META_PUSH, function(m)
  meta = m or meta
  -- Update your NUI/HUD here (SendNUIMessage meta, etc.)
end)

CreateThread(function()
  -- On spawn, request meta
  Wait(1500)
  TriggerServerEvent(EVENTS.REQ_META)
end)
