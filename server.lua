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

    character.addCurrency(0, 1000.0) -- Give $1000 cash
    TriggerClientEvent("vorp:TipRight", _source, "Heist payment: $1000 has been transferred to your inventory!", 5000)
end)
