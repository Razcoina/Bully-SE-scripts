local gPeds = {}
local gPedModels = {
	67,
	102,
	73,
	50
}
local bMissionRunning = true
local missions = {
	{
		id = "C_English_1",
		desc = "English 1"
	},
	{
		id = "C_English_2",
		desc = "English 2"
	},
	{
		id = "C_English_3",
		desc = "English 3"
	},
	{
		id = "C_English_4",
		desc = "English 4"
	},
	{
		id = "C_English_5",
		desc = "English 5"
	}
}
local currentMission = 5

function MissionSetup()
	DATLoad("TestCharIdles.DAT", 2)
	DATInit()
end

function MissionCleanup()
	DATUnload(2)
end

function F_CreatePeds()
	local ped
	for i = 1, 4 do
		--print("I is: ", i)
		ped = PedCreatePoint(gPedModels[i], POINTLIST._CHARACTERS, i)
		table.insert(gPeds, ped)
		Wait(0)
	end
end

function F_DeletePeds()
	while table.getn(gPeds) > 0 do
		if gPeds[1] and PedIsValid(gPeds[1]) then
			PedDelete(gPeds[1])
		end
		table.remove(gPeds, 1)
		Wait(0)
	end
end

function main()
	AreaTransitionPoint(22, POINTLIST._PLAYER, 1)
	CameraReturnToPlayer()
	CameraReset()
	LoadPedModels(gPedModels)
	F_CreatePeds()
	while true do
		TextPrintString("~L2~ + ~x~ - Reset Mission ~L2~ + ~t~ Quit Mission ~n~. ~L1~ + ~L2~ or ~L1~ + ~R1~ Iterate missions. ~n~ ~L1~ + ~R1~ Succeed Mission.", 5, 2)
		if not bButtonPressed then
			if IsButtonPressed(7, 0) and IsButtonPressed(11, 0) then
				F_DeletePeds()
				F_CreatePeds()
				bButtonPressed = true
				for i, missionId in missions do
					SetMissionSuccessCount(missionId.id, 0)
				end
			elseif IsButtonPressed(9, 0) and IsButtonPressed(11, 0) then
				break
			elseif IsButtonPressed(10, 0) and IsButtonPressed(11, 0) then
				currentMission = currentMission - 1
				if currentMission < 1 then
					currentMission = table.getn(missions)
				end
				TextPrintString(missions[currentMission].desc, 5, 1)
				Wait(1000)
			elseif IsButtonPressed(10, 0) and IsButtonPressed(13, 0) then
				currentMission = currentMission + 1
				if currentMission > table.getn(missions) then
					currentMission = 1
				end
				TextPrintString(missions[currentMission].desc, 5, 1)
				Wait(1000)
			elseif IsButtonPressed(10, 0) and IsButtonPressed(12, 0) then
				TextPrintString("Mission succeeded!", 5, 1)
				Wait(1000)
				SetMissionSuccessCount(missions[currentMission].id, 1)
				--print("Is mission success: ", GetMissionSuccessCount(missions[currentMission].id))
			end
		elseif not IsButtonPressed(7, 0) and not IsButtonPressed(9, 0) then
			bButtonPressed = false
		end
		Wait(0)
	end
	TextPrintString("", 1, 2)
	MissionSucceed()
end