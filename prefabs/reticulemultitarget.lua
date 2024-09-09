local willow_ember_common = require("prefabs/willow_ember_common")

local assets =
{
    Asset("ANIM", "anim/reticuleaoe.zip"),
}

local prefabs = 
{
    "reticulemultitargetsub",
}

local PAD_DURATION = .1
local SCALE = 1.5
local FLASH_TIME = .3

local function onremove(inst)
    if inst._targets then
        for i,target in ipairs(inst._targets)do
            target:Remove()
        end
    end
    inst._targets = nil
end

local function OnUpdate(inst, dt)
    if inst._targets then
        onremove(inst)
    end

    if ThePlayer then
        local ents = willow_ember_common.GetBurstTargets(ThePlayer)

        if ents ~= nil then
            for i, ent in ipairs(ents) do
                if not inst._targets then
                    inst._targets = {}
                end

                local newfx = SpawnPrefab("reticulemultitargetsub")
                ent:AddChild(newfx)
                table.insert(inst._targets,newfx)
            end
        end
    end
end

local function UpdatePing(inst, s0, s1, t0, duration, multcolour, addcolour)
    if next(multcolour) == nil then
        multcolour[1], multcolour[2], multcolour[3], multcolour[4] = inst.AnimState:GetMultColour()
    end
    if next(addcolour) == nil then
        addcolour[1], addcolour[2], addcolour[3], addcolour[4] = inst.AnimState:GetAddColour()
    end
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - PAD_DURATION) / duration
    k = 1 - k * k
    local c = Lerp(1, 0, k)
    inst.AnimState:SetScale(SCALE * Lerp(s0[1], s1[1], k), SCALE * Lerp(s0[2], s1[2], k))
    inst.AnimState:SetMultColour(multcolour[1], multcolour[2], multcolour[3], c * multcolour[4])

    k = math.min(FLASH_TIME, t) / FLASH_TIME
    c = math.max(0, 1 - k * k)
    inst.AnimState:SetAddColour(c * addcolour[1], c * addcolour[2], c * addcolour[3], c * addcolour[4])
end

local function pingfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()


    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleaoe")
    inst.AnimState:SetBuild("reticuleaoe")
    inst.AnimState:PlayAnimation("idle_1d2_12")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.15, 1.15)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    local duration = .4
    inst:DoPeriodicTask(0, UpdatePing, nil, { 1, 1 }, { 1.04, 1.25 }, GetTime(), duration, {}, {})
    inst:DoTaskInTime(duration + PAD_DURATION, inst.Remove)

    return inst
end

local function main()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleaoe")
    inst.AnimState:SetBuild("reticuleaoe")
    inst.AnimState:PlayAnimation("idle_1d2_12")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.15, 1.15)
    inst:Hide()
    
    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(OnUpdate)

    inst:ListenForEvent( "onremove", onremove )

    return inst
end

local function sub()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleaoe")
    inst.AnimState:SetBuild("reticuleaoe")
    inst.AnimState:PlayAnimation("idle_target_1")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    --inst.AnimState:SetScale(SCALE, SCALE)

    return inst
end


return Prefab("reticulemultitarget", main, assets, prefabs),
       Prefab("reticulemultitargetsub", sub, assets, prefabs),
       Prefab("reticulemultitargetping", pingfn, assets, prefabs)
