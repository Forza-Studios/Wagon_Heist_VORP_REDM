Camera = {}

-- Fades screen out and waits until completed
function Camera.FadeOut(duration)
    DoScreenFadeOut(duration or 1000)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
end

-- Fades screen in and waits until completed
function Camera.FadeIn(duration)
    DoScreenFadeIn(duration or 1000)
    while not IsScreenFadedIn() do
        Citizen.Wait(10)
    end
end
