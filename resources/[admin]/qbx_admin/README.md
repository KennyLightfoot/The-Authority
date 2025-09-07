# qbx_admin (txAdmin-first)

Neutral admin actions for QBX with txAdmin-first permissions and optional EasyAdmin compatibility.

## Install
1) Place in `resources/[admin]/qbx_admin`.
2) Ensure after `ox_lib` and `qbx_core` in your server.cfg:


ensure ox_lib
ensure qbx_core
ensure [admin]

3) (Optional) Set webhooks in `server.cfg` (or leave blank to disable):


set qbx_admin_webhook "https://discord.com/api/webhooks/
..."
set qbx_admin_webhook_money "..."
set qbx_admin_webhook_job "..."
set qbx_admin_webhook_gang "..."


## Permissions (txAdmin Admin Manager or ACE)
Grant via txAdmin Admin Manager **or** ACE:


add_ace group.admin qbxadmin.money allow
add_ace group.admin qbxadmin.job allow
add_ace group.admin qbxadmin.gang allow
add_ace group.admin qbxadmin.info allow
add_ace group.admin qbxadmin.heal allow
add_ace group.admin qbxadmin.revive allow
add_ace group.admin qbxadmin.bypassratelimit allow


If you still need legacy EasyAdmin compat, set `Config.UseEasyAdmin = true` in `config.lua`. The server will also respect EasyAdmin’s `DoesPlayerHavePermission` for `easyadmin.qbx.*` keys.

## Client commands (with target prompt if omitted)


/qbxadmin_givemoney <id>
/qbxadmin_removemoney <id>
/qbxadmin_setmoney <id>
/qbxadmin_setjob <id>
/qbxadmin_setjobgrade <id>
/qbxadmin_toggleduty <id>
/qbxadmin_setgang <id>
/qbxadmin_setganggrade <id>
/qbxadmin_info <id>
/qbxadmin_heal <id>
/qbxadmin_revive <id>
/qbxadmin_menu <id> (ox_lib context UI)
/qbxadmin_menu_aim (aim at player and run)


## Server console commands (for txAdmin Remote Console / Menu)


qbxadmin_givemoney <id> <cash|bank> <amount>
qbxadmin_removemoney <id> <cash|bank> <amount>
qbxadmin_setmoney <id> <cash|bank> <amount>
qbxadmin_setjob <id> <job>
qbxadmin_setjobgrade <id> <grade>
qbxadmin_toggleduty <id>
qbxadmin_setgang <id> <gang>
qbxadmin_setganggrade <id> <grade>
qbxadmin_heal <id>
qbxadmin_revive <id>
qbxadmin_info <id>


## txAdmin Menu examples
Create **Custom Buttons** in txAdmin “Player Modal”:
- Heal: `qbxadmin_heal {{id}}`
- Revive: `qbxadmin_revive {{id}}`
- Give $500 cash: `qbxadmin_givemoney {{id}} cash 500`
- Set Job police: `qbxadmin_setjob {{id}} police`
- Job Grade 3: `qbxadmin_setjobgrade {{id}} 3`
- Toggle Duty: `qbxadmin_toggleduty {{id}}`
- Set Gang ballas: `qbxadmin_setgang {{id}} ballas`
- Gang Grade 2: `qbxadmin_setganggrade {{id}} 2`
- Info: `qbxadmin_info {{id}}`

## Notes
- All actions are rate-limited; grant `qbxadmin.bypassratelimit` for bypass (e.g., owners).
- Webhook auditing is per-category (Money/Job/Gang) with a fallback default webhook.
- If `Config.UseEasyAdmin = true`, legacy `/easyadmin_qbx_*` aliases and `EasyAdmin:QBX:*` events remain usable.

# QBX Admin (txAdmin-first, EasyAdmin fallback)

Neutral admin actions for Qbox with ox_lib UI, Discord audits, and txAdmin-first permissions. EasyAdmin compatibility is optional via Config.UseEasyAdmin.

Install
- ensure `ox_lib`, `qbx_core`, then this resource:
```
ensure ox_lib
ensure qbx_core
ensure [admin]
```

Config (config.lua)
```
Config = {}
Config.UseEasyAdmin = false
Config.Perms = {
  money  = 'qbxadmin.money',
  job    = 'qbxadmin.job',
  gang   = 'qbxadmin.gang',
  info   = 'qbxadmin.info',
  heal   = 'qbxadmin.heal',
  revive = 'qbxadmin.revive',
  bypass = 'qbxadmin.bypassratelimit',
}
Config.Webhooks = {
  default = GetConvar('qbx_admin_webhook', ''),
  money   = GetConvar('qbx_admin_webhook_money', ''),
  job     = GetConvar('qbx_admin_webhook_job',   ''),
  gang    = GetConvar('qbx_admin_webhook_gang',  ''),
}
```

Console/txAdmin commands
- qbxadmin_givemoney <id> <cash|bank> <amount>
- qbxadmin_removemoney <id> <cash|bank> <amount>
- qbxadmin_setmoney <id> <cash|bank> <amount>
- qbxadmin_setjob <id> <job>
- qbxadmin_setjobgrade <id> <grade>
- qbxadmin_toggleduty <id>
- qbxadmin_setgang <id> <gang>
- qbxadmin_setganggrade <id> <grade>
- qbxadmin_heal <id>
- qbxadmin_revive <id>
- qbxadmin_info <id>

txAdmin menu buttons (examples)
- Heal: `qbxadmin_heal {{id}}`
- Revive: `qbxadmin_revive {{id}}`
- Give $500 cash: `qbxadmin_givemoney {{id}} cash 500`
- Set Job police: `qbxadmin_setjob {{id}} police` then `qbxadmin_setjobgrade {{id}} 2`
- Toggle Duty: `qbxadmin_toggleduty {{id}}`
- Info: `qbxadmin_info {{id}}`

ACE Permissions (fallback or to back txAdmin groups)
```
add_ace group.admin qbxadmin.money allow
add_ace group.admin qbxadmin.job allow
add_ace group.admin qbxadmin.gang allow
add_ace group.admin qbxadmin.info allow
add_ace group.admin qbxadmin.heal allow
add_ace group.admin qbxadmin.revive allow
add_ace group.admin qbxadmin.bypassratelimit allow
```

Client UX
- ox_lib context menus (`/qbxadmin_menu`, `/qbxadmin_menu_aim`)
- Aim-at-player quick actions (F6 heal, F7 revive)
- Notifications via lib.notify
- If `Config.UseEasyAdmin=true`, legacy `/easyadmin_qbx_*` aliases are also available

Auditing
- Console print + Discord embeds with per-category overrides
