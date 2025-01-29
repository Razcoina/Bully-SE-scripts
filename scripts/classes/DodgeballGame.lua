ImportScript("Library/LibPlayer.lua")
local bRunCinematic = true
local nCurrentStage = 1
local bStageLoaded = false
local red1, red2, red3, blue1, blue2, blue3, blue4, referee, coach, playerActor
local missionSuccess = false
local StartFadeout = false
local gTextQueue = {}
local bThreadRunning = true
local tblCinematicScript = {}
local tblCameraIndex = {}
local CAM_HEADING = 1
local CAM_PED = 2
local CAM_PEDOFFSET = 3
local CAM_POINT = 4
local idFakePlayer
local bDialogueThreadRunning = true
local encourageTime = 0
local encourageMaxTime = 0
local gRoundTable = {
    "DBG_ROUND 1",
    "DBG_ROUND 2",
    "DBG_ROUND 3"
}
local camcoach, camred1, camred2, camred3, camblue1, camblue2, camblue3, camblue4
local gPlayedInitialTutorial = false
local textTable = {
    {
        { textid = "C2_01", time = 6 },
        { textid = "C2_02", time = 6 },
        { textid = "C2_03", time = 6 },
        { textid = "C2_04", time = 6 },
        { textid = "C2_05", time = 6 },
        { textid = "C2_06", time = 6 },
        { textid = "C2_07", time = 6 },
        { textid = "C2_10", time = 2 },
        { textid = "C2_11", time = 2 },
        { textid = "C2_08", time = 2 }
    },
    {
        { textid = "C2_09", time = 2 },
        { textid = "C2_12", time = 2 },
        { textid = "C2_13", time = 2 }
    },
    {
        { textid = "C2_09", time = 2 },
        { textid = "C2_14", time = 2 },
        { textid = "C2_15", time = 2 },
        { textid = "C2_16", time = 2 }
    },
    {
        { textid = "C2_09", time = 2 },
        { textid = "C2_17", time = 2 }
    },
    {
        { textid = "C2_18", time = 2 },
        { textid = "C2_19", time = 2 }
    }
}
local teamTable = {
    {
        p1 = 214,
        p2 = 213,
        p3 = 211,
        p4 = 212,
        p1AI = "Timid",
        p2AI = "Default",
        p3AI = "Timid",
        p4AI = "Timid",
        difficulty = "1",
        script1 = "DB_Ped.act",
        script2 = "DB_Ped.act",
        script3 = "DB_Ped.act",
        script4 = "DB_Ped.act",
        node1 = "DB_Ped",
        node2 = "DB_Ped",
        node3 = "DB_Ped",
        node4 = "DB_Ped",
        aiscript1 = "DB_Hit.act",
        aiscript2 = "DB_Hit.act",
        aiscript3 = "DB_Hit.act",
        aiscript4 = "DB_Hit.act",
        ainode1 = "DBHit",
        ainode2 = "DBHit",
        ainode3 = "DBHit",
        ainode4 = "DBHit",
        convNode = "FirstGame",
        name1 = "C2_PrepGord",
        name2 = "C2_PrepTad",
        name3 = "C2_PrepParker",
        name4 = "C2_PrepJustin"
    },
    {
        p1 = 202,
        p2 = 200,
        p3 = 203,
        p4 = 201,
        p1AI = "Default",
        p2AI = "Aggressive",
        p3AI = "Timid",
        p4AI = "Aggressive",
        difficulty = "2",
        script1 = "DB_Ped.act",
        script2 = "DB_Ped.act",
        script3 = "DB_Ped.act",
        script4 = "DB_Ped.act",
        node1 = "DB_Ped",
        node2 = "DB_Ped",
        node3 = "DB_Ped",
        node4 = "DB_Ped",
        aiscript1 = "DB_Hit.act",
        aiscript2 = "DB_Hit.act",
        aiscript3 = "DB_Hit.act",
        aiscript4 = "DB_Hit.act",
        ainode1 = "DBHit",
        ainode2 = "DBHit",
        ainode3 = "DBHit",
        ainode4 = "DBHit",
        convNode = "Game2",
        name1 = "C2_PrepGord",
        name2 = "C2_PrepTad",
        name3 = "C2_PrepParker",
        name4 = "C2_PrepJustin"
    },
    {
        p1 = 205,
        p2 = 204,
        p3 = 206,
        p4 = 207,
        p1AI = "Aggressive",
        p2AI = "Default",
        p3AI = "Aggressive",
        p4AI = "Default",
        difficulty = "3",
        script1 = "DB_Ped.act",
        script2 = "DB_Ped.act",
        script3 = "DB_Ped.act",
        script4 = "DB_Ped.act",
        node1 = "DB_Ped",
        node2 = "DB_Ped",
        node3 = "DB_Ped",
        node4 = "DB_Ped",
        aiscript1 = "DB_Hit.act",
        aiscript2 = "DB_Hit.act",
        aiscript3 = "DB_Hit.act",
        aiscript4 = "DB_Hit.act",
        ainode1 = "DBHit",
        ainode2 = "DBHit",
        ainode3 = "DBHit",
        ainode4 = "DBHit",
        convNode = "Game3",
        name1 = "C2_JockDamon",
        name2 = "C2_JockBo",
        name3 = "C2_JockJuri",
        name4 = "C2_JockKirby"
    },
    {
        p1 = 199,
        p2 = 196,
        p3 = 198,
        p4 = 197,
        p1AI = "Aggressive",
        p2AI = "Aggressive",
        p3AI = "Timid",
        p4AI = "Aggressive",
        difficulty = "5",
        script1 = "DB_Ped.act",
        script2 = "DB_Ped.act",
        script3 = "DB_Ped.act",
        script4 = "DB_Ped.act",
        node1 = "DB_Ped",
        node2 = "DB_Ped",
        node3 = "DB_Ped",
        node4 = "DB_Ped",
        aiscript1 = "DB_Hit.act",
        aiscript2 = "DB_Hit.act",
        aiscript3 = "DB_Hit.act",
        aiscript4 = "DB_Hit.act",
        ainode1 = "DBHit",
        ainode2 = "DBHit",
        ainode3 = "DBHit",
        ainode4 = "DBHit",
        convNode = "Game4",
        name1 = "C2_DropLeon",
        name2 = "C2_DropDuncan",
        name3 = "C2_DropJerry",
        name4 = "C2_DropGurney"
    },
    {
        p1 = 199,
        p2 = 196,
        p3 = 198,
        p4 = 197,
        p1AI = "Aggressive",
        p2AI = "Aggressive",
        p3AI = "Aggressive",
        p4AI = "Aggressive",
        difficulty = "5",
        script1 = "DB_Ped.act",
        script2 = "DB_Ped.act",
        script3 = "DB_Ped.act",
        script4 = "DB_Ped.act",
        node1 = "DB_Ped",
        node2 = "DB_Ped",
        node3 = "DB_Ped",
        node4 = "DB_Ped",
        aiscript1 = "DB_Hit.act",
        aiscript2 = "DB_Hit.act",
        aiscript3 = "DB_Hit.act",
        aiscript4 = "DB_Hit.act",
        ainode1 = "DBHit",
        ainode2 = "DBHit",
        ainode3 = "DBHit",
        ainode4 = "DBHit",
        convNode = "Game4",
        name1 = "C2_DropLeon",
        name2 = "C2_DropDuncan",
        name3 = "C2_DropJerry",
        name4 = "C2_DropGurney"
    }
}

