local PriceRegistry = {}

PriceRegistry.version = "2025-09-08-a"

PriceRegistry.catalog = {
  shops = {
    convenience = {
      water = { price = 5, max = 10 },
      sandwich = { price = 12, max = 10 },
      bandage = { price = 60, max = 5 },
    },
    ammunation = {
      pistol_ammo = { price = 250, max = 4, requires = { license = "firearm" } },
    },
  },
  services = {
    repair_basic = { price = 450 },
    taxi_per_km  = { price = 22, cap = 800 },
  },
  payouts = {
    vhs_recycle = {
      glass = 6, plastic = 5, scrap_metal = 8
    },
    mining = {
      ore_iron = 10, ore_copper = 8, bar_gold = 220
    },
  },
  taxes = {
    sales = 0.05,
    income = 0.10,
  }
}

function PriceRegistry:getShopItemPrice(shop, item, qty)
  local s = self.catalog.shops[shop]; if not s then return nil, "shop" end
  local row = s[item]; if not row then return nil, "item" end
  qty = math.max(1, math.floor(qty or 1))
  if row.max and qty > row.max then return nil, "max" end
  return row.price * qty, nil, row
end

function PriceRegistry:getServicePrice(name, units)
  local row = self.catalog.services[name]; if not row then return nil, "service" end
  units = math.max(1, math.floor(units or 1))
  local total = row.price * units
  if row.cap then total = math.min(total, row.cap) end
  return total
end

function PriceRegistry:getPayout(job, item, qty)
  local j = self.catalog.payouts[job]; if not j then return nil, "job" end
  local p = j[item]; if not p then return nil, "item" end
  qty = math.max(1, math.floor(qty or 1))
  return p * qty
end

return PriceRegistry


