require "prefabutil"
local fooddef = require("wintersfeastcookedfoods")

local assets =
{
	Asset("ANIM", "anim/wintersfeast_oven.zip"),
	Asset("ANIM", "anim/food_winters_feast_2019.zip"),
}

local prefabs =
{
    "wintersfeastoven_fire",
    "collapse_small",
}

local sounds =--placeholder sounds
{
	proximity_loop = "",
	door_open = "dontstarve/quagmire/common/safe/open",
    door_close = "wintersfeast2019/winters_feast/oven/start",
    cooking_loop = "wintersfeast2019/winters_feast/oven/LP",
    finish = "wintersfeast2019/winters_feast/oven/done",
    picked = "dontstarve/quagmire/common/cooking/dish_place",
    hit = "dontstarve/wilson/hit_metal",
    place = "wintersfeast2019/winters_feast/table/place",
}

local BASE_STAGE_COOK_TIME = TUNING.WINTERS_FEAST_OVEN_BASE_COOK_TIME / 2 -- 2 = number of cooking/"science" stages
local SCIENCE_STAGES =
{
    { time = BASE_STAGE_COOK_TIME, anim = "cooking_loop", pre_anim = "pre_cooking", fire_pre_anim = "pre_cooking_fire", fire_anim = "cooking_loop_fire", sound = sounds.door_close},
	{ time = BASE_STAGE_COOK_TIME, anim = "cooking_loop", fire_anim = "cooking_loop_fire"},
}

local FOOD_PREFABS =
{
	"berrysauce",
    "bibingka",
	"cabbagerolls",
    "festivefish",
	"gravy",
	"latkes",
	"lutefisk",
	"mulleddrink",
	"panettone",
    "pavlova",
    "pickledherring",
	"polishcookie",
	"pumpkinpie",
	"roastturkey",
	"stuffing",
	"sweetpotato",
	"tamales",
	"tourtiere",
}

local WINTERS_FEAST_COOKED_FOODS = {}
for _,v in ipairs(FOOD_PREFABS) do
	local fakeprefab = "wintercooking_"..v
	WINTERS_FEAST_COOKED_FOODS[fakeprefab] = v
	table.insert(prefabs, v)
	table.insert(prefabs, fakeprefab)
end

local function RemoveFireFx(inst)
	if inst._firefx ~= nil then
		inst._firefx:Remove()
		inst._firefx = nil
	end
end

local function MakeFireFx(inst)
	RemoveFireFx(inst)

    inst._firefx = SpawnPrefab("wintersfeastoven_fire")
    inst._firefx.entity:SetParent(inst.entity)
end

local function SetLightEnabled(inst, enabled)
	inst.Light:Enable(enabled or false)
end

local function SetupDish(inst, itemname)
	if inst.components.prototyper ~= nil then
		inst:RemoveComponent("prototyper")
	end

	inst.components.pickable:SetUp(itemname, 1000000)
	inst.components.pickable.caninteractwith = true

	inst.AnimState:OverrideSymbol("swap_food", "food_winters_feast_2019", itemname)
end

local function SetOvenCookTimeMultiplier(inst, multiplier)
	-- Presuming all cooking/"science" stages last equally long.
	if multiplier ~= nil then
		for _,v in pairs(inst.science_stages) do
			v.time = BASE_STAGE_COOK_TIME * multiplier
		end
	end
end

local function GetWinterFoodCookTimeMultiplier(prefab)
	return prefab ~= nil and WINTERS_FEAST_COOKED_FOODS[prefab] ~= nil and fooddef.foods[WINTERS_FEAST_COOKED_FOODS[prefab]].cooktime or 1
end

local function CanCookPrefab(prefab)
	local first, last = string.find(prefab, "wintercooking_")
	if first == nil or last == nil then
		return false
	end

	local prefab_trimmed = string.sub(prefab, last + 1)
	for _,v in pairs(FOOD_PREFABS) do
		if v == prefab_trimmed then
			return true
		end
	end
	return false
end

local function StartMakingScience(inst, doer, recipe)
    if recipe.product ~= nil and CanCookPrefab(recipe.product) then
		MakeFireFx(inst)
		SetOvenCookTimeMultiplier(inst, GetWinterFoodCookTimeMultiplier(recipe.product))

        inst.components.madsciencelab:StartMakingScience(recipe.product)

		SetLightEnabled(inst, true)
    end
end

