-- Server-side entity creation and bucket routing

function SpawnSessionEntities(session)
    local bucketId = session.bucket
    local spawnedPeds = {}
    local spawnedWagonNetId = nil

    -- 1. Spawn Wagon
    local wagon = CreateVehicle(Config.WagonModel, Config.WagonCoords.x, Config.WagonCoords.y, Config.WagonCoords.z, Config.WagonHeading, true, true)
    local timer = 0
    while not DoesEntityExist(wagon) and timer < 500 do
        Wait(10)
        timer = timer + 10
    end

    if DoesEntityExist(wagon) then
        SetEntityRoutingBucket(wagon, bucketId)
        AddSessionEntity(session.id, wagon)
        spawnedWagonNetId = NetworkGetNetworkIdFromEntity(wagon)
    else
        print("[WagonHeist] Error: Failed to spawn wagon on server.")
    end

    -- 2. Spawn Guards
    for _, coords in ipairs(Config.GuardCoords) do
        local guardModel = Config.GuardModels[math.random(1, #Config.GuardModels)]
        -- CreatePed(modelHash, x, y, z, heading, isNetwork, netMissionEntity)
        local ped = CreatePed(guardModel, coords.x, coords.y, coords.z, coords.w, true, true)
        
        timer = 0
        while not DoesEntityExist(ped) and timer < 500 do
            Wait(10)
            timer = timer + 10
        end

        if DoesEntityExist(ped) then
            SetEntityRoutingBucket(ped, bucketId)
            AddSessionEntity(session.id, ped)
            local netId = NetworkGetNetworkIdFromEntity(ped)
            local weaponHash = Config.GuardWeapons[math.random(1, #Config.GuardWeapons)]
            table.insert(spawnedPeds, { netId = netId, weapon = weaponHash })
        else
            print("[WagonHeist] Error: Failed to spawn a guard NPC on server.")
        end
    end

    return spawnedWagonNetId, spawnedPeds
end
