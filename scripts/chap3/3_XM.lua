--[[ Changes to this file:
    * Modified function MissionSetup, may require testing
    * Modified function MissionCleanup, may require testing
    * Modified function F_AnimateSanta, may require testing
    * Modified function F_UpdateSanta, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
local TIME_KID_WITH_SANTA = 20000
local TIME_AWAY_FROM_SANTA = 10000
local MAX_DIST_FROM_SANTA = 30
local GET_TO_SQUARE_DISTANCE = 18
local TIME_TO_GET_TO_SQUARE = 35
local MAX_SANTA_DAMAGE_POINTS = 100
local NUM_OBJECTS_TO_DESTROY = 20
local ELF_SPAWN_DELAY = 60000
local FAMILY_SPAWN_DELAY = 10000
local bum, santa
local globalDamagePoints = MAX_SANTA_DAMAGE_POINTS
local santaModel = 253
local bumSantaModel = 252
local kidModel_01 = 138
local kidModel_02 = 137
local kidModel_03 = 66
local kidModel_04 = 69
local parentModel_01 = 80
local parentModel_02 = 81
local parentModel_03 = 76
local elfModel_01 = MODELENUM._TO_ElfM
local elfModel_02 = MODELENUM._TO_ElfF
local elfModel_03 = MODELENUM._TO_ElfM
local elfModel_04 = MODELENUM._TO_ElfF
local elfAttackDelay = ELF_SPAWN_DELAY
local numFamilyModels = 3
local currentFamilyModel = 0
local familyModels = {
    { kid = kidModel_01, parent = parentModel_01 },
    { kid = kidModel_02, parent = parentModel_02 },
    { kid = kidModel_03, parent = parentModel_03 }
}
local tblElfModels = {
    MODELENUM._TO_ElfM,
    MODELENUM._TO_ElfF
}
local numFamilies = 0
local tblFamilyList = {}
local numSpawnPoints = 3
local parentsSpawned = {}
local kidsSpawned = {}
local numInLineup = 0
local numFamiliesAllowed = 5
local numLineupPoints = 4
local numParentPos = 5
local tblLineupList = {}
local tblParentPosList = {}
local bSantaBusy = false
local numElves = 0
local numElvesAttacking = 0
local tblElvesList = {}
local kid_01, kid_02, kid_03, parent_01, parent_02, parent_03, elf_01, elf_02, elf_03, elf_04
local bRunningStartDialog = false
local bClearAllFamiliesCalled = false
local bUpdateElvesRunning = false
local bShowSantaBar = false
local bAreaThreadRunning = false
local bOutOfArea = false
local currentTime = 0
local timeOutOfArea = 0
local bMissionFinised = false

function MissionSetup() -- ! Modified
    WeatherSet(2)
    PlayCutsceneWithLoad("3-01BA", true)
    MissionDontFadeIn()
    ClockSet(19, 30)
    LoadAnimationGroup("NPC_Adult")
    --[[
    LoadAnimationGroup("MIRACLE")
    ]] -- Not present in original script
    LoadPedModels({
        bumSantaModel,
        santaModel,
        kidModel_01,
        kidModel_02,
        kidModel_03,
        kidModel_04,
        parentModel_01,
        parentModel_02,
        parentModel_03,
        elfModel_01,
        elfModel_02
    })
    LoadWeaponModels({ 300, 323 })
    DATLoad("3_XM.DAT", 2)
    DATInit()
    LoadActionTree("Act/Conv/3_XM.act")
    SoundPlayInteractiveStream("MS_XmasJingleMiracleLow.rsm", 0.9, 0, 500)
    SoundSetMidIntensityStream("MS_XmasJingleMiracleMid.rsm", 0.9, 0, 500)
    SoundSetHighIntensityStream("MS_XmasJingleMiracleHigh.rsm", 0.9, 0, 500)
end

function main()
    CameraFade(0, 0)
    PlayerSetControl(0)
    AreaTransitionPoint(0, POINTLIST._3_XM_PLAYERSCENE, 1, false)
    AreaLoadSpecialEntities("Miracle", true)
    AreaEnsureSpecialEntitiesAreCreated()
    AreaSetPathableInRadius(592.2, -84.9, 5.7, 0.5, 5, false)
    AreaSetPathableInRadius(591.2, -84.1, 5.7, 0.5, 5, false)
    AreaSetPathableInRadius(592.1, -89.2, 5.7, 0.5, 5, false)
    AreaSetPathableInRadius(592, -93.6, 5.7, 0.5, 5, false)
    AreaSetPathableInRadius(590.7, -94, 5.7, 0.5, 5, false)
    F_SetupCandlesTable()
    F_SetupCandyCanesTable()
    F_SetupPresentsTable()
    F_SetupSnowmanTable()
    F_SetupSleighTable()
    F_SetupCastleTable()
    F_SetupWeapons()
    while not RequestModel(bumSantaModel) do
        Wait(0)
    end
    while not RequestModel(santaModel) do
        Wait(0)
    end
    while not RequestModel(elfModel_01) do
        Wait(0)
    end
    while not RequestModel(elfModel_02) do
        Wait(0)
    end
    while not RequestModel(kidModel_01) do
        Wait(0)
    end
    while not RequestModel(kidModel_02) do
        Wait(0)
    end
    while not RequestModel(kidModel_03) do
        Wait(0)
    end
    while not RequestModel(kidModel_04) do
        Wait(0)
    end
    while not RequestModel(parentModel_01) do
        Wait(0)
    end
    while not RequestModel(parentModel_02) do
        Wait(0)
    end
    while not RequestModel(parentModel_03) do
        Wait(0)
    end
    bum = PedCreatePoint(bumSantaModel, POINTLIST._3_XM_BUMSCENE)
    PedSetEmotionTowardsPed(bum, gPlayer, 7)
    F_SetupSantaEvent()
    F_SetupSantaQueue()
    F_SetupElves()
    F_GetToSquare()
    CreateThread("F_RunStartDialog")
    CreateThread("F_CheckInArea")
    CreateThread("F_UpdateSantaBar")
    CreateThread("F_UpdateElves")
    CreateThread("F_CheckMissionSuccess")
    F_DestroySnowman()
    F_DestroySleigh()
    F_DestroyCandles()
    F_DestroyPresents()
    F_DestroyCandyCanes()
    F_DestroyCastle()
end

function MissionCleanup() -- ! Modified
    UnpauseGameClock()
    AreaLoadSpecialEntities("Miracle", false)
    AreaRevertToDefaultPopulation()
    AreaEnableAllPatrolPaths() -- Added this
    HideGeneralHealthBar()
    if PedIsValid(bum) == true then
        PedMakeAmbient(bum)
    end
    PedMakeAmbient(santa)
    PedFlee(santa, gPlayer)
    PedDelete(santa)
    UnLoadAnimationGroup("NPC_Adult")
    --[[
    UnLoadAnimationGroup("MIRACLE")
    ]] -- Not present in original script
    WeatherRelease()
    DATUnload(2)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
end

function F_RunIntroScene()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    PlayerSetPunishmentPoints(0)
    PlayerSetPosPoint(POINTLIST._3_XM_PLAYERSCENE, 1)
    PedSetInvulnerable(bum, true)
    PedStop(bum)
    PedClearObjectives(bum)
    PedSetPosPoint(bum, POINTLIST._3_XM_BUMSCENE, 1)
    CameraSetWidescreen(true)
    Wait(1500)
    CameraFade(1000, 1)
    CameraSetXYZ(506.6459, -114.755394, 6.531527, 507.4622, -114.19067, 6.412071)
    PedStop(gPlayer)
    PedIgnoreStimuli(gPlayer, true)
    Wait(3000)
    CameraFade(500, 0)
    Wait(600)
end

function F_SetupWeapons()
    local tblWeapons = { 300, 323 }
    for i = 1, 8 do
        local weapon = PickupCreatePoint(300, POINTLIST._3_XM_WEAPONS, i, 0, "PermanentMission")
    end
end

function F_SetupAmbientPeds()
    AreaDisableAllPatrolPaths()
    SetAmbientPedsIgnoreStimuli(true)
    DisablePOI()
    AreaClearAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllVehicles()
    VehicleOverrideAmbient(0, 0, 0, 0)
end

function F_SetupSantaEvent()
    PlayerSetPosPoint(POINTLIST._3_XM_PLAYERSTART, 1)
    PedSetPosPoint(bum, POINTLIST._3_XM_BUMSTART, 1)
    F_SetupAmbientPeds()
    santa = PedCreatePoint(santaModel, POINTLIST._3_XM_BUMSCENE)
    PedSetPosPoint(santa, POINTLIST._3_XM_SANTASTART, 1)
    PedMakeTargetable(santa, false)
    PedIgnoreStimuli(santa, true)
end

function F_SetupElves()
    --print("[ScottieP]--> F_SetupElves")
    elf_01 = PedCreatePoint(elfModel_01, POINTLIST._3_XM_MIDGETSTART, 1)
    PedSetPosPoint(elf_01, POINTLIST._3_XM_MIDGETSTART, 1)
    elf_02 = PedCreatePoint(elfModel_02, POINTLIST._3_XM_MIDGETSTART, 2)
    PedSetPosPoint(elf_02, POINTLIST._3_XM_MIDGETSTART, 2)
    elf_03 = PedCreatePoint(elfModel_01, POINTLIST._3_XM_MIDGETSTART, 3)
    PedSetPosPoint(elf_03, POINTLIST._3_XM_MIDGETSTART, 3)
    elf_04 = PedCreatePoint(elfModel_02, POINTLIST._3_XM_MIDGETSTART, 4)
    PedSetPosPoint(elf_04, POINTLIST._3_XM_MIDGETSTART, 4)
    PlayerSocialDisableActionAgainstPed(elf_01, 30, true)
    PlayerSocialDisableActionAgainstPed(elf_02, 30, true)
    PlayerSocialDisableActionAgainstPed(elf_03, 30, true)
    PlayerSocialDisableActionAgainstPed(elf_04, 30, true)
    PedIgnoreStimuli(elf_01, true)
    PedIgnoreStimuli(elf_02, true)
    PedIgnoreStimuli(elf_03, true)
    PedIgnoreStimuli(elf_04, true)
    PedSetFlag(elf_01, 68, true)
    PedSetFlag(elf_02, 68, true)
    PedSetFlag(elf_03, 68, true)
    PedSetFlag(elf_04, 68, true)
    numElves = 4
    tblElvesList[1] = {
        elf = elf_01,
        attacking = false,
        position = 1
    }
    tblElvesList[2] = {
        elf = elf_02,
        attacking = false,
        position = 2
    }
    tblElvesList[3] = {
        elf = elf_03,
        attacking = false,
        position = 3
    }
    tblElvesList[4] = {
        elf = elf_04,
        attacking = false,
        position = 4
    }
end

function F_UpdateElves()
    --print("[ScottieP]--> F_UpdateElves")
    local lastTimeCheck = GetTimer()
    local numAttackersCreated = 0
    bUpdateElvesRunning = true
    while bUpdateElvesRunning == true do
        Wait(1000)
        elfAttackDelay = elfAttackDelay + (GetTimer() - lastTimeCheck)
        lastTimeCheck = GetTimer()
        for i, item in tblElvesList do
            if PedIsValid(item.elf) == true and (PedIsDead(item.elf) == true or 0 >= PedGetHealth(item.elf)) then
                PedMakeAmbient(item.elf)
                item.elf = -1
                item.attacking = false
            end
        end
        local currentNumElves = 0
        local currentNumElvesAttacking = 0
        for i, item in tblElvesList do
            if item.elf ~= -1 and PedIsValid(item.elf) and PedIsDead(item.elf) == false and 0 < PedGetHealth(item.elf) then
                currentNumElves = currentNumElves + 1
                if item.attacking == true then
                    currentNumElvesAttacking = currentNumElvesAttacking + 1
                end
            end
        end
        if currentNumElves < numElves then
            for i, item in tblElvesList do
                if item.elf == -1 then
                    local newElf
                    rand = math.random(1, 3)
                    if rand == 1 then
                        newElf = PedCreatePoint(elfModel_01, POINTLIST._3_XM_ELFSPAWN01)
                        PedSetPosPoint(newElf, POINTLIST._3_XM_ELFSPAWN01)
                    elseif rand == 2 then
                        newElf = PedCreatePoint(elfModel_02, POINTLIST._3_XM_ELFSPAWN02)
                        PedSetPosPoint(newElf, POINTLIST._3_XM_ELFSPAWN02)
                    elseif rand == 3 then
                        newElf = PedCreatePoint(elfModel_01, POINTLIST._3_XM_ELFSPAWN03)
                        PedSetPosPoint(newElf, POINTLIST._3_XM_ELFSPAWN03)
                    end
                    item.elf = newElf
                    item.attacking = false
                    PlayerSocialDisableActionAgainstPed(item.elf, 30, true)
                    PedIgnoreStimuli(item.elf, true)
                    PedSetFlag(item.elf, 68, true)
                    PedMoveToPoint(item.elf, 1, POINTLIST._3_XM_MIDGETSTART, item.position)
                end
            end
        end
        if elfAttackDelay >= ELF_SPAWN_DELAY and currentNumElvesAttacking < numElvesAttacking then
            local closestElfIndex = -1
            for i, item in tblElvesList do
                if item.elf ~= -1 and PedIsValid(item.elf) == true and PedIsDead(item.elf) == false and 0 < PedGetHealth(item.elf) and item.attacking == false then
                    local distance = DistanceBetweenPeds3D(item.elf, santa)
                    if closestElfIndex == -1 or distance < DistanceBetweenPeds3D(tblElvesList[closestElfIndex].elf, santa) then
                        closestElfIndex = i
                    end
                end
            end
            if closestElfIndex ~= -1 and PedIsValid(tblElvesList[closestElfIndex].elf) then
                for i, item in tblElvesList do
                    if i == closestElfIndex then
                        PedAttackPlayer(item.elf, 3)
                        item.attacking = true
                        PedSetFlag(item.elf, 68, false)
                        currentNumElvesAttacking = currentNumElvesAttacking + 1
                        numAttackersCreated = numAttackersCreated + 1
                        break
                    end
                end
            end
            if numAttackersCreated >= numElvesAttacking then
                numAttackersCreated = 0
                elfAttackDelay = 0
            end
        end
    end
end

function F_SetupSantaQueue()
    kid_01 = PedCreatePoint(kidModel_01, POINTLIST._3_XM_KIDSTART, 1)
    kid_02 = PedCreatePoint(kidModel_02, POINTLIST._3_XM_KIDSTART, 2)
    kid_03 = PedCreatePoint(kidModel_03, POINTLIST._3_XM_KIDSTART, 3)
    PedSetPosPoint(kid_01, POINTLIST._3_XM_KIDSTART, 1)
    PedSetPosPoint(kid_02, POINTLIST._3_XM_KIDSTART, 2)
    PedSetPosPoint(kid_03, POINTLIST._3_XM_KIDSTART, 3)
    PedMakeTargetable(kid_01, false)
    PedMakeTargetable(kid_02, false)
    PedMakeTargetable(kid_03, false)
    parent_01 = PedCreatePoint(parentModel_01, POINTLIST._3_XM_PARENTSTART, 1)
    parent_02 = PedCreatePoint(parentModel_02, POINTLIST._3_XM_PARENTSTART, 2)
    parent_03 = PedCreatePoint(parentModel_03, POINTLIST._3_XM_PARENTSTART, 3)
    PedSetPosPoint(parent_01, POINTLIST._3_XM_PARENTSTART, 1)
    PedSetPosPoint(parent_02, POINTLIST._3_XM_PARENTSTART, 2)
    PedSetPosPoint(parent_03, POINTLIST._3_XM_PARENTSTART, 3)
    PedMakeTargetable(parent_01, false)
    PedMakeTargetable(parent_02, false)
    PedMakeTargetable(parent_03, false)
    numFamilies = 3
    tblFamilyList[1] = { kid = kid_01, parent = parent_01 }
    tblFamilyList[2] = { kid = kid_02, parent = parent_02 }
    tblFamilyList[3] = { kid = kid_03, parent = parent_03 }
    numInLineup = 3
    tblLineupList[1] = kid_01
    tblLineupList[2] = kid_02
    tblLineupList[3] = kid_03
    tblParentPosList[1] = { parent = parent_01, spotTaken = true }
    tblParentPosList[2] = { parent = parent_02, spotTaken = true }
    tblParentPosList[3] = { parent = parent_03, spotTaken = true }
    tblParentPosList[4] = { parent = nil, spotTaken = false }
    tblParentPosList[5] = { parent = nil, spotTaken = false }
    bSantaBusy = false
    CreateThread("F_CheckSantaQueue")
end

function F_ClearAllFamilies()
    bClearAllFamiliesCalled = true
    for i, item in tblFamilyList do
        if PedIsValid(item.kid) then
            SoundPlayScriptedSpeechEvent(item.kid, "BUMP_RUDE", 0, "large")
            PedStop(item.kid)
            PedClearObjectives(item.kid)
            PedMakeAmbient(item.kid)
            PedFlee(item.kid, gPlayer)
        end
        if PedIsValid(item.parent) then
            SoundPlayScriptedSpeechEvent(item.parent, "BUMP_RUDE", 0, "large", false, true)
            PedStop(item.parent)
            PedClearObjectives(item.parent)
            PedMakeAmbient(item.parent)
            PedFlee(item.parent, gPlayer)
        end
        item.kid = nil
        item.parent = nil
    end
    numFamilies = 0
    for i, item in tblLineupList do
        item = nil
    end
    numInLineup = 0
    for i, item in tblParentPosList do
        item.parent = nil
        item.spotTaken = false
    end
    familySpawnDelay = 0
end

function F_CheckSantaQueue()
    --print("[ScottieP] --> F_CheckSantaQueue ")
    local timeLastChecked = GetTimer()
    local familySpawnDelay = FAMILY_SPAWN_DELAY
    while bClearAllFamiliesCalled == false do
        Wait(1000)
        local bScaredChildFound = false
        for i, item in tblFamilyList do
            if PedIsValid(item.kid) == true and (PedIsDoingTask(item.kid, "/Global/AI/Reactions/Stimuli/Explosion/FleeReaction", true) or PedIsDoingTask(item.kid, "/Global/AI/GeneralObjectives/FleeObjective/Flee", true)) then
                bScaredChildFound = true
                break
            end
        end
        if bScaredChildFound == true then
            F_ClearAllFamilies()
        else
            familySpawnDelay = familySpawnDelay + (GetTimer() - timeLastChecked)
            timeLastChecked = GetTimer()
            if familySpawnDelay >= FAMILY_SPAWN_DELAY then
                if bSantaBusy == false and 0 < numInLineup then
                    CreateThread("F_SeeSanta")
                end
                if numFamilies < numFamiliesAllowed then
                    F_SetupArrivingFamily()
                end
                for i = 1, numParentPos do
                    if tblParentPosList[i].spotTaken == true and tblParentPosList[i].parent ~= nil and PedIsValid(tblParentPosList[i].parent) == true and not PedIsFacingObject(tblParentPosList[i].parent, santa, 2, 40) then
                        local x1, y1, z1 = GetPointFromPointList(POINTLIST._3_XM_PARENTSTART, i)
                        local x2, y2, z2 = PedGetPosXYZ(tblParentPosList[i].parent)
                        if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) < 0.5 then
                            PedFaceObject(tblParentPosList[i].parent, santa, 2, 1)
                        end
                    end
                end
                for i = 1, numInLineup do
                    local kid = tblLineupList[i]
                    if not PedIsFacingObject(kid, santa, 2, 40) then
                        local x1, y1, z1 = GetPointFromPointList(POINTLIST._3_XM_KIDSTART, i)
                        local x2, y2, z2 = PedGetPosXYZ(kid)
                        if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) < 0.5 then
                            PedFaceObject(kid, santa, 2, 1)
                        end
                    end
                end
            end
        end
    end
