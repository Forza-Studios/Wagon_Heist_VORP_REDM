questStep = 0
local heistLives = Config.HeistLives
guardsAlerted = false
local entitiesSpawned = false

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

-- Create Prompts
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
    yesPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(yesPrompt, 0x6319DB71) -- UP Arrow
    local strYes = VarString(10, 'LITERAL_STRING', "Yes")
    UiPromptSetText(yesPrompt, strYes)
    UiPromptSetEnabled(yesPrompt, true)
    UiPromptSetVisible(yesPrompt, true)
    UiPromptSetStandardMode(yesPrompt, true)
    UiPromptSetGroup(yesPrompt, jobPromptGroup, 0)
    UiPromptRegisterEnd(yesPrompt)

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
    helpYesPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(helpYesPrompt, 0x6319DB71) -- UP Arrow
    local strYes = VarString(10, 'LITERAL_STRING', "Yes, I will help")
    UiPromptSetText(helpYesPrompt, strYes)
    UiPromptSetEnabled(helpYesPrompt, true)
    UiPromptSetVisible(helpYesPrompt, true)
    UiPromptSetStandardMode(helpYesPrompt, true)
    UiPromptSetGroup(helpYesPrompt, helpPromptGroup, 0)
    UiPromptRegisterEnd(helpYesPrompt)

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
    johnYesPrompt = UiPromptRegisterBegin()
    UiPromptSetControlAction(johnYesPrompt, 0x6319DB71) -- UP Arrow
    local strYes = VarString(10, 'LITERAL_STRING', "Yes")
    UiPromptSetText(johnYesPrompt, strYes)
    UiPromptSetEnabled(johnYesPrompt, true)
    UiPromptSetVisible(johnYesPrompt, true)
    UiPromptSetStandardMode(johnYesPrompt, true)
    UiPromptSetGroup(johnYesPrompt, johnJobPromptGroup, 0)
    UiPromptRegisterEnd(johnYesPrompt)

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

-- Server Events
RegisterNetEvent("wagon_heist:client:showPreparingScreen", function()
    Camera.FadeOut(1000)
    NUI.ShowPreparingScreen()
end)

RegisterNetEvent("wagon_heist:client:startHeistSuccess", function(bucketId)
    -- Hide loading screen and fade in
    NUI.HidePreparingScreen()
    Camera.FadeIn(1000)
    
    questStep = 1
    heistLives = Config.HeistLives
    entitiesSpawned = false
    TriggerEvent("vorp:TipRight", "Go to Strawberry and meet SAB, he will tell you what to do", 4000)
    PlaySoundFrontend("SELECT", "RDRO_Character_Creator_Sounds", true, 0)
    SpawnStrawberryNPC()
    AddStrawberryBlip()
    
    -- Setup GPS route to SAB
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
    AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
    AddPointToGpsMultiRoute(Config.StrawberryNpcCoords.x, Config.StrawberryNpcCoords.y, Config.StrawberryNpcCoords.z, false)
    SetGpsMultiRouteRender(true)
end)



RegisterNetEvent("wagon_heist:client:onSessionCleanup", function()
    questStep = 0
    entitiesSpawned = false
    CleanUpHeistClient()
end)

