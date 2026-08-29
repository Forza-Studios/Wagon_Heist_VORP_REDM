NUI = {}

-- Sends event to display "Preparing Heist..." UI loading screen
function NUI.ShowPreparingScreen()
    SendNUIMessage({
        action = "showLoading"
    })
end

-- Sends event to hide the UI loading screen
function NUI.HidePreparingScreen()
    SendNUIMessage({
        action = "hideLoading"
    })
end
