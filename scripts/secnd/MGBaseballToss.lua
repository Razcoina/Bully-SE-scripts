local bRunTutorial = GetMissionCurrentAttemptCount() <= 2
local gClerk
local TARGET_UMPIRE = 0
local TARGET_CATCHER = 1
local TARGET_BATTER = 2
local TARGET_BONUS = 3
local PINKY_CHEER = 1
local PINKY_BOO = 2
local gMissionTime = 60
local gCost = -100
local gStartTime
local bQuitGame = false
local gUmpires = {}
local gCatchers = {}
local gBatters = {}
local gChances = {
    {
        catcher = 25,
        batter = 60,
        umpire = 15
    },
    {
        catcher = 25,
        batter = 60,
        umpire = 15
    },
    {
        catcher = 25,
        batter = 60,
        umpire = 15
    }
}
local gPathSpeeds = {
    1.9,
    1.9,
    1.9
}
local gNoOfPropsPerPath = {
    6,
    6,
    6
}
local gPathOneProps = {}
local gPathTwoProps = {}
local gPathThreeProps = {}
local gBlinkTimer = 500
local aftershotTimer
local bHitTheBonusTarget = false
local gTickets = 0
local gStrikes = 0
local MAX_BALLCOUNT = 6
local gCurrentBallCount = MAX_BALLCOUNT
local bSucceed = false
local gPathHit = {
    false,
    false,
    false
}
local gLights = {
    {
        id = "Scr_Ball01",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -795.354,
        y = 92.4354,
        z = 12.2319,
        hidden = false
    },
    {
        id = "Scr_Ball02",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -795.303,
        y = 92.4572,
        z = 12.2319,
        hidden = false
    },
    {
        id = "Scr_Ball03",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -795.256,
        y = 92.4776,
        z = 12.2319,
        hidden = false
    },
    {
        id = "Scr_Ball04",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -795.21,
        y = 92.4972,
        z = 12.2319,
        hidden = false
    },
    {
        id = "Scr_Strike01",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -794.93,
        y = 92.6176,
        z = 12.2319,
        hidden = false
    },
    {
        id = "Scr_Strike02",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -794.884,
        y = 92.6373,
        z = 12.2319,
        hidden = false
    },
    {
        id = "Scr_Strike03",
        status = 0,
        blinkTimes = 0,
        currentBlinkTime = 0,
        x = -794.838,
        y = 92.6574,
        z = 12.2319,
        hidden = false
    }
}
local mission_accepted = true
local gOne, gTwo, gThree = false, false, false
local gBallsThrown = 0
local gBallsHit = 0
local gGoodThrows = 0
local gStrikes = 0
local gBonusesHit = 0
local gUmpiresHit = 0
local game_running = true
local game_won = false
local gTimeToCruise = 6930
local gPathWaits = {
    gTimeToCruise / gPathSpeeds[1] / (gNoOfPropsPerPath[1] + 1),
    gTimeToCruise / gPathSpeeds[2] / (gNoOfPropsPerPath[2] + 1),
    gTimeToCruise / gPathSpeeds[3] / (gNoOfPropsPerPath[3] + 1)
}
local bPlayerEnteredWithBear = false
local bClockPaused = false

function F_ChargeForGame(price)
    gCost = price
    --print(">>>[RUI]", "F_ChargeForGame price: " .. tostring(price))
end

function F_PreLoadTriggers()
    --print(">>>[RUI]", "!!F_PreLoadTriggers")
    gUmpires = {
        TRIGGER._UMPIREONE,
        TRIGGER._UMPIRETWO,
        TRIGGER._UMPIRETHREE,
        TRIGGER._UMPIREFOUR,
        TRIGGER._UMPIREFIVE,
        TRIGGER._UMPIRESIX,
        TRIGGER._UMPIRESEVEN
    }
    LoadPAnims(gUmpires)
    gCatchers = {
        TRIGGER._CATCHERONE,
        TRIGGER._CATCHERTWO,
        TRIGGER._CATCHERTHREE,
        TRIGGER._CATCHERFOUR,
        TRIGGER._CATCHERFIVE,
        TRIGGER._CATCHERSIX,
        TRIGGER._CATCHERSEVEN
    }
    LoadPAnims(gCatchers)
    gBatters = {
        TRIGGER._BATTERONE,
        TRIGGER._BATTERTWO,
        TRIGGER._BATTERTHREE,
        TRIGGER._BATTERFOUR,
        TRIGGER._BATTERFIVE,
        TRIGGER._BATTERSIX,
        TRIGGER._BATTERSEVEN,
        TRIGGER._BATTEREIGHT,
        TRIGGER._BATTERNINE
    }
    LoadPAnims(gBatters)
    LoadPAnims({
        TRIGGER._BONUSTARGET
    })
