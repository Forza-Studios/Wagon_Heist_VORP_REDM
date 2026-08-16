local npcModel = `re_deadjohn_females_01`
local npcCoords = vector3(-262.6665, 851.5240, 122.5683)
local npcHeading = 190.8490
local npcHandle = nil
local blipHandle = nil
local blipSprite = 1322310532

local promptGroup = GetRandomIntInRange(0, 0xffffff)
local talkPrompt = nil

local function CreateTalkPrompt()
    local str = "Talk"
    talkPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(talkPrompt, 0x80F28E95) -- L key
    str = VarString(10, 'LITERAL_STRING', str)
    UiPromptSetText(talkPrompt, str)
    UiPromptSetEnabled(talkPrompt, true)
    UiPromptSetVisible(talkPrompt, true)
    UiPromptSetHoldMode(talkPrompt, 3000) -- 3 second hold
    UiPromptSetGroup(talkPrompt, promptGroup, 0)
    UiPromptRegisterEnd(talkPrompt)
end

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
    CreateTalkPrompt()

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

                -- Prompt player when near the NPC
                if dist < 2.5 then
                    sleep = 0
                    local groupName = VarString(10, 'LITERAL_STRING', "CATY")
                    UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                    if UiPromptHasHoldModeCompleted(talkPrompt) then
                        print("Wagon Heist: Player talked to NPC")
                        TriggerEvent("vorp:TipRight", "You spoke with CATY", 4000)
                        TriggerServerEvent("wagon_heist:startTalk")
                        Wait(1000) -- Cooldown to prevent multiple inputs in quick succession
                    end
                end
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
        if talkPrompt then
            if UiPromptDelete then
                UiPromptDelete(talkPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, talkPrompt)
            end
        end
    end
end)
