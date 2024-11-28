function main()
  DATLoad("SP_BMXTrack.DAT", 0)
  DATLoad("tBMX.DAT", 0)
  DATLoad("BMXBikes.DAT", 0)
  F_PreDATInit()
  DATInit()
  shared.gAreaDATFileLoaded[62] = true
  shared.gAreaDataLoaded = true
  if IsMissionCompleated("3_02") then
    F_Bikes()
    while AreaGetVisible() == 62 and not SystemShouldEndScript() do
      Wait(0)
    end
  end
  AreaRevertToDefaultPopulation()
  DATUnload(0)
  shared.gAreaDataLoaded = false
  shared.gAreaDATFileLoaded[62] = false
  collectgarbage()
end
function F_Bikes()
  local numBikers = math.random(1, 3)
  local x, y, z = 0, 0, 0
  for count = 1, numBikers do
    x, y, z = GetPointFromPointList(POINTLIST._BMXBIKERS, count)
    local biker = GetStudent(4, 1, -1)
    if biker > 0 then
      while not PedRequestModel(biker) do
        Wait(0)
      end
      bike = RandomTableElement({
        279,
        282,
        274
      })
      while not VehicleRequestModel(bike, true) do
        Wait(0)
      end
      local ride = VehicleCreateXYZ(bike, x, y, z)
      local rider = PedCreateXYZ(biker, x, y, z + 1)
      PedWander(rider, 0)
      VehicleSetOwner(ride, rider)
      PedPutOnBike(rider, ride)
      PedOverrideStat(rider, 24, 70)
    end
  end
end
