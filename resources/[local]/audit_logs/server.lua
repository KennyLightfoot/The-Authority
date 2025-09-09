local webhook = GetConvar('authority_audit_webhook', '')

local function esc(s) return s and tostring(s):gsub('[\\"]','') or '' end

exports('write', function(src, action, ctx)
  local id
  if src == nil then
    id = 'server'
  else
    local lic = GetPlayerIdentifierByType(src, 'license')
    id = lic or tostring(src)
  end
  local payload = ctx and json.encode(ctx) or '{}'

  if GetResourceState('oxmysql') == 'started' then
    MySQL.insert.await('INSERT INTO audit_logs (player_identifier, action, context) VALUES (?, ?, ?)', { id, action, payload })
  end

  if webhook ~= '' then
    PerformHttpRequest(webhook, function() end, 'POST', json.encode({
      username = 'Audit',
      embeds = { {
        title = action,
        description = ("`%s`%s"):format(esc(id), src and (" (src "..src..")") or ""),
        fields = { { name = 'ctx', value = ("```json\n%s\n```"):format(payload:sub(1, 1900)) } },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
      } },
    }), { ['Content-Type'] = 'application/json' })
  end
end)


