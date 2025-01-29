local bRunTutorial = GetMissionCurrentAttemptCount() <= 2
local MAX_BALLCOUNT = 3
local PINKY_CHEER = 1
local PINKY_BOO = 2
local gCurrentBallCount = MAX_BALLCOUNT
local gTauntTime = 3000
local gCost = -100
local gTicketsWon
local gTicketMultiplier = 1
local bClockPaused = false
local bPlayerEnteredWithBear = false

function T_HandleTutorial()
    while bRunTutorial do
        TextPrint("MGDT_INSTRUCT", 0.5, 3)
        Wait(0)
    end
    collectgarbage()
end

function F_DisplayCountdown()
    while not IsButtonBeingPressed(7, 0) do
        TextPrint("MGDT_XSTART", 0.5, 1)
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
        PlayerAddMoney(gCost)
        SoundPlay2D("BuyItem")
        TextPrint("MG_READY", 1, 1)
        Wait(1000)
        TextPrint("MG_SET", 1, 1)
        Wait(1000)
        TutorialRemoveMessage()
        TextPrint("MG_GO", 1, 1)
        PedSetActionNode(gCarnie, "/Global/DunkTank/Carny/TauntLoop/Taunts/Taunt_A", "Act/Conv/MGDunkTank.act")
    end
end

function F_LoadProps()
    PAnimCreate(TRIGGER._DUNKBTTN)
    PAnimOverrideDamage(TRIGGER._DUNKBTTN, 500)
    PAnimCreate(TRIGGER._DUNKSEAT)
    --print(">>>[RUI]", "!!F_LoadProps")
end

function MissionSetup()
    MissionDontFadeIn()
    SoundFadeoutStream(0)
    SoundPlayStream("MS_CarnivalFunhouseAmbient.rsm", 0.6)
    AreaClearAllPeds()
    if PedIsValid(shared.gDunkMidget) then
        PedDelete(shared.gDunkMidget)
    end
    DATLoad("MGDunkTank.DAT", 2)
    DATInit()
    bClockPaused = ClockIsPaused()
    PauseGameClock()
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._DUNKTANKEXCLUDER, true)
    WeaponRequestModel(302)
    LoadActionTree("Act/Conv/MGDunkTank.act")
    LoadActionTree("Act/Conv/Store.act")
    LoadActionTree("Act/Props/DunkBench.act")
    LoadAnimationGroup("GEN_Social")
    LoadAnimationGroup("MINIDunk")
    MinigameCreate("DUNKTANK", false)
    SoundLoadBank("MINIGAME\\DnkTnk.bnk")
    SoundDisableSpeech_ActionTree()
end

function MissionCleanup()
    MinigameDestroy()
    CameraClearRotationLimit()
    CameraSetActive(13)
    CameraReturnToPlayer()
    CameraReset()
    ToggleHudComponents(true)
    PAnimDelete(TRIGGER._DUNKBTTN)
    PAnimDelete(TRIGGER._DUNKSEAT)
    PedDontCleanup(gCarnie)
    PedMakeAmbient(gCarnie)
    UnLoadAnimationGroup("GEN_Social")
    UnLoadAnimationGroup("MINIDunk")
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._DUNKTANKEXCLUDER, false)
    Wait(1000)
    PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
    PedIgnoreStimuli(gPlayer, false)
    PedIgnoreAttacks(gPlayer, false)
    SoundUnLoadBank("MINIGAME\\DnkTnk.bnk")
    PedSetActionNode(gCarnie, "/Global/Ambient/DunkTankMidget/TreadWater", "Act/Anim/Ambient.act")
    PlayerWeaponHudLock(false)
    PedDestroyWeapon(gPlayer, 302)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    DATUnload(2)
    shared.minigameRunning = nil
    --print(">>>[RUI]", "--MissionCleanup")
    SoundFadeoutStream(0)
    if bPlayerEnteredWithBear then
        PedSetWeapon(gPlayer, 363, 1)
        --print("()xxxxx[:::::::::::::::> [mgshootinggallery.lua] Restoring teddy bear.")
        bPlayerEnteredWithBear = false
    end
    SoundEnableSpeech_ActionTree()
    collectgarbage()
