local assets =
{
    Asset("ANIM", "anim/grass.zip"),
    Asset("ANIM", "anim/reeds_monkeytails.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "cutreeds",
	"dug_monkeytail",
}

local function dig_up(inst, worker)
    if inst.components.pickable ~= nil and inst.components.lootdropper ~= nil then
        local withered = inst.components.witherable ~= nil and inst.components.witherable:IsWithered()

        if inst.components.pickable:CanBePicked() then
            inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        end

        inst.components.lootdropper:SpawnLootPrefab(withered and "cutreeds" or "dug_monkeytail")
    end
    inst:Remove()
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
    if not POPULATING and
        (   inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered() or
            inst.AnimState:IsCurrentAnimation("idle_dead")
        ) then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("picked", false)
    else
        inst.AnimState:PlayAnimation("picked")
    end
end

local function makebarrenfn(inst, wasempty)
    if not POPULATING and
        (   inst.components.witherable ~= nil and
            inst.components.witherable:IsWithered()
        ) then
        inst.AnimState:PlayAnimation(wasempty and "empty_to_dead" or "full_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end

local function onpickedfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    inst.AnimState:PlayAnimation("picking")

    if inst.components.pickable:IsBarren() then
        inst.AnimState:PushAnimation("empty_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PushAnimation("picked", false)
    end
end

local function ontransplantfn(inst)
    inst.components.pickable:MakeBarren()
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("monkeytail.png")
    
	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.MEDIUM] / 2) --plantables deployspacing/2

    inst:AddTag("plant")
    inst:AddTag("silviculture") -- for silviculture book

    --witherable (from witherable component) added to pristine state for optimization
    inst:AddTag("witherable")
    
    inst.AnimState:SetBank("grass")
    inst.AnimState:SetBuild("reeds_monkeytails")
    inst.AnimState:PlayAnimation("idle", true)

    inst.scrapbook_specialinfo = "NEEDFERTILIZER"
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------------------------------------
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    ------------------------------------------------------------------------
    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable:SetUp("cutreeds", TUNING.REEDS_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.max_cycles = TUNING.MONKEYTAIL_CYCLES + (TUNING.MONKEYTAIL_CYCLES_VAR <= 1 and TUNING.MONKEYTAIL_CYCLES_VAR or math.random(TUNING.MONKEYTAIL_CYCLES_VAR))
    inst.components.pickable.cycles_left = inst.components.pickable.max_cycles
    inst.components.pickable.ontransplantfn = ontransplantfn

    ------------------------------------------------------------------------
    inst:AddComponent("witherable")

    ------------------------------------------------------------------------
    inst:AddComponent("lootdropper")

    ------------------------------------------------------------------------
    inst:AddComponent("inspectable")

    ------------------------------------------------------------------------
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL


	if not GetGameModeProperty("disable_transplanting") then
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.DIG)
		inst.components.workable:SetOnFinishCallback(dig_up)
		inst.components.workable:SetWorkLeft(1)
	end

    ------------------------------------------------------------------------
    MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)

    ------------------------------------------------------------------------
    MakeNoGrowInWinter(inst)

    MakeWaxablePlant(inst)

    ------------------------------------------------------------------------
    MakeHauntableIgnite(inst)
    
    return inst
end

return Prefab("monkeytail", fn, assets, prefabs)
