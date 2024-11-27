function MissionSetup()
end

function MissionCleanup()
end

function main()
	local x, y, z = PedGetPosXYZ(gPlayer)
	z = z + 2
	y = y + 2
	x = x + 2
	local dog = PedCreateXYZ(69, x, y, z)
	PedAttack(dog, gPlayer)
	while not PedIsDead(dog) do
		Wait(0)
	end
end
