local gMissionTime = 60
local gMissionTimeLimit = 60000
local bRunTutorial = GetMissionCurrentAttemptCount() <= 2
local TARGET_BOTTLE = 0
local TARGET_ROBBER = 1
local TARGET_BONUS = 2
local TARGET_GIRL = 3
local PINKY_CHEER = 1
local PINKY_BOO = 2
local gCost = -200
local bQuitGame = false
local gHitScore = 0
local gChances = {
    {
        bottle = 80,
        robber = 0,
        cowgirl = 20
    },
    {
        bottle = 0,
        robber = 80,
        cowgirl = 20
    },
    {
        bottle = 0,
        robber = 90,
        cowgirl = 10
    }
}
local gPathSpeeds = {
    { sMin = 0.85, sMax = 1 },
    { sMin = 2.2,  sMax = 2.2 },
    { sMin = 3.5,  sMax = 4.2 }
}
local bonusSpeed = 3.75
local gScore = {
    bottle = 5,
    cowgirl = -10,
    robber = 10,
    bonus = 50
}
local gPathBonus = {
    0,
    0,
    5
}
local gNoOfProps = 8
local gPropSpawnWaitTime = 500
local gSecondaryTimer = 3000
local gTertiaryTimer = 9000
local gBonusSpawned = false
local gBonusHit = false
local gPathOneProps = {}
local gPathTwoProps = {}
local gPathThreeProps = {}
local gTotalScore = 0
local gTargetScore = 30
local gTicketCount = 0
local mission_accepted = true
local gOne, gTwo, gThree = false, false, false
local game_running = true
local gBonusTrigger = -1
local gPrimaryPaths = {}
local gSecondaryPaths = {}
local gTertiaryPaths = {}
local bClockPaused = false
local bPlayerEnteredWithBear = false

function F_LoadTriggers()
    gBottles = {
        TRIGGER._MGS_BOTTLE01,
        TRIGGER._MGS_BOTTLE02,
        TRIGGER._MGS_BOTTLE03,
        TRIGGER._MGS_BOTTLE04,
        TRIGGER._MGS_BOTTLE05,
        TRIGGER._MGS_BOTTLE06,
        TRIGGER._MGS_BOTTLE07,
        TRIGGER._MGS_BOTTLE08
    }
    gCowboys = {
        TRIGGER._MGS_COWBOY01,
        TRIGGER._MGS_COWBOY02,
        TRIGGER._MGS_COWBOY03,
        TRIGGER._MGS_COWBOY04
    }
    gRobbers = {
        TRIGGER._MGS_ROBBER01,
        TRIGGER._MGS_ROBBER02,
        TRIGGER._MGS_ROBBER03,
        TRIGGER._MGS_ROBBER04
    }
    for i, anim in gBottles do
        PAnimCreate(anim)
        PAnimMakeTargetable(anim, false)
        PAnimMakeVisuallyTargetable(anim, true)
        PAnimOverrideDamage(anim, 1)
    end
    for i, anim in gCowboys do
        PAnimCreate(anim)
        PAnimMakeTargetable(anim, false)
        PAnimMakeVisuallyTargetable(anim, true)
        PAnimOverrideDamage(anim, 1)
    end
    for i, anim in gRobbers do
        PAnimCreate(anim)
        PAnimMakeTargetable(anim, false)
        PAnimMakeVisuallyTargetable(anim, true)
        PAnimOverrideDamage(anim, 1)
    end
    gBonusTrigger = TRIGGER._MGS_BONUS01
    PAnimCreate(gBonusTrigger)
    PAnimMakeTargetable(gBonusTrigger, false)
    PAnimMakeVisuallyTargetable(gBonusTrigger, true)
    PAnimOverrideDamage(gBonusTrigger, 1)
    gPrimaryPaths = {
        PATH._MGS_PATH01,
        PATH._MGS_PATH02,
        PATH._MGS_PATH03,
        PATH._MGS_PATH04,
        PATH._MGS_PATH05,
        PATH._MGS_PATH06,
        PATH._MGS_PATH07,
        PATH._MGS_PATH08,
        PATH._MGS_PATH09
    }
    gSecondaryPaths = {
        PATH._MGS_SECONDARY01,
        PATH._MGS_SECONDARY02,
        PATH._MGS_SECONDARY03
    }
    gTertiaryPaths = {
        PATH._MGS_TERTIARY01,
        PATH._MGS_TERTIARY02
    }
    --print(">>>[RUI]", "++F_LoadTriggers")
