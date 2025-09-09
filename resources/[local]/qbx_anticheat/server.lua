local RATE = 3 -- per second per RPC key

local playerBuckets = {}

local function nowMs()
  return GetGameTimer()
end

local function bucketKey(src, rpcName)
  return (src or 0) .. ':' .. rpcName
end

local function allow(src, rpcName)
  local key = bucketKey(src, rpcName)
  local b = playerBuckets[key]
  local t = nowMs()
  if not b or t - b.ts > 1000 then
    playerBuckets[key] = { ts = t, count = 1 }
    return true
  end
  if b.count < RATE then
    b.count = b.count + 1
    return true
  end
  return false
end

exports('ratelimit', function(src, rpcName)
  return allow(src, rpcName)
end)

-- One-shot transaction token store
local tokens = {}

local function generateToken(src, kind)
  local token = ('%s:%s:%d:%d'):format(kind, src, nowMs(), math.random(100000, 999999))
  tokens[token] = true
  return token
end

exports('issueToken', generateToken)

exports('consumeToken', function(token)
  if tokens[token] then
    tokens[token] = nil
    return true
  end
  return false
end)


