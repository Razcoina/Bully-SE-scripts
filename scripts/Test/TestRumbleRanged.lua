local missionStage
local missionCondition = "running"
local gRangedPedTableLocations = {}
local gMeleePedTableLocations = {}
local gFightingPeds = false
local gRangedPeds = true

function MissionSetup()
    DATLoad("TestRumbleRanged.DAT", 2)
    DATInit()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    VehicleOverrideAmbient(0, 0, 0, 0)
    ClockSet(22, 0)
    LoadPedModels({
        24,
        27,
        29
    })
    AreaTransitionPoint(0, POINTLIST._ROOFTESTPLAYERSTART)
    gRangedPedTableLocations = {
        {
            ped = nil,
            point = POINTLIST._ROOFTEST1,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST2,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST3,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST4,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST5,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST6,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST7,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST8,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST9,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST10,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST11,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._ROOFTEST12,
            bAlive = true
        }
    }
    gMeleePedTableLocations = {
        {
            ped = nil,
            point = POINTLIST._MELEEGUY1,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._MELEEGUY2,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._MELEEGUY3,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._MELEEGUY4,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._MELEEGUY5,
            bAlive = true
        },
        {
            ped = nil,
            point = POINTLIST._MELEEGUY6,
            bAlive = true
        }
    }
end

function MissionCleanup()
    DATUnload(2)
end

function F_Stage1Loop()
    local missionOver = true
    if gRangedPeds then
        for i, entity in gRangedPedTableLocations do
            if entity.bAlive then
                missionOver = false
                if entity.ped and PedIsValid(entity.ped) and (PedIsDead(entity.ped) or PedGetHealth(entity.ped) <= 0) then
                    entity.bAlive = false
                end
            end
            Wait(50)
        end
    end
    if gRangedPeds then
        for i, entity in gMeleePedTableLocations do
            if entity.bAlive then
                missionOver = false
                if entity.ped and PedIsValid(entity.ped) and (PedIsDead(entity.ped) or PedGetHealth(entity.ped) <= 0) then
                    entity.bAlive = false
                end
            end
            Wait(50)
        end
    end
    if missionOver then
        missionCondition = "passed"
    end
end

function F_Stage1Setup()
    local ped
    if gRangedPeds then
        for i, entity in gRangedPedTableLocations do
            ped = PedCreatePoint(RandomTableElement({
                24,
                27,
                29
            }), entity.point)
            PedSetEffectedByGravity(ped, false)
            PedSetStationary(ped, true)
            PedSetWeapon(ped, 312, 100)
            PedLockTarget(ped, gPlayer, 3)
            PedRooftopAttacker(ped)
            PedSetCheap(ped, true)
            PedSetUsesCollisionScripted(ped, true)
            PedSetActionTree(ped, "/Global/RooftopAttacker", "Act/Anim/RooftopAttacker.act")
            PedOverrideStat(ped, 3, 300)
            PedOverrideStat(ped, 11, 100)
            entity.ped = ped
            Wait(1)
        end
    end
    if gFightingPeds then
        for i, entity in gMeleePedTableLocations do
            ped = PedCreatePoint(RandomTableElement({
                24,
                27,
                29
            }), entity.point)
            PedLockTarget(ped, gPlayer, 3)
            PedAttack(ped, gPlayer, 3)
        end
    end
    missionStage = F_Stage1Loop
end

function main()
    missionStage = F_Stage1Setup
    while missionCondition == "running" do
        missionStage()
        Wait(0)
    end
    if missionCondition == "failed" then
        TextPrint("M_FAIL", 3, 1)
        Wait(1000)
        MissionFail()
    elseif missionCondition == "passed" then
        TextPrint("M_PASS", 3, 1)
        Wait(1000)
        MissionSucceed()
    end
end
