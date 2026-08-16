local npcModel = `re_deadjohn_females_01`
local npcCoords = vector3(-262.6665, 851.5240, 122.5683)
local npcHeading = 190.8490
local npcHandle = nil
local blipHandle = nil
local blipSprite = 1322310532

local function SpawnNPC()
    if not IsModelValid(npcModel) then
        print("Wagon Heist: Invalid NPC model re_deadjohn_females_01")
        return
    end

    if not HasModelLoaded(npcModel) then
        RequestModel(npcModel)
        repeat Wait(10) until HasModelLoaded(npcModel)
    end

    -- Create NPC ped
    npcHandle = CreatePed(npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcHeading, false, false, false, false)
    repeat Wait(10) until DoesEntityExist(npcHandle)

    SetRandomOutfitVariation(npcHandle, true)
    PlaceEntityOnGroundProperly(npcHandle)
    SetEntityCanBeDamaged(npcHandle, false)
    SetBlockingOfNonTemporaryEvents(npcHandle, true)
    
    -- Start smoking scenario
    TaskStartScenarioInPlace(
    npcHandle,
    joaat("WORLD_HUMAN_SMOKE_INTERACTION"),
    -1,
    true,
    false,
    false,
    false
)
    
    -- Allow animation to initialize before freezing position
    Wait(1000)
    FreezeEntityPosition(npcHandle, true)
end

local function RemoveNPC()
    if npcHandle and DoesEntityExist(npcHandle) then
        DeleteEntity(npcHandle)
        npcHandle = nil
    end
end

local function AddBlip()
    -- RDR3 BlipAddForCoords native (style hash 1664425300 or similar, then SetBlipSprite to change sprite)
    blipHandle = BlipAddForCoords(1664425300, npcCoords.x, npcCoords.y, npcCoords.z)
    SetBlipSprite(blipHandle, blipSprite, true)
    SetBlipName(blipHandle, "Wagon Heist")
end

CreateThread(function()
    AddBlip()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= 0 then
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - npcCoords)

            if dist < 150.0 then
                if not npcHandle then
                    SpawnNPC()
                end
                sleep = 500
            else
                if npcHandle then
                    RemoveNPC()
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveNPC()
        if blipHandle then
            RemoveBlip(blipHandle)
        end
    end
end)