end

function F_UnloadTriggers()
    for i, anim in gBottles do
        PAnimDelete(anim)
    end
    for i, anim in gCowboys do
        PAnimDelete(anim)
    end
    for i, anim in gRobbers do
        PAnimDelete(anim)
    end
    --print(">>>[RUI]", "--F_UnloadTriggers")
end

function F_EvaluateHit(targetType, path, trigger)
    gHitScore = 0
    if targetType == TARGET_BOTTLE then
        --print(">>>[RUI]", "F_EvaluateHit  hit Bottle")
        SoundPlay2D("BottleBreak")
        gHitScore = gScore.bottle
        StatAddToInt(238)
        if shared.g2_G2 then
            shared.MGaction = PINKY_CHEER
        end
    elseif targetType == TARGET_ROBBER then
        --print(">>>[RUI]", "F_EvaluateHit  hit Robber")
        SoundPlay2D("TargetHit")
        gHitScore = gScore.robber + gPathBonus[path]
        if shared.g2_G2 then
            shared.MGaction = PINKY_CHEER
        end
    elseif targetType == TARGET_GIRL then
        --print(">>>[RUI]", "F_EvaluateHit  hit cowgirl")
        SoundPlay2D("TargetHit")
        gHitScore = gScore.cowgirl
        if shared.g2_G2 then
            shared.MGaction = PINKY_BOO
        end
    elseif targetType == TARGET_BONUS then
        --print(">>>[RUI]", "F_EvaluateHit  hit bonus")
        SoundPlay2D("SpecialHit")
        gBonusHit = true
        gHitScore = gScore.bonus
        DoBonusEffects()
        if shared.g2_G2 then
            shared.MGaction = PINKY_CHEER
        end
    end
    gTotalScore = gTotalScore + gHitScore
    if gTotalScore < 0 then
        gTotalScore = 0
    end
    ScoreUpdateDisplay(gTotalScore)
    sx, sy, sz = PAnimGetPosition(trigger)
    EffectCreate("SGTargetHit", sx, sy, sz + 0.6)
    CarnivalShootAddNumber(gHitScore, sx, sy, sz + 0.6)
    --print(">>>[RUI]", "--F_EvaluateHit")
end

function DoBonusEffects()
    SoundPlay2D("TargetBonus")
    local xf, yf, zf
    xf, yf, zf = GetPointList(POINTLIST._MGS_EFFECT1)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._MGS_EFFECT2)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._MGS_EFFECT3)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._MGS_EFFECT4)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._MGS_EFFECT5)
    EffectCreate("Confetti", xf, yf, zf)
    --print(">>>[RUI]", "++DoBonusEffects")
end

function ScoreUpdateDisplay(score)
    CounterSetCurrent(score)
end

function F_CheckTriggers()
    for i, tOne in gPathOneProps do
        if PAnimIsDestroyed(tOne.id) and tOne.alive then
            F_EvaluateHit(tOne.targetType, 1, tOne.id)
            tOne.alive = false
        end
    end
    for i, tTwo in gPathTwoProps do
        if PAnimIsDestroyed(tTwo.id) and tTwo.alive then
            F_EvaluateHit(tTwo.targetType, 2, tTwo.id)
            tTwo.alive = false
        end
    end
    for i, tThree in gPathThreeProps do
        if PAnimIsDestroyed(tThree.id) and tThree.alive then
            F_EvaluateHit(tThree.targetType, 3, tThree.id)
            tThree.alive = false
        end
    end
end

function TableSize(tbl)
    local size = 0
    if tbl then
        for _, e in tbl do
            if e then
                size = size + 1
            end
        end
    end
    return size
end

