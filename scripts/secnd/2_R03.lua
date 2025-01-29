--[[ Changes to this file:
    * Removed local variable bTestBlip, not present in original script
    * Modified function T_OldLadyHazardSpawn, may require testing
    * Modified function OldLadyHazardCreate, may require testing
    * Modified function EggerHazardCreate, may require testing
    * Modified function MailManHazardsCreate, may require testing
    * Modified function CarHazardsCreate, may require testing
    * Modified function DogHazardsCreate, may require testing
]]

--local bTestBlip = false
local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local gMissionState
local TIER_TUTORIAL = 0
local TIER_REPEATABLE = 1
local gCurrentTier
local TIER_REWARD_PER_PAPER = 200
local MAILBOXES_CREATE = 0
local MAILBOXES_DELETE = 1
local gObjective, gBonusCustomersMessage
local gDeliveredPapers = 0
local gMissionTime, gMailBoxes
local gMinPapers = 0
local gReward = 0
local gMaxPapers = 30
local gBike, gDogHazards, gCarHazards, gMailManHazards, gEggersHazards, gOldLady, gOrderly, gJogger, bCarHazardsCreated, bDogHazardsCreated
local gDifficulty = GetMissionSuccessCount("2_R03_X")
local bMissionDone = false

function F_SetPaperRouteTier(tier)
    --print(">>>[RUI]", "!!F_SetPaperRouteTier")
    local t = tier or TIER_REPEATABLE
    gCurrentTier = t
end

function F_FirstPaperDelivered()
    if bPaperDelivered then
        return 1
    else
        return 0
    end
end

function F_MissionDone()
    if bMissionDone then
        return 1
    else
        return 0
    end
end

function PaperRouteInit(tier)
    --print(">>>[RUI]", "!!PaperRouteInit")
    dx, dy, dz = GetPointFromPointList(POINTLIST._PR_CARMOVETO, 1)
    WeaponRequestModel(320)
    gCarModels = { 293, 294 }
    gDogModels = { 219, 220 }
    gMailboxPedModels = {
        101,
        100,
        101,
        144,
        148,
        149,
        135
    }
    gDrivers = {
        78,
        79,
        80,
        81
    }
    LoadModels(gCarModels)
    LoadModels(gDogModels)
    LoadModels(gMailboxPedModels)
    LoadModels(gDrivers)
    LoadModels({
        116,
        281,
        55,
        185,
        53,
        30
    })
    F_SetCharacterModelsUnique(true, gDogModels)
    F_SetCharacterModelsUnique(true, {
        116,
        127,
        185,
        53,
        30,
        55
    })
    LoadActionTree("Act/Conv/2_R03.act")
    if PlayerIsInAnyVehicle() then
        --print(">>>[RUI]", "MissinSetup: clear the bike")
        local bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleDelete(bike)
    end
    Wait(200)
    SoundPlayInteractiveStream("MS_BikeFunLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_BikeFunHigh.rsm", MUSIC_DEFAULT_VOLUME)
    PlayerSetControl(0)
    if tier == 0 then
        PlayerSetPosPoint(POINTLIST._2_R03_PLAYERSTART, 1)
        Tier00Init()
        NIS_Intro()
    else
        PlayerSetPosPoint(POINTLIST._2_R03_PLAYERSTART, 2)
        Tier01Init()
    end
    MailBoxesInit()
    DogHazardsCreate()
    CarHazardsCreate()
    MailManHazardsCreate()
    EggerHazardCreate()
    PaperRouteHud(true, gMinPapers)
    if not gBike then
        gBike = VehicleCreatePoint(281, POINTLIST._2_R03_BIKESTART)
    end
    PlayerPutOnBike(gBike)
    while not PlayerIsInVehicle(gBike) do
        Wait(0)
    end
    Wait(500)
    gFakeStack = PickupCreatePoint(320, POINTLIST._2_R03_PAPERDROP)
end

function Tier00Init()
    --print(">>>[RUI]", "++Tier00Init")
    gMissionTime = 60
    gBonusCustomersMessage = "2_R03_PASS01"
    gMinPapers = 7
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX06
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09,
            pedPt = POINTLIST._PR_MAILBOXPED09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12,
            pedPt = POINTLIST._PR_MAILBOXPED12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART00,
            point = POINTLIST._PR_MAILBOXDOG00,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_DOGSTART01,
            point = POINTLIST._PR_MAILBOXDOG01,
            bActive = true
        }
    }
    gCarHazards = {
        {
            trigger = TRIGGER._PR_CARSTART03,
            point = POINTLIST._PR_CARSPAWN03,
            path = PATH._PR_CARPATH03,
            speed = 7,
            bActive = true
        }
    }
end

function Tier01Init()
    if gDifficulty == 0 then
        Tier01SetupDifficulty01()
    elseif gDifficulty == 1 then
        Tier01SetupDifficulty02()
    elseif gDifficulty == 2 then
        Tier01SetupDifficulty03()
    elseif 3 <= gDifficulty then
        Tier01SetupDifficulty04()
    end
end

