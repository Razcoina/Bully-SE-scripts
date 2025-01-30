--[[ Changes to this file:
    * Removed unused local variables
    * Modified function SetPlayerInstrument, may require testing
    * Modified function MissionSetup, may require testing
    * Modified function MissionCleanup, may require testing
    * Modified function main, may require testing
    * Heavily modified function F_3_01A_SwitchCamera, requires testing
    * Removed function T_StartCam03, not present in original script
    * Heavily modified function F_ActionsCallback, requires testing
]]

local NutDebugSet = false
local missionSuccess = false
local gGetReadyText = "3_01C_GETREADY"
local Players = {}
Players[0] = {}
Players[1] = {}
local ActionAnimFile
local animsroot = "/Global/MGMusic/Animations/"
local tblMasterAnim = {}
local tblInstrument = {
    "CowBell",
    "Maracas",
    "Timpani",
    "Snare",
    "Xylophone"
}
local musicTeach
local SongIndex = 0
local gCamTimer
local gCurrentCam = 1
local bCamActive = false
local InstrumentIndex = {}
InstrumentIndex[0] = 5
InstrumentIndex[1] = 3

function SetMusicTrack()
    local SongTable = {}
    if NutDebugSet then
        SongTable = { "Dummy.rsm" }
    else
        SongTable = {
            "ms_musicclass_Carols01.rsm"
        }
    end
    SongIndex = 1
    ClassMusicSetSong(SongTable[SongIndex], 1)
end

function SetPlayerInstrument(PlayerIndex) -- ! Modified
    local tCowbells = {
        "CAROLS_COWBELL.scn"
    }
    local tMaracas = {
        "CAROLS_MARACAS.scn"
    }
    local tTimpanis = {
        "CAROLS_TIMPANI.scn"
    }
    local tSnares = {
        "CAROLS_SNARE.scn"
    }
    local tXylophones = {
        "CAROLS_XYLOPHONE.scn"
    }
    if InstrumentIndex[PlayerIndex] == 1 then
        SoundLoadBank("MINIGAME\\COWBELL_01.bnk") -- Added this
        ClassMusicInstrument(PlayerIndex + 1, tCowbells[SongIndex])
    elseif InstrumentIndex[PlayerIndex] == 2 then
        SoundLoadBank("MINIGAME\\MARACAS_01.bnk") -- Added this
        ClassMusicInstrument(PlayerIndex + 1, tMaracas[SongIndex])
    elseif InstrumentIndex[PlayerIndex] == 3 then
        SoundLoadBank("MINIGAME\\TIMPANI_01.bnk") -- Added this
        ClassMusicInstrument(PlayerIndex + 1, tTimpanis[SongIndex])
    elseif InstrumentIndex[PlayerIndex] == 4 then
        SoundLoadBank("MINIGAME\\SNARE_01.bnk") -- Added this
        ClassMusicInstrument(PlayerIndex + 1, tSnares[SongIndex])
    elseif InstrumentIndex[PlayerIndex] == 5 then
        SoundLoadBank("MINIGAME\\XYLO_01a.bnk") -- Added this
        SoundLoadBank("MINIGAME\\XYLO_01b.bnk") -- Added this
        SoundLoadBank("MINIGAME\\XYLO_01c.bnk") -- Added this
        ClassMusicInstrument(PlayerIndex + 1, tXylophones[SongIndex])
    end
    SoundLoadBank("Clapping\\Claps.bnk") -- Added this
    Players[PlayerIndex].AnimList = {
        {
            Anim = Players[PlayerIndex].Animsroot .. "Right/" .. tblInstrument[InstrumentIndex[PlayerIndex]]
        },
        {
            Anim = Players[PlayerIndex].Animsroot .. "Left/" .. tblInstrument[InstrumentIndex[PlayerIndex]]
        },
        {
            Anim = Players[PlayerIndex].Animsroot .. "BothHands/" .. tblInstrument[InstrumentIndex[PlayerIndex]] .. "/Hit"
        },
        {
            Anim = Players[PlayerIndex].Animsroot .. "BothHands/" .. tblInstrument[InstrumentIndex[PlayerIndex]] .. "/Missed",
            cams = nil
        }
    }
end

