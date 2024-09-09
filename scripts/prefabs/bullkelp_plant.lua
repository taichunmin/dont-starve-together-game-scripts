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

	local fr = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
	inst.AnimState:SetFrame(fr)
	inst.underwater.AnimState:SetFrame(fr)
end

local function CheckBeached(inst)
    -- NOTES(JBK): If this is now beached it was ran ashore through something external force so do not spawn the bullkelp_beachedroot prefab instead spawn the expiring items.
    inst._checkgroundtask = nil
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst:GetCurrentPlatform() ~= nil or TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
        if inst.components.pickable ~= nil then
            inst.components.pickable:Pick(TheWorld)
        end
        inst:Remove()
        local beached = SpawnPrefab("bullkelp_root")
        beached.Transform:SetPosition(x, y, z)
    end
end

local function OnCollide(inst, other)
    if inst._checkgroundtask == nil then
        -- This collision callback is called very fast so only do the checks after some time in a staggered method.
        inst._checkgroundtask = inst:DoTaskInTime(1 + math.random(), CheckBeached)
    end
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
	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.MEDIUM] / 2) --bullkelp_root deployspacing/2

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

	local start_frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
	inst.AnimState:SetFrame(start_frame)
	inst.underwater.AnimState:SetFrame(start_frame)

    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    local pickable = inst:AddComponent("pickable")
    pickable.picksound = "turnoftides/common/together/water/harvest_plant"
    pickable:SetUp("kelp", TUNING.BULLKELP_REGROW_TIME)
    pickable.onregenfn = onregenfn
    pickable.onpickedfn = onpickedfn
    pickable.makeemptyfn = makeemptyfn

    inst:AddComponent("inspectable")

    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)
    ---------------------

    inst.Physics:SetCollisionCallback(OnCollide)
    inst:DoTaskInTime(1 + math.random(), CheckBeached) -- Does not need to be immediately done stagger over time.

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