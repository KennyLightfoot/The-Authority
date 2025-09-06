-- Verification script to check database tables
-- Run this in server console to verify all tables exist

CreateThread(function()
    Wait(3000) -- Wait for MySQL to be ready
    
    local tables = {
        'players',
        'bans', 
        'player_groups'
    }
    
    print("[Database Verify] Checking database tables...")
    
    for _, tableName in ipairs(tables) do
        local exists = MySQL.scalar.await([[
            SELECT COUNT(*)
            FROM information_schema.tables 
            WHERE table_schema = DATABASE() 
            AND table_name = ?
        ]], {tableName})
        
        if exists > 0 then
            print("[Database Verify] ✅ Table '" .. tableName .. "' exists")
            
            -- Check specific columns for each table
            if tableName == 'players' then
                local columns = {'citizenid', 'cid', 'last_logged_out', 'userId'}
                for _, col in ipairs(columns) do
                    local hasCol = MySQL.scalar.await([[
                        SELECT COUNT(*)
                        FROM information_schema.COLUMNS 
                        WHERE TABLE_SCHEMA = DATABASE() 
                        AND TABLE_NAME = ? AND COLUMN_NAME = ?
                    ]], {tableName, col})
                    
                    if hasCol > 0 then
                        print("[Database Verify]   ✅ Column '" .. col .. "' exists")
                    else
                        print("[Database Verify]   ❌ Column '" .. col .. "' missing")
                    end
                end
            elseif tableName == 'player_groups' then
                local columns = {'citizenid', 'group', 'type', 'grade'}
                for _, col in ipairs(columns) do
                    local hasCol = MySQL.scalar.await([[
                        SELECT COUNT(*)
                        FROM information_schema.COLUMNS 
                        WHERE TABLE_SCHEMA = DATABASE() 
                        AND TABLE_NAME = ? AND COLUMN_NAME = ?
                    ]], {tableName, col})
                    
                    if hasCol > 0 then
                        print("[Database Verify]   ✅ Column '" .. col .. "' exists")
                    else
                        print("[Database Verify]   ❌ Column '" .. col .. "' missing")
                    end
                end
            end
        else
            print("[Database Verify] ❌ Table '" .. tableName .. "' missing")
        end
    end
    
    print("[Database Verify] Database verification complete!")
end)