function F_GetRandomPath(pathType)
    local pathId = -1
    local randNo = 0
    if pathType == 1 then
        --print(">>>[RUI]", "!!F_GetRandomPath pathtype 1 " .. TableSize(gPrimaryPaths))
        if gPrimaryPaths and 0 < TableSize(gPrimaryPaths) then
            randNo = math.random(1, TableSize(gPrimaryPaths))
            pathId = gPrimaryPaths[randNo]
            table.remove(gPrimaryPaths, randNo)
        end
    elseif pathType == 2 then
        --print(">>>[RUI]", "!!F_GetRandomPath pathtype 2 " .. TableSize(gSecondaryPaths))
        if gSecondaryPaths and 0 < TableSize(gSecondaryPaths) then
            randNo = math.random(1, TableSize(gSecondaryPaths))
            pathId = gSecondaryPaths[randNo]
            table.remove(gSecondaryPaths, randNo)
        end
    elseif pathType == 3 then
        --print(">>>[RUI]", "!!F_GetRandomPath pathtype 3 " .. TableSize(gTertiaryPaths))
        if gTertiaryPaths and 0 < TableSize(gTertiaryPaths) then
            randNo = math.random(1, TableSize(gTertiaryPaths))
            pathId = gTertiaryPaths[randNo]
            table.remove(gTertiaryPaths, randNo)
        end
    end
    --print(">>>[RUI]", "!!F_GetRandomPath  path:" .. tostring(pathId))
    return pathId
end

function F_FollowPath(path)
    local propid = -1
    local trigger = -1
    local pType = -1
    local pathId = -1
    if not game_running then
        return false
    end
    local attempts = 0
    if path == 1 then
        --print(">>>[RUI]", "!!F_FollowPath path 1")
        trigger, pType, pathId = F_CreateProp(1)
        if trigger ~= -1111 then
            while trigger < 0 do
                trigger, pType, pathId = F_CreateProp(1)
                attempts = attempts + 1
                if 5 < attempts then
                    --print(">>>[RUI]", "!!Attempted path 1 more than 5 times")
                    return false
                end
            end
            Wait(10)
            table.insert(gPathOneProps, {
                id = trigger,
                targetType = pType,
                alive = true,
                pPath = pathId,
                pathType = path
            })
            PAnimFollowPath(trigger, pathId, false, CbRowOne)
            PAnimSetPathFollowSpeed(trigger, gPathSpeeds[1].sMin)
        end
    elseif path == 2 then
        --print(">>>[RUI]", "!!F_FollowPath path 2")
        trigger, pType, pathId = F_CreateProp(2)
        if trigger ~= -1111 then
            while trigger < 0 do
                trigger, pType, pathId = F_CreateProp(2)
                attempts = attempts + 1
                if 5 < attempts then
                    --print(">>>[RUI]", "!!Attempted path 2 more than 5 times")
                    return false
                end
            end
            Wait(10)
            table.insert(gPathTwoProps, {
                id = trigger,
                targetType = pType,
                alive = true,
                pPath = pathId,
                pathType = path
            })
            PAnimFollowPath(trigger, pathId, false, CbRowTwo)
            PAnimSetPathFollowSpeed(trigger, gPathSpeeds[2].sMin)
        end
    elseif path == 3 then
        --print(">>>[RUI]", "!!F_FollowPath path 3")
        trigger, pType, pathId = F_CreateProp(3)
        if trigger ~= -1111 then
            while trigger < 0 do
                trigger, pType, pathId = F_CreateProp(3)
                attempts = attempts + 1
                if 5 < attempts then
                    --print(">>>[RUI]", "!!Attempted path 3 more than 5 times")
                    return false
                end
            end
            Wait(10)
            table.insert(gPathThreeProps, {
                id = trigger,
                targetType = pType,
                alive = true,
                pPath = pathId,
                pathType = path
            })
            PAnimFollowPath(trigger, pathId, false, CbRowThree)
            if pType == TARGET_BONUS then
                speed = bonusSpeed
            else
                speed = gPathSpeeds[3].sMin
            end
            PAnimSetPathFollowSpeed(trigger, speed)
        end
    end
    return true
end

function BonusCanCreate()
    if gStartTime then
        if GetTimer() - gStartTime > gMissionTimeLimit * 0.8 then
            return not gBonusSpawned
        elseif GetTimer() - gStartTime > gMissionTimeLimit * 0.7 then
            bonusRand = math.random(1, 100)
            return not gBonusSpawned and bonusRand > 20
        elseif GetTimer() - gStartTime > gMissionTimeLimit * 0.6 then
            bonusRand = math.random(1, 100)
            return not gBonusSpawned and bonusRand > 50
        elseif GetTimer() - gStartTime > 4000 then
            bonusRand = math.random(1, 100)
            return not gBonusSpawned and bonusRand > 95
        end
    else
        gStartTime = GetTimer()
        return false
    end
    return false
end

