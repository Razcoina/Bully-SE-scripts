ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPropNewer.lua")
local tblProp

function F_TableInit()
	tblProp = {
		{
			id = TRIGGER._MB01
		},
		{
			id = TRIGGER._MB02
		},
		{
			id = TRIGGER._MB03
		},
		{
			id = TRIGGER._MB04
		},
		{
			id = TRIGGER._MB05
		},
		{
			id = TRIGGER._MB06
		},
		{
			id = TRIGGER._MB07
		},
		{
			id = TRIGGER._MB08
		},
		{
			id = TRIGGER._MB09
		},
		{
			id = TRIGGER._MB10
		},
		{
			id = TRIGGER._MB11
		},
		{
			id = TRIGGER._MB12
		}
	}
end

function F_PropTestOnBroken(hash_id, trigger_id)
	--print("ON BROKEN EVENT RAISED: hash_id=" .. tostring(hash_id) .. ",trigger_id=" .. tostring(trigger_id))
end

function F_PropTestOnUsed(hash_id, trigger_id)
	--print("ON USED EVENT RAISED: hash_id=" .. tostring(hash_id) .. ",trigger_id=" .. tostring(trigger_id))
end

function MissionSetup()
	DATLoad("TestPropEvents.DAT", 2)
	DATInit()
	F_TableInit()
	AreaTransitionPoint(62, POINTLIST._PLAYER)
	VehicleCreatePoint(273, POINTLIST._PLAYERBIKE)
	PedSetWeaponNow(gPlayer, 300, 0)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	L_PropLoad("test", tblProp)
	while true do
		LF_PropMonitor()
		Wait(0)
	end
end
