local assets =
{
    Asset("ANIM", "anim/atrium_overgrowth.zip"),
}

--[[
local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnEntityWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open_LP", "loop")
    end
end
]]

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("atrium_overgrowth")
    inst.AnimState:SetBank("atrium_overgrowth")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("atrium_overgrowth.png")

    MakeObstaclePhysics(inst, 1.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SUPERHUGE

    inst:AddComponent("inspectable")

    --inst.OnEntityWake = OnEntityWake
    --inst.OnEntitySleep = OnEntitySleep

    return inst
end

local function idolfn()
    local inst = fn()

    inst:SetPrefabName("atrium_overgrowth")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("atrium_overgrowth", fn, assets, prefabs),
    Prefab("atrium_idol", idolfn, assets, prefabs) -- deprecated
