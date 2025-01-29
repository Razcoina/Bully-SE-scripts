function F_ChangeGateState(GateHashID, overrideVariable, overrideOpen, openRuleFunction)
    shouldChangeState = false
    openDoor = false
    doorIsOpen = AreaIsDoorOpen(GateHashID)
    if doorIsOpen then
        if overrideVariable == true then
            if overrideOpen == false then
                shouldChangeState = true
                openDoor = false
            end
        else
            shouldBeClosed = false
            if openRuleFunction ~= nil then
                shouldBeClosed = not openRuleFunction()
            end
            if shouldBeClosed == true then
                shouldChangeState = true
                openDoor = false
            end
        end
    elseif overrideVariable == true then
        if overrideOpen == true then
            shouldChangeState = true
            openDoor = true
        end
    else
        shouldBeOpen = false
        if openRuleFunction ~= nil then
            shouldBeOpen = openRuleFunction()
        end
        if shouldBeOpened == true then
            shouldChangeState = true
            openDoor = true
        end
    end
    if shouldChangeState == true then
        AreaSetDoorOpen(GateHashID, openDoor)
        lock = false
        if openDoor == true then
            lock = false
        else
            lock = true
        end
        AreaSetDoorLocked(GateHashID, lock)
        AreaSetDoorLockedToPeds(GateHashID, lock)
        return lock
    end
end
