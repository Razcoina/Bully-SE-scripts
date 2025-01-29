local gNoOfREnemies = 3
local gNoOfSEnemies = 1
local gNoOfTEnemies = 1
local gTimeForCharge = 45000
local gTimeForRespawn = 5000
local gMissionTime = 300
local gDumpster01 = -1
local gRPaths = {}
local gSPaths = {}
local gTPaths = {}

function F_LoadPaths()
    gRPaths = {
        {
            path = PATH._3_S09_R01PATH,
            spawn = POINTLIST._3_S09_R01SPAWN,
            cover = POINTLIST._3_S09_R01COVER
        },
        {
            path = PATH._3_S09_R02PATH,
            spawn = POINTLIST._3_S09_R02SPAWN,
            cover = POINTLIST._3_S09_R02COVER
        },
        {
            path = PATH._3_S09_R03PATH,
            spawn = POINTLIST._3_S09_R03SPAWN,
            cover = POINTLIST._3_S09_R03COVER
        },
        {
            path = PATH._3_S09_R04PATH,
            spawn = POINTLIST._3_S09_R04SPAWN,
            cover = POINTLIST._3_S09_R04COVER
        }
    }
    gSPaths = {
        {
            path = PATH._3_S09_S01PATH,
            spawn = POINTLIST._3_S09_S01SPAWN
        },
        {
            path = PATH._3_S09_S02PATH,
            spawn = POINTLIST._3_S09_S02SPAWN
        }
    }
    gTPaths = {
        {
            path = PATH._3_S09_T01PATH,
            spawn = POINTLIST._3_S09_T01SPAWN
        },
        {
            path = PATH._3_S09_T02PATH,
            spawn = POINTLIST._3_S09_T02SPAWN
        }
    }
end

local mission_running = true
local fattyBoy = -1
local gSCharacter = -1
local enemies = {}
local stage = -1
local runningGreaser = -1
local currentR, currentS, currentT = 0, 0, 0
local gCurrentRespawnTime = 0
local gCurrentChargeTime = 0
local gEnemyDied = false
local gCreateChargingEnemy = false
local gAttackingDumpster = true
local threadCount = 0

function FattyLiving()
    while mission_running do
        if PedGetHealth(gSCharacter) <= 0 then
            F_CreateSEnemy()
        end
        Wait(0)
    end
end

function MissionSetup()
    DisablePOI()
    --print(" MISSION SETUP LOADED")
    DATLoad("RaulTest.DAT", 2)
    DATInit()
    CameraFade(1000, 0)
    Wait(1000)
    F_LoadPaths()
    setX, setY, setZ = GetPointList(POINTLIST._3_S09_RAULTEST_PLAYERSTART)
    AreaTransitionXYZ(0, setX, setY, setZ)
    Wait(1500)
end

function MissionCleanup()
    DATUnload(2)
    EnablePOI()
end

function main()
    ClockSet(21, 30)
    PedSetWeapon(gPlayer, 306, 100)
    CameraFade(1000, 1)
    Wait(1000)
    gDumpster01 = PAnimCreate(TRIGGER._3_S09_DUMPSTER01)
    PAnimCreate(TRIGGER._3_S09_COVER01)
    PAnimCreate(TRIGGER._3_S09_COVER02)
    PAnimCreate(TRIGGER._3_S09_COVER03)
    VehicleCreatePoint(295, POINTLIST._3_S09_CAR01)
    VehicleCreatePoint(295, POINTLIST._3_S09_CAR02)
    VehicleCreatePoint(295, POINTLIST._3_S09_CAR03)
    iGreaser01 = PedCreatePoint(24, POINTLIST._3_S09_INITIALGREASERS, 1)
    iGreaser02 = PedCreatePoint(27, POINTLIST._3_S09_INITIALGREASERS, 2)
    iGreaser03 = PedCreatePoint(28, POINTLIST._3_S09_INITIALGREASERS, 3)
    Wait(0)
    PedAttackProp(iGreaser01, TRIGGER._3_S09_DUMPSTER01)
    Wait(0)
    PedAttackProp(iGreaser02, TRIGGER._3_S09_DUMPSTER01)
    Wait(0)
    PedSetCheering(iGreaser03, true)
    Wait(0)
    stage = StageOneSetup
    F_InitThread("TextQueueThread")
    while mission_running do
        stage()
        Wait(0)
    end
    MissionSucceed()
end

