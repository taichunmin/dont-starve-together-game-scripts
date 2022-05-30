require("prefabs/veggies")

local assets_fx =
{
    Asset("ANIM", "anim/plant_normal_ground.zip"),
}

local prefabs =
{
    "ash",
    "seeds_cooked",
    "spoiled_food",
    "cutgrass",
    "plant_dug_small_fx",
    "plant_dug_medium_fx",
    "plant_dug_large_fx",
}
for k, v in pairs(VEGGIES) do
    table.insert(prefabs, k)
end

local function SpawnDugFX(inst, size)
    local fx = SpawnPrefab("plant_dug_"..size.."_fx")
    if size ~= "small" and inst.prefab ~= "plant_normal_ground" then
        fx.AnimState:OverrideSymbol("leaves", "plant_normal", "leaves")
    end
    return fx
end

local function onmatured(inst)
    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/common/farm_harvestable")
    end
    inst.AnimState:OverrideSymbol("swap_grown", inst.components.crop.product_prefab, inst.components.crop.product_prefab.."01")
    inst.components.workable:SetWorkAction(nil)
    local veg = VEGGIES[inst.components.crop.product_prefab]
	if veg ~= nil and veg.halloweenmoonmutable_settings ~= nil then
		inst:AddComponent("halloweenmoonmutable")
		inst.components.halloweenmoonmutable:SetPrefabMutated(veg.halloweenmoonmutable_settings.prefab)
		inst.components.halloweenmoonmutable:SetOnMutateFn(veg.halloweenmoonmutable_settings.onmutatefn)
	end
    if inst.components.timer ~= nil then
        inst.components.timer:StartTimer("rotting", (veg ~= nil and veg.perishtime or TUNING.PERISH_MED) + math.random() * TUNING.SEG_TIME)
    end
end

local function onwithered(inst)
    inst.AnimState:ClearOverrideSymbol("swap_grown")
    inst.components.workable:SetWorkAction(nil)
    if inst.components.timer ~= nil then
        inst.components.timer:StopTimer("rotting")
    end
end

local function CalcPerish(inst, product)
    local t = inst.components.timer ~= nil and inst.components.timer:GetTimeLeft("rotting") or 0
    if t <= 0 then
        return 1
    end
    t = math.max(0, 1 - t / (product.components.perishable.perishtime or TUNING.PERISH_MED))
    return 1 - t * t
end

local function onharvest(inst, product, doer)
    if product ~= nil and product.components.perishable ~= nil then
        product.components.perishable:SetPercent(CalcPerish(inst, product))
    end
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
            if product.components.perishable ~= nil and temp.components.perishable ~= nil then
                product.components.perishable:SetPercent((1 + CalcPerish(inst, temp)) * .5)
            end
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

local function OnDigUp(inst)--, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.components.crop ~= nil then
        local harvested, product = inst.components.crop:Harvest()
        if harvested then
            if product ~= nil and product.components.inventoryitem ~= nil then
                product.components.inventoryitem:DoDropPhysics(x, y, z, true)
            end
            SpawnDugFX(inst, inst.components.witherable ~= nil and inst.components.witherable:IsWithered() and "small" or "large").Transform:SetPosition(x, y, z)
            return
        end

        SpawnDugFX(inst,
            (inst.components.crop.growthpercent < .4 and "small") or
            (inst.components.crop.growthpercent < .7 and "medium") or
            "large"
        ).Transform:SetPosition(x, y, z)

        local grower = inst.components.crop.grower
        if grower ~= nil and grower:IsValid() and grower.components.grower ~= nil then
            grower.components.grower:RemoveCrop(inst)
            inst.components.crop.grower = nil
            return
        end
    else
        SpawnDugFX(inst, "small").Transform:SetPosition(x, y, z)
    end
    inst:Remove()
end

local function GetStatus(inst)
    return (inst:HasTag("withered") and "WITHERED")
        or (inst.components.crop:IsReadyForHarvest() and "READY")
        or "GROWING"
end