end

function F_LoadTriggers()
    for i, anim in gUmpires do
        PAnimCreate(anim, true, false)
        PAnimMakeTargetable(anim, false)
        PAnimOverrideDamage(anim, 1)
    end
    for i, anim in gCatchers do
        PAnimCreate(anim, true, false)
        PAnimMakeTargetable(anim, false)
        PAnimOverrideDamage(anim, 1)
    end
    for i, anim in gBatters do
        PAnimCreate(anim, true, false)
        PAnimMakeTargetable(anim, false)
        PAnimOverrideDamage(anim, 1)
    end
    PAnimCreate(TRIGGER._BONUSTARGET, true, false)
    PAnimMakeTargetable(TRIGGER._BONUSTARGET, false)
end

function F_UnloadTriggers()
    for i, anim in gUmpires do
        PAnimDelete(anim)
    end
    for i, anim in gCatchers do
        PAnimDelete(anim)
    end
    for i, anim in gBatters do
        PAnimDelete(anim)
    end
end

function F_SetStatus(lightNo)
    gLights[lightNo].status = 1
    gLights[lightNo].currentBlinkTime = GetTimer()
    gLights[lightNo].hidden = false
    GeometryInstance(gLights[lightNo].id, gLights[lightNo].hidden, gLights[lightNo].x, gLights[lightNo].y, gLights[lightNo].z)
end

function F_EvaluateHit(propType)
    if propType == TARGET_BATTER then
        --print(">>>[RUI]", "!!F_EvaluateHit TARGET_BATTER")
        SoundPlay2D("BsBallHitTarget")
        SoundPlay2D("Bs_FailBoos")
        gBallsHit = gBallsHit + 1
        StatAddToInt(235)
        if 4 <= gBallsHit then
            SoundPlay2D("LoseBuzzer")
            game_running = false
            F_SetStatus(4)
            PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Ball4", "Act/Conv/MGBaseballToss.act")
        else
            if gBallsHit == 1 then
                F_SetStatus(1)
            elseif gBallsHit == 2 then
                F_SetStatus(2)
            elseif gBallsHit == 3 then
                F_SetStatus(3)
            end
            TextAddParamNum(gBallsHit)
            PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Ball", "Act/Conv/MGBaseballToss.act")
        end
        if shared.g2_G2 then
            shared.MGaction = PINKY_BOO
        end
    elseif propType == TARGET_CATCHER then
        SoundPlay2D("BsBallHitTarget")
        SoundPlay2D("Bs_SuccessCheer")
        --print(">>>[RUI]", "!!F_EvaluateHit TARGET_CATCHER")
        gStrikes = gStrikes + 1
        CounterIncrementCurrent(1)
        StatAddToInt(50)
        StatAddToInt(236)
        gGoodThrows = gGoodThrows + 1
        if 3 <= gStrikes then
            SoundPlay2D("BsWin")
            SoundPlay2D("Bs_SuccessCheer")
            F_SetStatus(7)
            PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/StrikeOut", "Act/Conv/MGBaseballToss.act")
            if 0 < gCurrentBallCount then
                CarnivalBallTossDecCount()
                gCurrentBallCount = CarnivalBallTossGetCount()
            end
            game_running = false
            game_won = true
        else
            if gStrikes == 1 then
                F_SetStatus(5)
            elseif gStrikes == 2 then
                F_SetStatus(6)
            end
            PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Strike", "Act/Conv/MGBaseballToss.act")
        end
        if shared.g2_G2 then
            shared.MGaction = PINKY_CHEER
        end
    elseif propType == TARGET_BONUS then
        --print(">>>[RUI]", "!!F_EvaluateHit TARGET_BONUS")
        SoundPlay2D("BsBallHitTarget")
        PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/BonusHit", "Act/Conv/MGBaseballToss.act")
        DoBonusEffect()
        gStrikes = gStrikes + 1
        CounterIncrementCurrent(1)
        StatAddToInt(50)
        StatAddToInt(236)
        StatAddToInt(233)
        gGoodThrows = gGoodThrows + 1
        gBonusesHit = gBonusesHit + 1
        if 3 <= gStrikes then
            SoundPlay2D("BsWin")
            SoundPlay2D("Bs_SuccessCheer")
            F_SetStatus(7)
            if 0 < gCurrentBallCount then
                CarnivalBallTossDecCount()
                gCurrentBallCount = CarnivalBallTossGetCount()
            end
            game_running = false
            game_won = true
        elseif gStrikes == 1 then
            F_SetStatus(5)
        elseif gStrikes == 2 then
            F_SetStatus(6)
        end
        TextPrint("MGBT_46", 4, 1)
        bHitTheBonusTarget = true
        if shared.g2_G2 then
            shared.MGaction = PINKY_CHEER
        end
    else
        --print(">>>[RUI]", "!!F_EvaluateHit TARGET_UMPIRE")
        SoundPlay2D("BsBallHitTarget")
        SoundPlay2D("LoseBuzzer")
        game_running = false
        PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Umpire", "Act/Conv/MGBaseballToss.act")
        if shared.g2_G2 then
            shared.MGaction = PINKY_BOO
        end
        StatAddToInt(234)
        gUmpiresHit = gUmpiresHit + 1
    end
