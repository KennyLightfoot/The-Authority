local Districts = {
  version = "2025-09-08-a",
  zones = {
    { name = "LSIA", weight = 1.0, poly = {
      vec3(-1200, -3500, 13), vec3(-1200, -2500, 13), vec3(-1800, -2500, 13), vec3(-1800, -3500, 13)
    }},
    { name = "Downtown", weight = 1.2, poly = {
      vec3(200, -1100, 28), vec3(500, -1100, 28), vec3(500, -800, 28), vec3(200, -800, 28)
    }},
    { name = "Vespucci", weight = 1.1, poly = {
      vec3(-1400, -1200, 4), vec3(-900, -1200, 4), vec3(-900, -800, 4), vec3(-1400, -800, 4)
    }},
  },
  thresholds = {
    checkpoint = 100,
    curfew     = 200,
  },
  decay_per_min = 0.5
}

return Districts


