local assets =
{
    Asset("ANIM", "anim/bullkelp.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local underwater_assets =
{
    Asset("ANIM", "anim/bullkelp_underwater.zip"),
}

local prefabs =
{
    "kelp",
    "bullkelp_root",
	"bullkelp_plant_leaves",
}

local function onpickedfn(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", true)
    inst.underwater.AnimState:PlayAnimation("picking")
    inst.underwater.AnimState:PushAnimation("picked", true)
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
    inst.underwater.AnimState:PlayAnimation("grow")
    inst.underwater.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("picked", true)
    inst.underwater.AnimState:PlayAnimation("picked", true)

	local time = math.random() * inst.AnimState:GetCurrentAnimationLength()
    inst.AnimState:SetTime(time)
    inst.underwater.AnimState:SetTime(time)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("bullkelp_plant.png")

    MakeInventoryPhysics(inst, nil, 0.7)

    inst.AnimState:SetBank("bullkelp")
    inst.AnimState:SetBuild("bullkelp")
    inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetFinalOffset(1)

	AddDefaultRippleSymbols(inst, true, false)
    
    inst:AddTag("kelp")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
	inst.underwater = SpawnPrefab("bullkelp_plant_leaves")
	inst.underwater.entity:SetParent(inst.entity)
	inst.underwater.Transform:SetPosition(0,0,0)
    ---------------------

	local start_time = math.random() * 2
    inst.AnimState:SetTime(start_time)
    inst.underwater.AnimState:SetTime(start_time)

    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "turnoftides/common/together/water/harvest_plant"
    inst.components.pickable:SetUp("kelp", TUNING.BULLKELP_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn

    inst:AddComponent("inspectable")

    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)
    ---------------------

    return inst
end

local function underwaterleafsfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("bullkelp_underwater")
    inst.AnimState:SetBuild("bullkelp_underwater")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

	inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	return inst
end

return Prefab("bullkelp_plant", fn, assets, prefabs),
		Prefab("bullkelp_plant_leaves", underwaterleafsfn, underwater_assets)