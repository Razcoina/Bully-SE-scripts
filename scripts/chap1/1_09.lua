mission_completed = false
Earnest = nil
SpeechOn = true
local bMissionSuccess = false
SpeechTable = {}
HitResponseTable = {}
ComeBackTable = {}
EnemyTable = {}
SeatedTable = {}
StudentTable = {}
AttackersTable = {}
local tblRandomSpeech = {
    {
        model = 17,
        event = nil,
        comment = 41
    },
    {
        model = 17,
        event = "M_4_06",
        comment = 68
    },
    {
        model = 17,
        event = "JEER",
        comment = 0
    },
    {
        model = 17,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 17,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 17,
        event = "JEER",
        comment = 0
    },
    {
        model = 17,
        event = "JEER",
        comment = 0
    },
    {
        model = 17,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 17,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 15,
        event = nil,
        comment = 39
    },
    {
        model = 15,
        event = "TAUNT_RESPONSE_DONT_CARE",
        comment = 0
    },
    {
        model = 15,
        event = "JEER",
        comment = 0
    },
    {
        model = 15,
        event = "JEER",
        comment = 0
    },
    {
        model = 15,
        event = "JEER",
        comment = 0
    },
    {
        model = 15,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 15,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 15,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 13,
        event = nil,
        comment = 41
    },
    {
        model = 13,
        event = "M_2_G2",
        comment = 22
    },
    {
        model = 13,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 13,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 13,
        event = "JEER",
        comment = 0
    },
    {
        model = 13,
        event = "TAUNT",
        comment = 0
    },
    {
        model = 13,
        event = "JEER",
        comment = 0
    }
}
local tblNerdSpeech = {
    {
        model = 5,
        event = nil,
        comment = 43
    },
    {
        model = 9,
        event = nil,
        comment = 44
    },
    {
        model = 6,
        event = "M_2_05",
        comment = 16
    }
}
SpeakerTable = {}
SpeechPaused = false
CompleteTime = 165000
JocksKilled = 0
StudentCreated = 0
MascotCreated = false
MascotDelete = false
MascotSpeech = false
HitFlag = false
TextFlag1 = false
TextFlag2 = false
JockNum = 0
SpeakerCount = 0
local nChanceToCheerEarnest = 30
local LineTime = false
local nEarnestVolume = "jumbo"
local nJockVolume = "medium"
local nSpeechLow, nSpeechHigh = 3, 5
local nDamageThreshold = 0.05
local nCurrentHealthPercentage = 1
local nDefaultHealth = 100
local nMascotDamageRate = 0.2
local bMissionFailed = false
local nEarnestDamage = 10
gCutscene2Enabled = false

function F_PedGetHealthPercent(pedid)
    local maxHealth = PedGetMaxHealth(pedid)
    return PedGetHealth(pedid) / maxHealth
end

function F_CreateCharacters()
    Earnest = PedCreatePoint(10, POINTLIST._1_09_EARNEST)
    PedSetFlag(Earnest, 13, true)
    PedIgnoreStimuli(Earnest, true)
    PedSetHealth(Earnest, nDefaultHealth)
    PedMakeTargetable(Earnest, false)
    PedStop(Earnest)
    PedIgnoreAttacks(Earnest, true)
    PedSetMaxHealth(Earnest, nDefaultHealth)
    PedSetMinHealth(Earnest, nDefaultHealth * nDamageThreshold)
    PedShowHealthBar(Earnest, true, "N_Earnest", false)
    PedSetHealthBarQuiet(true)
    PedShowHealthBarInFPmode(true)
    PedSetAIButes("1_09")
    F_SetupSeated()
    F_CreateSeated()
    F_SetupStudents()
    F_CreateStudents()
    PedSetTypeToTypeAttitude(2, 1, 2)
    PedSetTypeToTypeAttitude(2, 6, 2)
end

function F_AttackPoint1(PedID, PathID, NodeID)
    if NodeID == 2 then
        PedSetStationary(PedID, true)
        PedAttack(PedID, Earnest, 3, true)
    end
end

function F_CheckMascot()
    local MascotRun = false
    local bMascotDancing = false
    PedSetFlag(Mascot, 13, true)
    while true do
        Wait(0)
        if PedIsInTrigger(Mascot, TRIGGER._1_09_STAGELEFT) then
            if PedIsValid(Mascot) then
                PedStop(Mascot)
                PedDelete(Mascot)
            end
            JocksKilled = JocksKilled + 1
            break
        elseif PedIsValid(Mascot) and not MascotRun then
            PedApplyDamage(Earnest, nMascotDamageRate)
        end
        if PedIsValid(Mascot) and PedIsHit(Mascot, 2, 0) and MascotRun == false then
            --print("MASCOT HIT!!!!!")
            if PedGetHealth(Mascot) < 80 then
                PedSetActionNode(Mascot, "/Global/1_09/CustomPedTree/Break", "Act\\Anim\\NPC1_09.act")
                MascotRun = true
                Wait(10)
                PedSetInvulnerable(Mascot, true)
                PedClearObjectives(Mascot)
                PedFollowPath(Mascot, PATH._1_09_MASCOTEXIT, 0, 1)
                MascotDelete = true
                HitFlag = true
                TextFlag1 = true
                SpeechPaused = false
                BlipRemove(MascotBlip)
            else
                Wait(0)
                if not PedIsPlaying(Mascot, "/Global/NPC1_09/Mascot/MascotDancing", true) then
                    PedSetActionNode(Mascot, "/Global/NPC1_09/Mascot/MascotDancing", "Act\\Anim\\NPC1_09.act")
                    bMascotDancing = true
                end
            end
        end
    end
end