function F_CreateCamPed(model, point, element)
    local ped
    if element then
        ped = PedCreatePoint(model, point, element)
    else
        ped = PedCreatePoint(model, point)
    end
    PedSetWeaponNow(ped, -1, 0)
    PedSetPedToTypeAttitude(ped, 13, 3)
    return ped
end

function F_PopulateCamTables()
    camcoach = PedCreatePoint(55, POINTLIST._DBALLCAM_COACH)
    PedSetFaction(camcoach, 9)
    PedMakeTargetable(camcoach, false)
    camred1 = F_CreateCamPed(208, POINTLIST._DBALLCAM_NERDOS, 1)
    camred2 = F_CreateCamPed(210, POINTLIST._DBALLCAM_NERDOS, 2)
    camred3 = F_CreateCamPed(209, POINTLIST._DBALLCAM_NERDOS, 3)
    camblue1 = F_CreateCamPed(teamTable[nCurrentStage].p1, POINTLIST._DBALLCAM_JOCKOS, 1)
    camblue2 = F_CreateCamPed(teamTable[nCurrentStage].p2, POINTLIST._DBALLCAM_JOCKOS, 2)
    camblue3 = F_CreateCamPed(teamTable[nCurrentStage].p3, POINTLIST._DBALLCAM_JOCKOS, 3)
    camblue4 = F_CreateCamPed(teamTable[nCurrentStage].p4, POINTLIST._DBALLCAM_JOCKOS, 4)
    PedSetWeaponNow(gPlayer, -1, 0)
    Wait(0)
    E3DodgeballHackCleanObjects()
    tblCinematicScript = {
        {
            {
                val = "C2_01",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 1
            },
            {
                val = "C2_02",
                tTime = 3000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 7
            },
            {
                val = "C2_03",
                tTime = 4500,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 2
            },
            {
                val = "C2_04",
                tTime = 1000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 9
            },
            {
                val = "C2_04",
                tTime = 2800,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 4
            },
            {
                val = "C2_05",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 11
            },
            {
                time = 0,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 3420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 5420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_007"
            },
            {
                time = 6000,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 6000,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 7830,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 7830,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 8000,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/PREP_PREP_IDLE_A"
            },
            {
                time = 9660,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_IDLE_D"
            },
            {
                time = 9660,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_SCRATCHARSE_A"
            },
            {
                time = 12000,
                animatePed = camblue1,
                animString = "/Global/DodgeballGame/Anims/Bank/PREP_TIME_CHECK_2"
            },
            {
                time = 14000,
                animatePed = camblue3,
                animString = "/Global/DodgeballGame/Anims/Bank/PREP_IDLE"
            },
            {
                time = 15000,
                animatePed = camred1,
                animString = "/Global/DodgeballGame/Anims/Bank/DB_ALG_IDLE"
            },
            {
                time = 17500,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_011"
            },
            {
                time = 26200,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/PREP_WIPE_SLEEVES_B"
            },
            {
                time = 27500,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                cameraName = PATH._DBALLCAM_CLOSEUP,
                targetType = CAM_PEDOFFSET,
                targetParam = camcoach,
                offset = 1.5,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 6000
            },
            {
                cameraName = PATH._DBALLCAM_PAN,
                targetType = CAM_HEADING,
                targetParam = PATH._DBALLCAM_PANFOCUS,
                snap = true,
                speedEaseIn = 0,
                speedEaseOut = 0,
                speedMax = 0.8,
                time = 10000
            },
            {
                cameraName = PATH._DBALL_CAM_1,
                targetType = CAM_POINT,
                targetParam = POINTLIST._DBALL_CENTER,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 3000
            }
        },
        {
            {
                val = "C2_01",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 1
            },
            {
                val = "C2_02",
                tTime = 3000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 7
            },
            {
                val = "C2_03",
                tTime = 4500,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 2
            },
            {
                val = "C2_04",
                tTime = 1000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 9
            },
            {
                val = "C2_04",
                tTime = 2800,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 4
            },
            {
                val = "C2_05",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 11
            },
            {
                time = 0,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 3420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 5420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_007"
            },
            {
                time = 6000,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 6000,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 7830,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 7830,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 8000,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/GRES_IDLE_B"
            },
            {
                time = 9660,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_RUBHEAD_A"
            },
            {
                time = 9660,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_IDLE_D"
            },
            {
                time = 12000,
                animatePed = camblue1,
                animString = "/Global/DodgeballGame/Anims/Bank/GRES_FIXHAIR_D"
            },
            {
                time = 14000,
                animatePed = camblue3,
                animString = "/Global/DodgeballGame/Anims/Bank/GRES_FISTPALM_A"
            },
            {
                time = 15000,
                animatePed = camred1,
                animString = "/Global/DodgeballGame/Anims/Bank/FAT_LOOKPANIC_B_01"
            },
            {
                time = 17500,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_011"
            },
            {
                time = 26200,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/GRES_LOOSENUP_A"
            },
            {
                time = 27500,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 28720,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                time = 31000,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                cameraName = PATH._DBALLCAM_CLOSEUP,
                targetType = CAM_PEDOFFSET,
                targetParam = camcoach,
                offset = 1.5,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 6000
            },
            {
                cameraName = PATH._DBALLCAM_PAN,
                targetType = CAM_HEADING,
                targetParam = PATH._DBALLCAM_PANFOCUS,
                snap = true,
                speedEaseIn = 0,
                speedEaseOut = 0,
                speedMax = 0.8,
                time = 10000
            },
            {
                cameraName = PATH._DBALL_CAM_1,
                targetType = CAM_POINT,
                targetParam = POINTLIST._DBALL_CENTER,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 3000
            }
        },
        {
            {
                val = "C2_01",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 1
            },
            {
                val = "C2_02",
                tTime = 3000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 7
            },
            {
                val = "C2_03",
                tTime = 4500,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 2
            },
            {
                val = "C2_04",
                tTime = 1000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 9
            },
            {
                val = "C2_04",
                tTime = 2800,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 4
            },
            {
                val = "C2_05",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 11
            },
            {
                time = 0,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 3420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 5420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_007"
            },
            {
                time = 6000,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 6000,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                time = 7830,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 7830,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 8000,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/JOCK_HAMSTRINGS_A"
            },
            {
                time = 9660,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_SCRATCHARSE_A"
            },
            {
                time = 9660,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_IDLE_D"
            },
            {
                time = 12000,
                animatePed = camblue1,
                animString = "/Global/DodgeballGame/Anims/Bank/JOCK_IDLE_E"
            },
            {
                time = 14000,
                animatePed = camblue3,
                animString = "/Global/DodgeballGame/Anims/Bank/JOCK_SMELLPITS_A"
            },
            {
                time = 15000,
                animatePed = camred1,
                animString = "/Global/DodgeballGame/Anims/Bank/FAT_PICKNOSE_A_01"
            },
            {
                time = 17500,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_011"
            },
            {
                time = 26200,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/JOCK_STRETCH_B"
            },
            {
                time = 27500,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 28720,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                time = 31000,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                cameraName = PATH._DBALLCAM_CLOSEUP,
                targetType = CAM_PEDOFFSET,
                targetParam = camcoach,
                offset = 1.5,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 6000
            },
            {
                cameraName = PATH._DBALLCAM_PAN,
                targetType = CAM_HEADING,
                targetParam = PATH._DBALLCAM_PANFOCUS,
                snap = true,
                speedEaseIn = 0,
                speedEaseOut = 0,
                speedMax = 0.8,
                time = 10000
            },
            {
                cameraName = PATH._DBALL_CAM_1,
                targetType = CAM_POINT,
                targetParam = POINTLIST._DBALL_CENTER,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 3000
            }
        },
        {
            {
                val = "C2_01",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 1
            },
            {
                val = "C2_02",
                tTime = 3000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 7
            },
            {
                val = "C2_03",
                tTime = 4500,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 2
            },
            {
                val = "C2_04",
                tTime = 1000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 9
            },
            {
                val = "C2_04",
                tTime = 2800,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 4
            },
            {
                val = "C2_05",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 11
            },
            {
                time = 0,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 3420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 5420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_007"
            },
            {
                time = 6000,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 6000,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/IDLE"
            },
            {
                time = 7830,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 7830,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 8000,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_B_01"
            },
            {
                time = 9660,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_RUBHEAD_A"
            },
            {
                time = 9660,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_IDLE_D"
            },
            {
                time = 12000,
                animatePed = camblue1,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_E_01"
            },
            {
                time = 14000,
                animatePed = camblue3,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_I_01"
            },
            {
                time = 15000,
                animatePed = camred1,
                animString = "/Global/DodgeballGame/Anims/Bank/FAT_LOOKSIDES_A_01"
            },
            {
                time = 17500,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_011"
            },
            {
                time = 26200,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_G_01"
            },
            {
                time = 27500,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/IDLE"
            },
            {
                time = 28720,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                time = 31000,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                cameraName = PATH._DBALLCAM_CLOSEUP,
                targetType = CAM_PEDOFFSET,
                targetParam = camcoach,
                offset = 1.5,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 6000
            },
            {
                cameraName = PATH._DBALLCAM_PAN,
                targetType = CAM_HEADING,
                targetParam = PATH._DBALLCAM_PANFOCUS,
                snap = true,
                speedEaseIn = 0,
                speedEaseOut = 0,
                speedMax = 0.8,
                time = 10000
            },
            {
                cameraName = PATH._DBALL_CAM_1,
                targetType = CAM_POINT,
                targetParam = POINTLIST._DBALL_CENTER,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 3000
            }
        },
        {
            {
                val = "C2_01",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 1
            },
            {
                val = "C2_02",
                tTime = 3000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 7
            },
            {
                val = "C2_03",
                tTime = 4500,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 2
            },
            {
                val = "C2_04",
                tTime = 1000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 9
            },
            {
                val = "C2_04",
                tTime = 2800,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 4
            },
            {
                val = "C2_05",
                tTime = 4000,
                style = 2,
                isText = false,
                priority = false,
                textSpeechEvent = "DODGEBALL",
                textSpeechIndex = 11
            },
            {
                time = 0,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/DONTMESS"
            },
            {
                time = 3420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 5420,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_007"
            },
            {
                time = 6000,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 6000,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/IDLE"
            },
            {
                time = 7830,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/STINK_REACT"
            },
            {
                time = 7830,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_BRING_IT"
            },
            {
                time = 8000,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_G_01"
            },
            {
                time = 9660,
                animatePed = camred2,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_IDLE_D"
            },
            {
                time = 9660,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/NERDS_SCRATCHARSE_A"
            },
            {
                time = 12000,
                animatePed = camblue1,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_I_01"
            },
            {
                time = 14000,
                animatePed = camblue3,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_E_01"
            },
            {
                time = 15000,
                animatePed = camred1,
                animString = "/Global/DodgeballGame/Anims/Bank/FAT_SMELLARMPIT_A_01"
            },
            {
                time = 17500,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/BURTON_DODGE_011"
            },
            {
                time = 26200,
                animatePed = camblue2,
                animString = "/Global/DodgeballGame/Anims/Bank/DOUT_IDLE_B_01"
            },
            {
                time = 27500,
                animatePed = camred3,
                animString = "/Global/DodgeballGame/Anims/Bank/IDLE"
            },
            {
                time = 28720,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                time = 31000,
                animatePed = camcoach,
                animString = "/Global/DodgeballGame/Anims/Bank/REAC_COMEON"
            },
            {
                cameraName = PATH._DBALLCAM_CLOSEUP,
                targetType = CAM_PEDOFFSET,
                targetParam = camcoach,
                offset = 1.5,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 6000
            },
            {
                cameraName = PATH._DBALLCAM_PAN,
                targetType = CAM_HEADING,
                targetParam = PATH._DBALLCAM_PANFOCUS,
                snap = true,
                speedEaseIn = 0,
                speedEaseOut = 0,
                speedMax = 0.8,
                time = 10000
            },
            {
                cameraName = PATH._DBALL_CAM_1,
                targetType = CAM_POINT,
                targetParam = POINTLIST._DBALL_CENTER,
                snap = true,
                speedEaseIn = nil,
                speedEaseOut = nil,
                speedMax = nil,
                time = 3000
            }
        }
    }
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("DBall.DAT", 2)
    DATLoad("DBallCam.DAT", 2)
    SoundStopStream()
    SoundEnableSpeech()
    SoundEnableInteractiveMusic(false)
    DATInit()
    DisablePunishmentSystem(true)
    PlayerSetPunishmentPoints(0)
    LoadAnimationGroup("Dodgeball")
    LoadAnimationGroup("Dodgeball2")
    LoadAnimationGroup("Ambient")
    LoadAnimationGroup("Cheer_Gen3")
    LoadAnimationGroup("MINI_REACT")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadActionTree("Act/Conv/DodgeballGame.act")
    SoundStopPA()
    SoundDisableSpeech_ActionTree()
    NonMissionPedGenerationDisable()
    ToggleHUDComponentVisibility(0, false)
    ToggleHUDComponentVisibility(11, false)
    ToggleHUDComponentVisibility(4, false)
    DoublePedShadowDistance(true)
