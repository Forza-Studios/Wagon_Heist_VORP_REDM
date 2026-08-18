local Core = exports.vorp_core:GetCore()

RegisterServerEvent("wagon_heist:startTalk", function()
    local _source = source
end)

RegisterServerEvent("wagon_heist:giveReward", function()
    local _source = source
    local user = Core.getUser(_source)
    if not user then return end

    local character = user.getUsedCharacter
    if not character then return end

    -- Delay reward by 1 minute for production
    Citizen.CreateThread(function()
        Citizen.Wait(60000)
        
        -- Check if player is still online
        local userCheck = Core.getUser(_source)
        if userCheck then
            character.addCurrency(0, 1000.0) -- Give $1000 cash
            TriggerClientEvent("notify:show", _source, { text = "Heist payment: $1000 has been transferred to your inventory!", duration = 5000 })
        end
    end)
end)
