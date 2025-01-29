local defaultCarGroup = "_DCr"
local carTypeName = "_Car"
local carDefault = {
    spawnLocation = nil,
    model = MODELENUM._PEUGEOT,
    actionRadius = 50,
    speed = 30,
    ped = gPlayer,
    OnEnterRadius = nil,
    OnLeaveRadius = nil,
    OnInsideRadius = nil,
    OnStopWaiting = nil,
    bSingleAction = false,
    bInRadius = false,
    bLeftRadius = false,
    bWaiting = false,
    bMovingToPoint = false,
    bDestinationReached = false,
    timeToWait = 1500
}

function L_CarValidate(car)
    --assert(car.spawnLocation ~= nil, "LibVehicle Error: tried to load a vehicle without specifying a spawn location")
    car.spawnLocation = car.spawnLocation or carDefault.spawnLocation
    car.model = car.model or carDefault.model
    car.actionRadius = car.actionRadius or carDefault.actionRadius
    car.speed = car.speed or carDefault.speed
    car.ped = car.ped or carDefault.ped
    car.OnEnterRadius = car.OnEnterRadius or carDefault.OnEnterRadius
    car.OnLeaveRadius = car.OnLeaveRadius or carDefault.OnLeaveRadius
    car.OnInsideRadius = car.OnInsideRadius or carDefault.OnInsideRadius
    car.OnReachDestination = car.OnReachDestination or carDefault.OnReachDestination
    car.OnStopWaiting = car.OnStopWaiting or carDefault.OnStopWaiting
    car.bSingleAction = car.bSingleAction or carDefault.bSingleAction
    car.bInRadius = car.bInRadius or carDefault.bInRadius
    car.bLeftRadius = car.bLeftRadius or carDefault.bLeftRadius
    car.bWaiting = car.bWaiting or carDefault.bWaiting
    car.bMovingToPoint = car.bMovingToPoint or carDefault.bMovingToPoint
    car.bDestinationReached = car.bDestinationReached or carDefault.bDestinationReached
    car.timeToWait = car.timeToWait or carDefault.timeToWait
end

function L_CarLoad(tblCarParam)
    for i, car in tblCarParam do
        L_CarValidate(car)
    end
    LT_Add(defaultCarGroup, tblCarParam, carTypeName)
    LT_GroupObjectCreate(defaultCarGroup, VehicleCreatePoint, "model", "spawnLocation")
    LT_GroupFunction(defaultCarGroup, VehicleSetCruiseSpeed, "id", "speed")
end

function L_CarLoadGroup(tblCarParam, groupNameParam)
    local errorFuncName = "L_CarLoadGroup"
    local groupName = ValidateGroup(groupNameParam, defaultCarGroup, carTypeName)
    for i, car in tblCarParam do
        L_CarValidate(car)
    end
    LT_Add(groupName, tblCarParam, carTypeName)
    LT_GroupObjectCreate(groupName, VehicleCreatePoint, "model", "spawnLocation")
    LT_GroupFunction(groupName, VehicleSetCruiseSpeed, "id", "speed")
end

function T_CarMonitor()
    while not L_ObjectiveProcessingDone() do
        Wait(0)
    end
    collectgarbage()
end

function F_CarMonitor()
    for i, group in LT_LibTable() do
        if LT_Type(i) == carTypeName then
            for j, car in group do
                if not (not (car.id and car.ped) or car.bLeftRadius) or car.bLeftRadius and not car.bSingleAction then
                    local pedinarea = PedIsInAreaObject(car.ped, car.id, 1, car.actionRadius, 0)
                    if not car.bInRadius and pedinarea then
                        car.bInRadius = true
                        if car.OnEnterRadius ~= nil then
                            car.OnEnterRadius(car)
                        end
                    elseif pedinarea then
                        if car.OnInsideRadius ~= nil then
                            car.OnInsideRadius(car)
                        end
                    else
                        car.bInRadius = false
                        car.bLeftRadius = true
                        if car.OnLeaveRadius ~= nil then
                            car.OnLeaveRadius(car)
                        end
                    end
                end
                if car.id then
                    if car.OnReachDestination and not car.bDestinationReached and car.bMovingToPoint then
                        local x, y, z
                        if car.x and car.y and car.z then
                            x = car.x
                            y = car.y
                            z = car.z
                        elseif car.point then
                            x, y, z = GetPointList(car.point)
                        else
                            error("LibCar unable to run OnReachDestination() (car.point and car.{x,y,z} were invalid)")
                        end
                        if VehicleIsInAreaXYZ(car.id, x, y, z, 3, 0) then
                            car.bMovingtoPoint = false
                            car.bDestinationReached = true
                            car.OnReachDestination(car)
                        end
                    end
                    if car.OnStopWaiting and car.bWaiting then
                        local currentTime = GetTimer()
                        if currentTime - car.startWait >= car.timeToWait then
                            car.bWaiting = false
                            car.OnStopWaiting(car)
                        end
                    end
                end
            end
        end
    end
end

function L_CarMakeAmbient(car)
    if car.id ~= nil then
        VehicleMakeAmbient(car.id)
        car.id = nil
    end
end

function L_CarMovePoint(car)
    --assert(car.point ~= nil, "ERROR - L_CarMovePoint: No point specified")
    local x, y, z = GetPointList(car.point)
    VehicleMoveToXYZ(car.id, x, y, z)
    car.bMovingToPoint = true
end

function L_CarFollowPath(car)
    --assert(car.path ~= nil, "ERROR - L_CarFollowPath: No path specified")
    VehicleFollowPath(car.id, car.path)
end

function L_CarMoveXYZ(car)
    --assert(car.x and car.y and car.z, "ERROR - L_CarMoveXYZ: Missing at least one coordinate")
    VehicleMoveToXYZ(car.id, car.x, car.y, car.z)
    car.bMovingToPoint = true
end

function L_CarWait(car)
    car.startWait = GetTimer()
    car.bWaiting = true
end