end

function MissionCleanup()
    NonMissionPedGenerationEnable()
    AllowAreaTransitions(true)
    DisablePunishmentSystem(false)
    SoundUnLoadBank("MISSION\\DdgBall.bnk")
    SoundLoadBank("FEET\\FEETSCHL.BNK")
    local setX, setY, setZ = GetPointList(POINTLIST._DBALL_START)
    SoundFadeoutStream()
    SoundEnableInteractiveMusic(true)
    PlayerSetPunishmentPoints(0)
    AreaRevertToDefaultPopulation()
    F_CleanupDodgeball()
    ToggleHUDComponentVisibility(0, true)
    ToggleHUDComponentVisibility(11, true)
    ToggleHUDComponentVisibility(4, true)
    SoundRestartPA()
    UnLoadAnimationGroup("Dodgeball")
    UnLoadAnimationGroup("Dodgeball2")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("Ambient")
    UnLoadAnimationGroup("MINI_REACT")
    UnLoadAnimationGroup("Cheer_Gen3")
    if gSoundLooping then
        SoundLoopPlay2D("CrowdCheers", false)
        gSoundLooping = false
    end
    if IsMissionCompleated("5_04") then
        GeometryInstance("GymHoopsBRT", false, -619.152, -71.9741, 66.2952, true)
        GeometryInstance("GymHoops03", false, -619.152, -71.9741, 52.9112, true)
        GeometryInstance("GymHoops02", false, -619.151, -47.4397, 52.884, true)
    else
        GeometryInstance("GymHoops", false, -624.326, -48.2877, 68.9731, true)
        GeometryInstance("GymHoops03", false, -619.152, -71.9741, 52.9112, true)
        GeometryInstance("GymHoops02", false, -619.151, -47.4397, 52.884, true)
    end
    GeometryInstance("PGymLights", false, -619.172, -63.31, 68.9731, true)
    GeometryInstance("PGymLights", false, -624.326, -48.2877, 68.9731, true)
    GeometryInstance("PGymLights", false, -624.326, -71.013, 68.9731, true)
    GeometryInstance("PGymLights", false, -614.133, -48.2877, 68.9731, true)
    GeometryInstance("PGymLights", false, -619.172, -48.2877, 68.9731, true)
    GeometryInstance("GymRfSpprt2", false, -621.207, -59.6986, 69.6478, true)
    GeometryInstance("GymWall", false, -619.299, -44.8307, 64.8379, true)
    if dGI then
        DeletePersistentEntity(dGI, dGO)
    end
    GeometryInstance("GymFlrMat12", false, -619.095, -45.1323, 60.6377, true)
    EffectTurnOnWindowGlowInArea(-619.172, -63.31, 68.9731, 2)
    EffectTurnOnWindowGlowInArea(-624.326, -48.2877, 68.9731, 2)
    EffectTurnOnWindowGlowInArea(-624.326, -71.013, 68.9731, 2)
    EffectTurnOnWindowGlowInArea(-614.133, -48.2877, 68.9731, 2)
    EffectTurnOnWindowGlowInArea(-619.172, -48.2877, 68.9731, 2)
    while DodgeballIsActive() do
        Wait(0)
    end
    ClothingRestore()
    ClothingBuildPlayer()
    PlayerSetPosPoint(POINTLIST._DBALL_PLAYEREND)
    DATUnload(2)
    SoundFadeoutStream()
    DoublePedShadowDistance(false)
    F_MakePlayerSafeForNIS(false)
    if shared.JockVendettaRunning then
        if 2 <= gMatchesWon then
            shared.DodgeballSuccess = 1
        else
            shared.DodgeballSuccess = 0
        end
    end
