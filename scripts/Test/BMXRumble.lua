ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
ImportScript("Library/LibHud.lua")
local gMissionPassed = false
local gWin = false
local gWaitHere = false
local gPlayerBike, gBaddie, gBaddie02, gBaddie03, gBaddie04
local gAllBaddiesDead = false
local gBaddieCounter = 0
local tblCounter = {
    icon = "HUDIcon_graf"
}
local gplayer_in_trigger = 1
local gChooseSequence = 1
local T_PlayerBikeCheck = function()
end
local T_EnemyUpdate = function()
end
local T_AllBaddiesDead = function()
end
local T_Player_OutOfBounds = function()
end
local T_ChooseAttackSequence = function()
end

function MissionSetup()
    DATLoad("BMX_Rumble.DAT", 2)
    DATInit()
    WeaponRequestModel(418)
    WeaponRequestModel(300)
    AreaTransitionPoint(62, POINTLIST._BMX_PLAYERSTART, 1)
    gPlayerBike = VehicleCreatePoint(273, POINTLIST._BMX_PLAYERSTART, 2)
    PedPutOnBike(gPlayer, gPlayerBike)
    PedSetWeaponNow(gPlayer, 300, 1)
    gBaddie = {
        point = POINTLIST._BMX_ENEMY01_START,
        model = 29,
        id = 0,
        Bikeid = 0,
        weapon = 418,
        dead = false,
        faction = 2
    }
    gBaddie02 = {
        point = POINTLIST._BMX_ENEMY02_START,
        model = 24,
        id = 0,
        Bikeid = 0,
        weapon = 418,
        dead = false,
        faction = 0
    }
    gBaddie03 = {
        point = POINTLIST._BMX_ENEMY03_START,
        model = 21,
        id = 0,
        Bikeid = 0,
        weapon = 418,
        dead = false,
        faction = 1
    }
    gBaddie04 = {
        point = POINTLIST._BMX_ENEMY04_START,
        model = 27,
        id = 0,
        Bikeid = 0,
        weapon = 418,
        dead = false,
        faction = 4
    }
    gBaddie05 = {
        point = POINTLIST._BMX_ENEMY05_START,
        model = 45,
        id = 0,
        Bikeid = 0,
        weapon = 418,
        dead = false,
        faction = 3
    }
    gBaddie06 = {
        point = POINTLIST._BMX_ENEMY06_START,
        model = 41,
        id = 0,
        Bikeid = 0,
        weapon = 418,
        dead = false,
        faction = 2
    }
    gBaddie.id = PedCreatePoint(gBaddie.model, gBaddie.point, 1)
    gBaddie02.id = PedCreatePoint(gBaddie02.model, gBaddie02.point, 1)
    gBaddie03.id = PedCreatePoint(gBaddie03.model, gBaddie03.point, 1)
    gBaddie04.id = PedCreatePoint(gBaddie04.model, gBaddie04.point, 1)
    gBaddie05.id = PedCreatePoint(gBaddie05.model, gBaddie05.point, 1)
    gBaddie06.id = PedCreatePoint(gBaddie06.model, gBaddie06.point, 1)
    AddBlipForChar(gBaddie.id, 4, 2, 1)
    AddBlipForChar(gBaddie02.id, 4, 2, 1)
    AddBlipForChar(gBaddie03.id, 4, 2, 1)
    AddBlipForChar(gBaddie04.id, 4, 2, 1)
    AddBlipForChar(gBaddie05.id, 4, 2, 1)
    AddBlipForChar(gBaddie06.id, 4, 2, 1)
    gBaddie.Bikeid = VehicleCreatePoint(273, gBaddie.point, 2)
    gBaddie02.Bikeid = VehicleCreatePoint(273, gBaddie02.point, 2)
    gBaddie03.Bikeid = VehicleCreatePoint(273, gBaddie03.point, 2)
    gBaddie04.Bikeid = VehicleCreatePoint(273, gBaddie04.point, 2)
    gBaddie05.Bikeid = VehicleCreatePoint(273, gBaddie05.point, 2)
    gBaddie06.Bikeid = VehicleCreatePoint(273, gBaddie06.point, 2)
    PedPutOnBike(gBaddie.id, gBaddie.Bikeid)
    PedPutOnBike(gBaddie02.id, gBaddie02.Bikeid)
    PedPutOnBike(gBaddie03.id, gBaddie03.Bikeid)
    PedPutOnBike(gBaddie04.id, gBaddie04.Bikeid)
    PedPutOnBike(gBaddie05.id, gBaddie05.Bikeid)
    PedPutOnBike(gBaddie06.id, gBaddie06.Bikeid)
    PedSetWeaponNow(gBaddie.id, gBaddie.weapon, 1)
    PedSetWeaponNow(gBaddie02.id, gBaddie02.weapon, 1)
    PedSetWeaponNow(gBaddie03.id, gBaddie03.weapon, 1)
    PedSetWeaponNow(gBaddie04.id, gBaddie04.weapon, 1)
    PedSetWeaponNow(gBaddie05.id, gBaddie05.weapon, 1)
    PedSetWeaponNow(gBaddie06.id, gBaddie06.weapon, 1)
    PedSetFaction(gBaddie.id, gBaddie.faction)
    PedSetFaction(gBaddie02.id, gBaddie02.faction)
    PedSetFaction(gBaddie03.id, gBaddie03.faction)
    PedSetFaction(gBaddie04.id, gBaddie04.faction)
    PedSetFaction(gBaddie05.id, gBaddie05.faction)
    PedSetFaction(gBaddie06.id, gBaddie06.faction)
    PedSetTetherToTrigger(gBaddie.id, TRIGGER._BMX_WARNING_TRIG)
    PedSetTetherToTrigger(gBaddie02.id, TRIGGER._BMX_WARNING_TRIG)
    PedSetTetherToTrigger(gBaddie03.id, TRIGGER._BMX_WARNING_TRIG)
    PedSetTetherToTrigger(gBaddie04.id, TRIGGER._BMX_WARNING_TRIG)
    PedSetTetherToTrigger(gBaddie05.id, TRIGGER._BMX_WARNING_TRIG)
    PedSetTetherToTrigger(gBaddie06.id, TRIGGER._BMX_WARNING_TRIG)
    tblCounter.max = 6
    tblCounter.start = 6
    CameraSetShot(8, "PaperRoute", false)
