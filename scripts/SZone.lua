weaponTable = {}
weaponTable.size = 0
pickupTable = {}
pickupTable.size = 0
local bikeSpawnDelay = 2000
local currentBikeIndex = 0
local maxBikes = 2
local bikeTable = {
	273,
	278,
	279,
	280,
	281,
	282,
	283,
	273,
	274,
	272
}
local currentBikesTable = {}
local bRAPressed = false
local bLAPressed = false
local bDAPressed = false
local tblScenario = {}
local currentScen = 1
local printScen = 1
local launchScen = 1

function F_SetupDebugMenuSZone()
	myPage = DebugMenuAddPage("Spawn Bike")
	numberOnPage = 0
	for bike = 1, table.getn(bikeTable) do
		if numberOnPage == 29 then
			myPage = DebugMenuAddPage("Spawn Bike")
			numberOnPage = 0
		end
		local tempBike = bike
		myItem = DebugMenuAddItem(myPage, GetModelName(bikeTable[bike]), function()
			currentBikeIndex = tempBike
			if table.getn(currentBikesTable) + 1 > maxBikes then
				VehicleDelete(currentBikesTable[1])
				table.remove(currentBikesTable, 1)
			end
			bikeLastSpawned = currentTime
			while not VehicleRequestModel(bikeTable[currentBikeIndex]) do
				Wait(0)
			end
			local x, y, z = PedGetPosXYZ(gPlayer)
			local new_bike = VehicleCreateXYZ(bikeTable[currentBikeIndex], x, y, z + 2)
			table.insert(currentBikesTable, new_bike)
			if not PedIsOnVehicle(gPlayer) then
				PlayerPutOnBike(new_bike)
			end
		end)
		numberOnPage = numberOnPage + 1
	end
	myPage = DebugMenuAddPage("Area Jump")
	numberOnPage = 0
	for location = 0, shared.areaTable.size - 1 do
		if numberOnPage == 29 then
			myPage = DebugMenuAddPage("Area Jump")
			numberOnPage = 0
		end
		local tempLocation = location
		myItem = DebugMenuAddItem(myPage, shared.areaTable[location].name, function()
			F_LoadArea(tempLocation)
		end)
		numberOnPage = numberOnPage + 1
	end
	myPage = DebugMenuAddPage("Ambient Scenarios")
	numberOnPage = 0
	for scenario = 1, table.getn(tblScenario) do
		if numberOnPage == 29 then
			myPage = DebugMenuAddPage("Ambient Scenarios")
			numberOnPage = 0
		end
		local tempScenario = scenario
		myItem = DebugMenuAddItem(myPage, tblScenario[scenario][2], function()
			F_SendToScenario(tempScenario)
		end)
		numberOnPage = numberOnPage + 1
	end
	myPage = DebugMenuAddPage("Give Weapon")
	numberOnPage = 0
	for weapon = 1, table.getn(weaponTable) do
		if numberOnPage == 29 then
			myPage = DebugMenuAddPage("Give Weapon")
			numberOnPage = 0
		end
		local tempWeapon = weapon
		myItem = DebugMenuAddItem(myPage, weaponTable[weapon].name, function()
			F_CreateWeapon(tempWeapon)
		end)
		numberOnPage = numberOnPage + 1
	end
	myPage = DebugMenuAddPage("Spawn Weapon")
	numberOnPage = 0
	for weapon = 1, table.getn(weaponTable) do
		if numberOnPage == 29 then
			myPage = DebugMenuAddPage("Spawn Weapon")
			numberOnPage = 0
		end
		local tempWeapon = weapon
		myItem = DebugMenuAddItem(myPage, weaponTable[weapon].name, function()
			F_SpawnWeapon(tempWeapon)
		end)
		numberOnPage = numberOnPage + 1
	end
	myPage = DebugMenuAddPage("Spawn Pickup")
	numberOnPage = 0
	for pickup = 1, table.getn(pickupTable) do
		if numberOnPage == 29 then
			myPage = DebugMenuAddPage("Spawn Pickup")
			numberOnPage = 0
		end
		local tempPickup = pickup
		myItem = DebugMenuAddItem(myPage, pickupTable[pickup].name, function()
			F_SpawnPickup(tempPickup)
		end)
		numberOnPage = numberOnPage + 1
	end
