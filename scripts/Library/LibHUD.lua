local tblCounterDefault = {
    start = 0,
    max = 10,
    displayMax = true
}
local tblCharBlipDefault = { blipStyle = 1, radarIcon = 2 }
local tblPropBlipDefault = { blipStyle = 1, radarIcon = 0 }
local tblPickupBlipDefault = { blipStyle = 1, radarIcon = 0 }
local tblCarBlipDefault = { blipStyle = 1, radarIcon = 0 }
local tblXYZBlipDefault = { blipStyle = 1, radarIcon = 0 }

function L_HUDBlipSetup()
    LT_TypeFunction("_Ped", L_HUDBlipAddChar, "element")
    LT_TypeFunction("_Prp", L_HUDBlipAddProp, "element")
    LT_TypeFunction("_Car", L_HUDBlipAddCar, "element")
    LT_TypeFunction("_Tag", L_HUDBlipAddXYZ, "element")
end

function L_HUDBlipRemove(element)
    if element.blip then
        BlipRemove(element.blip)
        element.blip = nil
    end
end

function L_HUDBlipAddCar(element)
    --assert(element.id ~= nil, "LibHUD Error: tried to set blip on char with no id")
    if element.blipStyle or element.radarIcon then
        L_HUDBlipRemove(element)
        element.blip = AddBlipForCar(element.id, element.radarIcon or tblCarBlipDefault.radarIcon, element.blipStyle, tblCarBlipDefault.blipStyle)
    end
end

function L_HUDBlipAddChar(element)
    --assert(element.id ~= nil, "LibHUD Error: tried to set blip on char with no id")
    if element.blipStyle or element.radarIcon then
        L_HUDBlipRemove(element)
        element.blip = AddBlipForChar(element.id, 2, element.radarIcon or tblCharBlipDefault.radarIcon, element.blipStyle or tblCharBlipDefault.blipStyle)
    end
end

function L_HUDBlipAddProp(element)
    --assert(element.id ~= nil, "LibHUD Error: tried to set blip on prop with no id")
    if element.blipStyle or element.radarIcon then
        L_HUDBlipRemove(element)
        element.blip = AddBlipForProp(element.id, element.radarIcon or tblPropBlipDefault.radarIcon, element.blipStyle or tblPropBlipDefault.blipStyle)
    end
end

function L_HUDBlipAddPickup(element)
    --assert(element.id ~= nil, "LibHUD Error: tried to set blip on pickup with no id")
    if element.blipStyle or element.radarIcon then
        L_HUDBlipRemove(element)
        element.blip = AddBlipForPickup(element.id, element.radarIcon or tblPropBlipDefault.radarIcon, element.blipStyle or tblPropBlipDefault.blipStyle)
    end
end

function L_HUDBlipCleanup()
    LT_TypeFunction("_Ped", L_HUDBlipRemove, "element")
    LT_TypeFunction("_Prp", L_HUDBlipRemove, "element")
    LT_TypeFunction("_Car", L_HUDBlipRemove, "element")
    LT_TypeFunction("_Tag", L_HUDBlipRemove, "element")
    LT_TypeFunction("_Pkp", L_HUDBlipRemove, "element")
end

function L_HUDShowPaper()
    NewspaperSetPaperVisible(true)
end

function L_HUDHidePaper()
    NewspaperSetPaperVisible(false)
end

function L_HUDCounterLoad(counter)
    --assert(counter.icon ~= nil, "ERROR - LibHUD: Tried to load custom counter without providing icon name")
    CounterSetIcon(counter.icon, counter.icon .. "_x")
    --print("L_HUDCounterLoad: second argument is " .. tostring(counter.displayMax or tblCounterDefault.displayMax))
    CounterMakeHUDVisible(true, F_GetDefault(counter.displayMax, tblCounterDefault.displayMax))
    CounterSetMax(counter.max or tblCounterDefault.max)
    CounterSetCurrent(counter.start or tblCounterDefault.start)
end

function L_HUDCounterCleanup()
    CounterMakeHUDVisible(false)
    CounterSetCurrent(0)
    CounterSetMax(0)
end

function L_HUDBlipAddXYZ(element)
    if element.blip == nil and element.x and element.y and element.z then
        element.blip = BlipAddXYZ(element.x, element.y, element.z, element.radarIcon or tblXYZBlipDefault.radarIcon, element.blipStyle or tblXYZBlipDefault.blipStyle)
    end
end

function F_GetDefault(value, default)
    if value ~= nil then
        return value
    end
    return default
end
