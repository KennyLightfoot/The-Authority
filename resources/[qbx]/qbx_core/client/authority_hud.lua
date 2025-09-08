local meta = { authority = 0, heat = 0, path = 'undecided', pass_level = 0, pass_xp = 0 }

RegisterNetEvent(CLIENT.META_PUSH, function(m)
  meta = m or meta
  SendNUIMessage({ type = 'authority:update', data = meta })
end)

CreateThread(function()
  Wait(1500)
  TriggerServerEvent(EVENTS.REQ_META)
end)

-- Minimal NUI toggles (assumes a shared NUI page exists or future addition)
RegisterCommand('authhud', function()
  SetNuiFocus(false, false)
  SendNUIMessage({ type = 'authority:toggle' })
end, false)


