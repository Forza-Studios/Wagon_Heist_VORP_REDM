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

local johnNpcCoords = vector3(2008.1365, 698.8608, 178.5635)
local johnNpcHeading = 1.1258
local johnNpcHandle = nil
local johnBlipHandle = nil

local wagonCoords = vector3(2457.0266, 288.9746, 70.7322)
local wagonHeading = 349.2638
local wagonModel = `buggy01`
local wagonHandle = nil
local wagonBlipHandle = nil
local wagonRadiusBlipHandle = nil
local guardCoords = {
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
local guardWeapons = {
    joaat("WEAPON_REPEATER_CARBINE"),
    joaat("WEAPON_REPEATER_WINCHESTER"),
    joaat("WEAPON_RIFLE_SPRINGFIELD"),
    joaat("WEAPON_SHOTGUN_DOUBLEBARREL"),
    joaat("WEAPON_REVOLVER_CATTLEMAN"),
    joaat("WEAPON_REVOLVER_SCHOFIELD")
}
local guardModels = {
    joaat("msp_fussar2_males_01"),
    joaat("msp_mob0_males_01"),
    joaat("msp_smuggler2_males_01"),
    joaat("rcsp_creole_males_01"),
    joaat("re_corpsecart_males_01"),
    joaat("re_hostagerescue_males_01"),
    joaat("re_playercampstrangers_males_01")
}
local spawnedGuards = {}
local guardBlips = {}
local guardsAlerted = false

local questStep = 0
local heistLives = 2
local horseCoords = vector3(-2363.0432, -356.3829, 145.0396)
local horseHeading = 356.4292
local horseModel = `A_C_Horse_Arabian_White`
local horseHandle = nil
local horseBlipHandle = nil
local horseRadiusBlipHandle = nil
local sabReturnBlip = nil
local forzaNpcCoords = vector3(-1013.6537, -524.0103, 100.5687)
local forzaNpcHeading = 257.2074
local forzaNpcHandle = nil
local forzaBlipHandle = nil

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

local johnJobPromptGroup = GetRandomIntInRange(0, 0xffffff)
local johnYesPrompt = nil
local johnNoPrompt = nil
local showJohnJobOffer = false


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

local function CreateJohnJobPrompts()
    -- Yes Prompt (UP Arrow)
    johnYesPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(johnYesPrompt, 0x6319DB71) -- UP Arrow
    local strYes = VarString(10, 'LITERAL_STRING', "Yes")
    UiPromptSetText(johnYesPrompt, strYes)
    UiPromptSetEnabled(johnYesPrompt, true)
    UiPromptSetVisible(johnYesPrompt, true)
    UiPromptSetStandardMode(johnYesPrompt, true)
    UiPromptSetGroup(johnYesPrompt, johnJobPromptGroup, 0)
    UiPromptRegisterEnd(johnYesPrompt)

    -- We will talk later Prompt (DOWN Arrow)
    johnNoPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(johnNoPrompt, 0x05CA7C52) -- DOWN Arrow
    local strNo = VarString(10, 'LITERAL_STRING', "We will talk later")
    UiPromptSetText(johnNoPrompt, strNo)
    UiPromptSetEnabled(johnNoPrompt, true)
    UiPromptSetVisible(johnNoPrompt, true)
    UiPromptSetStandardMode(johnNoPrompt, true)
    UiPromptSetGroup(johnNoPrompt, johnJobPromptGroup, 0)
    UiPromptRegisterEnd(johnNoPrompt)
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

local function SpawnJohnNPC()
    if johnNpcHandle and DoesEntityExist(johnNpcHandle) then
        return
    end

    local model = `re_burningbodies_males_01`
    if not IsModelValid(model) then
        print("Wagon Heist: Invalid John NPC model")
        return
    end

    if not HasModelLoaded(model) then
        RequestModel(model)
        repeat Wait(10) until HasModelLoaded(model)
    end

    johnNpcHandle = CreatePed(model, johnNpcCoords.x, johnNpcCoords.y, johnNpcCoords.z - 1.0, johnNpcHeading, false, false, false, false)
    repeat Wait(10) until DoesEntityExist(johnNpcHandle)

    SetRandomOutfitVariation(johnNpcHandle, true)
    PlaceEntityOnGroundProperly(johnNpcHandle)
    SetEntityCanBeDamaged(johnNpcHandle, false)
    SetBlockingOfNonTemporaryEvents(johnNpcHandle, true)
    
    -- Start smoking scenario
    TaskStartScenarioInPlace(
        johnNpcHandle,
        joaat("WORLD_HUMAN_SMOKE_INTERACTION"),
        -1,
        true,
        false,
        false,
        false
    )

    Wait(1000)
    FreezeEntityPosition(johnNpcHandle, true)
end

local function AddJohnBlip()
    if johnBlipHandle then
        RemoveBlip(johnBlipHandle)
    end

    johnBlipHandle = BlipAddForCoords(1664425300, johnNpcCoords.x, johnNpcCoords.y, johnNpcCoords.z)
    SetBlipSprite(johnBlipHandle, blipSprite, true)
    SetBlipName(johnBlipHandle, "Meet John")
    BlipAddModifier(johnBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))
