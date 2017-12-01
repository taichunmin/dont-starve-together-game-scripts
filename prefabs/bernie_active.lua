local brain = require("brains/berniebrain")

local assets =
{
    Asset("ANIM", "anim/bernie.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
    Asset("SOUND", "sound/together.fsb"),
}

local prefabs =
{
    "bernie_inactive",
}

local function goinactive(inst)
    local inactive = SpawnPrefab("bernie_inactive")
    if inactive ~= nil then
        --Transform health % into fuel.
        inactive.components.fueled:SetPercent(inst.components.health:GetPercent())
        inactive.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
        return inactive
    end
end

local function onpickup(inst, owner)
    local inactive = goinactive(inst)
    if inactive ~= nil then
        owner.components.inventory:GiveItem(inactive, nil, owner:GetPosition())
    end
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .25)
    inst.DynamicShadow:SetSize(1, .5)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("smallcreature")
    inst:AddTag("companion")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BERNIE_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("inspectable")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BERNIE_SPEED
    inst:AddComponent("combat")
    inst:AddComponent("timer")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(onpickup)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:SetStateGraph("SGbernie")
    inst:SetBrain(brain)

    inst.GoInactive = goinactive

    return inst
end

return Prefab("bernie_active", fn, assets, prefabs)