function F_ToggleHUDItems(b_on)
    ToggleHUDComponentVisibility(4, b_on)
    ToggleHUDComponentVisibility(5, b_on)
    ToggleHUDComponentVisibility(11, b_on)
    ToggleHUDComponentVisibility(0, b_on)
end

function MissionSetup() -- ! Modified
    MissionDontFadeIn()
    DATLoad("3_01C.DAT", 2)
    DATLoad("ClassMusic.DAT", 2) -- Added this
    DATInit()
    PlayerSetControl(0)
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
    SoundDisableSpeech_ActionTree()
    HUDSaveVisibility()
    HUDClearAllElements()
    ToggleHUDComponentVisibility(42, true)
    F_ToggleHUDItems(false)
    LoadAnimationGroup("Drumming")
    LoadAnimationGroup("Pageant")
    LoadAnimationGroup("UBO")
    LoadAnimationGroup("NPC_Spectator")
    LoadAnimationGroup("MINI_REACT")
    --[[
    SoundLoadBank("MINIGAME\\XYLO_01a.bnk")
    SoundLoadBank("MINIGAME\\XYLO_01b.bnk")
    SoundLoadBank("MINIGAME\\XYLO_01c.bnk")
    SoundLoadBank("WII\\Claps.bnk")
    ]] -- Removed this
    PedRequestModel(249)
    PedRequestModel(257)
    PedRequestModel(256)
    PedRequestModel(255)
    PedRequestModel(258)
    AreaLoadSpecialEntities("nutcracker", true)
    WeaponRequestModel(439)
    WeaponRequestModel(443)
    WeaponRequestModel(444)
    SoundEnableInteractiveMusic(false)
    GeometryInstance("xmas_xylophone", false, -763.996, 308.154, 77.249)
    GeometryInstance("xmas_timpani", false, -762.713, 308.603, 77.249)
    GeometryInstance("xmas_xylostick_r", false, -763.599, 307.457, 74.889)
    GeometryInstance("xmas_xylostick_l", false, -763.481, 307.457, 74.889)
    GeometryInstance("x_cowbell_2p", false, -762.737, 307.457, 74.889)
    GeometryInstance("xmas_timstick_l", false, -762.619, 307.457, 74.889)
    PlayerSetPunishmentPoints(0)
    if AreaGetVisible() ~= 2 then
        AreaTransitionPoint(2, POINTLIST._3_01C_PLAYEREND)
    end
    --[[
    AreaClearAllPeds()
    Wait(1)
    ]] -- Not present in original script
    PlayCutsceneWithLoad("3-01CA", true)
    MinigameCreate("MUSIC", false)
    while not MinigameIsReady() do
        Wait(0)
    end
    ActionAnimFile = "Act/Conv/MGMusic.act"
    LoadActionTree(ActionAnimFile)
    DancerActionFile = "Act/Conv/3_01C.act"
    LoadActionTree(DancerActionFile)
    ClothingBackup()
    ClothingSetPlayerOutfit("Nutcracker")
    ClothingBuildPlayer()
    AreaTransitionPoint(19, POINTLIST._3_01C_PLAYERSTART, nil, true)
end