function F_RPath(pedId, pathId, pathNode)
    if pathNode == 3 then
        PedSetWeapon(pedId, 303, 100)
        for i, pTable in enemies do
            if pTable.pedId == pedId then
                PedCoverSet(pedId, gPlayer, pTable.coverId, 1, 40, 1, 1, 2, 2, 2, 1, 1, 1, 1, false)
            end
        end
    end
end

function F_SPath(pedId, pathId, pathNode)
    if pathNode == 3 then
        F_MakeEnemiesCheer()
    elseif pathNode == 4 then
        PedAttackPlayer(pedId)
    end
end

function F_TPath(pedId, pathId, pathNode)
    if pathNode == 3 then
        PedSetWeapon(pedId, 311, 100)
        PedAttackPlayer(pedId)
    end
end

function F_TerminateThread(threadName)
    threadCount = threadCount - 1
    --print(threadCount, " <<<<<<<<<<<< THREADS REMAINING - ", threadName, " FINISHED ITS TASKS ")
end

function F_InitThread(threadName)
    threadCount = threadCount + 1
    CreateThread(threadName)
    --print(threadCount, " <<<<<<<<<<<<< THREADS CREATED ", threadName)
end

function F_WaitForNextStage()
end

function StageOneSetup()
    F_InitThread("CheckForHit")
    stage = StageOne
end

function StageOne()
    if PedIsDead(iGreaser01) then
        F_GreaserRun(iGreaser02, iGreaser03)
    elseif PedIsDead(iGreaser02) then
        F_GreaserRun(iGreaser01, iGreaser03)
    elseif PedIsDead(iGreaser03) then
        F_GreaserRun(iGreaser02, iGreaser01)
    end
    if PlayerIsInTrigger(TRIGGER._3_S09_LEAVINGTRIGGER) and not gAttackingDumpster then
        gAttackingDumpster = true
        F_GreasersReturnToDumpster()
        F_InitThread("CheckForHit02")
    end
end

function F_GreasersReturnToDumpster()
    local x, y, z = GetAnchorPosition(TRIGGER._3_S09_DUMPSTER01)
    if not PedIsDead(iGreaser01) then
        PedStop(iGreaser01)
        Wait(100)
        PedMoveToXYZ(iGreaser01, 2, x, y)
    end
    if not PedIsDead(iGreaser02) then
        PedStop(iGreaser02)
        Wait(100)
        PedMoveToXYZ(iGreaser02, 2, x, y)
    end
    if not PedIsDead(iGreaser03) then
        PedStop(iGreaser03)
        Wait(100)
        PedMoveToXYZ(iGreaser03, 2, x, y)
    end
    F_InitThread("CheckIfCloseToDumpster")
end

function F_GreaserRun(aliveGreaser01, aliveGreaser02)
    --print(" GREASER CHECK ", PedIsDead(aliveGreaser01), PedIsDead(aliveGreaser02))
    if not PedIsDead(aliveGreaser01) and not PedIsDead(aliveGreaser02) then
        --print(" GREASER START RUNNING ")
        PedStop(aliveGreaser01)
        PedMoveToPoint(aliveGreaser01, 2, POINTLIST._3_S09_HELP)
        PedIgnoreAttacks(aliveGreaser01, true)
        TextQueue("3_S09_08", 4000, 2)
        runningGreaser = aliveGreaser01
        stage = F_WaitForNextStage
        F_InitThread("CheckForReinforcements")
    end
end

function CheckForReinforcements()
    local bGreaserRunning = true
    local runningTime = GetTimer()
    while bGreaserRunning do
        Wait(0)
        local x, y, z = GetPointList(POINTLIST._3_S09_HELP)
        if PedIsInAreaXYZ(runningGreaser, x, y, z, 2, 0) or GetTimer() - runningTime > 10000 then
            TextQueue("3_S09_07", 4000, 2)
            bGreaserRunning = false
            PedIgnoreAttacks(runningGreaser, false)
            PedAttackPlayer(runningGreaser)
        end
    end
    stage = StageTwoSetup
    F_TerminateThread("CheckForReinforcements")
end

