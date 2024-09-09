
local assets = 	{
    Asset("ANIM", "anim/spawnprotectionbuff.zip"),
}

local prefabs =
{
	"battlesong_instant_panic_fx",
}

local function SpawnFx(target)
    local fx = SpawnPrefab("battlesong_instant_panic_fx")
    fx.Transform:SetNoFaced()

	target:AddChild(fx)

    return fx
end

local function owner_stop_buff_fn(owner)
	if owner:IsValid() then
		owner:RemoveDebuff("spawnprotectionbuff")
	end
end

local function stop_buff_fn(inst)
	inst.components.debuff:Stop()
end

local function start_exipiring(inst)
	inst.expire_task = inst:DoTaskInTime(TUNING.SPAWNPROTECTIONBUFF_DURATION, stop_buff_fn)
end

local function check_dist_from_spawnpt(inst, target)
	if not (target:GetDistanceSqToPoint(inst.spawn_pt) < TUNING.SPAWNPROTECTIONBUFF_SPAWN_DIST_SQ) then
		inst.check_dist_task:Cancel()
		inst.check_dist_task = nil

		inst.expire_task:Cancel()
		start_exipiring(inst)
	elseif TheWorld.state.isnight then
		inst.expire_task:Cancel()
		inst.expire_task = inst:DoTaskInTime(TUNING.SPAWNPROTECTIONBUFF_IDLE_DURATION, start_exipiring)
	end
end

local function buff_OnAttached(inst, target)
	inst.entity:SetParent(target.entity)

	inst.spawn_pt = target:GetPosition()

	inst.fx = SpawnFx(target)

	inst.expire_task = inst:DoTaskInTime(TUNING.SPAWNPROTECTIONBUFF_IDLE_DURATION, start_exipiring)
	inst.check_dist_task = inst:DoPeriodicTask(0.25, check_dist_from_spawnpt, nil, target)

	inst:OnEnableProtectionFn(target, true)

--[[
	if target.player_classified ~= nil then
		target.player_classified.hasinspirationbuff:set(true)
	end
]]

    inst:ListenForEvent("death", owner_stop_buff_fn, target)
    inst:ListenForEvent("doattack", owner_stop_buff_fn, target)
    inst:ListenForEvent("onattackother", owner_stop_buff_fn, target)
    inst:ListenForEvent("onmissother", owner_stop_buff_fn, target)
    inst:ListenForEvent("onthrown", owner_stop_buff_fn, target)

    inst:ListenForEvent("buildstructure", owner_stop_buff_fn, target)
    inst:ListenForEvent("builditem", owner_stop_buff_fn, target)

    inst:ListenForEvent("on_enter_might_gym", owner_stop_buff_fn, target)
	
end

local function buff_OnDetached(inst, target)
	inst:OnEnableProtectionFn(target, false)
	inst:DoTaskInTime(1, inst.Remove)
end

local function OnEnableProtectionFn(inst, target, enable)
	if enable then
		target:AddTag("notarget")
		target:AddTag("spawnprotection")

		target.Physics:ClearCollidesWith(COLLISION.OBSTACLES)
		target.Physics:ClearCollidesWith(COLLISION.SMALLOBSTACLES)
		target.Physics:ClearCollidesWith(COLLISION.CHARACTERS)
		target.Physics:ClearCollidesWith(COLLISION.FLYERS)
		target.AnimState:SetHaunted(true)
	else
		target:RemoveTag("notarget")
		target:RemoveTag("spawnprotection")

		target.Physics:CollidesWith(COLLISION.OBSTACLES)
		target.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
		target.Physics:CollidesWith(COLLISION.CHARACTERS)
		target.Physics:CollidesWith(COLLISION.FLYERS)
		target.AnimState:SetHaunted(false)

		inst.AnimState:PushAnimation("buff_pst", false)
	end
end

local function fn(songdata, dodelta_fn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("spawnprotectionbuff")
    inst.AnimState:SetBuild("spawnprotectionbuff")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:PlayAnimation("buff_pre")
    inst.AnimState:PushAnimation("buff_idle", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.25)

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --inst.entity:Hide()
    inst.persists = false

	inst.OnEnableProtectionFn = OnEnableProtectionFn

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)

    return inst
end

return Prefab("spawnprotectionbuff", fn, assets, prefabs)