function MissionCleanup() -- ! Modified
    HUDRestoreVisibility()
    SoundRestartPA()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundEnableInteractiveMusic(true)
    SoundEnableSpeech_ActionTree()
    SoundStopStream()
    CameraReturnToPlayer()
    SoundFadeoutStream()
    F_ToggleHUDItems(true)
    PedSetWeaponNow(Players[0].Player, MODELENUM._NOWEAPON, 0)
    PedSetWeaponNow(Players[1].Player, MODELENUM._NOWEAPON, 0)
    Wait(10)
    MinigameDestroy()
    PlayerWeaponHudLock(false)
    CameraSetWidescreen(false)
    AreaLoadSpecialEntities("nutcracker", false)
    if PedIsValid(musicTeach) then
        PedDelete(musicTeach)
    end
    if PedIsValid(Dancer01) then
        PedDelete(Dancer01)
    end
    if PedIsValid(Dancer02) then
        PedDelete(Dancer02)
    end
    if PedIsValid(Dancer03) then
        PedDelete(Dancer03)
    end
    if PedIsValid(Players[1].Player) then
        PedDelete(Players[1].Player)
    end
    ClothingRestore()
    ClothingBuildPlayer()
    F_MakePlayerSafeForNIS(false)
    if missionSuccess then
        ClothingGivePlayerOutfit("Nutcracker")
        MinigameSetCompletion("MEN_BLANK", true, 0, "TUT_301C")
    end
    AreaTransitionPoint(2, POINTLIST._3_01C_PLAYEREND, nil, true)
    while not AreaGetVisible() == 2 do
        Wait(0)
    end
    CameraFade(1000, 1)
    Wait(1000)
    if missionSuccess then
        SoundPlayMissionEndMusic(true, 10)
        SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
        PedSetActionNode(gPlayer, animsroot .. "Success", ActionAnimFile)
        Wait(2000)
    end
    SoundUnLoadBank("MINIGAME\\COWBELL_01.bnk") -- Added this
    SoundUnLoadBank("MINIGAME\\MARACAS_01.bnk") -- Added this
    SoundUnLoadBank("MINIGAME\\TIMPANI_01.bnk") -- Added this
    SoundUnLoadBank("MINIGAME\\SNARE_01.bnk")   -- Added this
    SoundUnLoadBank("MINIGAME\\XYLO_01a.bnk")
    SoundUnLoadBank("MINIGAME\\XYLO_01b.bnk")
    SoundUnLoadBank("MINIGAME\\XYLO_01c.bnk")
    --[[
    SoundUnLoadBank("WII\\Claps.bnk")
    ]]                                     -- Not present in original script
    SoundUnLoadBank("Clapping\\Claps.bnk") -- Added this
    PlayerSetPunishmentPoints(0)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    PlayerSetControl(1)
    UnLoadAnimationGroup("Drumming")
    UnLoadAnimationGroup("Pageant")
    UnLoadAnimationGroup("UBO")
    UnLoadAnimationGroup("NPC_Spectator")
    UnLoadAnimationGroup("MINI_REACT")
    DATUnload(2)
end

--[[
local bCam3Active = false
]]              -- Not present in original script

