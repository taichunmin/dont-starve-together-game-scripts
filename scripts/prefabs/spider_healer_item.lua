local assets =
{
    Asset("ANIM", "anim/spider_healer_item.zip"),
}

local prefabs =
{
    "spider_heal_fx",
    "spider_heal_target_fx",
}

local SPIDER_TAGS = { "spider" }
local SPIDER_IGNORE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function SpawnFx(inst, fx_prefab, scale)
    local x,y,z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab(fx_prefab)
    fx.Transform:SetNoFaced()
    fx.Transform:SetPosition(x,y,z)

    scale = scale or 1
    fx.Transform:SetScale(scale, scale, scale)
end

local function OnHealFn(inst, target)
    if target.SoundEmitter ~= nil then
        target.SoundEmitter:PlaySound("webber1/creatures/spider_cannonfodder/heal_fartcloud")
    end

    -- We heal webber manually instead of through the healer component because only webber should be healed by it
    if target:HasTag("spiderwhisperer") then
        target.components.health:DoDelta(TUNING.HEALING_MEDSMALL, false, inst.prefab)
        SpawnFx(target, "spider_heal_target_fx")
    end

    SpawnFx(target, "spider_heal_ground_fx")
    SpawnFx(target, "spider_heal_fx")
    local x,y,z = inst.Transform:GetWorldPosition()
    local other_spiders = TheSim:FindEntities(x, y, z, TUNING.SPIDER_HEALING_ITEM_RADIUS, SPIDER_TAGS, SPIDER_IGNORE_TAGS)

    for _, spider in ipairs(other_spiders) do
        spider.components.health:DoDelta(TUNING.SPIDER_HEALING_ITEM_AMOUNT, false, inst.prefab)
        SpawnFx(spider, "spider_heal_target_fx")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("spider_healer_item")
    inst.AnimState:SetBuild("spider_healer_item")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(0)
    inst.components.healer:SetOnHealFn(OnHealFn)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)

    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end


return Prefab("spider_healer_item", fn, assets, prefabs)