end

function MissionCleanup()
    DATUnload(2)
    CameraSetShot(8, "Regular", false)
    L_HUDBlipCleanup()
    L_HUDCounterCleanup()
    if PlayerIsInAnyVehicle() then
        PlayerDetachFromVehicle()
    end
    VehicleDelete(gBaddie.Bikeid)
    VehicleDelete(gBaddie02.Bikeid)
    VehicleDelete(gBaddie03.Bikeid)
    VehicleDelete(gBaddie04.Bikeid)
    VehicleDelete(gBaddie05.Bikeid)
    VehicleDelete(gBaddie06.Bikeid)
    VehicleDelete(gPlayerBike)
end

function main()
    CS_StartMission()
    while not gMissionPassed do
        Wait(0)
    end
    CS_EndMission()
    while gWaitHere do
        Wait(0)
    end
    if gWin then
        MissionSucceed()
    else
        MissionFail()
    end
end

function F_StartMission()
    L_HUDCounterLoad(tblCounter)
    TextPrintString("Take Out Enemies On Bikes", 3, 1)
    CreateThread(T_ChooseAttackSequence)
    CreateThread(T_PlayerBikeCheck)
    CreateThread(T_AllBaddiesDead)
    CreateThread(T_Player_OutOfBounds)
end

function T_PlayerBikeCheck()
    local Timer = 0
    while not gMissionPassed do
        if not PlayerIsInAnyVehicle() then
            TextPrintString("Get back on a bike!", 3, 1)
            MissionTimerStart(10)
            while not PlayerIsInAnyVehicle() do
                Timer = Timer + 1
                if Timer == 20 then
                    TextPrintString("You didn't get back on your bike in time", 3, 1)
                    MissionTimerStop()
                    gMissionPassed = true
                    Wait(500)
                    break
                end
                Wait(500)
            end
            Timer = 0
            MissionTimerStop()
        end
        Wait(0)
    end
end

