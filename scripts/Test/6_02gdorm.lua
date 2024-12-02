local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bLoadedPeds = false
local bLaunchFirstGreasers = false
local bLivingRoomAttack = false
local bNortonAttack = false
local bFoundJohnny = false
local bSetGreaser3OnPath = false
local bBottomStairs = false
local bFireVase02 = false
local dustX, dustY, dustZ = 0, 0, 0
local thumpX, thumpY, thumpZ = 0, 0, 0
local tableGlassSound = {
	"PlateBreakSmall",
	"PlateBreakMed",
	"PlateBreakLarge",
	"BulbPop",
	"CeramicHit"
}
local tableRandomGirl = {
	39,
	74,
	68,
	137,
	138
}
local tempGirl01, tempGirl02, tempGirl03
local bDeleteGirl01 = false
local bDeleteGirl02 = false
local bDeleteGirl03 = false

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	DATLoad("6_02GDORM.DAT", 2)
	DATInit()
	F_TableInit()
	LoadAnimationGroup("Area_Tenements")
	LoadAnimationGroup("W_Snowshwl")
	AreaTransitionPoint(0, POINTLIST._6_02G_SPAWNPLAYER)
	WeaponRequestModel(324)
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	DATUnload(2)
	DATInit()
	UnLoadAnimationGroup("Area_Tenements")
	UnLoadAnimationGroup("W_Snowshwl")
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_Stage1()
	if bMissionFailed then
		TextPrint("MFAIL", 3, 1)
		Wait(3000)
		MissionFail()
	elseif bMissionPassed then
		TextPrint("MPASS", 3, 1)
		Wait(3000)
		MissionSucceed()
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedGreaser01 = {
		spawn = POINTLIST._6_02G_GREASER01,
		element = 1,
		model = 24
	}
	pedGreaser02 = {
		spawn = POINTLIST._6_02G_GREASER02,
		element = 1,
		model = 27
	}
	pedGreaser03 = {
		spawn = POINTLIST._6_02G_GREASER03,
		element = 1,
		model = 22
	}
	pedGreaser04 = {
		spawn = POINTLIST._6_02G_GREASER04,
		element = 1,
		model = 26
	}
	pedGreaser05 = {
		spawn = POINTLIST._6_02G_GREASER05,
		element = 1,
		model = 28
	}
	pedGreaser06 = {
		spawn = POINTLIST._6_02G_GREASER06,
		element = 1,
		model = 27
	}
	pedMandy = {
		spawn = POINTLIST._6_02G_MANDY,
		element = 1,
		model = 14
	}
	pedJohnny = {
		spawn = POINTLIST._6_02G_JOHNNY,
		element = 1,
		model = 23
	}
	pedNorton = {
		spawn = POINTLIST._6_02G_NORTON,
		element = 1,
		model = 29
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		Stage1_Objectives()
		if bMissionPassed then
			break
		end
		if bMissionFailed then
			break
		end
		Wait(0)
	end
end

function Stage1_Objectives()
	if not bLoadedPeds and PlayerIsInTrigger(TRIGGER._6_02G_LOADPEDS) then
		F_SetupGDormPeds()
		bLoadedPeds = true
	end
	if not bLaunchFirstGreasers and PlayerIsInTrigger(TRIGGER._6_02G_ENTRANCE) then
		F_LaunchFirstGreasers()
		bLaunchFirstGreasers = true
	end
	if not bFireVase02 and PlayerIsInTrigger(TRIGGER._6_02G_FIREVASE02) then
		F_FireVase02()
		bFireVase02 = true
	end
	if not bLivingRoomAttack and PlayerIsInTrigger(TRIGGER._6_02G_LIVINGROOM) then
		F_LivingRoomAttack()
		bLivingRoomAttack = true
	end
	if bDeleteGirl01 then
		PedDelete(tempGirl01)
		bDeleteGirl01 = false
	end
	if bDeleteGirl02 then
		PedDelete(tempGirl02)
		bDeleteGirl02 = false
	end
	if bDeleteGirl03 then
		PedDelete(tempGirl03)
		bDeleteGirl03 = false
	end
	if not bBottomStairs and PlayerIsInTrigger(TRIGGER._6_02G_BOTTOMSTAIRS) then
		PedSetActionNode(pedGreaser06.id, "/Global/6_02GDORM/Anims/Empty", "Act/Conv/6_02gdorm.act")
		PedAttackPlayer(pedGreaser06.id, 3)
		bBottomStairs = true
	end
	if not bNortonAttack and PlayerIsInTrigger(TRIGGER._6_02G_NORTON) then
		F_NortonAttack()
		bNortonAttack = true
	end
	if not bFoundJohnny and PlayerIsInTrigger(TRIGGER._6_02G_JOHNNY) then
		F_CutJohnny()
		bFoundJohnny = true
	end
	if bSetGreaser3OnPath then
		PedFollowPath(pedGreaser03.id, PATH._6_02G_LOOP, 1, 1)
		bSetGreaser3OnPath = false
	end
end

function F_SetupGDormPeds()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupGDormPeds()")
	pedGreaser01.id = PedCreatePoint(pedGreaser01.model, pedGreaser01.spawn, pedGreaser01.element)
	PedSetWeapon(pedGreaser01.id, 321, 100)
	PedSetActionNode(pedGreaser01.id, "/Global/6_02GDORM/Anims/Spray/Spray_A", "Act/Conv/6_02gdorm.act")
	pedGreaser02.id = PedCreatePoint(pedGreaser02.model, pedGreaser02.spawn, pedGreaser02.element)
	pedGreaser03.id = PedCreatePoint(pedGreaser03.model, pedGreaser03.spawn, pedGreaser03.element)
	pedGreaser04.id = PedCreatePoint(pedGreaser04.model, pedGreaser04.spawn, pedGreaser04.element)
	PedSetEffectedByGravity(pedGreaser04.id, false)
	PedSetWeapon(pedGreaser04.id, 321, 100)
	pedGreaser05.id = PedCreatePoint(pedGreaser05.model, pedGreaser05.spawn, pedGreaser05.element)
	PedOverrideStat(pedGreaser05.id, 15, 100)
	PedOverrideStat(pedGreaser05.id, 14, 100)
	PedWander(pedGreaser05.id, 1)
	pedGreaser06.id = PedCreatePoint(pedGreaser06.model, pedGreaser06.spawn, pedGreaser06.element)
	PedOverrideStat(pedGreaser06.id, 15, 100)
	PedOverrideStat(pedGreaser06.id, 14, 100)
	PedWander(pedGreaser06.id, 1)
	pedMandy.id = PedCreatePoint(pedMandy.model, pedMandy.spawn, pedMandy.element)
	pedJohnny.id = PedCreatePoint(pedJohnny.model, pedJohnny.spawn, pedJohnny.element)
	pedNorton.id = PedCreatePoint(pedNorton.model, pedNorton.spawn, pedNorton.element)
	PedSetWeapon(pedNorton.id, 324, 1)
	PedSetActionNode(pedNorton.id, "/Global/6_02GDORM/Anims/NortonSwing/Initialize", "Act/Conv/6_02gdorm.act")
	PedSetHealth(pedNorton.id, PedGetHealth(pedNorton.id) * 2)
	TextPrintString("Objective: Find Johnny", 4, 1)
	threadMonitorGreaser02 = CreateThread("T_MonitorGreaser02")
	propVase01 = PAnimCreate(TRIGGER._6_02G_VASE01)
	propVase02 = PAnimCreate(TRIGGER._6_02G_VASE02)
	propVase03 = PAnimCreate(TRIGGER._6_02G_VASE03)
	dustX, dustY, dustZ = GetPointList(POINTLIST._6_02G_NORTONSMASH)
	thumpX, thumpY, thumpZ = GetPointList(POINTLIST._6_02G_NORTONSMASH02)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupGDormPeds()")
end

function F_LaunchFirstGreasers()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchFirstGreasers()")
	PAnimFollowPath(TRIGGER._6_02G_VASE01, PATH._6_02G_VASE01, false, F_prouteVase01)
	PAnimSetPathFollowSpeed(TRIGGER._6_02G_VASE01, 8)
	Wait(500)
	PedSetStealthBehavior(pedGreaser02.id, 1)
	PedFollowPath(pedGreaser02.id, PATH._6_02G_LAUNDRY, 0, 1, F_routeLaundry)
	Wait(500)
	PedSetStealthBehavior(pedGreaser03.id, 1)
	PedFollowPath(pedGreaser03.id, PATH._6_02G_LAUNDRY, 0, 1, F_routeLaundry)
	PedSetPosPoint(pedGreaser04.id, pedGreaser04.spawn, pedGreaser04.element)
	PedSetActionNode(pedGreaser04.id, "/Global/6_02GDORM/Anims/Spray/Spray_Big_1", "Act/Conv/6_02gdorm.act")
	F_SpawnGirl(1)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchFirstGreasers()")
end

function F_LivingRoomAttack()
	--print("()xxxxx[:::::::::::::::> [start] F_LivingRoomAttack()")
	PAnimFollowPath(TRIGGER._6_02G_VASE03, PATH._6_02G_VASE03, false, F_prouteVase03)
	PAnimSetPathFollowSpeed(TRIGGER._6_02G_VASE03, 8)
	TextPrintString("Greaser: Hey it's Jimmy, Johnny's going to like this...", 4, 2)
	PedSetActionNode(pedGreaser04.id, "/Global/6_02GDORM/Anims/Empty", "Act/Conv/6_02gdorm.act")
	PedSetEffectedByGravity(pedGreaser04.id, true)
	PedAttackPlayer(pedGreaser04.id, 3)
	F_SpawnGirl(2)
	--print("()xxxxx[:::::::::::::::> [finish] F_LivingRoomAttack()")
end

function F_NortonAttack()
	--print("()xxxxx[:::::::::::::::> [start] F_NortonAttack()")
	TextPrintString("Norton: You got some nerve showing up here...", 4, 2)
	threadMonitorNorton = CreateThread("T_MonitorNorton")
	PedSetActionNode(pedNorton.id, "/Global/6_02GDORM/Anims/Empty", "Act/Conv/6_02gdorm.act")
	PedAttackPlayer(pedNorton.id, 3)
	F_SpawnGirl(3)
	--print("()xxxxx[:::::::::::::::> [finish] F_NortonAttack()")
end

function F_CutJohnny()
	--print("()xxxxx[:::::::::::::::> [start] F_CutJohnny()")
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	PedSetActionNode(pedJohnny.id, "/Global/6_02GDORM/Anims/Empty", "Act/Conv/6_02gdorm.act")
	PedSetActionNode(pedMandy.id, "/Global/6_02GDORM/Anims/Empty", "Act/Conv/6_02gdorm.act")
	PedFaceObject(pedJohnny.id, gPlayer, 3, 1)
	PedFaceObject(pedMandy.id, gPlayer, 3, 1)
	PedFaceObject(gPlayer, pedJohnny.id, 2, 1)
	TextPrintString("Jimmy: What's going on in here loverboy?", 4, 2)
	Wait(4000)
	TextPrintString("Johnny: Oh man... Don't tell Lola, I'll do whatever you want.", 4, 2)
	Wait(4000)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	bMissionPassed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_CutJohnny()")
end

function F_NortonSmash()
	--print("()xxxxx[:::::::::::::::> [start] F_NortonSmash()")
	EffectCreate("CeilingDust", dustX, dustY, dustZ)
	SoundPlay3D(thumpX, thumpY, thumpZ, "InTble_HitLrg")
	--print("()xxxxx[:::::::::::::::> [finish] F_NortonSmash()")
end

function F_FireVase02()
	--print("()xxxxx[:::::::::::::::> [start] F_FireVase02()")
	PAnimFollowPath(TRIGGER._6_02G_VASE02, PATH._6_02G_VASE02, false, F_prouteVase02)
	PAnimSetPathFollowSpeed(TRIGGER._6_02G_VASE02, 8)
	--print("()xxxxx[:::::::::::::::> [finish] F_FireVase02()")
end

function F_FireVase03()
	--print("()xxxxx[:::::::::::::::> [start] F_FireVase03()")
	PAnimFollowPath(TRIGGER._6_02G_VASE03, PATH._6_02G_VASE03, false, F_prouteVase03)
	PAnimSetPathFollowSpeed(TRIGGER._6_02G_VASE03, 9)
	--print("()xxxxx[:::::::::::::::> [finish] F_FireVase03()")
end

function F_RandomGlassSound()
	--print("()xxxxx[:::::::::::::::> [start] F_RandomGlassSound()")
	SoundPlay2D(tableGlassSound[math.random(1, table.getn(tableGlassSound))])
	--print("()xxxxx[:::::::::::::::> [finish] F_RandomGlassSound()")
end

function F_SpawnGirl(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_SpawnGirl()")
	if pedID == 1 then
		tempGirl01 = PedCreatePoint(tableRandomGirl[math.random(1, table.getn(tableRandomGirl))], POINTLIST._6_02G_SPAWNGIRL, 1)
		PedFollowPath(tempGirl01, PATH._6_02G_GIRLFLEE, 0, 1, F_GirlFlee)
	elseif pedID == 2 then
		tempGirl02 = PedCreatePoint(tableRandomGirl[math.random(1, table.getn(tableRandomGirl))], POINTLIST._6_02G_SPAWNGIRL, 1)
		PedFollowPath(tempGirl02, PATH._6_02G_GIRLFLEE, 0, 1, F_GirlFlee)
	elseif pedID == 3 then
		tempGirl03 = PedCreatePoint(tableRandomGirl[math.random(1, table.getn(tableRandomGirl))], POINTLIST._6_02G_SPAWNGIRL, 1)
		PedFollowPath(tempGirl03, PATH._6_02G_GIRLFLEE, 0, 1, F_GirlFlee)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_SpawnGirl()")
end

function T_MonitorGreaser02()
	while bLoop do
		if PedIsInCombat(pedGreaser01.id) then
			break
		end
		if PedIsHit(pedGreaser02.id, 2, 1000) and PedGetWhoHitMeLast(pedGreaser02.id) == gPlayer then
			TextPrintString("Greaser: What the hell!", 4, 2)
			PedSetActionNode(pedGreaser01.id, "/Global/6_02GDORM/Anims/Empty", "Act/Conv/6_02gdorm.act")
			PedAttackPlayer(pedGreaser01.id, 3)
			break
		end
		Wait(0)
	end
end

function T_MonitorNorton()
	while bLoop do
		if PedIsDead(pedNorton.id) then
			PAnimOpenDoor(TRIGGER._GDORM_UPPERDOOR)
			pedJohnny.blip = AddBlipForChar(pedJohnny.id, 4, 0, 4)
			break
		end
		Wait(0)
	end
end

function F_prouteVase01(propID, pathID, nodeID)
	if nodeID == 4 then
		PAnimApplyDamage(TRIGGER._6_02G_VASE01, 100)
		SoundPlay2D("PlateBreakLarge")
	end
end

function F_prouteVase02(propID, pathID, nodeID)
	if nodeID == 4 then
		PAnimApplyDamage(TRIGGER._6_02G_VASE02, 100)
		SoundPlay2D("PlateBreakLarge")
	end
end

function F_prouteVase03(propID, pathID, nodeID)
	if nodeID == 4 then
		PAnimApplyDamage(TRIGGER._6_02G_VASE03, 100)
		SoundPlay2D("PlateBreakLarge")
	end
end

function F_routeLaundry(pedID, pathID, nodeID)
	if nodeID == 3 then
		if pedID == pedGreaser02.id then
			F_RandomGlassSound()
			PedAttackPlayer(pedID, 3)
		else
			F_RandomGlassSound()
			bSetGreaser3OnPath = true
		end
	end
end

function F_GirlFlee(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_GirlFlee() @ node : " .. nodeID)
	if pedID == tempGirl01 or pedID == tempGirl02 then
		F_RandomGlassSound()
	end
	if nodeID == 8 then
		if pedID == tempGirl01 then
			--print("()xxxxx[:::::::::::::::> Delete Girl 01")
			bDeleteGirl01 = true
		elseif pedID == tempGirl02 then
			--print("()xxxxx[:::::::::::::::> Delete Girl 02")
			bDeleteGirl02 = true
		elseif pedID == tempGirl03 then
			--print("()xxxxx[:::::::::::::::> Delete Girl 03")
			bDeleteGirl03 = true
		end
	end
end
