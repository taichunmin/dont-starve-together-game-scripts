local function OnCancelFocus(inst)
    inst.task = nil
    inst.target = nil
    TheCamera:SetDefaultOffset()
end

local function OnClearFocusPriority(inst)
    inst.task = inst:DoTaskInTime(0, OnCancelFocus)
    inst.priority = nil
    inst.prioritydistsq = nil
end

local function PushTempFocus(inst, target, minrange, maxrange, priority)
    if target == inst.target or inst.priority == nil or priority >= inst.priority then
        local parent = inst.entity:GetParent()
        if parent ~= nil then
            local tpos = target:GetPosition()
            local ppos = parent:GetPosition()
            local distsq = distsq(tpos, ppos) --3d distance
            if distsq < (priority == inst.priority and math.min(inst.prioritydistsq, maxrange * maxrange) or maxrange * maxrange) then
                local offs = tpos - ppos
                if distsq > minrange * minrange then
                    offs = offs * (maxrange - math.sqrt(distsq)) / (maxrange - minrange)
                end
                offs.y = offs.y + 1.5
                TheCamera:SetOffset(offs)

                if inst.task ~= nil then
                    inst.task:Cancel()
                end
                inst.task = inst:DoTaskInTime(0, OnClearFocusPriority)
                inst.target = target
                inst.priority = priority
                inst.prioritydistsq = distsq
            end
        end
    end
end

local function AttachToEntity(inst, entity)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.target = nil
        inst.priority = nil
        inst.prioritydistsq = nil
    end
    inst.entity:SetParent(entity)
    TheCamera:SetDefault()
    TheCamera:Snap()
end

local function fn()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.persists = false

    inst:ListenForEvent("playeractivated", function(world, player) AttachToEntity(inst, player.entity) end, TheWorld)
    inst:ListenForEvent("playerdeactivated", function() AttachToEntity(inst, nil) end, TheWorld)

    inst.task = nil
    inst.target = nil
    inst.priority = nil
    inst.prioritydistsq = nil
    inst.PushTempFocus = PushTempFocus

    return inst
end

return Prefab("focalpoint", fn)