function F_MascotDance2(PedID, PathID, NodeID)
    if NodeID == 1 and PedIsValid(PedID) then
        PedClearObjectives(PedID)
        PedFaceObjectNow(PedID, gPlayer, 2)
        PedSetActionNode(PedID, "/Global/NPC1_09/Mascot/MascotDancing", "Act\\Anim\\NPC1_09.act")
    end
end

function F_MascotWait()
    if PedIsValid(Mascot) then
        PedStop(Mascot)
        PedClearObjectives(Mascot)
        PedSetActionTree(Mascot, "/Global/J_Striker_A/Default", "Act/Anim/J_Striker_A.act")
        PedFollowPath(Mascot, PATH._1_09_MASCOTENTER2, 0, 0, F_MascotDance2)
    end
end

function F_MascotDance(PedID, PathID, NodeID)
    if NodeID == 3 and PedIsValid(PedID) then
        SpeechPaused = true
    end
end

function MissionSetup()
    SoundPlayInteractiveStream("MS_RunningLow02.rsm", 0.4)
    PlayCutsceneWithLoad("1-09", true)
    DATUnload(0)
    DATLoad("1_09.DAT", 2)
    DATInit()
    local lx = -669.87
    local ly = -308.5
    local lz = 0.01
    PlayerSetPosXYZArea(lx, ly, lz, 2)
    AreaClearAllPeds()
    MissionDontFadeIn()
end

function MissionCleanup()
    PedSetHealthBarQuiet(false)
    PedShowHealthBarInFPmode(false)
    AreaLoadSpecialEntities("vote", false)
    PlayerLockButtonInputsExcept(false)
    DisablePunishmentSystem(false)
    UnpauseGameClock()
    PedSetStationary(gPlayer, false)
    SoundStopInteractiveStream()
    AreaDisableCameraControlForTransition(false)
    CounterMakeHUDVisible(false)
    CounterUseMeter(false)
    for i, key in EnemyTable do
        if PedIsValid(EnemyTable[i].handle) then
            PedDelete(EnemyTable[i].handle)
        end
    end
    SoundEnableSpeech_ActionTree()
    PedSetAIButes("Default")
    UnLoadAnimationGroup("1_09_Candidate")
    UnLoadAnimationGroup("NPC_Mascot")
    UnLoadAnimationGroup("NIS_1_09")
    UnLoadAnimationGroup("1_03The Setup")
    UnLoadAnimationGroup("IDLE_NERD_A")
    UnLoadAnimationGroup("Cheer_Nerd1")
    PedResetTypeAttitudesToDefault()
    if bMissionSuccess then
        AreaLoadSpecialEntities("Halloween2", true)
        AreaEnsureSpecialEntitiesAreCreated()
        PauseGameClock()
    end
    DATUnload(2)
    DATInit()
    PlayerWeaponHudLock(false)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    Wait(10)
    PedHideHealthBar()
    PlayerFaceHeadingNow(180)
    EnemyTable = {}
    collectgarbage()
end

function F_EnemyTimer()
    local GameTime = GetTimer()
    local EnemyTime, LocalTime
    local PauseTime = 0
    while SpeechOn == true do
        Wait(0)
        EnemyTime = GetTimer()
        while JockNum >= 6 do
            Wait(0)
            PauseTime = GetTimer() - EnemyTime
        end
        for index, key in EnemyTable do
            if EnemyTable[index].handle == nil and EnemyTime - GameTime > EnemyTable[index].CreateTime + PauseTime then
                F_CreateAttacker(index)
            end
        end
        if EnemyTime - GameTime >= 105000 + PauseTime and MascotCreated == false then
            MascotCreated = true
            F_Mascot()
        end
        if EnemyTime - (GameTime + PauseTime) > CompleteTime + PauseTime and JocksKilled >= 26 then
            F_Success()
            SpeechOn = false
        end
    end
end

