RegisterNetEvent('authority:client:seasonMessage', function(msg)
  lib.notify({ description = msg, type = 'info' })
end)
