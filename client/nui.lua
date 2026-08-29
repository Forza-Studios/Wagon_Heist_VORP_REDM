NUI = {}

-- Fade screen to black (replaces the old NUI loading screen)
function NUI.ShowPreparingScreen()
    Camera.FadeOut(1000)
end

-- Fade screen back in
function NUI.HidePreparingScreen()
    Camera.FadeIn(1000)
end
