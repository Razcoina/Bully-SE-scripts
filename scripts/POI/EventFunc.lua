ImportScript("POI/EventLib.lua")
local HumiliationInterval = 5000
local PropInterval = 8000
local TellOffInterval = 5000
local SocialInterval = 5000
local CriminalInterval = 5000
local BrawlInterval = 5000
local RussellInterval = 60000
local BrawlTimer = 0
local HumiliationTimer = 0
local SocialTimer = 0
local TellOffTimer = 0
local PropTimer = 0
local CriminalTimer = 0
local RussellTimer = 0
local ThugChoices = {
    11,
    4,
    2,
    1
}

function F_CoupleCuddling(POIInfo, POIPointType, POIPointFaction, POIPointNum, ped1, ped2, ped3, ped4)
    if POIPointFaction ~= 12 then
        ped1 = GetStudent(POIPointFaction, 1, 1)
        ped2 = GetStudent(RandomElement2(6, POIPointFaction), 2, 1)
    else
        ped1 = GetStudent(RandomElement4(6, 5, 2, 4), 1, 1)
        ped2 = GetStudent(6, 2, 1)
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Boy = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    local Girl = PedCreatePOIPoint(ped2, POIInfo, -1, 0, 0)
    if Boy == -1 or Girl == -1 then
        return
    end
    PedLockTarget(Boy, Girl, 0)
    PedLockTarget(Girl, Boy, 0)
    PedFaceObjectNow(Girl, Boy, 2)
    PedFaceObjectNow(Boy, Girl, 2)
    local result = POIActionNode2(Boy, Girl, "/Global/Ambient/Scripted/Cuddle", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(Boy, 0)
        PedWander(Girl, 0)
    end
end

function F_CoupleKissing(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local special1chance = math.random(1, 100)
    local special2chance = math.random(1, 100)
    local special1 = false
    local special2 = false
    if POIPointFaction ~= 12 then
        if special2 == true then
            ped1 = GetStudent(POIPointFaction, 2, 1, false)
        else
            ped1 = GetStudent(POIPointFaction, 1, 1, false)
        end
        if POIPointFaction ~= 11 then
            if special1 == true then
                ped2 = GetStudent(RandomElement2(6, POIPointFaction), 1, 1, false)
            else
                ped2 = GetStudent(RandomElement2(6, POIPointFaction), 2, 1, false)
            end
        elseif special1 == true then
            ped2 = GetStudent(RandomElement2(6, POIPointFaction), 1, 1, false)
        else
            ped2 = GetStudent(6, 2, 1, false)
        end
    elseif special1 == true then
        ped1 = GetStudent(RandomElement4(6, 5, 2, 4), 1, 1, false)
        ped2 = GetStudent(RandomElement4(6, 5, 2, 4), 1, 1, false)
    elseif special2 == true then
        ped1 = GetStudent(RandomElement4(6, 5, 2, 4), 2, 1, false)
        ped2 = GetStudent(RandomElement4(6, 5, 2, 4), 2, 1, false)
    else
        ped1 = GetStudent(RandomElement5(6, 5, 2, 4, 11), 1, 1, false)
        ped2 = GetStudent(6, 2, 1, false)
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Boy = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    local Girl = PedCreatePOIPoint(ped2, POIInfo, 1.5, 0, 0)
    if Boy == -1 or Girl == -1 then
        return
    end
    PedClearAllWeapons(Boy)
    PedClearAllWeapons(Girl)
    PedFaceObjectNow(Boy, Girl, 2)
    PedFaceObjectNow(Girl, Boy, 2)
    PedAddPedToIgnoreList(Girl, Boy)
    PedAddPedToIgnoreList(Boy, Girl)
    PedLockTarget(Boy, Girl, 3)
    PedLockTarget(Girl, Boy, 3)
    PedSetEmotionTowardsPed(Boy, Girl, 8)
    PedSetEmotionTowardsPed(Girl, Boy, 8)
    local result = POIActionNode2(Boy, Girl, "/Global/Ambient/Scripted/Kiss_Me_Baby", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(Boy, 0)
        PedWander(Girl, 0)
    end
end

function F_Brawl(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local VictimChoice, Victim, Thug, ThugChoice
    local spawnGender = 1
    local numthugs = 0
    local factionchoice
    local NThug = false
    local weaponchoice, weaponroll
    numthugs = math.random(1, 2)
    if POIPointFaction == 9 or POIPointFaction == 10 then
        numthugs = 1
    end
    if POIGender == 0 then
        spawnGender = 1
    else
        spawnGender = POIGender
    end
    if POIPointFaction == 12 then
        POIPointFaction = RandomElement5(4, 11, 5, 2, 1)
    end
    if POIPointFaction == 1 then
        NThug = true
    end
    factionchoice = F_GetOpposingFaction(POIPointFaction)
    for count = 1, numthugs do
        ThugChoice = GetStudent(POIPointFaction, spawnGender)
        VictimChoice = GetStudent(factionchoice, spawnGender)
        if ThugChoice == VictimChoice then
            return
        end
        if VictimChoice ~= -1 and ThugChoice ~= -1 then
            LoadPedPOIModel(VictimChoice)
            LoadPedPOIModel(ThugChoice)
            Thug = PedCreatePOIPoint(ThugChoice, POIInfo, count, count * -0.5, 0)
            Victim = PedCreatePOIPoint(VictimChoice, POIInfo, count, count, 0)
            if Victim ~= -1 then
                PedWander(Victim, 0)
            end
            if Thug ~= -1 then
                PedWander(Thug, 0)
            end
            if Victim ~= -1 and Thug ~= -1 then
                if NThug == true and PedGetWeapon(Thug) == -1 then
                    F_SelectBrawlWeapon(Thug, POIPointFaction)
                end
                if POIPointFaction == 10 then
                    PedSetFaction(Thug, 9)
                end
                PedAttack(Thug, Victim, 0, true)
                PedAttack(Victim, Thug, 0, true)
            end
            Thug = -1
            Victim = -1
        end
    end
end

function F_GangBeat(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local spawnGender = 1
    local VictimChoice = GetStudent(POIPointFaction, spawnGender)
    if VictimChoice == -1 then
        return
    end
    LoadPedPOIModel(VictimChoice)
    local Victim = PedCreatePOIPoint(VictimChoice, POIInfo, 0, 0, 0)
    local Thug, ThugChoice
    if Victim == -1 then
        return
    end
    local numthugs = 0
    numthugs = math.random(1, 3)
    for count = 1, numthugs do
        ThugChoice = GetStudent(F_GetOpposingFaction(POIPointFaction), spawnGender)
        if ThugChoice ~= -1 then
            LoadPedPOIModel(ThugChoice)
            Thug = PedCreatePOIPoint(ThugChoice, POIInfo, count, count * -0.5, 0)
            if Thug ~= -1 and Victim ~= -1 then
                PedWander(Thug, 0)
                PedWander(Victim, 0)
                PedAttack(Thug, Victim, 1, true)
                PedAttack(Victim, Thug, 1, true)
            end
        end
    end
end

function F_ReachItHumiliation(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local charType
    --print("POIPointFaction: ", POIPointFaction)
    if POIPointFaction == 11 or POIPointFaction == 4 or POIPointFaction == 5 or POIPointFaction == 2 then
        charType = POIPointFaction
    elseif POIPointFaction == 1 then
        return
    else
        charType = RandomElement4(4, 11, 5, 2)
    end
    if charType == 11 or charType == 5 then
        ped1 = GetStudent(charType, 1, -1)
        ped2 = GetStudent(1, 1, -1, false)
    else
        ped1 = GetStudent(charType, 1, -1)
        charType = RandomElement2(1, 6, false)
        if charType == 1 then
            ped2 = GetStudent(charType, 1, -1, false)
        else
            ped2 = GetStudent(charType, 1, -1, false)
        end
        if ped2 == 7 or ped2 == 9 then
            return
        end
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    POISetScriptedPedExitObjective(POIInfo, 0)
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    LoadWeaponPOIModel(405)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 0, 0, 0)
    local Thug = PedCreatePOIPoint(ped1, POIInfo, 1, 0, 0)
    if Victim == -1 or Thug == -1 then
        ModelNotNeededAmbient(405)
        return
    end
    ModelNotNeededAmbient(405)
    PedFaceObjectNow(Victim, Thug, 2)
    PedFaceObjectNow(Thug, Victim, 2)
    PedSetWeapon(Thug, 405, 1)
    PedLockTarget(Thug, Victim, 0)
    PedLockTarget(Victim, Thug, 0)
    local result = POIActionNode2(Thug, Victim, "/Global/Ambient/Scripted/BookHarass", "Act/Anim/Ambient.act")
end

function F_TeacherHarassingKids(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if MissionActive() then
        return
    end
    RequestAnimGroup("POI_Telloff")
    if AreaGetVisible() == 2 then
        if math.random(100) > 50 then
            ped1 = 54
        else
            ped1 = GetStudent(8, -1, -1, false)
        end
        ped2 = GetStudent(12, POIGender, -1)
    elseif POIPointFaction == 12 then
        POIPointFaction = RandomElement2(8, 0)
        ped1 = GetStudent(POIPointFaction, POIGender, -1, false)
        ped2 = GetStudent(12, POIGender)
    elseif POIPointFaction == 8 or POIPointFaction == 7 or POIPointFaction == 0 or POIPointFaction == 9 then
        ped1 = GetStudent(POIPointFaction, 1, -1, false)
        ped2 = GetStudent(12, POIGender)
    else
        ped2 = GetStudent(POIPointFaction, POIGender)
        POIPointFaction = RandomElement2(8, 0)
        ped1 = GetStudent(POIPointFaction, POIGender, -1, false)
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Teacher = PedCreatePOIPoint(ped1, POIInfo, 1, 0, 0)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 0, 0, 0)
    if Victim == -1 or Teacher == -1 then
        if Victim ~= -1 then
            PedDelete(Victim)
        end
        if Teacher ~= -1 then
            PedDelete(Teacher)
        end
        return
    end
    PedFaceObjectNow(Teacher, Victim, 2)
    PedFaceObjectNow(Victim, Teacher, 2)
    PedClearObjectives(Teacher)
    PedClearObjectives(Victim)
    PedLockTarget(Teacher, Victim, 3)
    PedLockTarget(Victim, Teacher, 3)
    local result = POIActionNode2(Teacher, Victim, "/Global/Ambient/Scripted/Tell_Off", "Act/Anim/Ambient.act")
end

function F_Puker(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local char = -1
    local hour, minute = ClockGet()
    if POIPointFaction == 12 then
        POIPOINTFaction = 6
    end
    if POIPointFaction == 10 then
        char = RandomElement2(157, 116)
    else
        char = GetStudent(POIPointFaction, POIGender, -1)
    end
    if char == -1 then
        return
    end
    LoadPedPOIModel(char)
    puker = PedCreatePOIPoint(char, POIInfo, 0, 0, 0)
    if puker == -1 then
        return
    end
    PedClearAllWeapons(puker)
    if POIIsValid(POIInfo) then
        local x, y, z = POIGetPosXYZ(POIInfo)
        PAnimOpenDoors(x, y, z, 0, "StalDoor")
    end
    local result = ExecuteActionNode(puker, "/Global/Ambient/Scripted/SpecialPuke", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(puker, 0)
    end
end

function F_WallSmoking(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if POIPointFaction ~= 8 and POIPointFaction ~= 0 and POIPointFaction ~= 6 and POIPointFaction ~= 1 then
        if POIGender == 0 then
            POIGender = 1
        end
        if POIPointFaction == 12 then
            POIPointFaction = RandomElement2(4, 11)
            ped1 = GetStudent(POIPointFaction, POIGender)
        elseif POIPointFaction == 9 then
            ped1 = GetStudent(POIPointFaction, POIGender)
        else
            ped1 = GetStudent(POIPointFaction, POIGender)
        end
        if ped1 == -1 then
            return
        end
        if F_IsSmallKid(ped1) then
            return
        end
        LoadPedPOIModel(ped1)
        local char = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
        if char == -1 then
            return
        end
        PedClearAllWeapons(char)
        local result = ExecuteActionNode(char, "/Global/Ambient/Scripted/Wall_Smoke", "Act/Anim/Ambient.act")
        if result == true then
            PedWander(char, 0)
        end
    end
end

function F_WallHangout(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if POIGender == 0 and AreaGetVisible() == 2 then
        POIGender = 1
    end
    ped1 = GetStudent(POIPointFaction, POIGender)
    if ped1 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    local char = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedClearAllWeapons(char)
    local result = ExecuteActionNode(char, "/Global/Ambient/Scripted/Wall_Lean", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(char, 0)
    end
end

function F_Arrest(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local modelchance, copmodel
    if POIGender == 0 then
        POIGender = 1
    end
    if MissionActive() then
        return
    end
    if POIPointFaction == 7 then
        modelchance = math.random(1, 100)
        if modelchance < 75 then
            ped1 = RandomElement2(157, 116)
        else
            ped1 = GetStudent(3, POIGender)
        end
    else
        ped1 = GetStudent(12, POIGender)
    end
    if ped1 == -1 then
        return
    end
    if POIPointFaction == 7 then
        copmodel = RandomElement4(83, 97, 234, 238)
        LoadPedPOIModel(ped1)
        LoadPedPOIModel(copmodel)
        ped2 = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
        ped3 = PedCreatePOIPoint(copmodel, POIInfo, -2, 0, 0)
    else
        LoadPedPOIModel(ped1)
        LoadPedPOIModel(53)
        ped2 = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
        ped3 = PedCreatePOIPoint(53, POIInfo, -1, 0, 0)
    end
    if ped2 == -1 or ped3 == -1 then
        return
    end
    PedSetFlag(ped2, 120, true)
    PedSetFlag(ped3, 120, true)
    PedFaceObjectNow(ped2, ped3, 2)
    PedFaceObjectNow(ped3, ped2, 2)
    PedSetPunishmentPoints(ped2, 175)
    PedFlee(ped2, ped3)
end

function F_Sweep(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local x, y, z = 0, 0, 0
    local char = -1
    while not WeaponRequestModel(377, true) and POIIsValid(POIInfo) do
        Wait(0)
    end
    local hour, minute = ClockGet()
    if POIPointFaction == 8 then
        if 0 < PedGetPedCountWithModel(56) and hour < 17 then
            ModelNotNeededAmbient(377)
            return
        else
            LoadPedPOIModel(56)
            char = PedCreatePOIPoint(56, POIInfo, 0, 0, 0)
            if char == -1 then
                ModelNotNeededAmbient(377)
                return
            end
            local MovePed = false
            for pos = 1, 20 do
                x, y, z = PedFindRandomSpawnPosition(char)
                if x ~= 9999 then
                    pos = 21
                    MovePed = true
                else
                    pos = pos + 1
                    if pos == 21 and POIIsValid(POIInfo) then
                        x, y, z = POIGetPosXYZ(POIInfo)
                    else
                        ModelNotNeededAmbient(377)
                        return
                    end
                end
            end
            if MovePed == true then
                PedSetPosXYZ(char, x, y, z)
            end
        end
    end
    ModelNotNeededAmbient(377)
    if char == -1 then
        return
    end
    PedSetWeapon(char, 377, 1)
    local result = ExecuteActionNode(char, "/Global/Ambient/Scripted/SweepFloors", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(char, 0)
    end
end

function F_HeldAgainstWall(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if POIPointFaction == 12 then
        ped1 = RandomElement3(4, 5, 2)
        if ped1 == 5 then
            ped1 = GetStudent(ped1, 1, -1)
            ped2 = GetStudent(1, 1, 1)
        else
            ped1 = GetStudent(ped1, 1, -1)
            ped2 = RandomElement2(1, 6)
            if ped2 == 6 then
                ped2 = GetStudent(6, 1, -1)
            else
                ped2 = GetStudent(1, 1, 1)
            end
        end
    elseif POIPointFaction == 0 or POIPointFaction == 7 then
        if MissionActive() then
            return
        else
            ped1 = GetStudent(POIPointFaction, 1)
            ped2 = GetStudent(RandomElement4(4, 5, 2, 11), 1, 1)
        end
    elseif POIPointFaction == 5 then
        ped1 = GetStudent(POIPointFaction, 1, -1)
        ped2 = GetStudent(1, 1, 1)
    else
        repeat
            if POIPointFaction ~= 1 then
            end
            do return end
            do break end -- pseudo-goto
            ped1 = GetStudent(POIPointFaction, 1, -1)
            ped2 = F_GetOpposingFaction(POIPointFaction)
            if ped2 ~= 6 then
                ped2 = GetStudent(6, 1, -1)
            else
                ped2 = GetStudent(1, 1, 1)
            end
        until true
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 0, 0, 0)
    local Thug = PedCreatePOIPoint(ped1, POIInfo, 0, -0.5, 0)
    if Victim == -1 or Thug == -1 then
        return
    end
    PedFaceObjectNow(Victim, Thug, 2)
    PedFaceObjectNow(Thug, Victim, 2)
    if PedHasWeapon(Victim, 300) or PedHasWeapon(Victim, 312) then
        if PedHasWeapon(Victim, 300) then
            PedDestroyWeapon(Victim, 300)
        else
            PedDestroyWeapon(Victim, 312)
        end
    end
    PedWander(Thug, 0)
    PedWander(Victim, 0)
    PedLockTarget(Thug, Victim, 3)
    PedLockTarget(Victim, Thug, 3)
    local result = ExecuteActionNode(Thug, "/Global/Ambient/Scripted/Wall_Hold", "Act/Anim/Ambient.act")
    if result == true then
        PedLockTarget(Thug, -1)
        PedLockTarget(Victim, -1)
    end
end

function F_DrunkenBeggar(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local model = RandomElement2(116, 157)
    LoadPedPOIModel(model)
    local char = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    LoadWeaponPOIModel(327)
    ModelNotNeededAmbient(327)
    if char == -1 then
        return
    end
    PedSetWeaponNow(char, 327, 1)
    PedWander(char, 0)
    ExecuteActionNode(char, "/Global/Ambient/Scripted/Drunk", "Act/Anim/Ambient.act")
end

function F_Catch(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1_ModelID, ped2_ModelID, ped3, ped4)
    if POIPointFaction == 12 then
        POIPointFaction = RandomElement2(2, 6)
    end
    local ped1_ModelID, ped2_ModelID
    if AreaGetVisible() == 13 then
        ped1_ModelID = GetGymModel(POIPointFaction)
        ped2_ModelID = GetGymModel(POIPointFaction)
    else
        ped1_ModelID = GetStudent(POIPointFaction, 1)
        ped2_ModelID = GetStudent(POIPointFaction, 1)
    end
    if ped1_ModelID == -1 or ped2_ModelID == -1 then
        return
    end
    LoadPedPOIModel(ped1_ModelID)
    LoadPedPOIModel(ped2_ModelID)
    if POIIsValid(POIInfo) then
        local x, y, z = POIGetPosXYZ(POIInfo)
        local testY1 = y - 3.5
        local testY2 = y + 3.5
        if PedAreaClearOfPedsInXYZ(x, testY1, z) == false or PedAreaClearOfPedsInXYZ(x, testY2, z) == false then
            ModelNotNeededAmbient(ped1_ModelID)
            ModelNotNeededAmbient(ped2_ModelID)
            return
        end
    else
        ModelNotNeededAmbient(ped1_ModelID)
        ModelNotNeededAmbient(ped2_ModelID)
        return
    end
    local ped2 = PedCreatePOIPoint(ped2_ModelID, POIInfo, 0, -3.5, 0)
    local ped1 = PedCreatePOIPoint(ped1_ModelID, POIInfo, 0, 3.5, 0)
    if ped1 == -1 or ped2 == -1 then
        return
    end
    if PedIsValid(ped1) and not PedIsValid(ped2) then
        PedWander(ped1, 0)
        PedClearPOI(ped1)
        return
    end
    if PedIsValid(ped2) and not PedIsValid(ped1) then
        PedWander(ped2, 0)
        PedClearPOI(ped2)
        return
    end
    Wait(10)
    PedClearAllWeapons(ped1)
    PedClearAllWeapons(ped2)
    PedSetFlag(ped1, 120, true)
    PedSetFlag(ped2, 120, true)
    PedOverrideStat(ped1, 10, 100)
    PedOverrideStat(ped2, 10, 100)
    PedSetRemoveOwnedProj(ped1, true)
    PedSetRemoveOwnedProj(ped2, true)
    if POIPointFaction == 3 then
        LoadWeaponPOIModel(346)
        PedSetWeapon(ped1, 346, 1)
        ModelNotNeededAmbient(346)
    elseif POIPointFaction == 5 then
        LoadWeaponPOIModel(335)
        PedSetWeapon(ped1, 335, 1)
        ModelNotNeededAmbient(335)
    else
        weapon = 331
        LoadWeaponPOIModel(weapon)
        PedSetWeapon(ped1, weapon, 1)
        ModelNotNeededAmbient(331)
    end
    PedPlayCatch(ped1, ped2, 22000)
    PedPlayCatch(ped2, ped1, 22000)
end

function F_Cheerleading(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = 180
    ped2 = 181
    ped3 = 182
    if ped1 == -1 or ped2 == -1 or ped3 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    LoadPedPOIModel(ped3)
    local cheerleader1, cheerleader2, cheerleader3
    cheerleader1 = PedCreatePOIPoint(ped1, POIInfo, 1, 0, 0)
    cheerleader2 = PedCreatePOIPoint(ped2, POIInfo, 0, 1, 0)
    cheerleader3 = PedCreatePOIPoint(ped3, POIInfo, -1, 0, 0)
    if cheerleader1 == -1 or cheerleader2 == -1 or cheerleader3 == -1 then
        return
    end
    PedSetFaction(cheerleader1, 2)
    PedSetFaction(cheerleader2, 2)
    PedSetFaction(cheerleader3, 2)
    ExecuteActionNode(cheerleader1, "/Global/Ambient/Scripted/Cheering", "Act/Anim/Ambient.act")
    ExecuteActionNode(cheerleader2, "/Global/Ambient/Scripted/Cheering", "Act/Anim/Ambient.act")
    ExecuteActionNode(cheerleader3, "/Global/Ambient/Scripted/Cheering", "Act/Anim/Ambient.act")
end

function F_Workout(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local hour, minute = ClockGet()
    local ped1 = GetGymModel(2)
    local ped2 = GetGymModel(2)
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local jock1, jock2
    if PedGetPedCountWithModel(ped1) == 0 then
        jock1 = PedCreatePOIPoint(ped1, POIInfo, 0, 1, 0)
    end
    if PedGetPedCountWithModel(ped2) == 0 then
        jock2 = PedCreatePOIPoint(ped2, POIInfo, 0, -1, 0)
    end
    if PedIsValid(jock1) then
        PedClearAllWeapons(jock1)
        ExecuteActionNode(jock1, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    end
    if PedIsValid(jock2) then
        PedClearAllWeapons(jock2)
        ExecuteActionNode(jock2, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    end
end

function F_InstantBully(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if shared.bBathroomPOIEnabled == false then
        return
    end
    local randomroll = math.random(1, 100)
    local model
    if POIPointFaction == 12 then
        if randomroll < 40 then
            model = GetStudent(11, 1)
        elseif randomroll < 60 then
            model = GetStudent(4, 1)
        elseif randomroll < 90 then
            model = GetStudent(2, 1)
        elseif randomroll <= 100 then
            model = GetStudent(5, 1)
        end
    else
        model = GetStudent(POIPointFaction, 1)
    end
    if model == -1 then
        return
    end
    LoadPedPOIModel(model)
    local char = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    if PedGetPedToTypeAttitude(char, 13) == 1 or PedGetPedToTypeAttitude(char, 13) == 2 then
        PedSetFlag(char, 120, true)
        PedOverrideStat(char, 14, 80)
        PedSetEmotionTowardsPed(char, gPlayer, 0, false)
        PedSetWantsToSocializeWithPed(char, gPlayer)
    else
        PedSetFlag(char, 120, true)
        PedWander(char, 0)
        PedSetWantsToSocializeWithPed(char, gPlayer)
    end
end

function F_Crying(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local ped1, student
    if POIPointFaction == 12 then
        POIPointFaction = 6
    end
    if math.random(1, 100) > 75 then
        ped1 = GetStudent(POIPointFaction, 2, -1)
    else
        ped1 = GetStudent(POIPointFaction, 1, -1)
    end
    if ped1 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    student = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if student == -1 then
        return
    end
    ExecuteActionNode(student, "/Global/Ambient/Scripted/Crying", "Act/Anim/Ambient.act")
end

function F_OutsideClass(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = GetStudent(6, 1, -1)
    if ped1 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    local student
    student = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if student == -1 then
        return
    end
    PedStop(student)
end

function F_PrincipalPOI(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if not MissionActiveSpecific("1_01") then
        local wanderchoice = false
        local model
        if POIGender == 2 then
            return
        elseif POIGender == 1 or POIGender == 0 then
            local prefectchoice = math.random(1, 100)
            if 50 < prefectchoice then
                model = RandomElement4(49, 50, 51, 52)
                wanderchoice = true
            else
                return
            end
        end
        LoadPedPOIModel(model)
        local char = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
        if char == -1 then
            return
        end
        if wanderchoice == true then
            PedClearPOI(char)
            PedClearObjectives(char)
            PedWander(char, 0)
        end
    end
end

function F_BullyDogs(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = RandomElement3(141, 219, 220)
    LoadPedPOIModel(ped1)
    local dog
    dog = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if dog == -1 then
        return
    end
    PedSetPedToTypeAttitude(dog, 13, 0)
    GameSetPedStat(dog, 14, 100)
    PedSetFlag(dog, 120, true)
    PedWander(dog, 0)
end

function F_GuardDog(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = RandomElement3(141, 219, 220)
    LoadPedPOIModel(ped1)
    local dog
    dog = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if dog == -1 then
        return
    end
    PedSetPedToTypeAttitude(dog, 13, 0)
    PedSetPedToTypeAttitude(dog, 5, 4)
    PedSetPedToTypeAttitude(dog, 3, 4)
    PedSetPedToTypeAttitude(dog, 4, 0)
    GameSetPedStat(dog, 14, 100)
    GameSetPedStat(dog, 6, 0)
    if POIIsValid(POIInfo) then
        local x, y, z = POIGetPosXYZ(POIInfo)
        PedSetTetherToXYZ(dog, x, y, z, 20)
    end
    ExecuteActionNode(dog, "/Global/Ambient/Scripted/GuardDog", "Act/Anim/Ambient.act")
end

function F_Fireman(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = 82
    LoadPedPOIModel(ped1)
    char = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedSetFlag(char, 120, true)
    PedWander(char, 0)
end

function F_BikeCheckout(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = RandomElement4(279, 278, 280, 274)
    local vehicle, curPed
    local x, y, z = 0, 0, 0
    local pedcount
    if POIPointNum == 0 then
        POIPointNum = math.random(2, 3)
    end
    LoadVehiclePOIModel(ped1)
    for i = 1, POIPointNum do
        local pedModel = GetStudent(POIPointFaction, 1, -1)
        LoadPedPOIModel(pedModel)
        if pedModel ~= -1 then
            if i == 1 then
                curPed = PedCreatePOIPoint(pedModel, POIInfo, 0, 0, 0)
            elseif i == 2 then
                curPed = PedCreatePOIPoint(pedModel, POIInfo, -1.5, 0, 0)
            elseif i == 3 then
                curPed = PedCreatePOIPoint(pedModel, POIInfo, 0, 1.5, 0)
            elseif i == 4 then
                curPed = PedCreatePOIPoint(pedModel, POIInfo, 1.5, 0, 0)
            end
        end
        if curPed ~= -1 and PedIsValid(curPed) and vehicle == nil then
            x, y, z = PedGetPosXYZ(curPed)
            vehicle = VehicleCreateXYZ(ped1, x, y, z)
            VehicleModelNotNeededAmbient(vehicle)
            if VehicleIsValid(vehicle) then
                VehicleFaceHeading(vehicle, PedGetHeading(curPed))
            end
            PedDelete(curPed)
        end
        if vehicle ~= -1 and PedIsValid(curPed) then
            PedTargetVehicle(curPed, vehicle)
            PedFaceXYZ(curPed, x, y, z, 0)
            VehicleSetOwner(vehicle, curPed)
            PedSetFlag(curPed, 120, true)
        end
    end
    if vehicle ~= nil and VehicleIsValid(vehicle) and vehicle ~= -1 then
        VehicleMakeAmbient(vehicle)
    end
end

function F_CarnivalWalker(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local charchoice = math.random(0, 4)
    if charchoice == 0 then
        charchoice = 114
    elseif charchoice == 1 then
        charchoice = 113
    elseif charchoice == 2 then
        charchoice = 115
    elseif charchoice == 3 then
        charchoice = 143
    elseif charchoice == 4 then
        charchoice = 140
    end
    if 0 < PedGetPedCountWithModel(charchoice) then
        return
    end
    LoadPedPOIModel(charchoice)
    local char = PedCreatePOIPoint(charchoice, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedSetFlag(char, 120, true)
    PedWander(char, 0)
end

function F_CBarkerGame(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local hour, minute = ClockGet()
    if 1 <= hour and hour < 8 then
        return
    end
    local charchoice = 114
    LoadPedPOIModel(charchoice)
    local char = PedCreatePOIPoint(charchoice, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    ExecuteActionNode(char, "/Global/Ambient/Scripted/Carny/CarnyGame", "Act/Anim/Ambient.act")
end

function F_CBarkerGame2(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local hour, minute = ClockGet()
    if 1 <= hour and hour < 8 then
        return
    end
    local charchoice = 143
    LoadPedPOIModel(charchoice)
    local char = PedCreatePOIPoint(charchoice, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    ExecuteActionNode(char, "/Global/Ambient/Scripted/Carny/CarnyGame", "Act/Anim/Ambient.act")
end

function F_CBarkerHouse(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local hour, minute = ClockGet()
    if 1 <= hour and hour < 8 then
        return
    end
    local charchoice = 113
    LoadPedPOIModel(charchoice)
    local char = PedCreatePOIPoint(charchoice, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    ExecuteActionNode(char, "/Global/Ambient/Scripted/Carny/CarnyHouse", "Act/Anim/Ambient.act")
end

function F_Industrial(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local model = RandomElement3(123, 236, 237)
    LoadPedPOIModel(model)
    local char = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedSetFlag(char, 120, true)
    PedWander(char, 0)
end

function F_DockWorker(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    LoadPedPOIModel(195)
    local char = PedCreatePOIPoint(195, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedSetFlag(char, 120, true)
    PedWander(char, 0)
end

function F_MillWorker(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    LoadPedPOIModel(222)
    local char = PedCreatePOIPoint(222, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedSetFlag(char, 120, true)
    PedWander(char, 0)
end

function F_Pirate(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    LoadPedPOIModel(173)
    local char = PedCreatePOIPoint(173, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    PedSetAsleep(char, true)
end

function F_Rats(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    LoadPedPOIModel(136)
    local numRats = math.random(1, 2)
    for i = 0, numRats do
        local char = PedCreatePOIPoint(136, POIInfo, math.random(-1, 1), math.random(-1, 1), 0)
        if char ~= -1 then
            PedWander(char, 0)
            PedClearPOI(char)
        end
    end
end

local gAsylumThread = false
local gAsylumTable = {}

function UpdateAsylum()
    if gAsylumThread == false then
        if (not MissionActiveSpecific2("3_S11") or not MissionActiveSpecific("5_03")) and PlayerIsInTrigger(TRIGGER._ASYLUMPATROLS) then
            gAsylumThread = true
            LoadPedPOIModel(53)
            gAsylumTable.ped1 = PedCreatePoint(53, POINTLIST._ASYLUMSPAWNPOINTS, 1)
            PedModelNotNeededAmbient(gAsylumTable.ped1)
            ModelNotNeededAmbient(53)
            if gAsylumTable.ped1 ~= -1 then
                PedFollowPath(gAsylumTable.ped1, PATH._ASYLUMPATH1, 2, 0)
                PedSetActionNode(gAsylumTable.ped1, "/Global/Ambient/Scripted/OrderlyPatrol/OrderlyPatrol_Child", "Act/Anim/Ambient.act")
            end
            gAsylumTable.ped2 = PedCreatePoint(53, POINTLIST._ASYLUMSPAWNPOINTS, 2)
            PedModelNotNeededAmbient(gAsylumTable.ped2)
            ModelNotNeededAmbient(53)
            if gAsylumTable.ped2 ~= -1 then
                PedFollowPath(gAsylumTable.ped2, PATH._ASYLUMPATH2, 2, 0)
                PedSetActionNode(gAsylumTable.ped2, "/Global/Ambient/Scripted/OrderlyPatrol/OrderlyPatrol_Child", "Act/Anim/Ambient.act")
            end
        end
    elseif not PlayerIsInTrigger(TRIGGER._ASYLUMPATROLS) then
        gAsylumThread = false
        if gAsylumTable.ped1 ~= nil and gAsylumTable.ped1 ~= -1 and not PedIsDead(gAsylumTable.ped1) then
            PedDelete(gAsylumTable.ped1)
            gAsylumTable.ped1 = -1
        end
        if gAsylumTable.ped2 ~= nil and gAsylumTable.ped2 ~= -1 and not PedIsDead(gAsylumTable.ped2) then
            PedDelete(gAsylumTable.ped2)
            gAsylumTable.ped2 = -1
        end
    end
end

function F_ClassSmokers(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if POIGender == 0 then
        POIGender = 1
    end
    if shared.bBathroomPOIEnabled == false then
        return
    end
    ped1 = GetStudent(POIPointFaction, POIGender, -1)
    if ped1 == -1 then
        return
    end
    if F_IsSmallKid(ped1) then
        return
    end
    LoadPedPOIModel(ped1)
    local char = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    local result = ExecuteActionNode(char, "/Global/Ambient/Scripted/Wall_Smoke", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(char, 0)
    end
end

function F_SmokingFireman(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    ped1 = 82
    if ped1 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    local char = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    local result = ExecuteActionNode(char, "/Global/Ambient/Scripted/Wall_Smoke", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(char, 0)
    end
end

function F_Straggler(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local model = GetStudent(POIPointFaction, 1, -1)
    if model == -1 then
        return
    end
    LoadPedPOIModel(model)
    local ped = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    if ped == -1 then
        return
    end
    PedOverrideStat(ped, 6, 80)
    PedSetFlag(ped, 120, true)
    PedWander(ped, 1)
end

function F_RandomStudent(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local model
    if POIPointFaction == 8 then
        if MissionActive() then
            return
        else
            local teachroll = math.random(1, 100)
            if 60 <= teachroll then
                return
            end
        end
    end
    model = GetStudent(POIPointFaction, POIGender, -1)
    local dirroll = math.random(1, 100)
    if model == -1 then
        return
    end
    LoadPedPOIModel(model)
    local ped = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    if ped == -1 then
        return
    end
    if 50 < dirroll then
        local head = PedGetHeading(ped) + 180
        PedFaceHeading(ped, head, 0)
    end
    if POIPointFaction == 2 then
        if not PedIsFemale(ped) then
            PedClearAllWeapons(ped)
            while not WeaponRequestModel(381, true) and POIIsValid(POIInfo) do
                Wait(0)
            end
            ModelNotNeededAmbient(381)
            PedSetWeaponNow(ped, 381, 1)
            ExecuteActionNode(ped, "/Global/Ambient/Scripted/Dribble", "Act/Anim/Ambient.act")
        else
            PedSetFlag(ped, 120, true)
            PedWander(ped, 0)
        end
    else
        PedSetFlag(ped, 120, true)
        PedWander(ped, 0)
    end
end

function F_LockerStuff(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if GetMissionSuccessCount("1_02B") == 0 then
        return
    end
    local charType
    --print("POIPointFaction: ", POIPointFaction)
    if POIPointFaction == 11 or POIPointFaction == 4 or POIPointFaction == 5 or POIPointFaction == 2 then
        charType = POIPointFaction
    elseif POIPointFaction == 1 then
        return
    else
        charType = RandomElement4(4, 11, 5, 2)
    end
    if charType == 5 then
        ped1 = GetStudent(charType, 1, -1)
        ped2 = GetStudent(1, 1, -1)
    else
        ped1 = GetStudent(charType, 1, -1)
        charType = RandomElement2(1, 6)
        ped2 = GetStudent(charType, 1, -1)
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    POISetScriptedPedExitObjective(POIInfo, 0)
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 0, 1, 0)
    local Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if Victim == -1 or Thug == -1 then
        return
    end
    PedClearAllWeapons(Thug)
    PedLockTarget(Thug, Victim, 0)
    PedLockTarget(Victim, Thug, 0)
    PedFaceObjectNow(Victim, Thug, 2)
    PedFaceObjectNow(Thug, Victim, 2)
    local result = POIActionNode2(Thug, Victim, "/Global/Ambient/Scripted/LockerStuff", "Act/Anim/Ambient.act")
    if result == true then
        PropTimer = GetTimer()
    end
end

function F_TrashStuff(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local charType
    if POIPointFaction == 11 or POIPointFaction == 4 or POIPointFaction == 5 or POIPointFaction == 2 then
        charType = POIPointFaction
    elseif POIPointFaction == 1 then
        return
    else
        charType = RandomElement4(4, 11, 5, 2)
    end
    if charType == 5 then
        ped1 = GetStudent(charType, 1, -1)
        ped2 = GetStudent(1, 1, -1)
    else
        ped1 = GetStudent(charType, 1, -1)
        charType = RandomElement2(1, 6)
        ped2 = GetStudent(charType, 1, -1)
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    POISetScriptedPedExitObjective(POIInfo, 0)
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 0, 1, 0)
    local Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if Victim == -1 or Thug == -1 then
        return
    end
    PedClearAllWeapons(Thug)
    PedLockTarget(Thug, Victim, 0)
    PedLockTarget(Victim, Thug, 0)
    PedFaceObjectNow(Victim, Thug, 2)
    PedFaceObjectNow(Thug, Victim, 2)
    local result = POIActionNode2(Thug, Victim, "/Global/Ambient/Scripted/CanDump", "Act/Anim/Ambient.act")
end

function F_Swirlie(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if shared.bBathroomPOIEnabled == false then
        return
    end
    local charType, sizeType, sizeType2
    --print("POIPointFaction: ", POIPointFaction)
    if POIPointFaction == 11 or POIPointFaction == 4 or POIPointFaction == 5 or POIPointFaction == 2 then
        charType = POIPointFaction
    elseif POIPointFaction == 1 then
        return
    else
        charType = RandomElement4(4, 11, 5, 2)
    end
    if charType == 5 then
        ped1 = GetStudent(charType, 1, -1)
        ped2 = GetStudent(1, 1, -1)
    else
        sizeType = 1
        ped1 = GetStudent(charType, 1, -1)
        charType = RandomElement2(1, 6)
        if charType == 1 then
            ped2 = GetStudent(charType, 1, -1)
        else
            if sizeType == 1 then
                sizeType2 = 1
            else
                sizeType2 = 1
            end
            ped2 = GetStudent(charType, 1, -1)
        end
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    POISetScriptedPedExitObjective(POIInfo, 0)
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 1, 0, 0)
    local Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if Victim == -1 or Thug == -1 then
        return
    end
    if POIIsValid(POIInfo) then
        local x, y, z = POIGetPosXYZ(POIInfo)
        PAnimOpenDoors(x, y, z, 0, "StalDoor")
    end
    PedClearAllWeapons(Thug)
    PedLockTarget(Thug, Victim, 0)
    PedLockTarget(Victim, Thug, 0)
    PedFaceObjectNow(Victim, Thug, 2)
    PedFaceObjectNow(Thug, Victim, 2)
    local result = POIActionNode2(Thug, Victim, "/Global/Ambient/Scripted/Swirlie", "Act/Anim/Ambient.act")
end

function F_SocialHumiliation(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local charType, sizeType, sizeType2
    if POIGender == 0 then
        POIGender = 1
    end
    --print("POIPointFaction: ", POIPointFaction)
    if POIPointFaction == 11 or POIPointFaction == 4 or POIPointFaction == 5 or POIPointFaction == 9 or POIPointFaction == 2 then
        charType = POIPointFaction
    elseif POIPointFaction == 1 then
        return
    else
        charType = RandomElement4(4, 11, 5, 2)
    end
    if charType == 5 then
        ped1 = GetStudent(charType, POIGender, -1)
        ped2 = GetStudent(1, POIGender, -1)
    elseif charType == 9 then
        ped1 = GetStudent(charType, POIGender, -1)
        ped2 = GetStudent(5, POIGender, -1)
    else
        sizeType = RandomElement2(2, 1)
        ped1 = GetStudent(charType, 1, -1)
        charType = RandomElement2(1, 6)
        if charType == 1 then
            ped2 = GetStudent(charType, POIGender, -1)
        else
            sizeType2 = RandomElement2(0, 1)
            ped2 = GetStudent(charType, POIGender, -1, false)
        end
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    POISetScriptedPedExitObjective(POIInfo, 0)
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Victim = PedCreatePOIPoint(ped2, POIInfo, 0, 1, 0)
    local Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if Victim == -1 or Thug == -1 then
        return
    end
    PedSetFlag(Thug, 120, true)
    PedSetFlag(Victim, 120, true)
    PedClearAllWeapons(Thug)
    PedLockTarget(Thug, Victim, 0)
    PedLockTarget(Victim, Thug, 0)
    PedFaceObjectNow(Victim, Thug, 2)
    PedFaceObjectNow(Thug, Victim, 2)
    PedSetWantsToSocializeWithPed(Victim, Thug)
    PedSetWantsToSocializeWithPed(Thug, Victim)
    PedSetEmotionTowardsPed(Thug, Victim, 0)
    PedSetEmotionTowardsPed(Victim, Thug, 5)
    PedOverrideStat(Thug, 14, 100)
end

function F_Criminal(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if MissionActive() then
        return
    end
    local Thug = -1
    local charType
    --print("POIPointFaction: ", POIPointFaction)
    if Thug == -1 then
        if POIPointFaction == 8 or POIPointFaction == 0 then
            charType = RandomElement5(4, 11, 5, 2, 1)
        elseif POIPointFaction ~= 12 then
            charType = POIPointFaction
        else
            charType = RandomElement5(4, 11, 5, 2, 1)
        end
        ped1 = GetStudent(charType, 1, -1)
        if ped1 == -1 or ped2 == -1 then
            return
        end
        LoadPedPOIModel(ped1)
        Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    end
    if Thug == -1 then
        return
    end
    local dirroll = math.random(1, 100)
    PedSetFlag(Thug, 120, true)
    PedClearAllWeapons(Thug)
    if 50 < dirroll then
        local head = PedGetHeading(Thug) + 180
        PedFaceHeading(Thug, head, 0)
    end
    PedWander(Thug, 0)
    PedOverrideStat(Thug, 15, 100)
    PedOverrideStat(Thug, 14, 75)
    local hour, minute = ClockGet()
    if 21 <= hour or hour < 7 then
        local WChoice = math.random(1, 100)
        if 50 < WChoice then
            F_SelectBrawlWeapon(Thug, charType)
        end
    else
        F_ChoosePrank(Thug, charType)
    end
end

function F_RoofSniper(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if MissionActive() then
        return
    end
    local Thug = -1
    local charType
    --print("POIPointFaction: ", POIPointFaction)
    if Thug == -1 then
        if POIPointFaction ~= 12 then
            charType = POIPointFaction
        else
            charType = RandomElement3(3, 11, 1)
        end
        ped1 = GetStudent(charType, 1, -1)
        if ped1 == -1 or ped2 == -1 then
            return
        end
        LoadPedPOIModel(ped1)
        Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    end
    if Thug == -1 then
        return
    end
    local dirroll = math.random(1, 100)
    PedSetFlag(Thug, 120, true)
    PedSetPedToTypeAttitude(Thug, 13, 0)
    PedSetPedToTypeAttitude(Thug, 7, 0)
    PedSetPedToTypeAttitude(Thug, 9, 0)
    PedSetFlag(Thug, 2, true)
    PedSetStationary(Thug, true)
    PedSetHealth(Thug, 10)
    PedRooftopAttacker(Thug)
    PedSetCheap(Thug, true)
    PedClearAllWeapons(Thug)
    F_ChooseSniperWeapon(Thug)
end

function F_ProjAttack(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local chartype
    if shared.gNoEggers == true then
        return
    end
    if POIPointFaction ~= 12 then
        charType = POIPointFaction
    else
        charType = RandomElement5(4, 11, 5, 2, 1)
    end
    local spawnGender = 1
    local Thug, ThugChoice
    local numthugs = 0
    if 1 < POIPointNum then
        numthugs = math.random(1, POIPointNum)
    else
        numthugs = 1
    end
    for count = 1, numthugs do
        ThugChoice = GetStudent(charType, spawnGender)
        if ThugChoice ~= -1 then
            LoadPedPOIModel(ThugChoice)
            Thug = PedCreatePOIPoint(ThugChoice, POIInfo, 0, count * 2, 0)
            if Thug ~= -1 then
                PedSetFlag(Thug, 120, true)
                PedClearAllWeapons(Thug)
                PedWander(Thug, 0)
                F_SelectProjWeapon(Thug, charType)
                if Thug ~= -1 then
                    PedSetTaskNode(Thug, "/Global/AI/Reactions/Criminal/ProjAttack/ScriptedProj/ScriptedProjtrack", "Act/AI/AI.act")
                    GameSetPedStat(Thug, 11, 80)
                end
            end
        end
    end
end

function F_Truck(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if ChapterGet() < 4 then
        return
    end
    if AreaIsLoading() then
        return
    end
    local driverc = RandomElement6(123, 223, 222, 195, 236, 237)
    local carc = RandomElement3(291, 297, 288)
    if driverc == -1 or carc == -1 then
        return
    end
    LoadPedPOIModel(driverc)
    while not VehicleRequestModel(carc, true) and POIIsValid(POIInfo) do
        Wait(0)
    end
    local x, y, z = 0
    local CanCreate = false
    if POIIsValid(POIInfo) then
        for pos = 1, 20 do
            x, y, z = VehicleFindRandomSpawnPosition(carc)
            if x ~= 9999 then
                pos = 21
                CanCreate = true
            else
                pos = pos + 1
            end
        end
        if CanCreate == true then
            local car = VehicleCreateXYZ(carc, x, y, z)
            local driver = PedCreateXYZ(driverc, x + 4, y, z)
            if car ~= -1 and driver ~= -1 then
                VehicleModelNotNeededAmbient(car)
                PedSetFlag(driver, 120, true)
                VehicleSetOwner(car, driver)
                PedWarpIntoCar(driver, car)
                VehicleSetDrivingMode(car, 0)
                PedMakeAmbient(driver)
                VehicleMakeAmbient(car)
            end
        end
    end
    ModelNotNeededAmbient(driverc)
    ModelNotNeededAmbient(carc)
end

function F_WorkerHangout(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local ped1 = RandomElement6(123, 223, 222, 195, 236, 237)
    local ped2 = RandomElement6(123, 223, 222, 195, 236, 237)
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local worker1 = PedCreatePOIPoint(ped1, POIInfo, 0, 1, 0)
    local worker2 = PedCreatePOIPoint(ped2, POIInfo, 0, -1, 0)
    if worker1 == -1 or worker2 == -1 then
        return
    end
    PedSetFlag(worker1, 120, true)
    PedSetFlag(worker2, 120, true)
    PedFaceObject(worker1, worker2, 2, 0)
    PedFaceObject(worker2, worker1, 2, 0)
    PedSetWantsToSocializeWithPed(worker1, worker2)
    PedSetWantsToSocializeWithPed(worker2, worker1)
    PedSetEmotionTowardsPed(worker2, worker1, 8)
    PedSetEmotionTowardsPed(worker1, worker2, 8)
end

function F_WorkerSmoking(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local ped1 = RandomElement6(123, 223, 222, 195, 236, 237)
    if ped1 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    local char = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    local result = ExecuteActionNode(char, "/Global/Ambient/Scripted/Wall_Smoke", "Act/Anim/Ambient.act")
    if result == true then
        PedWander(char, 0)
    end
end

function F_Biker(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if AreaIsLoading() or GetCurrentNumOfAmbientBikes() > 4 then
        return
    end
    local bike, facchoice
    local hour, minute = ClockGet()
    if POIPointFaction == 12 then
        if 19 <= hour or hour < 7 then
            facchoice = RandomElement2(3, 4)
        else
            facchoice = RandomElement7(11, 1, 6, 6, 5, 2, 4)
        end
    else
        facchoice = POIPointFaction
    end
    if facchoice == -1 then
        return
    end
    if POIGender == 0 then
        if facchoice ~= 6 then
            if math.random(1, 100) > 15 or facchoice == 11 then
                POIGender = 1
            else
                POIGender = 2
            end
        elseif math.random(1, 100) > 40 then
            POIGender = 1
        else
            POIGender = 2
        end
    end
    local biker = GetStudent(facchoice, POIGender, -1)
    if POIGender == 2 then
        bike = 281
    elseif facchoice == 1 then
        bike = RandomElement2(281, 274)
    elseif facchoice == 4 then
        bike = RandomElement2(279, 282)
    elseif facchoice == 5 then
        bike = RandomElement2(283, 282)
    else
        bike = RandomElement2(274, 279)
    end
    if biker == -1 or bike == -1 then
        return
    end
    LoadPedPOIModel(biker)
    while not VehicleRequestModel(bike, true) and POIIsValid(POIInfo) do
        Wait(0)
    end
    if POIIsValid(POIInfo) then
        local x, y, z = 0, 0, 0
        local CanCreate = false
        if AreaGetVisible() ~= 62 then
            for pos = 1, 20 do
                x, y, z = VehicleFindRandomSpawnPosition(bike)
                if x ~= 9999 then
                    pos = 21
                    CanCreate = true
                else
                    pos = pos + 1
                end
            end
        elseif POIIsValid(POIInfo) then
            x, y, z = POIGetPosXYZ(POIInfo)
            CanCreate = true
        else
            CanCreate = false
        end
        local CanCreateNearXYZ = CanCreateVehicleNearXYZ(x, y, z)
        if CanCreate == true and CanCreateNearXYZ == true then
            local ride = VehicleCreateXYZ(bike, x, y, z)
            VehicleModelNotNeededAmbient(ride)
            local rider = PedCreateXYZ(biker, x, y, z + 1)
            if ride ~= -1 and rider ~= -1 then
                PedSetFlag(rider, 120, true)
                PedWander(rider, 0)
                VehicleSetOwner(ride, rider)
                PedPutOnBike(rider, ride)
                PedMakeAmbient(rider)
                VehicleMakeAmbient(ride)
                if AreaGetVisible() == 62 then
                    PedOverrideStat(rider, 24, 70)
                    PedSetFlag(rider, 120, false)
                    PedClearPOI(rider)
                end
            end
        end
    end
    ModelNotNeededAmbient(biker)
    ModelNotNeededAmbient(bike)
end

function F_SocialHangout(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if WeatherGet() == 2 or WeatherGet() == 5 then
        return
    end
    local ped1 = GetStudent(POIPointFaction, POIGender, -1)
    local ped2 = GetStudent(POIPointFaction, POIGender, -1)
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local worker1 = PedCreatePOIPoint(ped1, POIInfo, 0, 1, 0)
    local worker2 = PedCreatePOIPoint(ped2, POIInfo, 0, -1, 0)
    if worker1 == -1 or worker2 == -1 then
        return
    end
    PedSetFlag(worker1, 120, true)
    PedSetFlag(worker2, 120, true)
    PedFaceObject(worker1, worker2, 2, 0)
    PedFaceObject(worker2, worker1, 2, 0)
    PedSetWantsToSocializeWithPed(worker1, worker2)
    PedSetWantsToSocializeWithPed(worker2, worker1)
    PedSetEmotionTowardsPed(worker2, worker1, 8)
    PedSetEmotionTowardsPed(worker1, worker2, 8)
    if POIIsValid(POIInfo) then
        local x, y, z = POIGetPosXYZ(POIInfo)
        PedSetTetherToXYZ(worker1, x, y, z, 20)
        PedSetTetherToXYZ(worker2, x, y, z, 20)
    end
end

function F_DogWalker(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if POIPointFaction == 12 then
        POIPointFaction = RandomElement3(5, 6, 9)
        POIGender = 1
    end
    local ped1 = GetStudent(POIPointFaction, POIGender, -1)
    local ped2 = RandomElement3(141, 219, 220)
    if ped1 == -1 or ped2 == -1 then
        return
    end
    local x, y, z = 0, 0, 0
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Walker = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    local Dog = PedCreatePOIPoint(ped2, POIInfo, 0, -1, 0)
    if Walker == -1 or Dog == -1 then
        return
    end
    local MovePed = false
    for pos = 1, 20 do
        x, y, z = PedFindRandomSpawnPosition(Walker)
        if x ~= 9999 then
            pos = 21
            MovePed = true
        else
            pos = pos + 1
            if pos == 21 then
                if POIIsValid(POIInfo) then
                    x, y, z = POIGetPosXYZ(POIInfo)
                else
                    ModelNotNeededAmbient(ped1)
                    ModelNotNeededAmbient(ped2)
                    return
                end
            end
        end
    end
    if MovePed == true then
        PedSetPosXYZ(Walker, x, y, z)
        PedSetPosXYZ(Dog, x, y - 2, z)
    end
    PedSetFlag(Walker, 120, true)
    PedSetFlag(Dog, 120, true)
    PedWander(Dog, 0)
    PedRecruitAlly(Dog, Walker)
    PedWander(Walker, 0)
    local faction = PedGetFaction(Walker)
    PedSetPedToTypeAttitude(Dog, faction, 4)
end

function F_HCriminal(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local Thug = -1
    --print("POIPointFaction: ", POIPointFaction)
    if Thug == -1 then
        ped1 = GetStudent(12, POIGender, -1)
        if ped1 == -1 then
            return
        end
        LoadPedPOIModel(ped1)
        Thug = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    end
    if Thug == -1 then
        return
    end
    local dirroll = math.random(1, 100)
    PedSetFlag(Thug, 120, true)
    PedClearAllWeapons(Thug)
    if 50 < dirroll then
        local head = PedGetHeading(Thug) + 180
        PedFaceHeading(Thug, head, 0)
    end
    PedWander(Thug, 0)
    PedOverrideStat(Thug, 15, 100)
    PedOverrideStat(Thug, 14, 75)
    F_ChoosePrank(Thug, 12)
end

function F_CoupleWalking(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local ped1 = GetStudent(POIPointFaction, 1, -1)
    local ped2
    if POIPointFaction == 9 or POIPointFaction == 10 or POIPointFaction == 8 then
        ped2 = GetStudent(POIPointFaction, 2, -1)
    elseif POIPointFaction ~= 11 then
        ped2 = GetStudent(RandomElement2(6, POIPointFaction), 2, -1)
    else
        ped2 = GetStudent(POIPointFaction, 2, -1)
    end
    if ped1 == -1 or ped2 == -1 then
        return
    end
    LoadPedPOIModel(ped1)
    LoadPedPOIModel(ped2)
    local Walker = PedCreatePOIPoint(ped1, POIInfo, 0, 0, 0)
    local Walker2 = PedCreatePOIPoint(ped2, POIInfo, 0, -1, 0)
    if Walker == -1 or Dog == -1 then
        return
    end
    PedSetFlag(Walker, 120, true)
    PedSetFlag(Walker2, 120, true)
    PedWander(Walker, 0)
    PedRecruitAlly(Walker, Walker2, true)
    PedWander(Walker, 0)
end

function F_HStudent(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    local model = -1
    local pickedModel
    for pedCount = 1, 13 do
        pickedModel = RandomElement13(168, 159, 161, 162, 163, 164, 166, 167, 169, 170, 171, 173, 174)
        --print(pickedModel)
        if PedGetPedCountWithModel(pickedModel) > 0 then
            pickedModel = nil
            pedCount = pedCount + 1
            --print(pedCount)
        else
            model = pickedModel
            pedCount = 13
        end
    end
    local dirroll = math.random(1, 100)
    if model == -1 then
        return
    end
    LoadPedPOIModel(model)
    local ped = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    if ped == -1 then
        return
    end
    if 50 < dirroll then
        local head = PedGetHeading(ped) + 180
        PedFaceHeading(ped, head, 0)
    end
    PedSetFlag(ped, 120, true)
    PedWander(ped, 0)
end

function F_DunkMidget(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    if MissionActiveSpecific("MGDunkTank") or MissionActiveSpecific2("MGDunkTank") then
        return
    end
    local hour, minute = ClockGet()
    if 1 <= hour and hour < 8 then
        return
    end
    local charchoice = 115
    LoadPedPOIModel(charchoice)
    shared.gDunkMidget = PedCreatePOIPoint(charchoice, POIInfo, 0, 0, 0)
    if shared.gDunkMidget == -1 then
        return
    end
    PedSetInvulnerable(shared.gDunkMidget, true)
    PedSetEffectedByGravity(shared.gDunkMidget, false)
    ExecuteActionNode(shared.gDunkMidget, "/Global/Ambient/Scripted/Carny/CarnyDunk", "Act/Anim/Ambient.act")
end

function F_Russell(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    --print("TRYING RUSSELL")
    local model = 75
    if PedGetPedCountWithModel(model) > 0 then
        --print("FAILED PEDCOUNT")
        return
    end
    if MissionActive() then
        --print("MISSIONACTIVE")
        return
    end
    LoadPedPOIModel(model)
    local x, y
    z = 0, 0, 0
    if POIIsValid(POIInfo) then
        local MovePed = false
        for pos = 1, 20 do
            x, y, z = PedFindRandomSpawnPosition(model)
            if x ~= 9999 then
                pos = 21
                MovePed = true
            else
                pos = pos + 1
                if pos == 21 then
                    if POIIsValid(POIInfo) then
                        x, y, z = POIGetPosXYZ(POIInfo)
                    else
                        ModelNotNeededAmbient(model)
                        return
                    end
                end
            end
        end
    end
    local char = PedCreatePOIPoint(model, POIInfo, 0, 0, 0)
    if char == -1 then
        return
    end
    --print("CREATED RUSSELL")
    if MovePed == true then
        PedSetPosXYZ(char, x, y, z)
    end
    PedSetFlag(char, 117, false)
    if ChapterGet() == 0 then
        PedSetEmotionTowardsPed(char, gPlayer, 0, false)
    else
        PedSetPedToTypeAttitude(char, 13, 4)
    end
end