end

function DoBonusEffect()
    local xf, yf, zf
    SoundPlay2D("BsBallBonus")
    xf, yf, zf = GetPointList(POINTLIST._BASEBALLTOSS_EFFECT1)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._BASEBALLTOSS_EFFECT2)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._BASEBALLTOSS_EFFECT3)
    EffectCreate("Confetti", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._BASEBALLTOSS_EFFECT4)
    EffectCreate("FireworksWinner", xf, yf, zf)
    xf, yf, zf = GetPointList(POINTLIST._BASEBALLTOSS_EFFECT5)
    EffectCreate("FireworksWinner", xf, yf, zf)
end

function F_CheckTriggers()
    for i, tOne in gPathOneProps do
        if PAnimIsDestroyed(tOne.id) and tOne.alive then
            if tOne.propType == TARGET_CATCHER then
                gPathHit[1] = true
                --print(">>>[RUI]", "Hit Catcher, deactivate path 1")
            end
            F_EvaluateHit(tOne.propType)
            tOne.alive = false
            return
        end
    end
    for i, tTwo in gPathTwoProps do
        if PAnimIsDestroyed(tTwo.id) and tTwo.alive then
            if tTwo.propType == TARGET_CATCHER then
                --print(">>>[RUI]", "Hit Catcher, deactivate path 2")
                gPathHit[2] = true
            end
            F_EvaluateHit(tTwo.propType)
            tTwo.alive = false
            return
        end
    end
    for i, tThree in gPathThreeProps do
        if PAnimIsDestroyed(tThree.id) and tThree.alive then
            if tThree.propType == TARGET_CATCHER then
                --print(">>>[RUI]", "Hit Catcher, deactivate path 3")
                gPathHit[3] = true
            end
            F_EvaluateHit(tThree.propType)
            tThree.alive = false
            return
        end
    end
end

function BonusCanCreate()
    if gStartTime then
        if GetTimer() - gStartTime > 4000 then
            bonusRand = math.random(1, 100)
            return not bBonusCreated and bonusRand > 95
        end
    else
        gStartTime = GetTimer()
        return false
    end
    return false
end

local bonusRand