function F_EarnestSpeech()
    local CurrentLine = 1
    local Choice = 0
    local TextFlag3 = false
    local GameTime = GetTimer()
    local SpeechTime = 0
    local MascotTimer = 0
    local MFlag1 = false
    local x, y, z = GetPointList(POINTLIST._1_09_EARNEST)
    while SpeechOn == true do
        Wait(0)
        SpeechTime = GetTimer()
        if PedIsHit(Earnest, 2, 0) then
            SoundStopCurrentSpeechEvent(Earnest)
            F_StimulateCrowd(false, true, false)
            HitFlag = true
        end
        while SpeechPaused == true do
            Wait(0)
            if not PedIsInAreaXYZ(Earnest, x, y, z, 0.75, 0) then
                PedSetAsleep(Earnest, false)
                PedSetStationary(Earnest, false)
                PedMoveToPoint(Earnest, 0, POINTLIST._1_09_EARNEST)
            else
                PedSetAsleep(Earnest, true)
                PedSetStationary(Earnest, true)
            end
            if MascotCreated == true then
                if MascotSpeech == false then
                    MascotSpeech = true
                    SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", 51, nEarnestVolume, true)
                    Wait(3000)
                    SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", 48, nEarnestVolume, true)
                    Wait(2000)
                end
                if MascotDelete == false and MascotSpeech == true then
                    MascotTimer = GetTimer()
                    if MascotTimer - GameTime == 5000 and MFlag1 == false then
                        MFlag1 = true
                        SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", 45, nEarnestVolume, true)
                        PedSetActionNode(Earnest, "/Global/NPC1_09/EarnestCry", "Act/Anim/NPC1_09.act")
                        Wait(3000)
                    end
                end
            end
        end
        if HitFlag == true then
            Choice = math.random(1, 2)
            if TextFlag1 == false then
                TextFlag1 = true
                SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", HitResponseTable[Choice].line, nEarnestVolume, true)
                GameTime = GetTimer({})
            end
            while PedIsPlaying(Earnest, "/Global/HitTree", true) do
                Wait(0)
            end
            PedSetInvulnerable(Earnest, false)
            if not PedIsInAreaXYZ(Earnest, x, y, z, 0.75, 0) then
                PedSetAsleep(Earnest, false)
                PedSetStationary(Earnest, false)
                PedMoveToPoint(Earnest, 0, POINTLIST._1_09_EARNEST)
            end
            while not PedIsInAreaXYZ(Earnest, x, y, z, 0.75, 0) do
                Wait(0)
                if PedIsHit(Earnest, 2, 1000) then
                    Choice = math.random(1, 2)
                    SoundStopCurrentSpeechEvent(Earnest)
                    SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", HitResponseTable[Choice].line, nEarnestVolume, true)
                    while LineTime do
                        Wait(0)
                    end
                end
            end
            PedFaceHeading(Earnest, 180, 0)
            PedSetAsleep(Earnest, true)
            PedSetStationary(Earnest, true)
            if TextFlag2 == false then
                TextFlag2 = true
            end
            if TextFlag2 == true and not LineTime then
                HitFlag = false
                TextFlag1 = false
                TextFlag2 = false
            end
        else
            if TextFlag3 == false and HitFlag == false then
                TextFlag3 = true
                SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", SpeechTable[CurrentLine].line, nEarnestVolume, true)
                PedSetActionNode(Earnest, "/Global/1_09/EarnestSpeech/" .. SpeechTable[CurrentLine].anim, "Act/Conv/1_09.act")
                --print("Setting Earnest Action Tree: " .. SpeechTable[CurrentLine].anim)
                GameTime = GetTimer({})
                LineTime = SoundSpeechPlaying()
            end
            if TextFlag3 == true and not LineTime then
                CurrentLine = CurrentLine + 1
                --print("CurrentLine: " .. CurrentLine)
                if CurrentLine > table.getn(SpeechTable) then
                    SpeechOn = false
                    F_Success()
                end
                TextFlag3 = false
            end
        end
    end
end

function F_ProcessAttackers()
    while SpeechOn == true do
        Wait(4)
        for i, key in EnemyTable do
            if EnemyTable[i].deleteflag == true then
                if PedIsHit(EnemyTable[i].handle, 2, 6) and PedGetWhoHitMeLast(EnemyTable[i].handle) == gPlayer then
                    PedClearObjectives(EnemyTable[i].handle)
                    PedStop(EnemyTable[i].handle)
                    PedSetStationary(EnemyTable[i].handle, false)
                    PedSetInvulnerable(EnemyTable[i].handle, true)
                    if F_CompareTable(i, {
                            3,
                            6,
                            9,
                            11,
                            12
                        }) then
                        F_StimulateCrowd(true, false, true)
                    end
                    if EnemyTable[i].point == POINTLIST._1_09_CATWALK1 then
                        PedStop(EnemyTable[i].handle)
                        PedFaceHeading(EnemyTable[i].handle, 90, 0)
                        PedSetActionTree(EnemyTable[i].handle, "/Global/J_Striker_A", "Act/Anim/J_Striker_A.act")
                        Wait(250)
                        PedFollowPath(EnemyTable[i].handle, EnemyTable[i].path, 0, 2, nil, 2)
                    else
                        Wait(300)
                        local animchoice = math.random(1, 100)
                        if animchoice <= 25 then
                            PedSetActionNode(EnemyTable[i].handle, "/Global/Ambient/MissionSpec/MissionCower", "Act/Anim/Ambient.act")
                        elseif animchoice <= 75 then
                            PedSetActionNode(EnemyTable[i].handle, "/Global/Ambient/MissionSpec/MissionLookAround", "Act/Anim/Ambient.act")
                        end
                        Wait(100)
                        PedStop(EnemyTable[i].handle)
                        PedFollowPath(EnemyTable[i].handle, EnemyTable[i].path, 0, 1, nil, 2)
                    end
                    BlipRemove(EnemyTable[i].blip)
                    PedIgnoreStimuli(EnemyTable[i].handle, true)
                    if EnemyTable[i].cpoint == nil then
                        PedSetInvulnerable(EnemyTable[i].handle, true)
                    end
                end
                if PedIsInTrigger(EnemyTable[i].handle, EnemyTable[i].trigger) then
                    PedStop(EnemyTable[i].handle)
                    PedDelete(EnemyTable[i].handle)
                    EnemyTable[i].deleteflag = false
                    JocksKilled = JocksKilled + 1
                    if 0 < JockNum then
                        JockNum = JockNum - 1
                    end
                end
            end
        end
    end
end

function F_CompareTable(thing, tableOfThingsToCompareWith)
    for i, entry in tableOfThingsToCompareWith do
        if thing == entry then
            --print("THING CONFIRMED in INDEX #" .. i)
            return true
        end
    end
    return false
end

function F_CheckFailure()
    local EHealth
    local soundflag1 = false
    local soundflag2 = false
    while SpeechOn == true do
        Wait(0)
        if F_PedGetHealthPercent(Earnest) <= nDamageThreshold then
            SpeechOn = false
            Wait(1000)
            F_FailStuff("1_G1_FAILHUM")
            Wait(5000)
        end
        if SpeakerCount == 10 then
            SpeechOn = false
            F_FailStuff("1_G1_FAILSPKR")
            Wait(5000)
        end
    end
end

