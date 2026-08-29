local Core = exports.vorp_core:GetCore()

-- Legacy event for talking (retained for backward compatibility if needed)
RegisterServerEvent("wagon_heist:startTalk", function()
    -- No-op
end)

-- Start Heist session from the client
RegisterServerEvent("wagon_heist:server:startHeist", function()
    local src = source
    local session = GetPlayerSession(src)
    
    -- If already in a session, clean it up first
    if session then
        CleanupSession(session.id)
    end
    
    -- Create session and assign routing bucket
    session = CreateSession(src)
    
    -- Trigger client loading screen UI
    TriggerClientEvent("wagon_heist:client:showPreparingScreen", src)
    session.state = "running"
    
    -- Wait to allow UI transition
    Citizen.Wait(1000)
    
    -- Start heist on client
    TriggerClientEvent("wagon_heist:client:startHeistSuccess", src, session.bucket)
end)

-- Spawn entities when player is in proximity
RegisterServerEvent("wagon_heist:server:spawnHeistEntities", function()
    local src = source
    local session = GetPlayerSession(src)
    if not session then return end
    
    if not session.entitiesSpawned then
        session.entitiesSpawned = true
        local wagonNetId = SpawnSessionEntities(session)
        TriggerClientEvent("wagon_heist:client:heistEntitiesSpawned", src, wagonNetId)
    end
end)

-- End Heist session (either success or fail)
RegisterServerEvent("wagon_heist:server:endHeist", function(success)
    local src = source
    local session = GetPlayerSession(src)
    if not session then return end
    
    if success then
        local user = Core.getUser(src)
        if user then
            local character = user.getUsedCharacter
            if character then
                if Config.RewardDelayMs and Config.RewardDelayMs > 0 then
                    Citizen.CreateThread(function()
                        Citizen.Wait(Config.RewardDelayMs)
                        local userCheck = Core.getUser(src)
                        if userCheck then
                            character.addCurrency(0, Config.RewardCash)
                            TriggerClientEvent("notify:show", src, { 
                                text = string.format("Heist payment: $%d has been transferred to your inventory!", Config.RewardCash), 
                                duration = 5000 
                            })
                        end
                    end)
                else
                    character.addCurrency(0, Config.RewardCash)
                    TriggerClientEvent("notify:show", src, { 
                        text = string.format("Heist payment: $%d has been transferred to your inventory!", Config.RewardCash), 
                        duration = 5000 
                    })
                end
            end
        end
    end
    
    -- Cleanup all session resources and return to bucket 0
    CleanupSession(session.id)
end)
