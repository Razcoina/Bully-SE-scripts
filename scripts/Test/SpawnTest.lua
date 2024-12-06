function MissionSetup()
	AreaTransitionPoint(22, POINTLIST._SPAWNTEST_SPAWNSTART)

	Spawner1 = AreaAddMissionSpawner(5, 2, TRIGGER._SPAWNTEST_TRIG1, 2, 2000, 2000)
	SpawnP1 = AreaAddSpawnLocation(Spawner1, POINTLIST._SPAWNTEST_SPAWNP1, TRIGGER._SPAWNTEST_DOOR1)
	AreaAddPedTypeToSpawnLocation(Spawner1, SpawnP1, 2)
	SpawnP2 = AreaAddSpawnLocation(Spawner1, POINTLIST._SPAWNTEST_SPAWNP2, TRIGGER._SPAWNTEST_DOOR2)
	AreaAddPedTypeToSpawnLocation(Spawner1, SpawnP2, 2)
end

function main()
	while true do
		Wait(0)
	end
end