function CheckIfCloseToDumpster()
    local g01, g02, g03 = true, true, true
    while g01 and g02 and g03 do
        if g01 and iGreaser01 and PedIsInAreaObject(iGreaser01, TRIGGER._3_S09_DUMPSTER01, 0, 5, 0) then
            g01 = false
            PedAttackProp(iGreaser01, TRIGGER._3_S09_DUMPSTER01)
        end
        if g02 and iGreaser02 and PedIsInAreaObject(iGreaser02, TRIGGER._3_S09_DUMPSTER01, 0, 5, 0) then
            g02 = false
            PedAttackProp(iGreaser02, TRIGGER._3_S09_DUMPSTER01)
        end
        if g03 and iGreaser03 and PedIsInAreaObject(iGreaser03, TRIGGER._3_S09_DUMPSTER01, 0, 5, 0) then
            g03 = false
            PedAttackProp(iGreaser03, TRIGGER._3_S09_DUMPSTER01)
        end
        Wait(0)
    end
    F_TerminateThread("CheckIfCloseToDumpster")
end

function CheckForHit02()
    Wait(2000)
    local greaserNotHit = true
    while greaserNotHit do
        Wait(0)
        if iGreaser01 and PedIsHit(iGreaser01, 2, 1000) then
            greaserNotHit = false
        end
        if iGreaser02 and PedIsHit(iGreaser02, 2, 1000) then
            greaserNotHit = false
        end
        if iGreaser03 and PedIsHit(iGreaser03, 2, 1000) then
            greaserNotHit = false
        end
    end
    gAttackingDumpster = false
    if iGreaser01 then
        PedAttackPlayer(iGreaser01)
    end
    if iGreaser02 then
        PedAttackPlayer(iGreaser02)
    end
    if iGreaser03 then
        PedAttackPlayer(iGreaser03)
    end
    F_TerminateThread("CheckForHit02")
end

function CheckForHit()
    local greaserNotHit = true
    while greaserNotHit do
        Wait(0)
        if iGreaser01 and PedIsHit(iGreaser01, 2, 1000) then
            greaserNotHit = false
        end
        if iGreaser02 and PedIsHit(iGreaser02, 2, 1000) then
            greaserNotHit = false
        end
        if iGreaser03 and PedIsHit(iGreaser03, 2, 1000) then
            greaserNotHit = false
        end
    end
    gAttackingDumpster = false
    TextQueue("3_S09_04", 2000, 2)
    TextQueue("3_S09_05", 3000, 2)
    TextQueue("3_S09_06", 4000, 2)
    PedStop(iGreaser01)
    PedStop(iGreaser02)
    PedSetCheering(iGreaser03, false)
    PedAttackPlayer(iGreaser01)
    PedAttackPlayer(iGreaser02)
    PedAttackPlayer(iGreaser03)
    F_TerminateThread("CheckForHit")
end

function TextQueueThread()
    while mission_running do
        CheckTextQueue()
        Wait(0)
    end
    F_TerminateThread("TextQueueThread")
end

function StageTwoSetup()
    local waiting = true
    while waiting do
        Wait(0)
        if PedIsDead(iGreaser01) and PedIsDead(iGreaser02) and PedIsDead(iGreaser03) then
            waiting = false
        end
    end
    TextQueue(-1, 3000, 2)
    TextQueue("3_S09_09", 3000, 2)
    TextQueue("3_S09_10", 4000, 2)
    local spawning = true
    while spawning do
        if currentR < gNoOfREnemies then
            F_CreateEnemy("R")
        else
            spawning = false
        end
    end
    MissionTimerStart(gMissionTime)
    gCurrentChargeTime = GetTimer()
    gCreateChargingEnemy = true
    stage = StageTwo
end

function StageTwo()
    F_CheckForDeath()
    if currentS <= 0 and gEnemyDied and GetTimer() - gCurrentRespawnTime >= gTimeForRespawn then
        gEnemyDied = false
        if currentR < gNoOfREnemies then
            F_CreateEnemy("R")
        end
        if currentT < gNoOfTEnemies then
            F_CreateEnemy("T")
        end
    end
    if gCreateChargingEnemy and GetTimer() - gCurrentChargeTime >= gTimeForCharge then
        if currentS < gNoOfSEnemies then
            F_CreateEnemy("S")
        end
        gCreateChargingEnemy = false
    end
    if MissionTimerHasFinished() then
        mission_running = false
        MissionTimerStop()
    end
end

function F_MakeEnemiesCheer()
    --print(" MAKE HIM CHEER ", table.getn(enemies))
    for i, pTable in enemies do
        --print("IN FOR", pTable.enemyType)
        if pTable.enemyType ~= "S" then
            --print("IN IF")
            PedStop(pTable.pedId)
            PedSetCheering(pTable.pedId, true)
        end
    end
end

