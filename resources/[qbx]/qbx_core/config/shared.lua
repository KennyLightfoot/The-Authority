return {
    serverName = 'Server',
    defaultSpawn = vec4(311.25, -595.47, 43.28, 70.0),
    notifyPosition = 'top-right', -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
    ---@type { name: string, amount: integer, metadata: fun(source: number): table }[]
    starterItems = { -- Character starting items
        { name = 'phone', amount = 1 },
        -- Temporarily disabled until qbx_idcard resource is available
        -- { name = 'id_card', amount = 1 },
        -- { name = 'driver_license', amount = 1 },
    }
}
