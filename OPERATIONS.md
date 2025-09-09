# OPERATIONS

## Profiles
- Staging = Prod resources; prod only differs via convars (security stricter).

## Release
- CI: luacheck, stylua, fxmanifest validation, SQL dry-run.
- Tag -> artifact zip (configs + resource hashes).
- Maintenance windows: Tue/Thu 1:00–1:30 AM CT.
- Rollback: stop → swap artifact → restart → verify health checks.

## Backups & DR
- Nightly DB (35d), weekly full snapshot (12w).
- Restore rehearsal: perform once pre-launch, quarterly thereafter.

## Monitoring
- Resmon idle gates: core ≤0.20 ms, warn at 0.30 ms.
- Daily Discord KPI digest (players peak/avg, sinks/sources, job runs, top errors).

## Playbooks
- Economy dupe: disable shops via convar → isolate audits → hotfix validation → re-enable.
- Stash dupe: freeze inventory ops → migrate to tokenized transfers → spot-audit last 4h.
- Vehicle spam: limit spawns per 5m → lock down offending resource → mod-log actions.


