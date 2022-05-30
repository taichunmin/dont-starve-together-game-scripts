local prefabs =
{
    "squid",
}

local function AddMember(inst, member)
    member._squidherd_entitysleep = function() inst.checkforremoval(inst) end
    inst:ListenForEvent("entitysleep", member._squidherd_entitysleep, member)
end

local function RemoveMember(inst, member)
    if member._squidherd_entitysleep then
        inst:RemoveEventCallback("entitysleep", member._squidherd_entitysleep, member)
        member._squidherd_entitysleep = nil
    end
end

local function _OnUpdate(inst, self)
    inst.components.herd:OnUpdate()
end

local function updateposfn(inst)

    local DIST = 20
    local move = true

    for k,v in pairs(inst.components.herd.members)do
        if inst:GetDistanceSqToInst(k) > DIST * DIST then
            move = false
            break
        end
    end

    if move then
        inst.currentnav = inst.currentnav + 1
        if not inst.components.knownlocations:GetLocation("nav".. inst.currentnav) then
            inst.currentnav = 1
        end
    end

    local currentpos = inst.components.knownlocations:GetLocation("nav".. inst.currentnav)

    for k,v in pairs(inst.components.herd.members)do
        local angle = math.random()*2*PI
        local dist = math.sqrt(math.random())* 4
        local offsetx = math.cos(angle) * dist
        local offsetz = math.sin(angle) * dist
        local herd_offset = Vector3(currentpos.x+offsetx,currentpos.y,currentpos.z+offsetz)

        k.components.knownlocations:RememberLocation("herd_offset", herd_offset )
    end

    return currentpos
end

local function setupnavs(inst)
    if not inst.components.knownlocations:GetLocation("nav1") then
        inst.components.knownlocations:RememberLocation("nav1", Vector3(inst.Transform:GetWorldPosition()) )

local total = 1

        local total = 6
        local radiusMax = 100
        for i=1,total -1 do
            local loop = true
            local tries = 0
            local triesmax = 36
            local angle = math.random()*2*PI
            local dist = math.sqrt(math.random())*radiusMax + 50
            while loop == true do
                if i == 3 then
                    inst.components.knownlocations:RememberLocation("nav"..i, Vector3(inst.Transform:GetWorldPosition()) )
                    loop = false
                else
                    local origin = inst.components.knownlocations:GetLocation("nav1")
                    angle = angle + ( (2*PI/triesmax) * tries)
                    local offsetx = math.cos(angle) * dist
                    local offsetz = math.sin(angle) * dist
                    local water = not TheWorld.Map:IsVisualGroundAtPoint(origin.x + offsetx,0, origin.z + offsetz) and TheWorld.Map:IsValidTileAtPoint(origin.x + offsetx,0, origin.z + offsetz)
                    if water then
                        inst.components.knownlocations:RememberLocation("nav"..i, Vector3(origin.x + offsetx,0, origin.z + offsetz ) )
                        loop = false
                    else
                        tries = tries + 1
                        if tries > triesmax then
                            loop = false
                        end
                    end
                end
            end
        end

        --[[
        for i=1,total do
            local pos = inst.components.knownlocations:GetLocation("nav"..i)
            if pos then
                local thing = SpawnPrefab("manrabbit_tail")
                thing.Transform:SetPosition(pos.x ,pos.y,pos.z)
            end
        end
        ]]

        inst.currentnav = 1
    end
end

local function checkforremoval(inst)
    local remove = true
    for k,v in pairs(inst.components.herd.members)do
        if k.entity:IsAwake() or (k:IsValid() and not k:IsOnOcean()) then

            remove = false
            break
        end
    end
    if remove then
        for k,v in pairs(inst.components.herd.members)do
            k:Remove()
        end
        inst:Remove()
    end
end

local function OnSave(inst, data)
    if inst.currentnav then
        data.currentnav = inst.currentnav
    end
end

local function OnLoad(inst, data)
    if data then
        if data.currentnav then
            inst.currentnav = data.currentnav
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst:AddComponent("herd")
    if inst:HasTag("migratory") then
        inst.components.herd:SetMemberTag("squid_migratory")
    else
        inst.components.herd:SetMemberTag("squid")
    end
    inst.components.herd:SetGatherRange(TUNING.BEEFALOHERD_RANGE)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(inst.Remove)
    inst.components.herd:SetAddMemberFn(AddMember)
    inst.components.herd:SetRemoveMemberFn(RemoveMember)
    inst.components.herd.updateposfn = updateposfn

    inst:AddComponent("knownlocations")
    --inst.components.herd.task:Cancel()
    --inst.components.herd.task = inst:DoPeriodicTask(1, _OnUpdate, nil,  inst.components.herd)

    inst.checkforremoval = checkforremoval
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad


    inst:DoTaskInTime(0,function(inst) setupnavs(inst) end)

    return inst
end

return Prefab("squidherd", fn, nil, prefabs)