end

function F_CleanupDodgeball()
    if not gCleanedDodgeball then
        DodgeballTerm()
        DodgeballEnableCamera(false)
        E3DodgeballHackCleanObjects()
        gCleanedDodgeball = true
    end
end

function main()
    AreaTransitionPoint(13, POINTLIST._DBALL_PLAYER, nil, true)
    PlayerSetControl(0)
    if IsMissionCompleated("5_04") then
        GeometryInstance("GymHoopsBRT", true, -619.152, -71.9741, 66.2952, false)
        GeometryInstance("GymHoops03", true, -619.152, -71.9741, 52.9112, false)
        GeometryInstance("GymHoops02", true, -619.151, -47.4397, 52.884, false)
    else
        GeometryInstance("GymHoops", true, -619.151, -59.6986, 66.2952, false)
        GeometryInstance("GymHoops03", true, -619.152, -71.9741, 52.9112, false)
        GeometryInstance("GymHoops02", true, -619.151, -47.4397, 52.884, false)
    end
    GeometryInstance("PGymLights", true, -619.172, -63.31, 68.9731, false)
    GeometryInstance("PGymLights", true, -624.326, -48.2877, 68.9731, false)
    GeometryInstance("PGymLights", true, -624.326, -71.013, 68.9731, false)
    GeometryInstance("PGymLights", true, -614.133, -48.2877, 68.9731, false)
    GeometryInstance("PGymLights", true, -619.172, -48.2877, 68.9731, false)
    GeometryInstance("GymRfSpprt2", true, -621.207, -59.6986, 69.6478, false)
    EffectTurnOffWindowGlowInArea(-619.172, -63.31, 68.9731, 2)
    EffectTurnOffWindowGlowInArea(-624.326, -48.2877, 68.9731, 2)
    EffectTurnOffWindowGlowInArea(-624.326, -71.013, 68.9731, 2)
    EffectTurnOffWindowGlowInArea(-614.133, -48.2877, 68.9731, 2)
    EffectTurnOffWindowGlowInArea(-619.172, -48.2877, 68.9731, 2)
    if not shared.bBustedClassLaunched and not ClothingIsWearingOutfit("Gym Strip") then
        ClothingBackup()
        ClothingSetPlayerOutfit("Gym Strip")
        ClothingBuildPlayer()
    end
    while not bStageLoaded do
        Wait(0)
    end
    SoundUnLoadBank("FEET\\FEETSCHL.BNK")
    SoundLoadBank("MISSION\\DdgBall.bnk")
    PedClearPOIForAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
    WeaponRequestModel(318)
    if not gNonClassDodgeball then
        CreateThread("TextQueueThread")
        CreateThread("AnimQueueThread")
        F_PopulateCamTables()
        if bRunCinematic then
            F_RunCinematic()
        end
        F_CleanupCamPeds()
    end
    SoundEnableSpeech_ActionTree()
    gMatchesPlayed = 0
    gMatchesWon = 0
    gMatchesLost = 0
    gDodgeballActive = true
    F_CreateDodgeballPeds()
    if gNonClassDodgeball then
        CameraSetWidescreen(true)
        CameraSetPath(PATH._DBALL_NONCLASSCAM, true)
        CameraSetSpeed(4, 4, 4)
        CameraLookAtXYZ(-617.73016, -60.631695, 60.147766, true)
        CameraFade(-1, 1)
        Wait(5000)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME)
        CameraSetWidescreen(false)
    end
    GeometryInstance("GymWall", true, -619.299, -44.8307, 64.8379, false)
    dGI, dGO = CreatePersistentEntity("DodgeballGate", -620.11, -55.437, 59.185, 0, 13)
    GeometryInstance("DodgeballGate", true, -620.11, -55.437, 59.185, true)
    GeometryInstance("GymFlrMat12", true, -619.095, -45.1323, 60.6377, false)
    SoundPlayStream("MS_GymClass.rsm", 0.6, 2, 1)
    PlayerSetControl(1)
    while gDodgeballActive do
        if nCurrentStage ~= 6 then
            gMatchesPlayed = gMatchesPlayed + 1
            gCleanedDodgeball = nil
            F_DodgeballSetup()
            bRunCinematic = false
            while AreaIsLoading() do
                wait(0)
            end
            MinigameSetCompletion(gRoundTable[gMatchesPlayed], true, 0)
            DodgeballStartGame("TEST_GAME", true)
            DodgeballEnableHud(true)
            DodgeballEnableCamera(true)
            --DebugPrint("DodgeballPause test3")
            DodgeballPause(false)
            --DebugPrint("DodgeballPause test3 eof")
            CameraFade(1000, 1)
            Wait(2100)
            SoundFadeWithCamera(true)
            MusicFadeWithCamera(true)
            AllowAreaTransitions(false)
            PedSetActionNode(referee, "/Global/DodgeballGame/Anims/Coach/CoachWhistle", "Act/Conv/DodgeballGame.act")
            while DodgeballGetWinner() == -1 do
                if not gPlayedInitialTutorial and gGrade == 2 then
                    DodgeballHelpMsg(true)
                end
                if not gPlayedInitialTutorial and IsButtonPressed(8, 0) then
                    DodgeballHelpMsg(false)
                    gPlayedInitialTutorial = true
                end
                if gCheckForBallTimer then
                    if not gPlayerHasBall then
                        if PedHasWeapon(gPlayer, 318) or PedHasWeapon(red1, 318) or PedHasWeapon(red2, 318) or PedHasWeapon(red3, 318) then
                            gPlayerHasBall = GetTimer()
                        end
                    elseif 5000 < GetTimer() - gPlayerHasBall then
                        if PedHasWeapon(gPlayer, 318) or PedHasWeapon(red1, 318) or PedHasWeapon(red2, 318) or PedHasWeapon(red3, 318) then
                            TutorialShowMessage("DB_TUT_HOLDBALL", 5000)
                            gCheckForBallTimer = nil
                        else
                            gPlayerHasBall = false
                        end
                    end
                end
                Wait(0)
            end
            Wait(1000)
            bDialogueThreadRunning = false
            if DodgeballGetWinner() == 0 then
                F_AnimateTeam(true)
                missionSuccess = true
                gMatchesWon = gMatchesWon + 1
                if 2 <= gMatchesWon then
                    if gGrade then
                        PlayerSetGrade(6, gGrade)
                    end
                    if gGrade then
                        SoundFadeoutStream()
                        SoundPlayMissionEndMusic(true, 9)
                        MinigameSetGrades(6, gGrade - 1)
                        while MinigameIsShowingGrades() do
                            Wait(0)
                        end
                        if gGrade == 5 then
                            endPresentation = true
                        end
                    else
                        MinigameSetCompletion("DBG_WON", true, 1500, F_GetScoreText())
                        while not MinigameIsFadingCompletion() do
                            Wait(0)
                        end
                    end
                    gDodgeballActive = false
                else
                    MinigameSetCompletion("DBG_WON", true, 0, F_GetScoreText())
                    while not MinigameIsFadingCompletion() do
                        Wait(0)
                    end
                end
            else
                F_AnimateTeam(false)
                gMatchesLost = gMatchesLost + 1
                if 2 <= gMatchesLost then
                    gDodgeballActive = false
                    if gGrade then
                        SoundFadeoutStream()
                        SoundPlayMissionEndMusic(false, 9)
                        MinigameSetGrades(6, gGrade - 1)
                        while MinigameIsShowingGrades() do
                            Wait(0)
                        end
                    end
                else
                    MinigameSetCompletion("DBG_LOST", true, 0, F_GetScoreText())
                    while not MinigameIsFadingCompletion() do
                        Wait(0)
                    end
                end
            end
            if gDodgeballActive then
                SoundFadeWithCamera(false)
                MusicFadeWithCamera(false)
            end
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME + 100)
            if gSoundLooping then
                SoundLoopPlay2D("CrowdCheers", false)
                gSoundLooping = false
            end
            F_CleanupDodgeball()
            if endPresentation then
                CameraSetWidescreen(true)
                CameraLookAtXYZ(-610.51184, -60.444046, 60.750626, true)
                CameraSetXYZ(-613.52075, -59.238907, 61.594936, -610.51184, -60.444046, 60.750626)
                PedIgnoreStimuli(referee, true)
                PedStop(referee)
                PedClearObjectives(referee)
                PedFaceHeading(referee, 90, 0)
                CameraFade(-1, 1)
                F_PlaySpeechAndWait(referee, "DODGEBALL", 29, "jumbo", true)
                CameraFade(-1, 0)
                Wait(FADE_OUT_TIME)
                CameraReturnToPlayer()
                CameraReset()
                CameraSetWidescreen(false)
            end
            --print("********************** SOUND STOP STREAM")
            AllowAreaTransitions(true)
        else
            CameraFade(1000, 1)
            Wait(1100)
            SoundFadeWithCamera(true)
            MusicFadeWithCamera(true)
        end
        Wait(0)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if 2 <= gMatchesWon then
        if gGrade then
            F_CleanupDodgeball()
            F_CleanupDodgeballPeds()
            PlayerSetPosSimple(-621.3, -60, 59.6)
            PlayerFaceHeadingNow(103)
            CameraSetWidescreen(true)
            CameraSetXYZ(-623.0122, -59.272133, 60.80008, -622.0705, -59.59584, 60.88535)
            F_MakePlayerSafeForNIS(true)
            PlayerSetControl(0)
            if PlayerHasItem(306) then
                LoadModels({ 306 }, true)
                PedSetWeaponNow(gPlayer, 306, 1, false)
            else
                LoadModels({ 303 }, true)
                PedSetWeaponNow(gPlayer, 303, 1, false)
            end
            Wait(1000)
            CameraFade(-1, 1)
            PedSetActionNode(gPlayer, "/Global/DodgeballGame/Anims/Unlock/Charge", "Act/Conv/DodgeballGame.act")
            MinigameSetCompletion("MEN_BLANK", true, 0, "DB_UPGRADE")
            Wait(1000)
            TutorialShowMessage("DB_UNLOCK01", -1, true)
            SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
            while MinigameIsShowingCompletion() do
                Wait(0)
            end
            Wait(1500)
            PedSetActionNode(gPlayer, "/Global/DodgeballGame/Anims/Unlock/Charge/Release/Release", "Act/Conv/DodgeballGame.act")
            Wait(500)
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
            PlayerSetControl(1)
            F_MakePlayerSafeForNIS(false)
            CameraSetWidescreen(false)
            TutorialRemoveMessage()
        end
        MissionSucceed(true, true, false)
    else
        SoundPlayMissionEndMusic(false, 9)
        MissionFail(true, false)
    end
    tblCinematicScript = nil