local function OnHaunt(inst, haunter)
    if inst.components.crop ~= nil then-- and math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
        if not (inst.components.crop:IsReadyForHarvest() or inst:HasTag("withered")) then
            local fert = SpawnPrefab("spoiled_food")
            if fert.components.fertilizer ~= nil then
                fert.components.fertilizer.fertilize_sound = nil
            end
            inst.components.crop:Fertilize(fert, haunter)
        elseif inst.components.workable ~= nil then
            inst.components.workable:Destroy(haunter)
        end
        return true
    end
    return false
end

--------------------------------------------------------------------------
--ground version

local function MakeRotten(inst, instant)
    inst:AddTag("rotten")
    inst.components.inspectable.nameoverride = "spoiled_food"
    inst.components.inspectable.getstatus = nil
    if inst.components.witherable ~= nil then
        inst.components.witherable:ForceWither()
    end
    if inst.components.crop ~= nil then
        inst.components.crop.product_prefab = "spoiled_food"
    end
    inst.AnimState:ClearOverrideSymbol("swap_grown")
    if instant then
        inst.AnimState:SetPercent("rotten", 1)
    else
        inst.AnimState:PlayAnimation("rotten")
        inst.SoundEmitter:PlaySound("dontstarve/common/farm_harvestable")
    end
end

local function OnTimerDone(inst, data)
    if data.name == "rotting" then
        MakeRotten(inst, false)
    end
end

local function OnSave(inst, data)
    data.rotten = inst:HasTag("rotten") or nil
end

local function OnLoad(inst, data)--, ents)
    if data ~= nil and data.rotten then
        MakeRotten(inst, true)
    end
end

--------------------------------------------------------------------------

local function MakePlant(name, build, isground)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),

        -- products for buildswap
        Asset("ANIM", "anim/durian.zip"),
        Asset("ANIM", "anim/eggplant.zip"),
        Asset("ANIM", "anim/dragonfruit.zip"),
        Asset("ANIM", "anim/pomegranate.zip"),
        Asset("ANIM", "anim/corn.zip"),
        Asset("ANIM", "anim/pumpkin.zip"),
        Asset("ANIM", "anim/carrot.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        if isground then
            inst.entity:AddMiniMapEntity()
            inst.MiniMapEntity:SetIcon("plant_normal_ground.png")
        else
            inst.AnimState:SetFinalOffset(3)
        end
        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("grow")
        inst.AnimState:Hide("mouseover")

        inst:AddTag("NPC_workable")

        --witherable (from witherable component) added to pristine state for optimization
        inst:AddTag("witherable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("crop")
        inst.components.crop:SetOnMatureFn(onmatured)
        inst.components.crop:SetOnWitheredFn(onwithered)

        inst:AddComponent("witherable")

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus
        if name ~= "plant_normal" then
            inst.components.inspectable.nameoverride = "plant_normal"
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(OnDigUp)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        inst.components.burnable:SetOnBurntFn(onburnt)
        --Clear default handlers so we don't stomp our .persists flag
        inst.components.burnable:SetOnIgniteFn(nil)
        inst.components.burnable:SetOnExtinguishFn(nil)

        if isground then
            inst.components.crop:SetOnHarvestFn(onharvest)

            inst:AddComponent("timer")
            inst:ListenForEvent("timerdone", OnTimerDone)

            inst.OnSave = OnSave
            inst.OnLoad = OnLoad
        end

		inst:ListenForEvent("onhalloweenmoonmutate", function(inst)
			if inst.components.crop.grower ~= nil and inst.components.crop.grower.components.grower ~= nil then
                inst.components.crop.matured = false
                inst.components.crop.growthpercent = 0
                inst.components.crop.product_prefab = nil
				inst.components.crop.grower.components.grower:RemoveCrop(inst)
			end
		end)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function MakeFX(size)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.AnimState:SetBank("plant_normal_ground")
        inst.AnimState:SetBuild("plant_normal_ground")
        inst.AnimState:PlayAnimation("dug_"..size)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", ErodeAway)
        inst.persists = false

        return inst
    end

    return Prefab("plant_dug_"..size.."_fx", fn, assets_fx)
end

return MakePlant("plant_normal", "plant_normal", false),
    MakePlant("plant_normal_ground", "plant_normal_ground", true),
    MakeFX("small"),
    MakeFX("medium"),
    MakeFX("large")
