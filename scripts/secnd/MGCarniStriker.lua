--[[ Changes to this file:
    * Modified function HighStrikerRun, may require testing
]]

local bRunTutorial = GetMissionCurrentAttemptCount() <= 2
local PINKY_CHEER = 1
local PINKY_BOO = 2
local bResultDisplayed, mission_started = false
local result = 0
local curResult = 0
local gFirstStrike = -1
local gSecondStrike = -1
local gCost = -100
local bHammerLifted = false
local gTicketCount = 0
local gCarnie
local bClockPaused = false
local bPlayerEnteredWithBear = false

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("HighStrikerProps.DAT", 2)
    DATLoad("CarnStrik.DAT", 2)
    DATInit()
    DisablePOI(true, true)
    bClockPaused = ClockIsPaused()
    PauseGameClock()
    SoundLoadBank("MINIGAME\\HiStrkr.bnk")
    MinigameCreate("STRIKER", false)
    LoadActionTree("Act/Anim/HighStriker.act")
    LoadAnimationGroup("Car_Ham")
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._HIGHSTRIKEREXCLUDER, true)
    SoundFadeoutStream(0)
    SoundPlayStream("MS_CarnivalFunhouseAmbient.rsm", 0.6)
end

function MissionCleanup()
    EnablePOI(true, true)
    TextClear()
    CameraReturnToPlayer()
    CameraReset()
    PlayerWeaponHudLock(false)
    if F_PedExists(gCarnie) then
        --print(">>>[RUI]", "cleanup Freeley")
        PedSetStationary(gCarnie, false)
        PedMakeAmbient(gCarnie)
    end
    MinigameDestroy()
    PlayerSetPunishmentPoints(0)
    UnLoadAnimationGroup("Car_Ham")
    SoundUnLoadBank("MINIGAME\\HiStrkr.bnk")
    mission_started = false
    EnableHudComponents(true)
    shared.minigameRunning = nil
    F_MakePlayerSafeForNIS(false)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._HIGHSTRIKEREXCLUDER, false)
    PlayerSetControl(1)
    DATUnload(2)
    SoundFadeoutStream(0)
    if bPlayerEnteredWithBear then
        PedSetWeapon(gPlayer, 363, 1)
        --print("()xxxxx[:::::::::::::::> [mgshootinggallery.lua] Restoring teddy bear.")
        bPlayerEnteredWithBear = false
    end
    collectgarbage()
end

function F_CarnyInsultForFailure(score)
    if score <= 5 then
        --print(">>>[RUI]", "Carny: Dang, son.  Even I'm embarassed by that one!")
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 1, "jumbo")
    elseif score <= 10 then
        --print(">>>[RUI]", "Carny: I think you're the worst I've ever seen")
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 2, "jumbo")
    elseif score <= 15 then
        --print(">>>[RUI]", "Carny:  Frankly, that's just pathetic.")
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 3, "jumbo")
    end
end

function F_CarnyRemark(score)
    if score < 20 then
        return
    end
    if score <= 20 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 20, "jumbo")
        --print(">>>[RUI]", "Carny:  You got to HIT it, son.  Don't blow it a kiss.")
    elseif score <= 25 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 25, "jumbo")
        --print(">>>[RUI]", "Carny: Maybe you should just jump on the pad?")
    elseif score <= 30 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 30, "jumbo")
        --print(">>>[RUI]", "Carny:  You could almost call that one respectable.  If you was a girl.")
    elseif score <= 40 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 40, "jumbo")
        --print(">>>[RUI]", "Carny:  That almost had some power behind it!", "jumbo")
    elseif score <= 50 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 50, "jumbo")
        --print(">>>[RUI]", "Carny:  Halfway to the promised land, son!  One more try and I know you got it.")
    elseif score <= 60 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 60, "jumbo")
        --print(">>>[RUI]", "Carny:  Lookee here, folks!  Gather round and watch this young man go all the way!")
    elseif score <= 70 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 70, "jumbo")
        --print(">>>[RUI]", "Carny:  You almost had it, son.  Course, almost don't get you squat.")
    elseif score <= 80 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 80, "jumbo")
        --print(">>>[RUI]", "Carny:  Whoo diggity!  That there's a sight to behold.  Gather round, folks!  This young man's gonna ring the bell!")
    elseif score <= 98 then
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 90, "jumbo")
        --print(">>>[RUI]", "Carny:  Almost, almost!  Folks, we got ourselves a contender, here!")
    else
        SoundPlayScriptedSpeechEvent(gCarnie, "HISTRIKE", 4, "jumbo")
        --print(">>>[RUI]", "Carny:  Hoo boy!  We got ourselves a winner, folks!")
    end
end

function F_CarnieFirstStrike(param)
    gFirstStrike = param
end

function F_CarnieSecondStrike(param)
    gSecondStrike = param
end