function F_FailStuff(szFailMessage)
    if PedIsValid(Earnest) then
        SoundStopCurrentSpeechEvent(Earnest)
        Wait(500)
        SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", 45, nEarnestVolume, true)
        PedSetStationary(Earnest, false)
        PedFollowPath(Earnest, PATH._1_09_FLEEEARNEST, 0, 2)
        PedSetInvulnerable(Earnest, true)
        Wait(2000)
    end
    for i, entry in SeatedTable do
        if PedIsValid(entry.handle) then
            PedMakeAmbient(entry.handle)
        end
    end
    PedHideHealthBar()
    SoundPlayMissionEndMusic(false, 10)
    if szFailMessage then
        MissionFail(false, true, szFailMessage)
    else
        MissionFail(false)
    end
    if AreaGetVisible() == 19 then
        Wait(5500)
        PlayerWeaponHudLock(false)
        PlayerUnequip()
        CameraAllowChange(true)
        CameraReturnToPlayer()
        PlayerSetControl(0)
        PedDestroyWeapon(gPlayer, 306)
        AreaTransitionPoint(2, POINTLIST._1_09_ENDTRANS)
        AreaLoadSpecialEntities("vote", false)
    end
    bMissionFailed = true
end

function F_Debug()
    local x, y, z = PlayerGetPosXYZ()
    AreaLoadSpecialEntities("vote", true)
    AreaTransitionPoint(19, POINTLIST._1_09_PSTART)
    Wait(3000)
    while IsStreamingBusy() do
        Wait(0)
    end
    F_CreateCharacters()
    Wait(2000)
    CreateThread("F_JockTaunt")
    Wait(50000000)
    --print("[1.09] SETTING FATTY'S NODE!!!!!!!")
end

function cbNerdStandCheck()
    if shared.g109Nerd then
        return 1
    else
        return 0
    end
end

function cbJockStandCheck()
    if shared.g109Jock then
        return 1
    else
        return 0
    end
end

function cbResetVars()
    shared.g109Jock = nil
end

function F_StimulateCrowd(bNerdStand, bJockStand, bApplause)
    if bNerdStand then
        shared.g109Nerd = true
    end
    if bJockStand then
        shared.g109Jock = true
    end
    if bApplause then
        SoundPlay2D("Applause")
    end
end

function main()
    LoadAnimationGroup("1_03The Setup")
    LoadAnimationGroup("Cheer_Nerd1")
    LoadAnimationGroup("IDLE_NERD_A")
    LoadAnimationGroup("1_09_Candidate")
    LoadAnimationGroup("NPC_Mascot")
    LoadAnimationGroup("NIS_1_09")
    LoadActionTree("Act/Conv/1_09.act")
    LoadActionTree("Act/Anim/NPC1_09.act")
    CameraFade(1000, 1)
    TextPrint("1_09_TRIGGER", 3, 1)
    Wait(0)
    local x1, y1, z1 = GetPointList(POINTLIST._1_09_HALLTRIG)
    local hallblip = BlipAddXYZ(x1, y1, z1, 0)
    MissionObj1 = MissionObjectiveAdd("1_09_TRIGGER")
    MissionTimerStart(30)
    while not PedIsInAreaXYZ(gPlayer, x1, y1, z1, 1, 7) do
        Wait(0)
        if MissionTimerHasFinished() then
            MissionTimerStop()
            F_FailStuff("1_G1_FAILTIME")
            break
        end
    end
    BlipRemove(hallblip)
    if not bMissionFailed then
        F_MissionLoop()
    end
    while mission_completed == false do
        if SoundSpeechPlaying() then
            LineTime = true
        else
            LineTime = false
        end
        Wait(0)
    end
    F_PlayerGotThingyNIS()
end

function F_Success()
    SpeechOn = false
    for i, entry in EnemyTable do
        if PedIsValid(entry.handle) then
            BlipRemove(entry.blip)
            PedDestroyWeapon(entry.handle, 312)
            entry.deleteflag = true
        end
    end
    Wait(1000)
    F_EarnestFinishNIS()
    F_EndCut()
    mission_completed = true
end

