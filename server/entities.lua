-- Server-side entity creation and bucket routing

function SpawnSessionEntities(session)
    local bucketId = session.bucket
    local spawnedWagonNetId = nil
    local spawnedHorse1NetId = nil
    local spawnedHorse2NetId = nil

    -- Spawn Wagon
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
        print(string.format("[WagonHeist] Wagon spawned (netId: %d) in bucket %d", spawnedWagonNetId, bucketId))

        local horseModel = `A_C_Horse_Draft_Belgian`

        -- Spawn Horse 1
        local horse1 = CreatePed(28, horseModel, Config.WagonCoords.x, Config.WagonCoords.y, Config.WagonCoords.z, Config.WagonHeading, true, true)
        timer = 0
        while not DoesEntityExist(horse1) and timer < 500 do
            Wait(10)
            timer = timer + 10
        end

        if DoesEntityExist(horse1) then
            SetEntityRoutingBucket(horse1, bucketId)
            AddSessionEntity(session.id, horse1)
            spawnedHorse1NetId = NetworkGetNetworkIdFromEntity(horse1)
            print(string.format("[WagonHeist] Horse 1 spawned (netId: %d) in bucket %d", spawnedHorse1NetId, bucketId))
        else
            print("[WagonHeist] Error: Failed to spawn horse 1 on server.")
        end

        -- Spawn Horse 2
        local horse2 = CreatePed(28, horseModel, Config.WagonCoords.x, Config.WagonCoords.y, Config.WagonCoords.z, Config.WagonHeading, true, true)
        timer = 0
        while not DoesEntityExist(horse2) and timer < 500 do
            Wait(10)
            timer = timer + 10
        end

        if DoesEntityExist(horse2) then
            SetEntityRoutingBucket(horse2, bucketId)
            AddSessionEntity(session.id, horse2)
            spawnedHorse2NetId = NetworkGetNetworkIdFromEntity(horse2)
            print(string.format("[WagonHeist] Horse 2 spawned (netId: %d) in bucket %d", spawnedHorse2NetId, bucketId))
        else
            print("[WagonHeist] Error: Failed to spawn horse 2 on server.")
        end
    else
        print("[WagonHeist] Error: Failed to spawn wagon on server.")
    end

    return spawnedWagonNetId, spawnedHorse1NetId, spawnedHorse2NetId
end
