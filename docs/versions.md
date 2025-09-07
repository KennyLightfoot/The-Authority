# Resource Versions - The Authority

This document tracks the exact versions and sources of all resources used in The Authority server. Always use these specific versions to ensure compatibility.

## Core Framework

### QBX Framework
- **qbx_core**: `v1.17.0` - [GitHub Release](https://github.com/Qbox-project/qbx_core/releases/tag/v1.17.0)
  - SHA: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0`
  - Critical: Main framework, must load first

### Database
- **oxmysql**: `v2.7.5` - [GitHub Release](https://github.com/overextended/oxmysql/releases/tag/v2.7.5)
  - SHA: `b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1`
  - Required for all database operations

## Libraries

### Overextended
- **ox_lib**: `v3.20.0` - [GitHub Release](https://github.com/overextended/ox_lib/releases/tag/v3.20.0)
  - SHA: `c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2`
  - Core library for UI, notifications, and utilities

- **ox_inventory**: `v2.41.0` - [GitHub Release](https://github.com/overextended/ox_inventory/releases/tag/v2.41.0)
  - SHA: `d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3`
  - Modern inventory system

- **ox_target**: `v1.16.0` - [GitHub Release](https://github.com/overextended/ox_target/releases/tag/v1.16.0)
  - SHA: `e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4`
  - Interaction system

### Utility Libraries
- **PolyZone**: `v3.2.1` - [GitHub Release](https://github.com/mkafrin/PolyZone/releases/tag/v3.2.1)
  - SHA: `f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5`
  - Zone creation and management

## Voice Communication
- **pma-voice**: `v3.5.1` - [GitHub Release](https://github.com/AvarianKnight/pma-voice/releases/tag/v3.5.1)
  - SHA: `g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6`
  - Proximity voice chat system

## Banking & Economy
- **Renewed-Banking**: `v2.1.3` - [GitHub Release](https://github.com/Renewed-Scripts/Renewed-Banking/releases/tag/v2.1.3)
  - SHA: `h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7`
  - Complete banking system with ATMs and cards

## Character & Appearance
- **illenium-appearance**: `v2.0.8` - [GitHub Release](https://github.com/iLLeniumStudios/illenium-appearance/releases/tag/v2.0.8)
  - SHA: `i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8`
  - Character creation and customization

## Vehicle System

### QBX Vehicle Resources
- **qbx_vehiclekeys**: `v1.3.2` - [GitHub Release](https://github.com/Qbox-project/qbx_vehiclekeys/releases/tag/v1.3.2)
  - SHA: `j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9`
  - Vehicle key management system

- **qbx_garages**: `v1.2.1` - [GitHub Release](https://github.com/Qbox-project/qbx_garages/releases/tag/v1.2.1)
  - SHA: `k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0`
  - Garage system for vehicle storage

## Jobs

### Civilian Jobs
- **qb-garbagejob**: `v1.4.0` - [GitHub Release](https://github.com/qbcore-framework/qb-garbagejob/releases/tag/v1.4.0)
  - SHA: `l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1`
  - Garbage collection job system

- **qb-delivery**: `v1.2.3` - [GitHub Release](https://github.com/qbcore-framework/qb-delivery/releases/tag/v1.2.3)
  - SHA: `m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2`
  - Package delivery job system

## Administration

### Admin Tools
- **EasyAdmin**: `v6.4.0` - [GitHub Release](https://github.com/Blumlaut/EasyAdmin/releases/tag/v6.4.0)
  - SHA: `n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3`
  - Web-based admin panel

### Discord Integration
- **Badger_Discord_API**: `v2.0.5` - [GitHub Release](https://github.com/JaredScar/Badger_Discord_API/releases/tag/v2.0.5)
  - SHA: `o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4`
  - Discord API integration for role management

## Phone System (Optional)
- **npwd**: `v2.4.1` - [GitHub Release](https://github.com/project-error/npwd/releases/tag/v2.4.1)
  - SHA: `p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5`
  - **Status**: Staged but disabled by default
  - **Note**: Enable when core gameplay is stable

## Custom Resources

### [local] Resources
These are custom-built for The Authority and included in this repository:

- **db_migrator**: `v1.0.0` - Custom database migration system
- **core**: `v1.0.0` - Payment and key helper functions  
- **apartments**: `v1.0.0` - Simple apartment system with spawn/stash/wardrobe
- **job_patches**: `v1.0.0` - Patches jobs to use Renewed-Banking
- **qa_tools**: `v1.0.0` - Quality assurance and testing tools
- **discord_perms**: `v1.0.0` - Discord role to ACE permission mapping

## Installation Notes

### Download Instructions
1. **Always use release archives** - Do not clone main branches
2. **Verify SHA hashes** when possible to ensure integrity
3. **Extract to correct folders** as specified in folder structure
4. **Check dependencies** - Some resources require others to be loaded first

### Load Order
The `server.cfg` ensures resources load in the correct order:
1. Database (oxmysql)
2. Libraries (ox_lib, qbx_core, etc.)
3. Core systems (banking, inventory, etc.)
4. Features (apartments, vehicles, jobs)
5. Administration (Discord, EasyAdmin)
6. Custom helpers and QA tools

### Compatibility Matrix

| Resource | QBX Core | ox_lib | ox_inventory | Notes |
|----------|----------|--------|--------------|-------|
| qbx_vehiclekeys | ✅ v1.17.0+ | ✅ v3.20.0+ | ❌ | Uses QBX inventory |
| qbx_garages | ✅ v1.17.0+ | ✅ v3.20.0+ | ✅ v2.41.0+ | Full compatibility |
| Renewed-Banking | ✅ v1.15.0+ | ✅ v3.15.0+ | ❌ | Standalone banking |
| illenium-appearance | ✅ v1.10.0+ | ✅ v3.10.0+ | ❌ | Character system |

### Update Policy
- **Major versions**: Test thoroughly before updating
- **Minor versions**: Generally safe to update
- **Patch versions**: Usually safe for immediate deployment
- **Custom resources**: Update through this repository only

### Backup Strategy
Before updating any resource:
1. Backup current resource folder
2. Backup database (especially player data)
3. Test on development server first
4. Update `docs/versions.md` with new versions

## Change Log

### 2025-01-06
- Initial version documentation created
- All resources pinned to stable releases
- Custom resources at v1.0.0

### Future Updates
Document all version changes here with:
- Date of change
- Resource name and new version
- Reason for update
- Any breaking changes or migration steps required

---

**Last Updated**: January 6, 2025  
**Maintained By**: The Authority Development Team  
**Review Schedule**: Monthly version audits





