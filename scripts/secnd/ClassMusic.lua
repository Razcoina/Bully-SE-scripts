local missionSuccess = false
local missionFailed = true
local prefect
local gGetReadyText = "MC_GETREADY"
local camerasTable = {}
local bStageLoaded = false
local nCurrentClass = -1
local InstrumentIndex = 1
local gClassPassede = false
local ActionAnimFile
local animsroot = "/Global/MGMusic/Animations/Jimmy/"
local tblMasterAnim = {}
local cMissed = 4
local tblInstrument = {
    "CowBell",
    "Maracas",
    "Timpani",
    "Snare",
    "Xylophone"
}
local musicTeach, gCamTimer
local gCurrentCam = 1
local bCamActive = false
local TeacherFaceIndex = 2
local TeacherFaceCounter = 0
local TeacherRoot = "/Global/MGMusic/Animations/Teacher/"
local TeacherFace = {
    "Face/facial1",
    "Face/facial2",
    "Face/facial3"
}
local MusicTecherIntroTime = {
    { 1, 6000 },
    { 2, 4000 },
    { 3, 9000 },
    { 4, 10000 },
    { 5, 9000 },
    { 5, 9000 }
}
nSongIndex = 0

function SetMusicTrack()
    local SongTable = {
        "MS_MusicClass_Turkey.rsm",
        "Ms_MusicClass_MasterP.rsm",
        "MS_MusicClass_Coming.rsm",
        "MS_MusicClass_Liberty.rsm",
        "MS_MusicClass_Washing.rsm"
    }
    if nCurrentClass == 6 then
        nSongIndex = math.random(1, 5)
        ClassMusicSetSong(SongTable[nSongIndex], 1)
    else
        nSongIndex = nCurrentClass
        ClassMusicSetSong(SongTable[nSongIndex], 1)
    end
end

