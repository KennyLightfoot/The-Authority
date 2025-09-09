local THRESH = tonumber(GetConvar('perf_warn_ms', '0.30'))
local last = {}

CreateThread(function()
  while true do
    Wait(60000)
    local resources = GetNumResources()
    for i=0,resources-1 do
      local res = GetResourceByFindIndex(i)
      if res and GetResourceState(res) == 'started' then
        local ms = GetResourceAverageTickTime(res) or 0.0
        if ms >= THRESH then
          local prev = last[res] or 0.0
          if math.abs(ms - prev) >= 0.02 then
            if GetResourceState('audit_logs') == 'started' then
              exports['audit_logs']:write(nil, 'perf_warn', { resource=res, ms=ms })
            end
            last[res] = ms
          end
        end
      end
    end
  end
end)