function Tier01SetupDifficulty01()
    gMissionTime = 2 * 60
    gMinPapers = 10
    gBonusCustomersMessage = "2_R03_PASS02"
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12,
            pedPt = POINTLIST._PR_MAILBOXPED12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART02,
            point = POINTLIST._PR_MAILBOXDOG02,
            bActive = true
        }
    }
    gCarHazards = {
        {
            trigger = TRIGGER._PR_CARSTART02,
            point = POINTLIST._PR_CARSPAWN02,
            path = PATH._PR_CARPATH02,
            speed = 7,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_CARSTART03,
            point = POINTLIST._PR_CARSPAWN03,
            path = PATH._PR_CARPATH03,
            speed = 7,
            bActive = true
        }
    }
    --print(">>>[RUI]", "++Tier01SetupDifficulty01")
end

function Tier01SetupDifficulty02()
    gMissionTime = 2 * 60
    gMinPapers = 14
    gBonusCustomersMessage = "2_R03_PASS03"
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12,
            pedPt = POINTLIST._PR_MAILBOXPED12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21,
            pedPt = POINTLIST._PR_MAILBOXPED21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART02,
            point = POINTLIST._PR_MAILBOXDOG02,
            bActive = true
        }
    }
    gCarHazards = {
        {
            trigger = TRIGGER._PR_CARSTART01,
            point = POINTLIST._PR_CARSPAWN01,
            path = PATH._PR_CARPATH01,
            speed = 7,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_CARSTART02,
            point = POINTLIST._PR_CARSPAWN02,
            path = PATH._PR_CARPATH02,
            speed = 7,
            bActive = true
        }
    }
    gMailManHazards = {
        {
            trigger = TRIGGER._PR_MAILMANSTART01,
            point = POINTLIST._PR_MAILMAN01,
            bActive = true
        }
    }
    gEggersHazards = {
        {
            point = POINTLIST._PR_EGGER02,
            bActive = true
        }
    }
    --print(">>>[RUI]", "++Tier01SetupDifficulty02")
end

function Tier01SetupDifficulty03()
    gMissionTime = 2 * 60
    gMinPapers = 19
    gBonusCustomersMessage = "2_R03_PASS03"
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX01
        },
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX04
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX06
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12,
            pedPt = POINTLIST._PR_MAILBOXPED12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15,
            pedPt = POINTLIST._PR_MAILBOXPED15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        },
        {
            id = TRIGGER._RICH_MAILBOX23
        },
        {
            id = TRIGGER._RICH_MAILBOX24
        },
        {
            id = TRIGGER._RICH_MAILBOX25
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART03,
            point = POINTLIST._PR_MAILBOXDOG03,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_DOGSTART04,
            point = POINTLIST._PR_MAILBOXDOG04,
            bActive = true
        }
    }
    gCarHazards = {
        {
            trigger = TRIGGER._PR_CARSTART01,
            point = POINTLIST._PR_CARSPAWN01,
            path = PATH._PR_CARPATH01,
            speed = 7,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_CARSTART02,
            point = POINTLIST._PR_CARSPAWN02,
            path = PATH._PR_CARPATH02,
            speed = 7,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_CARSTART04,
            point = POINTLIST._PR_CARSPAWN04,
            path = PATH._PR_CARPATH04,
            speed = 7,
            bActive = true
        }
    }
    gEggersHazards = {
        {
            point = POINTLIST._PR_EGGER01,
            bActive = true
        },
        {
            point = POINTLIST._PR_EGGER02,
            bActive = true
        },
        {
            point = POINTLIST._PR_EGGER03,
            bActive = true
        },
        {
            point = POINTLIST._PR_EGGER04,
            bActive = true
        }
    }
    HazardsRandomize(gEggersHazards, 1)
    CreateThread("T_OldLadyHazardSpawn")
    CreateThread("T_JoggerHazardSpawn")
    --print(">>>[RUI]", "++Tier01SetupDifficulty03")
end