function F_MissionLoop()
    MissionTimerStop()
    if MissionObj1 then
        MissionObjectiveRemove(MissionObj1)
    end
    if gCutscene2Enabled == true then
        AreaLoadSpecialEntities("vote", true)
        AreaTransitionPoint(19, POINTLIST._1_09_ENDC1, nil, true)
        F_EndCut()
    end
    PlayerSetControl(0)
    CameraFade(1000, 0)
    Wait(1000)
    SoundStopInteractiveStream(0)
    SoundEnableInteractiveMusic(false)
    AreaLoadSpecialEntities("vote", true)
    AreaTransitionPoint(19, POINTLIST._1_09_AUDTRIG, nil, true)
    local x, y, z = GetPointList(POINTLIST._1_09_AUDTRIG)
    while not PedIsInAreaXYZ(gPlayer, x, y, z, 2, 1) do
        Wait(0)
    end
    while IsStreamingBusy() do
        Wait(0)
    end
    Wait(2000)
    PlayerSetPosPoint(POINTLIST._1_09_CUTSTART)
    PlayerFaceHeading(0, 1)
    LoadPedModels({
        16,
        13,
        18,
        20,
        15,
        88
    })
    LoadWeaponModels({ 306 })
    PauseGameClock()
    local h, m = ClockGet()
    if h < 18 then
        ClockSet(18, 45)
    elseif h == 18 and m < 45 then
        ClockSet(18, 45)
    end
    CameraSetFOV(90)
    CameraSetPath(PATH._1_09_NISINTROCAM, true)
    CameraSetSpeed(0.8, 0.2, 0.2)
    CameraLookAtPath(PATH._1_09_NISINTROCAM_LOOK, true)
    CameraSetFOV(90)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true, false)
    PedSetWeaponNow(gPlayer, 306, 1)
    Wait(1000)
    F_SetupEnemyTable()
    F_SetupSpeakerTable()
    F_CreateCharacters()
    SoundPlayStream("MS_Candidate.rsm", 0.4)
    CameraFade(1000, 1)
    Wait(1000)
    TextPrint("1_09_08", 6, 1)
    Wait(3500)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraSetFOV(90)
    CameraSetPath(PATH._1_09_NISINTROCAM2, true)
    CameraSetSpeed(0.8, 0.2, 0.2)
    CameraLookAtPath(PATH._1_09_NISINTROCAM2_LOOK, true)
    Wait(7500)
    CameraFade(500, 0)
    Wait(500)
    CameraDefaultFOV()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    local tx, ty, tz = GetPointList(POINTLIST._1_09_PSTART)
    PlayerSetPosSimple(tx, ty, tz)
    Wait(100)
    CameraSetActive(2)
    PedSetStationary(gPlayer, true)
    CameraAllowChange(false)
    PlayerWeaponHudLock(true)
    F_SetupDialog()
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(true, 18, 22, 19, 23, 2, 3, 12)
    CameraFade(500, 1)
    F_MakePlayerSafeForNIS(false, false)
    PlayerSetPunishmentPoints(0)
    DisablePunishmentSystem(true)
    Wait(500)
    TutorialStart("SSLING1")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundDisableSpeech_ActionTree()
    CreateThread("F_EarnestSpeech")
    CreateThread("F_JockTaunt")
    PedSetActionNode(Earnest, "/Global/NPC1_09/Speech", "Act/Anim/NPC1_09.act")
    CreateThread("F_EnemyTimer")
    CreateThread("F_ProcessAttackers")
    CreateThread("F_CheckFailure")
    MissionObj2 = MissionObjectiveAdd("1_09_08")
    MissionObjectiveReminderTime(1000000)
end

function F_EarnestFinishNIS()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    F_Cinematic(true)
    CameraAllowChange(true)
    PedSetInvulnerable(Earnest, true)
    SoundStopCurrentSpeechEvent(Earnest)
    Wait(1000)
    PlayerUnequip()
    CameraSetWidescreen(true)
    PlayerWeaponHudLock(false)
    CameraReturnToPlayer()
    CameraSetFOV(90)
    CameraSetXYZ(-770.22723, 307.27567, 78.10176, -769.9627, 308.2095, 78.33977)
    CameraFade(500, 1)
    PedSetActionNode(Earnest, "/Global/1_09/NIS/Earnest/Earnest01", "Act/Conv/1_09.act")
    F_PlaySpeechWait(Earnest, "M_1_09", 34, "jumbo")
    CameraSetFOV(80)
    CameraSetXYZ(-769.9688, 308.01367, 78.294075, -769.6935, 308.93536, 78.56688)
    PedSetActionNode(Earnest, "/Global/1_09/NIS/Earnest/Earnest02", "Act/Conv/1_09.act")
    F_PlaySpeechWait(Earnest, "M_1_09", 35, "jumbo")
    F_StimulateCrowd(true, false, true)
    PedSetActionNode(Earnest, "/Global/1_09/NIS/Earnest/Earnest03", "Act/Conv/1_09.act")
    SoundPlayScriptedSpeechEvent(Earnest, "M_1_09", 36, nEarnestVolume, true)
    Wait(400)
    CameraSetFOV(80)
    CameraSetPath(PATH._1_09_CUT3, true)
    CameraSetSpeed(1, 0, 2)
    CameraLookAtPath(PATH._1_09_NISWIDE, true)
    CameraLookAtPathSetSpeed(1, 0, 2)
    Wait(1000)
    F_StimulateCrowd(true, false, true)
    SoundPlay2D("Applause")
    SoundPlay2D("Applause")
    Wait(1000)
    F_StimulateCrowd(true, false, true)
    SoundPlay2D("Applause")
    SoundPlay2D("Applause")
    Wait(1000)
    F_StimulateCrowd(true, false, true)
    SoundPlay2D("Applause")
    SoundPlay2D("Applause")
    Wait(1000)
    F_StimulateCrowd(true, false, true)
    SoundPlay2D("Applause")
    SoundPlay2D("Applause")
    Wait(1000)
    F_StimulateCrowd(true, false, true)
    SoundPlay2D("Applause")
    SoundPlay2D("Applause")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_Cinematic(bStart)
    if bStart then
        CameraFade(500, 0)
        Wait(500)
        PlayerSetControl(0)
        F_MakePlayerSafeForNIS(true)
    elseif not bStart then
        CameraFade(500, 0)
        Wait(500)
        CameraReturnToPlayer()
        CameraFade(500, 1)
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
    end
end

