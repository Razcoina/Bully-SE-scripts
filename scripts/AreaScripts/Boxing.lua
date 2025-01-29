--[[ Changes to this file:
    * Modified function F_TrophyCaseFullCreate, may require testing
    * Modified function F_TrophyCaseBustedCreate, may require testing
]]

local gTrophyProps = {}
local sweater_guard
local shirtMI = ObjectNameToHashID("R_Sweater1")
local shirt2MI = ObjectNameToHashID("R_Sweater5")
local playerShirtMI = ClothingGetPlayer(1)
local refuse = false
local PB1, PB2, PB3, Box1Stat, Box2Stat
local BoxerRequest = false
local BoxersLoaded = false
local BoxersCreated = false
local PBPLoaded = false
local Boxer1, Boxer2, Boxer3
local EventsOn = false
local tblDoors = {}
local EventsKilled = false
local g203Corona

function IsMission2_03Available()
    local hour, minute = ClockGet()
    return not IsMissionCompleated("2_03") and IsMissionCompleated("3_R09_P3") and hour <= 23 and 8 <= hour
end

function main()
    AreaSetPopulationSexGeneration(false, true)
    DATLoad("iboxing.DAT", 0)
    DATLoad("SP_BoxingRing.DAT", 0)
    LoadActionTree("Act/AI/AI_Punchbag.act")
    LoadActionTree("Act/Anim/PunchBagBS.act")
    LoadActionTree("Act/Conv/2_03i.act")
    LoadAnimationGroup("NIS_2_03")
    LoadPedPOIModels({
        31,
        233,
        118,
        117,
        36
    })
    BoxersLoaded = true
    PBPLoaded = true
    DATLoad("eventsBoxing.DAT", 0)
    if MissionActiveSpecific("2_03") or MissionActiveSpecific2("2_R11_Chad") or MissionActiveSpecific2("2_R11_Justin") or MissionActiveSpecific2("2_R11_Parker") or MissionActiveSpecific2("2_R11_Bryce") or MissionActiveSpecific2("2_R11_Random") or MissionActiveSpecific("3_R09_P3") or MissionActiveSpecific("2_09") or MissionActiveSpecific("2_B") then
        EventsOn = false
    else
        EventsOn = true
    end
    F_PreDATInit()
    DATInit()
    F_InitializeDoors()
    shared.gAreaDataLoaded = true
    shared.gAreaDATFileLoaded[27] = true
    if not MissionActive() then
        if IsMission2_03Available() then
            --print(">>>[RUI]", "BOXING add sweater guard")
            sweater_guard = PedCreatePoint(31, POINTLIST._IBOXING_TAD_SWEATER)
            PedSetHealth(sweater_guard, 1)
            PedIgnoreStimuli(sweater_guard, true)
            PedIgnoreAttacks(sweater_guard, true)
            bSweaterCheckOn = true
            CreateThread("T_Sweater_Check")
        else
            bSweaterCheckOn = false
        end
    end
    if IsMissionCompleated("5_01") or MissionActiveSpecific("5_02") then
        F_TrophyCaseBustedCreate()
    else
        F_TrophyCaseFullCreate()
    end
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._BOXINGTURFTRIGGER, 5)
    F_CreatePunchBags()
    if EventsOn == true then
        CreateThread("F_Boxers")
        CreateThread("F_PunchBagPrep")
    else
        AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    end
    while not (AreaGetVisible() ~= 27 or SystemShouldEndScript()) do
        if (MissionActiveSpecific("2_03") or MissionActiveSpecific2("2_R11_Chad") or MissionActiveSpecific2("2_R11_Justin") or MissionActiveSpecific2("2_R11_Parker") or MissionActiveSpecific2("2_R11_Bryce") or MissionActiveSpecific2("2_R11_Random") or MissionActiveSpecific("3_R09_P3") or MissionActiveSpecific("2_09") or MissionActiveSpecific("2_B")) and EventsKilled == false then
            EventsKilled = true
            --print("KILLING EVENTS!!!!!!!!!!!!!!!!!!!!!!!")
            F_ResetBoxers()
            AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            AreaSetPopulationSexGeneration(false, true)
            DisablePOI(true, true)
            AreaClearAllPeds()
            EventsOn = false
        end
        Wait(0)
    end
    F_TrophyCaseRemove()
    DATUnload(0)
    DATUnload(5)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[27] = false
    if EventsOn == true then
        F_ResetBoxers()
    end
    AreaSetPopulationSexGeneration(true, true)
    EnablePOI()
    AreaRevertToDefaultPopulation()
    collectgarbage()
end

