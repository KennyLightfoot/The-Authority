local started = false

local function startOnboarding()
  if started then return end
  started = true
  local input = lib.inputDialog('Choose your path', {
    { type = 'select', label = 'Path', options = {
      { label = 'Pioneer', value = 'pioneer' },
      { label = 'Rebel', value = 'rebel' },
    }},
  })
  local path = input and input[1] or 'undecided'
  TriggerServerEvent(EVENTS.SET_PATH, path)
  lib.notify({ description = 'Follow the waypoints to complete onboarding.', type = 'info' })
  TriggerServerEvent(EVENTS.ONBOARDING_DONE)
end

-- Expose a command for quick testing
RegisterCommand('start_onboarding', function()
  startOnboarding()
end, false)


