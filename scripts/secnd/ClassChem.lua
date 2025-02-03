local missionSuccess = false
local L1_1 = 0
local L2_1 = 1
local L3_1 = 2
local IntroWaitTime = 0.45
local gGetReadyText = "C4_GETREADY"
local shortWait = 0.2
local longWait = 0.8
local Win1 = 0.6
local Win2 = 0.55
local Win3 = 0.55
local Win4 = 0.5
local Win5 = 0.5
local num_missed = 1
local camerasTable = {}
local FlaskFX_XYZ = {}
local eff
local bStageLoaded = false
local nCurrentClass = -1
local gAmmoModel = -1
local gAmmoAmount = 3
local gUnlockText = ""
local gClassPassede = false
local tab1 = {
    7,
    8,
    3,
    1
}
local tab2 = {
    4,
    5,
    2,
    0
}
local tab3 = { 28, 29 }
local tab4 = { 22, 23 }
local tab5 = { 3, 0 }
local tab6 = { 6, 9 }
animsroot = "/Global/C4/Animations/"
local AnimSeq
local gActions = {
    0,
    1,
    2,
    3,
    4,
    7,
    5,
    8
}
local AnimSeqTier1 = {
    {
        waitTime = longWait,
        cams = { 2 },
        act = 0,
        anim = animsroot .. "Right/Tube/GrabTube",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Right/Tube/PourTube",
        window = Win1,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = animsroot .. "Right/Tube/PutDownTube",
        window = Win1
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win1,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win1,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win1
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 2,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win1,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win1
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win1,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win1,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win1,
        tab = nil
    }
}
local AnimSeqTier2 = {
    {
        waitTime = longWait,
        cams = { 2 },
        act = 0,
        anim = animsroot .. "Right/Tube/GrabTube",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Right/Tube/PourTube",
        window = Win2,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = animsroot .. "Right/Tube/PutDownTube",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win2,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 2,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win2,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 2,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win2,
        tab = nil
    }
}
local AnimSeqTier3 = {
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win3,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 2 },
        act = 1,
        anim = animsroot .. "Left/Tube/GrabTube",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/Tube/PourTube",
        window = Win3,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/Tube/PutDownTube",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = nil,
        window = Win3,
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win3,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win3
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 7,
        anim = animsroot .. "Left/Powder/GrabPowder",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Powder/ShakePowder",
        window = Win3,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Powder/PutDownPowder",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win3
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 0,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win3,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win3,
        tab = nil
    }
}
local AnimSeqTier4 = {
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win4,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 2 },
        act = 1,
        anim = animsroot .. "Right/Tube/GrabTube",
        window = Win4,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Right/Tube/PourTube",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Right/Tube/PutDownTube",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win4,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 7,
        anim = animsroot .. "Left/Powder/GrabPowder",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Powder/ShakePowder",
        window = Win4,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Powder/PutDownPowder",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 0,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win4,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win4,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win4,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win4,
        tab = nil
    }
}
local AnimSeqTier5 = {
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win5,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 2 },
        act = 5,
        anim = animsroot .. "Left/Tube/GrabTube",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Tube/PourTube",
        window = Win5,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Tube/PutDownTube",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win5,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 5,
        nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 4,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 4,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win5,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 0,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 5,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win5,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 4,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 7,
        anim = animsroot .. "Left/Powder/GrabPowder",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Powder/ShakePowder",
        window = Win5,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Powder/PutDownPowder",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win5,
        tab = nil
    }
}
local FailAnimTable = {
    animsroot .. "React/Smoke",
    animsroot .. "React/Explode"
}
local chemTeach
local diff_easy = 1
local diff_hard = 2