end

local function SpawnForzaNPC()
    if forzaNpcHandle and DoesEntityExist(forzaNpcHandle) then
        return
    end

    local model = `re_burningbodies_males_01`
    if not IsModelValid(model) then
        print("Wagon Heist: Invalid Forza NPC model")
        return
    end

    if not HasModelLoaded(model) then
        RequestModel(model)
        repeat Wait(10) until HasModelLoaded(model)
    end

    forzaNpcHandle = CreatePed(model, forzaNpcCoords.x, forzaNpcCoords.y, forzaNpcCoords.z - 1.0, forzaNpcHeading, false, false, false, false)
    repeat Wait(10) until DoesEntityExist(forzaNpcHandle)

    SetRandomOutfitVariation(forzaNpcHandle, true)
    PlaceEntityOnGroundProperly(forzaNpcHandle)
    SetEntityCanBeDamaged(forzaNpcHandle, false)
    SetBlockingOfNonTemporaryEvents(forzaNpcHandle, true)
    
    -- Start smoking scenario
    TaskStartScenarioInPlace(
        forzaNpcHandle,
        joaat("WORLD_HUMAN_SMOKE_INTERACTION"),
        -1,
        true,
        false,
        false,
        false
    )

    Wait(1000)
    FreezeEntityPosition(forzaNpcHandle, true)
end