function F_SetupDialog()
    table.insert(SpeechTable, {
        line = 3,
        duration = 1,
        anim = "01"
    })
    table.insert(SpeechTable, {
        line = 4,
        duration = 4,
        anim = "02"
    })
    table.insert(SpeechTable, {
        line = 5,
        duration = 4,
        anim = "03"
    })
    table.insert(SpeechTable, {
        line = 6,
        duration = 4,
        anim = "04"
    })
    table.insert(SpeechTable, {
        line = 7,
        duration = 4,
        anim = "05"
    })
    table.insert(SpeechTable, {
        line = 8,
        duration = 4,
        anim = "06"
    })
    table.insert(SpeechTable, {
        line = 9,
        duration = 4,
        anim = "07"
    })
    table.insert(SpeechTable, {
        line = 10,
        duration = 4,
        anim = "08"
    })
    table.insert(SpeechTable, {
        line = 11,
        duration = 4,
        anim = "09"
    })
    table.insert(SpeechTable, {
        line = 12,
        duration = 4,
        anim = "10"
    })
    table.insert(SpeechTable, {
        line = 13,
        duration = 4,
        anim = "11"
    })
    table.insert(SpeechTable, {
        line = 14,
        duration = 4,
        anim = "12"
    })
    table.insert(SpeechTable, {
        line = 15,
        duration = 5,
        anim = "13"
    })
    table.insert(SpeechTable, {
        line = 16,
        duration = 4,
        anim = "14"
    })
    table.insert(SpeechTable, {
        line = 17,
        duration = 4,
        anim = "15"
    })
    table.insert(SpeechTable, {
        line = 18,
        duration = 4,
        anim = "16"
    })
    table.insert(SpeechTable, {
        line = 19,
        duration = 4,
        anim = "17"
    })
    table.insert(SpeechTable, {
        line = 20,
        duration = 4,
        anim = "18"
    })
    table.insert(SpeechTable, {
        line = 21,
        duration = 4,
        anim = "19"
    })
    table.insert(SpeechTable, {
        line = 22,
        duration = 4,
        anim = "20"
    })
    table.insert(SpeechTable, {
        line = 23,
        duration = 4,
        anim = "21"
    })
    table.insert(SpeechTable, {
        line = 24,
        duration = 4,
        anim = "22"
    })
    table.insert(SpeechTable, {
        line = 25,
        duration = 4,
        anim = "23"
    })
    table.insert(SpeechTable, {
        line = 26,
        duration = 5,
        anim = "24"
    })
    table.insert(SpeechTable, {
        line = 27,
        duration = 4,
        anim = "25"
    })
    table.insert(SpeechTable, {
        line = 28,
        duration = 4,
        anim = "26"
    })
    table.insert(SpeechTable, {
        line = 29,
        duration = 4,
        anim = "27"
    })
    table.insert(SpeechTable, {
        line = 30,
        duration = 5,
        anim = "28"
    })
    table.insert(SpeechTable, {
        line = 31,
        duration = 4,
        anim = "29"
    })
    table.insert(SpeechTable, {
        line = 32,
        duration = 4,
        anim = "30"
    })
    table.insert(HitResponseTable, { line = 37, duration = 2 })
    table.insert(HitResponseTable, { line = 37, duration = 2 })
    table.insert(ComeBackTable, { line = 38, duration = 3 })
    table.insert(ComeBackTable, { line = 38, duration = 3 })
    table.insert(ComeBackTable, { line = 38, duration = 3 })
    table.insert(ComeBackTable, { line = 38, duration = 3 })
end

function F_SetupEnemyTable()
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 5000,
        model = 13,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_AISLELEFT,
        cpoint = POINTLIST._1_09_COVERFLOORL,
        path = PATH._1_09_AISLELEFT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_AISLELEFT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 12500,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGELEFT,
        cpoint = POINTLIST._1_09_COVERSTAGEL,
        path = PATH._1_09_STAGELEFT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGELEFT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 21200,
        model = 15,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXLEFT2,
        cpoint = POINTLIST._1_09_COVERL2,
        path = PATH._1_09_BOXLEFT2,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXLEFT2,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 30000,
        model = 17,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_AISLELEFT,
        cpoint = POINTLIST._1_09_COVERFLOORL1,
        path = PATH._1_09_AISLELEFT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_AISLELEFT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 38000,
        model = 18,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXLEFT2,
        cpoint = POINTLIST._1_09_COVERL2,
        path = PATH._1_09_BOXLEFT2,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXLEFT2,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 44000,
        model = 20,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_CATWALK1,
        cpoint = nil,
        path = PATH._1_09_CATWALK1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_CATWALK1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 52000,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXRIGHT2,
        cpoint = POINTLIST._1_09_COVERR2,
        path = PATH._1_09_BOXRIGHT2,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXRIGHT2,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 53000,
        model = 15,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGERIGHT,
        cpoint = POINTLIST._1_09_COVERSTAGER,
        path = PATH._1_09_STAGERIGHT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGERIGHT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 60000,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_AISLERIGHT,
        cpoint = POINTLIST._1_09_COVERFLOORR,
        path = PATH._1_09_AISLERIGHT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_AISLERIGHT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 71000,
        model = 13,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGERIGHT,
        cpoint = POINTLIST._1_09_COVERSTAGER,
        path = PATH._1_09_STAGERIGHT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGERIGHT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 72000,
        model = 15,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXRIGHT1,
        cpoint = POINTLIST._1_09_COVERR1,
        path = PATH._1_09_BOXRIGHT1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXRIGHT1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 80000,
        model = 18,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_CATWALK1,
        cpoint = nil,
        path = PATH._1_09_CATWALK1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_CATWALK1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 89000,
        model = 13,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXRIGHT1,
        cpoint = POINTLIST._1_09_COVERR1,
        path = PATH._1_09_BOXRIGHT1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXRIGHT1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 95000,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGELEFT,
        cpoint = POINTLIST._1_09_COVERSTAGEL,
        path = PATH._1_09_STAGELEFT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGELEFT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 120000,
        model = 18,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGERIGHT,
        cpoint = POINTLIST._1_09_COVERSTAGER,
        path = PATH._1_09_STAGERIGHT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGERIGHT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 122000,
        model = 15,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_CATWALK1,
        cpoint = nil,
        path = PATH._1_09_CATWALK1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_CATWALK1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 130000,
        model = 13,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXLEFT2,
        cpoint = POINTLIST._1_09_COVERL2,
        path = PATH._1_09_BOXLEFT2,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXLEFT2,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 131000,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_AISLELEFT,
        cpoint = POINTLIST._1_09_COVERFLOORL,
        path = PATH._1_09_AISLELEFT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_AISLELEFT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 139000,
        model = 15,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXLEFT1,
        cpoint = POINTLIST._1_09_COVERL1,
        path = PATH._1_09_BOXLEFT1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXLEFT1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 145000,
        model = 20,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGELEFT,
        cpoint = POINTLIST._1_09_COVERSTAGEL,
        path = PATH._1_09_STAGELEFT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGELEFT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 146000,
        model = 17,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_CATWALK1,
        cpoint = nil,
        path = PATH._1_09_CATWALK1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_CATWALK1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 150000,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_AISLERIGHT,
        cpoint = POINTLIST._1_09_COVERFLOORR,
        path = PATH._1_09_AISLERIGHT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_AISLERIGHT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 151000,
        model = 13,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_STAGERIGHT,
        cpoint = POINTLIST._1_09_COVERSTAGER,
        path = PATH._1_09_STAGERIGHT,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_STAGERIGHT,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 155000,
        model = 20,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_BOXRIGHT1,
        cpoint = POINTLIST._1_09_COVERR1,
        path = PATH._1_09_BOXRIGHT1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_BOXRIGHT1,
        blip = nil
    })
    table.insert(EnemyTable, {
        handle = nil,
        CreateTime = 158000,
        model = 16,
        weapon = 312,
        weapcount = 99,
        point = POINTLIST._1_09_CATWALK1,
        cpoint = nil,
        path = PATH._1_09_CATWALK1,
        cbfunc = F_AttackPoint1,
        deleteflag = false,
        trigger = TRIGGER._1_09_CATWALK1,
        blip = nil
    })