function F_SetDifficulty()
    if nCurrentClass == 1 then
        AnimSeq = AnimSeqTier1
        allowedActions = 4
        gGrade = 1
        gAmmoModel = 301
        gAmmoAmount = 3
        gUnlockText = "C4_Unlock01"
    elseif nCurrentClass == 2 then
        AnimSeq = AnimSeqTier2
        allowedActions = 4
        gGrade = 2
        gAmmoModel = 309
        gAmmoAmount = 5
        gUnlockText = "C4_Unlock02"
    elseif nCurrentClass == 3 then
        AnimSeq = AnimSeqTier3
        allowedActions = 6
        gGrade = 3
        gAmmoModel = 394
        gAmmoAmount = 3
        gUnlockText = "C4_Unlock03"
    elseif nCurrentClass == 4 then
        AnimSeq = AnimSeqTier4
        allowedActions = 8
        gGrade = 4
        gAmmoModel = 308
        gAmmoAmount = 5
        gUnlockText = "C4_Unlock04"
    elseif nCurrentClass == 5 then
        AnimSeq = AnimSeqTier5
        allowedActions = 8
        gAmmoModel = 308
        gAmmoAmount = 10
        gUnlockText = "C4_Unlock05"
        gGrade = 5
    elseif 6 <= nCurrentClass then
        gGrade = 5
        AnimSeq = AnimSeqTier5
        allowedActions = 8
        gUnlockText = false
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
    DATLoad("C4.DAT", 2)
    DATLoad("CLASSLOC.DAT", 2)
    DATLoad("1_02C.DAT", 2)
    DATInit()
    F_ToggleHUDItems(false)
    LoadAnimationGroup("MINICHEM")
    LoadAnimationGroup("WeaponUnlock")
    LoadAnimationGroup("MINI_React")
    LoadAnimationGroup("NPC_Spectator")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("MG_Craps")
    LoadActionTree("Act/Conv/C4.act")
    WeaponRequestModel(366)
    WeaponRequestModel(369)
    WeaponRequestModel(367)
    WeaponRequestModel(368)
    WeaponRequestModel(365)
    WeaponRequestModel(351)
    WeaponRequestModel(408)
    LoadAnimationGroup("MINIBIKE")
    LoadAnimationGroup("SHOPBIKE")
    WeaponRequestModel(375)
    SoundEnableInteractiveMusic(false)
    AreaTransitionPoint(4, POINTLIST._C4_P_DOOR, nil, true)
    PlayerSetPunishmentPoints(0)
    MinigameCreate("CHEM", false)
    while not MinigameIsReady() do
        Wait(0)
    end
    Wait(2)
    ActionAnimFile = "Act/Conv/C4.act"
    FailAnimTableSize = table.getn(FailAnimTable)
    local hide = false
    GeometryInstance("Grab_BeakerX", hide, -596.55, 323.487, 35.407)
    GeometryInstance("Grab_TesttubeRightX", hide, -595.786, 323.605, 35.311)
    GeometryInstance("Grab_CanisterX", hide, -595.951, 323.461, 35.238)
    GeometryInstance("chem_stirX", hide, -596.426, 323.612, 35.175)
    GeometryInstance("Grab_EyedropX", hide, -595.839, 323.426, 35.3079)
    FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z = GetPointList(POINTLIST._C4_FLASK_FX)
    camerasTable = {
        {
            cameraPath = PATH._C4_CAMPATH01,
            x = -595.9582,
            y = 323.8534,
            z = 35.3826,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH02,
            x = -596.3934,
            y = 324.1351,
            z = 35.4825,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH03,
            x = -595.785,
            y = 324.1081,
            z = 35.6425,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH04,
            x = -596.1057,
            y = 323.7872,
            z = 35.5224,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH05,
            x = -596.1946,
            y = 323.8774,
            z = 35.5921,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH06,
            x = -596.1849,
            y = 323.8566,
            z = 35.542,
            speed = 0.2
        }
    }
    GeometryInstance("chem_desk06", false, -597.038, 323.127, 34.9106, false)
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
    SoundDisableSpeech_ActionTree()
end