function F_SetDifficulty()
    local tCowbells = {
        "TURKEY_COWBELL.scn",
        "MASTER_COWBELL.scn",
        "COMING_COWBELL.scn",
        "LIBERTY_COWBELL.scn",
        "WASHING_COWBELL.scn"
    }
    local tMaracas = {
        "TURKEY_MARACAS.scn",
        "MASTER_MARACAS.scn",
        "COMING_MARACAS.scn",
        "LIBERTY_MARACAS.scn",
        "WASHING_MARACAS.scn"
    }
    local tTimpanis = {
        "TURKEY_TIMPANI.scn",
        "MASTER_TIMPANI.scn",
        "COMING_TIMPANI.scn",
        "LIBERTY_TIMPANI.scn",
        "WASHING_TIMPANI.scn"
    }
    local tSnares = {
        "TURKEY_SNARE.scn",
        "MASTER_SNARE.scn",
        "COMING_SNARE.scn",
        "LIBERTY_SNARE.scn",
        "WASHING_SNARE.scn"
    }
    local tXylophones = {
        "TURKEY_XYLOPHONE.scn",
        "MASTER_XYLOPHONE.scn",
        "COMING_XYLOPHONE.scn",
        "LIBERTY_XYLOPHONE.scn",
        "WASHING_XYLOPHONE.scn"
    }
    if nCurrentClass == 6 then
        InstrumentIndex = math.random(1, 5)
    else
        InstrumentIndex = nCurrentClass
    end
    if InstrumentIndex == 1 then
        SoundLoadBank("MINIGAME\\COWBELL_01.bnk")
        ClassMusicInstrument(1, tCowbells[nSongIndex])
        GeometryInstance("x_cowbell", false, -533.534, 317.355, -1.945)
        GeometryInstance("drumstick_l", false, -533.284, 317.876, -3.214)
        GeometryInstance("drumstick_r", false, -533.402, 317.876, -3.214)
        PedSetActionNode(gPlayer, animsroot .. "Sticks/DrumSticks", ActionAnimFile)
        if nCurrentClass ~= 6 then
            gUnlockText = "MC_Unlock01"
            gGrade = 1
        end
    elseif InstrumentIndex == 2 then
        SoundLoadBank("MINIGAME\\MARACAS_01.bnk")
        ClassMusicInstrument(1, tMaracas[nSongIndex])
        GeometryInstance("maracas_r", false, -534.308, 317.876, -3.21369)
        GeometryInstance("maracas_l", false, -534.426, 317.876, -3.21369)
        PedSetActionNode(gPlayer, animsroot .. "Sticks/Maracas", ActionAnimFile)
        if nCurrentClass ~= 6 then
            gUnlockText = "MC_Unlock02"
            gGrade = 2
        end
    elseif InstrumentIndex == 3 then
        if nSongIndex == 1 then
            SoundLoadBank("MINIGAME\\TIMPANI_003.bnk")
        end
        if nSongIndex == 2 then
            SoundLoadBank("MINIGAME\\TIMPANI_001.bnk")
        end
        if nSongIndex == 3 then
            SoundLoadBank("MINIGAME\\TIMPANI_002.bnk")
        end
        if nSongIndex == 4 then
            SoundLoadBank("MINIGAME\\TIMPANI_004.bnk")
        end
        if nSongIndex == 5 then
            SoundLoadBank("MINIGAME\\TIMPANI_005.bnk")
        end
        ClassMusicInstrument(1, tTimpanis[nSongIndex])
        GeometryInstance("x_Timpani", false, -533.586, 317.355, -1.945)
        GeometryInstance("timstick_r", false, -533.611, 317.876, -3.21369)
        GeometryInstance("timstick_l", false, -533.729, 317.876, -3.21369)
        PedSetActionNode(gPlayer, animsroot .. "Sticks/Timpani", ActionAnimFile)
        if nCurrentClass ~= 6 then
            gUnlockText = "MC_Unlock03"
            gGrade = 3
        end
    elseif InstrumentIndex == 4 then
        SoundLoadBank("MINIGAME\\SNARE_01.bnk")
        ClassMusicInstrument(1, tSnares[nSongIndex])
        GeometryInstance("x_snaredrum", false, -533.562, 317.313, -1.945)
        GeometryInstance("drumstick_l", false, -533.284, 317.876, -3.214)
        GeometryInstance("drumstick_r", false, -533.402, 317.876, -3.214)
        PedSetActionNode(gPlayer, animsroot .. "Sticks/DrumSticks", ActionAnimFile)
        if nCurrentClass ~= 6 then
            gUnlockText = "MC_Unlock04"
            gGrade = 4
        end
    elseif InstrumentIndex == 5 then
        SoundLoadBank("MINIGAME\\XYLO_01a.bnk")
        SoundLoadBank("MINIGAME\\XYLO_01b.bnk")
        SoundLoadBank("MINIGAME\\XYLO_01c.bnk")
        ClassMusicInstrument(1, tXylophones[nSongIndex])
        GeometryInstance("x_xylophone", false, -533.562, 317.18, -1.945)
        GeometryInstance("xylostick_r", false, -533.959, 317.876, -3.21369)
        GeometryInstance("xylostick_l", false, -534.077, 317.876, -3.21369)
        PedSetActionNode(gPlayer, animsroot .. "Sticks/xylophone", ActionAnimFile)
        if nCurrentClass ~= 6 then
            gUnlockText = "MC_Unlock05"
            gGrade = 5
        end
    end
end

function F_ToggleHUDItems(b_on)
    ToggleHUDComponentVisibility(4, b_on)
    ToggleHUDComponentVisibility(5, b_on)
    ToggleHUDComponentVisibility(11, b_on)
    ToggleHUDComponentVisibility(0, b_on)
end