function F_StopEnemiesCheering()
    --print(" MAKE HIM STOP CHEER ", table.getn(enemies))
    for i, pTable in enemies do
        --print("IN FOR", pTable.enemyType)
        if pTable.enemyType ~= "S" then
            --print("IN IF")
            PedSetCheering(pTable.pedId, false)
            if pTable.enemyType == "R" then
                F_RPath(pTable.pedId, 1, 3)
            else
                F_TPath(pTable.pedId, 1, 4)
            end
        end
    end
end

function F_RestorePaths(eType, pathId, spawnId, coverId)
    --print("<<<<<<<<<<<<<<<<<< RESTORING", eType, pathId, spawnId, coverId)
    if eType == "R" then
        table.insert(gRPaths, {
            path = pathId,
            spawn = spawnId,
            cover = coverId
        })
        currentR = currentR - 1
    elseif eType == "S" then
        table.insert(gSPaths, { path = pathId, spawn = spawnId })
        F_StopEnemiesCheering()
        currentS = currentS - 1
        gCurrentChargeTime = GetTimer()
        gCreateChargingEnemy = true
    else
        table.insert(gTPaths, { path = pathId, spawn = spawnId })
        currentT = currentT - 1
    end
    --print("<<<<<<<<<<<<<<< FINISHED RESTORING ")
end

function F_CheckForDeath()
    local indexesToRemove = {}
    for i, pTable in enemies do
        if PedIsDead(pTable.pedId) then
            if pTable.enemyType == "S" then
                PickupCreateFromPed(502, pTable.pedId)
            end
            F_RestorePaths(pTable.enemyType, pTable.pathId, pTable.spawnId, pTable.coverId)
            table.insert(indexesToRemove, 1, i)
            gCurrentRespawnTime = GetTimer()
            gEnemyDied = true
        end
    end
    for i, index in indexesToRemove do
        table.remove(enemies, index)
    end
    indexesToRemove = nil
end

function F_CreateEnemy(eType)
    --print(" >>>>>>>>>>>>>>>>>>>>> CREATING AN ENEMY", eType)
    local callbackFunction = -1
    local randNo = 0
    local nPedType = PedGetRandomModelId(4, 1, 1)
    local nSpawnSpeed = 1
    local nCover
    if eType == "R" then
        callbackFunction = F_RPath
        randNo = math.random(1, table.getn(gRPaths))
        --print(">S>S>S>S> GETTING THE RANDOM NO FROM", table.getn(gRPaths))
        nPath = gRPaths[randNo].path
        nSpawn = gRPaths[randNo].spawn
        nCover = gRPaths[randNo].cover
        table.remove(gRPaths, randNo)
        currentR = currentR + 1
    elseif eType == "S" then
        callbackFunction = F_SPath
        randNo = math.random(1, table.getn(gSPaths))
        nPath = gSPaths[randNo].path
        nSpawn = gSPaths[randNo].spawn
        nPedType = PedGetRandomModelId(4, 1, 2)
        table.remove(gSPaths, randNo)
        currentS = currentS + 1
    else
        callbackFunction = F_TPath
        randNo = math.random(1, table.getn(gTPaths))
        nPath = gTPaths[randNo].path
        nSpawn = gTPaths[randNo].spawn
        table.remove(gTPaths, randNo)
        currentT = currentT + 1
    end
    local nEnemy = PedCreatePoint(nPedType, nSpawn, 1)
    --print(" >>>>>>>>>>>>>>>>>>>>> AFTER CREATING THE PED")
    --print(" >>>>>>>>>>>>>>>>>>>>> ", randNo, nEnemy, eType, nPath, nSpawn, nSpawnSpeed, callbackFunction)
    PedFollowPath(nEnemy, nPath, 0, nSpawnSpeed, callbackFunction)
    table.insert(enemies, {
        pedId = nEnemy,
        enemyType = eType,
        currentStatus = "PEDRUNNING",
        pathId = nPath,
        spawnId = nSpawn,
        coverId = nCover
    })
    Wait(1000)
end