end

function main()
	local location = 0
	local missionIndex = 0
	local weap_loc = 1
	local CutSceneIndex = 0
	F_BuildWeaponTable()
	F_BuildPickupTable()
	F_InitScenarioTable()
	local bikeLastSpawned = 0
	local didSetupDebugMenu = false
	while true do
		Wait(0)
		if not didSetupDebugMenu and 0 < shared.areaTable.size then
			F_SetupDebugMenuSZone()
			didSetupDebugMenu = true
		end
		local currentTime = GetTimer()
		if IsButtonPressed(11, 1) and IsButtonPressed(10, 1) and IsButtonPressed(13, 1) then
			local x, y, z = PlayerGetPosXYZ()
			while not VehicleRequestModel(289) do
				Wait(0)
			end
			local kart = VehicleCreateXYZ(289, x + 1, y + 1, z)
			Wait(0)
			PedWarpIntoCar(gPlayer, kart)
			Wait(500)
		end
		if IsButtonPressed(11, 1) and IsButtonPressed(13, 1) and currentTime - bikeLastSpawned > bikeSpawnDelay then
			bikeLastSpawned = currentTime
			local x, y, z = PedGetPosXYZ(gPlayer)
			currentBikeIndex = currentBikeIndex + 1
			if currentBikeIndex > table.getn(bikeTable) then
				currentBikeIndex = 1
			end
			while not VehicleRequestModel(bikeTable[currentBikeIndex]) do
				Wait(0)
			end
			if table.getn(currentBikesTable) + 1 > maxBikes then
				VehicleDelete(currentBikesTable[1])
				table.remove(currentBikesTable, 1)
			end
			local new_bike = VehicleCreateXYZ(bikeTable[currentBikeIndex], x, y, z + 2)
			table.insert(currentBikesTable, new_bike)
			if not PedIsOnVehicle(gPlayer) then
				PlayerPutOnBike(new_bike)
			end
		end
		if IsButtonPressed(10, 1) and IsButtonPressed(13, 1) then
			local x, y, z = PlayerGetPosXYZ()
			while not VehicleRequestModel(284) do
				Wait(0)
			end
			local mower = VehicleCreateXYZ(284, x + 1, y + 1, z)
			Wait(0)
			PedWarpIntoCar(gPlayer, mower)
			Wait(500)
		end
		if IsButtonPressed(10, 1) and IsButtonPressed(11, 1) then
			local x, y, z = PlayerGetPosXYZ()
			PickupCreateXYZ(483, x + 2, y + 2, z)
			Wait(500)
		end
		if IsButtonPressed(15, 1) then
			if IsButtonPressed(1, 1) then
				weap_loc = weap_loc + 1
				if weap_loc > weaponTable.size then
					weap_loc = 1
				end
				TextPrintString(weaponTable[weap_loc].name, 2, 2)
				Wait(200)
			elseif IsButtonPressed(0, 1) then
				weap_loc = weap_loc - 1
				if weap_loc < 1 then
					weap_loc = weaponTable.size
				end
				TextPrintString(weaponTable[weap_loc].name, 2, 2)
				Wait(200)
			elseif F_IsButtonPressedWithDelayCheck(3, 1) then
				F_CreateWeapon(weap_loc)
			elseif gCurrentZone ~= 22 and IsButtonPressed(10, 1) then
				CutSceneIndex = CutSceneIndex + 1
				if CutSceneIndex > cutsceneTable.size then
					CutSceneIndex = 1
				end
				TextPrintString(cutsceneTable[CutSceneIndex].name, 2, 2)
				Wait(200)
			elseif gCurrentZone ~= 22 and IsButtonPressed(11, 1) then
				CutSceneIndex = CutSceneIndex - 1
				if CutSceneIndex < 1 then
					CutSceneIndex = cutsceneTable.size
				end
				TextPrintString(cutsceneTable[CutSceneIndex].name, 2, 2)
				Wait(200)
			elseif gCurrentZone ~= 22 and IsButtonPressed(2, 1) then
				CutSceneIndex = CutSceneIndex + 10
				if CutSceneIndex > cutsceneTable.size then
					CutSceneIndex = 1
				end
				TextPrintString(cutsceneTable[CutSceneIndex].name, 2, 2)
				Wait(200)
			elseif gCurrentZone ~= 22 and IsButtonPressed(13, 1) then
				F_PlayCutScene(CutSceneIndex, true)
			end
		elseif IsButtonPressed(11, 1) and IsButtonPressed(6, 1) then
			if IsButtonPressed(1, 1) and not bRAPressed then
				currentScen = currentScen + 1
				F_PrintSelectedScenario()
				bRAPressed = true
			elseif not IsButtonPressed(1, 1) and bRAPressed then
				bRAPressed = false
			end
			if IsButtonPressed(0, 1) and not bLAPressed then
				currentScen = currentScen - 1
				F_PrintSelectedScenario()
				bLAPressed = true
			elseif not IsButtonPressed(0, 1) and bLAPressed then
				bLAPressed = false
			end
			if IsButtonPressed(3, 1) and not bDAPressed then
				F_SendPlayerToScenario()
				bDAPressed = true
			elseif not IsButtonPressed(3, 1) and bDAPressed then
				bDAPressed = false
			end
		elseif not CameraDebugActive() then
			if IsButtonPressed(1, 1) then
				location = location + 1
				if location == shared.areaTable.size then
					location = 0
				end
				TextPrintString(shared.areaTable[location].name, 2, 1)
				Wait(200)
			end
			if IsButtonPressed(0, 1) then
				location = location - 1
				if location == -1 then
					location = shared.areaTable.size - 1
				end
				TextPrintString(shared.areaTable[location].name, 2, 1)
				Wait(200)
			end
			if IsButtonPressed(3, 1) then
				F_LoadArea(location)
			end
			if IsButtonPressed(10, 1) and IsButtonPressed(6, 1) then
				local missionCount = GetMissionCount()
				if IsButtonPressed(11, 1) then
					missionIndex = missionIndex - 10
				else
					missionIndex = missionIndex - 1
				end
				if missionIndex < 0 then
					missionIndex = missionCount - 1
				end
				local missionName = MissionGetName(missionIndex)
				TextPrintString(missionName, 2, 1)
				Wait(200)
			end
			if IsButtonPressed(10, 1) and IsButtonPressed(8, 1) then
				local missionCount = GetMissionCount()
				if IsButtonPressed(11, 1) then
					missionIndex = missionIndex + 10
				else
					missionIndex = missionIndex + 1
				end
				if missionCount <= missionIndex then
					missionIndex = 0
				end
				local missionName = MissionGetName(missionIndex)
				TextPrintString(missionName, 2, 1)
				Wait(200)
			end
			if IsButtonPressed(10, 1) and IsButtonPressed(5, 1) then
				ForceStartMissionIndex(missionIndex)
			end
		end
	end