function Tier01SetupDifficulty04()
    gMissionTime = 3 * 60
    gMinPapers = 24
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX01
        },
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX04
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX06
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15,
            pedPt = POINTLIST._PR_MAILBOXPED15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21,
            pedPt = POINTLIST._PR_MAILBOXPED21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        },
        {
            id = TRIGGER._RICH_MAILBOX23
        },
        {
            id = TRIGGER._RICH_MAILBOX24
        },
        {
            id = TRIGGER._RICH_MAILBOX25
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART00,
            point = POINTLIST._PR_MAILBOXDOG00
        },
        {
            trigger = TRIGGER._PR_DOGSTART01,
            point = POINTLIST._PR_MAILBOXDOG01
        },
        {
            trigger = TRIGGER._PR_DOGSTART02,
            point = POINTLIST._PR_MAILBOXDOG02
        },
        {
            trigger = TRIGGER._PR_DOGSTART03,
            point = POINTLIST._PR_MAILBOXDOG03
        },
        {
            trigger = TRIGGER._PR_DOGSTART04,
            point = POINTLIST._PR_MAILBOXDOG04
        }
    }
    HazardsRandomize(gDogHazards, 2)
    gCarHazards = {
        {
            trigger = TRIGGER._PR_CARSTART01,
            point = POINTLIST._PR_CARSPAWN01,
            path = PATH._PR_CARPATH01,
            speed = 7
        },
        {
            trigger = TRIGGER._PR_CARSTART02,
            point = POINTLIST._PR_CARSPAWN02,
            path = PATH._PR_CARPATH02,
            speed = 7
        },
        {
            trigger = TRIGGER._PR_CARSTART03,
            point = POINTLIST._PR_CARSPAWN03,
            path = PATH._PR_CARPATH03,
            speed = 7
        },
        {
            trigger = TRIGGER._PR_CARSTART04,
            point = POINTLIST._PR_CARSPAWN04,
            path = PATH._PR_CARPATH04,
            speed = 7
        },
        {
            trigger = TRIGGER._PR_CARSTART05,
            point = POINTLIST._PR_CARSPAWN05,
            path = PATH._PR_CARPATH05,
            speed = 7
        }
    }
    HazardsRandomize(gCarHazards, 2)
    gMailManHazards = {
        {
            trigger = TRIGGER._PR_MAILMANSTART01,
            point = POINTLIST._PR_MAILMAN01,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_MAILMANSTART02,
            point = POINTLIST._PR_MAILMAN02,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_MAILMANSTART03,
            point = POINTLIST._PR_MAILMAN03,
            bActive = true
        }
    }
    HazardsRandomize(gMailManHazards, 2)
    gEggersHazards = {
        {
            point = POINTLIST._PR_EGGER01,
            bActive = true
        },
        {
            point = POINTLIST._PR_EGGER02,
            bActive = true
        },
        {
            point = POINTLIST._PR_EGGER03,
            bActive = true
        },
        {
            point = POINTLIST._PR_EGGER04,
            bActive = true
        }
    }
    HazardsRandomize(gEggersHazards, 1)
    local roll = math.random(100)
    if 50 <= roll then
        CreateThread("T_OldLadyHazardSpawn")
    end
    roll = math.random(100)
    if 50 <= roll then
        CreateThread("T_JoggerHazardSpawn")
    end
    --print(">>>[RUI]", "++Tier01SetupDifficulty04")
end

gOldLadyEvents = {
    "BUMP_RUDE",
    "TAUNT",
    "INDIGNANT",
    "BOISTEROUS"
}

function T_OldLadyHazardSpawn() -- ! Modified
    local roll = math.random(100)
    bNorth = false
    ladyTrigger = TRIGGER._PR_OLDLADYSOUTHSTART
    if 50 <= roll then
        bNorth = true
        ladyTrigger = TRIGGER._PR_OLDLADYNORTHSTART
        --print(">>>[RUI]", "T_OldLadyHazardSpawn Chose North event")
        while gMissionState == MISSION_RUNNING and MissionActive() do
            if PlayerIsInTrigger(ladyTrigger) then
                OldLadyHazardCreate(bNorth)
                break
            end
            Wait(0)
        end
    end
    --print(">>>[RUI]", "++T_OldLadyHazardSpawn")
    --[[
    while gMissionState == MISSION_RUNNING and MissionActive() do
        if PlayerIsInTrigger(ladyTrigger) then
            OldLadyHazardCreate(bNorth)
            break
        end
        Wait(0)
    end
    ]]-- Moved inside previous if
    --print(">>>[RUI]", "--T_OldLadyHazardSpawn")
    Wait(3000)
    gSpeechTimer = GetTimer()
    while gMissionState == MISSION_RUNNING do
        if gSpeechTimer then
            if TimerPassed(gSpeechTimer) then
                SoundPlayScriptedSpeechEvent(gOrderly, "TAUNT_AGGRO", 0, "large")
                Wait(1000)
                event = RandomTableElement(gOldLadyEvents)
                SoundPlayScriptedSpeechEvent(gOldLady, event, 0, "large")
                gSpeechTimer = nil
            end
        else
            gSpeechTimer = GetTimer() + 5000
        end
        Wait(0)
    end
    collectgarbage()
end

function OldLadyHazardCreate(bNorth) -- ! Modified
    if bNorth then
        oldlady = POINTLIST._PR_OLDLADYNORTH
        orderly = POINTLIST._PR_ORDERLYNORTH
        oldladyPath = PATH._PR_OLDLADYNORTHPATH
    else
        oldlady = POINTLIST._PR_OLDLADYSOUTH
        orderly = POINTLIST._PR_ORDERLYSOUTH
        oldladyPath = PATH._PR_OLDLADYSOUTHPATH
    end
    gOldLady = PedCreatePoint(185, oldlady, 1)
    PedSetInfiniteSprint(gOldLady, true)
    PedFollowPath(gOldLady, oldladyPath, 1, 2)
    --[[
    if bTestBlip then
        AddBlipForChar(gOldLady, 0, 2, 1)
    end
    ]]-- Not present in original script
    gOrderly = PedCreatePoint(53, orderly, 1)
    PedSetTetherToPed(gOrderly, gOldLady, 10)
    --print(">>>[RUI]", "++OldLadyHazardCreate")
end

function OldLadyHazardCleanup()
    PedCleanup(gOldLady)
    PedCleanup(gOrderly)
    --print(">>>[RUI]", "--OldLadyHazardCleanup")
end