function MissionInit()
    PlayerSetControl(0)
    PedSetWeaponNow(gPlayer, -1, 0)
    AreaClearAllPeds()
    F_MakePlayerSafeForNIS(true)
    if IsMissionCompleated("C_Photography_5") then
        gTicketMultiplier = 2
    else
        gTicketMultiplier = 1
    end
    if PlayerHasWeapon(363) then
        WeaponRequestModel(363)
        --print("()xxxxx[:::::::::::::::> [mgshootinggallery.lua] Player entered with a teddy bear.")
        bPlayerEnteredWithBear = true
    end
    PlayerUnequip()
    Wait(100)
    PlayerWeaponHudLock(true)
    AreaTransitionPoint(0, POINTLIST._HS_PLAYER)
    mission_started = true
    EnableHudComponents(false)
    shared.minigameRunning = "CarnieStriker"
    local bStartGame = false
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerFaceHeadingNow(180)
    LoadModels({ 332, 495 })
    gCarnie = PedCreatePoint(143, POINTLIST._HS_CARNIE, 1)
    PedSetStationary(gCarnie, true)
    PedFaceObject(gCarnie, gPlayer, 3, 1, false)
    ToggleHUDComponentVisibility(20, false)
    PAnimCreate(TRIGGER._HSDINGER)
    PAnimReset(TRIGGER._HSDINGER)
    PedSetActionTree(gPlayer, "/Global/HighStriker", "Act/Anim/HighStriker.act")
    PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/Start/Start", "Act/Anim/HighStriker.act")
    CameraFade(500, 1)
    Wait(500)
    CameraSetXYZ(164.07652, 437.95673, 6.260658, 163.50488, 438.7185, 6.56444)
    while MinigameIsReady() == false do
        Wait(0)
    end
    --print(">>>[RUI]", "MinigameIsReady")
    Wait(1000)
    --print(">>>[RUI]", "!!MissionInit")
end

function F_DisplayCountdown()
    while not IsButtonBeingPressed(7, 0) do
        TextPrint("HS_XSTART", 0.5, 1)
        Wait(10)
        if IsButtonBeingPressed(8, 0) then
            TutorialRemoveMessage()
            shared.quit_minigame = true
            bQuitGame = true
            break
        end
    end
    if not bClockPaused then
        UnpauseGameClock()
    end
    bClockPaused = false
    if not bQuitGame then
        SoundPlayAmbientSpeechEvent(gCarnie, "CARNIE_GAME_SELL")
        PlayerAddMoney(gCost)
        SoundPlay2D("BuyItem")
        TextPrint("MG_READY", 1, 1)
        Wait(1000)
        TextPrint("MG_SET", 1, 1)
        Wait(1000)
        TutorialRemoveMessage()
        TextPrint("MG_GO", 1, 1)
    end
end

function F_HammerLifted()
    --print(">>>[RUI]", "!!F_HammerLifted")
    bHammerLifted = true
end

function F_HammerSwingDone()
    --print(">>>[RUI]", "F_HammerSwingDone")
    bHammerSwingDone = true
end

function HighStrikerRun() -- ! Modified
    local result, power, action = 0, 0, 0
    MinigameStart()
    MinigameEnableHUD(true)
    CarnivalStrikerMeterSetParams(1.8, 9, 0.08, 2, 0.01)
    CarnivalStrikerMeterStart()
    --print(">>>[RUI]", "!!MiniGameStarted")
    Wait(100)
    PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/HammerLiftHold", "Act/Anim/HighStriker.act")
    PlayerSetControl(1)
    while not bHammerLifted do
        if MinigameIsSuccess() then
            break
        end
        Wait(0)
    end
    Wait(125)
    PlayerSetControl(0)
    power = CarnivalStrikerMeterGetLevel()
    Wait(125)
    --print(">>>[RUI]", "Raw Power: " .. power)
    result = PowerToResult(power)
    if result < 10 then
        PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/HammerSwings/Fail", "Act/Anim/HighStriker.act")
        F_CarnyInsultForFailure(result)
        action = PINKY_BOO
        --print(">>>[RUI]", "swing FAIL")
    elseif result <= 50 then
        PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/HammerSwings/Weak", "Act/Anim/HighStriker.act")
        action = PINKY_BOO
        --print(">>>[RUI]", "swing WEAK")
    elseif result < 80 then
        PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/HammerSwings/Medium", "Act/Anim/HighStriker.act")
        action = PINKY_BOO
        --print(">>>[RUI]", "swing MEDIUM")
    elseif 80 <= result then
        action = PINKY_CHEER
        PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/HammerSwings/Strong", "Act/Anim/HighStriker.act")
        --print(">>>[RUI]", "swing STRONG")
    end
    while not bHammerSwingDone do
        Wait(0)
    end
    PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/End/EndDropHammer", "Act/Anim/HighStriker.act")
    local x, y, z = GetPointFromPointList(POINTLIST._HS_CAMLOOKAT, 1)
    CameraLookAtXYZ(x, y, z, true)
    CameraSetSpeed(400, 400, 0)
    --[[
    CameraSetPath(PATH._HS_DINGER_CAM_PATH, true)
    ]] -- Removed this
    Wait(250)
    HighStrikerDingerRespond(result)
    MinigameEnd()
    --print(">>>[RUI]", "!!HighStrikerRun result: " .. tostring(result))
    if shared.g2_G2 then
        shared.MGaction = action
    end
    return result
