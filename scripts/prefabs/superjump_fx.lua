local assets =
{
    Asset("ANIM", "anim/player_superjump.zip"),
}

local prefabs =
{
    "superjump_debris",
}

local function OnInit(inst)
    inst.inittask = nil
    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = .4 })
end

local function SetTarget(inst, target, distance)
    local x, y, z = target.Transform:GetWorldPosition()
    local rot = target.Transform:GetRotation()
    if distance ~= nil then
        local theta = rot * DEGREES
        x = x + distance * math.cos(theta)
        z = z - distance * math.sin(theta)
    end

    inst.Transform:SetPosition(x, y, z)
    inst.Transform:SetRotation(rot)

    local debris = SpawnPrefab("superjump_debris")
    debris.Transform:SetPosition(x, y, z)
    debris.Transform:SetRotation(rot)
    debris.Transform:SetScale(target.Transform:GetScale())

    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        OnInit(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("player_superjump")
    inst.AnimState:PlayAnimation("superjump_land_fx")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetAddColour(.7, .5, 0, 0)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    inst.persists = false

    inst.SetTarget = SetTarget
    inst.inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

local function debrisfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("player_superjump")
    inst.AnimState:PlayAnimation("superjump_land_debris")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetAddColour(.7, .5, 0, 0)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    inst.persists = false

    return inst
end

return Prefab("superjump_fx", fn, assets, prefabs),
    Prefab("superjump_debris", debrisfn, assets)
