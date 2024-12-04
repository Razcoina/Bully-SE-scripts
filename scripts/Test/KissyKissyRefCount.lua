function MissionSetup()
end

function MissionCleanup()
end

function main()
	--print("=====================> MAIN LOOPAGE!")
	DATLoad("KissyKissyRefCount.DAT", 2)
	DATInit()
	AreaTransitionPoint(22, POINTLIST._KISSYKISSY, 1)
	local ped1, ped2
	ped1 = PedGetRandomModelId(2, 1, 1)
	ped2 = PedGetRandomModelId(6, 2, 1)
	LoadPedModels({ ped1, ped2 })
	local Boy = PedCreatePoint(ped1, POINTLIST._KISSYKISSY, 2)
	local Girl = PedCreatePoint(ped2, POINTLIST._KISSYKISSY, 3)
	PedFaceObject(Boy, Girl, 2, 1)
	PedFaceObject(Girl, Boy, 2, 1)
	PedAddPedToIgnoreList(Girl, Boy)
	PedAddPedToIgnoreList(Boy, Girl)
	PedLockTarget(Boy, Girl)
	PedLockTarget(Girl, Boy)
	ExecuteAnimationSequence(Boy, "/Global/RefCounting/Kiss_Me_Baby", "Act/Anim/RefCountTest.act")
	PedWander(Boy, 0)
	PedWander(Girl, 0)
	DATUnload(2)
	Wait(10000)
	MissionSucceed()
end

function ExecuteAnimationSequence(ped, actionNode, fileName)
	while true do
		Wait(0)
		if not PedIsDead(ped) and not PedIsPlaying(ped, actionNode, true) then
			PedSetActionNode(ped, actionNode, fileName)
		elseif true then
			break
		else
			break
		end
	end
end
