local FISH_DATA = require("prefabs/oceanfishdef")

local function AddMember(inst, member)
    member._schoolherd_entitysleep = function() inst.checkforremoval(inst) end
    inst:ListenForEvent("entitysleep", member._schoolherd_entitysleep, member)
end


local function RemoveMember(inst, member)
    if member._schoolherd_entitysleep then
        inst:RemoveEventCallback("entitysleep", member._schoolherd_entitysleep, member)
        member._schoolherd_entitysleep = nil
    end
end

local function _OnUpdate(inst, self)
    inst.components.herd:OnUpdate()
end

local function updateposfn(inst)

    local data = FISH_DATA.fish[inst.fishprefab]

    if data and not inst.delaying then
        -- this is the check for if the nav point should change to the next
        local dist = data and data.herdarrivedist or 8
        for k,v in pairs(inst.components.herd.members)do
            if inst:GetDistanceSqToInst(k) < dist then
                inst.delaying = true
                break
            end
        end

        if inst.delaying then
            local time = data.herdwanderdelaymin + (math.random() * (data.herdwanderdelaymax - data.herdwanderdelaymin))
            inst:DoTaskInTime(time, function(inst)
                inst.delaying = nil
                inst.currentnav = inst.currentnav + 1
                if not inst.components.knownlocations:GetLocation("nav".. inst.currentnav) then
                    inst.currentnav = 1
                end
            end)
        end
    end

    local currentpos = inst.components.knownlocations:GetLocation("nav".. inst.currentnav) or inst.components.knownlocations:GetLocation("nav1")
    for k, v in pairs(inst.components.herd.members)do
        local angle = math.random() * 2 * PI
        local dist = math.sqrt(math.random()) * 8
        local herd_offset = Vector3(currentpos.x + math.cos(angle) * dist, currentpos.y, currentpos.z + math.sin(angle) * dist)
        k.components.knownlocations:RememberLocation("herd_offset", herd_offset )
    end

    return currentpos
end

local function setupnavs(inst)
    local data = FISH_DATA.fish[inst.fishprefab]
    if not inst.components.knownlocations:GetLocation("nav1") then
        local origin = inst:GetPosition()
        inst.components.knownlocations:RememberLocation("nav1", origin)

        local total = 6
        for i = 2, total do
            local triesmax = 36
            if i == 4 then
                inst.components.knownlocations:RememberLocation("nav"..i, origin)
            else
                local dist = math.sqrt(math.random())*(data and data.herdwandermin or 15) + (data and (data.herdwandermax - data.herdwandermin) or 15)
                local swim_offset = FindSwimmableOffset(origin, math.random()*PI*2, dist, triesmax, true, nil, nil, true)
                if swim_offset then
                    inst.components.knownlocations:RememberLocation("nav"..i, Vector3(origin.x + swim_offset.x, 0, origin.z + swim_offset.z))
                end
            end
        end

        inst.currentnav = 2
    end

    if not inst.components.timer:TimerExists("lifetime") then
        inst.components.timer:StartTimer("lifetime", data.schoollifetimemin + (math.random()*(data.schoollifetimemax-data.schoollifetimemin)))
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

local function checkforremoval(inst)
    local remove = true
    for k,v in pairs(inst.components.herd.members)do
        if k.entity:IsAwake() then

            remove = false
            break
        end
    end
    if remove then
--        print("ALL SCHOOL FISH IN ENTITY SLEEP: REMOVE SCHOOL HERD")
        for k,v in pairs(inst.components.herd.members)do
            k:Remove()
        end
        inst:Remove()
    end
end

local function OnTimerDone(inst,data)
    if data.name == "lifetime" then
        for k,v in pairs(inst.components.herd.members)do
            k:PushEvent("doleave")
        end
        inst:Remove()
    end
end

local function fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst:AddComponent("herd")

    inst.components.herd:SetMemberTag("herd_"..data.prefab)

    inst.components.herd:SetGatherRange(10)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(inst.Remove)
    inst.components.herd:SetAddMemberFn(AddMember)
    inst.components.herd:SetRemoveMemberFn(RemoveMember)

    inst.components.herd.updateposfn = updateposfn

    inst:AddComponent("knownlocations")

    inst:AddComponent("timer")

    inst.checkforremoval = checkforremoval
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.fishprefab = data.prefab

   -- inst:DoPeriodicTask(10, function(inst) checkforremoval(inst) end)

    inst:DoTaskInTime(0,function(inst) setupnavs(inst) end)

    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

local school_prefabs = {}

local function makeschool(data)
    local prefabs = {data.prefab}
    table.insert(school_prefabs, Prefab("schoolherd_"..data.prefab, function() return fn(data) end, nil, prefabs) )
    return
end

for _, school_def in pairs(FISH_DATA.fish) do
    makeschool(school_def)
end

return unpack(school_prefabs)