function F_CreateProp(pathNo)
    --print(">>>[RUI]", "++F_CreateProp pathNo: " .. tostring(pathNo))
    local propid = -1
    local trigger = -1
    local pType = TARGET_ROBBER
    local randNo = math.random(1, 100)
    local pBottle = gChances[pathNo].bottle
    local pRobber = gChances[pathNo].robber + pBottle
    local pGirl = gChances[pathNo].cowgirl + pRobber
    local pathId = F_GetRandomPath(pathNo)
    if pathId ~= -1 then
        if BonusCanCreate() and pathNo ~= 3 then
            bBonusReady = true
            gBonusSpawned = true
        end
        if pathNo == 3 and bBonusReady then
            pType = TARGET_BONUS
            bBonusReady = false
        elseif randNo <= pBottle then
            --print(">>>[RUI]", "!!F_CreateProp  Bottle Next, rand: " .. tostring(randNo))
            pType = TARGET_BOTTLE
        elseif randNo <= pRobber then
            pType = TARGET_ROBBER
            --print(">>>[RUI]", "!!F_CreateProp  Robber Next, rand: " .. tostring(randNo))
        elseif randNo <= pGirl then
            --print(">>>[RUI]", "!!F_CreateProp  Girl Next, rand: " .. tostring(randNo))
            pType = TARGET_GIRL
        end
        if pType == TARGET_BOTTLE then
            if TableSize(gBottles) > 0 then
                trigger = gBottles[1]
                table.remove(gBottles, 1)
            end
        elseif pType == TARGET_GIRL then
            if 0 < TableSize(gCowboys) then
                trigger = gCowboys[1]
                table.remove(gCowboys, 1)
            end
        elseif pType == TARGET_ROBBER then
            if 0 < TableSize(gRobbers) then
                trigger = gRobbers[1]
                table.remove(gRobbers, 1)
            end
        elseif pType == TARGET_BONUS then
            trigger = gBonusTrigger
        end
        --print(">>>[RUI]", "!!F_CreateProp  trigger: " .. tostring(trigger) .. " pType " .. tostring(pType) .. " pathId " .. tostring(pathId))
        return trigger, pType, pathId
    else
        --print(">>>[RUI]", "!!F_CreateProp  pathId ~= -1")
        return -1111
    end
end

function CbRowOne(propId, pathId, pathNode)
    if pathNode == 2 then
        F_EliminateProp(propId, 1)
        --print(">>>[RUI]", "!!CbRowOne")
        gOne = true
    end
end

function CbRowTwo(propId, pathId, pathNode)
    if pathNode == 3 then
        F_EliminateProp(propId, 2)
        --print(">>>[RUI]", "!!CbRowTwo")
        gTwo = true
    end
end

function CbRowThree(propId, pathId, pathNode)
    if pathNode == 3 then
        F_EliminateProp(propId, 3)
        --print(">>>[RUI]", "!!CbRowThree")
        gThree = true
    end
end

function CbTutPath(propId, pathId, pathNode)
    if pathNode == 1 then
        if not gTutTemp then
            gTutTemp = true
        else
            gReachedSecond = true
        end
        --print(">>>[RUI]", "!!CbTutPath  pathnode == 1")
    elseif pathNode == 3 then
        PAnimDelete(propId)
        --print(">>>[RUI]", "!!CbTutPath  pathnode == 3")
    end
end

function F_EliminateProp(triggerId, pathNo)
    local pType = "U"
    local pId = -1
    local pPath = -1
    local pathType = -1
    if pathNo == 1 then
        pType = gPathOneProps[1].targetType
        pId = gPathOneProps[1].id
        pPath = gPathOneProps[1].pPath
        pathType = gPathOneProps[1].pathType
        table.remove(gPathOneProps, 1)
        --print(">>>[RUI]", "F_EliminateProp  pathNo == 1 pathType = " .. pathType)
    elseif pathNo == 2 then
        pType = gPathTwoProps[1].targetType
        pId = gPathTwoProps[1].id
        pPath = gPathTwoProps[1].pPath
        pathType = gPathTwoProps[1].pathType
        table.remove(gPathTwoProps, 1)
        --print(">>>[RUI]", "F_EliminateProp  pathNo == 2 pathType = " .. pathType)
    elseif pathNo == 3 then
        pType = gPathThreeProps[1].targetType
        pId = gPathThreeProps[1].id
        pPath = gPathThreeProps[1].pPath
        pathType = gPathThreeProps[1].pathType
        table.remove(gPathThreeProps, 1)
        --print(">>>[RUI]", "F_EliminateProp  pathNo == 3 pathType = " .. pathType)
    end
    if pType == TARGET_BOTTLE then
        table.insert(gBottles, triggerId)
    elseif pType == TARGET_GIRL then
        table.insert(gCowboys, triggerId)
    elseif pType == TARGET_ROBBER then
        table.insert(gRobbers, triggerId)
    end
    if pathType == 1 then
        --print(">>>[RUI]", "F_EliminateProp  INSERTING TO PRIMARY PATHS")
        table.insert(gPrimaryPaths, pPath)
    elseif pathType == 2 then
        --print(">>>[RUI]", "F_EliminateProp  INSERTING TO SECONDARY PATHS")
        table.insert(gSecondaryPaths, pPath)
    elseif pathType == 3 then
        --print(">>>[RUI]", "F_EliminateProp  INSERTING TO TERTIARY PATHS")
        table.insert(gTertiaryPaths, pPath)
    end
    gCurrentNoOfProps = gCurrentNoOfProps - 1
    PAnimStopFollowPath(triggerId)
    PAnimReset(triggerId)
    --print(">>>[RUI]", "--F_EliminateProp")
