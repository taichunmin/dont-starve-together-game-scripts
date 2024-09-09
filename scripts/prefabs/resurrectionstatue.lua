require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/wilsonstatue.zip"),
    Asset("MINIMAP_IMAGE", "resurrect"),
}

local prefabs =
{
    "collapse_small",
    "collapse_big",
    "charcoal",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    local fx
    if inst:HasTag("burnt") then
        if inst.components.lootdropper ~= nil then
            inst.components.lootdropper:SpawnLootPrefab("charcoal")
        end
        fx = SpawnPrefab("collapse_small")
    else
        if inst.components.lootdropper ~= nil then
            inst.components.lootdropper:DropLoot()
        end
        fx = SpawnPrefab("collapse_big")
    end
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onburnt(inst)
    inst:RemoveComponent("attunable")
    DefaultBurntStructureFn(inst)
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onattunecost(inst, player)
    --round up health to match UI display
	local amount_required = player:HasTag("health_as_oldage") and math.ceil(TUNING.EFFIGY_HEALTH_PENALTY * TUNING.OLDAGE_HEALTH_SCALE) or TUNING.EFFIGY_HEALTH_PENALTY

    if player.components.health == nil or math.ceil(player.components.health.currenthealth) <= amount_required then
		--Don't die from attunement!
        return false, "NOHEALTH"
    end
    
	player:PushEvent("consumehealthcost")
    player.components.health:DoDelta(-TUNING.EFFIGY_HEALTH_PENALTY, false, "statue_attune", true, inst, true)
    return true
end

local function onlink(inst, player, isloading)
    if not isloading then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/on")
        inst.AnimState:PlayAnimation("attune_on")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function onunlink(inst, player, isloading)
    if not (isloading or inst.AnimState:IsCurrentAnimation("attune_on")) then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/off")
        inst.AnimState:PlayAnimation("attune_off")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function PlayAttuneSound(inst)
    if inst.AnimState:IsCurrentAnimation("place") or inst.AnimState:IsCurrentAnimation("attune_on") then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/on")
    end
end

local function onbuilt(inst, data)
    --Hack to auto-link without triggering fx or paying the cost again
    inst.components.attunable:SetOnAttuneCostFn(nil)
    inst.components.attunable:SetOnLinkFn(nil)
    inst.components.attunable:SetOnUnlinkFn(nil)

    inst.AnimState:PlayAnimation("place")
    if inst.components.attunable:LinkToPlayer(data.builder) then
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), PlayAttuneSound)
        inst.AnimState:PushAnimation("attune_on")
    end
    inst.AnimState:PushAnimation("idle", false)

    --End hack
    inst.components.attunable:SetOnAttuneCostFn(onattunecost)
    inst.components.attunable:SetOnLinkFn(onlink)
    inst.components.attunable:SetOnUnlinkFn(onunlink)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .3)

    inst.MiniMapEntity:SetIcon("resurrect.png")

    inst:AddTag("structure")
    inst:AddTag("resurrector")

    inst.AnimState:SetBank("wilsonstatue")
    inst.AnimState:SetBuild("wilsonstatue")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_specialinfo = "RESURECTIONSTATUE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("attunable")
    inst.components.attunable:SetAttunableTag("remoteresurrector")
    inst.components.attunable:SetOnAttuneCostFn(onattunecost)
    inst.components.attunable:SetOnLinkFn(onlink)
    inst.components.attunable:SetOnUnlinkFn(onunlink)

    MakeSnowCovered(inst)

    inst:ListenForEvent("activateresurrection", inst.Remove)

    return inst
end

return Prefab("resurrectionstatue", fn, assets, prefabs),
    MakePlacer("resurrectionstatue_placer", "wilsonstatue", "wilsonstatue", "idle")
