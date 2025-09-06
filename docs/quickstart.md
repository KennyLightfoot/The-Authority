# Quick Start Guide - The Authority

This guide will help you set up "The Authority" FiveM server from scratch on both Windows and Linux.

## Prerequisites

- FiveM Server License Key
- MySQL 8.0+ Database Server
- Discord Bot Token
- Basic knowledge of server administration

## Windows Setup (txAdmin)

### 1. Install Dependencies

1. **Download and install MySQL**:
   - Download MySQL 8.0+ from [mysql.com](https://dev.mysql.com/downloads/mysql/)
   - Create a database named `authority`
   - Create a user with full permissions to the database

2. **Download FiveM Server**:
   - Download from [FiveM.net](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/)
   - Extract to `C:\FXServer\`

3. **Install txAdmin**:
   - txAdmin comes bundled with FiveM server
   - Run `FXServer.exe` to start txAdmin setup

### 2. Server Configuration

1. **Clone/Download The Authority**:
   ```cmd
   cd C:\FXServer\
   git clone <repository-url> server-data
   cd server-data
   ```

2. **Configure Environment**:
   ```cmd
   copy env.example .env
   notepad .env
   ```
   
   Update the following values:
   ```env
   MYSQL_DSN="mysql://username:password@localhost/authority?charset=utf8mb4"
   DISCORD_TOKEN="your_discord_bot_token"
   DISCORD_GUILD_ID="your_discord_server_id"
   FIVEM_LICENSE_KEY="your_license_key"
   ```

3. **Update server.cfg**:
   ```cfg
   # Update these lines in server.cfg
   sv_licenseKey "your_license_key_here"
   set mysql_connection_string "mysql://username:password@localhost/authority?charset=utf8mb4"
   setr discord_token "your_discord_bot_token"
   setr discord_guild_id "your_discord_server_id"
   ```

### 3. Download Resources

Download the following resources and place them in the correct folders:

#### [ox] Folder:
- **ox_lib**: [Download latest release](https://github.com/overextended/ox_lib/releases)
- **ox_inventory**: [Download latest release](https://github.com/overextended/ox_inventory/releases)
- **ox_target**: [Download latest release](https://github.com/overextended/ox_target/releases)
- **PolyZone**: [Download latest release](https://github.com/mkafrin/PolyZone/releases)

#### [qbx] Folder:
- **qbx_core**: [Download latest release](https://github.com/Qbox-project/qbx_core/releases)
- **qbx_vehiclekeys**: [Download latest release](https://github.com/Qbox-project/qbx_vehiclekeys/releases)
- **qbx_garages**: [Download latest release](https://github.com/Qbox-project/qbx_garages/releases)

#### [standalone] Folder:
- **Renewed-Banking**: [Download latest release](https://github.com/Renewed-Scripts/Renewed-Banking/releases)
- **illenium-appearance**: [Download latest release](https://github.com/iLLeniumStudios/illenium-appearance/releases)
- **EasyAdmin**: [Download latest release](https://github.com/Blumlaut/EasyAdmin/releases)
- **Badger_Discord_API**: [Download latest release](https://github.com/JaredScar/Badger_Discord_API/releases)

#### [jobs] Folder:
- **qb-garbagejob**: [Download latest release](https://github.com/qbcore-framework/qb-garbagejob/releases)
- **qb-delivery**: [Download latest release](https://github.com/qbcore-framework/qb-delivery/releases)

#### [voice] Folder:
- **pma-voice**: [Download latest release](https://github.com/AvarianKnight/pma-voice/releases)

### 4. Start Server

1. **Using txAdmin**:
   - Open txAdmin web interface (usually http://localhost:40120)
   - Create new server profile
   - Point to your `server.cfg` file
   - Start the server

2. **Direct Start**:
   ```cmd
   cd C:\FXServer\
   FXServer.exe +exec server-data/server.cfg
   ```

## Linux Setup (systemd)

### 1. Install Dependencies

1. **Install MySQL**:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install mysql-server
   
   # CentOS/RHEL
   sudo yum install mysql-server
   
   # Create database
   sudo mysql -u root -p
   CREATE DATABASE authority;
   CREATE USER 'fivem'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON authority.* TO 'fivem'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

2. **Download FiveM Server**:
   ```bash
   cd /opt
   sudo wget https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/fx.tar.xz
   sudo tar -xf fx.tar.xz
   sudo mv fx fivem-server
   sudo chown -R fivem:fivem fivem-server
   ```

### 2. Server Configuration

1. **Clone The Authority**:
   ```bash
   cd /opt/fivem-server
   sudo git clone <repository-url> server-data
   sudo chown -R fivem:fivem server-data
   ```

2. **Configure Environment**:
   ```bash
   cd server-data
   cp env.example .env
   nano .env
   ```

3. **Update server.cfg** (same as Windows section)

### 3. Download Resources

Follow the same resource download steps as Windows, but extract to Linux paths.

### 4. Create systemd Service

1. **Create service file**:
   ```bash
   sudo nano /etc/systemd/system/fivem.service
   ```

2. **Service configuration**:
   ```ini
   [Unit]
   Description=FiveM Server - The Authority
   After=network.target mysql.service
   
   [Service]
   Type=simple
   User=fivem
   WorkingDirectory=/opt/fivem-server
   ExecStart=/opt/fivem-server/run.sh +exec server-data/server.cfg
   Restart=always
   RestartSec=10
   
   [Install]
   WantedBy=multi-user.target
   ```

3. **Enable and start**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable fivem
   sudo systemctl start fivem
   ```

## Discord Bot Setup

### 1. Create Discord Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Create new application
3. Go to "Bot" section
4. Create bot and copy token
5. Enable "Server Members Intent" and "Message Content Intent"

### 2. Add Bot to Server

1. Go to "OAuth2" > "URL Generator"
2. Select "bot" scope
3. Select "Administrator" permission (or customize as needed)
4. Use generated URL to add bot to your Discord server

### 3. Configure Role Mappings

Edit `resources/[standalone]/discord_perms/config.lua`:

```lua
Config.RoleMapping = {
    ['YOUR_OWNER_ROLE_ID'] = 'owner',
    ['YOUR_ADMIN_ROLE_ID'] = 'admin',
    ['YOUR_MOD_ROLE_ID'] = 'moderator',
    -- Add more role mappings as needed
}
```

To get role IDs:
1. Enable Developer Mode in Discord
2. Right-click on roles and "Copy ID"

## Testing Your Setup

### 1. Run QA Tests

Once your server is running, connect and run:
```
/qa:base
```

This should show all green checkmarks (✅) for:
- Database connection
- Resource exports
- Apartment configuration
- Payment system

### 2. Test Player Flow

1. **Create Character**: Use illenium-appearance
2. **Select Apartment**: Choose from available apartments
3. **Test Features**:
   - Stash access in apartment
   - Wardrobe functionality
   - Vehicle spawning and keys
   - Job completion and payouts

### 3. Test Admin Features

1. **EasyAdmin**: Access admin panel
2. **Discord Perms**: Verify role-based permissions
3. **Commands**: Test admin commands work properly

## Troubleshooting

### Common Issues

1. **Database Connection Failed**:
   - Check MySQL service is running
   - Verify connection string format
   - Test database credentials

2. **Resources Not Loading**:
   - Check folder structure matches exactly
   - Verify all dependencies are present
   - Check server console for error messages

3. **Discord Integration Not Working**:
   - Verify bot token is correct
   - Check bot has proper permissions
   - Ensure guild ID is correct

4. **QA Tests Failing**:
   - Run `/qa:base` to see specific failures
   - Check resource load order in server.cfg
   - Verify all exports are available

### Performance Optimization

1. **Database**:
   - Use SSD storage for database
   - Optimize MySQL configuration
   - Regular database maintenance

2. **Server**:
   - Allocate sufficient RAM (8GB+ recommended)
   - Use fast CPU (3.0GHz+ recommended)
   - Monitor resource usage

3. **Network**:
   - Use dedicated server hosting
   - Ensure stable internet connection
   - Configure proper firewall rules

## Next Steps

1. **Customize Apartments**: Add more locations in config
2. **Add More Jobs**: Integrate additional job resources
3. **Configure Police**: Set up police resources in `[police]` folder
4. **Enable NPWD**: Uncomment phone system when ready
5. **Add Custom Resources**: Place in `[local]` folder

## Support

- Check server console logs for errors
- Use `/qa:base` for system health checks
- Verify all resources are latest stable versions
- Join The Authority Discord for community support