-- Main loop
Citizen.CreateThread(function()
    AddCatyBlip()
    CreateTalkPrompt()
    CreateJobPrompts()
    CreateHelpPrompts()
    CreateJohnJobPrompts()

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= 0 then
            local playerCoords = GetEntityCoords(playerPed)

            -- STEP 0: Talk to Caty
            local catyDist = #(playerCoords - Config.NpcCoords)
            if catyDist < 150.0 then
                if not npcHandle or not DoesEntityExist(npcHandle) then
                    SpawnCatyNPC()
                end
                sleep = 500

                if catyDist < 2.5 and questStep == 0 then
                    sleep = 0
                    if not showJobOffer and not showHelpOffer then
                        local groupName = VarString(10, 'LITERAL_STRING', "CATY")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            showJobOffer = true
                            Wait(500)
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
                            -- Start private routing bucket session immediately upon accepting job from Caty
                            TriggerServerEvent("wagon_heist:server:startHeist")
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
                RemoveCatyNPC()
            end

            -- STEP 1 or 3: Talk to SAB
            local sabDist = #(playerCoords - Config.StrawberryNpcCoords)
            if (questStep == 1 or questStep == 3) and sabDist < 150.0 then
                if not strawberryNpcHandle or not DoesEntityExist(strawberryNpcHandle) then
                    SpawnStrawberryNPC()
                end
                sleep = 500

                if sabDist < 2.5 then
                    sleep = 0
                    if questStep == 1 then
                        local groupName = VarString(10, 'LITERAL_STRING', "SAB")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            questStep = 2
                            TriggerEvent("vorp:TipRight", "My horse is trapped near Owanjila Pond. Go and bring it back to me.", 4000)
                            
                            if strawberryBlipHandle then
                                RemoveBlip(strawberryBlipHandle)
                                strawberryBlipHandle = nil
                            end
                            ClearGpsMultiRoute()

                            SpawnQuestHorse()
                            AddHorseBlips()
                            Wait(1000)
                        end
                    elseif questStep == 3 then
                        local groupName = VarString(10, 'LITERAL_STRING', "SAB")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            questStep = 4
                            TriggerEvent("vorp:TipRight", "Thank you for bringing back my horse!", 4000)
                            Wait(4000)
                            TriggerEvent("vorp:TipRight", "Go and meet John at New Hanover and he will give you more details.", 4000)
                            
                            AddJohnBlip()
                            
                            StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                            AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                            AddPointToGpsMultiRoute(Config.JohnNpcCoords.x, Config.JohnNpcCoords.y, Config.JohnNpcCoords.z, false)
                            SetGpsMultiRouteRender(true)
                            
                            if sabReturnBlip then
                                RemoveBlip(sabReturnBlip)
                                sabReturnBlip = nil
                            end

                            RemoveQuestHorse()
                            Wait(1000)
                        end
                    end
                end
            end

            -- STEP 2: Find and mount the Horse
            if questStep == 2 and horseHandle and DoesEntityExist(horseHandle) then
                local currentMount = GetMount(playerPed)
                if currentMount == horseHandle then
                    questStep = 3

                    if horseBlipHandle then RemoveBlip(horseBlipHandle) horseBlipHandle = nil end
                    if horseRadiusBlipHandle then RemoveBlip(horseRadiusBlipHandle) horseRadiusBlipHandle = nil end

                    AddSabReturnBlip()
                    
                    StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                    AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                    AddPointToGpsMultiRoute(Config.StrawberryNpcCoords.x, Config.StrawberryNpcCoords.y, Config.StrawberryNpcCoords.z, false)
                    SetGpsMultiRouteRender(true)
                    
                    TriggerEvent("vorp:TipRight", "You found the horse! Ride back to SAB.", 4000)
                end
            end

            -- STEP 4: Talk to John
            local johnDist = #(playerCoords - Config.JohnNpcCoords)
            if (questStep == 4 or questStep == 5) and johnDist < 150.0 then
                if not johnNpcHandle or not DoesEntityExist(johnNpcHandle) then
                    SpawnJohnNPC()
                end
                sleep = 500

                if johnDist < 2.5 and questStep == 4 then
                    sleep = 0
                    if not showJohnJobOffer then
                        local groupName = VarString(10, 'LITERAL_STRING', "John")
                        UiPromptSetActiveGroupThisFrame(promptGroup, groupName, 0, 0, 0, 0)

                        if UiPromptHasHoldModeCompleted(talkPrompt) then
                            showJohnJobOffer = true
                            Wait(500)
                        end
                    elseif showJohnJobOffer then
                        local johnGroupName = VarString(10, 'LITERAL_STRING', "Are you interested in this job?")
                        UiPromptSetActiveGroupThisFrame(johnJobPromptGroup, johnGroupName, 0, 0, 0, 0)

                        if UiPromptHasStandardModeCompleted(johnYesPrompt) or IsControlJustPressed(0, 0x6319DB71) then
                            showJohnJobOffer = false
                            if johnBlipHandle then
                                RemoveBlip(johnBlipHandle)
                                johnBlipHandle = nil
                            end
                            questStep = 5
                            heistLives = Config.HeistLives
                            TriggerEvent("vorp:TipRight", "Go to Fort Brennand and find the wagon.", 4000)
                            AddWagonBlips()

                            -- Setup path route to wagon
                            ClearGpsMultiRoute()
                            StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                            AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                            AddPointToGpsMultiRoute(Config.WagonCoords.x, Config.WagonCoords.y, Config.WagonCoords.z, false)
                            SetGpsMultiRouteRender(true)
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
                    RemoveJohnNPC()
                    showJohnJobOffer = false
                end
            end

            -- STEP 5: In Heist (Wait/fight guards, get wagon)
            if questStep == 5 then
                -- Proximity-based entity spawn trigger
                local wagonDist = #(playerCoords - Config.WagonCoords)
                if wagonDist < 150.0 and not entitiesSpawned then
                    entitiesSpawned = true
                    TriggerServerEvent("wagon_heist:server:spawnHeistEntities")
                end

                -- Death check inside the instanced heist
                if IsEntityDead(playerPed) then
                    if heistLives > 1 then
                        heistLives = heistLives - 1
                        TriggerEvent("vorp:TipRight", "You died! Remaining lives: " .. heistLives, 5000)
                        Wait(3000)
                        
                        local respawnCoords = Config.WagonCoords + vector3(math.random(-25, 25), math.random(-25, 25), 2.0)
                        TriggerEvent("vorp_core:Client:OnPlayerRevive", true)
                        Wait(500)
                        local ped = PlayerPedId()
                        SetEntityCoords(ped, respawnCoords.x, respawnCoords.y, respawnCoords.z, false, false, false, false)
                        SetEntityHealth(ped, 200)
                    else
                        TriggerEvent("vorp:TipRight", "Heist failed! You ran out of lives.", 5000)
                        TriggerServerEvent("wagon_heist:server:endHeist", false)
                        Wait(1000)
                    end
                end

                -- Alert guards check
                if wagonDist < 150.0 then
                    sleep = 500
                    if wagonDist < 45.0 and not guardsAlerted then
                        guardsAlerted = true
                        TriggerEvent("vorp:TipRight", "You've been spotted by the guards! Watch out!", 4000)
                        AlertGuards(playerPed)
                    end
                end

                -- Check if guards are dead
                if AreAllGuardsDead() then
                    questStep = 6
                    TriggerEvent("vorp:TipRight", "Take the wagon and deliver to Riggs Station", 4000)
                    ClearGuardBlips()

                    if wagonBlipHandle then RemoveBlip(wagonBlipHandle) wagonBlipHandle = nil end
                    if wagonRadiusBlipHandle then RemoveBlip(wagonRadiusBlipHandle) wagonRadiusBlipHandle = nil end

                    AddDeliveryBlip()

                    ClearGpsMultiRoute()
                    StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
                    AddPointToGpsMultiRoute(playerCoords.x, playerCoords.y, playerCoords.z, false)
                    AddPointToGpsMultiRoute(Config.DeliveryCoords.x, Config.DeliveryCoords.y, Config.DeliveryCoords.z, false)
                    SetGpsMultiRouteRender(true)
                end
            end

            -- STEP 6: Delivering Wagon to Cylinder Marker
            if questStep == 6 then
                local deliveryDist = #(playerCoords - Config.DeliveryCoords)
                if deliveryDist < 100.0 then
                    sleep = 0
                    -- Draw cylinder marker at delivery location
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, Config.DeliveryCoords.x, Config.DeliveryCoords.y, Config.DeliveryCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.5, 229, 193, 88, 150, false, false, 2, false, nil, nil, false)
                else
                    sleep = 500
                end

                if wagonHandle and DoesEntityExist(wagonHandle) then
                    local playerVehicle = GetVehiclePedIsIn(playerPed, false)
                    local wCoords = GetEntityCoords(wagonHandle)
                    local distToWagon = #(playerCoords - wCoords)

                    -- Anti-exploit: Check if player left the wagon / is far from wagon
                    if playerVehicle ~= wagonHandle and distToWagon > 15.0 then
                        if not wagonAbandonTimer then
                            wagonAbandonTimer = GetGameTimer() + (Config.WagonAbandonTimeout * 1000)
                        end

                        local timeLeft = math.ceil((wagonAbandonTimer - GetGameTimer()) / 1000)
                        if timeLeft > 0 then
                            sleep = 0
                            -- Display countdown warning
                            TriggerEvent("vorp:TipBottom", string.format("Return to the wagon! Time remaining: %ds", timeLeft), 500)
                        else
                            -- Timer expired: fail mission
                            wagonAbandonTimer = nil
                            questStep = 0
                            TriggerEvent("vorp:TipRight", "Heist failed! You abandoned the wagon.", 5000)
                            TriggerServerEvent("wagon_heist:server:endHeist", false)
                        end
                    else
                        wagonAbandonTimer = nil
                    end

                    -- Check delivery inside marker
                    local wDist = #(wCoords - Config.DeliveryCoords)
                    if wDist < 6.0 then
                        questStep = 0
                        wagonAbandonTimer = nil
                        
                        -- Delete vehicle
                        DeleteVehicle(wagonHandle)
                        wagonHandle = nil

                        if forzaBlipHandle then RemoveBlip(forzaBlipHandle) forzaBlipHandle = nil end
                        ClearGpsMultiRoute()

                        -- Play mission complete sound effect
                        PlaySoundFrontend("CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true, 0)

                        -- Notify player
                        TriggerEvent("vorp:TipRight", "Wagon delivered! Heist successfully completed!", 5000)

                        -- Trigger server instant payout & cleanup
                        TriggerServerEvent("wagon_heist:server:endHeist", true)
                        Wait(1000)
                    end
                else
                    -- Wagon destroyed or missing
                    wagonAbandonTimer = nil
                    questStep = 0
                    TriggerEvent("vorp:TipRight", "Heist failed! The wagon was destroyed.", 5000)
                    TriggerServerEvent("wagon_heist:server:endHeist", false)
                end
            else
                wagonAbandonTimer = nil
            end
        end
        Wait(sleep)
    end
end)

-- Resource Stop Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanUpHeistClient()

        local prompts = { talkPrompt, yesPrompt, noPrompt, helpYesPrompt, helpNoPrompt, johnYesPrompt, johnNoPrompt }
        for _, prompt in ipairs(prompts) do
            if prompt then
                if UiPromptDelete then
                    UiPromptDelete(prompt)
                else
                    Citizen.InvokeNative(0x00EDE88D4D13CF59, prompt)
                end
            end
        end
    end
end)
