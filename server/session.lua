sessions = {}
local sessionCounter = 0
local playerSessions = {}

-- Create a new heist session
function CreateSession(ownerSource)
    sessionCounter = sessionCounter + 1
    local sessionId = "session_" .. sessionCounter
    local bucketId = 100 + sessionCounter

    sessions[sessionId] = {
        id = sessionId,
        bucket = bucketId,
        owner = ownerSource,
        members = { [ownerSource] = true },
        entities = {},
        state = "preparing"
    }

    playerSessions[ownerSource] = sessionId

    -- Set the owner player to the session's routing bucket
    SetPlayerRoutingBucket(ownerSource, bucketId)
    print(string.format("[WagonHeist] Created session %s (Bucket %d) for owner %d", sessionId, bucketId, ownerSource))
    
    return sessions[sessionId]
end

-- Get a player's active session
function GetPlayerSession(source)
    local sessionId = playerSessions[source]
    if sessionId then
        return sessions[sessionId]
    end
    return nil
end

-- Add a member to a session
function AddSessionMember(sessionId, memberSource)
    local session = sessions[sessionId]
    if not session then return false end

    session.members[memberSource] = true
    playerSessions[memberSource] = sessionId
    SetPlayerRoutingBucket(memberSource, session.bucket)
    return true
end

-- Remove a member from a session
function RemoveSessionMember(sessionId, memberSource)
    local session = sessions[sessionId]
    if not session then return end

    if session.members[memberSource] then
        session.members[memberSource] = nil
        playerSessions[memberSource] = nil
        SetPlayerRoutingBucket(memberSource, 0)
    end
end

-- Track a server-spawned entity in the session
function AddSessionEntity(sessionId, entity)
    local session = sessions[sessionId]
    if not session then return end
    table.insert(session.entities, entity)
end

-- Cleanup a session completely
function CleanupSession(sessionId)
    local session = sessions[sessionId]
    if not session then return end

    print(string.format("[WagonHeist] Cleaning up session %s...", sessionId))

    -- Delete all tracked entities
    for _, entity in ipairs(session.entities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    -- Return all remaining members to bucket 0
    for memberSource, _ in pairs(session.members) do
        playerSessions[memberSource] = nil
        SetPlayerRoutingBucket(memberSource, 0)
        TriggerClientEvent("wagon_heist:client:onSessionCleanup", memberSource)
    end

    sessions[sessionId] = nil
end

-- Clean up on player dropped
AddEventHandler("playerDropped", function(reason)
    local source = source
    local session = GetPlayerSession(source)
    if session then
        if session.owner == source then
            -- Owner disconnected, clean up the entire session
            CleanupSession(session.id)
        else
            -- Member disconnected, just remove them
            RemoveSessionMember(session.id, source)
        end
    end
end)

-- Clean up all sessions on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("[WagonHeist] Resource stopping, cleaning up all sessions...")
    for sessionId, _ in pairs(sessions) do
        CleanupSession(sessionId)
    end
end)
