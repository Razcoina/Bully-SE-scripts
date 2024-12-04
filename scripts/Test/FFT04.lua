local L0_1, L1_1
L0_1 = ImportScript
L1_1 = "\\Library\\LibTable.lua"
L0_1(L1_1)
L0_1 = ImportScript
L1_1 = "\\Library\\LibPed.lua"
L0_1(L1_1)
L0_1 = false

function L1_1()
  local L0_2, L1_2, L2_2
  L0_2 = DATLoad
  L1_2 = "TFIGHT01.DAT"
  L2_2 = 2
  L0_2(L1_2, L2_2)
  L0_2 = DATInit
  L0_2()
  L0_2 = PlayerSetHealth
  L1_2 = 200
  L0_2(L1_2)
  L0_2 = AreaTransitionPoint
  L1_2 = 22
  L2_2 = POINTLIST
  L2_2 = L2_2._TFIGHT01_C
  L0_2(L1_2, L2_2)
  L0_2 = EnemyCreate
  L0_2()
end

MissionSetup = L1_1

function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L0_2 = L_PedLoadPoint
  L1_2 = nil
  L2_2 = {}
  L3_2 = {}
  L3_2.model = 30
  L4_2 = POINTLIST
  L4_2 = L4_2._TFIGHT01_NE_01
  L3_2.point = L4_2
  L4_2 = {}
  L4_2.model = 31
  L5_2 = POINTLIST
  L5_2 = L5_2._TFIGHT01_E_01
  L4_2.point = L5_2
  L5_2 = {}
  L5_2.model = 32
  L6_2 = POINTLIST
  L6_2 = L6_2._TFIGHT01_SE_01
  L5_2.point = L6_2
  L6_2 = {}
  L6_2.model = 34
  L7_2 = POINTLIST
  L7_2 = L7_2._TFIGHT01_W_01
  L6_2.point = L7_2
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L0_2(L1_2, L2_2)
end

EnemyCreate = L1_1

function L1_1()
  local L0_2, L1_2
  L0_2 = DATUnload
  L1_2 = 2
  L0_2(L1_2)
end

MissionCleanup = L1_1

function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = L_PedExec
  L1_2 = nil
  L2_2 = PedAttack
  L3_2 = "id"
  L4_2 = gPlayer
  L0_2(L1_2, L2_2, L3_2, L4_2)
  goto lbl_17
  repeat
    L0_2 = L_PedAllDead
    L0_2 = L0_2()
    if L0_2 then
      L0_2 = true
      L0_1 = L0_2
    end
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
    ::lbl_17::
    L0_2 = L0_1
    L1_2 = false
  until L0_2 ~= L1_2
  L0_2 = Wait
  L1_2 = 3000
  L0_2(L1_2)
  L0_2 = MissionSucceed
  L0_2()
end

main = L1_1