function F_OpeningCutscene()
    Wait(10)
    teacher = PedCreatePoint(55, POINTLIST._3_S09_TEACHERSTART)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    CameraLookAtObject(gPlayer, 3, true)
    CameraSetPath(PATH._3_S09_CAM1, true)
    Wait(0)
    PedFaceObject(gPlayer, teacher, 2, 1)
    TextPrint("3_S09_C01", 3, 2)
    Wait(3100)
    CameraLookAtObject(teacher, 2, false)
    TextPrint("3_S09_C02", 2, 2)
    Wait(2000)
    local girlfriend = PedCreatePoint(62, POINTLIST._3_S09_GIRLFRIEND)
    local x, y, z = GetPointList(POINTLIST._3_S09_DOOR)
    PedMoveToXYZ(girlfriend, 0, x, y)
    Wait(250)
    CameraSetPath(PATH._3_S09_CAM2, true)
    CameraLookAtObject(girlfriend, 2, true)
    CameraSetSpeed(1.5, 2, 2)
    Wait(2500)
    CameraSetPath(PATH._3_S09_CAM1, true)
    while not PedIsInAreaXYZ(girlfriend, x, y, z, 0.5, 0) do
        Wait(100)
    end
    CameraLookAtObject(teacher, 2, true)
    Wait(100)
    TextPrint("3_S09_C03", 1, 2)
    Wait(100)
    PedDelete(girlfriend)
    Wait(750)
    PedFaceHeading(teacher, 90, 1)
    TextPrint("3_S09_C04", 1, 2)
    Wait(3000)
    PedFaceObject(teacher, gPlayer, 2, 1)
    Wait(100)
    TextPrint("3_S09_C05", 4, 2)
    Wait(4100)
    CameraLookAtObject(gPlayer, 2, false)
    TextPrint("3_S09_C06", 2, 2)
    Wait(2100)
    CameraSetWidescreen(true)
    CameraSetPath(PATH._3_S09_CAM1, true)
    CameraLookAtObject(teacher, 2, false)
    TextPrint("3_S09_C07", 5, 2)
    Wait(5100)
    PedMoveToXYZ(teacher, 1, x, y)
    while not PedIsInAreaXYZ(teacher, x, y, z, 0.5, 0) do
        Wait(0)
    end
    Wait(100)
    CameraLookAtObject(gPlayer, 2, false)
    PedDelete(teacher)
    local manager = PedCreatePoint(76, POINTLIST._3_S09_MANAGER)
    local x, y, z = GetPointList(POINTLIST._3_S09_TEACHERSTART)
    PedMoveToXYZ(manager, 1, x, y)
    CameraLookAtObject(manager, 2, false)
    while not PedIsInAreaXYZ(manager, x, y, z, 0.5, 0) do
        Wait(0)
    end
    PedFaceObject(manager, gPlayer, 2, 1)
    TextPrint("3_S09_C08", 3, 2)
    Wait(3100)
    CameraLookAtObject(gPlayer, 2, false)
    TextPrint("3_S09_C09", 4, 2)
    Wait(4100)
    TextPrint("3_S09_C10", 3, 2)
    Wait(1500)
    PedAttackProp(iGreaser01, TRIGGER._3_S09_DUMPSTER01)
    Wait(0)
    PedAttackProp(iGreaser02, TRIGGER._3_S09_DUMPSTER01)
    Wait(0)
    PedSetCheering(iGreaser03, true)
    Wait(0)
    CameraLookAtObject(iGreaser01, 2, false)
    Wait(3100)
    TextPrint("3_S09_C11", 4, 2)
    Wait(4100)
    CameraLookAtObject(gPlayer, 2, false)
    TextPrint("3_S09_C12", 4, 2)
    Wait(4100)
    PedFaceObject(gPlayer, manager, 2, 1)
    TextPrint("3_S09_C13", 3, 2)
    Wait(3100)
    CameraLookAtObject(manager, 2, false)
    TextPrint("3_S09_C14", 3, 2)
    Wait(3100)
    CameraLookAtObject(gPlayer, 2, false)
    TextPrint("3_S09_C15", 3, 2)
    Wait(3100)
    local x, y, z = GetPointList(POINTLIST._3_S09_MANAGER)
    PedMoveToXYZ(manager, 1, x, y)
    while not PedIsInAreaXYZ(manager, x, y, z, 0.5, 0) do
        Wait(0)
    end
    PedDelete(manager)
    Wait(0)
    PlayerFaceHeading(270, 1)
    Wait(1000)
    CameraReturnToPlayer()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    Wait(2000)
end

local gTextQueue = {}
local gTextQueueTimer = 0
local gTextWaitTimer = 0
local gStartPrinting = false

function TextQueue(val, tTime, style, isText, priority)
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
            tStyle = style
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
                    TextPrintString(gTextQueue[1].textVal, gTextQueue[1].textTime / 1000, gTextQueue[1].tStyle)
                else
                    TextPrint(gTextQueue[1].textVal, gTextQueue[1].textTime / 1000, gTextQueue[1].tStyle)
                end
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
