local gDogs = {}

function MissionSetup()
end

function MissionCleanup()
end

function cbReachedPoint(ped, route, num)
end

function main()
	DATLoad("GuardDog.DAT", 2)
	DATInit()
	local dog = PedCreatePoint(69, POINTLIST.DOGSPAWN, 1)
	table.insert(gDogs, dog)
	PedSetPedToTypeAttitude(dog, 13, 0)
	PedFollowPath(dog, PATH._BEHINDRETIREMENT, 1, 0)
	local dog = PedCreatePoint(69, POINTLIST.SECONDDOG, 1)
	table.insert(gDogs, dog)
	PedSetPedToTypeAttitude(dog, 13, 0)
	PedFollowPath(dog, PATH._BESIDEPSYCHO, 2, 0)
	while PlayerIsInTrigger(TRIGGER._RICHAREA) do
		Wait(0)
	end
end