end

function F_LoadArea(area)
	CameraFade(600, 0)
	Wait(600)
	hour, minute = ClockGet()
	AreaForceLoadAreaByAreaTransition(true)
	AreaDisableCameraControlForTransition(true)
	AreaTransitionXYZ(shared.areaTable[area].zone, shared.areaTable[area].x, shared.areaTable[area].y, shared.areaTable[area].z)
	AreaDisableCameraControlForTransition(false)
	AreaForceLoadAreaByAreaTransition(false)
	PlayerFaceHeading(shared.areaTable[area].h - 90, 0)
	TextPrintString(shared.areaTable[area].name, 5, 2)
	gCurrentZone = shared.areaTable[area].zone
	CameraReturnToPlayer()
	CameraFade(600, 1)
	AreaRemoveExtraScene()
	Wait(50)
end

function F_CreateWeapon(weapon)
	local wtable = {
		weaponTable[weapon].model
	}
	if weaponTable[weapon].ammo ~= nil then
		table.insert(wtable, weaponTable[weapon].ammo)
	end
	LoadWeaponModels(wtable)
	if weaponTable[weapon].inventory then
		if shared.gControllerPed == gPlayer then
			GiveWeaponToPlayer(weaponTable[weapon].model)
			PlayerSetWeapon(weaponTable[weapon].model, 50)
			if weaponTable[weapon].ammo ~= nil then
				GiveAmmoToPlayer(weaponTable[weapon].ammo, 50)
			end
		else
			PedSetWeapon(shared.gControllerPed, weaponTable[weapon].model, 50)
		end
	elseif shared.gControllerPed == gPlayer then
		PlayerSetWeapon(weaponTable[weapon].model, 1)
	else
		PedSetWeapon(shared.gControllerPed, weaponTable[weapon].model, 1)
	end
