-- Shared Utility Functions
Utils = {}

function Utils.DebugPrint(msg)
    if GetConvar("wagon_heist_debug", "false") == "true" then
        print("[WagonHeist Debug] " .. tostring(msg))
    end
end
