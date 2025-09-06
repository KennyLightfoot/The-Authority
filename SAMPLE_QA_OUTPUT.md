# Sample /qa:base Output

This is what the QA test output would look like when all systems are properly configured:

```
=== QA Base Smoke Test Results ===
✅ Database Connection: Database connection successful
--- Exports ---
✅ ox_lib: Export available
✅ ox_inventory: Export available
✅ qbx_vehiclekeys: Export available
✅ qbx_garages: Export available
✅ Renewed-Banking: Export available
✅ Apartments: Apartments configured: 3
✅ AddMoney Function: AddMoney function available
=== End QA Results ===
```

## Additional QA Commands Available:
- `/qa:notify [message]` - Test ox_lib notification system
- `/qa:coords` - Get current coordinates (useful for adding new locations)
- `/qa:vehicle` - Get vehicle information when in a vehicle
- `/qa:health` - Record server health metrics
- `/refreshperms` - Refresh Discord permissions (admin only)