local function onturnon(inst)
    if inst.components.madsciencelab ~= nil and not inst:HasTag("burnt") and not inst.components.madsciencelab:IsMakingScience() and not inst.AnimState:IsCurrentAnimation("item_idle") and not inst.AnimState:IsCurrentAnimation("idle_open") then
        if inst.AnimState:IsCurrentAnimation("hit_door_open") then
			inst.AnimState:PushAnimation("idle_open")

			inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime(), function(inst)
				inst.SoundEmitter:PlaySound(sounds.door_open)
			end)
		elseif inst.AnimState:IsCurrentAnimation("hit_door_closed") or inst.AnimState:IsCurrentAnimation("place") then
			inst.AnimState:PushAnimation("proximity")
            inst.AnimState:PushAnimation("idle_open")

			inst:DoTaskInTime(math.max(0, inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()), function(inst)
				inst.SoundEmitter:PlaySound(sounds.door_open)
			end)
        else
			inst.AnimState:PlayAnimation("proximity")
			inst.AnimState:PushAnimation("idle_open")

			inst.SoundEmitter:PlaySound(sounds.door_open)
        end

        inst.SoundEmitter:KillSound("cooking_loop")
        inst.SoundEmitter:PlaySound(sounds.proximity_loop, "cooking_loop")
    end
end

local function onturnoff(inst)
    if inst.components.madsciencelab ~= nil and not inst:HasTag("burnt") and not inst.components.madsciencelab:IsMakingScience() then
		inst.AnimState:PushAnimation("cooking_start")
		inst.AnimState:PushAnimation("idle_closed")

        inst.SoundEmitter:KillSound("cooking_loop")
		inst:DoTaskInTime(math.max(0, inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()), function(inst)
			inst.SoundEmitter:PlaySound(sounds.door_close)
		end)
    end
end

local function MakePrototyper(inst)
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = StartMakingScience
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.WINTERSFEASTCOOKING
end

local function onitemtaken(inst, picker, loot)
    if inst.components.pickable.caninteractwith then
        inst.components.pickable.caninteractwith = false
        inst.SoundEmitter:PlaySound(sounds.picked)
    end

	if inst.components.prototyper == nil then
		MakePrototyper(inst)
	end

    inst.AnimState:ClearOverrideSymbol("swap_food")
end

local function OnInactive(inst)
    if not inst:HasTag("burnt") then
        inst:RemoveEventCallback("animover", OnInactive)
		inst.AnimState:PlayAnimation("item_idle")
    end
end