function F_FollowPath(path)
    local propid = -1
    local trigger = -1
    local pType = -1
    if not gPathHit[path] then
        bonusRand = math.random(1, 100)
        if path == 1 then
            if BonusCanCreate() then
                trigger = TRIGGER._BONUSTARGET
                pType = TARGET_BONUS
                bBonusCreated = true
            else
                trigger, pType, propid = F_CreateProp(1)
                if trigger then
                    while trigger < 0 do
                        trigger, pType, propid = F_CreateProp(1)
                    end
                end
            end
            Wait(10)
            table.insert(gPathOneProps, {
                id = trigger,
                propType = pType,
                alive = true
            })
            PAnimFollowPath(trigger, PATH._BASEBALLTOSS_ROWONEPATH, false, CbRowOne)
            PAnimSetPathFollowSpeed(trigger, gPathSpeeds[1])
        elseif path == 2 then
            if BonusCanCreate() then
                trigger = TRIGGER._BONUSTARGET
                pType = TARGET_BONUS
                bBonusCreated = true
            else
                trigger, pType, propid = F_CreateProp(2)
                if trigger then
                    while trigger < 0 do
                        trigger, pType, propid = F_CreateProp(2)
                    end
                end
            end
            Wait(10)
            table.insert(gPathTwoProps, {
                id = trigger,
                propType = pType,
                alive = true
            })
            PAnimFollowPath(trigger, PATH._BASEBALLTOSS_ROWTWOPATH, false, CbRowTwo)
            PAnimSetPathFollowSpeed(trigger, gPathSpeeds[2])
        elseif path == 3 then
            if BonusCanCreate() then
                trigger = TRIGGER._BONUSTARGET
                pType = TARGET_BONUS
                bBonusCreated = true
            else
                trigger, pType, propid = F_CreateProp(3)
                if trigger then
                    while trigger < 0 do
                        trigger, pType, propid = F_CreateProp(3)
                    end
                end
            end
            Wait(10)
            if trigger then
                table.insert(gPathThreeProps, {
                    id = trigger,
                    propType = pType,
                    alive = true
                })
                PAnimFollowPath(trigger, PATH._BASEBALLTOSS_ROWTHREEPATH, false, CbRowThree)
                PAnimSetPathFollowSpeed(trigger, gPathSpeeds[3])
            end
        end
    end
end

function F_CreateProp(pathNo)
    local propid = -1
    local trigger = -1
    local randNo = math.random(1, 100)
    local pCatcher = gChances[pathNo].catcher
    local pBatter = gChances[pathNo].batter + pCatcher
    local pType = TARGET_UMPIRE
    if randNo < pCatcher then
        pType = TARGET_CATCHER
    elseif randNo < pBatter then
        pType = TARGET_BATTER
    end
    if pType == TARGET_BATTER then
        if gBatters then
            if table.getn(gBatters) > 0 then
                trigger = gBatters[1]
                table.remove(gBatters, 1)
            end
        else
            trigger = nil
        end
    elseif pType == TARGET_CATCHER then
        if gCatchers then
            if table.getn(gCatchers) > 0 then
                trigger = gCatchers[1]
                table.remove(gCatchers, 1)
            end
        else
            trigger = nil
        end
    elseif pType == TARGET_UMPIRE then
        if gUmpires then
            if table.getn(gUmpires) > 0 then
                trigger = gUmpires[1]
                table.remove(gUmpires, 1)
            end
        else
            gTrigger = nil
        end
    end
    return trigger, pType, propid
end

function CbRowOne(propId, pathId, pathNode)
    if pathNode == 1 then
        F_EliminateProp(propId, 1)
        gOne = true
    end
end

function CbRowTwo(propId, pathId, pathNode)
    if pathNode == 1 then
        F_EliminateProp(propId, 2)
        gTwo = true
    end
end

function CbRowThree(propId, pathId, pathNode)
    if pathNode == 1 then
        F_EliminateProp(propId, 3)
        gThree = true
    end
end

function F_DisablePath(path)
    local targetList
    --print(">>>[RUI]", "F_DisablePath path: " .. path)
    if path == 1 then
        targetList = gPathOneProps
    elseif path == 2 then
        targetList = gPathTwoProps
    elseif path == 3 then
        targetList = gPathThreeProps
    end
    if targetList then
        for _, prop in targetList do
            F_EliminateProp(prop.id, path)
        end
    end
end

function F_EliminateProp(triggerId, pathNo)
    local pType = TARGET_UMPIRE
    local pId = -1
    if pathNo == 1 then
        pType = gPathOneProps[1].propType
        pId = gPathOneProps[1].id
        table.remove(gPathOneProps, 1)
    elseif pathNo == 2 then
        pType = gPathTwoProps[1].propType
        pId = gPathTwoProps[1].id
        table.remove(gPathTwoProps, 1)
    elseif pathNo == 3 then
        pType = gPathThreeProps[1].propType
        pId = gPathThreeProps[1].id
        table.remove(gPathThreeProps, 1)
    end
    if pType == TARGET_BATTER then
        table.insert(gBatters, triggerId)
    elseif pType == TARGET_CATCHER then
        table.insert(gCatchers, triggerId)
    elseif pType == TARGET_UMPIRE then
        table.insert(gUmpires, triggerId)
    end
    if triggerId then
        PAnimReset(triggerId)
        PAnimStopFollowPath(triggerId)
    end
end

