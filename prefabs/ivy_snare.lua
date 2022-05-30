local assets =
{
    Asset("ANIM", "anim/weed_ivy.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
}

local prefabs =
{
}

local function DoKillOff(inst)
	if inst.components.health ~= nil and not inst.components.health:IsDead() then
		inst.components.health:Kill()
	end
end

local function KillOff(inst)
	inst:RemoveTag("groundspike")
	if inst.validate_task ~= nil then
		inst.validate_task:Cancel()
		inst.validate_task = nil
	end
	inst:DoTaskInTime(0.2 + math.random() * 0.5, DoKillOff)
end

local function OnDeath(inst)
	inst.AnimState:PlayAnimation("spike_pst")
	inst:RemoveTag("groundspike")
    inst:AddTag("NOCLICK")
    inst.Physics:SetActive(false)
	if inst.validate_task ~= nil then
		inst.validate_task:Cancel()
		inst.validate_task = nil
	end
    inst:DoTaskInTime(1.5, inst.Remove)
end

local function ValidateTarget(inst)
	if not inst:HasTag("groundspike") then
		inst.validate_task:Cancel()
		inst.validate_task = nil
	end

	local target = inst.target
	if target == nil or not target:IsValid() or target.components.health == nil or target.components.health:IsDead() or not inst:IsNear(target, inst.target_max_dist) then
		KillOff(inst)
	end
end

local function StartSpike(inst, duration)
    inst.AnimState:PlayAnimation("spike_pre")
    inst.AnimState:PushAnimation("spike_loop", true)
	inst:Show()

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")

    --DoDamage(inst)
end

local function RestartSnare(inst, delay)
    if inst.task ~= nil then
        inst.task:Cancel()
	end

	inst:Hide()
    inst.task = inst:DoTaskInTime(delay or 0, StartSpike)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

	inst:Hide()

    inst.AnimState:SetBank("weed_ivy")
    inst.AnimState:SetBuild("weed_ivy")
    inst.AnimState:PlayAnimation("spike_pre")
	inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")
    inst.AnimState:SetFinalOffset(1)
	inst.AnimState:SetDeltaTimeMultiplier(0.9 + math.random() * 0.2)

	MakeObstaclePhysics(inst, 0.2, 2)

    inst:AddTag("groundspike")
    inst:AddTag("hostile")
	inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(10)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(40)
	inst.components.health.nofadeout = true

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	inst:ListenForEvent("death", OnDeath)

	inst.validate_task = inst:DoPeriodicTask(1.0, ValidateTarget, 2.0 + math.random())

    inst.persists = false

    inst.RestartSnare = RestartSnare
	inst.KillOff = KillOff

    return inst
end

return Prefab("ivy_snare", fn, assets, prefabs)
