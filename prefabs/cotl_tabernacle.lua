require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/cotl_tabernacle.zip"),
}

local prefabs =
{
	"ash",
	"charcoal",
    "campfirefire",
    "collapse_small",
	"cotl_tabernacle_level2",
	"cotl_tabernacle_level3",
}

local scrapbook_adddeps =
{
    "rocks",
    "log",
    "cutstone",
    "goldnugget",
}

local data = {
	{
		construction_product = "cotl_tabernacle_level2", 
		minimap = "cotl_tabernacle_level1.png",
		tunings = TUNING.COTL_TABERNACLE_1,
		anims = {
			place = "place_1",
			hit = "hit_1",
			idle = "idle_1",
		},
		sounds = {
			place = "dontstarve/common/place",
			ontakefuel = "dontstarve/common/fireAddFuel",
		},
		sanity_arua = TUNING.SANITYAURA_TINY,
        disable_charcoal = true,
        scrapbook_proxy = "cotl_tabernacle_level3",
	},
	{
		construction_product = "cotl_tabernacle_level3", 
		minimap = "cotl_tabernacle_level2.png",
		tunings = TUNING.COTL_TABERNACLE_2,
		anims = {
			place = "place_2",
			hit = "hit_2",
			idle = "idle_2",
		},
		sounds = {
			place = "dontstarve/common/place",
			ontakefuel = "dontstarve/common/fireAddFuel",
		},
		sanity_arua = TUNING.SANITYAURA_SMALL_TINY,
        disable_charcoal = true,
        scrapbook_proxy = "cotl_tabernacle_level3",
		scannable_recipename = "cotl_tabernacle_level1",
	},
	{
		construction_product = nil, 
		minimap = "cotl_tabernacle_level3.png",
		tunings = TUNING.COTL_TABERNACLE_3,
		anims = {
			place = "place_3",
			hit = "hit_3",
			idle = "idle_3",
		},
		sounds = {
			place = "dontstarve/common/place",
			ontakefuel = "dontstarve/common/fireAddFuel",
		},
		sanity_arua = TUNING.SANITYAURA_SMALL,
        disable_charcoal = false,
        scrapbook_proxy = nil,
		scannable_recipename = "cotl_tabernacle_level1",
	},
}


local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("ash").Transform:SetPosition(x, y, z)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation(inst.data.anims.hit)
    inst.AnimState:PushAnimation(inst.data.anims.idle, true)
end

local function onextinguish(inst)
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function ontakefuel(inst)
    inst.SoundEmitter:PlaySound(inst.data.sounds.ontakefuel)
end

local function updatefuelrate(inst)
    inst.components.fueled.rate = TheWorld.state.israining and inst.components.rainimmunity == nil and 1 + inst.data.tunings.RAIN_RATE * TheWorld.state.precipitationrate or 1
end

local function onupdatefueled(inst)
    if inst.components.burnable and inst.components.fueled then
        updatefuelrate(inst)
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end

local function onfuelchange(newsection, oldsection, inst, doer)
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
        if inst.queued_charcoal then
            inst.components.lootdropper:SpawnLootPrefab("charcoal")
            inst.queued_charcoal = nil
        end

		inst:RemoveComponent("sanityaura")

		inst.AnimState:Hide("FIRE")
		inst.AnimState:Show("NOFIRE")
    else
        if not inst.components.burnable:IsBurning() then
            updatefuelrate(inst)
            inst.components.burnable:Ignite(nil, nil, doer)
        end
        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())

		if not inst.components.sanityaura then
			inst:AddComponent("sanityaura")
			inst.components.sanityaura.aura = inst.data.sanity_arua
		end

		inst.AnimState:Show("FIRE")
		inst.AnimState:Hide("NOFIRE")

        if newsection == inst.components.fueled.sections then
            inst.queued_charcoal = not inst.disable_charcoal
        end
    end
end

local function getstatus(inst)
    return not inst.components.fueled:IsEmpty() and "LIT" or nil
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation(inst.data.anims.place)
    inst.AnimState:PushAnimation(inst.data.anims.idle, true)
    inst.SoundEmitter:PlaySound(inst.data.sounds.place)
    inst.SoundEmitter:PlaySound(inst.data.sounds.ontakefuel)
end

local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE and
        inst.components.fueled ~= nil and
        not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(TUNING.MED_FUEL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function OnInit(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:FixFX()
    end
end

local function OnSave(inst, data)
    data.queued_charcoal = inst.queued_charcoal or nil
end

local function OnPreLoad(inst)
	--V2C: -charcoal gets queued from constructor maxing out fuel level
	--     -need to clear that before loading, otherwise extinguished
	--      save data will drop an extra charcoal
	inst.queued_charcoal = nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.queued_charcoal then
        inst.queued_charcoal = true
    end
end

local function OnConstructed(inst, doer)
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            return -- not completed
        end
    end

    local new_inst = ReplacePrefab(inst, inst._construction_product)
    new_inst.SoundEmitter:PlaySound(new_inst.data.sounds.place)
    new_inst.SoundEmitter:PlaySound(new_inst.data.sounds.ontakefuel)

    new_inst.AnimState:PlayAnimation(new_inst.data.anims.place)
    new_inst.AnimState:PushAnimation(new_inst.data.anims.idle, true)

end

--------------------------------------------------------------------------

local function fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon(data.minimap)
    inst.MiniMapEntity:SetPriority(1)

    inst.AnimState:SetBank("cotl_tabernacle")
    inst.AnimState:SetBuild("cotl_tabernacle")
    inst.AnimState:PlayAnimation(data.anims.idle, true)

    inst:AddTag("campfire")
    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

	if data.construction_product then
		inst:AddTag("constructionsite")
	end

	inst.SCANNABLE_RECIPENAME = data.scannable_recipename

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2
    MakeObstaclePhysics(inst, 0.75)
    MakeSnowCoveredPristine(inst)

    inst.scrapbook_proxy = data.scrapbook_proxy

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim    = "idle_3"
    inst.scrapbook_adddeps = scrapbook_adddeps

	inst.data = data

    inst.disable_charcoal = data.disable_charcoal
    inst.OnSave = OnSave
	inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad

	if data.construction_product then
		inst._construction_product = data.construction_product

		inst:AddComponent("constructionsite")
		inst.components.constructionsite:SetConstructionPrefab("construction_container")
		inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
	end

    -----------------------
    inst:AddComponent("burnable")
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0), "firefx", true)
	inst.components.burnable:SetOnExtinguishFn(onextinguish)

    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -------------------------
    inst:AddComponent("cooker")
    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = data.tunings.FUEL_MAX
    inst.components.fueled.accepting = true

    inst.components.fueled:SetSections(data.tunings.FUEL_SECTIONS)
    inst.components.fueled.bonusmult = data.tunings.BONUS_MULT
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetUpdateFn(onupdatefueled)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(data.tunings.FUEL_MAX)

    inst:AddComponent("storytellingprop")

    -----------------------------

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    -----------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:DoTaskInTime(0, OnInit)

    return inst
end

local function fn_lvl1()
	return fn(data[1])
end

local function fn_lvl2()
	return fn(data[2])
end

local function fn_lvl3()
	return fn(data[3])
end

return Prefab("cotl_tabernacle_level1", fn_lvl1, assets, prefabs),
	Prefab("cotl_tabernacle_level2", fn_lvl2, assets, prefabs),
	Prefab("cotl_tabernacle_level3", fn_lvl3, assets, prefabs),
    MakePlacer("cotl_tabernacle_level1_placer", "cotl_tabernacle", "cotl_tabernacle", "placer1")