function F_ManageLights()
    for i, lightEntry in gLights do
        if lightEntry.status == 1 and GetTimer() - lightEntry.currentBlinkTime > gBlinkTimer then
            lightEntry.hidden = not lightEntry.hidden
            lightEntry.currentBlinkTime = GetTimer()
            lightEntry.blinkTimes = lightEntry.blinkTimes + 1
            GeometryInstance(lightEntry.id, lightEntry.hidden, lightEntry.x, lightEntry.y, lightEntry.z)
            if lightEntry.blinkTimes >= 4 then
                lightEntry.status = 2
            end
        end
    end
end

function MissionInit()
    PlayerSetControl(0)
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
    Wait(100)
    while MinigameIsReady() == false do
        Wait(0)
    end
    EnableHudComponents(false)
    PlayerFaceHeadingNow(0)
    shared.minigameRunning = "BaseballToss"
    if shared.g2_G2 then
        shared.MGaction = 0
    end
    GeometryInstance("Scr_Ball01", true, -795.354, 92.4354, 12.2319)
    GeometryInstance("Scr_Ball02", true, -795.303, 92.4572, 12.2319)
    GeometryInstance("Scr_Ball03", true, -795.256, 92.4776, 12.2319)
    GeometryInstance("Scr_Ball04", true, -795.21, 92.4972, 12.2319)
    GeometryInstance("Scr_Strike01", true, -794.93, 92.6176, 12.2319)
    GeometryInstance("Scr_Strike02", true, -794.884, 92.6373, 12.2319)
    GeometryInstance("Scr_Strike03", true, -794.838, 92.6574, 12.2319)
    F_LoadTriggers()
    gClerk = PedCreatePoint(114, POINTLIST._BASEBALLTOSS_MINIGAME_CLERK)
    PedIgnoreStimuli(gClerk, true)
    Wait(100)
    PedFaceHeading(gClerk, 330, 0)
    PedSetActionTree(gPlayer, "/Global/MG_BallToss", "Act/Anim/MG_BallToss.act")
    PedMakeTargetable(gClerk, false)
    PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/StandIdle", "Act/Conv/MGBaseballToss.act")
    PedFaceObject(gClerk, gPlayer, 2, 0)
    PedIgnoreAttacks(gClerk, true)
    Wait(100)
    AreaDisableCameraControlForTransition(false)
    CameraSetActive(13)
    Wait(0)
    CameraSetRotationLimit(20, 40, 0, 1, 0)
    CameraFade(500, 1)
    Wait(501)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    math.randomseed(GetTimer())
    gBaseballCheckTime = GetTimer() + 200
    --print(">>>[RUI]", "!!MissionInit")
end

function CounterSetup(bOn, maxC)
    if bOn then
        CounterSetCurrent(0)
        CounterSetMax(3)
        CarnivalBallTossSetCount(maxC)
        CounterSetIcon("catcher", "catcher_x")
        CounterMakeHUDVisible(true)
        MinigameEnableHUD(true)
    else
        CounterSetMax(0)
        CounterSetCurrent(0)
        CounterClearIcon()
        CounterMakeHUDVisible(false)
    end
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("MGBaseballToss.DAT", 2)
    DATInit()
    bClockPaused = ClockIsPaused()
    PauseGameClock()
    AreaDisableCameraControlForTransition(true)
    MinigameCreate("BALLTOSS", false)
    SoundFadeoutStream(0)
    SoundPlayStream("MS_CarnivalFunhouseAmbient.rsm", 0.6)
    LoadModels({ 114, 495 })
    LoadWeaponModels({ 302 })
    PlayerSetPosPoint(POINTLIST._BASEBALLTOSS_MINIGAME_ENTRY)
    LoadActionTree("Act/Conv/MGBaseballToss.act")
    LoadActionTree("Act/Anim/MG_BallToss.act")
    LoadAnimationGroup("carnies")
    LoadAnimationGroup("CONV")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("MINI_BallToss")
    F_PreLoadTriggers()
end

