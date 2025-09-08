local started = false
local function startOnboarding()
  if started then return end
  started = true
  -- Show simple path selection (ox_lib inputDialog)
  local input = lib.inputDialog('Choose your path', {
    { type = 'select', label = 'Path', options = {
      {label='Pioneer', value='pioneer'},
      {label='Rebel', value='rebel'}
    }}
  })
  local path = input and input[1] or 'undecided'
  TriggerServerEvent(EVENTS.SET_PATH, path)
  lib.notify({description='Follow the waypoints to complete onboarding.', type='info'})
  -- … guide steps here …
  -- When finished:
  TriggerServerEvent(EVENTS.ONBOARDING_DONE)
end

-- call startOnboarding() based on your join logic or TextUI prompt
