-- Server-side entity creation and bucket routing

function SpawnSessionEntities(session)
    local bucketId = session.bucket
    local spawnedWagonNetId = nil

    -- Spawn Wagon only (guards are spawned client-side)
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
    else
        print("[WagonHeist] Error: Failed to spawn wagon on server.")
    end

    return spawnedWagonNetId
end