function JoggerHazardCreate()
    --print(">>>[RUI]", "++JoggerHazardCreate")
    gJogger = PedCreatePoint(55, POINTLIST._PR_JOGGER, 1)
    PedFollowPath(gJogger, PATH._PR_JOGGERPATH, 2, 2)
end

function JoggerHazardCleanup()
    if F_PedExists(gJogger) then
        PedStop(gJogger)
        PedMakeAmbient(gJogger)
    end
    --print(">>>[RUI]", "--JoggerHazardCleanup")
end

function T_JoggerHazardSpawn()
    --print(">>>[RUI]", "++T_JoggerHazardSpawn")
    while gMissionState == MISSION_RUNNING and MissionActive() do
        if PlayerIsInTrigger(TRIGGER._PR_JOGGERTRIGGER) then
            JoggerHazardCreate()
            break
        end
        Wait(0)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_JoggerHazardSpawn")
end

function EggerHazardCreate() --! Modified
    if not gEggersHazards then
        return -1
    end
    for _, egger in gEggersHazards do
        if egger.bActive then
            egger.id = PedCreatePoint(30, egger.point, 1)
            --[[
            if bTestBlip then
                AddBlipForChar(egger.id, 0, 2, 1)
            end
            ]]-- -- Not present in original script
            PedSetWeapon(egger.id, 312, 4)
            PedCoverSet(egger.id, gPlayer, egger.point, 1, 15, 1, 0, 0, 0, 3, 0, 0, 1, 1, true)
            PedSetPedToTypeAttitude(egger.id, 13, 0)
        end
    end
    bEggerHazardCreated = true
    --print(">>>[RUI]", "++EggerHazardCreate")
end

function EggerHazardCleanup()
    if not bEggerHazardCreated then
        return
    end
    for _, egger in gEggersHazards do
        if F_PedExists(egger.id) then
            PedStop(egger.id)
            PedMakeAmbient(egger.id)
        end
    end
    --print(">>>[RUI]", "++EggerHazardCleanup")
end

function MailManHazardsCreate() -- ! Modified
    if not gMailManHazards then
        return -1
    end
    --print(">>>[RUI]", "++MailManHazardsCreate")
    for _, MailMan in gMailManHazards do
        if MailMan.bActive then
            MailMan.id = PedCreatePoint(127, MailMan.point, 1)
            PedSetTetherToPoint(MailMan.id, MailMan.point, 1, 5)
            --[[
            if bTestBlip then
                AddBlipForChar(MailMan.id, 0, 2, 1)
            end
            ]]-- Not present in original script
        end
    end
    bMailManHazardsCreated = true
end

function T_MailManHazardsMonitor()
    --print(">>>[RUI]", "++T_MailManHazardsMonitor")
    if bMailManHazardsCreated then
        while gMissionState == MISSION_RUNNING and MissionActive() do
            for _, MailMan in gMailManHazards do
                if MailMan and MailMan.id and not MailMan.bAttacking and PlayerIsInTrigger(MailMan.trigger) then
                    PedClearTether(MailMan.id)
                    PedAttack(MailMan.id, gPlayer, 1, true)
                    MailMan.bAttacking = true
                    --print(">>>[RUI]", "T_MailManHazardsMonitor send MailMan")
                end
            end
            Wait(20)
        end
        --print(">>>[RUI]", "NO MailManS")
    end
    --print(">>>[RUI]", "--T_MailManHazardsMonitor")
    collectgarbage()
end

function MailManHazardsCleanup()
    if not gMailManHazards then
        return
    end
    for _, MailMan in gMailManHazards do
        PedCleanup(MailMan.id)
    end
    bMailManHazardsCreated = false
    --print(">>>[RUI]", "--MailManHazardsCleanup")
end

function CarHazardsCreate() -- ! Modified
    --print(">>>[RUI]", "++CarHazardsCreate")
    if not gCarHazards then
        return -1
    end
    for _, car in gCarHazards do
        if car.bActive then
            car.driver = PedCreatePoint(RandomTableElement(gDrivers), POINTLIST._PR_DRIVERSPAWN, 1)
            PedIgnoreStimuli(car.driver, true)
            PedSetCheap(car.driver, true)
            PedSetFlag(car.driver, 108, true)
            PedAddPedToIgnoreList(car.driver, gPlayer)
            PedMakeTargetable(car.driver, false)
            PedSetAsleep(car.driver, true)
            PedIgnoreAttacks(car.driver, true)
            Wait(50)
            car.id = VehicleCreatePoint(RandomTableElement(gCarModels), car.point, 1)
            PedWarpIntoCar(car.driver, car.id)
            while not PedIsInVehicle(car.driver, car.id) do
                Wait(0)
            end
            VehicleEnableEngine(car.id, true)
            --[[
            if bTestBlip then
                AddBlipForChar(car.driver, 0, 2, 1)
            end
            ]]-- Not present in original script
        end
    end
    bCarHazardsCreated = true
end

local px, py, cx, cy

function PlayerFarEnoughFromCar(car)
    px, py = PlayerGetPosXYZ()
    cx, cy = VehicleGetPosXYZ(car)
    if DistanceBetweenCoords2d(px, py, cx, cy) >= 70 then
        --print(">>>[RUI]", "PlayerFarEnoughFromCar YES")
        return true
    else
        return false
    end
end