local function OnStageStarted(inst, stage)
	if inst._firefx == nil or not inst._firefx:IsValid() then
		MakeFireFx(inst)
	end

    inst:RemoveComponent("prototyper")

	local stagedata = inst.science_stages[stage]
	local prevstagedata = stage > 1 and inst.science_stages[stage-1] or nil

    if stagedata.pre_anim then
        inst.AnimState:PlayAnimation(stagedata.pre_anim)
		inst.AnimState:PushAnimation(stagedata.anim, true)
    else
		-- Prevents smoke animation in cooking loop from clipping
		-- back to anim start when stage changes.
		if prevstagedata == nil or prevstagedata.anim ~= stagedata.anim then
			inst.AnimState:PushAnimation(stagedata.anim, true)
		end
	end

	if stagedata.sound ~= nil then
		inst.SoundEmitter:PlaySound(stagedata.sound)
	end

    inst.SoundEmitter:KillSound("cooking_loop")
    inst.SoundEmitter:PlaySound(sounds.cooking_loop, "cooking_loop", stage / #inst.science_stages)

    if stagedata.fire_pre_anim then
        inst._firefx.AnimState:PlayAnimation(stagedata.fire_pre_anim)
    end
    inst._firefx.AnimState:PushAnimation(stagedata.fire_anim, true)
end

local function OnScienceWasMade(inst, wintercooking_id)
	if WINTERS_FEAST_COOKED_FOODS[wintercooking_id] ~= nil then
		SetupDish(inst, WINTERS_FEAST_COOKED_FOODS[wintercooking_id])
	end

	inst.AnimState:PlayAnimation("cooking_post")

	inst.AnimState:PushAnimation("cook_done")
    inst.SoundEmitter:KillSound("cooking_loop")
    inst.SoundEmitter:PlaySound(sounds.finish)
    inst:ListenForEvent("animover", OnInactive)

    inst._firefx.AnimState:PlayAnimation("cooking_post_fire")
	inst:DoTaskInTime(inst._firefx.AnimState:GetCurrentAnimationLength(), RemoveFireFx)

	SetLightEnabled(inst, false)
end

local function onhammered(inst, worker)
	if inst.components.pickable.caninteractwith and inst.components.pickable.product then
		inst.components.lootdropper:SetLoot({ inst.components.pickable.product })
	end
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function onhit(inst, worker)
    if not inst.AnimState:IsCurrentAnimation("cook_done") then
		if inst.components.pickable.caninteractwith then
			inst.AnimState:PlayAnimation("hit_door_open")
			inst.AnimState:PushAnimation("item_idle")
            inst.SoundEmitter:PlaySound(sounds.hit)
        elseif inst.components.prototyper ~= nil and inst.components.prototyper.on then
			inst.AnimState:PlayAnimation("hit_door_open")
			inst.AnimState:PushAnimation("idle_open")
            inst.SoundEmitter:PlaySound(sounds.hit)
            onturnon(inst)
        elseif inst.components.madsciencelab == nil or not inst.components.madsciencelab:IsMakingScience() then
			inst.AnimState:PlayAnimation("hit_door_closed")
			inst.AnimState:PushAnimation("idle_closed")
            inst.SoundEmitter:PlaySound(sounds.hit)
        end
    end
end

local function getstatus(inst)
    return inst.components.pickable.caninteractwith and "DISH_READY"
		or inst.components.madsciencelab:IsMakingScience() and inst.components.madsciencelab.stage ~= nil and (inst.components.madsciencelab.stage > (#inst.science_stages - 1) and "ALMOST_DONE_COOKING" or "COOKING")
        or nil
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_closed", false)
    inst.SoundEmitter:PlaySound(sounds.place)
end

local function onsave(inst, data)
	if inst.components.pickable.caninteractwith and inst.components.pickable.product ~= nil then
		data.completed_dish_name = inst.components.pickable.product
	end
end

local function onload(inst, data)
	if data ~= nil and data.completed_dish_name ~= nil then
		SetupDish(inst, data.completed_dish_name)
		inst.AnimState:PlayAnimation("item_idle")
	elseif inst.components.madsciencelab ~= nil and inst.components.madsciencelab.product ~= nil then
		SetOvenCookTimeMultiplier(inst, GetWinterFoodCookTimeMultiplier(inst.components.madsciencelab.product))
		SetLightEnabled(inst, true)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.6) --recipe min_spacing/2
	MakeObstaclePhysics(inst, 0.8, 1.2)

    inst.MiniMapEntity:SetIcon("wintersfeastoven.png")

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1.5)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(250/255,180/255,50/255)
   -- inst.Light:EnableClientModulation(true)

    inst:AddTag("structure")

    inst.AnimState:SetBank("wintersfeast_oven")
    inst.AnimState:SetBuild("wintersfeast_oven")
    inst.AnimState:PlayAnimation("idle_closed")
	inst.AnimState:SetFinalOffset(1)

    inst.scrapbook_anim = "idle_closed"

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakePrototyper(inst)

    inst:AddComponent("madsciencelab")
    inst.components.madsciencelab.OnStageStarted = OnStageStarted
    inst.components.madsciencelab.OnScienceWasMade = OnScienceWasMade
	inst.science_stages = deepcopy(SCIENCE_STAGES)
    inst.components.madsciencelab.stages = inst.science_stages

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = onitemtaken
    inst.components.pickable.paused = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

local function fire_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("wintersfeast_oven")
    inst.AnimState:SetBuild("wintersfeast_oven")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:PlayAnimation("idle_fire_off")

    inst:AddTag("FX")
	inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function dummy_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
		return inst
	end

    inst.persists = false
	inst:DoTaskInTime(0, inst.Remove)
	return inst
end

local prefab_list = {}
table.insert(prefab_list, Prefab("wintersfeastoven", fn, assets, prefabs))
table.insert(prefab_list, Prefab("wintersfeastoven_fire", fire_fn))
table.insert(prefab_list, MakePlacer("wintersfeastoven_placer", "wintersfeast_oven", "wintersfeast_oven", "idle_closed"))

-- add fake prefabs for all the experiments so the game doesn't log about non-existing prefabs due to recipes
for k,_ in pairs(WINTERS_FEAST_COOKED_FOODS) do
    table.insert(prefab_list, Prefab(k, dummy_fn))
end

return unpack(prefab_list)