function T_AllBaddiesDead()
    while not gMissionPassed do
        if PedIsDead(gBaddie.id) and not gBaddie.dead then
            gBaddie.dead = true
            CounterIncrementCurrent(-1)
            gBaddieCounter = gBaddieCounter + 1
        end
        if PedIsDead(gBaddie02.id) and not gBaddie02.dead then
            gBaddie02.dead = true
            CounterIncrementCurrent(-1)
            gBaddieCounter = gBaddieCounter + 1
        end
        if PedIsDead(gBaddie03.id) and not gBaddie03.dead then
            gBaddie03.dead = true
            CounterIncrementCurrent(-1)
            gBaddieCounter = gBaddieCounter + 1
        end
        if PedIsDead(gBaddie04.id) and not gBaddie04.dead then
            gBaddie04.dead = true
            CounterIncrementCurrent(-1)
            gBaddieCounter = gBaddieCounter + 1
        end
        if PedIsDead(gBaddie05.id) and not gBaddie05.dead then
            gBaddie05.dead = true
            CounterIncrementCurrent(-1)
            gBaddieCounter = gBaddieCounter + 1
        end
        if PedIsDead(gBaddie06.id) and not gBaddie06.dead then
            gBaddie06.dead = true
            CounterIncrementCurrent(-1)
            gBaddieCounter = gBaddieCounter + 1
        end
        if 6 <= gBaddieCounter then
            gWin = true
            gMissionPassed = true
        end
        Wait(0)
    end
end

function T_Player_OutOfBounds()
    local Timer = 0
    while not gMissionPassed do
        if not PlayerIsInTrigger(TRIGGER._BMX_WARNING_TRIG) then
            TextPrintString("Get back in the Rumble Area", 3, 2)
            MissionTimerStart(5)
            while not PlayerIsInTrigger(TRIGGER._BMX_WARNING_TRIG) do
                Timer = Timer + 1
                if Timer == 10 then
                    TextPrintString("You went out of bounds!", 3, 1)
                    MissionTimerStop()
                    gMissionPassed = true
                    Wait(500)
                    break
                end
                Wait(500)
            end
            Timer = 0
            MissionTimerStop()
        end
        Wait(0)
    end
end

function CS_StartMission()
    PlayerSetControl(0)
    PedSetInvulnerable(gPlayer, true)
    CameraFade(1000, 0)
    Wait(1000)
    CS_Dude = PedCreatePoint(46, POINTLIST._BMX_CS_DUDE)
    CameraFade(1000, 1)
    CameraSetWidescreen(true)
    CameraSetXYZ(240.885, -248.691, 37.14, 242.195, -254.391, 35.901)
    TextPrintString("This is the BMX Rumble, last man standing wins.", 3, 2)
    WaitSkippable(3000)
    TextPrintString("Stay on your bike and knock out the other contenders!", 3, 2)
    WaitSkippable(3000)
    CameraFade(1000, 0)
    Wait(1000)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraFade(1000, 1)
    PedSetInvulnerable(gPlayer, false)
    PlayerSetControl(1)
    F_StartMission()
end

function CS_EndMission()
    PlayerSetControl(0)
    PedSetInvulnerable(gPlayer, true)
    CameraFade(1000, 0)
    Wait(1000)
    CameraFade(1000, 1)
    CameraSetWidescreen(true)
    CameraSetXYZ(240.885, -248.691, 37.14, 242.195, -254.391, 35.901)
    TextPrintString("That's it, the Rumble is over", 3, 2)
    WaitSkippable(3000)
    if gWin then
        TextPrintString("Jimmy Wins!", 3, 2)
        WaitSkippable(3000)
    end
    CameraFade(1000, 0)
    Wait(1000)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraFade(1000, 1)
    PedSetInvulnerable(gPlayer, false)
    PlayerSetControl(1)
    gWaitHere = false
end

function T_ChooseAttackSequence()
    while not gMissionPassed do
        if gChooseSequence == 1 then
            F_AttackSequence(1)
        elseif gChooseSequence == 2 then
            F_AttackSequence(2)
        elseif gChooseSequence == 3 then
            F_AttackSequence(3)
        end
        Wait(0)
    end
end