function T_CarHazardsMonitor()
    --print(">>>[RUI]", "++T_CarHazardsMonitor")
    if bCarHazardsCreated then
        while gMissionState == MISSION_RUNNING and MissionActive() do
            for _, car in gCarHazards do
                if car and car.id then
                    if not car.bTriggered then
                        if PlayerIsInTrigger(car.trigger) then
                            --print(">>>[RUI]", "T_CarHazardsMonitor send Car")
                            VehicleSetCruiseSpeed(car.id, car.speed)
                            VehicleFollowPath(car.id, car.path, true)
                            car.bTriggered = true
                        end
                    elseif not car.bDriveOff then
                        if not VehicleIsInTrigger(car.id, car.trigger) then
                            --print(">>>[RUI]", "T_CarHazardsMonitor car drive off")
                            if F_PedExists(car.driver) and PedIsInVehicle(car.driver, car.id) then
                                VehicleStop(car.id)
                                Wait(100)
                                VehicleMoveToXYZ(car.id, dx, dy, dz, 12)
                                car.bDriveOff = true
                            else
                                PedWarpIntoCar(car.driver, car.id)
                            end
                        end
                    elseif PlayerFarEnoughFromCar(car.id) then
                        --print(">>>[RUI]", "T_CarHazardsMonitor remove car")
                        VehicleStop(car.id)
                        VehicleDelete(car.id)
                        car.id = nil
                        car = nil
                    end
                end
            end
            Wait(10)
        end
        --print(">>>[RUI]", "NO CARS")
    end
    --print(">>>[RUI]", "--T_CarHazardsMonitor")
    collectgarbage()
end

function CarHazardsCleanup(bForce)
    if not gCarHazards then
        return
    end
    for _, car in gCarHazards do
        if car.id then
            CarCleanup(car, bForce)
        end
    end
    bCarHazardsCreated = false
    --print(">>>[RUI]", "--CarHazardsCleanup")
end

function DogHazardsCreate() -- ! Modified
    if not gDogHazards then
        return -1
    end
    --print(">>>[RUI]", "++DogHazardsCreate")
    for _, dog in gDogHazards do
        if dog.bActive then
            dog.id = PedCreatePoint(RandomTableElement(gDogModels), dog.point, 1)
            PedSetTetherToPoint(dog.id, dog.point, 1, 5)
            --[[
            if bTestBlip then
                AddBlipForChar(dog.id, 0, 2, 1)
            end
            ]]-- Not present in original script
        end
    end
    bDogHazardsCreated = true
end

function T_DogHazardsMonitor()
    --print(">>>[RUI]", "++T_DogHazardsMonitor")
    if bDogHazardsCreated then
        while gMissionState == MISSION_RUNNING and MissionActive() do
            for _, dog in gDogHazards do
                if dog and dog.id and not dog.bAttacking and PlayerIsInTrigger(dog.trigger) then
                    PedClearTether(dog.id)
                    PedAttack(dog.id, gPlayer, 1, true)
                    dog.bAttacking = true
                    --print(">>>[RUI]", "T_DogHazardsMonitor send dog")
                end
            end
            Wait(20)
        end
        --print(">>>[RUI]", "NO DOGS")
    end
    --print(">>>[RUI]", "--T_DogHazardsMonitor")
    collectgarbage()
end

function DogHazardsCleanup()
    if not gDogHazards then
        return
    end
    for _, dog in gDogHazards do
        PedCleanup(dog.id)
    end
    bDogHazardsCreated = false
    --print(">>>[RUI]", "--DogHazardsCleanup")
end

function HazardsRandomize(hazardTbl, limit)
    local roll
    local limitCount = 0
    for _, hazard in hazardTbl do
        roll = math.random(100)
        if 50 <= roll then
            hazard.bActive = true
            limitCount = limitCount + 1
            if limit <= limitCount then
                break
            end
        else
            hazard.bActive = false
        end
    end
end

function cbMailBoxHit(mailBox)
    --print(">>>[RUI]", "cbMailBoxHit " .. tostring(mailBox))
    local mailbox = MailBoxesFindBox(mailBox)
    if mailbox and not mailbox.bDelivered then
        bPaperDelivered = true
        TutorialStart("BUSTPREFNIGHT")
        if bTutorialOn then
            bTutorialOn = false
        end
        CounterIncrementCurrent(1)
        if mailbox.ped then
            MailBoxPedThank(mailbox.ped)
        end
        mailbox.blip = BlipCleanup(mailbox.blip)
        gReward = gReward + TIER_REWARD_PER_PAPER
        gDeliveredPapers = gDeliveredPapers + 1
        PAnimMakeTargetable(mailbox.id, false)
        mailbox.bDelivered = true
        --print(">>>[RUI]", "cbMailBoxHit reward: " .. tostring(gReward) .. " papers:" .. tostring(gDeliveredPapers))
    end
end

function MailBoxPedThank(ped)
    PedClearTether(ped)
    PedSetActionNode(ped, "/Global/2_R03_Conv/Animations/ThankYou", "Act/Conv/2_R03.act")
    PedMakeAmbient(ped)
    --print(">>>[RUI]", "!!MailBoxPedThank")
end