function MissionCleanup()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
    MinigameDestroy()
    SoundLoopPlay2D("BsTargetTrack", false)
    TextClear()
    CounterSetup(false)
    F_UnloadTriggers()
    CameraAllowChange(true)
    EnableHudComponents(true)
    CameraSetActive(1)
    PlayerSetControl(1)
    AreaDisableCameraControlForTransition(false)
    CameraClearRotationLimit()
    CameraReturnToPlayer()
    CameraReset()
    UnLoadAnimationGroup("carnies")
    UnLoadAnimationGroup("CONV")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("MINI_BallToss")
    Wait(1000)
    PlayerSetControl(1)
    DATUnload(2)
    shared.minigameRunning = nil
    SoundFadeoutStream(0)
    if bPlayerEnteredWithBear then
        PedSetWeapon(gPlayer, 363, 1)
        --print("()xxxxx[:::::::::::::::> [mgshootinggallery.lua] Restoring teddy bear.")
        bPlayerEnteredWithBear = false
    end
    collectgarbage()
end

function F_FailMission()
    mission_accepted = false
end

function F_CheckClerk()
    if gClerkHit then
        if PedIsHit(gClerk, 2, 1000) then
            gClerkHit = false
            gClerkHitTimes = gClerkHitTimes + 1
            if gClerkHitTimes == 1 then
                PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Hit/TorsoFront1", "Act/Conv/MGBaseballToss.act")
            elseif gClerkHitTimes == 2 then
                PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Hit/TorsoFront2", "Act/Conv/MGBaseballToss.act")
            elseif gClerkHitTimes == 3 then
                PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/Hit/KickPlayerOut", "Act/Conv/MGBaseballToss.act")
                game_running = false
            end
            gClerkTimer = GetTimer()
        end
    elseif 1000 < GetTimer() - gClerkTimer then
        gClerkHit = true
    end
end

local noP01, noP02, noP03 = 0, 0, 0
local bS01, bS02, bS03 = true, true, true
local tS01 = GetTimer()
local tS02 = GetTimer()
local tS03 = GetTimer()

function F_TargetManager()
    if bS01 and GetTimer() - tS01 > gPathWaits[1] then
        noP01 = noP01 + 1
        tS01 = GetTimer()
        F_FollowPath(1)
        if noP01 > gNoOfPropsPerPath[1] then
            bS01 = false
        end
    end
    if gOne then
        F_FollowPath(1)
        gOne = false
    end
    if bS02 and GetTimer() - tS02 > gPathWaits[2] then
        noP02 = noP02 + 1
        tS02 = GetTimer()
        F_FollowPath(2)
        if noP02 > gNoOfPropsPerPath[2] then
            bS02 = false
        end
    end
    if gTwo then
        F_FollowPath(2)
        gTwo = false
    end
    if bS03 and GetTimer() - tS03 > gPathWaits[3] then
        noP03 = noP03 + 1
        tS03 = GetTimer()
        F_FollowPath(3)
        if noP03 > gNoOfPropsPerPath[3] then
            bS03 = false
        end
    end
    if gThree then
        F_FollowPath(3)
        gThree = false
    end
end

function PlayerEquipBaseball(bEquip)
    local equip = true
    if bEquip ~= nil then
        equip = bEquip
    end
    if equip then
        --print(">>>[RUI]", "++PlayerEquipBaseball")
        PedSetActionNode(gPlayer, "/Global/MG_BallToss/BaseBall/GiveBall/GiveBall", "Act/Anim/MG_BallToss.act")
    else
        --print(">>>[RUI]", "--PlayerEquipBaseball")
        PedSetActionNode(gPlayer, "/Global/MG_BallToss/BaseBall/RemoveBall", "Act/Anim/MG_BallToss.act")
    end
end

function F_HandleTutorial()
    if bRunTutorial then
        TextPrint("MGBT_INSTRUCT", gMissionTime, 4)
    end
end

function TimerPassed(time)
    return time <= GetTimer()
end

function F_ReleaseBall()
    bBallThrown = true
    StatAddToInt(51)
    gBallsThrown = gBallsThrown + 1
    --print(">>>[RUI]", "F_ReleaseBall")
end

function F_BaseballCountCheck()
    if TimerPassed(gBaseballCheckTime) then
        if 0 < gCurrentBallCount and gCurrentBallCount >= 3 - gStrikes then
            if bBallThrown then
                --print(">>>[RUI]", "--F_BaseballCountCheck")
                CarnivalBallTossDecCount()
                gCurrentBallCount = CarnivalBallTossGetCount()
                bBallThrown = false
                PlayerEquipBaseball()
            end
        else
            --print(">>>[RUI]", "else no balls")
            if not bRanOutStart then
                bRanOutStart = true
                CarnivalBallTossSetCount(0)
                aftershotTimer = GetTimer() + 0
                --print(">>>[RUI]", "bRanOutStart")
            elseif aftershotTimer and TimerPassed(aftershotTimer) then
                --print(">>>[RUI]", "Tell user balls ran out")
                SoundPlayScriptedSpeechEvent(gClerk, "BASEBALL", 14, "large")
                game_running = false
                game_won = false
            end
        end
        gBaseballCheckTime = GetTimer() + 200
    end
