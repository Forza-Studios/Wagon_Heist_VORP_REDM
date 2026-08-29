-- Client Mission Helpers & Management
local spawnedGuards = {}
local guardBlips = {}

npcHandle = nil
blipHandle = nil

strawberryNpcHandle = nil
strawberryBlipHandle = nil

johnNpcHandle = nil
johnBlipHandle = nil

wagonHandle = nil
wagonBlipHandle = nil
wagonRadiusBlipHandle = nil

horseHandle = nil
horseBlipHandle = nil
horseRadiusBlipHandle = nil
sabReturnBlip = nil

forzaNpcHandle = nil
forzaBlipHandle = nil

-- Relationship group setup
Citizen.CreateThread(function()
    AddRelationshipGroup("bandits")
end)

-- Wait for a network ID to synchronize and return the local entity handle
function GetLocalEntityFromNetId(netId)
    local timer = 0
    while not NetworkDoesNetworkIdExist(netId) and timer < 8000 do
        Citizen.Wait(10)
        timer = timer + 10
    end
    
    if not NetworkDoesNetworkIdExist(netId) then
        print("[WagonHeist] Error: Network ID did not sync in time: " .. tostring(netId))
        return 0
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    timer = 0
    while not DoesEntityExist(entity) and timer < 5000 do
        Citizen.Wait(10)
        timer = timer + 10
        entity = NetworkGetEntityFromNetworkId(netId)
    end

    return entity
end

-- Called by server when wagon is ready; guards are spawned here client-side
RegisterNetEvent("wagon_heist:client:heistEntitiesSpawned", function(wagonNetId)
    SetupHeistEntities(wagonNetId)
end)