end

function F_SeeSanta()
    --print("[SCOTTIE P] --> F_SeeSanta")
    PedClearObjectives(santa)
    PedStop(santa)
    PedMoveToPoint(santa, 0, POINTLIST._3_XM_SANTASTART, 1, nil, 0.1)
    bSantaBusy = true
    local santaKid = tblLineupList[1]
    local x, y, z = GetPointList(POINTLIST._3_XM_SEESANTA)
    PedMoveToPoint(santaKid, 0, POINTLIST._3_XM_SEESANTA, 1, nil, 0.1)
    for i = 1, numInLineup do
        tblLineupList[i] = tblLineupList[i + 1]
        if i < numInLineup and PedIsValid(tblLineupList[i]) then
            PedStop(tblLineupList[i])
            PedClearObjectives(tblLineupList[i])
            PedMoveToPoint(tblLineupList[i], 0, POINTLIST._3_XM_KIDSTART, i, nil, 0.2, false)
        end
    end
    numInLineup = numInLineup - 1
    if bRunningStartDialog == false then
        if PedIsValid(santaKid) and DistanceBetweenPeds3D(santa, santaKid) < 4 then
            PedFaceObject(santa, santaKid, 2, 1)
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [9]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 9, "large")
        end
        Wait(TIME_KID_WITH_SANTA / 3)
        if PedIsValid(santaKid) and DistanceBetweenPeds3D(santa, santaKid) < 3 then
            PedFaceObject(santa, santaKid, 2, 1)
            PedFaceObject(santaKid, santa, 2, 1)
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [7]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 7, "large")
        end
        Wait(TIME_KID_WITH_SANTA / 3)
        if PedIsValid(santaKid) and DistanceBetweenPeds3D(santa, santaKid) < 3 then
            PedFaceObject(santa, santaKid, 2, 1)
            PedFaceObject(santaKid, santa, 2, 1)
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [8]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 8, "large")
        end
        Wait(TIME_KID_WITH_SANTA / 3)
    else
        Wait(TIME_KID_WITH_SANTA)
    end
    local bFamilyFound = false
    for i = 1, numFamilies do
        if tblFamilyList[i].kid == santaKid then
            bFamilyFound = true
            for j = 1, numParentPos do
                if tblParentPosList[j].parent == tblFamilyList[i].parent then
                    tblParentPosList[j].spotTaken = false
                    break
                end
            end
            PedStop(tblFamilyList[i].parent)
            PedClearObjectives(tblFamilyList[i].parent)
            PedStop(tblFamilyList[i].kid)
            PedClearObjectives(tblFamilyList[i].kid)
            PedMakeAmbient(tblFamilyList[i].parent)
            PedMakeAmbient(tblFamilyList[i].kid)
            PedRecruitAlly(tblFamilyList[i].parent, tblFamilyList[i].kid, true)
        end
        if bFamilyFound == true then
            tblFamilyList[i] = tblFamilyList[i + 1]
        end
    end
    if bFamilyFound == true then
        numFamilies = numFamilies - 1
    end
    Wait(2000)
    bSantaBusy = false