function MissionCleanup()
    SoundRestartPA()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundEnableInteractiveMusic(true)
    SoundEnableSpeech_ActionTree()
    SoundStopStream()
    CameraReturnToPlayer()
    SoundFadeoutStream()
    F_ToggleHUDItems(true)
    PedDelete(chemTeach)
    MinigameDestroy()
    PlayerWeaponHudLock(false)
    if eff ~= nil then
        EffectKill(eff)
        eff = nil
    end
    if gBuntzenFlame2 then
        EffectKill(gBuntzenFlame2)
        gBuntzenFlame2 = nil
    end
    if gBuntzenFlame3 then
        EffectKill(gBuntzenFlame3)
        gBuntzenFlame3 = nil
    end
    if g_eff ~= nil then
        EffectKill(g_eff)
        g_eff = nil
    end
    if gBubbleEffect then
        EffectKill(gBubbleEffect)
        gBubbleEffect = false
    end
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    if AreaGetVisible() ~= 2 then
        AreaTransitionPoint(2, POINTLIST._C4_EXIT)
    end
    PlayerSetPunishmentPoints(0)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    if nCurrentClass == 5 then
        UnLoadAnimationGroup("NPC_Spectator")
    end
    PlayerSetControl(1)
    UnLoadAnimationGroup("MINICHEM")
    UnLoadAnimationGroup("MG_Craps")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("WeaponUnlock")
    UnLoadAnimationGroup("MINI_React")
    DATUnload(2)
end