end

function F_FailMission()
    mission_accepted = false
end

function MissionSetup()
    MissionDontFadeIn()
    MinigameCreate("SHOOT", false)
    DATLoad("MGShooting.DAT", 2)
    DATInit()
    bClockPaused = ClockIsPaused()
    PauseGameClock()
    AreaDisableCameraControlForTransition(true)
    F_MakePlayerSafeForNIS(true)
    SoundFadeoutStream(0)
    SoundPlayStream("MS_CarnivalFunhouseAmbient.rsm", 0.6)
    PedDestroyWeapon(gPlayer, 391)
    PlayerSetPosPoint(POINTLIST._MGS_PLAYERENTER)
    EnableHudComponents()
    math.randomseed(GetTimer())
end

function MissionCleanup()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    MinigameDestroy()
    SoundLoopPlay2D("GunTargetTrack", false)
    if F_PedExists(gCarny) then
        PedIgnoreStimuli(gCarny, false)
        PedMakeAmbient(gCarny)
    end
    F_UnloadTriggers()
    collectgarbage()
    CameraAllowChange(true)
    CameraSetShot(2, 0)
    CameraReturnToPlayer()
    CameraClearRotationLimit()
    CameraDefaultFOV()
    PlayerWeaponHudLock(false)
    PedDestroyWeapon(gPlayer, 391)
    CameraSetActive(1)
    EnableHudComponents(true)
    CounterSetup(false)
    PlayerSetControl(1)
    DATUnload(2)
    SoundFadeoutStream(0)
    shared.minigameRunning = nil
    F_MakePlayerSafeForNIS(false)
    if bPlayerEnteredWithBear then
        PedSetWeapon(gPlayer, 363, 1)
        --print("()xxxxx[:::::::::::::::> [mgshootinggallery.lua] Restoring teddy bear.")
        bPlayerEnteredWithBear = false
    end
    MissionDontFadeInAfterCompetion()
    --print(">>>[RUI]", "--MissionCleanup")
end

function MissionInit()
    shared.minigameRunning = "ShootingGallery"
    PedSetWeaponNow(gPlayer, -1, 0)
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
    LoadWeaponModels({ 391 })
    LoadModels({ 143, 495 })
    Wait(100)
    while MinigameIsReady() == false do
        Wait(0)
    end
    --print(">>>[RUI]", "MinigameIsReady")
    PlayerSetControl(0)
    PlayerWeaponHudLock(true)
    gCarny = PedCreatePoint(143, POINTLIST._MGS_CLERK, 1)
    PedIgnoreStimuli(gCarny, true)
    PedIgnoreAttacks(gCarny, true)
    Wait(100)
    PedFaceHeading(gCarny, 270, 0)
    PedFaceObject(gCarny, gPlayer, 3, 0)
    PedMakeTargetable(gCarny, false)
    if shared.g2_G2 then
        shared.MGaction = 0
    end
    F_LoadTriggers()
    Wait(1000)
    --print(">>>[RUI]", "MissionInit")
    CameraSetXYZ(-792.7507, 75.741035, 11.883444, -792.30035, 68.92447, 10.46345)
    CameraLookAtXYZ(-792.30035, 68.92447, 10.46345, true)
    AreaDisableCameraControlForTransition(false)
    CameraAllowChange(true)
    CameraSetActive(2)
    CameraSetRotationLimit(10, 40, 0, -1, 0)
    CameraSetShot(2, "ShootingGallery", true)
    CameraAllowChange(false)
    Wait(100)
    CameraFade(500, 1)
    Wait(501)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    math.randomseed(GetTimer())
    --print(">>>[RUI]", "!!MissionInit")
