function F_InitGarages()
	DATLoad("Garages.DAT", 1)
	GarageClearAll()
	GarageAdd(TRIGGER._Garage_SchoolGrounds, POINTLIST._Garage_SchoolGrounds)
	GarageAdd(TRIGGER._Garage_RichArea, POINTLIST._Garage_RichArea)
	GarageAdd(TRIGGER._Garage_BusinessArea, POINTLIST._Garage_BusinessArea)
	GarageAdd(TRIGGER._Garage_PoorArea, POINTLIST._Garage_PoorArea)
end