-- Sets up the server-spawned wagon and client-spawned guards
function SetupHeistEntities(wagonNetId)
    -- Reset alert states
    guardsAlerted = false
    spawnedGuards = {}
    guardBlips = {}

    -- 1. Setup Wagon (server-owned, get local handle)
    wagonHandle = GetLocalEntityFromNetId(wagonNetId)
    if DoesEntityExist(wagonHandle) then
        PlaceObjectOnGroundProperly(wagonHandle)
        SetEntityAsMissionEntity(wagonHandle, true, true)
    end

    -- 2. Spawn Guards locally (client-side, avoids server CreatePed failure)
    AddRelationshipGroup("bandits")
    SetRelationshipBetweenGroups(5, joaat("PLAYER"), joaat("bandits"))
    SetRelationshipBetweenGroups(5, joaat("bandits"), joaat("PLAYER"))

    for _, coords in ipairs(Config.GuardCoords) do
        local guardModel = Config.GuardModels[math.random(1, #Config.GuardModels)]
        local weaponHash = Config.GuardWeapons[math.random(1, #Config.GuardWeapons)]

        RequestModel(guardModel)
        local timer = 0
        while not HasModelLoaded(guardModel) and timer < 5000 do
            Wait(10)
            timer = timer + 10
        end

        if HasModelLoaded(guardModel) then
            local ped = CreatePed(guardModel, coords.x, coords.y, coords.z, coords.w, false, false, false, false)
            if DoesEntityExist(ped) then
                PlaceEntityOnGroundProperly(ped)

                -- Give weapon
                GiveWeaponToPed_2(ped, weaponHash, 100, true, false, 3, false, 0.5, 1.0, 752097756, false, 0, false)
                SetPedInfiniteAmmo(ped, true, weaponHash)
                SetCurrentPedWeapon(ped, weaponHash, true)

                -- Relationship
                SetPedRelationshipGroupHash(ped, joaat("bandits"))

                -- Freeze until player is in range
                FreezeEntityPosition(ped, true)
                SetEntityCanBeDamaged(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, false)

                -- Blip
                local blip = BlipAddForEntity(1664425300, ped)
                SetBlipSprite(blip, Config.BlipSprite, true)
                BlipAddModifier(blip, joaat("BLIP_MODIFIER_MP_COLOR_2"))
                SetBlipName(blip, "Enemy")

                table.insert(spawnedGuards, ped)
                table.insert(guardBlips, blip)
            end
        else
            print("[WagonHeist] Warning: Could not load guard model: " .. tostring(guardModel))
        end
    end

    print(string.format("[WagonHeist] Spawned %d guards client-side.", #spawnedGuards))
end

-- Alert guards to engage player
function AlertGuards(playerPed)
    for _, guard in ipairs(spawnedGuards) do
        if DoesEntityExist(guard) then
            FreezeEntityPosition(guard, false)
            ClearPedTasksImmediately(guard)
            TaskCombatPed(guard, playerPed, 0, 16)
        end
    end
end

-- Check if all spawned guards are dead
function AreAllGuardsDead()
    if #spawnedGuards == 0 then return false end
    for _, guard in ipairs(spawnedGuards) do
        if DoesEntityExist(guard) and not IsPedDeadOrDying(guard, true) then
            return false
        end
    end
    return true
end

-- Clear guard blips
function ClearGuardBlips()
    for _, blip in ipairs(guardBlips) do
        if blip then RemoveBlip(blip) end
    end
    guardBlips = {}
end

-- Local NPC Spawners (Caty, SAB, John, Forza, Horse)
function SpawnCatyNPC()
    if npcHandle and DoesEntityExist(npcHandle) then return end
    RequestModel(Config.NpcModel)
    repeat Wait(10) until HasModelLoaded(Config.NpcModel)
    npcHandle = CreatePed(Config.NpcModel, Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z - 1.0, Config.NpcHeading, false, false, false, false)
    SetRandomOutfitVariation(npcHandle, true)
    PlaceEntityOnGroundProperly(npcHandle)
    SetEntityCanBeDamaged(npcHandle, false)
    SetBlockingOfNonTemporaryEvents(npcHandle, true)
    TaskStartScenarioInPlace(npcHandle, joaat("WORLD_HUMAN_SMOKE_INTERACTION"), -1, true, false, false, false)
    Wait(1000)
    FreezeEntityPosition(npcHandle, true)
end

function RemoveCatyNPC()
    if npcHandle and DoesEntityExist(npcHandle) then
        DeleteEntity(npcHandle)
        npcHandle = nil
    end
end

function SpawnStrawberryNPC()
    if strawberryNpcHandle and DoesEntityExist(strawberryNpcHandle) then return end
    RequestModel(Config.StrawberryModel)
    repeat Wait(10) until HasModelLoaded(Config.StrawberryModel)
    strawberryNpcHandle = CreatePed(Config.StrawberryModel, Config.StrawberryNpcCoords.x, Config.StrawberryNpcCoords.y, Config.StrawberryNpcCoords.z - 1.0, Config.StrawberryNpcHeading, false, false, false, false)
    SetRandomOutfitVariation(strawberryNpcHandle, true)
    PlaceEntityOnGroundProperly(strawberryNpcHandle)
    SetEntityCanBeDamaged(strawberryNpcHandle, false)
    SetBlockingOfNonTemporaryEvents(strawberryNpcHandle, true)
    TaskStartScenarioInPlace(strawberryNpcHandle, joaat("WORLD_HUMAN_SMOKE_INTERACTION"), -1, true, false, false, false)
    Wait(1000)
    FreezeEntityPosition(strawberryNpcHandle, true)
end

function RemoveStrawberryNPC()
    if strawberryNpcHandle and DoesEntityExist(strawberryNpcHandle) then
        DeleteEntity(strawberryNpcHandle)
        strawberryNpcHandle = nil
    end
end

function SpawnJohnNPC()
    if johnNpcHandle and DoesEntityExist(johnNpcHandle) then return end
    RequestModel(Config.JohnModel)
    repeat Wait(10) until HasModelLoaded(Config.JohnModel)
    johnNpcHandle = CreatePed(Config.JohnModel, Config.JohnNpcCoords.x, Config.JohnNpcCoords.y, Config.JohnNpcCoords.z, Config.JohnNpcHeading, false, false, false, false)
    SetRandomOutfitVariation(johnNpcHandle, true)
    PlaceEntityOnGroundProperly(johnNpcHandle)
    SetEntityCanBeDamaged(johnNpcHandle, false)
    SetBlockingOfNonTemporaryEvents(johnNpcHandle, true)
    TaskStartScenarioInPlace(johnNpcHandle, joaat("WORLD_HUMAN_SMOKE_INTERACTION"), -1, true, false, false, false)
    Wait(1000)
    FreezeEntityPosition(johnNpcHandle, true)
end

function RemoveJohnNPC()
    if johnNpcHandle and DoesEntityExist(johnNpcHandle) then
        DeleteEntity(johnNpcHandle)
        johnNpcHandle = nil
    end
end

function SpawnQuestHorse()
    if horseHandle and DoesEntityExist(horseHandle) then return end
    RequestModel(Config.HorseModel)
    repeat Wait(10) until HasModelLoaded(Config.HorseModel)
    horseHandle = CreatePed(Config.HorseModel, Config.HorseCoords.x, Config.HorseCoords.y, Config.HorseCoords.z - 1.0, Config.HorseHeading, false, false, false, false)
    SetRandomOutfitVariation(horseHandle, true)
    PlaceEntityOnGroundProperly(horseHandle)
    SetEntityCanBeDamaged(horseHandle, false)
    SetBlockingOfNonTemporaryEvents(horseHandle, true)
end

function RemoveQuestHorse()
    if horseHandle and DoesEntityExist(horseHandle) then
        DeleteEntity(horseHandle)
        horseHandle = nil
    end
end

-- Blip Adders
function AddCatyBlip()
    if blipHandle then RemoveBlip(blipHandle) end
    blipHandle = BlipAddForCoords(1664425300, Config.NpcCoords.x, Config.NpcCoords.y, Config.NpcCoords.z)
    SetBlipSprite(blipHandle, Config.BlipSprite, true)
    SetBlipName(blipHandle, "Meet Caty")
end

function AddStrawberryBlip()
    if strawberryBlipHandle then RemoveBlip(strawberryBlipHandle) end
    strawberryBlipHandle = BlipAddForCoords(1664425300, Config.StrawberryNpcCoords.x, Config.StrawberryNpcCoords.y, Config.StrawberryNpcCoords.z)
    SetBlipSprite(strawberryBlipHandle, Config.BlipSprite, true)
    SetBlipName(strawberryBlipHandle, "Meet SAB")
    BlipAddModifier(strawberryBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6")) -- Yellow
end

function AddHorseBlips()
    if horseBlipHandle then RemoveBlip(horseBlipHandle) end
    if horseRadiusBlipHandle then RemoveBlip(horseRadiusBlipHandle) end

    horseRadiusBlipHandle = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, Config.HorseCoords.x, Config.HorseCoords.y, Config.HorseCoords.z, 50.0)
    BlipAddModifier(horseRadiusBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))

    horseBlipHandle = BlipAddForCoords(1664425300, Config.HorseCoords.x, Config.HorseCoords.y, Config.HorseCoords.z)
    SetBlipSprite(horseBlipHandle, Config.BlipSprite, true)
    SetBlipName(horseBlipHandle, "Find SAB's horse")
    BlipAddModifier(horseBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))
end

function AddSabReturnBlip()
    if sabReturnBlip then RemoveBlip(sabReturnBlip) end
    sabReturnBlip = BlipAddForCoords(1664425300, Config.StrawberryNpcCoords.x, Config.StrawberryNpcCoords.y, Config.StrawberryNpcCoords.z)
    SetBlipSprite(sabReturnBlip, Config.BlipSprite, true)
    SetBlipName(sabReturnBlip, "Return to SAB")
    BlipAddModifier(sabReturnBlip, joaat("BLIP_MODIFIER_MP_COLOR_6"))
end

function AddJohnBlip()
    if johnBlipHandle then RemoveBlip(johnBlipHandle) end
    johnBlipHandle = BlipAddForCoords(1664425300, Config.JohnNpcCoords.x, Config.JohnNpcCoords.y, Config.JohnNpcCoords.z)
    SetBlipSprite(johnBlipHandle, Config.BlipSprite, true)
    SetBlipName(johnBlipHandle, "Meet John")
    BlipAddModifier(johnBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))
end

function AddWagonBlips()
    if wagonBlipHandle then RemoveBlip(wagonBlipHandle) end
    if wagonRadiusBlipHandle then RemoveBlip(wagonRadiusBlipHandle) end

    wagonRadiusBlipHandle = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, Config.WagonCoords.x, Config.WagonCoords.y, Config.WagonCoords.z, 50.0)
    BlipAddModifier(wagonRadiusBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))

    wagonBlipHandle = BlipAddForCoords(1664425300, Config.WagonCoords.x, Config.WagonCoords.y, Config.WagonCoords.z)
    SetBlipSprite(wagonBlipHandle, 1012165077, true)
    SetBlipName(wagonBlipHandle, "Find the Wagon")
    BlipAddModifier(wagonBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))