end

function F_SetupArrivingFamily()
    --print("[SCOTTIE P] --> F_SetupArrivingFamily")
    currentFamilyModel = currentFamilyModel + 1
    if currentFamilyModel > numFamilyModels then
        currentFamilyModel = 1
    end
    local kidModel = familyModels[currentFamilyModel].kid
    local parentModel = familyModels[currentFamilyModel].parent
    local spawnPos = math.random(1, numSpawnPoints)
    local lineupIndex = math.random(1, numLineupPoints)
    local newKid
    newKid = PedCreatePoint(kidModel, POINTLIST._3_XM_KIDSPAWN, spawnPos)
    PedMakeMissionChar(newKid)
    PedClearObjectives(newKid)
    PedClearAllWeapons(newKid)
    PedMakeTargetable(newKid, false)
    local newParent
    newParent = PedCreatePoint(parentModel, POINTLIST._3_XM_PARSPAWN, spawnPos)
    PedMakeMissionChar(newParent)
    PedClearObjectives(newParent)
    PedClearAllWeapons(newParent)
    PedMakeTargetable(newParent, false)
    numFamilies = numFamilies + 1
    tblFamilyList[numFamilies] = { kid = newKid, parent = newParent }
    PedMoveToPoint(newParent, 0, POINTLIST._3_XM_LINEUP, lineupIndex, F_ReachedLineup, 1, false)
    PedRecruitAlly(newParent, newKid, true)