end

function F_SetupSeated()
    SeatedTable = {
        {
            handle = nil,
            model = 5,
            element = 1
        },
        {
            handle = nil,
            model = 9,
            element = 2
        },
        {
            handle = nil,
            model = 8,
            element = 3
        },
        {
            handle = nil,
            model = 15,
            element = 4
        },
        {
            handle = nil,
            model = 13,
            element = 5
        },
        {
            handle = nil,
            model = 17,
            element = 6
        },
        {
            handle = nil,
            model = 6,
            element = 7
        },
        {
            handle = nil,
            model = 21,
            element = 8
        },
        {
            handle = nil,
            model = 30,
            element = 9
        },
        {
            handle = nil,
            model = 3,
            element = 10
        },
        {
            handle = nil,
            model = 14,
            element = 11
        },
        {
            handle = nil,
            model = 31,
            element = 12
        },
        {
            handle = nil,
            model = 22,
            element = 13
        }
    }
end

function F_SetupStudents()
end

function F_CreateSeated()
    for i, entry in SeatedTable do
        entry.handle = PedCreatePoint(entry.model, POINTLIST._1_09_SEATEDPOINTS, entry.element)
        PedMakeTargetable(entry.handle, false)
        PedIgnoreStimuli(entry.handle, true)
        PedSetInvulnerable(entry.handle, true)
        PedIgnoreAttacks(entry.handle, true)
        PedSetActionNode(entry.handle, "/Global/1_09/CustomPedTree", "Act/Conv/1_09.act")
    end
end

function F_CreateStudents()
end

function F_Sleep()
end

function F_CreateAttacker(index)
    --print("EnemyCreated:: " .. index)
    if EnemyTable[index].point == POINTLIST._1_09_CATWALK1 then
        EnemyTable[index].handle = PedCreatePoint(EnemyTable[index].model, EnemyTable[index].point)
        PedSetActionTree(EnemyTable[index].handle, "/Global/NPC1_09/Default_KEY", "Act/Anim/NPC1_09.act")
        PedFaceHeading(EnemyTable[index].handle, 90, 0)
        PedFollowPath(EnemyTable[index].handle, EnemyTable[index].path, 0, 0, EnemyTable[index].cbfunc)
    else
        EnemyTable[index].handle = PedCreatePoint(EnemyTable[index].model, EnemyTable[index].point)
    end
    EnemyTable[index].blip = AddBlipForChar(EnemyTable[index].handle, 2, 26, 4)
    PedSetStatsType(EnemyTable[index].handle, "STAT_109_RANGED")
    PedSetFlag(EnemyTable[index].handle, 13, true)
    PedOverrideStat(EnemyTable[index].handle, 3, 10)
    PedAddPedToIgnoreList(EnemyTable[index].handle, gPlayer)
    PedSetPedToTypeAttitude(EnemyTable[index].handle, 13, 0)
    if EnemyTable[index].cpoint ~= nil then
        PedCoverSet(EnemyTable[index].handle, Earnest, EnemyTable[index].cpoint, 0, 100, 0, 1, 1, 0.5, 0.5, 99, 99, 99, 99, true)
    elseif EnemyTable[index].cpoint == nil then
        PedFollowPath(EnemyTable[index].handle, EnemyTable[index].path, 0, 2, EnemyTable[index].cbfunc)
    end
    PedSetMinEngage(EnemyTable[index].handle, 100)
    PedSetCombatZoneMask(EnemyTable[index].handle, false, false, true)
    PedSetMoney(EnemyTable[index].handle, 0)
    PedSetWeapon(EnemyTable[index].handle, EnemyTable[index].weapon, EnemyTable[index].weapcount)
    PedOverrideStat(EnemyTable[index].handle, 34, 0)
    if index ~= 17 or index ~= 19 then
        PedAddPedToIgnoreList(EnemyTable[index].handle, gPlayer)
    end
    EnemyTable[index].deleteflag = true
    JockNum = JockNum + 1
    if SpeechPaused == false and index == 1 then
        --print("CS TIME!!!")
        SpeechPaused = true
        F_Sleep()
        SpeechPaused = false
        TutorialStart("SSLING1")
    end
