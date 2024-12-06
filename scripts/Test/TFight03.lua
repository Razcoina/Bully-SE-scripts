local wt = {
	{ name = "Bat",       model = 300 },
	{ name = "Yardstick", model = 299 },
	{
		name = "Sledgehammer",
		model = 324
	},
	{ name = "Lid", model = 315 }
}
local x, y, z

function main()
	local index = 1
	x, y, z = -21, 9, 26.5
	while true do
		Wait(0)
		if IsButtonPressed(2, 0) then
			Wait(250)
			index = index + 1
			if index > table.getn(wt) then
				index = 1
			end
			TextPrintString(wt[index].name, 2)
			--print(wt[index].name)
		end
		if IsButtonPressed(3, 0) then
			Wait(250)
			PickupCreateXYZ(wt[index].model, x, y, z)
			TextPrintString("Creating pickup: " .. wt[index].name, 2)
		end
		if IsButtonPressed(0, 0) then
			Wait(250)
			myPed = PedCreateXYZ(24, x + 10, y, z)
			TextPrintString("Creating ped", 2)
		end
	end
	MissionSucceed()
end

function MissionCleanup()
end

function MissionSetup()
	local x, y, z = -9.988, 21.42, 30.06
	AreaTransitionXYZ(22, x, y, z)
end