function MailBoxesFindBox(trigger)
    --print(">>>[RUI]", "!!MailBoxesFindBox")
    for _, mailbox in gMailBoxes do
        if mailbox.id == trigger then
            return mailbox
        end
    end
    return nil
end

local bx, by, bz

function MailBoxesInit()
    --print(">>>[RUI]", "++MailBoxesInit")
    for _, mailbox in gMailBoxes do
        PAnimCreate(mailbox.id)
        PAnimMakeTargetable(mailbox.id, true)
        PAnimEnableStreaming(mailbox.id, false)
        if mailbox.pedPt then
            mailbox.ped = MailBoxPedCreate(mailbox.pedPt)
        end
    end
end

function MailBoxPedCreate(point)
    local guy = PedCreatePoint(RandomTableElement(gMailboxPedModels), point, 1)
    PedSetPedToTypeAttitude(guy, 13, 4)
    PedSetFlag(guy, 68, true)
    PedSetTetherToPoint(guy, point, 1, 2)
    --print(">>>[RUI]", "++MailBoxPedCreate")
    return guy
end

function MailBoxesCleanup()
    --print(">>>[RUI]", "--MailBoxesCleanup")
    MailBoxesBlip(false)
    for _, mailbox in gMailBoxes do
        PAnimDelete(mailbox.id)
        PedCleanup(mailbox.ped)
    end
end

local bx, by, bz

function MailBoxesBlip(bOn)
    --print(">>>[RUI]", "++MailBoxesBlip " .. tostring(bOn))
    for _, mailbox in gMailBoxes do
        if bOn then
            if not mailbox.bDelivered then
                bx, by, bz = GetAnchorPosition(mailbox.id)
                mailbox.blip = BlipAddXYZ(bx, by, bz, 0, 4)
                BlipSetShortRanged(mailbox.blip, true)
                --print(">>>[RUI]", "++MailBoxesBlip " .. tostring(mailbox.blip))
            end
        else
            mailbox.blip = BlipCleanup(mailbox.blip)
        end
    end
end

function MailBoxesClearAmbient()
    shared.MailboxesRespawn = MAILBOXES_DELETE
    AreaForceLoadAreaByAreaTransition(true)
    --print(">>>[RUI]", "--MailBoxesClearAmbient")
end

function MailBoxesRestoreAmbient()
    shared.MailboxesRespawn = MAILBOXES_CREATE
    AreaForceLoadAreaByAreaTransition(true)
    --print(">>>[RUI]", "++MailBoxesRestoreAmbient")
end

function FailMission(message)
    bMissionDone = true
    gFailMessage = message
    gMissionState = MISSION_FAIL
    gCurrentStage = nil
    --print(">>>[RUI]", "--FailMission " .. tostring(message))
end

function PaperRouteHud(bOn, maxPapers)
    if bOn then
        CounterSetCurrent(0)
        CounterSetMax(maxPapers)
        CounterSetIcon("mailbox", "mailbox_x")
        CounterMakeHUDVisible(true)
    else
        CounterMakeHUDVisible(false)
        CounterClearIcon()
        CounterSetCurrent(0)
        CounterSetMax(0)
        CounterClearText()
        CounterClearIcon()
    end
end

function NIS_Intro()
    --print(">>>[RUI]", "!!NIS_Intro")
    F_MakePlayerSafeForNIS(true)
    CameraSetFOV(70)
    CameraSetXYZ(409.28677, 244.62155, 10.363867, 409.75677, 243.74342, 10.451683)
    gBike = VehicleCreatePoint(281, POINTLIST._2_R03_BIKESTART)
    gNewsMan = PedCreatePoint(116, POINTLIST._2_R03_VENDOR)
    Wait(200)
    PedFaceObjectNow(gPlayer, gNewsMan, 2)
    PedFaceObjectNow(gNewsMan, gPlayer, 2)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    CameraSetFOV(70)
    CameraFade(FADE_IN_TIME, 1)
    Wait(FADE_IN_TIME)
    PlaySpeechNode(gNewsMan, "/Global/2_R03_Conv/IntroNIS/M_2_R03_01", 1)
    CameraSetFOV(50)
    CameraSetXYZ(410.25504, 238.29808, 10.296689, 410.8849, 239.06924, 10.381994)
    PlaySpeechNode(gPlayer, "/Global/2_R03_Conv/IntroNIS/M_2_R03_02", 2)
    CameraSetFOV(50)
    CameraSetXYZ(409.88898, 242.38374, 10.378567, 410.62692, 241.71104, 10.424344)
    PlaySpeechNode(gNewsMan, "/Global/2_R03_Conv/IntroNIS/M_2_R03_03", 3)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME)
    MakeAmbient(gNewsMan)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    CameraDefaultFOV()
end

function PlaySpeechNode(ped, node, event)
    --print(">>>[RUI]", "!!PlaySpeechNode " .. tostring(node))
    PedSetActionNode(ped, node, "Act/Conv/2_R03.act")
    SoundPlayScriptedSpeechEvent(ped, "M_2_R03", event, "large")
    while SoundSpeechPlaying(ped) do
        Wait(0)
    end
end

function TimerPassed(time)
    return time < GetTimer()
end