end

function AddDeliveryBlip()
    if forzaBlipHandle then RemoveBlip(forzaBlipHandle) end
    forzaBlipHandle = BlipAddForCoords(1664425300, Config.DeliveryCoords.x, Config.DeliveryCoords.y, Config.DeliveryCoords.z)
    SetBlipSprite(forzaBlipHandle, Config.BlipSprite, true)
    SetBlipName(forzaBlipHandle, "Deliver Wagon")
    BlipAddModifier(forzaBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))
end

-- Clear client-side components completely
function CleanUpHeistClient()
    RemoveCatyNPC()
    RemoveStrawberryNPC()
    RemoveQuestHorse()
    RemoveJohnNPC()

    if blipHandle then RemoveBlip(blipHandle) blipHandle = nil end
    if strawberryBlipHandle then RemoveBlip(strawberryBlipHandle) strawberryBlipHandle = nil end
    if horseBlipHandle then RemoveBlip(horseBlipHandle) horseBlipHandle = nil end
    if horseRadiusBlipHandle then RemoveBlip(horseRadiusBlipHandle) horseRadiusBlipHandle = nil end
    if sabReturnBlip then RemoveBlip(sabReturnBlip) sabReturnBlip = nil end
    if johnBlipHandle then RemoveBlip(johnBlipHandle) johnBlipHandle = nil end
    if wagonBlipHandle then RemoveBlip(wagonBlipHandle) wagonBlipHandle = nil end
    if wagonRadiusBlipHandle then RemoveBlip(wagonRadiusBlipHandle) wagonRadiusBlipHandle = nil end
    if forzaBlipHandle then RemoveBlip(forzaBlipHandle) forzaBlipHandle = nil end

    ClearGuardBlips()
    ClearGpsMultiRoute()
    
    if wagonHandle and DoesEntityExist(wagonHandle) then
        DeleteVehicle(wagonHandle)
        wagonHandle = nil
    end
end
