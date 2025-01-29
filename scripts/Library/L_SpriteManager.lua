gSpriteLayerTable = {}
removeX, removeY = 1000, 1000

function SpriteManagerAllocateSIDS(spriteMax, lid, cbUpdate, cbCollision)
    local cbU = cbUpdate or __cbNoUpdate
    local cbC = cbCollision or __cbNoCollision
    gSpriteLayerTable[lid] = {}
    local spriteTable = gSpriteLayerTable[lid]
    for i = 1, spriteMax do
        local sid = MGArcade_Layer_AddSprite(lid, cbU, cbC)
        MGArcade_Sprite_SetVisible(lid, sid, false)
        MGArcade_Sprite_SetVel(lid, sid, 0, 0)
        MGArcade_Sprite_SetAcc(lid, sid, 0, 0)
        MGArcade_Sprite_SetPos(lid, sid, removeX, removeY)
        spriteTable[sid] = {}
        spriteTable[sid].bParked = true
        spriteTable[sid].sid = sid
    end
end

function SpriteManagerNextSID(lid)
    local sid
    local spriteTable = SpriteManagerGetSpriteTable(lid)
    if not spriteTable then
        return nil
    end
    for _, e in spriteTable do
        if e.bParked then
            sid = e.sid
            e.bParked = false
            break
        end
    end
    return sid
end

function SpriteManagerReuseSID(lid, sid)
    local spriteTable = SpriteManagerGetSpriteTable(lid)
    if not spriteTable then
        return nil
    end
    spriteTable[sid].bParked = true
end

function SpriteManagerIsGoodSprite(lid, sid)
    local spriteTable = SpriteManagerGetSpriteTable(lid)
    if not spriteTable then
        return nil
    end
    if spriteTable[sid] == nil then
        return false
    end
    return not spriteTable[sid].bParked
end

function SpriteManagerGetSpriteTable(lid)
    if not gSpriteLayerTable[lid] then
        return nil
    end
    return gSpriteLayerTable[lid]
end

function __cbNoUpdate(dt, lid, sid)
end

function __cbNoCollision(lid, sid, clid, csid)
end