function main() -- ! Modified
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayCutsceneWithLoad("3-01CB", true)
    PlayerWeaponHudLock(true)
    PlayerSetControl(0)
    PedSetPosPoint(gPlayer, POINTLIST._3_01C_PLAYERSTART)
    musicTeach = PedCreatePoint(249, POINTLIST._3_01C_MSPETERS)
    Dancer01 = PedCreatePoint(257, POINTLIST._3_01C_DANCER01)
    Dancer02 = PedCreatePoint(256, POINTLIST._3_01C_DANCER02)
    Dancer03 = PedCreatePoint(258, POINTLIST._3_01C_DANCER03)
    Players[0].Player = gPlayer
    Players[1].Player = PedCreatePoint(255, POINTLIST._3_01C_BAND02)
    Players[0].Animsroot = animsroot .. "Jimmy/"
    Players[1].Animsroot = animsroot .. "Gary/"
    F_MakePlayerSafeForNIS(true)
    ClassMusicSetPlayers(3)
    SetMusicTrack()
    SetPlayerInstrument(0)
    SetPlayerInstrument(1)
    MinigameStart()
    MinigameEnableHUD(true)
    PedSetActionNode(Players[0].Player, Players[0].Animsroot .. "Sticks/xylophone", ActionAnimFile)
    PedSetActionNode(Players[1].Player, Players[1].Animsroot .. "Sticks/Timpani", ActionAnimFile)
    Wait(10)
    PedSetActionNode(Players[0].Player, Players[0].Animsroot .. "CustomIdle", ActionAnimFile)
    PedSetActionNode(Players[1].Player, Players[1].Animsroot .. "CustomIdle", ActionAnimFile)
    Wait(100)
    --[[
    CameraSetXYZ(-761.227, 305.409, 78.6611, -761.92865, 305.54236, 78.544655)
    ]] -- Changed to:
    CameraSetXYZ(-761.265, 304.796, 78.6007, -761.92865, 305.54236, 78.544655)
    for i = 0, 1 do
        PedStop(Players[i].Player)
        PedClearObjectives(Players[i].Player)
    end
    PlayerFaceHeading(135, 0)
    local fx, fy, fz = GetPointList(POINTLIST._3_01C_CAMPOINT01)
    CameraLookAtXYZ(fx, fy, fz, true)
    CameraFade(1000, 1)
    Wait(1500)
    TextPrint(gGetReadyText, 2, 1)
    Wait(2000)
    TextPrint("3_01C_BEGIN", 1, 1)
    Wait(1000)
    TutorialRemoveMessage()
    ClassMusicFeedbackCallback(F_ActionsCallback)
    ClassMusicStartSeq(3)
    CameraSetPath(PATH._3_01C_CAMPATH02, false) -- Added this
    gCurrentCam = 2                             -- Changed this value from 3 to 2
    CameraSetSpeed(0.2, 0.2, 0.2)               -- Added this
    bCamActive = false
    PedSetActionNode(Dancer01, "/Global/3_01C/Flower", DancerActionFile)
    PedSetActionNode(Dancer02, "/Global/3_01C/Fairy", DancerActionFile)
    PedSetActionNode(Dancer03, "/Global/3_01C/Flower", DancerActionFile)
    PedSetActionNode(musicTeach, "/Global/MGMusic/Animations/Teacher", ActionAnimFile)
    while MinigameIsActive() do
        --[[
        if not bCam3Active then
            F_3_01A_SwitchCamera()
        end
        ]]                     -- Removed this
        F_3_01A_SwitchCamera() -- Added this
        Wait(0)
    end
    Wait(1000)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if MinigameIsSuccess() then
        local iWinner, iScore = ClassMusicGetWinner()
        if iWinner == 0 then
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
            PedSetActionNode(Players[0].Player, Players[0].Animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
            PedSetActionNode(Players[1].Player, Players[0].Animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
            CameraSetXYZ(-763.4773, 306.53128, 78.49783, -763.7385, 307.49515, 78.55007)
            Wait(10)
            CameraFade(500, 1)
            Wait(500)
            SoundStopInteractiveStream()
            print("*****************************Playing Clapping**************************************")
            SoundPlay2D("Clapping01")
            MinigameSetCompletion("M_PASS", true, 2000)
            SoundPlayMissionEndMusic(true, 10)
            Wait(2500)
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
            missionSuccess = true -- Added this
            MissionSucceed(false, false, false)
        else
            PedSetActionNode(gPlayer, "/Global/MGMusic/Animations/Failure", ActionAnimFile)
            SoundPlayMissionEndMusic(false, 10)
            MissionFail(false, true, "3_01C_FAIL_01")
            Wait(2500)
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
            PedSetActionNode(Players[0].Player, Players[0].Animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
            PedSetActionNode(Players[1].Player, Players[0].Animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
        end
    else
        MissionFail(false, true)
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME)
        PedSetActionNode(Players[0].Player, Players[0].Animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
        PedSetActionNode(Players[1].Player, Players[0].Animsroot .. "Sticks/RemoveSticks", ActionAnimFile)
    end
end

--[[
local CamWaitTime = 5000
]]                              -- Not present in original script

function F_3_01A_SwitchCamera() -- ! Heavily modified
    if bCamActive == false then
        gCamTimer = GetTimer()
        bCamActive = true
    end
    --[[
    if GetTimer() - gCamTimer > CamWaitTime then
        if gCurrentCam == 1 then
            CameraSetPath(PATH._3_01C_CAMPATH04, false)
            gCurrentCam = 2
            CamWaitTime = 12000
            CameraSetSpeed(0.3, 0.3, 0.3)
        elseif gCurrentCam == 2 then
            CameraSetPath(PATH._3_01C_CAMPATH01, false)
            gCurrentCam = 3
            CamWaitTime = 20000
            CameraSetSpeed(0.2, 0.2, 0.2)
        else
            CameraSetPath(PATH._3_01C_CAMPATH02, false)
            gCurrentCam = 1
            CamWaitTime = 10000
            CameraSetSpeed(0.2, 0.2, 0.2)
        end
        CameraSetSpeed(0.2, 0.2, 0.2)
        bCamActive = false
    end
    ]] -- Different from original script
    -- Added the following:
    if 25000 < GetTimer() - gCamTimer then
        if gCurrentCam == 1 then
            CameraSetPath(PATH._3_01C_CAMPATH02, false)
            gCurrentCam = 2
        else
            CameraSetPath(PATH._3_01C_CAMPATH01, false)
            gCurrentCam = 1
        end
        CameraSetSpeed(0.2, 0.2, 0.2)
        bCamActive = false
    end
end

--[[
function T_StartCam03()
    Wait(105000)
    bCam3Active = true
    CameraSetPath(PATH._3_01C_CAMPATH04, false)
    CameraSetSpeed(0.4, 0.4, 0.4)
    Wait(25000)
    CameraSetPath(PATH._3_01C_CAMPATH02, false)
    gCurrentCam = 2
    CameraSetSpeed(0.4, 0.4, 0.4)
    bCamActive = false
    bCam3Active = false
end
]] -- Not present in original script

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

function F_ActionsCallback(cPIndex, iAction, sNote, bPassed, ActionState) -- ! Heavily modified
    --DebugPrint("F_ActionsCallback(): pass:" .. tostring(bPassed))
    if iAction ~= 0 then
        if bPassed then
            if Players[cPIndex].AnimList[iAction].Anim then
                PedSetActionNode(Players[cPIndex].Player, Players[cPIndex].AnimList[iAction].Anim, ActionAnimFile)
            end
            if sNote ~= "NONE" then
                if InstrumentIndex == 3 then
                    print("******************************* Soft **************************************")
                    if iAction == 1 then
                        SoundPlay2D("TIMP_LEFT_S")  -- Added this
                    elseif iAction == 2 then
                        SoundPlay2D("TIMP_RIGHT_S") -- Added this
                    else
                        SoundPlay2D("TIMP_BOTH_S")  -- Added this
                    end
                else
                    --[[
                    SoundPlay2DWii(sNote, 1, 0)
                    ]] -- Not present in original script
                    -- Added the following:
                    if InstrumentIndex == 4 then
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
                end
                -- Added the following (to the end of this else chunk):
            else
                if InstrumentIndex[cPIndex] == 1 then
                    if iAction == 1 then
                        SoundPlay2D("COWBELL_LEFT_H")
                    elseif iAction == 2 then
                        SoundPlay2D("COWBELL_RIGHT_H")
                    else
                        SoundPlay2D("COWBELL_BOTH_H")
                    end
                elseif InstrumentIndex[cPIndex] == 2 then
                    if iAction == 1 then
                        SoundPlay2D("MARACAS_LEFT_H")
                    elseif iAction == 2 then
                        SoundPlay2D("MARACAS_RIGHT_H")
                    else
                        SoundPlay2D("MARACAS_BOTH_H")
                    end
                elseif InstrumentIndex[cPIndex] == 3 then
                    if iAction == 1 then
                        SoundPlay2D("TIMPANI_LEFT_H")
                    elseif iAction == 2 then
                        SoundPlay2D("TIMPANI_RIGHT_H")
                    else
                        SoundPlay2D("TIMPANI_BOTH_H")
                    end
                elseif InstrumentIndex[cPIndex] == 4 then
                    if iAction == 1 then
                        SoundPlay2D("SNARE_LEFT_H")
                    elseif iAction == 2 then
                        SoundPlay2D("SNARE_RIGHT_H")
                    else
                        SoundPlay2D("SNARE_BOTH_H")
                    end
                end
            end
            --[[
            elseif InstrumentIndex[cPIndex] ~= 3 or iAction == 1 then
            else
                if iAction == 2 then
                else
                end
            end
            ]] -- Not present in original script
            -- Added the following (to the end of this elseif chunk):
        elseif ActionState < 6 then
            if InstrumentIndex[cPIndex] == 1 then
                SoundPlay2D("COWBELL_MISTAKE")
            elseif InstrumentIndex[cPIndex] == 2 then
                SoundPlay2D("MARACAS_MISTAKE")
            elseif InstrumentIndex[cPIndex] == 3 then
                SoundPlay2D("TIMPANI_MISTAKE")
            elseif InstrumentIndex[cPIndex] == 4 then
                SoundPlay2D("SNARE_MISTAKE")
            elseif InstrumentIndex[cPIndex] == 5 then
                SoundPlay2D("MISTAKE")
            end
        end
        --[[	
        elseif ActionState < 6 and InstrumentIndex[cPIndex] == 5 then
            SoundPlay2DWii("MISTAKE", 1, 0)
        end
        ]] -- Not present in original script
    end
end
