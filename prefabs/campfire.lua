require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/campfire.zip"),
}

local prefabs =
{
    "campfirefire",
    "collapse_small",
    "ash",
}

local function onhammered(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("ash").Transform:SetPosition(x, y, z)
    SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
    inst:Remove()
end

local function onextinguish(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function ontakefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function updatefuelrate(inst)
    inst.components.fueled.rate = TheWorld.state.israining and 1 + TUNING.CAMPFIRE_RAIN_RATE * TheWorld.state.precipitationrate or 1
end

local function onupdatefueled(inst)
    if inst.components.burnable ~= nil and inst.components.fueled ~= nil then
        updatefuelrate(inst)
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end

local PROPAGATE_RANGES = { 1, 2, 3, 4 }
local HEAT_OUTPUTS = { 2, 5, 5, 10 }
local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
        inst.AnimState:PlayAnimation("dead")
        RemovePhysicsColliders(inst)

        SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst.components.fueled.accepting = false
        inst:RemoveComponent("cooker")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("workable")
        inst.persists = false
        inst:AddTag("NOCLICK")
        inst:DoTaskInTime(1, ErodeAway)
    else
        if not inst.components.burnable:IsBurning() then
            updatefuelrate(inst)
        end
        inst.AnimState:PlayAnimation("idle")
        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())

        inst.components.propagator.propagaterange = PROPAGATE_RANGES[newsection]
        inst.components.propagator.heatoutput = HEAT_OUTPUTS[newsection]
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local SECTION_STATUS =
{
    [0] = "OUT",
    [1] = "EMBERS",
    [2] = "LOW",
    [3] = "NORMAL",
    [4] = "HIGH",
}
local function getstatus(inst)
    return SECTION_STATUS[inst.components.fueled:GetCurrentSection()]
end

local function OnHaunt(inst)
    if inst.components.fueled ~= nil and
        inst.components.fueled.accepting and
        math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
        inst.components.fueled:DoDelta(TUNING.TINY_FUEL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
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

    MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBank("campfire")
    inst.AnimState:SetBuild("campfire")
    inst.AnimState:PlayAnimation("idle", false)
    --inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("campfire")
    inst:AddTag("NPC_workable")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

	-- for storytellingprop component
	inst:AddTag("storytellingprop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    inst:AddComponent("propagator")
    -----------------------

    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("campfirefire", Vector3())
    inst:ListenForEvent("onextinguish", onextinguish)

    -------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetOnFinishCallback(onhammered)

    -------------------------
    inst:AddComponent("cooker")
    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.CAMPFIRE_FUEL_MAX
    inst.components.fueled.accepting = true

    inst.components.fueled:SetSections(4)

    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetUpdateFn(onupdatefueled)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.CAMPFIRE_FUEL_START)

    -----------------------------
    inst:AddComponent("storytellingprop")

    -----------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    --------------------

    inst.components.burnable:Ignite()
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    return inst
end

-------------------------------------------------------------------------------

local function quagmire_fn()
    local inst = fn()

    inst:SetPrefabNameOverride("campfire")

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/campfire").master_postinit(inst, SECTION_STATUS, updatefuelrate)

    return inst
end

-------------------------------------------------------------------------------

return Prefab("campfire", fn, assets, prefabs),
    MakePlacer("campfire_placer", "campfire", "campfire", "preview"),
    Prefab("quagmire_campfire", quagmire_fn, assets, prefabs)
