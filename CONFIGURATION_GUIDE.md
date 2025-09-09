# Configuration Guide - The Authority

## 🔧 Step-by-Step Configuration

### 1. Database Configuration

Update the MySQL connection string in `server.cfg`:

```cfg
# Replace this line in server.cfg:
set mysql_connection_string "mysql://user:pass@127.0.0.1/authority?charset=utf8mb4"

# With your actual MySQL credentials:
set mysql_connection_string "mysql://fivem:YOUR_PASSWORD@127.0.0.1/authority?charset=utf8mb4"
```

### 2. Discord Bot Configuration

Update Discord settings in `server.cfg`:

```cfg
# Replace these lines in server.cfg:
setr discord_token "changeme"
setr discord_guild_id "000000000000"

# With your actual Discord bot credentials:
setr discord_token "YOUR_DISCORD_BOT_TOKEN"
setr discord_guild_id "YOUR_DISCORD_SERVER_ID"
```

**How to get Discord credentials:**
1. Go to https://discord.com/developers/applications
2. Create a new application
3. Go to "Bot" section and create a bot
4. Copy the bot token
5. Enable "Server Members Intent" and "Message Content Intent"
6. Get your Discord server ID (enable Developer Mode, right-click server, Copy ID)

### 3. FiveM License Key

Update in `server.cfg`:

```cfg
# Replace this line:
sv_licenseKey "changeme"

# With your actual license key:
sv_licenseKey "YOUR_FIVEM_LICENSE_KEY"
```

**How to get FiveM license key:**
1. Go to https://keymaster.fivem.net/
2. Login with your account
3. Create a new server key
4. Copy the key

### 4. Steam Web API Key (Optional)

Update in `server.cfg`:

```cfg
# Replace this line:
steam_webApiKey "changeme"

# With your Steam Web API key:
steam_webApiKey "YOUR_STEAM_WEB_API_KEY"
```

**How to get Steam Web API key:**
1. Go to https://steamcommunity.com/dev/apikey
2. Enter your domain (can be localhost for testing)
3. Copy the API key

### 5. Discord Role Mapping

Edit `resources/[standalone]/discord_perms/config.lua`:

```lua
Config.RoleMapping = {
    -- Replace these with your actual Discord role IDs:
    ['123456789012345678'] = 'owner',      -- Your Owner role ID
    ['123456789012345679'] = 'admin',      -- Your Admin role ID  
    ['123456789012345680'] = 'moderator',  -- Your Moderator role ID
    ['123456789012345681'] = 'helper',     -- Your Helper role ID
    ['123456789012345682'] = 'vip',        -- Your VIP role ID
    ['123456789012345683'] = 'donator',    -- Your Donator role ID
}
```

**How to get Discord role IDs:**
1. Enable Developer Mode in Discord (User Settings > Advanced > Developer Mode)
2. Right-click on roles in your server
3. Click "Copy ID"

## 🗄️ Database Setup Commands

Run these MySQL commands to set up your database:

```sql
-- Connect to MySQL as root
mysql -u root -p

-- Create the database
CREATE DATABASE authority;

-- Create a user for FiveM
CREATE USER 'fivem'@'localhost' IDENTIFIED BY 'your_secure_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON authority.* TO 'fivem'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

## ✅ Configuration Checklist

- [ ] MySQL database `authority` created
- [ ] MySQL user `fivem` created with password
- [ ] `server.cfg` updated with MySQL connection string
- [ ] Discord bot created and token obtained
- [ ] `server.cfg` updated with Discord token and guild ID
- [ ] FiveM license key obtained and added to `server.cfg`
- [ ] Steam Web API key obtained and added to `server.cfg` (optional)
- [ ] Discord role IDs copied and added to `discord_perms/config.lua`

## 🚀 Ready to Start!

Once all configurations are complete, start your server and run `/qa:base` to verify everything is working!