function F_TrophyCaseFullCreate() -- ! Modified
    --[[
    local index, simpleObject = CreatePersistentEntity("BX_loungeBWG", -736.848, 382.395, 300.476, 0, 27)
    ]] -- Changes to:
    local index, simpleObject = CreatePersistentEntity("BX_loungeBWG", -736.784, 382.395, 300.476, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("DPI_TrophyGlsA", -736.527, 384.586, 299.311, 90, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("DPI_TrophyGlsB", -736.53, 384.584, 299.932, 90, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("DPI_TrophyGlsC", -736.527, 383.798, 299.725, 90, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("DPI_TrophyGlsA", -736.527, 382.294, 299.311, 90, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("DPI_TrophyGlsB", -736.53, 382.295, 299.932, 90, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("DPI_TrophyGlsC", -736.527, 383.079, 299.725, 90, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyF", -736.718, 382.151, 299.279, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyG", -736.981, 382.524, 299.269, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyE", -736.861, 381.925, 299.231, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyC", -736.648, 382.334, 299.664, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyA", -736.658, 382.011, 299.746, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyB", -736.925, 382.163, 299.82, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyD", -736.928, 382.498, 299.84, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyH", -736.792, 383.093, 299.589, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyI", -736.758, 383.799, 299.305, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyM", -736.864, 384.377, 299.283, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyN", -736.986, 384.699, 299.273, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyO", -736.856, 384.974, 299.246, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyL", -736.783, 384.912, 299.742, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyK", -736.79, 384.601, 299.836, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyJ", -736.816, 384.296, 299.742, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
    index, simpleObject = CreatePersistentEntity("BX_DTrophyP", -736.784, 385.537, 299.786, 0, 27)
    table.insert(gTrophyProps, { id = index, object = simpleObject })
end

function F_TrophyCaseBustedCreate() -- ! Modified
    if gTrophyProps and table.getn(gTrophyProps) > 0 then
        F_TrophyCaseRemove()
    end
    gTrophyProps = {}
    --[[
    local caseI, caseObject = CreatePersistentEntity("BX_loungeBWB", -736.848, 382.395, 300.476, 0, 27)
    ]] -- Changed to:
    local caseI, caseObject = CreatePersistentEntity("BX_loungeBWB", -736.801, 382.395, 300.476, 0, 27)
    table.insert(gTrophyProps, { id = caseI, object = caseObject })
end

function F_TrophyCaseRemove()
    for _, thing in gTrophyProps do
        if thing then
            DeletePersistentEntity(thing.id, thing.object)
        end
    end
end

function F_PlayerHasAquaberrySweater()
    local shirtMI = ObjectNameToHashID("R_Sweater1")
    local shirt2MI = ObjectNameToHashID("R_Sweater5")
    local playerShirtMI = ClothingGetPlayer(1)
    return playerShirtMI == shirtMI or playerShirtMI == shirt2MI
end

function TimerPassed(time)
    return time < GetTimer()
end

function HandleFakeCorona_203()
    if not gInsideCorona and PlayerIsInTrigger(TRIGGER._IBOXING_FAKECORONATRIGGER) then
        TextPrint("BOX_SWEATER", 5, 1)
        TutorialShowMessage("TUT_AQUA1", 5000, false)
        gInsideCorona = true
    elseif gInsideCorona and not PlayerIsInTrigger(TRIGGER._IBOXING_FAKECORONATRIGGER) then
        gInsideCorona = false
    end
end

function T_Sweater_Check()
    while not (AreaGetVisible() ~= 27 or SystemShouldEndScript()) do
        while MissionActive() do
            Wait(0)
        end
        if F_PlayerHasAquaberrySweater() then
            if F_PedExists(sweater_guard) then
                PedDelete(sweater_guard)
            end
            bSweaterCheckOn = false
        else
            HandleFakeCorona_203()
            if F_PedExists(sweater_guard) and PlayerIsInTrigger(TRIGGER._IBOXING_SWEATER_TRIG) and bSweaterCheckOn and not F_PlayerHasAquaberrySweater() then
                F_MakePlayerSafeForNIS(true)
                PedClearHitRecord(sweater_guard)
                PedStop(sweater_guard)
                TutorialRemoveMessage()
                CameraSetWidescreen(true)
                CameraSetXYZ(-733.6162, 370.13602, 299.5328, -734.5477, 369.7767, 299.4793)
                PlayerSetControl(0)
                PedStop(gPlayer)
                PedSetActionNode(sweater_guard, "/Global/2_03i/animations/TadReject/Rebuff", "Act/Conv/2_03i.act")
                Wait(100)
                while SoundSpeechPlaying(sweater_guard) do
                    Wait(0)
                end
                Wait(2000)
                CameraFade(500, 0)
                Wait(1000)
                PlayerSetPosPoint(POINTLIST._IBOXING_NO_SWEATER)
                CameraReturnToPlayer()
                CameraSetWidescreen(false)
                Wait(1000)
                CameraFade(500, 1)
                F_MakePlayerSafeForNIS(false)
                PlayerSetControl(1)
                TextPrint("BOX_SWEATER", 5, 1)
                TutorialStart("AQUASTORE")
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function F_CreatePunchBags()
    PB1 = PedCreatePoint(233, POINTLIST._PUNCHBAGS, 1)
    PedModelNotNeededAmbient(PB1)
    PedSetAITree(PB1, "/Global/PunchbagAI", "Act/AI/AI_Punchbag.act")
    PedSetActionTree(PB1, "/Global/PunchBagBS", "Act/Anim/PunchBagBS.act")
    PedSetFaction(PB1, 12)
    PB2 = PedCreatePoint(233, POINTLIST._PUNCHBAGS, 2)
    PedModelNotNeededAmbient(PB2)
    PedSetAITree(PB2, "/Global/PunchbagAI", "Act/AI/AI_Punchbag.act")
    PedSetActionTree(PB2, "/Global/PunchBagBS", "Act/Anim/PunchBagBS.act")
    PedSetFaction(PB2, 12)
    PB3 = PedCreatePoint(233, POINTLIST._PUNCHBAGS, 3)
    PedModelNotNeededAmbient(PB3)
    PedSetAITree(PB3, "/Global/PunchbagAI", "Act/AI/AI_Punchbag.act")
    PedSetActionTree(PB3, "/Global/PunchBagBS", "Act/Anim/PunchBagBS.act")
    PedSetFaction(PB3, 12)
end

function F_Boxers()
    Box1Stat = PedGetUniqueModelStatus(34)
    PedSetUniqueModelStatus(34, -1)
    Box2Stat = PedGetUniqueModelStatus(32)
    PedSetUniqueModelStatus(32, -1)
    BoxerRequest = true
    while BoxersLoaded == false do
        Wait(0)
    end
    Boxer1 = PedCreatePoint(118, POINTLIST._BOXING_PLAYERSTART1)
    PedModelNotNeededAmbient(Boxer1)
    Boxer2 = PedCreatePoint(117, POINTLIST._BOXING_ENEMYSTART1)
    PedModelNotNeededAmbient(Boxer2)
    PedSetFaction(Boxer1, 6)
    PedSetFaction(Boxer2, 6)
    PedSetFlag(Boxer1, 106, false)
    PedSetFlag(Boxer2, 106, false)
    PedSetFlag(Boxer1, 58, true)
    PedSetFlag(Boxer2, 58, true)
    PedAttack(Boxer1, Boxer2, 3)
    PedAttack(Boxer2, Boxer1, 3)
    PedSetTetherToTrigger(Boxer1, TRIGGER._BOXINGTETHER)
    PedSetTetherToTrigger(Boxer2, TRIGGER._BOXINGTETHER)
    BoxersLoaded = false
    BoxersCreated = true
end

function F_ResetBoxers()
    if PedIsValid(Boxer1) then
        PedSetFlag(Boxer1, 58, false)
        Wait(0)
        PedDelete(Boxer1)
    end
    if PedIsValid(Boxer2) then
        PedSetFlag(Boxer2, 58, false)
        Wait(0)
        PedDelete(Boxer2)
    end
    if PedIsValid(Boxer3) then
        PedDelete(Boxer3)
    end
    if BoxersCreated == true then
        PedSetUniqueModelStatus(34, Box1Stat)
        PedSetUniqueModelStatus(32, Box2Stat)
        PedSetUniqueModelStatus(35, Box3Stat)
    end
end

function F_PunchBagPrep()
    while not PBPLoaded == true do
        Wait(0)
    end
    Box3Stat = PedGetUniqueModelStatus(35)
    PedSetUniqueModelStatus(35, -1)
    Boxer3 = PedCreatePoint(36, POINTLIST._PUNCHBAGPREP)
    PedModelNotNeededAmbient(Boxer3)
    PedAttack(Boxer3, PB3, 0)
end

function F_InitializeDoors()
    tblDoors = {
        "iboxing_ESCDoorL",
        "iboxing_ESCDoorL01"
    }
    for _, entry in tblDoors do
        AreaSetDoorLocked(entry, F_BoxingDoorRules(shared.gOverrideBoxingDoors))
        --print("[BOXING] >> Initializing Doors to:", tostring(F_BoxingDoorRules(shared.gOverrideBoxingDoors)))
    end
    tblDoors = nil
end

function F_BoxingDoorRules(bOverride)
    if bOverride == nil then
        if IsMissionCompleated("2_B") and not IsMissionAvailable("3_S10") and not IsMissionAvailable("5_02") then
            return false
        else
            return true
        end
    elseif bOverride == true then
        return true
    elseif bOverride == false then
        return false
    end
end
