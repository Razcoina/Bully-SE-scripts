local defaultPickupGroup = "_DPkp"
local pickupTypeName = "_Pkp"
local pickupDefault = {
	model = nil,
	cleanup = false,
	butes = "",
	ped = nil,
	point = nil,
	spawnx = nil,
	spawnx = nil,
	spawnx = nil,
	x = nil,
	y = nil,
	z = nil,
	blipStyle = nil,
	radarIcon = nil,
	grabber = nil,
	lastPedToPickup = nil,
	noGrab = false,
	grabDelay = 5000,
	grabRadius = 1,
	timeSpawned = 0
}

function L_PickupAdd(tblPickupParam)
	for i, pickup in tblPickupParam do
		--assert(pickup.model ~= nil, "LibPickup Error: pickup " .. i .. " has no model")
		pickup.butes = pickup.butes or pickupDefault.butes
		pickup.ped = pickup.ped or pickupDefault.ped
		pickup.point = pickup.point or pickupDefault.point
		pickup.spawnx = pickup.spawnx or pickupDefault.spawnx
		pickup.spawny = pickup.spawny or pickupDefault.spawny
		pickup.spawnz = pickup.spawnz or pickupDefault.spawnz
		pickup.x = pickup.x or pickupDefault.x
		pickup.y = pickup.y or pickupDefault.y
		pickup.z = pickup.z or pickupDefault.z
		pickup.cleanup = pickup.cleanup or pickupDefault.cleanup
		pickup.blipStyle = pickup.blipStyle or pickupDefault.blipStyle
		pickup.grabber = pickup.grabber or pickupDefault.grabber
		pickup.lastPedToPickup = pickup.lastPedToPickup or pickupDefault.lastPedToPickup
		pickup.noGrab = pickup.noGrab or pickupDefault.noGrab
		pickup.grabDelay = pickup.grabDelay or pickupDefault.grabDelay
		pickup.grabRadius = pickup.grabRadius or pickupDefault.grabRadius
		pickup.timeSpawned = pickup.timeSpawned or pickupDefault.timeSpawned
		pickup.numInventory = {}
		local numInventory = ItemGetCurrentNum(pickup.model)
		pickup.initPlayerInventory = numInventory
		pickup.numInventory[gPlayer] = numInventory
	end
	LT_Add(defaultPickupGroup, tblPickupParam, pickupTypeName)
end

function L_PickupAddGroup(tblPickupParam, groupNameParam)
	local errorFuncName = "L_PickupAddGroup"
	local groupName = ValidateGroup(groupNameParam, defaultPickupGroup, pickupTypeName)
	for i, pickup in tblPickupParam do
		--assert(pickup.model ~= nil, "LibPickup Error: pickup " .. i .. " has no model")
		--assert(not pickup.ped and not pickup.point and pickup.x and pickup.y and pickup.z, "LibPickup Error: no spawning location was specified for pickup " .. tostring(i))
		pickup.butes = pickup.butes or pickupDefault.butes
		pickup.ped = pickup.ped or pickupDefault.ped
		pickup.point = pickup.point or pickupDefault.point
		pickup.spawnx = pickup.spawnx or pickupDefault.spawnx
		pickup.spawny = pickup.spawny or pickupDefault.spawny
		pickup.spawnz = pickup.spawnz or pickupDefault.spawnz
		pickup.x = pickup.x or pickupDefault.x
		pickup.y = pickup.y or pickupDefault.y
		pickup.z = pickup.z or pickupDefault.z
		pickup.cleanup = pickup.cleanup or pickupDefault.cleanup
		pickup.blipStyle = pickup.blipStyle or pickupDefault.blipStyle
		pickup.grabber = pickup.grabber or pickupDefault.grabber
		pickup.lastPedToPickup = pickup.lastPedToPickup or pickupDefault.lastPedToPickup
		pickup.noGrab = pickup.noGrab or pickupDefault.noGrab
		pickup.grabDelay = pickup.grabDelay or pickupDefault.grabDelay
		pickup.grabRadius = pickup.grabRadius or pickupDefault.grabRadius
		pickup.timeSpawned = pickup.timeSpawned or pickupDefault.timeSpawned
		pickup.numInventory = {}
		local numInventory = ItemGetCurrentNum(pickup.model)
		pickup.initPlayerInventory = numInventory
		pickup.numInventory[gPlayer] = numInventory
	end
	LT_Add(groupName, tblPickupParam, pickupTypeName)