end

function F_ReachedLineup(pedId)
    --print("[SCOTTIE P] --> F_ReachedLineup")
    for i = 1, numFamilies do
        if tblFamilyList[i].parent == pedId then
            local parentPosition = 1
            for j = 1, numParentPos do
                if tblParentPosList[j].spotTaken == false then
                    tblParentPosList[j].parent = tblFamilyList[i].parent
                    tblParentPosList[j].spotTaken = true
                    parentPosition = j
                    break
                end
            end
            PedDismissAlly(tblFamilyList[i].parent, tblFamilyList[i].kid)
            PedStop(tblFamilyList[i].parent)
            PedClearObjectives(tblFamilyList[i].parent)
            PedMoveToPoint(tblFamilyList[i].parent, 0, POINTLIST._3_XM_PARENTSTART, parentPosition, nil, 0.5, false)
            numInLineup = numInLineup + 1
            tblLineupList[numInLineup] = tblFamilyList[i].kid
            PedStop(tblFamilyList[i].kid)
            PedClearObjectives(tblFamilyList[i].kid)
            PedMoveToPoint(tblFamilyList[i].kid, 0, POINTLIST._3_XM_KIDSTART, numInLineup, nil, 0.2, false)
            break
        end
    end
end

function F_GetToSquare()
    CameraSetWidescreen(false)
    CameraReset()
    CameraReturnToPlayer()
    WeaponRequestModel(300)
    PlayerSetWeapon(300, 1, false)
    CameraSetWidescreen(false)
    CameraFade(500, 1)
    Wait(600)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    local x, y, z = GetPointList(POINTLIST._3_XM_SANTASTART)
    currentObjective = MissionObjectiveAdd("3_XM_SQUARE")
    currentBlip = BlipAddXYZ(x, y, z, 0, 1)
    TextPrint("3_XM_SQUARE", 4, 1)
    MissionTimerStart(TIME_TO_GET_TO_SQUARE)
    local x1, y1, z1 = PedGetPosXYZ(gPlayer)
    local x2, y2, z2 = GetPointList(POINTLIST._3_XM_SANTASTART)
    while DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > GET_TO_SQUARE_DISTANCE do
        Wait(0)
        if MissionTimerHasFinished() == true then
            MissionFail(true, true, "3_XM_FAIL_TIME")
        end
        x1, y1, z1 = PedGetPosXYZ(gPlayer)
        x2, y2, z2 = GetPointList(POINTLIST._3_XM_SANTASTART)
    end
    PedMakeAmbient(bum)
    MissionTimerStop()
    MissionObjectiveComplete(currentObjective)
    BlipRemove(currentBlip)