end

function CarnieCreate(point)
    local carnie
    if not PedIsValid(shared.gDunkMidget) then
        carnie = PedCreatePoint(115, point)
        PedSetInvulnerable(carnie, true)
        PedSetEffectedByGravity(carnie, false)
        PedSetActionNode(carnie, "/Global/DunkTank/Carny/TauntLoop", "Act/Conv/MGDunkTank.act")
    else
        carnie = shared.gDunkMidget
        PedMakeMissionChar(shared.gDunkMidget)
    end
    return carnie
end

function MissionInit()
    PedSetWeaponNow(gPlayer, -1, 0)
    PlayerWeaponHudLock(true)
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
    LoadModels({ 115, 495 })
    PlayerUnequip()
    Wait(100)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    PedSetActionTree(gPlayer, "/Global/MG_DunkTank", "Act/Anim/MG_DunkTank.act")
    while MinigameIsReady() == false do
        Wait(0)
    end
    ToggleHudComponents(false)
    AreaTransitionPoint(0, POINTLIST._MGDUNK_PLAYERSTART)
    PedSetActionNode(gPlayer, "/Global/Welcome/Idle", "Act/Conv/Store.act")
    PedIgnoreStimuli(gPlayer, true)
    PedIgnoreAttacks(gPlayer, true)
    F_LoadProps()
    gCarnie = CarnieCreate(POINTLIST._MGDUNK_CARNIE)
    Wait(1000)
    CameraSetXYZ(151.55801, 432.1491, 8.194367, 152.30055, 431.48544, 8.104391)
    CameraFade(500, 1)
    Wait(500)
    --print(">>>[RUI]", "MiniGameIsReady")
    shared.minigameRunning = "DunkTank"
    if shared.g2_G2 then
        shared.MGaction = 0
    end
    LoadModels({ 302 })
    --print(">>>[RUI]", "!!MissionInit")
end

function DunkTankRun()
    --print(">>>[RUI]", "++DunkTankRun")
    local bShotGood = false
    local tx, ty, hitTimer
    gCurrentBallCount = CarnivalDunkTankGetCount()
    while 0 < gCurrentBallCount do
        --print(">>>[RUI]", "throw loop " .. tostring(gCurrentBallCount))
        CreateThread("T_HandleTutorial")
        MinigameEnableHUD(true)
        PlayerSetControl(1)
        CarnivalDunkTankStartAiming()
        while not MinigameIsSuccess() do
            if not MinigameIsActive() then
                bPlayerExitHandle = true
                break
            end
            Wait(0)
        end
        MinigameEnableHUD(false)
        if bPlayerExitHandle then
            return false
        end
        Wait(150)
        PlayerSetControl(0)
        --print(">>>[RUI]", "--Ballcount")
        CarnivalDunkTankDecCount()
        gCurrentBallCount = CarnivalDunkTankGetCount()
        --print(">>>[RUI]", "DunkTankRun throw time")
        tx, ty = CarnivalDunkTankGetTargetPos()
        PedStop(gPlayer)
        PedAttackPropOffset(gPlayer, TRIGGER._DUNKBTTN, tx, ty)
        --print(">>>[RUI]", "!!PedAttackPropOffset  tx, ty: " .. tostring(tx) .. ", " .. tostring(ty))
        while not bBallThrown do
            Wait(0)
        end
        --print(">>>[RUI]", "--WAIT Ball Thrown")
        PedStop(gPlayer)
        hitTimer = GetTimer()
        bShotGood = false
        while GetTimer() - hitTimer < 3000 do
            if bDunkButtonHit then
                bShotGood = true
                break
            end
            Wait(0)
            if ObjectTypeIsInTrigger(302, TRIGGER._DUNKBACKBOARD) or ObjectTypeIsInTrigger(302, TRIGGER._DUNKTANK) then
                --print(">>>[RUI]", "BackBoardHit")
                Wait(1000)
                if not bDunkButtonHit then
                    --print(">>>[RUI]", "Hit BackBoard button not hit")
                    bShotGood = false
                    break
                end
            end
            Wait(0)
        end
        bBallThrown = false
        Wait(100)
        --print(">>>[RUI]", "timerDone")
        if bShotGood then
            if shared.g2_G2 then
                shared.MGaction = PINKY_CHEER
            end
            --print(">>>[RUI]", "bShotGood == true")
            break
        else
            if shared.g2_G2 then
                shared.MGaction = PINKY_BOO
            end
            SoundStopCurrentSpeechEvent(gCarnie)
            PedSetActionNode(gCarnie, "/Global/DunkTank/Carny/TauntLoop/Taunts/Taunt_A", "Act/Conv/MGDunkTank.act")
            Wait(500)
            --print(">>>[RUI]", "bShotGood == false")
        end
        Wait(10)
    end
    --print(">>>[RUI]", "--DunkTankRun")
    return bShotGood
