# The Authority - FiveM QBX Server

A production-ready FiveM server starter built on the QBX framework, designed for "The Authority" GTA RP server.

## 🚀 Features

- **QBX Framework** - Modern, stable framework with active development
- **Banking System** - Renewed-Banking integration for all transactions
- **Vehicle System** - Complete vehicle management with keys and garages
- **Apartment System** - Simple spawn/stash/wardrobe system for new players
- **Job System** - Garbage collection and delivery jobs with bank payouts
- **Admin Tools** - EasyAdmin with Discord role integration
- **Quality Assurance** - Built-in testing and health monitoring tools

## 📋 Requirements

- **FiveM Server** (Windows or Linux)
- **MySQL Database** (8.0+ recommended)
- **Discord Bot** (for admin permissions)
- **txAdmin** (recommended for server management)

## 🛠️ Quick Start

1. **Clone or download** this repository to your FiveM server directory

2. **Configure Environment**:
   ```bash
   cp env.example .env
   # Edit .env with your database and Discord credentials
   ```

3. **Database Setup**:
   - Create a MySQL database named `authority`
   - Update connection string in `server.cfg` or `.env`

4. **Discord Setup**:
   - Create a Discord bot and get the token
   - Add bot to your Discord server
   - Update Discord configuration in `server.cfg`

5. **Download Resources**:
   - Download required resources (see `docs/versions.md` for exact versions)
   - Place them in the appropriate `resources/[category]/` folders

6. **Start Server**:
   ```bash
   # Windows (txAdmin)
   start server.cfg
   
   # Linux (systemd)
   ./run.sh +exec server.cfg
   ```

## 🧪 Testing

Run the built-in smoke tests to verify everything is working:

```
/qa:base
```

This will check:
- ✅ Database connection
- ✅ Resource exports (ox_lib, banking, vehicles, etc.)
- ✅ Apartment configuration
- ✅ Payment system functionality

Additional QA commands:
- `/qa:notify [message]` - Test notification system
- `/qa:coords` - Get current coordinates
- `/qa:vehicle` - Get vehicle information

## 📁 Folder Structure

```
resources/
├── [ox]/           # Overextended resources
├── [qbx]/          # QBX framework resources  
├── [standalone]/   # Standalone resources
├── [jobs]/         # Job-related resources
├── [local]/        # Custom server resources
├── [police]/       # Police resources (empty initially)
└── [voice]/        # Voice chat resources

migrations/         # Database migration files
docs/              # Documentation
config/            # Configuration files
```

## 🔧 Configuration

### Database
Update the MySQL connection string in `server.cfg`:
```cfg
set mysql_connection_string "mysql://user:pass@localhost/authority?charset=utf8mb4"
```

### Discord Integration
Configure Discord bot settings:
```cfg
setr discord_token "your_bot_token"
setr discord_guild_id "your_server_id"
```

Update role mappings in `resources/[standalone]/discord_perms/config.lua`

### Apartments
Modify apartment locations in `resources/[local]/apartments/config.lua`

## 🎮 Player Experience

### New Player Flow
1. **Character Creation** - Uses illenium-appearance
2. **Apartment Selection** - Choose from 3 starter apartments
3. **Spawn System** - Automatic spawn at assigned apartment
4. **Banking** - All transactions go through Renewed-Banking
5. **Jobs** - Start with garbage collection or delivery jobs

### Available Jobs
- **Garbage Collection** - Collect trash bags and complete routes
- **Delivery Service** - Pick up and deliver packages around the city

### Vehicle System
- **Garages** - Store and retrieve vehicles
- **Vehicle Keys** - Automatic key management
- **Ownership** - Persistent vehicle ownership system

## 🛡️ Admin Features

### EasyAdmin Integration
- Web-based admin panel
- Player management (kick, ban, teleport)
- Server monitoring and controls

### Discord Permissions
- Automatic role-based permissions
- ACE group integration
- Real-time permission updates

### QA Tools
- Health monitoring
- Automated testing
- Performance metrics

## 🔄 Database Migrations

The server includes an automatic migration system:
- Migrations run automatically on server start
- Located in `/migrations/` folder
- Tracked in `db_migrations` table
- Safe to run multiple times

## 📚 Documentation

- [Quick Start Guide](docs/quickstart.md) - Detailed setup instructions
- [Version Information](docs/versions.md) - Resource versions and sources

## 🤝 Contributing

1. Keep commits small and descriptive
2. Test changes with `/qa:base` before committing
3. Update `docs/versions.md` when adding new resources
4. Follow the existing folder structure

## 📄 License

This project is provided as-is for "The Authority" FiveM server. Modify as needed for your server.

## 🆘 Support

- Check `/qa:base` output for common issues
- Verify all resources are in correct folders
- Ensure database connection is working
- Check Discord bot permissions

---

**The Authority Development Team**