end

function F_RunStartDialog()
    if PedIsValid(elf_01) then
        --print("[ScottieP] --> Sound event triggered: [M_3_01B] [15]")
        SoundPlayScriptedSpeechEvent(elf_01, "M_3_01B", 15, "large")
    end
    Wait(5000)
    if PedIsValid(elf_02) then
        --print("[ScottieP] --> Sound event triggered: [M_3_01B] [19]")
        SoundPlayScriptedSpeechEvent(elf_02, "M_3_01B", 19, "large")
    end
    Wait(2000)
    if PedIsValid(elf_03) then
        --print("[ScottieP] --> Sound event triggered: [M_3_01B] [14]")
        SoundPlayScriptedSpeechEvent(elf_03, "M_3_01B", 14, "large")
    end
    bRunningStartDialog = false
end

local numCandles = 6
local numCandlesToDestroy = 3
local tblCandleObjects = {}

function F_IsCandlesDestroyed()
    local numCandlesDestroyed = 0
    for i, item in tblCandleObjects do
        if item.destroyed == true then
            numCandlesDestroyed = numCandlesDestroyed + 1
        end
    end
    if numCandlesDestroyed >= numCandlesToDestroy then
        return true
    end
    return false
end

function F_SetupCandlesTable()
    tblCandleObjects = {
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cndl",
            x = 589.292,
            y = -81.1408,
            z = 5.70581
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cndl",
            x = 585.073,
            y = -81.8887,
            z = 5.70581
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cndl",
            x = 585.073,
            y = -97.259,
            z = 5.70581
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cndl",
            x = 589.292,
            y = -98.3899,
            z = 5.70581
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cndl",
            x = 580.643,
            y = -95.0824,
            z = 5.70581
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cndl",
            x = 580.69,
            y = -84.0524,
            z = 5.70581
        }
    }
end

