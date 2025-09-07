# QBX ↔ EasyAdmin Integration

Admin tools that hook EasyAdmin to the QBX framework with ox_lib UI, rate limiting, and Discord webhook audits.

## Requirements
- `qbx_core`
- `ox_lib`
- (optional) `chat` for suggestions
- EasyAdmin (for your staff perms / workflows)

## Install
1. Drop the folder as `qbx_easyadmin` in your `resources/`.
2. Ensure deps first, then this resource:
   ```cfg
   ensure ox_lib
   ensure qbx_core
   ensure easyadmin
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

## Permissions (ACE / EasyAdmin)

Give your admin group the abilities (and optional rate-limit bypass):

```cfg
# EasyAdmin-style permission check (DoesPlayerHavePermission) is used when available;
# otherwise ACE is used. Add these to ACE for compatibility.

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

**Slash commands** (all accept optional `serverId`; if omitted you’ll be prompted):

* `/easyadmin_qbx_givemoney [serverId]`
* `/easyadmin_qbx_removemoney [serverId]`
* `/easyadmin_qbx_setmoney [serverId]`
* `/easyadmin_qbx_setjob [serverId]`
* `/easyadmin_qbx_setjobgrade [serverId]`
* `/easyadmin_qbx_toggleduty [serverId]`
* `/easyadmin_qbx_setgang [serverId]`
* `/easyadmin_qbx_setganggrade [serverId]`
* `/easyadmin_qbx_playerinfo [serverId]`
* `/easyadmin_qbx_menu [serverId]` (ox_lib context menu)
* `/easyadmin_qbx_menu_aim` (aim at a player, then run)

**Keybinds**
Blank by default; bind in FiveM keybinds menu. Examples: `QBX: Give Money`, `QBX: Admin Menu`, etc.

**Exports** (for EasyAdmin buttons or other UIs):

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


