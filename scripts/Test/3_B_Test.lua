ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
local johnny
local pattern = 1

function MissionSetup()
	DATLoad("3_B.DAT", 2)
	DATLoad("3_B_BIKE_STUFF.DAT", 2)
	DATLoad("3_B_EXTRA.DAT", 2)
	DATInit()
	PlayerSetHealth(200)
	AreaTransitionPoint(43, POINTLIST._3_B_STAGE3_PLAYER_START)
	WeatherSet(2)
	EnemyCreate()
end

function EnemyCreate()
	L_PedLoadPoint(nil, {
		{
			model = 23,
			point = POINTLIST._3_B_JV_STAGE3_SPAWN
		}
	})
	johnny = L_PedGetIDByIndex(nil, 1)
	PedSetCombatZoneMask(johnny, true, false, false)
end

function MissionCleanup()
	WeatherRelease()
	PedSetAIButes("Default")
	DATUnload(2)
	CameraAllowChange(true)
	CameraReturnToPlayer()
	PlayerIgnoreTargeting(false)
end

function ToggleAttackPattern()
end

local function MudKickingPattern()
	while true do
		if PedIsDead(johnny) == false and (PedIsPlaying(gPlayer, "/Global/HitTree/Standing/PostHit/BellyUp", true) or PedIsPlaying(gPlayer, "/Global/HitTree/Standing/PostHit/BellyDown", true)) or pattern == 2 then
			ToggleAttackPattern()
			if pattern == 2 then
				Wait(5000)
			elseif pattern == 1 then
				Wait(10000)
			end
		end
		Wait(0)
	end
end

function main()
	PedSetAIButes("3_B")
	PedLockTarget(gPlayer, johnny)
	PedLockTarget(johnny, gPlayer)
	FollowCamSetFightShot("1_B_X")
	CameraSetShot(1, "1_B_X", false)
	PlayerIgnoreTargeting(true)
	CameraAllowChange(false)
	L_PedExec(nil, PedAttack, "id", gPlayer)
	CreateThread("MudKickingPattern")
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(3000)
	MissionSucceed()
end
