local playerDefault = {
    startPosition = nil,
    startOnBike = false,
    bike = { model = 273, location = nil },
    weapon = { model = nil, ammo = 0 },
    currentTarget = nil,
    clothing = {
        outfit_HashId = nil,
        head_model = 0,
        head_txd = 0,
        left_wrist_model = 0,
        left_wrist_txd = 0,
        right_wrist_model = 0,
        right_wrist_txd = 0,
        torso_model = 0,
        torso_txd = 0,
        legs_model = 0,
        legs_txd = 0,
        feet_model = 0,
        feet_txd = 0
    }
}
local player = playerDefault

function L_PlayerClothingBackup()
    ClothingBackup()
end

function L_PlayerClothingRestore()
    ClothingRestore()
    ClothingBuildPlayer()
end

function L_PlayerSetParam(playerParam)
    --assert(playerParam.startPosition ~= nil, "ERROR - LibPlayer: tried to load player with no startPosition")
    player = playerParam
    player.startOnBike = player.startOnBike or playerDefault.startOnBike
    if player.bike ~= nil then
        --assert(player.bike.location ~= nil, "ERROR - LibPlayer: tried to spawn a bike without specifying start location")
        player.bike.model = player.bike.model or playerDefault.bike.model
    end
    if player.weapon ~= nil then
        --assert(player.weapon.model ~= nil, "ERROR - LibPlayer: tried to give player weapon without specifying model")
        player.weapon.model = player.weapon.model or playerDefault.weapon.model
        player.weapon.ammo = player.weapon.ammo or playerDefault.weapon.ammo
    end
end

function L_PlayerLoad(playerParam)
    L_PlayerSetParam(playerParam)
    if player.weapon ~= nil then
        if not PlayerHasWeapon(player.weapon.model) then
            GiveItemToPlayer(player.weapon.model)
        end
        PedSetWeaponNow(gPlayer, player.weapon.model, 0)
        ItemSetCurrentNum(player.weapon.model, player.weapon.ammo)
    end
    local transitionArea = player.visibleArea
    local startPosition = player.startPosition
    if transitionArea ~= nil and transitionArea ~= AreaGetVisible() then
        AreaTransitionPoint(transitionArea, startPosition, 0, true)
    else
        ManagedPlayerSetPosPoint(startPosition)
    end
    local px, py, pz = GetPointList(player.startPosition)
    local tblAreaBikes = VehicleFindInAreaXYZ(px, py, pz, 15, true)
    local lastBike = PedGetLastVehicle(gPlayer)
    if tblAreaBikes then
        for i, bikeID in tblAreaBikes do
            if bikeID ~= lastBike then
                VehicleDelete(bikeID)
            else
                PlayerDetachFromVehicle()
            end
        end
    end
    if player.bike ~= nil then
        if player.bike.id == nil then
            L_PlayerLoadVehicle(player)
        end
        if player.startOnBike then
            PlayerPutOnBike(player.bike.id)
        end
    end
    PedStop(gPlayer)
end

function L_PlayerLoadVehicle(player)
    local px, py, pz = GetPointList(player.startPosition)
    local tblAreaBikes = VehicleFindInAreaXYZ(px, py, pz, 15, true)
    local lastBike = PedGetLastVehicle(gPlayer)
    AreaLoadCollision(px, py)
    while AreaIsLoading() do
        Wait(0)
    end
    local bikeInWay = F_PlayerClearBikeSpawnArea(player.bike.location, lastBike)
    local startOnBike = player.startOnBike
    if not bikeInWay then
        while not VehicleRequestModel(player.bike.model) do
            Wait(0)
        end
        local x, y, z, r1, r2, r2 = GetPointList(player.bike.location)
        player.bike.id = VehicleCreatePoint(player.bike.model, player.bike.location)
    else
        player.bike.id = lastBike
        if startOnBike then
            local x, y, z, r1, r2, r2 = GetPointList(player.bike.location)
            VehicleSetPosPoint(lastBike, player.bike.location)
        end
    end
end

function F_PlayerClearBikeSpawnArea(location, lastBike)
    local bx, by, bz = GetPointList(location)
    local bikeInWay = false
    local tblAreaBikes = VehicleFindInAreaXYZ(bx, by, bz, 3, true)
    if tblAreaBikes then
        for i, bikeID in tblAreaBikes do
            if bikeID ~= lastBike then
                VehicleDelete(bikeID)
            else
                bikeInWay = true
            end
        end
    end
    return bikeInWay
end

function L_PlayerCleanup()
    player = nil
    playerDefault = nil
    collectgarbage()
end

function L_PlayerSetCurrentTarget(element)
    player.currentTarget = element.id
end

function L_PlayerClearCurrentTarget()
    player.currentTarget = nil
end

function L_PlayerGetCurrentTarget()
    return player.currentTarget
end
