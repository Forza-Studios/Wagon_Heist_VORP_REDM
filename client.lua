local npcModel = `re_deadjohn_females_01`
local npcCoords = vector3(-262.6665, 851.5240, 122.5683)
local npcHeading = 190.8490
local npcHandle = nil
local blipHandle = nil
local blipSprite = 1322310532

local strawberryNpcCoords = vector3(-1792.1530, -354.8040, 165.0181)
local strawberryNpcHeading = 296.9975
local strawberryNpcHandle = nil
local strawberryBlipHandle = nil

local questStep = 0
local horseCoords = vector3(-2363.0432, -356.3829, 145.0396)
local horseHeading = 356.4292
local horseModel = `A_C_Horse_Arabian_White`
local horseHandle = nil
local horseBlipHandle = nil
local horseRadiusBlipHandle = nil
local sabReturnBlip = nil

local promptGroup = GetRandomIntInRange(0, 0xffffff)
local talkPrompt = nil

local jobPromptGroup = GetRandomIntInRange(0, 0xffffff)
local yesPrompt = nil
local noPrompt = nil
local showJobOffer = false

local helpPromptGroup = GetRandomIntInRange(0, 0xffffff)
local helpYesPrompt = nil
local helpNoPrompt = nil
local showHelpOffer = false

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

local function CreateJobPrompts()
    -- Yes Prompt (UP Arrow)
    yesPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(yesPrompt, 0x6319DB71) -- UP Arrow
    local strYes = VarString(10, 'LITERAL_STRING', "Yes")
    UiPromptSetText(yesPrompt, strYes)
    UiPromptSetEnabled(yesPrompt, true)
    UiPromptSetVisible(yesPrompt, true)
    UiPromptSetStandardMode(yesPrompt, true)
    UiPromptSetGroup(yesPrompt, jobPromptGroup, 0)
    UiPromptRegisterEnd(yesPrompt)

    -- Maybe next time Prompt (DOWN Arrow)
    noPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(noPrompt, 0x05CA7C52) -- DOWN Arrow
    local strNo = VarString(10, 'LITERAL_STRING', "Maybe next time")
    UiPromptSetText(noPrompt, strNo)
    UiPromptSetEnabled(noPrompt, true)
    UiPromptSetVisible(noPrompt, true)
    UiPromptSetStandardMode(noPrompt, true)
    UiPromptSetGroup(noPrompt, jobPromptGroup, 0)
    UiPromptRegisterEnd(noPrompt)
end

local function CreateHelpPrompts()
    -- Yes, I will help (UP Arrow)
    helpYesPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(helpYesPrompt, 0x6319DB71) -- UP Arrow
    local strYes = VarString(10, 'LITERAL_STRING', "Yes, I will help")
    UiPromptSetText(helpYesPrompt, strYes)
    UiPromptSetEnabled(helpYesPrompt, true)
    UiPromptSetVisible(helpYesPrompt, true)
    UiPromptSetStandardMode(helpYesPrompt, true)
    UiPromptSetGroup(helpYesPrompt, helpPromptGroup, 0)
    UiPromptRegisterEnd(helpYesPrompt)

    -- Sorry, I can't do it (DOWN Arrow)
    helpNoPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(helpNoPrompt, 0x05CA7C52) -- DOWN Arrow
    local strNo = VarString(10, 'LITERAL_STRING', "Sorry, I can't do it")
    UiPromptSetText(helpNoPrompt, strNo)
    UiPromptSetEnabled(helpNoPrompt, true)
    UiPromptSetVisible(helpNoPrompt, true)
    UiPromptSetStandardMode(helpNoPrompt, true)
    UiPromptSetGroup(helpNoPrompt, helpPromptGroup, 0)
    UiPromptRegisterEnd(helpNoPrompt)
end

local function SpawnStrawberryNPC()
    if strawberryNpcHandle and DoesEntityExist(strawberryNpcHandle) then
        return
    end

    local model = `re_burningbodies_males_01`
    if not IsModelValid(model) then
        print("Wagon Heist: Invalid Strawberry NPC model re_burningbodies_males_01")
        return
    end

    if not HasModelLoaded(model) then
        RequestModel(model)
        repeat Wait(10) until HasModelLoaded(model)
    end

    strawberryNpcHandle = CreatePed(model, strawberryNpcCoords.x, strawberryNpcCoords.y, strawberryNpcCoords.z - 1.0, strawberryNpcHeading, false, false, false, false)
    repeat Wait(10) until DoesEntityExist(strawberryNpcHandle)

    SetRandomOutfitVariation(strawberryNpcHandle, true)
    PlaceEntityOnGroundProperly(strawberryNpcHandle)
    SetEntityCanBeDamaged(strawberryNpcHandle, false)
    SetBlockingOfNonTemporaryEvents(strawberryNpcHandle, true)
    
    -- Start smoking scenario
    TaskStartScenarioInPlace(
        strawberryNpcHandle,
        joaat("WORLD_HUMAN_SMOKE_INTERACTION"),
        -1,
        true,
        false,
        false,
        false
    )

    Wait(1000)
    FreezeEntityPosition(strawberryNpcHandle, true)