end

function F_SpawnPickup(pickup)
	local h = PedGetHeading(gPlayer) + math.pi / 2
	local hx = math.cos(h) * 2
	local hy = math.sin(h) * 2
	local px, py, pz = PlayerGetPosXYZ()
	PickupCreateXYZ(pickupTable[pickup].model, px + hx, py + hy, pz)
end

function F_SpawnWeapon(weapon)
	local h = PedGetHeading(gPlayer) + math.pi / 2
	local hx = math.cos(h) * 2
	local hy = math.sin(h) * 2
	local px, py, pz = PlayerGetPosXYZ()
	PickupCreateXYZ(weaponTable[weapon].model, px + hx, py + hy, pz)
end

function F_SendToScenario(number)
	PlayerSetPosXYZArea(tblScenario[number][4], tblScenario[number][5], tblScenario[number][6], tblScenario[number][1])
	ClockSet(tblScenario[number][3], 0)
end

function F_SendPlayerToScenario()
	CameraFade(600, 0)
	Wait(600)
	if shared.gAllMissionsPassed == false then
		shared.gAllMissionsPassed = true
		--print("CMON!")
		ForceMissionAvailable("6_PassAll")
		StartMission("6_PassAll")
		while not MissionActiveSpecific("6_PassAll") do
			Wait(0)
		end
		while MissionActiveSpecific("6_PassAll") do
			Wait(0)
		end
		--print("YEAH!!!!")
	end
	PlayerSetPosXYZArea(tblScenario[currentScen][4], tblScenario[currentScen][5], tblScenario[currentScen][6], tblScenario[currentScen][1])
	ClockSet(tblScenario[currentScen][3], 0)
	CameraReturnToPlayer()
	CameraFade(600, 1)
end

function F_PrintSelectedScenario()
	currentScen = F_CheckRange(currentScen)
	TextClear()
	TextPrintString(tblScenario[currentScen][2], 3, 1)
end

function F_CheckRange(currentScen)
	if currentScen < 1 then
		currentScen = maxScen
	end
	if currentScen > maxScen then
		currentScen = 1
	end
	return currentScen
end

