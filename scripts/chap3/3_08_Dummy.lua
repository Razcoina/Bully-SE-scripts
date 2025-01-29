function MissionSetup()
    MissionDontFadeIn()
    if MissionActiveSpecific("3_08_Launch") then
        F_MakePlayerSafeForNIS(true)
        PlayerSetControl(0)
        PauseGameClock()
    end
end

function MissionCleanup()
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
end

function main()
    CameraSetWidescreen(false)
    CameraFade(500, 1)
    Wait(501)
    Wait(2000)
    MissionSucceed(false, false, false)
end
