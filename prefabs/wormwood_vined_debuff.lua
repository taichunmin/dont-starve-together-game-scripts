local assets =
{
    Asset("ANIM", "anim/weed_ivy_lunar.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
}

----
local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)

    OnChangeFollowSymbol(inst, target, followsymbol, followoffset)

	if target.components.rooted == nil then
		target:AddComponent("rooted")
	end
	target.components.rooted:AddSource(inst)

    local function on_target_removed(t) inst.components.debuff:Stop() end
    inst:ListenForEvent("death", on_target_removed, target)
    inst:ListenForEvent("enterlimbo", on_target_removed, target)
    inst:ListenForEvent("teleported", on_target_removed, target)
    inst:ListenForEvent("onremove", on_target_removed, target)

    inst:ListenForEvent("newstate", function(t)
        local t_sg = t.sg
        if t_sg and t_sg:HasStateTag("flight") then
            on_target_removed(t)
        end
    end, target)

    local target_health = target.components.health
    if target_health and not target_health:IsDead() then
        local target_combat = target.components.combat
        if target_combat then
            target_combat:GetAttacked(inst, TUNING.WORMWOOD_ROOT_DAMAGE)
        end
    end
end

local function OnDetached(inst, target)
	if target and target:IsValid() and target.components.rooted ~= nil then
		target.components.rooted:RemoveSource(inst)
    end

    inst.AnimState:PlayAnimation("spike_pst")
    inst:ListenForEvent("animover", inst.Remove)
end

----
local STOP_TASK_NAME = "stop_vined_debuff"
local function OnTimerDone(inst, data)
    if data.name == STOP_TASK_NAME then
        inst.components.debuff:Stop()
    end
end

----
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("weed_ivy")
    inst.AnimState:SetBuild("weed_ivy_lunar")
    inst.AnimState:PlayAnimation("spike_pre")
    inst.AnimState:PushAnimation("spike_loop", true)
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetDeltaTimeMultiplier(0.8)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    local debuff = inst:AddComponent("debuff")
    debuff:SetChangeFollowSymbolFn(OnChangeFollowSymbol)
    debuff:SetAttachedFn(OnAttached)
    debuff:SetDetachedFn(OnDetached)

    --
    local timer = inst:AddComponent("timer")
    timer:StartTimer(STOP_TASK_NAME, TUNING.WORMWOOD_ROOT_TIME)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("wormwood_vined_debuff", fn, assets)