end

local function AddStrawberryBlip()
    if strawberryBlipHandle then
        RemoveBlip(strawberryBlipHandle)
    end

    strawberryBlipHandle = BlipAddForCoords(1664425300, strawberryNpcCoords.x, strawberryNpcCoords.y, strawberryNpcCoords.z)
    SetBlipSprite(strawberryBlipHandle, blipSprite, true)
    SetBlipName(strawberryBlipHandle, "Meet SAB")
    BlipAddModifier(strawberryBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6")) -- Yellow Color
end

local function SpawnQuestHorse()
    if horseHandle and DoesEntityExist(horseHandle) then
        return
    end

    if not HasModelLoaded(horseModel) then
        RequestModel(horseModel)
        repeat Wait(10) until HasModelLoaded(horseModel)
    end

    horseHandle = CreatePed(horseModel, horseCoords.x, horseCoords.y, horseCoords.z - 1.0, horseHeading, false, false, false, false)
    repeat Wait(10) until DoesEntityExist(horseHandle)

    SetRandomOutfitVariation(horseHandle, true)
    PlaceEntityOnGroundProperly(horseHandle)
    SetEntityCanBeDamaged(horseHandle, false)
    SetBlockingOfNonTemporaryEvents(horseHandle, true)
end

local function AddHorseBlips()
    if horseBlipHandle then RemoveBlip(horseBlipHandle) end
    if horseRadiusBlipHandle then RemoveBlip(horseRadiusBlipHandle) end

    -- Radius blip
    horseRadiusBlipHandle = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, horseCoords.x, horseCoords.y, horseCoords.z, 50.0)
    BlipAddModifier(horseRadiusBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6")) -- Yellow color for radius

    -- Normal blip inside the radius
    horseBlipHandle = BlipAddForCoords(1664425300, horseCoords.x, horseCoords.y, horseCoords.z)
    SetBlipSprite(horseBlipHandle, blipSprite, true)
    SetBlipName(horseBlipHandle, "Find SAB's horse")
    BlipAddModifier(horseBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6")) -- Yellow Color
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
    CreateJobPrompts()
    CreateHelpPrompts()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= 0 then
            local playerCoords = GetEntityCoords(playerPed)

            -- Handle CATY (NPC 1)
            local dist = #(playerCoords - npcCoords)
            if dist < 150.0 then
                if not npcHandle then
                    SpawnNPC()
                end
                sleep = 500

                -- Prompt player when near the NPC (only before quest starts)
                if dist < 2.5 and questStep == 0 then
                    sleep = 0
                    if not showJobOffer and not showHelpOffer then
                        local groupName = VarString(10, 'LITERAL_STRING', "CATY")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            print("Wagon Heist: Player talked to NPC")
                            showJobOffer = true
                            Wait(500) -- Cooldown to prevent double-firing
                        end
                    elseif showJobOffer then
                        local jobGroupName = VarString(10, 'LITERAL_STRING', "Are you looking for work?")
                        UiPromptSetActiveGroupThisFrame(jobPromptGroup, jobGroupName, 0, 0, 0, 0)

                        if UiPromptHasStandardModeCompleted(yesPrompt) or IsControlJustPressed(0, 0x6319DB71) then
                            showJobOffer = false
                            TriggerEvent("vorp:TipRight", "I will give you a job, but before that you need to help me", 4000)
                            showHelpOffer = true
                            Wait(500)
                        elseif UiPromptHasStandardModeCompleted(noPrompt) or IsControlJustPressed(0, 0x05CA7C52) then
                            showJobOffer = false
                            TriggerEvent("vorp:TipRight", "We can see next time", 4000)
                            Wait(1000)
                        end
                    elseif showHelpOffer then
                        local helpGroupName = VarString(10, 'LITERAL_STRING', "Will you help me?")
                        UiPromptSetActiveGroupThisFrame(helpPromptGroup, helpGroupName, 0, 0, 0, 0)

                        if UiPromptHasStandardModeCompleted(helpYesPrompt) or IsControlJustPressed(0, 0x6319DB71) then
                            showHelpOffer = false
                            questStep = 1
                            TriggerEvent("vorp:TipRight", "Go to Strawberry and meet SAB, he will tell you what to do", 4000)
                            PlaySoundFrontend("SELECT", "RDRO_Character_Creator_Sounds", true, 0)
                            SpawnStrawberryNPC()
                            AddStrawberryBlip()
                            TriggerServerEvent("wagon_heist:startTalk")
                            Wait(1000)
                        elseif UiPromptHasStandardModeCompleted(helpNoPrompt) or IsControlJustPressed(0, 0x05CA7C52) then
                            showHelpOffer = false
                            TriggerEvent("vorp:TipRight", "We can see next time", 4000)
                            Wait(1000)
                        end
                    end
                else
                    showJobOffer = false
                    showHelpOffer = false
                end
            else
                if npcHandle then
                    RemoveNPC()
                end
            end

            -- Handle SAB (NPC 2)
            local sabDist = #(playerCoords - strawberryNpcCoords)
            if (questStep == 1 or questStep == 3) and sabDist < 150.0 then
                if not strawberryNpcHandle then
                    SpawnStrawberryNPC()
                end
                sleep = 500

                -- Prompt player when near SAB
                if sabDist < 2.5 then
                    sleep = 0
                    if questStep == 1 then
                        local groupName = VarString(10, 'LITERAL_STRING', "SAB")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            print("Wagon Heist: Player talked to SAB")
                            questStep = 2
                            TriggerEvent("vorp:TipRight", "My horse is trapped near Owanjila Pond. Go and bring it back to me.", 4000)
                            
                            -- Remove Meet SAB blip
                            if strawberryBlipHandle then
                                RemoveBlip(strawberryBlipHandle)
                                strawberryBlipHandle = nil
                            end

                            -- Spawn quest horse & blips
                            SpawnQuestHorse()
                            AddHorseBlips()
                            Wait(1000)
                        end
                    elseif questStep == 3 then
                        local groupName = VarString(10, 'LITERAL_STRING', "SAB")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            print("Wagon Heist: Player returned horse to SAB")
                            questStep = 4
                            TriggerEvent("vorp:TipRight", "Thank you for bringing back my horse!", 4000)
                            
                            -- Remove Return blip
                            if sabReturnBlip then
                                RemoveBlip(sabReturnBlip)
                                sabReturnBlip = nil
                            end
                            ClearGpsMultiRoute()

                            -- Delete the horse
                            if horseHandle and DoesEntityExist(horseHandle) then
                                DeleteEntity(horseHandle)
                                horseHandle = nil
                            end
                            Wait(1000)
                        end
                    end
                end
            end

            -- Check if player entered the horse
            if questStep == 2 and horseHandle and DoesEntityExist(horseHandle) then
                local currentMount = GetMount(playerPed)
                if currentMount == horseHandle then
                    questStep = 3

                    -- Remove the find horse blips
                    if horseBlipHandle then
                        RemoveBlip(horseBlipHandle)
                        horseBlipHandle = nil
                    end
                    if horseRadiusBlipHandle then
                        RemoveBlip(horseRadiusBlipHandle)
                        horseRadiusBlipHandle = nil
                    end

                    -- Create waypoint blip back to SAB
                    sabReturnBlip = BlipAddForCoords(1664425300, strawberryNpcCoords.x, strawberryNpcCoords.y, strawberryNpcCoords.z)
                    SetBlipSprite(sabReturnBlip, blipSprite, true)
                    SetBlipName(sabReturnBlip, "Return to SAB")
                    BlipAddModifier(sabReturnBlip, joaat("BLIP_MODIFIER_MP_COLOR_6")) -- Yellow color
                    
                    -- Draw waypoint GPS route
                    StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                    AddPointToGpsMultiRoute(strawberryNpcCoords.x, strawberryNpcCoords.y, strawberryNpcCoords.z, false)
                    SetGpsMultiRouteRender(true)
                    
                    TriggerEvent("vorp:TipRight", "You found the horse! Ride back to SAB.", 4000)
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveNPC()
        if strawberryNpcHandle and DoesEntityExist(strawberryNpcHandle) then
            DeleteEntity(strawberryNpcHandle)
            strawberryNpcHandle = nil
        end
        if horseHandle and DoesEntityExist(horseHandle) then
            DeleteEntity(horseHandle)
            horseHandle = nil
        end
        if blipHandle then
            RemoveBlip(blipHandle)
        end
        if strawberryBlipHandle then
            RemoveBlip(strawberryBlipHandle)
            strawberryBlipHandle = nil
        end
        if horseBlipHandle then
            RemoveBlip(horseBlipHandle)
            horseBlipHandle = nil
        end
        if horseRadiusBlipHandle then
            RemoveBlip(horseRadiusBlipHandle)
            horseRadiusBlipHandle = nil
        end
        if sabReturnBlip then
            RemoveBlip(sabReturnBlip)
            sabReturnBlip = nil
        end
        ClearGpsMultiRoute()
        if talkPrompt then
            if UiPromptDelete then
                UiPromptDelete(talkPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, talkPrompt)
            end
        end
        if yesPrompt then
            if UiPromptDelete then
                UiPromptDelete(yesPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, yesPrompt)
            end
        end
        if noPrompt then
            if UiPromptDelete then
                UiPromptDelete(noPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, noPrompt)
            end
        end
        if helpYesPrompt then
            if UiPromptDelete then
                UiPromptDelete(helpYesPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, helpYesPrompt)
            end
        end
        if helpNoPrompt then
            if UiPromptDelete then
                UiPromptDelete(helpNoPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, helpNoPrompt)
            end
        end
    end
end)
