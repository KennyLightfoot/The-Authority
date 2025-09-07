Config = {}

-- If true, also register legacy EasyAdmin aliases and listen to EasyAdmin:QBX:* events (back-compat)
Config.UseEasyAdmin = false

-- Rate-limit window in ms for action spam protection (client + server)
Config.RateMs = 750

-- Permission keys (txAdmin/ACE first, EasyAdmin fallback if available)
-- Grant with txAdmin Admin Manager (recommended) or with ACE in server.cfg:
--   add_ace group.admin qbxadmin.money allow
--   add_ace group.admin qbxadmin.job allow
--   add_ace group.admin qbxadmin.gang allow
--   add_ace group.admin qbxadmin.info allow
--   add_ace group.admin qbxadmin.heal allow
--   add_ace group.admin qbxadmin.revive allow
--   add_ace group.admin qbxadmin.bypassratelimit allow
Config.Perms = {
    money  = 'qbxadmin.money',
    job    = 'qbxadmin.job',
    gang   = 'qbxadmin.gang',
    info   = 'qbxadmin.info',
    heal   = 'qbxadmin.heal',
    revive = 'qbxadmin.revive',
    bypass = 'qbxadmin.bypassratelimit',
}

-- Account types validated server-side
Config.ValidAccounts = { cash = true, bank = true }
Config.MaxMoneyAmount = 1000000
Config.MaxJobGrade    = 10
Config.MaxGangGrade   = 10

-- Webhooks (set to "" to disable). You can override by category, else fallback to Default
Config.Webhooks = {
    Default = GetConvar('qbx_admin_webhook', ''),
    Money   = GetConvar('qbx_admin_webhook_money', ''),
    Job     = GetConvar('qbx_admin_webhook_job',   ''),
    Gang    = GetConvar('qbx_admin_webhook_gang',  ''),
}

Config = Config or {}

-- If true, also register legacy EasyAdmin prefixes/aliases and permissions.
Config.UseEasyAdmin = false

-- Permissions map (txAdmin-first; fallback to EasyAdmin/ACE)
Config.Perms = {
	money  = 'qbxadmin.money',
	job    = 'qbxadmin.job',
	gang   = 'qbxadmin.gang',
	info   = 'qbxadmin.info',
	heal   = 'qbxadmin.heal',
	revive = 'qbxadmin.revive',
	bypass = 'qbxadmin.bypassratelimit',
}

-- Discord webhooks (or leave empty to disable)
Config.Webhooks = {
	default = GetConvar('qbx_admin_webhook', ''),
	money   = GetConvar('qbx_admin_webhook_money', ''),
	job     = GetConvar('qbx_admin_webhook_job',   ''),
	gang    = GetConvar('qbx_admin_webhook_gang',  ''),
}


