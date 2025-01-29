local playerWins = false

function MissionSetup()
    DATLoad("ClassLoc.DAT", 2)
    DATInit()
    AreaTransitionPoint(15, POINTLIST._SV_SCHOOLENGLISH)
    PlayerSetControl(0)
    MinigameCreate("LOCK", false)
    while MinigameIsReady() == false do
        Wait(0)
    end
    Wait(2)
end

function MissionCleanup()
    MinigameDestroy()
    PlayerSetPunishmentPoints(0)
    Wait(1)
    AreaTransitionPoint(15, POINTLIST._SV_SCHOOLENGLISH)
    PlayerSetControl(1)
    DATUnload(2)
end

function main()
    MinigameStart()
    MinigameEnableHUD(true)
    CameraFade(1000, 1)
    Wait(1100)
    while MinigameIsActive() do
        Wait(0)
    end
    if MinigameIsSuccess() then
        Wait(2000)
        playerWins = true
    end
    MinigameEnableHUD(false)
    if playerWins then
        TextPrintString("You win!", 3)
    else
        TextPrintString("You lose.  GAME OVER.", 3)
    end
    Wait(4000)
    MinigameEnd()
    if playerWins then
        MissionSucceed()
    else
        MissionFail()
    end
end
