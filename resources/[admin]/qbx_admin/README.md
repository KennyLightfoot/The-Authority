# qbx_admin

Lightweight admin menu for QBX/QBCore using ox_lib context menus.

## Features
- Players: teleport, bring/return, spectate, freeze, heal/armor/revive, warn, kick
- Economy: give/take cash and give item with caps, cooldowns and reason prompts
- Vehicles: repair, clean, flip and delete nearest
- Utilities: noclip, show identifiers, server-wide announce
- Optional Discord logging via `admin_webhook`

## Installation
1. Place this resource in `resources/[admin]/qbx_admin`.
2. In `server.cfg` ensure dependencies and (optionally) set the webhook:
   ```
   ensure ox_lib
   ensure qbx_core
   ensure qbx_admin
   set admin_webhook ""
   ```

## Dependencies
- [qbx-core](https://github.com/Qbox-project/qbx-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- Optional: [ox_inventory](https://github.com/overextended/ox_inventory)

## ACE examples
```
add_principal identifier.discord:123456789012345678 group.admin
add_ace group.admin qbxadmin.* allow

add_principal identifier.discord:234567890123456789 group.moderator
add_ace group.moderator qbxadmin.tp allow
add_ace group.moderator qbxadmin.freeze allow
add_ace group.moderator qbxadmin.medical allow
add_ace group.moderator qbxadmin.moderation allow
add_ace group.moderator qbxadmin.ids allow
add_ace group.moderator qbxadmin.announce allow
```

## Config reference
See `config.lua` for caps, cooldowns, whitelists and feature toggles.

## Known limits / Phase 2
- Billing is stubbed until Phase 2
- Job/duty tools are out of scope
- Teleporters and player reports are not yet implemented