function F_DestroyCandles()
    if F_IsCandlesDestroyed() == false then
        currentObjective = MissionObjectiveAdd("3_XM_CANDLES")
        TextPrint("3_XM_CANDLES", 4, 1)
        for i, item in tblCandleObjects do
            if item.destroyed == false then
                item.blip = BlipAddXYZ(item.x, item.y, item.z + 1.75, 0, 4)
            end
        end
        while F_IsCandlesDestroyed() == false do
            Wait(0)
        end
        for i, item in tblCandleObjects do
            BlipRemove(item.blip)
        end
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
    end
end

local numCandyCanes = 3
local numCandyCanesToDestroy = 2
local tblCandyCaneObjects = {}

function F_IsCandyCanesDestroyed()
    local numCandyCanesDestroyed = 0
    for i, item in tblCandyCaneObjects do
        if item.destroyed == true then
            numCandyCanesDestroyed = numCandyCanesDestroyed + 1
        end
    end
    if numCandyCanesDestroyed >= numCandyCanesToDestroy then
        return true
    end
    return false
end

function F_SetupCandyCanesTable()
    tblCandyCaneObjects = {
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_ccane",
            x = 588.19,
            y = -82.5892,
            z = 5.74878
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_ccane",
            x = 588.269,
            y = -96.718,
            z = 5.74878
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_chair",
            x = 590.61,
            y = -89.4984,
            z = 5.74283
        }
    }
end

function F_DestroyCandyCanes()
    if F_IsCandyCanesDestroyed() == false then
        currentObjective = MissionObjectiveAdd("3_XM_CANDYCANES")
        TextPrint("3_XM_CANDYCANES", 4, 1)
        for i, item in tblCandyCaneObjects do
            if item.destroyed == false then
                if item.name == "x_chair" then
                    item.blip = BlipAddXYZ(item.x, item.y, item.z + 2.5, 0, 4)
                else
                    item.blip = BlipAddXYZ(item.x, item.y, item.z + 2, 0, 4)
                end
            end
        end
        while F_IsCandyCanesDestroyed() == false do
            Wait(0)
        end
        for i, item in tblCandyCaneObjects do
            BlipRemove(item.blip)
        end
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
    end
end

local numPresents = 6
local numPresentsToDestroy = 3
local tblPresentObjects = {}

function F_IsPresentsDestroyed()
    local numPresentsDestroyed = 0
    for i, item in tblPresentObjects do
        if item.destroyed == true then
            numPresentsDestroyed = numPresentsDestroyed + 1
        end
    end
    if numPresentsDestroyed >= numPresentsToDestroy then
        return true
    end
    return false
end

function F_SetupPresentsTable()
    tblPresentObjects = {
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "xmas_prsnt1",
            x = 588.273,
            y = -83.6541,
            z = 6.4679
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "xmas_prsnt2",
            x = 583.593,
            y = -85.1148,
            z = 6.08142
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_tedy",
            x = 588.203,
            y = -95.4786,
            z = 5.77261
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "xmas_prsnt2",
            x = 587.453,
            y = -96.469,
            z = 6.10129
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "xmas_prsnt1",
            x = 584.704,
            y = -84.1464,
            z = 6.4679
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "xmas_prsnt2",
            x = 584.17,
            y = -92.5149,
            z = 6.10129
        }
    }
end

function F_DestroyPresents()
    if F_IsPresentsDestroyed() == false then
        currentObjective = MissionObjectiveAdd("3_XM_PRESENTS")
        TextPrint("3_XM_PRESENTS", 4, 1)
        for i, item in tblPresentObjects do
            if item.name == "x_tedy" then
                if item.destroyed == false then
                    item.blip = BlipAddXYZ(item.x, item.y, item.z + 1.5, 0, 4)
                end
            elseif item.destroyed == false then
                item.blip = BlipAddXYZ(item.x, item.y, item.z + 0.5, 0, 4)
            end
        end
        while F_IsPresentsDestroyed() == false do
            Wait(0)
        end
        for i, item in tblPresentObjects do
            BlipRemove(item.blip)
        end
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
    end
end

local numSnowman = 1
local tblSnowmanObjects = {}

function F_IsSnowmanDestroyed()
    for i, item in tblSnowmanObjects do
        if item.destroyed == true then
            return true
        end
    end
    return false
end

function F_SetupSnowmanTable()
    tblSnowmanObjects = {
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "DPE_Snowman",
            x = 583.027,
            y = -96.681,
            z = 5.70801
        }
    }
end

function F_DestroySnowman()
    if F_IsSnowmanDestroyed() == false then
        currentObjective = MissionObjectiveAdd("3_XM_SNOWMAN")
        TextPrint("3_XM_SNOWMAN", 4, 1)
        for i, item in tblSnowmanObjects do
            if item.destroyed == false then
                item.blip = BlipAddXYZ(item.x, item.y, item.z + 1.5, 0, 4)
            end
        end
        while F_IsSnowmanDestroyed() == false do
            Wait(0)
        end
        --print("[ScottieP] --> Snowman Destroyed!")
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
    end
end

local tblSleighObject = {}

function F_IsSleighDestroyed()
    for i, item in tblSleighObject do
        if item.destroyed == true then
            return true
        end
    end
    return false
end

function F_SetupSleighTable()
    tblSleighObject = {
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_sleigh",
            x = 583.405,
            y = -94.0158,
            z = 6.37012
        }
    }
end

function F_DestroySleigh()
    --print("[ScottieP] --> F_DestroySleigh")
    if F_IsSleighDestroyed() == false then
        --print("[ScottieP] --> F_DestroySleigh not destroyed")
        currentObjective = MissionObjectiveAdd("3_XM_SLEIGH")
        TextPrint("3_XM_SLEIGH", 4, 1)
        for i, item in tblSleighObject do
            if item.destroyed == false then
                item.blip = BlipAddXYZ(item.x, item.y, item.z + 0.5, 0, 4)
            end
        end
        while F_IsSleighDestroyed() == false do
            Wait(0)
        end
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
    end
end

local numCastlePieces = 3
local tblCastleObjects = {}