function NIS_Tutorial()
    PlayerSetControl(0)
    if not PickupIsPickedUp(gFakeStack) then
        PickupDelete(gFakeStack)
    end
    NISBlipOn(true, TRIGGER._RICH_MAILBOX03)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    mx, my, mz = GetAnchorPosition(TRIGGER._RICH_MAILBOX03)
    CameraLookAtXYZ(mx, my, mz, true)
    CameraSetPath(PATH._2_R03_INTROCAM, true)
    TutorialShowMessage("2_R03_05", 4000, true)
    Wait(4000)
    FollowCamSetVehicleShot("PaperRoute")
    CameraSetWidescreen(false)
    NISBlipOn(false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
end

function NISBlipOn(bOn, trigger)
    if bOn then
        local bx, by, bz = GetAnchorPosition(trigger)
        gNISBlip = BlipAddXYZ(bx, by, bz, 0, 2)
    else
        gNISBlip = BlipCleanup(gNISBlip)
    end
end

function CarCleanup(car, bForce)
    if car and VehicleIsValid(car.id) then
        --print(">>>[RUI]", "--CarCleanup")
        VehicleStop(car.id)
        if not car.bDriveOff then
            PedWarpIntoCar(car.driver, car.id)
            if PedIsInVehicle(car.driver, car.id) then
                VehicleMoveToXYZ(car.id, dx, dy, dz, 12)
            end
        end
        if bForce then
            VehicleDelete(car.id)
        else
            VehicleMakeAmbient(car.id, false)
        end
    end
end

function PedCleanup(ped)
    if F_PedExists(ped) then
        --print(">>>[RUI]", "--PedCleanup")
        PedMakeAmbient(ped)
    end
end

function BlipCleanup(blip)
    --print(">>>[RUI]", "--BlipCleanup " .. tostring(blip))
    if blip and blip ~= -1 then
        BlipRemove(blip)
    end
    return nil
end

function AnimationGroupsLoad(bLoad, groups)
    if bLoad then
        if groups then
            gAnimationGroups = groups
            for _, group in gAnimationGroups do
                LoadAnimationGroup(group)
            end
            --print(">>>[RUI]", "++AnimationGroupsLoad LOAD")
        end
    elseif gAnimationGroups then
        for _, group in gAnimationGroups do
            UnLoadAnimationGroup(group)
        end
        --print(">>>[RUI]", "--AnimationGroupsLoad UNLOAD")
    end
end

function MakeAmbient(ped, bForce)
    if F_PedExists(ped) then
        if bForce then
            PedDelete(ped)
        else
            PedMakeAmbient(ped)
        end
    end
end

function UpdateObjectiveLog(newObjStr, oldObj, bUseParam, param)
    local newObj
    if newObjStr then
        if bUseParam then
            newObj = MissionObjectiveAdd(newObjStr, 1, -1)
            MissionObjectiveUpdateParam(newObj, 1, param)
            TextAddParamNum(param)
            TextPrintF(newObjStr, 5, 1)
        else
            newObj = MissionObjectiveAdd(newObjStr, 0, -1)
            TextPrint(newObjStr, 5, 1)
        end
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function BlipBike(bOn)
    if bOn then
        if not gBikeBlip then
            gBikeBlip = AddBlipForCar(gBike, 0, 4)
        end
    elseif gBikeBlip then
        gBikeBlip = BlipCleanup(gBikeBlip)
    end
end

function Stage01_GetToHillInit()
    --print(">>>[RUI]", "Stage01_GetToHillInit")
    PlayerSetControl(1)
    gObjectiveBlip = BlipAddPoint(POINTLIST._2_R03_HILLTOP, 0, 1, 1, 7)
    gObjective = UpdateObjectiveLog("2_R03_OBJ01", nil)
    if gCurrentTier == TIER_TUTORIAL then
        gCurrentStage = Stage01_GetToHillTutorialLoop
    else
        gCurrentStage = Stage01_GetToHillJobLoop
    end
    MissionTimerStart(35)
end

function Stage01_GetToHillTutorialLoop()
    if PlayerIsInTrigger(TRIGGER._PR_HILLTOP) then
        NIS_Tutorial()
        bTutorialOn = true
        TutorialStart("HIDING2X")
        gObjective = UpdateObjectiveLog("2_R03_OBJ02", gObjective, true, gMinPapers)
        gCurrentStage = Stage02_DeliverPapersInit
    end
    if MissionTimerHasFinished() then
        MissionTimerStop()
        FailMission("2_R03_FAIL04")
        return
    end
end

function Stage01_GetToHillJobLoop()
    if PlayerIsInTrigger(TRIGGER._PR_PAPERPICKUPTRIGGER) then
        if not PickupIsPickedUp(gFakeStack) then
            PickupDelete(gFakeStack)
        end
        gObjective = UpdateObjectiveLog("2_R03_OBJ02", gObjective, true, gMinPapers)
        gCurrentStage = Stage02_DeliverPapersInit
    end
    if MissionTimerHasFinished() then
        MissionTimerStop()
        FailMission("2_R03_FAIL05")
        return
    end
end

function Stage02_DeliverPapersInit()
    --print(">>>[RUI]", "Stage02_DeliverPapersInit")
    gObjectiveBlip = BlipCleanup(gObjectiveBlip)
    MailBoxesBlip(true)
    if not PlayerHasWeapon(320) then
        --print(">>>[RUI]", "Stage02_DeliverPapersInit SAFETY add papers")
        PedSetWeaponNow(gPlayer, 320, gMaxPapers)
    end
    CreateThread("T_DogHazardsMonitor")
    CreateThread("T_CarHazardsMonitor")
    CreateThread("T_MailManHazardsMonitor")
    MissionTimerStart(gMissionTime)
    gPaperTimer = nil
    gCurrentStage = Stage02_DeliverPapersLoop
end

function Stage02_DeliverPapersLoop()
    if MissionTimerHasFinished() or gDeliveredPapers >= gMinPapers then
        MissionTimerStop()
        if gDeliveredPapers >= gMinPapers then
            gMissionState = MISSION_PASS
        else
            FailMission("2_R03_FAIL02")
        end
        gCurrentStage = nil
        return
    end
    if F_RanOutOfPapers() then
        FailMission("2_R03_FAIL03")
        return
    end
end

function F_RanOutOfPapers()
    if gPaperTimer then
        if TimerPassed(gPaperTimer) then
            gPaperTimer = GetTimer() + 4000
            return not PlayerHasItem(320)
        end
    else
        gPaperTimer = GetTimer() + 4000
    end
    return false
end

function MissionSetup()
    MissionDontFadeIn()
    MailBoxesClearAmbient()
    PedSetPunishmentPoints(gPlayer, 0)
    DATLoad("PaperRoute.DAT", 2)
    DATLoad("Mailboxes_Rich.DAT", 2)
    DATInit()
    RadarSetMinMax(30, 65, 30)
    AnimationGroupsLoad(true, {
        "NIS_0_00A",
        "F_Adult",
        "2_R03PaperRoute",
        "SBULL_S"
    })
    LoadActionTree("Act/Props/MailBox.act")
    SoundEnableInteractiveMusic(false)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PR_HILLTOPEXCLUDER, true)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PAPERROUTE_EXCLUDER, true)
    AreaOverridePopulation(2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0)
    VehicleOverrideAmbient(2, 1, 1, 0)
    DisablePOI(true, true)
    AreaClearAllVehicles()
    AreaClearAllPeds()
    shared.gDisableBusStops = true