end

function main()
    MissionInit()
    F_DisplayCountdown()
    if not bQuitGame then
        PedStop(gPlayer)
        MissionTimerStart(gMissionTime)
        gCurrentNoOfProps = 0
        Wait(100)
        cTertiaryTimer = GetTimer()
        cSecondaryTimer = GetTimer()
        gClerkHit = true
        gClerkHitTimes = 0
        CreateThread("F_CheckTriggersThread")
        ScoreUpdateDisplay(gTotalScore)
        PedFaceObject(gCarny, gPlayer, 3, 0)
        PlayerSetControl(1)
        CounterSetup(true)
        F_HandleTutorial()
        SoundLoopPlay2D("GunTargetTrack", true)
        MinigameStart()
        while game_running do
            if not PlayerHasWeapon(391) then
                game_running = false
                bSwitchedWeapon = true
                --print(">>>[RUI]", "FAIL changed weapon")
                break
            end
            if MissionTimerHasFinished() then
                game_running = false
                TextPrint("TIMER_D", 3, 1)
                Wait(1000)
                break
            end
            ShootingGalleryRunTargets()
            Wait(0)
        end
        SoundLoopPlay2D("GunTargetTrack", false)
        TextClear()
        MinigameEnd()
        PlayerSetControl(0)
        MissionTimerStop()
        Wait(3000)
        PlayerWeaponHudLock(false)
        Wait(100)
        PedDestroyWeapon(gPlayer, 391)
        if ShootingGalleryGameWon(gTotalScore) then
            SoundPlay2D("GunWin")
            gTicketCount = ShootingGalleryTallyTickets(gTotalScore)
            GiveItemToPlayer(495, gTicketCount)
            if 2 <= gTicketCount then
                SoundPlayAmbientSpeechEvent(gCarny, "CARNIE_GAME_EXIT_WIN")
            end
            Wait(3000)
            CameraFade(500, 0)
            Wait(501)
            AreaDisableCameraControlForTransition(true)
            PlayerSetPosPoint(POINTLIST._MGS_PLAYEREXIT)
            AreaDisableCameraControlForTransition(false)
            MissionSucceed(true, true, false)
        else
            SoundPlayAmbientSpeechEvent(gCarny, "CARNIE_GAME_EXIT_LOSE")
            Wait(3000)
            CameraFade(500, 0)
            Wait(501)
            AreaDisableCameraControlForTransition(true)
            PlayerSetPosPoint(POINTLIST._MGS_PLAYEREXIT)
            AreaDisableCameraControlForTransition(false)
            MissionFail(true, false)
        end
    else
        CameraFade(500, 0)
        Wait(501)
        AreaDisableCameraControlForTransition(true)
        PlayerSetPosPoint(POINTLIST._MGS_PLAYEREXIT)
        AreaDisableCameraControlForTransition(false)
        MissionFail(true, false)
    end
end

function CounterSetup(bOn)
    if bOn then
        CounterSetMax(0)
        CounterSetCurrent(0)
        CounterSetText("MGSG_31")
        CounterMakeHUDVisible(true, true)
    else
        CounterSetMax(0)
        CounterSetCurrent(0)
        CounterClearText()
        CounterClearIcon()
        CounterMakeHUDVisible(false)
    end
end

function ShootingGalleryGameWon(score)
    if gClerkHitTimes >= 3 then
        return false
    elseif score < gTargetScore then
        return false
    elseif bSwitchedWeapon then
        return false
    else
        return true
    end
end

function TimerPassed(time)
    if time < GetTimer() then
        return true
    else
        return false
    end
end