function F_InitScenarioTable()
	tblScenario = {
		{
			0,
			"POI._SCENARIO_ALGIE1",
			9,
			581.783,
			-123.586,
			5.87038
		},
		{
			2,
			"POI._SCENARIO_ALGIEESCORT",
			12,
			-656.269,
			-297.92,
			5.53
		},
		{
			2,
			"POI._SCENARIO_BOGROLL",
			9,
			-584.2,
			-327.8,
			0
		},
		{
			2,
			"POI._SCENARIO_BOGROLL2",
			9,
			-584.2,
			-327.8,
			0
		},
		{
			0,
			"POI._SCENARIO_BUSGETBIKE",
			20,
			478.116,
			-79.74,
			5.543
		},
		{
			0,
			"POI._SCENARIO_CABLEGUY",
			9,
			226.861,
			-373.252,
			2.82299
		},
		{
			0,
			"POI._SCENARIO_CANNING",
			12,
			154.9,
			-87.252,
			6.3
		},
		{
			2,
			"POI._SCENARIO_CHERRYTOILET",
			9,
			-583.537,
			-319.987,
			0
		},
		{
			0,
			"POI._SCENARIO_CRABTRAPS",
			9,
			322.343,
			242.305,
			5.08089
		},
		{
			0,
			"POI._SCENARIO_CARNIEPHOTO",
			9,
			185.549,
			433.8,
			5.40052
		},
		{
			0,
			"POI._SCENARIO_CRAZYFARM",
			9,
			-66.8206,
			-314.201,
			4.35176
		},
		{
			0,
			"POI._SCENARIO_DETECTIVEJIMMY",
			9,
			624.808,
			-102.176,
			6.01003
		},
		{
			0,
			"POI._SCENARIO_EASYDRUGS",
			9,
			501.676,
			-100.956,
			4.73346
		},
		{
			0,
			"POI._SCENARIO_EGGBDORM",
			20,
			295.169,
			-43.144,
			6.207
		},
		{
			0,
			"POI._SCENARIO_EGGGDORM",
			20,
			293.819,
			-102.271,
			7.86751
		},
		{
			0,
			"POI._SCENARIO_EGGGREASER",
			9,
			228.013,
			-424.729,
			2.60339
		},
		{
			0,
			"POI._SCENARIO_EGGPOORH",
			20,
			487.968,
			-373.436,
			2.95156
		},
		{
			0,
			"POI._SCENARIO_ESCAPIST",
			22,
			553.382,
			377.684,
			17.3928
		},
		{
			0,
			"POI._SCENARIO_FASTFOOD",
			9,
			393.318,
			267.045,
			9.06575
		},
		{
			2,
			"POI._SCENARIO_FIREALARM",
			9,
			224.799,
			11.9209,
			6.4858
		},
		{
			0,
			"POI._SCENARIO_GIRLESCORT",
			17,
			519.395,
			-297.667,
			2.31491
		},
		{
			0,
			"POI._SCENARIO_JUMPMAN",
			17,
			218.483,
			242.456,
			3.45399
		},
		{
			0,
			"POI._SCENARIO_HOMELESSHELP",
			20,
			562.941,
			-375.675,
			2.26791
		},
		{
			2,
			"POI._SCENARIO_LOCKERED_SCHOOL",
			8,
			-643.889,
			-298.994,
			5.59048
		},
		{
			0,
			"POI._SCENARIO_LOSTBEAR",
			9,
			289.443,
			144.623,
			1.44452
		},
		{
			0,
			"POI._SCENARIO_LOSTCARGO",
			9,
			223.102,
			-278.158,
			1.75871
		},
		{
			0,
			"POI._SCENARIO_LOSTDOG",
			16,
			536.667,
			-25.5259,
			5.83425
		},
		{
			0,
			"POI._SCENARIO_LOSTDOG2",
			12,
			518.667,
			-143.5259,
			5.43425
		},
		{
			0,
			"POI._SCENARIO_PHOTOTAG",
			18,
			475.5,
			-448.783,
			2.83845
		},
		{
			2,
			"POI._SCENARIO_PICKIT_SCHOOL",
			8,
			-617.154,
			-311.758,
			0.0199999
		},
		{
			0,
			"POI._SCENARIO_PIRATE",
			15,
			53.9133,
			224.567,
			2.3561
		},
		{
			0,
			"POI._SCENARIO_PRANKB",
			9,
			549.378,
			-75.4747,
			12.6079
		},
		{
			0,
			"POI._SCENARIO_RATKILLER",
			16,
			335.019,
			-241.495,
			2.4446
		},
		{
			0,
			"POI._SCENARIO_RATSOUT",
			9,
			573.033,
			-473.676,
			4.46808
		},
		{
			2,
			"POI._SCENARIO_SECRETADMIRER",
			12,
			-606.701,
			-318.327,
			5.49998
		},
		{
			2,
			"POI._SCENARIO_SECRETADMIRER2",
			12,
			-627.7,
			-283.3,
			-1.7
		},
		{
			0,
			"POI._SCENARIO_SHIPPINGRECEIVING",
			9,
			124.264,
			-402.298,
			7.68428
		},
		{
			0,
			"POI._SCENARIO_SHIPWREAKED",
			17,
			218.483,
			242.456,
			3.45399
		},
		{
			0,
			"POI._SCENARIO_SMASHCAR",
			20,
			100.8,
			-445.3,
			3.02
		},
		{
			0,
			"POI._SCENARIO_SMASHCARP",
			20,
			490.098,
			-258.127,
			2.54317
		},
		{
			0,
			"POI._SCENARIO_SMOKEFREE",
			20,
			551.167,
			-19.5072,
			5.5561
		},
		{
			0,
			"POI._SCENARIO_SPAZZDELIVERY",
			12,
			503.763,
			-364.605,
			4.0583
		},
		{
			0,
			"POI._SCENARIO_STRANGEHOBO",
			16,
			501.797,
			-47.8991,
			5.91426
		},
		{
			0,
			"POI._SCENARIO_SWIMIT",
			12,
			230.867,
			303.43,
			1.43772
		},
		{
			0,
			"POI._SCENARIO_TAGPOOR",
			16,
			506.736,
			-232.306,
			2.33091
		},
		{
			0,
			"POI._SCENARIO_TAGRICH",
			16,
			483.635,
			286.777,
			19.905
		},
		{
			0,
			"POI._SCENARIO_TAKEMEHOME",
			20,
			186.667,
			-6.217,
			5.581
		},
		{
			0,
			"POI._SCENARIO_THECHEAT",
			16,
			543.154,
			-286.271,
			2.28173
		},
		{
			0,
			"POI._SCENARIO_TENFIRES",
			9,
			573.033,
			-473.676,
			4.46808
		},
		{
			0,
			"POI._SCENARIO_THEMAILMAN",
			12,
			394.2,
			499.2,
			22.6
		},
		{
			0,
			"POI._SCENARIO_THEWIDOW",
			12,
			553.382,
			377.684,
			17.3928
		}
	}
	maxScen = table.getn(tblScenario)