end

function PowerToResult(power)
    --print(">>>[RUI]", "!!PowerToResult  power: " .. tostring(power))
    local result
    if power < 10 then
        result = 0
    elseif 98 < power then
        result = 100
    else
        result = power - math.mod(power, 10)
    end
    return result
end

function F_FailDone()
    --print(">>>[RUI]", "!!F_FailDone")
    bFailDone = true
end

function HighStrikerDingerRespond(score)
    --print(">>>[RUI]", "++HighStrikerDingerRespond score: " .. score)
    curResult = score
    if 0 < score then
        --print(">>>[RUI]", "score > 0")
        PAnimFollowPath(TRIGGER._HSDINGER, PATH._HS_DINGER_PATH, false, cbDingerPath)
        dx, dy, dz = PAnimGetPosition(TRIGGER._HSDINGER)
        MinigameEnableHUD(false)
        PAnimSetPathFollowSpeed(TRIGGER._HSDINGER, 4)
        SoundLoopPlay2D("DivitClimb", true)
        while not bResultDisplayed do
            dx, dy, dz = PAnimGetPosition(TRIGGER._HSDINGER)
            CameraLookAtXYZ(dx, dy, dz, false)
            CameraSetXYZ(162.3, 440.1, dz, dx, dy, dz)
            Wait(0)
        end
        --print(">>>[RUI]", "bResultDisplayed")
        SoundLoopPlay2D("DivitClimb", false)
    end
    F_CarnyRemark(score)
    --print(">>>[RUI]", "--HighStrikerDingerRespond")
end

function cbDingerPath(idTrigger, idPath, idNode)
    local speed = PAnimGetPathFollowSpeed(idTrigger)
    --print(">>>[RUI]", "cbDingerPath " .. result, curResult, idNode, speed)
    if 0 <= speed and curResult ~= nil then
        curResult = curResult - 5
        --print(curResult)
        if curResult < 4.5 then
            CameraLookAtPathSetSpeed(0.01, 0, 0)
            CameraSetSpeed(0.01, 0, 0)
            PAnimSetPathFollowSpeed(TRIGGER._HSDINGER, -1)
            bResultDisplayed = true
        end
        if idNode == 20 then
            CameraLookAtXYZ(162.297, 438.813, 17.4426, true)
            SoundPlay2D("BellHit")
        end
    end
end

function HighStrikerTallyTickets(score)
    local tickets = 0
    if 99 <= score then
        tickets = 3
    elseif 80 <= score then
        tickets = 2
    elseif 70 <= score then
        tickets = 1
    else
        SoundPlayAmbientSpeechEvent(gCarnie, "CARNIE_GAME_EXIT_LOSE")
    end
    return tickets * gTicketMultiplier
end

function main()
    MissionInit()
    F_DisplayCountdown()
    if not bQuitGame then
        result = HighStrikerRun()
        --print(">>>[RUI]", "MinigameEnd")
        if 70 <= result then
            gTicketCount = HighStrikerTallyTickets(result)
            GiveItemToPlayer(495, gTicketCount)
            Wait(3000)
            CameraFade(500, 0)
            Wait(501)
            PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/End/EndDropHammer", "Act/Anim/HighStriker.act")
            MissionSucceed(false, true, false)
        else
            SoundPlayAmbientSpeechEvent(gCarnie, "CARNIE_GAME_EXIT_LOSE")
            Wait(2000)
            CameraFade(500, 0)
            Wait(501)
            PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/End/EndDropHammer", "Act/Anim/HighStriker.act")
            MissionFail(false, false)
        end
    else
        CameraFade(500, 0)
        Wait(501)
        PedSetActionNode(gPlayer, "/Global/HighStriker/HammerActions/End/EndDropHammer", "Act/Anim/HighStriker.act")
        MissionFail(true, false)
    end
    --print(">>>[RUI]", "--MAIN")
end

function EnableHudComponents(bShow)
    bShow = bShow or false
    --print(">>>[RUI]", "!!EnableHudComponents  " .. tostring(bShow))
    ToggleHUDComponentVisibility(11, bShow)
    ToggleHUDComponentVisibility(4, bShow)
    ToggleHUDComponentVisibility(0, bShow)
    ToggleHUDComponentVisibility(20, bShow)
end