function main()
    while not bStageLoaded do
        Wait(0)
    end
    F_SetDifficulty()
    for _, value in AnimSeq do
        if value.tab then
            value.act = PickRandom(value.tab)
        end
    end
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    F_IntroCinematic()
    bUsingTimer = false
    MissionObjectiveAdd("C4_INST01", 0, -1)
    TextPrintString("", 0.1, 1)
    PedFollowPath(chemTeach, PATH._C4_TEACHER_PATH, 1, 0)
    if nCurrentClass == 1 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 3, "jumbo", true)
    elseif nCurrentClass == 2 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 11, "jumbo", true)
    elseif nCurrentClass == 3 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 3, "jumbo", true)
    elseif nCurrentClass == 4 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 9, "jumbo", true)
    else
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 2, "jumbo", true)
    end
    PlayerFaceHeadingNow(180)
    CameraFade(1000, 1)
    Wait(1100)
    local tx, ty, tz = GetPointList(POINTLIST._C4_BUBBLEPOINT)
    gBubbleEffect = EffectCreate("Chem_Bubbles", tx, ty, tz)
    local L3_2 = -1
    local L4_2 = 0
    local L5_2 = 1
    local L6_2 = table.getn(AnimSeq)
    local L7_2 = 0
    local L8_2 = 0
    while L4_2 < 1 and L7_2 < 3 do
        L5_2 = 1
        Wait(2000)
        MinigameStart()
        ClassChemSetGameType("CHEM")
        ClassChemSetScrollyOnly(true)
        MinigameEnableHUD(true)
        if gCamera then
            CameraSetPath(camerasTable[6].cameraPath, true)
            CameraSetSpeed(camerasTable[6].speed, camerasTable[6].speed, camerasTable[6].speed)
            CameraLookAtXYZ(camerasTable[6].x, camerasTable[6].y, camerasTable[6].z, true)
        else
            gCamera = true
        end
        for key, value in AnimSeq do
            if AnimSeq[key].act ~= 34 and L7_2 == 0 then
                AnimSeq[key].act = gActions[math.random(1, allowedActions)]
            end
            if key == 1 then
                ClassChemAddAction(0, value.act, value.waitTime + 2, value.window)
            else
                ClassChemAddAction(0, value.act, value.waitTime, value.window)
            end
        end
        local L9_2 = 0
        local L10_2 = 0
        TutorialShowMessage("C4_INST01")
        TextPrint(gGetReadyText, 2, 1)
        Wait(2500)
        if L7_2 == 0 then
            SoundPlayStream("MS_ChemistryClass.rsm", 0.25, 2, 1)
        end
        TextPrint("C4_BEGIN", 1, 1)
        Wait(1000)
        if gBadExperiment then
            EffectKill(gBadExperiment)
            gBadExperiment = nil
        end
        TutorialRemoveMessage()
        ClassChemStartSeq(0)
        while MinigameIsActive() do
            if L6_2 > L5_2 then
                if ClassChemGetActionJustFinished(AnimSeq[L5_2].act) then
                    F_ActionsCallback(AnimSeq[L5_2], true)
                    L5_2 = L5_2 + 1
                    Wait(300)
                end
                if ClassChemGetActionJustFailed(AnimSeq[L5_2].act) then
                    gSlowdown = GetTimer()
                    L7_2 = L7_2 + 1
                    F_ActionsCallback(AnimSeq[L5_2], false, L7_2)
                    L5_2 = L5_2 + 1
                    Wait(300)
                end
            end
            Wait(0)
        end
        if MinigameIsSuccess() then
            break
        end
        Wait(0)
    end
    if MinigameIsSuccess() then
        PedSetActionNode(gPlayer, animsroot .. "Success", "Act/Conv/C4.act")
        EffectCreate("Chem_GoodReaction", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
        if not bIsRepeatable then
            PlayerSetGrade(1, gGrade)
            if nCurrentClass == 5 then
                MinigameSetGrades(1, gGrade - 1)
                SoundFadeoutStream()
                SoundPlayMissionEndMusic(true, 9)
                while MinigameIsShowingGrades() do
                    Wait(0)
                end
                Wait(1000)
                CameraFade(-1, 0)
                Wait(FADE_OUT_TIME)
                PedStop(chemTeach)
                PedClearObjectives(chemTeach)
                PedSetPosPoint(chemTeach, POINTLIST._C4_TEACH)
                PedFaceHeading(chemTeach, 180, 0)
                CameraLookAtXYZ(-595.66345, 325.33215, 35.663586, true)
                CameraSetXYZ(-595.4686, 324.35153, 35.64855, -595.66345, 325.33215, 35.663586)
                CameraSetWidescreen(true)
                CameraFade(-1, 1)
                Wait(FADE_IN_TIME)
                PedSetActionNode(chemTeach, "/Global/C4/Animations/TeacherFinishClass", "Act/Conv/C4.act")
                F_PlaySpeechAndWait(chemTeach, "CHEM", 16, "jumbo", true)
            else
                SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 14, "supersize", true)
                MinigameSetGrades(1, gGrade - 1)
                SoundFadeoutStream()
                SoundPlayMissionEndMusic(true, 9)
                while MinigameIsShowingGrades() do
                    Wait(0)
                end
            end
        else
            Wait(2000)
        end
        missionSuccess = true
    elseif not bIsRepeatable then
        MinigameSetGrades(1, gGrade - 1)
        SoundFadeoutStream()
        SoundPlayMissionEndMusic(false, 9)
        while MinigameIsShowingGrades() do
            Wait(0)
        end
    else
        Wait(2000)
    end
    PedSetActionNode(gPlayer, "/Global/C4/Animations/CycleClear", "Act/Conv/C4.act")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if missionSuccess then
        if not bIsRepeatable then
            F_EndPresentation()
        else
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
        end
        if gUnlockText ~= false then
            TextPrintString("", 1, 1)
        end
        MissionSucceed(false, false, false)
    else
        MissionFail(true, false)
    end
end

