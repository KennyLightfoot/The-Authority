# Go-Live Verification Checklist (On-Call)

## Before Start
- Confirm `config/secrets.cfg` has valid: sv_licenseKey, mysql_connection_string, discord_token, discord_guild_id
- Ensure firewall allows UDP/TCP 30120 and blocks txAdmin web port from public if required
- Verify txAdmin profile: OneSync enabled appropriately; player cap sane; 2FA on; webhook set

## Start Server
- Start profile via txAdmin or `start_server_permanent.bat`
- Watch console for `oxmysql`, `ox_lib`, `qbx_core`, `ox_inventory`, `ox_target`, `PolyZone`, `pma-voice`, `healthcheck` → all must be `started`
- Probe health: `curl http://127.0.0.1:30121/health` → HTTP 200 and `ok:true`

## Smoke Tests (2 clients)
- Voice: talk in proximity; toggle cycle (F11); radio PTT if configured
- Banking: complete a delivery/garbage action → balance updates in DB; Renewed-Banking exports OK
- Inventory: give/take items via admin command (requires ACE); cross-player give respects range/weight
- Admin: qbx_admin money/job actions require proper ACE; self-target is rejected
- Anti-abuse: try client event to add money or change job → server rejects and logs

## Data & DB
- Tables exist: `player_meta`, `bank_accounts_new`, `player_vehicles`, `vehicle_keys`, `qa_test_results`, `telemetry_events`
- `player_meta.player_path` is enum('pioneer','rebel','undecided'); `playtime_hours` exists; indices present

## Monitoring
- txAdmin Monitoring enabled with restart on crash
- Health watchdog running (healthcheck resource); endpoint returns 503 if critical resources fail
- Discord webhook receives crash/restart notifications (if configured)

## Security
- `sv_scriptHookAllowed 0` set
- No trainer/vMenu in prod profile; EasyAdmin disabled or guarded
- Secrets not committed; `.gitignore` excludes `config/secrets.cfg`, `.env`

## Post-Deploy
- Run `/qa:base`; expect all green for DB and exports
- Observe CPU/memory; watch for error spam; review `txAdmin` warnings

## Rollback Plan
- Use `backup_deployment.ps1` to restore last `txData` profile if needed
- Revert to previous resource versions per `docs/versions.md`

