function main()
	DoRemoteXmlHeapDump("post_startup.xml")
	DATLoad("BuildTest.DAT", 2)
	DATInit()
	math.randomseed(GetTimer())
	PedSetPunishmentPoints(gPlayer, 0)
	AreaTransitionPoint(14, POINTLIST._TB_PLAYERSTART)
	PlayerSetControl(0)
	PedSetInfiniteSprint(gPlayer, true)
	Wait(1000)
	gMissionSuccess = false
	PedFollowPath(gPlayer, PATH._TB_PLAYERPATH01, 0, 2, CbPath01)
	while not gMissionSuccess do
		Wait(0)
	end
	DoRemoteXmlHeapDump("boys_dorm.xml")
	AreaTransitionPoint(0, POINTLIST._TB_SCHOOLGROUNDS)
	gMissionSuccess = false
	PedFollowPath(gPlayer, PATH._TB_PLAYERPATH02, 0, 2, CbPath02)
	while not gMissionSuccess do
		Wait(0)
	end
	DoRemoteXmlHeapDump("school_grounds.xml")
	AreaTransitionPoint(2, POINTLIST._TB_SCHOOLHALLWAYS)
	Wait(3000)
	PedSetInfiniteSprint(gPlayer, false)
	PlayerSetControl(1)
	DATUnload(2)
	DoRemoteXmlHeapDump("school_hallways.xml")
	myAreaTable = {
		{
			zone = 0,
			name = "Business District",
			x = 458.59,
			y = -80.7372,
			z = 5.91727,
			h = 0
		},
		{
			zone = 0,
			name = "Rich Area",
			x = 338.8,
			y = 113.8,
			z = 7.8,
			h = 90
		},
		{
			zone = 0,
			name = "Carnival",
			x = 226.2,
			y = 412.6,
			z = 9,
			h = 150
		},
		{
			zone = 0,
			name = "Industrial Area",
			x = 355,
			y = -432,
			z = 3,
			h = 0
		},
		{
			zone = 9,
			name = "Library",
			x = -784.875,
			y = 203.098,
			z = 90.31,
			h = 0
		},
		{
			zone = 35,
			name = "Girls Dorm",
			x = -454,
			y = 311,
			z = 3.5,
			h = 0
		},
		{
			zone = 14,
			name = "Boys Dorm",
			x = -502.47,
			y = 309.606,
			z = 31.963,
			h = 0
		},
		{
			zone = 32,
			name = "Prep House",
			x = -569.538,
			y = 133.33,
			z = 46.3,
			h = 0
		},
		{
			zone = 19,
			name = "Auditorium",
			x = -778.496,
			y = 292.221,
			z = 77.951,
			h = 0
		},
		{
			zone = 27,
			name = "Boxing Club",
			x = -702.445,
			y = 372.796,
			z = 293.937,
			h = 252.5
		},
		{
			zone = 29,
			name = "Bike Shop",
			x = -785.601,
			y = 380.055,
			z = 0.73,
			h = 0
		},
		{
			zone = 30,
			name = "Comic Shop",
			x = -724.707,
			y = 12.604,
			z = 1.696,
			h = 0
		},
		{
			zone = 36,
			name = "Tenements",
			x = -544.463,
			y = -48.881,
			z = 32.009,
			h = 0
		},
		{
			zone = 37,
			name = "Funhouse",
			x = -700.446,
			y = -537.674,
			z = 11.27,
			h = 0
		},
		{
			zone = 38,
			name = "Asylum",
			x = -736.295,
			y = 422.404,
			z = 2.5,
			h = 30
		},
		{
			zone = 40,
			name = "Observatory",
			x = -696.615,
			y = 61.633,
			z = 21.089,
			h = 90
		},
		{
			zone = 0,
			name = "Poor Area",
			x = 499.367,
			y = -245.193,
			z = 1.94765,
			h = -90
		}
	}
	for area = 1, table.getn(myAreaTable) do
		CameraFade(1000, 0)
		Wait(1000)
		AreaTransitionXYZ(myAreaTable[area].zone, myAreaTable[area].x, myAreaTable[area].y, myAreaTable[area].z, true)
		PlayerFaceHeading(myAreaTable[area].h - 90, 0)
		TextPrintString(myAreaTable[area].name, 5, 2)
		gCurrentZone = myAreaTable[area].zone
		CameraReturnToPlayer()
		CameraFade(1000, 1)
		AreaRemoveExtraScene()
		Wait(10000)
		DoRemoteXmlHeapDump(myAreaTable[area].name .. ".xml")
	end
	Quit()
end

function CbPath01(pedId, pathId, pathNode)
	if pathNode == 18 then
		gMissionSuccess = true
	end
end

function CbPath02(pedId, pathId, pathNode)
	if pathNode == 14 then
		gMissionSuccess = true
	end
end