function MissionSetup()
    MissionDontFadeIn()
    PlayerSetControl(0)
    HUDSaveVisibility()
    HUDClearAllElements()
    ToggleHUDComponentVisibility(42, true)
    DATLoad("ClassMusic.DAT", 2)
    DATLoad("CLASSLOC.DAT", 2)
    DATInit()
    PlayerSetMinPunishmentPoints(0)
    Wait(2)
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    SoundDisableSpeech_ActionTree()
    F_ToggleHUDItems(false)
    LoadAnimationGroup("UBO")
    LoadAnimationGroup("NPC_Spectator")
    LoadAnimationGroup("Drumming")
    LoadAnimationGroup("WeaponUnlock")
    LoadAnimationGroup("MINI_REACT")
    ActionAnimFile = "Act/Conv/MGMusic.act"
    LoadActionTree(ActionAnimFile)
    LoadActionTree("Act/Conv/ClassMusic.act")
    PedRequestModel(249)
    PedRequestModel(70)
    PedRequestModel(74)
    WeaponRequestModel(439)
    WeaponRequestModel(443)
    WeaponRequestModel(444)
    WeaponRequestModel(440)
    SoundEnableInteractiveMusic(false)
    AreaTransitionPoint(15, POINTLIST._CM_JIMMYSTART, nil, true)
    GeometryInstance("x_cowbell", true, -533.534, 317.355, -1.945)
    GeometryInstance("x_snaredrum", true, -533.562, 317.313, -1.945)
    GeometryInstance("x_Timpani", true, -533.586, 317.355, -1.945)
    GeometryInstance("x_xylophone", true, -533.562, 317.18, -1.945)
    GeometryInstance("x_cowbell_2p", true, -536.534, 317.355, -1.945)
    GeometryInstance("x_snaredrum_2p", true, -536.562, 317.313, -1.945)
    GeometryInstance("x_Timpani_2p", true, -536.586, 317.355, -1.945)
    GeometryInstance("x_xylophone_2p", true, -536.562, 317.18, -1.945)
    GeometryInstance("drumstick_l", true, -533.284, 317.876, -3.214)
    GeometryInstance("drumstick_r", true, -533.402, 317.876, -3.214)
    GeometryInstance("timstick_r", true, -533.611, 317.876, -3.21369)
    GeometryInstance("timstick_l", true, -533.729, 317.876, -3.21369)
    GeometryInstance("xylostick_r", true, -533.959, 317.876, -3.21369)
    GeometryInstance("xylostick_l", true, -534.077, 317.876, -3.21369)
    GeometryInstance("maracas_r", true, -534.308, 317.876, -3.21369)
    GeometryInstance("maracas_l", true, -534.426, 317.876, -3.21369)
    GeometryInstance("drumstick_2r", true, -535.594, 317.876, -3.21369)
    GeometryInstance("drumstick_2l", true, -535.476, 317.876, -3.21369)
    GeometryInstance("timstick_2r", true, -535.804, 317.876, -3.21369)
    GeometryInstance("timstick_2l", true, -535.922, 317.876, -3.21369)
    GeometryInstance("xylostick_2r", true, -536.151, 317.876, -3.21369)
    GeometryInstance("xylostick_2l", true, -536.269, 317.876, -3.21369)
    GeometryInstance("maracas_2r", true, -536.501, 317.876, -3.21369)
    GeometryInstance("maracas_2l", true, -536.619, 317.876, -3.21369)
    MinigameCreate("MUSIC", false)
    while not MinigameIsReady() do
        Wait(0)
    end
end

