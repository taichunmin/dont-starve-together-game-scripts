local assets =
{
    Asset("ANIM", "anim/plant_normal.zip"),

    -- products for buildswap
    Asset("ANIM", "anim/durian.zip"),
    Asset("ANIM", "anim/eggplant.zip"),
    Asset("ANIM", "anim/dragonfruit.zip"),
    Asset("ANIM", "anim/pomegranate.zip"),
    Asset("ANIM", "anim/corn.zip"),
    Asset("ANIM", "anim/pumpkin.zip"),
    Asset("ANIM", "anim/carrot.zip"),
}

require "prefabs/veggies"

local prefabs =
{
    "ash",
    "seeds_cooked",
}
for k, v in pairs(VEGGIES) do
    table.insert(prefabs, k)
end

local function onmatured(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/farm_harvestable")
    inst.AnimState:OverrideSymbol("swap_grown", inst.components.crop.product_prefab,inst.components.crop.product_prefab.."01")
end

local function onburnt(inst)
    if inst.components.crop.product_prefab ~= nil then
        local product
        if inst.components.witherable ~= nil and inst.components.witherable:IsWithered() then
            product = SpawnPrefab("ash")
        elseif not inst.components.crop:IsReadyForHarvest() then
            product = SpawnPrefab("seeds_cooked")
        else
            local temp = SpawnPrefab(inst.components.crop.product_prefab)
            product = SpawnPrefab(temp.components.cookable ~= nil and temp.components.cookable.product or "seeds_cooked")
            temp:Remove()
        end

        if inst.components.stackable ~= nil and product.components.stackable ~= nil then
            product.components.stackable.stacksize = math.min(product.components.stackable.maxsize, inst.components.stackable.stacksize)
        end

        product.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    if inst.components.crop.grower ~= nil and inst.components.crop.grower.components.grower ~= nil then
        inst.components.crop.grower.components.grower:RemoveCrop(inst)
    end

    inst:Remove()
end

local function GetStatus(inst)
    return (inst:HasTag("withered") and "WITHERED")
        or (inst.components.crop:IsReadyForHarvest() and "READY")
        or "GROWING"
end

local function OnHaunt(inst, haunter)
    if inst.components.crop ~= nil and math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
        local harvested, product = inst.components.crop:Harvest()
        if not harvested then
            local fert = SpawnPrefab("spoiled_food")
            if fert.components.fertilizer ~= nil then
                fert.components.fertilizer.fertilize_sound = nil
            end
            inst.components.crop:Fertilize(fert, haunter)
        elseif product ~= nil then
            Launch(product, haunter, TUNING.LAUNCH_SPEED_SMALL)
        end
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("plant_normal")
    inst.AnimState:SetBuild("plant_normal")
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:SetFinalOffset(-1)

    --witherable (from witherable component) added to pristine state for optimization
    inst:AddTag("witherable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("crop")
    inst.components.crop:SetOnMatureFn(onmatured)

    inst:AddComponent("witherable")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(onburnt)
    --Clear default handlers so we don't stomp our .persists flag
    inst.components.burnable:SetOnIgniteFn(nil)
    inst.components.burnable:SetOnExtinguishFn(nil)

    return inst
end

return Prefab("plant_normal", fn, assets, prefabs)
