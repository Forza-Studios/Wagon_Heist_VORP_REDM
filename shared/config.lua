Config = {}

-- Caty NPC
Config.NpcModel = `re_deadjohn_females_01`
Config.NpcCoords = vector3(-262.6665, 851.5240, 122.5683)
Config.NpcHeading = 190.8490
Config.BlipSprite = 1322310532

-- Strawberry SAB NPC
Config.StrawberryNpcCoords = vector3(-1792.1530, -354.8040, 165.0181)
Config.StrawberryNpcHeading = 296.9975
Config.StrawberryModel = `re_burningbodies_males_01`

-- New Hanover John NPC
Config.JohnNpcCoords = vector3(2007.7274, 702.8318, 178.4863)
Config.JohnNpcHeading = 159.6117
Config.JohnModel = `re_burningbodies_males_01`

-- Wagon Heist Settings
Config.WagonCoords = vector3(2457.0266, 288.9746, 70.7322)
Config.WagonHeading = 349.2638
Config.WagonModel = `wagon02x`

Config.GuardCoords = {
    vector4(2459.7314, 304.5994, 73.8571, 40.3134),
    vector4(2466.0957, 299.9571, 73.7404, 268.2031),
    vector4(2465.6653, 293.9383, 73.7190, 275.8509),
    vector4(2465.6555, 276.8107, 77.3401, 266.8364),
    vector4(2463.6267, 275.4280, 77.3231, 161.4272),
    vector4(2460.0710, 276.1804, 74.4061, 173.4485),
    vector4(2454.8694, 276.2929, 74.1484, 166.9812),
    vector4(2440.5715, 276.6414, 75.5341, 184.6143),
    vector4(2446.6384, 281.7252, 73.7392, 326.6702),
    vector4(2447.0142, 305.5007, 73.9627, 333.8371),
    vector4(2440.4124, 287.3599, 73.1754, 74.02861),
    vector4(2440.8340, 297.8888, 73.1206, 81.8241),
    vector4(2445.5073, 293.8673, 70.3714, 177.6443),
    vector4(2445.1138, 290.3621, 70.3456, 286.2909),
    vector4(2445.5974, 286.1053, 70.4831, 281.7885),
    vector4(2445.8591, 278.5839, 70.5328, 262.7608),
    vector4(2458.1079, 277.8130, 71.2404, 168.4978),
    vector4(2461.4741, 284.1385, 70.9786, 5.1296),
    vector4(2461.0615, 294.4632, 70.5414, 66.1621),
    vector4(2455.9961, 304.7139, 70.3001, 26.3951),
    vector4(2451.9343, 304.6973, 70.3516, 344.9767),
}

Config.GuardWeapons = {
    `WEAPON_REPEATER_CARBINE`,
    `WEAPON_REPEATER_WINCHESTER`,
    `WEAPON_RIFLE_SPRINGFIELD`,
    `WEAPON_SHOTGUN_DOUBLEBARREL`,
    `WEAPON_REVOLVER_CATTLEMAN`,
    `WEAPON_REVOLVER_SCHOFIELD`
}

Config.GuardModels = {
    `A_M_M_BLWLaborer_01`,
    `A_M_M_RHDTownfolk_01`,
    `G_M_M_UniBanditos_01`,
    `G_M_Y_UniExConfeds_01`
}

Config.HeistLives = 2

-- Owanjila Pond Horse
Config.HorseCoords = vector3(-2363.0432, -356.3829, 145.0396)
Config.HorseHeading = 356.4292
Config.HorseModel = `A_C_Horse_Arabian_White`

-- Riggs Station Delivery Location
Config.DeliveryCoords = vector3(-1013.6537, -524.0103, 100.5687)

-- Wagon Abandonment Timeout
Config.WagonAbandonTimeout = 60 -- 60 seconds (1 minute)
Config.WagonAbandonDistance = 100.0 -- Max distance before considered abandoned

-- Reward
Config.RewardCash = 1000.0
Config.RewardDelayMs = 0 -- Instant payout