end

function F_BuildWeaponTable()
	weaponTable = {
		{
			model = 300,
			name = "bat",
			inventory = false
		},
		{
			model = 310,
			name = "apple",
			inventory = false
		},
		{
			model = 327,
			name = "bottle",
			inventory = false
		},
		{
			model = 311,
			name = "brick",
			inventory = false
		},
		{
			model = 307,
			name = "rocket launcher",
			inventory = true,
			ammo = 308
		},
		{
			model = 301,
			name = "cherry bomb",
			inventory = true
		},
		{
			model = 312,
			name = "eggs",
			inventory = true
		},
		{
			model = 326,
			name = "fire extinguisher",
			inventory = false
		},
		{
			model = 315,
			name = "garbage can lid",
			inventory = false
		},
		{
			model = 320,
			name = "newspaper",
			inventory = true
		},
		{
			model = 303,
			name = "slingshot",
			inventory = true
		},
		{
			model = 313,
			name = "snowball",
			inventory = false
		},
		{
			model = 330,
			name = "big snowball",
			inventory = false
		},
		{
			model = 321,
			name = "spraycan",
			inventory = true
		},
		{
			model = 305,
			name = "spud gun",
			inventory = true,
			ammo = 316
		},
		{
			model = 309,
			name = "stinkbomb",
			inventory = true
		},
		{
			model = 306,
			name = "super slingshot",
			inventory = true,
			ammo = 304
		},
		{
			model = 323,
			name = "two by four",
			inventory = false
		},
		{
			model = 328,
			name = "camera",
			inventory = true
		},
		{
			model = 426,
			name = "digital camera",
			inventory = true
		},
		{
			model = 299,
			name = "yardstick",
			inventory = false
		},
		{
			model = 337,
			name = "chemical compound",
			inventory = true
		},
		{
			model = 339,
			name = "cigarette",
			inventory = false
		},
		{
			model = 331,
			name = "football",
			inventory = false
		},
		{
			model = 335,
			name = "frisbee",
			inventory = false
		},
		{
			model = 302,
			name = "baseball",
			inventory = false
		},
		{
			model = 357,
			name = "Cricket Bat",
			inventory = false
		},
		{
			model = 332,
			name = "Mallet",
			inventory = false
		},
		{
			model = 355,
			name = "Decorative plate",
			inventory = false
		},
		{
			model = 354,
			name = "Vase",
			inventory = false
		},
		{
			model = 353,
			name = "Plant Pot",
			inventory = false
		},
		{
			model = 364,
			name = "Snow Shovel",
			inventory = false
		},
		{
			model = 378,
			name = "Soccer ball for Footy",
			inventory = false
		},
		{
			model = 329,
			name = "Soccer ball",
			inventory = false
		},
		{
			model = 342,
			name = "Water Pipe",
			inventory = false
		},
		{
			model = 387,
			name = "Edgar Shield A",
			inventory = false
		},
		{
			model = 388,
			name = "Edgar Shield B",
			inventory = false
		},
		{
			model = 389,
			name = "Edgar Shield C",
			inventory = false
		},
		{
			model = 381,
			name = "AniBasketball",
			inventory = false
		},
		{
			model = 349,
			name = "Marbles",
			inventory = true
		},
		{
			model = 372,
			name = "Kick Me",
			inventory = false
		},
		{
			model = 346,
			name = "Dead rat",
			inventory = false
		},
		{
			model = 324,
			name = "Sledgehammer",
			inventory = false
		},
		{
			model = 393,
			name = "Joke Candy",
			inventory = true,
			ammo = 393
		},
		{
			model = 394,
			name = "Itching Powder",
			inventory = true
		},
		{
			model = 396,
			name = "Super Spud Gun",
			inventory = true,
			ammo = 316
		},
		{
			model = 395,
			name = "Rat Killa Gun",
			inventory = false
		},
		{
			model = 397,
			name = "Firework Fountain",
			inventory = false
		},
		{
			model = 399,
			name = "Bag O' Poo",
			inventory = false
		},
		{
			model = 404,
			name = "Umbrella",
			inventory = false
		},
		{
			model = 405,
			name = "SchoolBook",
			inventory = true
		},
		{
			model = MODELENUM._W_GARBBIN,
			name = "Garbage Bin",
			inventory = false
		},
		{
			model = 411,
			name = "SS Whip",
			inventory = false
		},
		{
			model = 410,
			name = "Pinky Wand",
			inventory = false
		},
		{
			model = 409,
			name = "Pitchfork",
			inventory = false
		},
		{
			model = 348,
			name = "Cafeteria Tray",
			inventory = false
		},
		{
			model = 412,
			name = "BoltCutters",
			inventory = false
		},
		{
			model = 417,
			name = "Detonator",
			inventory = false
		},
		{
			model = 418,
			name = "Lead Pipe",
			inventory = false
		},
		{
			model = 419,
			name = "TBone Steak",
			inventory = false
		},
		{
			model = 420,
			name = "Flashlight",
			inventory = false
		},
		{
			model = 377,
			name = "Broom",
			inventory = false
		},
		{
			model = 363,
			name = "Teddy Bear",
			inventory = false
		},
		{
			model = 433,
			name = "Siamese Twin Bad",
			inventory = false
		},
		{
			model = 360,
			name = "PSheild",
			inventory = false
		},
		{
			model = 383,
			name = "Water Balloon",
			inventory = false
		},
		{
			model = 358,
			name = "Banana",
			inventory = false
		},
		{
			model = 403,
			name = "TP Roll",
			inventory = false
		},
		{
			model = 325,
			name = "Rubber band ball",
			inventory = false
		},
		{
			model = 400,
			name = "Rigged Football",
			inventory = false
		}
	}
	weaponTable.size = table.getn(weaponTable)