end

function F_DisplayCountdown()
    SoundPlayScriptedSpeechEvent(gClerk, "BASEBALL", 19, "jumbo")
    while not IsButtonBeingPressed(7, 0) do
        TextPrint("MGBT_XSTART", 0.5, 1)
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
        while SoundSpeechPlaying(gClerk) do
            Wait(10)
        end
        local i = math.random(20, 23) or 20
        SoundPlayScriptedSpeechEvent(gClerk, "BASEBALL", i, "jumbo")
        TextPrint("MG_READY", 1, 1)
        Wait(1000)
        TextPrint("MG_SET", 1, 1)
        PlayerEquipBaseball()
        Wait(100)
        CounterSetup(true, MAX_BALLCOUNT)
        Wait(1000)
        TutorialRemoveMessage()
        TextPrint("MG_GO", 1, 1)
    end
end

function main()
    MissionInit()
    MinigameStart()
    F_DisplayCountdown()
    if not bQuitGame then
        CameraAllowChange(false)
        gClerkHit = true
        gClerkHitTimes = 0
        PlayerSetControl(1)
        MissionTimerStart(gMissionTime)
        F_HandleTutorial()
        SoundLoopPlay2D("BsTargetTrack", true)
        while game_running do
            F_TargetManager()
            F_CheckTriggers()
            F_ManageLights()
            F_CheckClerk()
            F_BaseballCountCheck()
            if MissionTimerHasFinished() then
                SoundPlayScriptedSpeechEvent(gClerk, "BASEBALL", 11, "large")
                game_running = false
                break
            end
            Wait(0)
        end
        TextClear()
        SoundLoopPlay2D("BsTargetTrack", false)
        Wait(100)
        PlayerEquipBaseball(false)
        PlayerSetControl(0)
        MissionTimerStop()
        Wait(2000)
        if BaseBallTossGameWon(gStrikes) then
            gTickets = BaseBallTossTallyTickets()
            GiveItemToPlayer(495, gTickets)
            while SoundSpeechPlaying(gClerk) do
                Wait(10)
            end
            PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/WonGame", "Act/Conv/MGBaseballToss.act")
            PedSetActionNode(gPlayer, "/Global/MGBaseballToss/Animations/Victory", "Act/Conv/MGBaseballToss.act")
            Wait(4000)
            bSucceed = true
        else
            if gClerkHitTimes < 3 then
                PedSetActionNode(gClerk, "/Global/MGBaseballToss/Animations/Carny/LostGame", "Act/Conv/MGBaseballToss.act")
            end
            PedSetActionNode(gPlayer, "/Global/MGBaseballToss/Animations/Fail", "Act/Conv/MGBaseballToss.act")
            Wait(3000)
        end
    else
        PlayerEquipBaseball(false)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(500, 0)
    Wait(501)
    AreaTransitionPoint(0, POINTLIST._BASEBALLTOSS_MINIGAME_EXIT, nil, true)
    while not (AreaGetVisible() == 0 and shared.gAreaDATFileLoaded[0]) do
        Wait(0)
    end
    if bSucceed then
        MissionSucceed(false, true, false)
    else
        MissionFail(false, false)
    end
end

function BaseBallTossGameWon(score)
    if 3 <= gStrikes then
        return true
    elseif 3 <= gClerkHitTimes then
        return false
    else
        return false
    end
end

function BaseBallTossTallyTickets()
    local tickets = 0
    if bHitTheBonusTarget then
        tickets = 4
    else
        tickets = 3
    end
    --print(">>>[RUI]", "!!BaseBallTossTallyTickets tickets: " .. tostring(tickets))
    return tickets * gTicketMultiplier
end

function EnableHudComponents(bShow)
    local show = true
    if bShow ~= nil then
        show = bShow
    end
    PlayerWeaponHudLock(not show)
    ToggleHUDComponentVisibility(11, show)
    ToggleHUDComponentVisibility(4, show)
    ToggleHUDComponentVisibility(0, show)
end