local function SpawnGuards()
    for _, blip in ipairs(guardBlips) do
        if blip then RemoveBlip(blip) end
    end
    guardBlips = {}

    for _, guard in ipairs(spawnedGuards) do
        if DoesEntityExist(guard) then
            DeleteEntity(guard)
        end
    end
    spawnedGuards = {}

    for _, coords in ipairs(guardCoords) do
        -- Pick a random model from the list
        local guardModel = guardModels[math.random(1, #guardModels)]
        if not HasModelLoaded(guardModel) then
            RequestModel(guardModel)
            repeat Wait(10) until HasModelLoaded(guardModel)
        end

        local guardPed = CreatePed(guardModel, coords.x, coords.y, coords.z - 1.0, coords.w, true, false, false, false)
        repeat Wait(10) until DoesEntityExist(guardPed)

        SetRandomOutfitVariation(guardPed, true)
        PlaceEntityOnGroundProperly(guardPed)
        
        -- Pick a random weapon from the list
        local weaponHash = guardWeapons[math.random(1, #guardWeapons)]
        
        -- Give weapon and infinite ammo
        GiveWeaponToPed_2(guardPed, weaponHash, 100, true, false, 3, false, 0.5, 1.0, 752097756, false, 0, false)
        SetPedInfiniteAmmo(guardPed, true, weaponHash)
        
        -- Set relationship to hostile
        SetPedRelationshipGroupHash(guardPed, joaat("bandits"))
        SetRelationshipBetweenGroups(5, joaat("PLAYER"), joaat("bandits"))
        SetRelationshipBetweenGroups(5, joaat("bandits"), joaat("PLAYER"))
        
        -- Set current weapon in hand
        SetCurrentPedWeapon(guardPed, weaponHash, true)
        
        -- Make them stand still for testing (frozen)
        FreezeEntityPosition(guardPed, true)
        
        -- Add red enemy blip to guard
        local blip = BlipAddForEntity(1664425300, guardPed)
        SetBlipSprite(blip, blipSprite, true)
        BlipAddModifier(blip, joaat("BLIP_MODIFIER_MP_COLOR_2")) -- Red Color
        SetBlipName(blip, "Enemy")
        table.insert(guardBlips, blip)
        
        table.insert(spawnedGuards, guardPed)
    end
end

local function SpawnWagon()
    if wagonHandle and DoesEntityExist(wagonHandle) then
        return
    end

    if not HasModelLoaded(wagonModel) then
        RequestModel(wagonModel)
        repeat Wait(10) until HasModelLoaded(wagonModel)
    end

    wagonHandle = CreateVehicle(wagonModel, wagonCoords.x, wagonCoords.y, wagonCoords.z, wagonHeading, true, false)
    repeat Wait(10) until DoesEntityExist(wagonHandle)
    
    PlaceObjectOnGroundProperly(wagonHandle)
    SetEntityAsMissionEntity(wagonHandle, true, true)

    -- Reset alert state and spawn guards
    guardsAlerted = false
    SpawnGuards()
end

local function AddWagonBlip()
    if wagonBlipHandle then RemoveBlip(wagonBlipHandle) end
    if wagonRadiusBlipHandle then RemoveBlip(wagonRadiusBlipHandle) end

    -- Radius blip
    wagonRadiusBlipHandle = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, wagonCoords.x, wagonCoords.y, wagonCoords.z, 50.0)
    BlipAddModifier(wagonRadiusBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6")) -- Yellow color for radius

    -- Normal blip inside the radius
    wagonBlipHandle = BlipAddForCoords(1664425300, wagonCoords.x, wagonCoords.y, wagonCoords.z)
    SetBlipSprite(wagonBlipHandle, 1012165077, true)
    SetBlipName(wagonBlipHandle, "Find the Wagon")
    BlipAddModifier(wagonBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))

    -- Draw GPS route to the wagon
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
    AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
    AddPointToGpsMultiRoute(wagonCoords.x, wagonCoords.y, wagonCoords.z, false)
    SetGpsMultiRouteRender(true)
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
    SetBlipName(blipHandle, "Meet Caty")
end

CreateThread(function()
    AddBlip()
    CreateTalkPrompt()
    CreateJobPrompts()
    CreateHelpPrompts()
    CreateJohnJobPrompts()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= 0 then
            local playerCoords = GetEntityCoords(playerPed)

            -- Handle CATY (NPC 1)
            local dist = #(playerCoords - npcCoords)
            if dist < 150.0 then
                if not npcHandle or not DoesEntityExist(npcHandle) then
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
                            
                            -- Draw GPS route to SAB
                            StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                            AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                            AddPointToGpsMultiRoute(strawberryNpcCoords.x, strawberryNpcCoords.y, strawberryNpcCoords.z, false)
                            SetGpsMultiRouteRender(true)

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
                if not strawberryNpcHandle or not DoesEntityExist(strawberryNpcHandle) then
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
                            ClearGpsMultiRoute()

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
                             Wait(4000)
                             TriggerEvent("vorp:TipRight", "Go and meet John at New Hanover and he will give you more details.", 4000)
                             
                             -- Add Meet John Blip
                             AddJohnBlip()
                             
                             -- Draw GPS route to John
                             StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                             AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                             AddPointToGpsMultiRoute(johnNpcCoords.x, johnNpcCoords.y, johnNpcCoords.z, false)
                             SetGpsMultiRouteRender(true)
                             
                             -- Remove Return blip
                             if sabReturnBlip then
                                 RemoveBlip(sabReturnBlip)
                                 sabReturnBlip = nil
                             end

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

            -- Handle John (NPC 3)
            local johnDist = #(playerCoords - johnNpcCoords)
            if (questStep == 4 or questStep == 5) and johnDist < 150.0 then
                if not johnNpcHandle or not DoesEntityExist(johnNpcHandle) then
                    SpawnJohnNPC()
                end
                sleep = 500


                -- Prompt player when near John
                if johnDist < 2.5 and questStep == 4 then
                    sleep = 0
                    if not showJohnJobOffer then
                        local groupName = VarString(10, 'LITERAL_STRING', "John")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            print("Wagon Heist: Player talked to John")
                            showJohnJobOffer = true
                            Wait(500)
                        end
                    elseif showJohnJobOffer then
                        local johnGroupName = VarString(10, 'LITERAL_STRING', "Are you interested in this job?")
                        UiPromptSetActiveGroupThisFrame(johnJobPromptGroup, johnGroupName, 0, 0, 0, 0)

                        if UiPromptHasStandardModeCompleted(johnYesPrompt) or IsControlJustPressed(0, 0x6319DB71) then
                             showJohnJobOffer = false
                             questStep = 5
                             heistLives = 2
                             if johnBlipHandle then
                                 RemoveBlip(johnBlipHandle)
                                 johnBlipHandle = nil
                             end
                             TriggerEvent("vorp:TipRight", "Go to Fort Brennand and find the wagon.", 4000)
                             SpawnWagon()
                             AddWagonBlip()
                             Wait(1000)
                        elseif UiPromptHasStandardModeCompleted(johnNoPrompt) or IsControlJustPressed(0, 0x05CA7C52) then
                            showJohnJobOffer = false
                            TriggerEvent("vorp:TipRight", "Alright, we will talk later.", 4000)
                            Wait(1000)
                        end
                    end
                else
                    showJohnJobOffer = false
                end
            else
                if johnNpcHandle and ((questStep ~= 4 and questStep ~= 5) or johnDist >= 150.0) then
                    if DoesEntityExist(johnNpcHandle) then
                        DeleteEntity(johnNpcHandle)
                    end
                    johnNpcHandle = nil
                    showJohnJobOffer = false
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
                    AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                    AddPointToGpsMultiRoute(strawberryNpcCoords.x, strawberryNpcCoords.y, strawberryNpcCoords.z, false)
                    SetGpsMultiRouteRender(true)
                    
                    TriggerEvent("vorp:TipRight", "You found the horse! Ride back to SAB.", 4000)
                end
            end

            -- Check if player reached the wagon zone in questStep 5
            if questStep == 5 then
                if IsEntityDead(playerPed) then
                    if heistLives > 1 then
                        heistLives = heistLives - 1
                        TriggerEvent("vorp:TipRight", "You died! Remaining lives: " .. heistLives, 5000)
                        Wait(3000)
                        
                        local respawnCoords = wagonCoords + vector3(math.random(-25, 25), math.random(-25, 25), 2.0)
                        TriggerEvent("vorp_core:Client:OnPlayerRevive", true)
                        Wait(500)
                        local ped = PlayerPedId()
                        SetEntityCoords(ped, respawnCoords.x, respawnCoords.y, respawnCoords.z, false, false, false, false)
                        SetEntityHealth(ped, 200)
                    else
                        questStep = 0
                        TriggerEvent("vorp:TipRight", "Heist failed! You ran out of lives.", 5000)
                        
                        if wagonHandle and DoesEntityExist(wagonHandle) then
                            DeleteVehicle(wagonHandle)
                            wagonHandle = nil
                        end
                        if wagonBlipHandle then
                            RemoveBlip(wagonBlipHandle)
                            wagonBlipHandle = nil
                        end
                        if wagonRadiusBlipHandle then
                            RemoveBlip(wagonRadiusBlipHandle)
                            wagonRadiusBlipHandle = nil
                        end
                        for _, guard in ipairs(spawnedGuards) do
                            if DoesEntityExist(guard) then
                                DeleteEntity(guard)
                            end
                        end
                        spawnedGuards = {}
                        for _, blip in ipairs(guardBlips) do
                            if blip then RemoveBlip(blip) end
                        end
                        guardBlips = {}
                        ClearGpsMultiRoute()
                        Wait(1000)
                    end
                end

                local wagonDist = #(playerCoords - wagonCoords)
                if wagonDist < 150.0 then
                    sleep = 500
                    if wagonDist < 45.0 and not guardsAlerted then
                        guardsAlerted = true
                        TriggerEvent("vorp:TipRight", "You've been spotted by the guards! Watch out!", 4000)
                        
                        for _, guard in ipairs(spawnedGuards) do
                            if DoesEntityExist(guard) then
                                FreezeEntityPosition(guard, false)
                                ClearPedTasksImmediately(guard)
                                TaskCombatPed(guard, playerPed, 0, 16)
                            end
                        end
                    end
                end

                if #spawnedGuards > 0 then
                    local allDead = true
                    for _, guard in ipairs(spawnedGuards) do
                        if DoesEntityExist(guard) and not IsPedDeadOrDying(guard, true) then
                            allDead = false
                            break
                        end
                    end

                    if allDead then
                        questStep = 6
                        TriggerEvent("vorp:TipRight", "Take the wagon and deliver to Riggs Station", 4000)
                        
                        for _, blip in ipairs(guardBlips) do
                            if blip then RemoveBlip(blip) end
                        end
                        guardBlips = {}

                        if wagonBlipHandle then
                            RemoveBlip(wagonBlipHandle)
                            wagonBlipHandle = nil
                        end
                        if wagonRadiusBlipHandle then
                            RemoveBlip(wagonRadiusBlipHandle)
                            wagonRadiusBlipHandle = nil
                        end

                        forzaBlipHandle = BlipAddForCoords(1664425300, forzaNpcCoords.x, forzaNpcCoords.y, forzaNpcCoords.z)
                        SetBlipSprite(forzaBlipHandle, blipSprite, true)
                        SetBlipName(forzaBlipHandle, "Deliver Wagon")
                        BlipAddModifier(forzaBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))

                        ClearGpsMultiRoute()
                        StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                        AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                        AddPointToGpsMultiRoute(forzaNpcCoords.x, forzaNpcCoords.y, forzaNpcCoords.z, false)
                        SetGpsMultiRouteRender(true)
                    end
                end
            end

            if questStep == 6 then
                local forzaDist = #(playerCoords - forzaNpcCoords)
                if forzaDist < 150.0 then
                    if not forzaNpcHandle or not DoesEntityExist(forzaNpcHandle) then
                        SpawnForzaNPC()
                    end
                    sleep = 500
                else
                    if forzaNpcHandle and DoesEntityExist(forzaNpcHandle) then
                        DeleteEntity(forzaNpcHandle)
                        forzaNpcHandle = nil
                    end
                end

                if wagonHandle and DoesEntityExist(wagonHandle) then
                    local wCoords = GetEntityCoords(wagonHandle)
                    local wDist = #(wCoords - forzaNpcCoords)
                    if wDist < 10.0 then
                        questStep = 7
                        
                        DeleteVehicle(wagonHandle)
                        wagonHandle = nil

                        if forzaBlipHandle then
                            RemoveBlip(forzaBlipHandle)
                            forzaBlipHandle = nil
                        end
                        ClearGpsMultiRoute()

                        -- Re-add blip specifically for talking to Forza
                        forzaBlipHandle = BlipAddForCoords(1664425300, forzaNpcCoords.x, forzaNpcCoords.y, forzaNpcCoords.z)
                        SetBlipSprite(forzaBlipHandle, blipSprite, true)
                        SetBlipName(forzaBlipHandle, "Talk to Forza")
                        BlipAddModifier(forzaBlipHandle, joaat("BLIP_MODIFIER_MP_COLOR_6"))

                        TriggerEvent("vorp:TipRight", "Wagon delivered! Go talk to Forza.", 5000)
                    end
                end
            end

            if questStep == 7 then
                local forzaDist = #(playerCoords - forzaNpcCoords)
                if forzaDist < 150.0 then
                    if not forzaNpcHandle or not DoesEntityExist(forzaNpcHandle) then
                        SpawnForzaNPC()
                    end
                    sleep = 500

                    if forzaDist < 2.5 and forzaNpcHandle and DoesEntityExist(forzaNpcHandle) then
                        sleep = 0
                        local groupName = VarString(10, 'LITERAL_STRING', "Forza")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            questStep = 0
                            TriggerEvent("vorp:TipRight", "Forza: The amount will transfer to you within 1 min. You can go now.", 8000)
                            TriggerServerEvent("wagon_heist:giveReward")

                            if forzaBlipHandle then
                                RemoveBlip(forzaBlipHandle)
                                forzaBlipHandle = nil
                            end

                            -- Remove the NPC after a short delay
                            SetTimeout(5000, function()
                                if forzaNpcHandle and DoesEntityExist(forzaNpcHandle) then
                                    DeleteEntity(forzaNpcHandle)
                                    forzaNpcHandle = nil
                                end
                            end)
                        end
                    end
                else
                    if forzaNpcHandle and DoesEntityExist(forzaNpcHandle) then
                        DeleteEntity(forzaNpcHandle)
                        forzaNpcHandle = nil
                    end
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
         if johnNpcHandle and DoesEntityExist(johnNpcHandle) then
             DeleteEntity(johnNpcHandle)
             johnNpcHandle = nil
         end
         if johnBlipHandle then
             RemoveBlip(johnBlipHandle)
             johnBlipHandle = nil
         end
         if forzaNpcHandle and DoesEntityExist(forzaNpcHandle) then
             DeleteEntity(forzaNpcHandle)
             forzaNpcHandle = nil
         end
         if forzaBlipHandle then
             RemoveBlip(forzaBlipHandle)
             forzaBlipHandle = nil
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
        if johnYesPrompt then
            if UiPromptDelete then
                UiPromptDelete(johnYesPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, johnYesPrompt)
            end
        end
        if johnNoPrompt then
            if UiPromptDelete then
                UiPromptDelete(johnNoPrompt)
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, johnNoPrompt)
            end
        end
        if wagonHandle and DoesEntityExist(wagonHandle) then
            DeleteVehicle(wagonHandle)
            wagonHandle = nil
        end
        if wagonBlipHandle then
            RemoveBlip(wagonBlipHandle)
            wagonBlipHandle = nil
        end
        if wagonRadiusBlipHandle then
            RemoveBlip(wagonRadiusBlipHandle)
            wagonRadiusBlipHandle = nil
        end
        for _, guard in ipairs(spawnedGuards) do
            if DoesEntityExist(guard) then
                DeleteEntity(guard)
            end
        end
        spawnedGuards = {}
        for _, blip in ipairs(guardBlips) do
            if blip then
                RemoveBlip(blip)
            end
        end
        guardBlips = {}
    end
end)