end

function F_BuildPickupTable()
	pickupTable = {
		{ model = 464, name = "ClwnPant" },
		{ model = 465, name = "ClwnShoe" },
		{ model = 466, name = "StpdShrt" },
		{ model = 467, name = "CanaHat" },
		{ model = 468, name = "BeadBrac" },
		{ model = 469, name = "AngelBand" },
		{ model = 470, name = "DevilHorn" },
		{ model = 471, name = "WeirdHat" },
		{ model = 472, name = "ClownWig" },
		{ model = 473, name = "BigWatch" },
		{ model = 474, name = "GeekCard" },
		{ model = 475, name = "FlowerGift" },
		{ model = 476, name = "Radio" },
		{ model = 478, name = "ChocBox" },
		{ model = 481, name = "CollectA" },
		{ model = 482, name = "GiftA" },
		{ model = 483, name = "bea_diary" },
		{ model = 484, name = "undie" },
		{ model = 485, name = "PickBull" },
		{ model = 488, name = "LabNotes" },
		{ model = 489, name = "Save" },
		{ model = 490, name = "Perfume" },
		{ model = 491, name = "NPearl" },
		{ model = 492, name = "SexDress" },
		{ model = 494, name = "TadKey" },
		{ model = 495, name = "ticket" },
		{ model = 497, name = "charSheet" },
		{ model = 498, name = "textbook" },
		{ model = 501, name = "drugbag" },
		{ model = 502, name = "PChealth" },
		{ model = 503, name = "PCspec" },
		{ model = 504, name = "Comicbk" },
		{ model = 505, name = "dossier" },
		{ model = 506, name = "CrnPosterB" },
		{ model = 507, name = "laundbag" },
		{ model = 508, name = "lipstick" },
		{ model = 510, name = "orderly" },
		{ model = 511, name = "Moped" },
		{ model = 512, name = "PostBand" },
		{ model = 513, name = "PostCar" },
		{ model = 514, name = "CrnPosterA" },
		{
			model = 515,
			name = "BUNCHOFPANTIES"
		},
		{ model = 517, name = "MarbBag" },
		{
			model = 518,
			name = "flashlightCone"
		},
		{
			model = 519,
			name = "flashlightVolume"
		},
		{ model = 520, name = "SmWatch" },
		{ model = 521, name = "package" },
		{ model = 522, name = "DrugBttl" },
		{ model = 523, name = "Crab" },
		{ model = 524, name = "AlgieJac" },
		{ model = 525, name = "SaveB" },
		{
			model = 526,
			name = "BUNCHOFPHOTOS"
		},
		{ model = 527, name = "TbonePU" },
		{ model = 528, name = "Oldmeat" },
		{
			model = 529,
			name = "bbagbottle_inv"
		},
		{ model = 530, name = "SmCargo" },
		{
			model = MODELENUM._BOUY,
			name = "Bouy"
		},
		{ model = 499, name = "Razor" },
		{ model = 500, name = "RubBand" },
		{ model = 516, name = "RatCrate" },
		{ model = 509, name = "AddBook" },
		{ model = 496, name = "LolaKeys" },
		{ model = 493, name = "NewKey" },
		{ model = 487, name = "BoltCutPU" },
		{ model = 486, name = "W_diaryPU" },
		{ model = 320, name = "PaperStack" }
	}
	pickupTable.size = table.getn(pickupTable)
end