function F_IntroCinematic()
    while not PedRequestModel(106) do
        Wait(1)
    end
    chemTeach = PedCreatePoint(106, POINTLIST._C4_TEACH)
    student1 = PedCreatePoint(3, POINTLIST._C4_STUDENTS, 1)
    student2 = PedCreatePoint(66, POINTLIST._C4_STUDENTS, 2)
    PedIgnoreStimuli(student1, true)
    PedIgnoreStimuli(student2, true)
    PedIgnoreStimuli(chemTeach, true)
    PedSetInvulnerable(chemTeach, true)
    PedMakeTargetable(chemTeach, false)
    Wait(1)
    CameraSetWidescreen(true)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    PedFollowPath(gPlayer, PATH._C4_PLAYERPATH, 0, 0)
    PedFollowPath(student1, PATH._C4_STUDENT01, 0, 0)
    PedFollowPath(student2, PATH._C4_STUDENT02, 0, 0)
    CameraSetPath(PATH._C4_CAMPATH, true)
    CameraSetSpeed(1.4, 3.4, 1.4)
    CameraLookAtPath(PATH._C4_CAMLOOKAT, true)
    CameraLookAtPathSetSpeed(1.8, 1.8, 1.8)
    if nCurrentClass == 1 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 6, "jumbo", true)
    elseif nCurrentClass == 2 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 10, "jumbo", true)
    elseif nCurrentClass == 3 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 2, "jumbo", true)
    elseif nCurrentClass == 4 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 7, "jumbo", true)
    else
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 1, "jumbo", true)
    end
    PedSetActionNode(chemTeach, "/Global/C4/Animations/TeacherFinishClass", "Act/Conv/C4.act")
    Wait(2738)
    PlayerFaceHeading(180, 1)
    Wait(1095)
    if nCurrentClass == 1 then
        IntroConv = "C4_INTRO1"
    elseif nCurrentClass == 2 then
        IntroConv = "C4_INTRO2"
    elseif nCurrentClass == 3 then
        IntroConv = "C4_INTRO3"
    elseif nCurrentClass == 4 then
        IntroConv = "C4_INTRO4"
    elseif 5 <= nCurrentClass then
        IntroConv = "C4_INTRO5"
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(800, 0)
    Wait(900)
    F_CleanPrefect()
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PlayerSetPosPoint(POINTLIST._C4_P_TABLE)
    Wait(100)
    CameraSetWidescreen(false)
    CameraSetPath(camerasTable[6].cameraPath, true)
    CameraSetSpeed(camerasTable[6].speed, camerasTable[6].speed, camerasTable[6].speed)
    CameraLookAtXYZ(camerasTable[6].x, camerasTable[6].y, camerasTable[6].z, true)
    CameraFade(1000, 1)
    PedSetActionNode(gPlayer, "/Global/C4/Animations/StartAnimations", "Act/Conv/C4.act")
end

function F_ExplainGame()
    TutorialMessage("C4_INST01")
    TextPrintString("", 0.1, 1)
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

local L40_1 = true

