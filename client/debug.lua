-- ============================================================
--  WagonHeist Debug Commands  (client-side)
--  Usage in F8 console:
--    /whdebug <step>         -- Jump to a quest step (0-6)
--    /whdebug status         -- Print current quest state
--    /whdebug guards         -- Print guard count / alive status
--    /whdebug spawn          -- Force-spawn heist entities now
--    /whdebug cleanup        -- Run full client cleanup
--    /whdebug tp <step>      -- Teleport to the NPC/location for that step
-- ============================================================

local STEPS = {
    [0] = "STEP 0  - Talk to Caty (no active quest)",
    [1] = "STEP 1  - Talk to SAB in Strawberry",
    [2] = "STEP 2  - Find & mount SAB's horse near Owanjila Pond",
    [3] = "STEP 3  - Return the horse to SAB",
    [4] = "STEP 4  - Talk to John in New Hanover",
    [5] = "STEP 5  - Heist zone (fight guards, reach wagon)",
    [6] = "STEP 6  - Deliver the wagon to Riggs Station",
}

local function dbgPrint(msg)
    print(string.format("^3[WH-DEBUG]^7 %s", msg))
    TriggerEvent("vorp:TipRight", "[DEBUG] " .. msg, 4000)
end

local function getPlayerCoords()
    local ped = PlayerPedId()
    return GetEntityCoords(ped)
end

local function setRoute(destCoords)
    ClearGpsMultiRoute()
    local pc = getPlayerCoords()
    StartGpsMultiRoute(joaat("COLOR_YELLOW"), true, true)
    AddPointToGpsMultiRoute(pc.x, pc.y, pc.z, false)
    AddPointToGpsMultiRoute(destCoords.x, destCoords.y, destCoords.z, false)
    SetGpsMultiRouteRender(true)
end

-- /whdebug
RegisterCommand("whdebug", function(source, args, rawCommand)

    local sub = args[1]

    -- /whdebug status
    if sub == "status" then
        dbgPrint(string.format("questStep=%d  guardsAlerted=%s", questStep, tostring(guardsAlerted)))
        dbgPrint(STEPS[questStep] or "Unknown step")
        return
    end

    -- /whdebug guards
    if sub == "guards" then
        local total, alive = 0, 0
        for _, g in ipairs(spawnedGuards) do
            total = total + 1
            if DoesEntityExist(g) and not IsPedDeadOrDying(g, true) then
                alive = alive + 1
            end
        end
        dbgPrint(string.format("Guards: %d total, %d alive", total, alive))
        return
    end

    -- /whdebug spawn
    if sub == "spawn" then
        dbgPrint("Force-triggering server entity spawn...")
        TriggerServerEvent("wagon_heist:server:spawnHeistEntities")
        return
    end

    -- /whdebug cleanup
    if sub == "cleanup" then
        dbgPrint("Running full client cleanup -> step 0")
        questStep = 0
        guardsAlerted = false
        CleanUpHeistClient()
        return
    end

    -- /whdebug tp <step>
    if sub == "tp" then
        local step = tonumber(args[2])
        local STEP_COORDS = {
            [0] = Config.NpcCoords,
            [1] = Config.StrawberryNpcCoords,
            [2] = Config.HorseCoords,
            [3] = Config.StrawberryNpcCoords,
            [4] = Config.JohnNpcCoords,
            [5] = Config.WagonCoords,
            [6] = Config.DeliveryCoords,
        }
        if not step or not STEP_COORDS[step] then
            dbgPrint("Usage: /whdebug tp <0-6>")
            return
        end
        local c = STEP_COORDS[step]
        SetEntityCoords(PlayerPedId(), c.x, c.y, c.z + 0.5, false, false, false, false)
        dbgPrint(string.format("Teleported to step %d: %.1f, %.1f, %.1f", step, c.x, c.y, c.z))
        return
    end

    -- /whdebug <0-6>  jump to quest step
    local step = tonumber(sub)
    if not step or not STEPS[step] then
        dbgPrint("=== WagonHeist Debug Commands ===")
        dbgPrint("/whdebug <0-6>      - jump to step")
        dbgPrint("/whdebug status     - current state")
        dbgPrint("/whdebug guards     - guard status")
        dbgPrint("/whdebug spawn      - force entity spawn")
        dbgPrint("/whdebug cleanup    - reset to step 0")
        dbgPrint("/whdebug tp <0-6>  - teleport to step location")
        return
    end

    questStep = step
    guardsAlerted = false
    dbgPrint(string.format("questStep -> %d | %s", step, STEPS[step]))

    if step == 0 then
        CleanUpHeistClient()

    elseif step == 1 then
        SpawnStrawberryNPC()
        AddStrawberryBlip()
        setRoute(Config.StrawberryNpcCoords)

    elseif step == 2 then
        SpawnQuestHorse()
        AddHorseBlips()

    elseif step == 3 then
        SpawnStrawberryNPC()
        AddSabReturnBlip()
        setRoute(Config.StrawberryNpcCoords)

    elseif step == 4 then
        SpawnJohnNPC()
        AddJohnBlip()
        setRoute(Config.JohnNpcCoords)

    elseif step == 5 then
        TriggerServerEvent("wagon_heist:server:startHeist")
        Wait(1500)
        AddWagonBlips()
        setRoute(Config.WagonCoords)
        dbgPrint("Server session started. Go near the wagon to trigger guard spawn.")

    elseif step == 6 then
        ClearGuardBlips()
        AddDeliveryBlip()
        setRoute(Config.DeliveryCoords)
        dbgPrint("NOTE: wagonHandle may be nil if guards weren't killed. Use /whdebug spawn first.")
    end

end, false)