function MissionCleanup()
    HUDRestoreVisibility()
    SoundRestartPA()
    SoundEnableInteractiveMusic(true)
    PlayerWeaponHudLock(false)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundFadeoutStream()
    PedSetWeaponNow(gPlayer, MODELENUM._NOWEAPON, 0)
    Wait(10)
    MinigameDestroy()
    SoundStopStream()
    SoundEnableSpeech_ActionTree()
    F_ToggleHUDItems(true)
    F_MakePlayerSafeForNIS(false)
    PedDelete(musicTeach)
    SoundUnLoadBank("MINIGAME\\COWBELL_01.bnk")
    SoundUnLoadBank("MINIGAME\\MARACAS_01.bnk")
    SoundUnLoadBank("MINIGAME\\TIMPANI_01.bnk")
    SoundUnLoadBank("MINIGAME\\SNARE_01.bnk")
    SoundUnLoadBank("MINIGAME\\XYLO_01a.bnk")
    SoundUnLoadBank("MINIGAME\\XYLO_01b.bnk")
    SoundUnLoadBank("MINIGAME\\XYLO_01c.bnk")
    PedSetActionNode(gPlayer, animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
    UnLoadAnimationGroup("Drumming")
    UnLoadAnimationGroup("UBO")
    UnLoadAnimationGroup("NPC_Spectator")
    UnLoadAnimationGroup("WeaponUnlock")
    UnLoadAnimationGroup("MINI_REACT")
    CameraSetWidescreen(false)
    CameraDefaultFOV()
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetPunishmentPoints(0)
    PedClearObjectives(gPlayer)
    PedStop(gPlayer)
    AreaTransitionPoint(2, POINTLIST._CM_JIMMYEND)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    while not AreaGetVisible() == 2 do
        Wait(0)
    end
    CameraFade(1000, 1)
    Wait(1000)
    if missionSuccess then
        if nCurrentClass == 1 then
            ClothingGivePlayer("SP_MusicShirt", 1)
        elseif nCurrentClass == 2 then
            ClothingGivePlayer("SP_Bandshirt", 1)
        elseif nCurrentClass == 3 then
            ClothingGivePlayer("SP_MusicPJ_T", 1)
            ClothingGivePlayer("SP_MusicPJ_L", 4)
        elseif nCurrentClass == 4 then
            ClothingGivePlayerOutfit("Marching Band")
        elseif nCurrentClass == 5 then
            ClothingGivePlayerOutfit("80 Rocker")
        end
        SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
        PedSetActionNode(gPlayer, animsroot .. "Success", ActionAnimFile)
        if gUnlockText ~= nil then
            MinigameSetCompletion("MEN_BLANK", true, 0, gUnlockText)
        end
    end
    TutorialRemoveMessage()
    PedSetFlag(gPlayer, 128, false)
    PlayerSetControl(1)
    DATUnload(2)
end

function main()
    while not bStageLoaded do
        Wait(0)
    end
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    F_MakePlayerSafeForNIS(true)
    if F_CheckIfPrefect() then
        CameraFade(1000, 0)
        Wait(1000)
    end
    musicTeach = PedCreatePoint(249, POINTLIST._CM_TEACHERSPEAK)
    Student01 = PedCreatePoint(70, POINTLIST._CM_STUDENT01)
    Student02 = PedCreatePoint(74, POINTLIST._CM_STUDENT02)
    Wait(200)
    PedSetActionNode(musicTeach, TeacherRoot .. "CustomIdleEnter", ActionAnimFile)
    PedFollowPath(Student01, PATH._CM_PSTUDENT01, 0, 0)
    Wait(2000)
    PedFollowPath(Student02, PATH._CM_PSTUDENT02, 0, 0)
    CameraSetWidescreen(true)
    CameraSetFOV(60)
    local fx, fy, fz = GetPointList(POINTLIST._CM_TEACHERSPEAK)
    CameraLookAtXYZ(fx, fy, fz + 1, true)
    CameraSetPath(PATH._CM_CAMTEACHER, true)
    CameraSetSpeed(0.2, 0.2, 0.2)
    Wait(500)
    PedFaceHeading(musicTeach, 0, 0)
    PedFollowPath(gPlayer, PATH._CM_JIMMYWALKIN, 0, 0)
    CameraFade(500, 1)
    Wait(500)
    SoundStopCurrentSpeechEvent(musicTeach)
    --DebugPrint(" ****************************  Song Index == " .. nCurrentClass)
    SoundPlayScriptedSpeechEvent(musicTeach, "ClassMusic", MusicTecherIntroTime[nCurrentClass][1], "jumbo", true)
    Wait(MusicTecherIntroTime[nCurrentClass][2])
    CameraFade(500, 0)
    Wait(500)
    PedClearObjectives(gPlayer)
    PedStop(gPlayer)
    Wait(10)
    tblMasterAnim = {
        {
            Anim = animsroot .. "Right/" .. tblInstrument[InstrumentIndex],
            cams = nil
        },
        {
            Anim = animsroot .. "Left/" .. tblInstrument[InstrumentIndex],
            cams = nil
        },
        {
            Anim = animsroot .. "BothHands/" .. tblInstrument[InstrumentIndex] .. "/Hit",
            cams = nil
        },
        {
            Anim = animsroot .. "BothHands/" .. tblInstrument[InstrumentIndex] .. "/Missed",
            cams = nil
        }
    }
    PedSetPosPoint(musicTeach, POINTLIST._CM_TEACHER)
    PedSetPosPoint(gPlayer, POINTLIST._CM_JIMMYSTAND)
    Wait(100)
    PedFaceHeading(gPlayer, 0, 0)
    PedFaceHeading(musicTeach, 45, 0)
    PedDelete(Student01)
    PedDelete(Student02)
    SetMusicTrack()
    F_SetDifficulty()
    PedSetActionNode(musicTeach, TeacherRoot .. "CustomIdleEnter", ActionAnimFile)
    PedSetActionNode(gPlayer, animsroot .. "CustomIdle", ActionAnimFile)
    Wait(500)
    CameraSetWidescreen(false)
    CameraSetXYZ(-534.4892, 318.94156, -0.448955, -533.937, 318.11575, -0.563465)
    CameraSetFOV(60)
    local fx, fy, fz = GetPointList(POINTLIST._CM_CAMPOINT01)
    CameraLookAtXYZ(fx, fy, fz, true)
    CameraSetWidescreen(false)
    MinigameStart()
    ClassMusicSetPlayers(1)
    MinigameEnableHUD(true)
    CameraFade(500, 1)
    Wait(550)
    TextPrint(gGetReadyText, 2, 1)
    Wait(2000)
    TextPrint("MC_BEGIN", 1, 1)
    Wait(1000)
    ClassMusicFeedbackCallback(F_ActionsCallback)
    ClassMusicStartSeq(nCurrentClass)
    bCamActive = false
    gCurrentCam = 1
    CameraSetPath(PATH._CM_CAMPATH01, false)
    CameraSetSpeed(0.2, 0.2, 0.2)
    PedSetActionNode(musicTeach, TeacherRoot .. "CustomIdle", ActionAnimFile)
    Wait(1500)
    while MinigameIsActive() do
        F_CM_SwitchCamera()
        Wait(0)
    end
    Wait(1000)
    CameraFade(500, 0)
    Wait(500)
    CameraReset()
    CameraReturnToPlayer()
    PedSetActionNode(musicTeach, TeacherRoot .. "CustomIdleEnter", ActionAnimFile)
    PedSetActionNode(gPlayer, animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
    Wait(10)
    CameraSetXYZ(-533.64526, 319.03046, -0.56863, -533.6358, 318.03464, -0.659398)
    CameraSetFOV(60)
    F_CleanPrefect()
    CameraFade(-1, 1)
    if MinigameIsSuccess() then
        local iWinner, iScore = ClassMusicGetWinner()
        if iWinner == 0 then
            if not bIsRepeatable then
                PlayerSetGrade(9, gGrade)
                if nCurrentClass < 5 then
                    SoundStopCurrentSpeechEvent(musicTeach)
                    SoundPlayScriptedSpeechEvent(musicTeach, "ClassMusic", nCurrentClass + 5, "jumbo", true)
                end
                MinigameSetGrades(9, gGrade - 1)
                SoundFadeoutStream()
                SoundPlayMissionEndMusic(true, 9)
                while MinigameIsShowingGrades() do
                    Wait(0)
                end
                Wait(1000)
            else
                SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
                PedSetActionNode(gPlayer, animsroot .. "Success", ActionAnimFile)
                Wait(2000)
            end
            missionSuccess = true
        else
            if not bIsRepeatable then
                MinigameSetGrades(9, gGrade - 1)
                PedSetActionNode(gPlayer, animsroot .. "Failure", ActionAnimFile)
                SoundFadeoutStream()
                SoundPlayMissionEndMusic(false, 9)
                F_TeacherSayFail()
                while MinigameIsShowingGrades() do
                    Wait(0)
                end
            else
                PedSetActionNode(gPlayer, animsroot .. "Failure", ActionAnimFile)
                Wait(2000)
            end
            missionFailed = true
        end
    else
        if not bIsRepeatable then
            MinigameSetGrades(9, gGrade - 1)
            PedSetActionNode(gPlayer, animsroot .. "Failure", ActionAnimFile)
            SoundFadeoutStream()
            SoundPlayMissionEndMusic(false, 9)
            F_TeacherSayFail()
            while MinigameIsShowingGrades() do
                Wait(0)
            end
        else
            Wait(2000)
        end
        missionFailed = true
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if missionSuccess then
        if nCurrentClass == 5 then
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
            PedClearObjectives(musicTeach)
            PedStop(musicTeach)
            PedSetPosPoint(musicTeach, POINTLIST._CM_TEACHERSPEAK)
            PedFaceHeading(musicTeach, 60, 0)
            CameraSetWidescreen(true)
            CameraSetFOV(60)
            local fx, fy, fz = GetPointList(POINTLIST._CM_TEACHERSPEAK)
            CameraLookAtXYZ(fx, fy, fz + 1, true)
            CameraSetPath(PATH._CM_CAMTEACHER02, true)
            CameraSetSpeed(0.2, 0.2, 0.2)
            Wait(500)
            CameraFade(500, 1)
            Wait(500)
            SoundStopCurrentSpeechEvent(musicTeach)
            SoundPlayScriptedSpeechEvent(musicTeach, "ClassMusic", nCurrentClass + 5, "jumbo", true)
            Wait(8000)
        end
        CameraFade(500, 0)
        Wait(500)
        MissionSucceed(false, false, false)
    else
        if missionFailed == true then
            PedSetActionNode(gPlayer, "/Global/MGMusic/Animations/Failure", ActionAnimFile)
            SoundPlayMissionEndMusic(false, 10)
        end
        MissionFail(true, false)
        Wait(1000)
        CameraFade(500, 0)
        Wait(500)
        CameraSetWidescreen(false)
    end
    Wait(1000)
end

function PickRandom(tbl)
    if type(tbl) ~= "table" then
        --DebugPrint("PickRandom tbl~=table")
        return nil
    end
    if table.getn(tbl) <= 0 then
        --DebugPrint("PickRandom tbl.size=0")
        return nil
    end
    return tbl[math.random(1, table.getn(tbl))]
end

function F_CM_SwitchCamera()
    if bCamActive == false then
        gCamTimer = GetTimer()
        bCamActive = true
    end
    if GetTimer() - gCamTimer > 30000 then
        if gCurrentCam == 1 then
            CameraSetPath(PATH._CM_CAMPATH02, false)
            gCurrentCam = 2
        else
            CameraSetPath(PATH._CM_CAMPATH01, false)
            gCurrentCam = 1
        end
        CameraSetSpeed(0.2, 0.2, 0.2)
        bCamActive = false
    end
end

local TeacherSayCount = 0

function F_ActionsCallback(cPIndex, iAction, sNote, bPassed, ActionState)
    --DebugPrint("F_ActionsCallback(): pass:" .. tostring(bPassed))
    if iAction ~= 0 then
        if bPassed then
            if tblMasterAnim[iAction].Anim then
                PedSetActionNode(gPlayer, tblMasterAnim[iAction].Anim, ActionAnimFile)
            end
            TeacherSayCount = TeacherSayCount + 1
            if 5 <= TeacherSayCount then
                --DebugPrint("***************Teacher Index Happy****************** " .. TeacherFaceIndex)
                TeacherSayCount = 0
                if 1 < TeacherFaceIndex then
                    TeacherFaceIndex = TeacherFaceIndex - 1
                end
                PedSetActionNode(musicTeach, TeacherRoot .. TeacherFace[TeacherFaceIndex], ActionAnimFile)
            end
            if sNote ~= "NONE" then
                if InstrumentIndex == 3 then
                    print("******************************* Soft **************************************")
                    if iAction == 1 then
                        SoundPlay2D("TIMP_LEFT_S")
                    elseif iAction == 2 then
                        SoundPlay2D("TIMP_RIGHT_S")
                    else
                        SoundPlay2D("TIMP_BOTH_H")
                    end
                elseif InstrumentIndex == 4 then
                    if iAction == 1 then
                        SoundPlay2D("SNARE_LEFT_S")
                    elseif iAction == 2 then
                        SoundPlay2D("SNARE_RIGHT_S")
                    else
                        SoundPlay2D("SNARE_BOTH_H")
                    end
                else
                    SoundPlay2D(sNote)
                end
            elseif InstrumentIndex == 1 then
                if iAction == 1 then
                    SoundPlay2D("COWBELL_LEFT_H")
                elseif iAction == 2 then
                    SoundPlay2D("COWBELL_RIGHT_H")
                else
                    SoundPlay2D("COWBELL_BOTH_H")
                end
            elseif InstrumentIndex == 2 then
                if iAction == 1 then
                    --DebugPrint(" I got a sound F" .. sNote)
                    SoundPlay2D("MARACAS_LEFT_H")
                elseif iAction == 2 then
                    SoundPlay2D("MARACAS_RIGHT_H")
                else
                    SoundPlay2D("MARACAS_BOTH_H")
                end
            elseif InstrumentIndex == 3 then
                print("******************************* Hard **************************************")
                if iAction == 1 then
                    SoundPlay2D("TIMP_LEFT_H")
                elseif iAction == 2 then
                    SoundPlay2D("TIMP_RIGHT_H")
                else
                    SoundPlay2D("TIMP_BOTH_H")
                end
            elseif InstrumentIndex == 4 then
                if iAction == 1 then
                    SoundPlay2D("SNARE_LEFT_H")
                elseif iAction == 2 then
                    SoundPlay2D("SNARE_RIGHT_H")
                else
                    SoundPlay2D("SNARE_BOTH_H")
                end
            end
        elseif ActionState < 6 then
            if InstrumentIndex == 1 then
                SoundPlay2D("COWBELL_MISTAKE")
            elseif InstrumentIndex == 2 then
                SoundPlay2D("MARACAS_MISTAKE")
            elseif InstrumentIndex == 3 then
                SoundPlay2D("TIMP_MISTAKE")
            elseif InstrumentIndex == 4 then
                SoundPlay2D("SNARE_MISTAKE")
            elseif InstrumentIndex == 5 then
                SoundPlay2D("MISTAKE")
            end
            --DebugPrint("*************** Teacher Index  Sad ****************** " .. TeacherFaceIndex)
            if TeacherFaceIndex < 3 then
                TeacherFaceIndex = TeacherFaceIndex + 1
            end
            PedSetActionNode(musicTeach, TeacherRoot .. TeacherFace[TeacherFaceIndex], ActionAnimFile)
            F_TeacherSayBad()
        end
    end
end

function F_SetStage(param)
    nCurrentClass = param
    bStageLoaded = true
end

function F_SetStageRepeatable(param)
    nCurrentClass = param
    bStageLoaded = true
    bIsRepeatable = true
end

local gSpeechPlayed = false
local gSpeechMissesPlayed = false
local gSpeechTimer = 0

function F_TeacherSayGood()
    if gSpeechPlayed == false and gSpeechMissesPlayed == false then
        --DebugPrint(" Hit Teacher Speak ************************************** ")
        SoundStopCurrentSpeechEvent(musicTeach)
        SoundPlayScriptedSpeechEvent(musicTeach, "ClassMusic", 6, "jumbo", true)
        gSpeechPlayed = true
        gSpeechTimer = GetTimer()
    elseif GetTimer() - gSpeechTimer > 5000 then
        gSpeechPlayed = false
        gSpeechMissesPlayed = false
    end
end

function F_TeacherSayBad()
    --DebugPrint(" Missed Hit Teacher Speak ************************************** ")
    if gSpeechMissesPlayed == false then
        SoundStopCurrentSpeechEvent(musicTeach)
        SoundPlayScriptedSpeechEvent(musicTeach, "ClassMusic", 12, "jumbo", true)
        gSpeechMissesPlayed = true
        gSpeechTimer = GetTimer()
    elseif GetTimer() - gSpeechTimer > 2000 then
        gSpeechMissesPlayed = false
    end
end

function F_TeacherSayFail()
    --DebugPrint(" Missed Hit Teacher Speak ************************************** ")
    SoundStopCurrentSpeechEvent(musicTeach)
    SoundPlayScriptedSpeechEvent(musicTeach, "ClassMusic", 11, "jumbo", true)
end

function F_CheckIfPrefect()
    if shared.bBustedClassLaunched then
        local prefectModels = {
            49,
            50,
            51,
            52
        }
        local prefectModel = prefectModels[math.random(1, 4)]
        LoadModels({ prefectModel })
        prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
        PedStop(prefect)
        PedClearObjectives(prefect)
        PedIgnoreStimuli(prefect, true)
        PedFaceObject(gPlayer, prefect, 2, 0)
        PedFaceObject(prefect, gPlayer, 3, 1, false)
        PedSetInvulnerable(prefect, true)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraSetXYZ(-534.2069, 319.03763, 0.650509, -535.13385, 318.75516, 0.403447)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C9/PlayerFail", "Act/Conv/C9.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C9/Release", "Act/Conv/C9.act")
        shared.bBustedClassLaunched = false
        return true
    end
    return false
end

function F_CleanPrefect()
    if prefect and PedIsValid(prefect) then
        PedDelete(prefect)
    end
end