end

function F_SpeechCut()
    CameraAllowChange(true)
    CameraSetWidescreen(true)
    CameraReturnToPlayer()
    PlayerSetControl(0)
    CameraSetPath(PATH._1_09_CUT2, true)
    CameraLookAtObject(EnemyTable[1].handle, 2, true)
    TextPrint("1_09_CRAP", 2, 2)
    Wait(2000)
    CameraReturnToPlayer()
    Wait(10)
    CameraSetActive(2)
    Wait(10)
    CameraAllowChange(false)
    CameraSetWidescreen(false)
    SpeechPaused = false
    PlayerSetControl(1)
end

function F_Mascot()
    Mascot = PedCreatePoint(88, POINTLIST._1_09_STAGERIGHT)
    PedSetFlag(Mascot, 13, true)
    PedOverrideStat(Mascot, 3, 2)
    PedAddPedToIgnoreList(Mascot, gPlayer)
    PedSetPedToTypeAttitude(Mascot, 13, 0)
    PedFollowPath(Mascot, PATH._1_09_MASCOTENTER, 0, 0, F_MascotDance)
    PedAddPedToIgnoreList(Mascot, gPlayer)
    PedIgnoreStimuli(Mascot, true)
    PedClearAllWeapons(Mascot)
    PedOverrideStat(Mascot, 34, 0)
    PedSetHealth(Mascot, 150)
    MascotBlip = AddBlipForChar(Mascot, 2, 26, 4)
    CreateThread("F_CheckMascot")
end

function F_EndCut()
    PlayerSetControl(0)
    CameraFade(1000, 0)
    Wait(1000)
    --print("DISABLING THE HUD COUNTER!")
    CounterMakeHUDVisible(false)
    CounterUseMeter(false)
    PlayerWeaponHudLock(false)
    CameraAllowChange(true)
    CameraReturnToPlayer()
end

function DamageEarnest()
    PedApplyDamage(Earnest, nEarnestDamage)
    --print("APPLYING DAMAGE TO EARNEST")
end

function F_SpeakerBroken()
    SpeakerCount = SpeakerCount + 1
end

function F_SetupSpeakerTable()
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker04",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker07",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker06",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker05",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker03",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker02",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker01",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Speaker",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Amp01",
        id = nil
    })
    table.insert(SpeakerTable, {
        name = "isc_audt_Aud_Amp",
        id = nil
    })
    SetNumberOfHandledHashEventObjects(10)
    for i, key in SpeakerTable do
        SpeakerTable[i].id = ObjectNameToHashID(SpeakerTable[i].name)
        RegisterHashEventHandler(SpeakerTable[i].id, 3, F_SpeakerBroken)
    end
end

function F_PlayerGotThingyNIS()
    bMissionSuccess = true
    GiveWeaponToPlayer(306, false)
    MissionObjectiveRemove(MissionObj2)
    AreaDisableCameraControlForTransition(true)
    for i, entry in SeatedTable do
        if PedIsValid(entry.handle) then
            PedMakeAmbient(entry.handle)
        end
    end
    AreaLoadSpecialEntities("vote", false)
    AreaTransitionPoint(2, POINTLIST._1_09_ENDTRANS, nil, true)
    while not (not AreaGetVisible() ~= 2 or shared.gAreaDATFileLoaded[32]) do
        Wait(0)
    end
    CameraSetXYZ(-619.96576, -297.0955, 6.551377, -619.3802, -296.2915, 6.654239)
    CameraSetWidescreen(true)
    SoundStopInteractiveStream(0)
    CameraFade(500, 1)
    Wait(501)
    PedSetWeaponNow(gPlayer, 306, 1, false)
    Wait(1)
    PedSetActionNode(gPlayer, "/Global/1_09/PlayerPickupSlingshot", "Act/Conv/1_09.act")
    MinigameSetCompletion("M_PASS", true, 1000)
    MinigameAddCompletionMsg("MRESPECT_JM5", 1)
    SoundPlayMissionEndMusic(true, 10)
    Wait(2000)
    MinigameSetCompletion("M_PASS", true, 0)
    Wait(1000)
    MinigameSetCompletion("M_PASS", true, 0, "1_09_UNLOCK")
    MinigameAddCompletionMsg("MRESPECT_NP5", 2)
    SetFactionRespect(1, 70)
    SetFactionRespect(2, 45)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    CameraReset()
    CameraReturnToPlayer()
    PedDestroyWeapon(gPlayer, 303)
    F_MakePlayerSafeForNIS(false)
    MissionSucceed(false, false, false)
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
end

function F_JockTaunt()
    while SpeechOn do
        Wait(math.random(nSpeechLow, nSpeechHigh) * 1000)
        F_PlayRandomSpeech(tblRandomSpeech, SeatedTable)
        if shared.g109Nerd then
            F_PlayRandomSpeech(tblNerdSpeech, SeatedTable)
            shared.g109Nerd = false
        end
    end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    local skip = false
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while not (not SoundSpeechPlaying() or skip) do
            Wait(0)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while not (not SoundSpeechPlaying() or skip) do
            Wait(0)
        end
    end
    return skip
end

function F_PlayRandomSpeech(speechTable, tableSeated)
    local choice = math.random(1, table.getn(speechTable))
    local model = speechTable[choice].model
    local event = speechTable[choice].event
    local comment = speechTable[choice].comment
    if event == nil then
        event = "M_1_09"
    end
    for i, entry in tableSeated do
        if PedIsModel(entry.handle, model) then
            SoundPlayScriptedSpeechEvent(entry.handle, event, comment, nJockVolume)
            break
        end
    end
end