end

function CounterSetup(bOn, maxC)
    if bOn then
        CarnivalDunkTankSetCount(maxC)
        MinigameEnableHUD(true)
    else
        CounterMakeHUDVisible(false)
    end
end

function DunkTankTallyTickets(score)
    --print(">>>[RUI]", "!!DunkTankTallyTickets score:" .. tostring(score))
    local tickets = 3
    return tickets * gTicketMultiplier
end

function F_DunkButtonHit()
    --print(">>>[RUI]", "!!F_DunkButtonHit")
    bDunkButtonHit = true
end

function DunkTankDoWin()
    PAnimSetActionNode(TRIGGER._DUNKSEAT, "/Global/DunkBench/Collapsing", "Act/Props/DunkBench.act")
    local a = GetAnchorPosition(TRIGGER._DUNKSEAT)
    Wait(300)
    PedSetActionNode(gCarnie, "/Global/DunkTank/Carny/Fall", "Act/Conv/MGDunkTank.act")
    CameraSetXYZ(155.65022, 432.3259, 7.174262, 155.87215, 431.36752, 7.353779)
    Wait(200)
    if shared.g2_G2 then
        shared.MGaction = PINKY_CHEER
    end
    Wait(1000)
    --print(">>>[RUI]", "MAIN carnie dunked")
    WaitSkippable(3000)
end

function cbBallThrown()
    --print(">>>[RUI]", "cbBallThrown")
    bBallThrown = true
end

function main()
    MissionInit()
    F_DisplayCountdown()
    if not bQuitGame then
        MinigameStart()
        CounterSetup(true, MAX_BALLCOUNT)
        bMissionPassed = DunkTankRun()
        if bMissionPassed then
            --print(">>>[RUI]", "MAIN PASSED")
            gTicketsWon = DunkTankTallyTickets(gCurrentBallCount)
            GiveItemToPlayer(495, gTicketsWon)
            DunkTankDoWin()
            Wait(3000)
            MissionSucceed(true, true, false)
        else
            --print(">>>[RUI]", "MAIN  FAIL")
            PedSetActionNode(gCarnie, "/Global/DunkTank/Carny/Taunt_Lose", "Act/Conv/MGDunkTank.act")
            Wait(3000)
            MissionFail(true, false)
        end
    else
        MissionFail(true, false)
    end
end

function ToggleHudComponents(bShow)
    bShow = bShow or false
    --print(">>>[RUI]", "!!ToggleHudComponents " .. tostring(bShow))
    ToggleHUDComponentVisibility(11, bShow)
    ToggleHUDComponentVisibility(4, bShow)
    ToggleHUDComponentVisibility(0, bShow)
end