function ShootingGalleryRunTargets()
    local cTimer = 0
    for i = 1, gNoOfProps do
        if not game_running then
            break
        end
        if gPropSpawnTimer then
            if TimerPassed(gPropSpawnTimer) and gCurrentNoOfProps < gNoOfProps then
                cTimer = GetTimer()
                if cTimer - cTertiaryTimer > gTertiaryTimer then
                    cTertiaryTimer = GetTimer()
                    if 0 < TableSize(gTertiaryPaths) then
                        --print(">>>[RUI]", "Trying to create something in path 3")
                        if F_FollowPath(3) then
                            --print(">>>[RUI]", "create something in path 3")
                            gCurrentNoOfProps = gCurrentNoOfProps + 1
                        end
                    end
                elseif cTimer - cSecondaryTimer > gSecondaryTimer then
                    cSecondaryTimer = GetTimer()
                    if 0 < TableSize(gSecondaryPaths) then
                        --print(">>>[RUI]", "Trying to create something in path 2")
                        if F_FollowPath(2) then
                            --print(">>>[RUI]", "create something in path 3")
                            gCurrentNoOfProps = gCurrentNoOfProps + 1
                        end
                    end
                elseif 0 < TableSize(gPrimaryPaths) then
                    --print(">>>[RUI]", "Trying to create something in path 1")
                    if F_FollowPath(1) then
                        --print(">>>[RUI]", "create something in path 1")
                        gCurrentNoOfProps = gCurrentNoOfProps + 1
                    end
                end
                gPropSpawnTimer = GetTimer() + gPropSpawnWaitTime
            end
        else
            gPropSpawnTimer = GetTimer() + gPropSpawnWaitTime
        end
    end
end

function ShootingGalleryTallyTickets(score)
    local tickets = 0
    if 100 <= score then
        tickets = 1
    end
    if 140 <= score then
        tickets = 2
    end
    if 180 <= score then
        tickets = 3
    end
    if 220 <= score then
        tickets = 4
    end
    if 260 <= score then
        tickets = 5
    end
    if 300 <= score then
        tickets = 10
    end
    if 310 <= score then
        tickets = 11
        local m = score - 310
        m = m - math.mod(m, 10)
        tickets = tickets + m / 10
    end
    --print(">>>[RUI]", "!!ShootingGalleryTallyTickets tickets: " .. tostring(tickets))
    return tickets * gTicketMultiplier
end

function T_LockedAndLoaded()
    PedFollowPath(gCarny, PATH._MGS_CLERKPATH, 0, 1, cbClerkDone)
    Wait(500)
    PlayerWeaponHudLock(false)
    PedSetWeaponNow(gPlayer, 391, 25, false)
    PlayerWeaponHudLock(true)
    Wait(500)
    SoundPlay2D("GunPump")
    collectgarbage()
end

function cbClerkDone(pedId, pathId, pathNode)
    if pedId == gCarny and pathNode == PathGetLastNode(pathId) then
        PedFaceObject(gCarny, gPlayer, 3, 0)
    end
end

function F_DisplayCountdown()
    SoundPlayAmbientSpeechEvent(gCarny, "CARNIE_GAME_SELL")
    while not IsButtonBeingPressed(7, 0) do
        TextPrint("MGSG_XSTART", 0.5, 1)
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
        CreateThread("T_LockedAndLoaded")
        TextPrint("MG_READY", 1, 1)
        Wait(1000)
        TextPrint("MG_SET", 1, 1)
        Wait(1000)
        TutorialRemoveMessage()
        TextPrint("MG_GO", 1, 1)
    end
end

function F_HandleTutorial()
    if bRunTutorial then
        TextPrint("MGSG_INST", gMissionTime, 3)
    end
end

function F_CheckTriggersThread()
    while game_running do
        F_CheckTriggers()
        if gClerkHit then
            if PedIsHit(gCarny, 2, 1000) then
                gClerkHit = false
                gClerkHitTimes = gClerkHitTimes + 1
                if gClerkHitTimes == 1 then
                    TextPrint("MGSG_40", 2, 2)
                elseif gClerkHitTimes == 2 then
                    TextPrint("MGSG_41", 2, 2)
                elseif gClerkHitTimes == 3 then
                    TextPrint("MGSG_42", 2, 2)
                    game_running = false
                end
                PedSetHealth(gCarny, 100)
                gClerkTimer = GetTimer()
            end
        elseif 1000 < GetTimer() - gClerkTimer then
            gClerkHit = true
        end
        Wait(0)
    end
end

function EnableHudComponents(bShow)
    bShow = bShow or false
    ToggleHUDComponentVisibility(20, bShow)
    ToggleHUDComponentVisibility(11, bShow)
    ToggleHUDComponentVisibility(4, bShow)
    ToggleHUDComponentVisibility(0, bShow)
end