function F_ActionsCallback(cAction, bPass, CurIndex)
    --DebugPrint("F_ActionsCallback(): pass:" .. tostring(bPass) .. " " .. tostring(cAction) .. " " .. tostring(CurIndex))
    local camPath = 0
    if bPass then
        SoundPlay2D("ChemRight")
        Wait(100)
        if cAction.anim then
            camEntry = PickRandom(camerasTable)
            camPath = camEntry.cameraPath
            if cAction.cams then
                if not gSpeechPlayed then
                    SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 13, "jumbo", true)
                    gSpeechPlayed = true
                    gSpeechTimer = GetTimer()
                elseif 3000 < GetTimer() - gSpeechTimer then
                    gSpeechPlayed = false
                end
                local tempTable = cAction.cams[1]
                camEntry = camerasTable[tempTable]
                CameraSetPath(camEntry.cameraPath, true)
                CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
                CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
                L40_1 = not L40_1
            else
                L40_1 = not L40_1
            end
            PedSetActionNode(gPlayer, cAction.anim, ActionAnimFile)
            if cAction.effect then
                eff = EffectCreate(cAction.effect, FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            end
            if cAction.ambEffect then
                g_eff = EffectCreate(cAction.ambEffect, FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            end
        end
    else
        SoundPlay2D("ChemWrong")
        Wait(100)
        if g_eff then
            EffectKill(g_eff)
            g_eff = nil
        end
        gBadExperiment = EffectCreate("Chem_Reaction", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
        PedStop(chemTeach)
        PedFaceObject(chemTeach, gPlayer, 3, 0)
        PedSetActionNode(chemTeach, "/Global/C4/Animations/Teacher/TeacherChew", "Act/Conv/C4.act")
        if CurIndex < 3 then
            StartVibration(1, 400, 7)
            PedSetActionNode(gPlayer, FailAnimTable[1], ActionAnimFile)
            SoundStopCurrentSpeechEvent(chemTeach)
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 12, "jumbo", true)
            if CurIndex == 1 then
                gGetReadyText = "C4_GETREADY2"
                local x, y, z = GetPointList(POINTLIST._C4_FLAMEPOINT)
                gBuntzenFlame2 = EffectCreate("BuntzenFlame2", x, y, z)
            elseif CurIndex == 2 then
                gGetReadyText = "C4_GETREADY3"
                local x, y, z = GetPointList(POINTLIST._C4_FLAMEPOINT)
                gBuntzenFlame3 = EffectCreate("BuntzenFlame3", x, y, z)
            end
        else
            SoundStopCurrentSpeechEvent(chemTeach)
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 15, "jumbo", true)
            StartVibration(2, 1500, 254)
            eff = EffectCreate("Chem_Accident", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            PedSetActionNode(gPlayer, FailAnimTable[2], ActionAnimFile)
            SoundFadeoutStream()
        end
        MinigameEnd()
        Wait(1000)
        PedFollowPath(chemTeach, PATH._C4_TEACHER_PATH, 1, 0)
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

function F_EndPresentation()
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    AreaTransitionPoint(2, POINTLIST._C4_EXIT, nil, true)
    AreaClearAllPeds()
    CameraSetWidescreen(true)
    local x, y, z = GetPointList(POINTLIST._C4_ENDCAMLOOKAT)
    CameraLookAtXYZ(x, y, z, true)
    CameraSetPath(PATH._C4_UNLOCKPATH, true)
    CameraSetSpeed(0.5, 0.5, 0.5)
    PlayerWeaponHudLock(false)
    local unlockText = false
    local unlockMissionText = false
    local unlockAnim = "/Global/C4/Animations/Unlocks/EarnA"
    local unlockAnim2 = "/Global/C4/Animations/Success"
    if nCurrentClass == 1 then
        PlayerSetWeapon(301, 3, false)
        unlockText = "C4_unlock01"
        unlockMissionText = "TUT_CHEM1C1"
        unlockAnim2 = "/Global/C4/Animations/Unlocks/SuccessHi2"
    elseif nCurrentClass == 2 then
        PlayerSetWeapon(309, 3, false)
        unlockText = "C4_unlock02"
        unlockAnim2 = "/Global/C4/Animations/Unlocks/SuccessMed1"
    elseif nCurrentClass == 3 then
        unlockAnim = "/Global/C4/Animations/Unlocks/EarnB"
        PlayerSetWeapon(394, 3, false)
        unlockText = "C4_Unlock03"
        unlockAnim = "/Global/C4/Animations/Unlocks/EarnB"
        unlockAnim2 = "/Global/C4/Animations/Unlocks/SuccessHi2"
    elseif nCurrentClass == 4 then
        unlockText = "C4_Unlock04"
        unlockMissionText = "TUT_CHEM4C1"
        unlockAnim = "/Global/C4/Animations/Unlocks/SuccessHi1"
    elseif nCurrentClass == 5 then
        unlockText = "C4_Unlock05"
        unlockMissionText = "TUT_CHEM5C1"
        unlockAnim = "/Global/C4/Animations/Unlocks/SuccessHi3"
        unlockAnim2 = false
    end
    if nCurrentClass < 4 then
        local timeout = GetTimer()
        while not WeaponEquipped() do
            if GetTimer() - timeout > 3000 then
                break
            end
            Wait(0)
        end
    end
    CameraFade(-1, 1)
    MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
    PedSetActionNode(gPlayer, unlockAnim, "Act/Conv/C4.act")
    Wait(2000)
    if unlockMissionText then
        TutorialShowMessage(unlockMissionText, -1, true)
    end
    while PedIsPlaying(gPlayer, unlockAnim, true) do
        Wait(0)
    end
    Wait(3500)
    TutorialRemoveMessage()
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
        PedSetInvulnerable(prefect, true)
        PedFaceObject(gPlayer, prefect, 2, 0)
        PedFaceObject(prefect, gPlayer, 3, 0)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraSetXYZ(-597.1507, 325.1509, 35.73755, -597.65344, 326.0126, 35.67)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C4/Animations/Failure", "Act/Conv/C4.act")
        Wait(3000)
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