function F_AttackSequence(SequenceNumber)
    if PedIsValid(gBaddie.id) then
        PedClearObjectives(gBaddie.id)
    end
    if PedIsValid(gBaddie02.id) then
        PedClearObjectives(gBaddie02.id)
    end
    if PedIsValid(gBaddie03.id) then
        PedClearObjectives(gBaddie03.id)
    end
    if PedIsValid(gBaddie04.id) then
        PedClearObjectives(gBaddie04.id)
    end
    if PedIsValid(gBaddie05.id) then
        PedClearObjectives(gBaddie05.id)
    end
    if PedIsValid(gBaddie06.id) then
        PedClearObjectives(gBaddie06.id)
    end
    if SequenceNumber == 1 then
        --print("===============STARTING SEQUENCE 1=================")
        if not gBaddie.dead or not gBaddie02.dead then
            PedAttack(gBaddie.id, gBaddie02.id, 1)
        elseif not gBaddie.dead then
            PedAttack(gBaddie.id, gPlayer, 1)
        end
        if not gBaddie02.dead then
            PedFollowPath(gBaddie02.id, PATH._BMX_PATHY01, 1, 1)
        end
        if not gBaddie03.dead or not gBaddie04.dead then
            PedAttack(gBaddie03.id, gBaddie04.id, 1)
        elseif not gBaddie03.dead then
            PedAttack(gBaddie03.id, gPlayer, 1)
        end
        if not gBaddie04.dead then
            PedFollowPath(gBaddie04.id, PATH._BMX_PATHY02, 1, 1)
        end
        if not gBaddie03.dead or not gBaddie04.dead then
            PedAttack(gBaddie05.id, gBaddie06.id, 1)
        elseif not gBaddie05.dead then
            PedAttack(gBaddie05.id, gPlayer, 1)
        end
        if not gBaddie06.dead then
            PedFollowPath(gBaddie06.id, PATH._BMX_PATHY04, 1, 1)
        end
        gChooseSequence = 2
        Wait(25000)
        --print("===============ENDING SEQUENCE 1=================")
    elseif SequenceNumber == 2 then
        --print("===============STARTING SEQUENCE 2=================")
        if not gBaddie02.dead or not gBaddie03.dead then
            PedAttack(gBaddie02.id, gBaddie03.id, 1)
        elseif not gBaddie02.dead then
            PedAttack(gBaddie02.id, gPlayer, 1)
        end
        if not gBaddie03.dead then
            PedFollowPath(gBaddie03.id, PATH._BMX_PATHY01, 1, 1)
        end
        if not gBaddie04.dead or not gBaddie05.dead then
            PedAttack(gBaddie04.id, gBaddie05.id, 1)
        elseif not gBaddie04.dead then
            PedAttack(gBaddie04.id, gPlayer, 1)
        end
        if not gBaddie05.dead then
            PedFollowPath(gBaddie05.id, PATH._BMX_PATHY02, 1, 1)
        end
        if not gBaddie06.dead or not gBaddie.dead then
            PedAttack(gBaddie06.id, gBaddie.id, 1)
        elseif not gBaddie06.dead then
            PedAttack(gBaddie06.id, gPlayer, 1)
        end
        if not gBaddie.dead then
            PedFollowPath(gBaddie.id, PATH._BMX_PATHY03, 1, 1)
        end
        gChooseSequence = 3
        Wait(25000)
        --print("===============ENDING SEQUENCE 2=================")
    elseif SequenceNumber == 3 then
        --print("===============STARTING SEQUENCE 3=================")
        if not gBaddie02.dead or not gBaddie04.dead then
            PedAttack(gBaddie02.id, gBaddie04.id, 1)
        elseif not gBaddie02.dead then
            PedAttack(gBaddie02.id, gPlayer, 1)
        end
        if not gBaddie04.dead then
            PedFollowPath(gBaddie04.id, PATH._BMX_PATHY01, 1, 1)
        end
        if not gBaddie06.dead or not gBaddie05.dead then
            PedAttack(gBaddie06.id, gBaddie05.id, 1)
        elseif not gBaddie06.dead then
            PedAttack(gBaddie06.id, gPlayer, 1)
        end
        if not gBaddie06.dead then
            PedFollowPath(gBaddie06.id, PATH._BMX_PATHY02, 1, 1)
        end
        if not gBaddie.dead or not gBaddie03.dead then
            PedAttack(gBaddie.id, gBaddie03.id, 1)
        elseif not gBaddie.dead then
            PedAttack(gBaddie.id, gPlayer, 1)
        end
        if not gBaddie03.dead then
            PedFollowPath(gBaddie03.id, PATH._BMX_PATHY04, 1, 1)
        end
        gChooseSequence = 1
        Wait(25000)
        --print("===============ENDING SEQUENCE 3=================")
    end
end