function F_IsCastleDestroyed()
    local numCastlePiecesDestroyed = 0
    for i, item in tblCastleObjects do
        if item.destroyed == true then
            numCastlePiecesDestroyed = numCastlePiecesDestroyed + 1
        end
    end
    if numCastlePiecesDestroyed >= numCastlePieces then
        return true
    end
    return false
end

function F_SetupCastleTable()
    --print("[ScottieP]--> F_SetupCastleTable")
    tblCastleObjects = {
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cas1",
            x = 591.428,
            y = -89.5091,
            z = 5.71496
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cas2",
            x = 591.435,
            y = -85.8887,
            z = 5.55417
        },
        {
            index = nil,
            pool = nil,
            blip = nil,
            destroyed = false,
            name = "x_cas3",
            x = 591.43,
            y = -93.064,
            z = 5.6154
        }
    }
end

function F_DestroyCastle()
    if F_IsCastleDestroyed() == false then
        currentObjective = MissionObjectiveAdd("3_XM_CASTLE")
        TextPrint("3_XM_CASTLE", 4, 1)
        for i, item in tblCastleObjects do
            if item.destroyed == false then
                item.blip = BlipAddXYZ(item.x - 0.5, item.y, item.z + 0.5, 0, 1)
            end
        end
        while F_IsCastleDestroyed() == false do
            Wait(0)
        end
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
    end
end

local bDamageStarted = false

function F_UpdateSantaBar()
    ShowGeneralHealthBar(MAX_SANTA_DAMAGE_POINTS, "3_XM_BAR", false)
    SetGeneralHealthBar(MAX_SANTA_DAMAGE_POINTS)
    bShowSantaBar = true
    while bShowSantaBar do
        Wait(500)
        local damagePoints = MAX_SANTA_DAMAGE_POINTS
        local weight = MAX_SANTA_DAMAGE_POINTS / NUM_OBJECTS_TO_DESTROY
        damagePoints = damagePoints - F_CheckDamageOnObjects(tblCandleObjects, weight)
        damagePoints = damagePoints - F_CheckDamageOnObjects(tblCandyCaneObjects, weight)
        damagePoints = damagePoints - F_CheckDamageOnObjects(tblPresentObjects, weight)
        damagePoints = damagePoints - F_CheckDamageOnObjects(tblSnowmanObjects, weight)
        damagePoints = damagePoints - F_CheckDamageOnObjects(tblSleighObject, weight)
        damagePoints = damagePoints - F_CheckDamageOnObjects(tblCastleObjects, weight)
        if damagePoints < globalDamagePoints then
            if bDamageStarted == false then
                bDamageStarted = true
                CreateThread("F_UpdateSanta")
            end
            F_ClearAllFamilies()
            globalDamagePoints = damagePoints
            CreateThread("F_AnimateSanta")
            CreateThread("F_UpdateSpawnersAndSpeech")
        end
        if damagePoints <= 0 then
            damagePoints = 0
            bShowSantaBar = false
        end
        SetGeneralHealthBar(damagePoints)
    end
    HideGeneralHealthBar()
end

local bSantaDoingMadAnim = false

function F_AnimateSanta() -- ! Modified
    if PedIsValid(santa) then
        bSantaDoingMadAnim = true
        PedFaceObject(santa, gPlayer, 3, 1)
        Wait(1000)
        --[[
        PedSetActionNode(santa, "/Global/3_XM/Anims/SantaMad", "Act/Conv/3_XM.act")
        ]] -- Changed to:
        PedSetActionNode(santa, "/Global/3_XM/Anims/ShakeFist", "Act/Conv/3_XM.act")
        Wait(2000)
        bSantaDoingMadAnim = false
    end
end

function F_UpdateSanta() -- ! Modified
    while bMissionFinised == false do
        Wait(1000)
        if PedIsValid(santa) and bSantaDoingMadAnim == false then
            local x1, y1, z1 = PedGetPosXYZ(santa)
            local x2, y2, z2 = GetPointList(POINTLIST._3_XM_SANTASTART)
            if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > 5 then
                PedStop(santa)
                PedClearObjectives(santa)
                PedMoveToPoint(santa, 1, POINTLIST._3_XM_SANTASTART)
            else
                if PedIsFacingObject(santa, gPlayer, 3, 40) == false then
                    --print("[ScottieP] --> santa is not facing the player!!!")
                    PedSetActionNode(santa, "/Global/3_XM/Anims/Restart", "Act/Conv/3_XM.act")
                    PedStop(santa)
                    PedClearObjectives(santa)
                    local x, y, z = PedGetPosXYZ(gPlayer)
                    PedFaceXYZ(santa, x, y, z, 1)
                    Wait(1500)
                end
                --[[
                if PedIsPlaying(santa, "/Global/3_XM/Anims/SantaIdle", true) == false then
                    PedSetActionNode(santa, "/Global/3_XM/Anims/SantaIdle", "Act/Conv/3_XM.act")
                end
                ]] -- Not present in original script
            end
        end
    end
end

function F_CheckDamageOnObjects(objectTable, weight)
    local weightCount = 0
    for i, item in objectTable do
        item.index, item.pool = PAnimGetPoolIndex(item.name, item.x, item.y, item.z, 1)
        PAnimMakeTargetable(item.name, item.x, item.y, item.z, true)
        if PAnimIsDestroyed(item.index, item.pool) == true then
            if item.destroyed == false then
                --print("[ScottieP] --> Item Destroyed!!!!")
                BlipRemove(item.blip)
                F_RunBrokenSpeech(item.name)
            end
            item.destroyed = true
            weightCount = weightCount + weight
        end
    end
    return weightCount
end

local bSleighSpeechDone = false
local bCandleSpeechDone = false
local bTeddySpeechDone = false
local bCandyCaneSpeech1Done = false
local bCandyCaneSpeech2Done = false
local bCastleSpeechDone = false