end

function L_PickupCreateName(pickupName)
	LT_IndexFunction("_Pkp", pickupName, L_PickupCreateType, "element")
end

function L_PickupCreatePointByName(pickupName)
	LT_IndexFunction("_Pkp", pickupName, L_PickupCreatePoint, "element")
end

function L_PickupCreateXYZByName(pickupName)
	LT_IndexFunction("_Pkp", pickupName, L_PickupCreateXYZ, "element")
end

function L_PickupCreatePedByName(pickupName)
	LT_IndexFunction("_Pkp", pickupName, L_PickupCreatePed, "element")
end

function L_PickupCreate()
	LT_GroupFunction("_DPkp", L_PickupCreateType, "element")
end

function F_PickupProcessAttributes(pickup)
	if pickup.OnCreate then
		pickup.OnCreate(pickup)
	end
	local x, y, z = PickupGetXYZ(pickup.id)
	pickup.x = x
	pickup.y = y
	pickup.z = z
	L_HUDBlipAddPickup(pickup)
	pickup.timeSpawned = GetTimer()
end

function L_PickupCreatePoint(pickup)
	--assert(pickup.point ~= nil, "ERROR - L_PickupCreatePoint: No point specified")
	pickup.id = PickupCreatePoint(pickup.model, pickup.point, 0, 360, pickup.butes)
	F_PickupProcessAttributes(pickup)
end

function L_PickupCreateXYZ(pickup)
	--assert(pickup.spawnx and pickup.spawny and pickup.spawnz, "ERROR - L_PickupCreateXYZByName: Missing at least one coordinate")
	pickup.id = PickupCreateXYZ(pickup.model, pickup.spawnx, pickup.spawny, pickup.spawnz)
	F_PickupProcessAttributes(pickup)
end

function L_PickupCreatePed(pickup)
	--assert(pickup.ped ~= nil, "ERROR - L_PickupCreatePedByName: No ped specified")
	pickup.id = PickupCreateFromPed(pickup.model, pickup.ped, pickup.butes)
	F_PickupProcessAttributes(pickup)
end

function L_PickupCreateGroup(groupName)
	LT_GroupFunction(groupName, L_PickupCreateByType)
end

function L_PickupCreateType(pickup)
	if pickup.ped then
		L_PickupCreatePed(pickup)
	elseif pickup.point then
		L_PickupCreatePoint(pickup)
	elseif pickup.x and pickup.y and pickup.z then
		L_PickupCreateXYZ(pickup)
	end
end

function L_PickupPlayerReset()
	for i, group in LT_LibTable() do
		if LT_Type(i) == pickupTypeName then
			for j, pickup in group do
				ItemSetCurrentNum(pickup.model, pickup.initPlayerInventory)
			end
		end
	end
end

function T_PickupMonitor()
	while not L_ObjectiveProcessingDone() do
		F_PickupMonitor()
		Wait(0)
	end
	collectgarbage()
end

function F_PickupMonitor()
	for i, group in LT_LibTable() do
		if LT_Type(i) == pickupTypeName then
			for j, pickup in group do
				local numInventory = ItemGetCurrentNum(pickup.model)
				if numInventory > pickup.numInventory[gPlayer] then
					pickup.numInventory[gPlayer] = numInventory
					pickup.lastPedToPickup = gPlayer
					if pickup.OnPickup then
						pickup.OnPickup(pickup)
					end
				end
				if pickup.grabber then
					for i, ped in pickup.grabber do
						if pickup.numInventory[ped] == nil then
							pickup.numInventory[ped] = 0
						end
						if not pickup.noGrab and pickup.id and (pickup.ped and not pickup.ped == ped or GetTimer() - pickup.timeSpawned > pickup.grabDelay) and PedIsInAreaXYZ(ped, pickup.x, pickup.y, pickup.z, pickup.grabRadius, 0) then
							PickupDelete(pickup.id)
							pickup.id = nil
							L_HUDBlipRemove(pickup)
							pickup.numInventory[ped] = pickup.numInventory[ped] + 1
							pickup.lastPedToPickup = ped
							if pickup.OnPickup then
								pickup.OnPickup(pickup)
							end
						end
					end
				end
			end
		end
	end
end
