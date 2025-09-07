# QBX Admin Integration (txAdmin-first with EasyAdmin fallback)

Admin tools for QBX with ox_lib UI, rate limiting, and Discord webhook audits. Works txAdmin-first for permissions, with optional EasyAdmin fallback.

## Requirements
- `qbx_core`
- `ox_lib`
- (optional) `chat` for suggestions
- (optional) EasyAdmin (fallback)

## Install
1. Drop the folder as `qbx_easyadmin` in your `resources/`.
2. Ensure deps first, then this resource:
   ```cfg
   ensure ox_lib
   ensure qbx_core
   # ensure easyadmin   # only if using fallback
   ensure chat         # optional, for / suggestions
   ensure qbx_easyadmin
   ```

3. (Optional) Configure Discord webhooks in `server.cfg`:

   ```cfg
   # one global webhook
   setr qbx_admin_webhook "https://discord.com/api/webhooks/XXXX/YYY"

   # or per-category overrides
   setr qbx_admin_webhook_money "https://discord.com/api/webhooks/..money.."
   setr qbx_admin_webhook_job   "https://discord.com/api/webhooks/..job.."
   setr qbx_admin_webhook_gang  "https://discord.com/api/webhooks/..gang.."
   ```

## Config

Create/edit `resources/qbx_easyadmin/config.lua`:

```lua
Config = {
    UseEasyAdmin = false, -- also register EasyAdmin-prefixed commands/permissions when true
}
```

## Permissions (txAdmin-first; ACE/EasyAdmin fallback)

Give your admin group the abilities (and optional rate-limit bypass):

```cfg
# When txAdmin is running, the resource will honor txAdmin groups/permissions
# via `txAdmin:isPlayerTrusted` and `txAdmin:hasPerm` (server-side). You should
# assign custom permissions like:
#   qbxadmin.money, qbxadmin.job, qbxadmin.gang, qbxadmin.info, qbxadmin.heal, qbxadmin.revive
# to the desired txAdmin roles.
#
# For fallback without txAdmin, add ACE permissions below (or grant via EasyAdmin):

add_ace group.admin easyadmin.qbx.money allow
add_ace group.admin easyadmin.qbx.job allow
add_ace group.admin easyadmin.qbx.gang allow
add_ace group.admin easyadmin.qbx.info allow

# Optional: let head admins bypass rate limiting
add_ace group.superadmin easyadmin.qbx.bypassratelimit allow

# Client commands are registered with "restricted=true" and expect ACE like:
add_ace group.admin command.easyadmin_qbx_givemoney allow
add_ace group.admin command.easyadmin_qbx_removemoney allow
add_ace group.admin command.easyadmin_qbx_setmoney allow
add_ace group.admin command.easyadmin_qbx_setjob allow
add_ace group.admin command.easyadmin_qbx_setjobgrade allow
add_ace group.admin command.easyadmin_qbx_toggleduty allow
add_ace group.admin command.easyadmin_qbx_setgang allow
add_ace group.admin command.easyadmin_qbx_setganggrade allow
add_ace group.admin command.easyadmin_qbx_playerinfo allow
add_ace group.admin command.easyadmin_qbx_menu allow
add_ace group.admin command.easyadmin_qbx_menu_aim allow
```

> If you use EasyAdmin’s internal permission system, grant equivalent permissions there:
> `easyadmin.qbx.money`, `easyadmin.qbx.job`, `easyadmin.qbx.gang`, `easyadmin.qbx.info`, `easyadmin.qbx.bypassratelimit`.

## Usage

**Slash commands** (all accept optional `serverId`; if omitted you’ll be prompted). Neutral commands are also provided for txAdmin/console use:

* `/easyadmin_qbx_givemoney [serverId]` (or `/qbxadmin_givemoney`)
* `/easyadmin_qbx_removemoney [serverId]` (or `/qbxadmin_removemoney`)
* `/easyadmin_qbx_setmoney [serverId]` (or `/qbxadmin_setmoney`)
* `/easyadmin_qbx_setjob [serverId]` (or `/qbxadmin_setjob`)
* `/easyadmin_qbx_setjobgrade [serverId]` (or `/qbxadmin_setjobgrade`)
* `/easyadmin_qbx_toggleduty [serverId]` (or `/qbxadmin_toggleduty`)
* `/easyadmin_qbx_setgang [serverId]` (or `/qbxadmin_setgang`)
* `/easyadmin_qbx_setganggrade [serverId]` (or `/qbxadmin_setganggrade`)
* `/easyadmin_qbx_playerinfo [serverId]` (or `/qbxadmin_playerinfo`)
* `/easyadmin_qbx_menu [serverId]` (or `/qbxadmin_menu`) (ox_lib context menu)
* `/easyadmin_qbx_menu_aim` (aim at a player, then run)

**Keybinds**
Blank by default; bind in FiveM keybinds menu. Examples: `QBX: Give Money`, `QBX: Admin Menu`, etc.

**Exports** (for txAdmin menu bindings or other UIs):

* `exports['qbx_easyadmin']:giveMoney(serverId)`
* `removeMoney(serverId)`
* `setMoney(serverId)`
* `setJob(serverId)`
* `setJobGrade(serverId)`
* `toggleDuty(serverId)`
* `setGang(serverId)`
* `setGangGrade(serverId)`
* `getPlayerInfo(serverId)`
* `showTargetMenu(serverId)`

## Notes / Safety

* Server revalidates **player online**, **permissions**, **account**, **amount**, and rate-limits actions.
* Per-category Discord webhooks let you pipe money/job/gang events to different channels.
* Job/Gang setters check existence via `qbx_core` helpers when available.
* `GetPlayerIdentifierByType` fallback supports runtimes where that native isn’t exposed.

Enjoy! If you want this zipped or want me to tune limits (max amounts/grades, rate ms) or add localization, tell me your prefs and I’ll bake them in.