end

function F_AnimateTeam(bSuccess)
    redTeam = {
        red1,
        red2,
        red3
    }
    blueTeam = {
        blue1,
        blue2,
        blue3,
        blue4
    }
    if bSuccess then
        SoundLoopPlay2D("CrowdCheers", true)
        gSoundLooping = true
        F_ExecuteAnimationSequence(gPlayer, "/Global/DodgeballGame/Anims/CelebrateA", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(red1, "/Global/DodgeballGame/Anims/CelebrateB", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(red2, "/Global/DodgeballGame/Anims/CelebrateC", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(red3, "/Global/DodgeballGame/Anims/CelebrateD", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue1, "/Global/DodgeballGame/Anims/DejectedA", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue2, "/Global/DodgeballGame/Anims/DejectedB", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue3, "/Global/DodgeballGame/Anims/DejectedC", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue4, "/Global/DodgeballGame/Anims/DejectedD", "Act/Conv/DodgeballGame.act")
        SoundPlayScriptedSpeechEvent(redTeam[math.random(1, 3)], "VICTORY_TEAM", 0, "large")
        Wait(2000)
        SoundPlayScriptedSpeechEvent(blueTeam[math.random(1, 4)], "DEFEAT_TEAM", 0, "large")
    elseif not bSuccess then
        F_ExecuteAnimationSequence(blue1, "/Global/DodgeballGame/Anims/CelebrateA", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue2, "/Global/DodgeballGame/Anims/CelebrateB", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue3, "/Global/DodgeballGame/Anims/CelebrateC", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(blue4, "/Global/DodgeballGame/Anims/CelebrateD", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(gPlayer, "/Global/DodgeballGame/Anims/DejectedA", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(red1, "/Global/DodgeballGame/Anims/DejectedB", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(red2, "/Global/DodgeballGame/Anims/DejectedC", "Act/Conv/DodgeballGame.act")
        F_ExecuteAnimationSequence(red3, "/Global/DodgeballGame/Anims/DejectedD", "Act/Conv/DodgeballGame.act")
        SoundPlayScriptedSpeechEvent(blueTeam[math.random(1, 4)], "VICTORY_TEAM", 0, "large")
        Wait(2000)
        SoundPlayScriptedSpeechEvent(redTeam[math.random(1, 3)], "DEFEAT_TEAM", 0, "large")
    end
end

function F_DialogueMonitor()
    while bDialogueThreadRunning do
        if PedIsHit(gPlayer, 2, 100) then
            SoundPlayScriptedSpeechEvent(gPlayer, "DODGEBALL_KO", 2)
            Wait(2000)
        end
        if GetTimer() - encourageTime >= encourageMaxTime then
            SoundPlayScriptedSpeechEvent(referee, "DODGEBALL", math.random(1, 2))
            encourageMaxTime = math.random(10, 20) * 1000
            encourageTime = GetTimer()
        end
        Wait(0)
    end
    collectgarbage()
end

function F_GetScoreText()
    if gMatchesWon == 0 and gMatchesLost == 0 then
        return "DBG_SCORE00"
    elseif gMatchesWon == 1 and gMatchesLost == 0 then
        return "DBG_SCORE10"
    elseif gMatchesWon == 0 and gMatchesLost == 1 then
        return "DBG_SCORE01"
    elseif gMatchesWon == 1 and gMatchesLost == 1 then
        return "DBG_SCORE11"
    end
end

function F_ConvStartFadeOut()
    StartFadeout = true
end

function F_CleanupCamPeds()
    peds = {
        camcoach,
        camred1,
        camred2,
        camred3,
        camblue1,
        camblue2,
        camblue3,
        camblue4
    }
    for i, ped in peds do
        if PedIsValid(ped) then
            PedDelete(ped)
        end
    end
end

function F_CleanupDodgeballPeds()
    peds = {
        red1,
        red2,
        red3,
        blue1,
        blue2,
        blue3,
        blue4,
        referee
    }
    for i, ped in peds do
        if PedIsValid(ped) then
            PedDelete(ped)
        end
    end
end

function F_ResetDodgeballPedsLoc()
    F_ResetWrapper(red1, POINTLIST._DBALL_RED1)
    F_ResetWrapper(red2, POINTLIST._DBALL_RED2)
    F_ResetWrapper(red3, POINTLIST._DBALL_RED3)
    F_ResetWrapper(blue1, POINTLIST._DBALL_BLUE1)
    F_ResetWrapper(blue2, POINTLIST._DBALL_BLUE2)
    F_ResetWrapper(blue3, POINTLIST._DBALL_BLUE3)
    F_ResetWrapper(blue4, POINTLIST._DBALL_BLUE4)
end

function F_ResetWrapper(pedId, point)
    if PedIsValid(pedId) then
        local x, y, z = GetPointList(point)
        PedSetPosXYZ(pedId, x, y, z)
    end
end

function F_CreateDodgeballPeds()
    red1 = F_CreateCamPed(208, POINTLIST._DBALL_RED1)
    red2 = F_CreateCamPed(210, POINTLIST._DBALL_RED2)
    red3 = F_CreateCamPed(209, POINTLIST._DBALL_RED3)
    blue1 = F_CreateCamPed(teamTable[nCurrentStage].p1, POINTLIST._DBALL_BLUE1)
    blue2 = F_CreateCamPed(teamTable[nCurrentStage].p2, POINTLIST._DBALL_BLUE2)
    blue3 = F_CreateCamPed(teamTable[nCurrentStage].p3, POINTLIST._DBALL_BLUE3)
    blue4 = F_CreateCamPed(teamTable[nCurrentStage].p4, POINTLIST._DBALL_BLUE4)
    referee = F_CreateCamPed(55, POINTLIST._DBALL_COACH)
    PedSetWeaponNow(gPlayer, -1, 0)
    Wait(0)
    E3DodgeballHackCleanObjects()
    PedSetAlpha(gPlayer, 100, false)
end

function F_DodgeballSetup()
    DodgeballInit()
    DodgeballSetPed(0, 0, 0, "DB_Ped.act", "DB_Ped", "DB_Hit.act", "DBHit", "Default", "1", "C2_idPlayer")
    DodgeballSetPed(0, 1, red1, "DB_Ped.act", "DB_Ped", "DB_Hit.act", "DBHit", "Default", "1", "C2_Algie")
    DodgeballSetPed(0, 2, red2, "DB_Ped.act", "DB_Ped", "DB_Hit.act", "DBHit", "Default", "1", "C2_Thad")
    DodgeballSetPed(0, 3, red3, "DB_Ped.act", "DB_Ped", "DB_Hit.act", "DBHit", "Default", "1", "C2_Bucky")
    DodgeballSetPed(1, 0, blue1, teamTable[nCurrentStage].script1, teamTable[nCurrentStage].node1, teamTable[nCurrentStage].aiscript1, teamTable[nCurrentStage].ainode1, teamTable[nCurrentStage].p1AI, teamTable[nCurrentStage].difficulty, teamTable[nCurrentStage].name1)
    DodgeballSetPed(1, 1, blue2, teamTable[nCurrentStage].script2, teamTable[nCurrentStage].node2, teamTable[nCurrentStage].aiscript2, teamTable[nCurrentStage].ainode2, teamTable[nCurrentStage].p2AI, teamTable[nCurrentStage].difficulty, teamTable[nCurrentStage].name2)
    DodgeballSetPed(1, 2, blue3, teamTable[nCurrentStage].script3, teamTable[nCurrentStage].node3, teamTable[nCurrentStage].aiscript3, teamTable[nCurrentStage].ainode3, teamTable[nCurrentStage].p3AI, teamTable[nCurrentStage].difficulty, teamTable[nCurrentStage].name3)
    DodgeballSetPed(1, 3, blue4, teamTable[nCurrentStage].script4, teamTable[nCurrentStage].node4, teamTable[nCurrentStage].aiscript4, teamTable[nCurrentStage].ainode4, teamTable[nCurrentStage].p4AI, teamTable[nCurrentStage].difficulty, teamTable[nCurrentStage].name4)
    DodgeballSetPed(2, 0, referee, "DB_Ped.act", "DB_Ped", "DB_Hit.act", "DBHit", "Default", "1", "C2_Bucky")
end

function F_RunText()
    local i, tblEntry
    local bSkip = false
    for i, tblEntry in textTable[nCurrentStage] do
        if tblEntry.textid ~= nil then
            bSkip = WaitSkippable((tblEntry.time + 1) * 1000)
            if bSkip then
                break
            end
        end
    end
end

function F_FindFirstCam()
    local cameraID, paramID
    local cameraFound = false
    for i, entry in tblCinematicScript[nCurrentStage] do
        if entry.cameraName ~= nil and not cameraFound then
            cameraID = entry.cameraName
            F_CamLookPicker(i)
            cameraFound = true
        end
    end
    return cameraID
end

function F_FakeWait(time)
    local waitStart = GetTimer()
    local bSkipped = false
    while time >= GetTimer() - waitStart do
        if IsButtonPressed(7, 0) then
            bSkipped = true
            break
        end
        Wait(0)
    end
end

function F_RunCinematic()
    local cameraStart = F_FindFirstCam()
    PlayerSetControl(0)
    SoundDisableSpeech_ActionTree()
    CameraSetWidescreen(true)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    CameraSetSpeed(0.01, 0.01, 0.01)
    CameraSetPath(cameraStart, true)
    for i, entry in tblCinematicScript[nCurrentStage] do
        if entry.cameraName ~= nil then
            F_CamLookPicker(i)
            CameraSetPath(entry.cameraName, entry.snap)
            if entry.speedEaseIn ~= nil and entry.speedEaseOut ~= nil and entry.speedMax ~= nil then
                CameraSetSpeed(entry.speedMax, entry.speedEaseIn, entry.speedEaseOut)
            end
            F_FakeWait(entry.time)
        elseif entry.animatePed ~= nil then
            AnimQueue(entry.time, entry.animatePed, entry.animString)
            Wait(0)
        elseif entry.val then
            TextQueue(entry.val, entry.tTime, entry.style, entry.isText, entry.priority, entry.textSpeechEvent, entry.textSpeechIndex)
            Wait(0)
        elseif entry.moveToPoint then
            F_MoveToPositions()
        end
    end
    bThreadRunning = false
    CameraFade(1000, 0)
    Wait(1100)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    SoundEnableSpeech_ActionTree()
end

function F_CamLookPicker(index)
    if tblCinematicScript[nCurrentStage][index].targetType == CAM_HEADING then
        CameraLookAtPath(tblCinematicScript[nCurrentStage][index].targetParam, tblCinematicScript[nCurrentStage][index].snap)
        CameraLookAtPathSetSpeed(tblCinematicScript[nCurrentStage][index].speedMax, tblCinematicScript[nCurrentStage][index].speedEaseIn, tblCinematicScript[nCurrentStage][index].speedEaseOut)
    elseif tblCinematicScript[nCurrentStage][index].targetType == CAM_PED then
        CameraLookAtObject(tblCinematicScript[nCurrentStage][index].targetParam, 2, tblCinematicScript[nCurrentStage][index].snap)
    elseif tblCinematicScript[nCurrentStage][index].targetType == CAM_PEDOFFSET then
        local lookX, lookY, lookZ = PedGetPosXYZ(tblCinematicScript[nCurrentStage][index].targetParam)
        CameraLookAtXYZ(lookX, lookY, lookZ + tblCinematicScript[nCurrentStage][index].offset, tblCinematicScript[nCurrentStage][index].snap)
    elseif tblCinematicScript[nCurrentStage][index].targetType == CAM_POINT then
        local lookX, lookY, lookZ = GetPointFromPointList(tblCinematicScript[nCurrentStage][index].targetParam, 1)
        CameraLookAtXYZ(lookX, lookY, lookZ, tblCinematicScript[nCurrentStage][index].snap)
    end
end

function F_ExecuteAnimationSequence(ped, actionNode, fileName)
    if actionNode then
        while not PedIsPlaying(ped, actionNode, true) do
            Wait(0)
            PedSetActionNode(ped, actionNode, fileName)
        end
    end
end

function F_MoveToPositions()
    PedMoveToPoint(gPlayer, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 1)
    PedMoveToPoint(camred1, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 2)
    PedMoveToPoint(camred2, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 3)
    PedMoveToPoint(camred3, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 4)
    PedMoveToPoint(camblue1, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 5)
    PedMoveToPoint(camblue2, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 6)
    PedMoveToPoint(camblue3, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 7)
    PedMoveToPoint(camblue4, 1, POINTLIST._DBALLCAM_RUNPOSITIONS, 8)
end

local gTextQueue = {}
local gTextQueueTimer = 0
local gTextWaitTimer = 0
local gStartPrinting = false

function TextQueue(val, tTime, style, isText, priority, tEvent, tIndex)
    if table.getn(gTextQueue) <= 0 then
        gStartPrinting = true
    end
    if priority then
        table.insert(gTextQueue, 1, {
            textVal = val,
            textTime = tTime,
            bText = isText,
            tStyle = style
        })
    else
        table.insert(gTextQueue, {
            textVal = val,
            textTime = tTime,
            bText = isText,
            tStyle = style,
            textSpeechEvent = tEvent,
            textSpeechIndex = tIndex
        })
    end
end

function CheckTextQueue()
    if table.getn(gTextQueue) > 0 then
        if gStartPrinting then
            gTextQueueTimer = GetTimer()
            gTextWaitTimer = gTextQueue[1].textTime
            if gTextQueue[1].textVal ~= -1 then
                if gTextQueue[1].bText then
                else
                end
                SoundPlayScriptedSpeechEvent(camcoach, gTextQueue[1].textSpeechEvent, gTextQueue[1].textSpeechIndex, "speech", true)
            end
            gStartPrinting = false
        end
        if GetTimer() - gTextQueueTimer >= gTextWaitTimer then
            gStartPrinting = true
            local tempBool = false
            table.remove(gTextQueue, 1)
        end
    end
end

function TextQueueThread()
    while bThreadRunning do
        CheckTextQueue()
        Wait(0)
    end
    collectgarbage()
end

local gAnimQueue = {}
local gAnimQueueTimer = GetTimer()
local gAnimWaitTimer = 50000
local gStartAnim = false

function AnimQueue(tTime, idPed, strAnim)
    table.insert(gAnimQueue, {
        time = tTime,
        ped = idPed,
        anim = strAnim
    })
end

function CheckAnimQueue()
    if table.getn(gAnimQueue) > 0 then
        if gAnimQueue[1].time ~= nil then
            gAnimWaitTimer = gAnimQueue[1].time
        else
            gAnimWaitTimer = 500000
        end
        if GetTimer() - gAnimQueueTimer >= gAnimWaitTimer then
            gStartanim = true
            F_ExecuteAnimationSequence(gAnimQueue[1].ped, gAnimQueue[1].anim, "Act/Conv/DodgeballGame.act")
            table.remove(gAnimQueue, 1)
        end
    end
end

function AnimQueueThread()
    while bThreadRunning do
        CheckAnimQueue()
        Wait(0)
    end
    collectgarbage()
end

function F_SetupStage(param)
    nCurrentStage = param
    if param == 1 then
        gGrade = 2
        gCheckForBallTimer = true
    elseif param == 2 then
        gGrade = 4
    elseif param == 3 then
        gGrade = 5
    elseif 3 < param then
        if param == 8 then
            nCurrentStage = math.random(1, 4)
            gRandomMatch = true
        else
            nCurrentStage = param - 3
        end
        gNonClassDodgeball = true
    end
    if shared.JockVendettaRunning then
        nCurrentStage = 3
        --print("Setting the Jock Vendetta Difficulty")
        teamTable[1].difficulty = "5"
        teamTable[2].difficulty = "5"
        teamTable[3].difficulty = "5"
        teamTable[4].difficulty = "5"
        teamTable[5].difficulty = "5"
    end
    bStageLoaded = true
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
        PlayerSetPosPoint(POINTLIST._PLAYERBUSTED)
        LoadModels({ prefectModel })
        prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
        PedStop(prefect)
        PedClearObjectives(prefect)
        PedIgnoreStimuli(prefect, true)
        PedSetInvulnerable(prefect, true)
        PedFaceObject(gPlayer, prefect, 2, 0)
        PedFaceObject(prefect, gPlayer, 3, 1, false)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraLookAtXYZ(-647.591, -60.377666, 56.458607, true)
        CameraSetXYZ(-645.588, -57.811245, 56.65822, -647.591, -60.377666, 56.458607)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C31Strt/PlayerFail", "Act/Conv/C3_1.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C31Strt/Clear", "Act/Conv/C3_1.act")
        local x, y, z = GetPointFromPointList(POINTLIST._PLAYERBUSTED, 2)
        PedFollowPath(gPlayer, PATH._BUSTEDPATH, 0, 0)
        Wait(1000)
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME + 110)
        if not ClothingIsWearingOutfit("Gym Strip") then
            ClothingBackup()
            ClothingSetPlayerOutfit("Gym Strip")
            ClothingBuildPlayer()
        end
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        Wait(1000)
        PlayerSetPosPoint(POINTLIST._DBALL_PLAYER)
        PedSetActionNode(gPlayer, "/Global/C31Strt/Clear", "Act/Conv/C3_1.act")
        CameraFade(-1, 1)
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