end

function MissionCleanup()
    bMissionDone = true
    RadarRestoreMinMax()
    shared.gDisableBusStops = false
    F_SetCharacterModelsUnique(false)
    MissionTimerStop()
    PaperRouteHud(false)
    SoundEnableInteractiveMusic(true)
    F_MakePlayerSafeForNIS(false, true)
    CameraSetWidescreen(false)
    MailBoxesCleanup()
    MailBoxesRestoreAmbient()
    if gFakeStack and gFakeStack ~= -1 and not PickupIsPickedUp(gFakeStack) then
        PickupDelete(gFakeStack)
    end
    DogHazardsCleanup()
    CarHazardsCleanup()
    OldLadyHazardCleanup()
    JoggerHazardCleanup()
    EggerHazardCleanup()
    MailManHazardsCleanup()
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PR_HILLTOPEXCLUDER, false)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PAPERROUTE_EXCLUDER, false)
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    EnablePOI(true, true)
    AnimationGroupsLoad(false)
    DATUnload(2)
    PedSetGlobalSleep(false)
    FollowCamDefaultVehicleShot()
    SoundStopInteractiveStream()
    PedDestroyWeapon(gPlayer, 320)
end

function main()
    --print(">>>[RUI]", "++Tier01Init difficulty: " .. tostring(gDifficulty))
    while not gCurrentTier do
        Wait(0)
    end
    gMissionState = MISSION_RUNNING
    PaperRouteInit(gCurrentTier)
    FollowCamSetVehicleShot("PaperRoute")
    Wait(1000)
    CameraFade(FADE_IN_TIME, 1)
    Wait(FADE_IN_TIME)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    gCurrentStage = Stage01_GetToHillInit
    while gMissionState == MISSION_RUNNING do
        if gCurrentStage then
            gCurrentStage()
        end
        Wait(0)
    end
    MissionTimerStop()
    PedDestroyWeapon(gPlayer, 320)
    MailBoxesBlip(false)
    TextPrint("", 8, 1)
    TutorialRemoveMessage()
    Wait(100)
    CameraSetWidescreen(true)
    if gMissionState == MISSION_PASS then
        bMissionDone = true
        StatAddToInt(171, gReward)
        SoundPlayMissionEndMusic(true, 8)
        if gBonusCustomersMessage then
            MinigameSetCompletion("M_PASS", true, gReward, gBonusCustomersMessage)
        else
            MinigameSetCompletion("M_PASS", true, gReward)
        end
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraSetWidescreen(false)
        MissionSucceed(false, false, false)
    else
        SoundPlayMissionEndMusic(false, 8)
        if gFailMessage then
            bMissionDone = true
            --print(">>>[RUI]", "MAIN MissionFail(true, true, gFailMessage)")
            MissionFail(true, true, gFailMessage)
        else
            bMissionDone = true
            --print(">>>[RUI]", "")
            MissionFail(true, true)
        end
    end
end