function F_RunBrokenSpeech(name)
    local closestElf1, closestElf2
    for i, item in tblElvesList do
        if PedIsValid(item.elf) == true and PedIsDead(item.elf) == false then
            local distance = DistanceBetweenPeds3D(item.elf, gPlayer)
            if closestElf1 == nil or distance < DistanceBetweenPeds3D(closestElf1, gPlayer) then
                closestElf2 = closestElf1
                closestElf1 = item.elf
            end
        end
    end
    if name == "x_sleigh" and bSleighSpeechDone == false then
        bSleighSpeechDone = true
        if PedIsValid(santa) == true then
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [39]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 39, "large")
        end
    elseif name == "x_tedy" and bTeddySpeechDone == false then
        bTeddySpeechDone = true
        if PedIsValid(santa) == true then
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [45]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 45, "large")
        end
    elseif name == "x_cndl" and bCandleSpeechDone == false then
        bCandleSpeechDone = true
        if PedIsValid(santa) == true then
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [46]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 46, "large")
        end
    elseif name == "ccane" and bCandyCaneSpeech1Done == false then
        bCandyCaneSpeech1Done = true
        if PedIsValid(closestElf1) == true then
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [16]")
            SoundPlayScriptedSpeechEvent(closestElf1, "M_3_01B", 16, "large")
        end
    elseif name == "ccane" and bCandyCaneSpeech2Done == false then
        bCandyCaneSpeech2Done = true
        if PedIsValid(santa) == true then
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [43]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 43, "large")
        end
    elseif bCastleSpeechDone == false and (name == "x_cas1" or name == "x_cas2" or name == "x_cas2") then
        bCastleSpeechDone = true
        if PedIsValid(santa) == true then
            --print("[ScottieP] --> Sound event triggered: [M_3_01B] [47]")
            SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 47, "large")
        end
    elseif PedIsValid(santa) == true then
        --print("[ScottieP] --> Sound event triggered: [M_3_01B] [10]")
        SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 10, "large")
    end
end

function F_UpdateSpawnersAndSpeech()
    local closestElf1, closestElf2
    for i, item in tblElvesList do
        if PedIsValid(item.elf) == true and PedIsDead(item.elf) == false then
            local distance = DistanceBetweenPeds3D(item.elf, gPlayer)
            if closestElf1 == nil or distance < DistanceBetweenPeds3D(closestElf1, gPlayer) then
                closestElf2 = closestElf1
                closestElf1 = item.elf
            end
        end
    end
    if globalDamagePoints < 10 then
        F_SantaTalkToElves()
    elseif globalDamagePoints < 20 then
        F_SantaTalkToElves()
    elseif globalDamagePoints < 30 then
        numFamiliesAllowed = 1
        F_SantaTalkToElves()
    elseif globalDamagePoints < 40 then
        numElvesAttacking = 4
        elfAttackDelay = ELF_SPAWN_DELAY
        F_SantaTalkToElves()
    elseif globalDamagePoints < 50 then
        F_SantaTalkToElves()
    elseif globalDamagePoints < 60 then
        numElvesAttacking = 3
        elfAttackDelay = ELF_SPAWN_DELAY
        F_SantaTalkToElves()
    elseif globalDamagePoints < 70 then
        numFamiliesAllowed = 2
        F_SantaTalkToElves()
    elseif globalDamagePoints < 80 then
        numElvesAttacking = 2
        elfAttackDelay = ELF_SPAWN_DELAY
        F_SantaTalkToElves()
    elseif globalDamagePoints < 90 then
        F_SantaTalkToElves()
        numFamiliesAllowed = 3
    elseif globalDamagePoints < 95 then
        F_SantaTalkToElves()
        numElvesAttacking = 1
        elfAttackDelay = ELF_SPAWN_DELAY
    end
end

function F_SantaTalkToElves()
    if PedIsValid(santa) == true then
        --print("[ScottieP] --> Sound event triggered: [M_3_01B] [21]")
        SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 21, "large")
    end
end

function F_CheckInArea()
    local timePassed = 0
    local timeLastChecked = GetTimer()
    bAreaThreadRunning = true
    while bAreaThreadRunning == true do
        Wait(0)
        timePassed = GetTimer() - timeLastChecked
        timeLastChecked = GetTimer()
        local x1, y1, z1, x2, y2, z2
        x1, y1, z1 = PedGetPosXYZ(gPlayer)
        x2, y2, z2 = GetPointList(POINTLIST._3_XM_SANTASTART)
        if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > MAX_DIST_FROM_SANTA then
            TextPrint("3_XM_WARN_AREA", 1, 1)
            timeOutOfArea = timeOutOfArea + timePassed
            if timeOutOfArea > TIME_AWAY_FROM_SANTA then
                MissionFail(true, true, "3_XM_FAIL_AREA")
            end
        else
            bOutOfArea = false
            timeOutOfArea = 0
        end
    end
end

function F_CheckMissionSuccess()
    bSuccessThreadRunning = true
    while bSuccessThreadRunning == true do
        Wait(0)
        if F_IsCastleDestroyed() == true then
            F_MissionFinished()
            break
        end
    end
end

function F_MissionFinished()
    F_MakePlayerSafeForNIS(true)
    bAreaThreadRunning = false
    bUpdateElvesRunning = false
    bClearAllFamiliesCalled = true
    bMissionFinised = true
    HideGeneralHealthBar()
    SoundStopInteractiveStream()
    --print("[ScottieP] --> Sound event triggered: [M_3_01B] [38]")
    SoundStopCurrentSpeechEvent(santa)
    SoundPlayScriptedSpeechEvent(santa, "M_3_01B", 38, "large")
    MinigameSetCompletion("M_PASS", true, 0, "3_XM_REWARD")
    SoundPlayMissionEndMusic(true, 10)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    ClothingGivePlayerOutfit("Elf")
    MissionSucceed(true, false, false)
end

function F_MissionFail()
end
