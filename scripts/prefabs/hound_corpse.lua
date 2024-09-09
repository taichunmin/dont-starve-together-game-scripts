local assets =
{
    Asset("ANIM", "anim/hound.zip"),
    Asset("ANIM", "anim/hound_basic_transformation.zip"),
}

local prefabs =
{
    "mutatedhound",
}

local function SpawnMutatedHound(inst)
	local hound = SpawnPrefab("mutatedhound")
	hound.Transform:SetPosition(inst.Transform:GetWorldPosition())
	hound.Transform:SetRotation(inst.Transform:GetRotation())
	if not inst:IsAsleep() then
		hound.sg:GoToState("mutated_spawn")
	end
	local warg = inst.components.entitytracker:GetEntity("warg")
	if warg ~= nil then
		hound.components.follower:SetLeader(warg)
		warg:ForgetFollowerCorpse(inst)
		inst.components.entitytracker:ForgetEntity("warg")
	end

	inst.components.burnable.fastextinguish = true

	inst.spawn_task = nil
	inst:RemoveComponent("inspectable")
	inst:RemoveComponent("burnable")
	inst:RemoveComponent("propagator")
	inst.persists = false
	inst:DoTaskInTime(5, inst.Remove)
end

local function play_punch(inst)
    inst.SoundEmitter:PlaySound("turnoftides/creatures/together/mutated_hound/punch")
end
local function play_body_fall(inst)
    inst.SoundEmitter:PlaySound("dontstarve/movement/body_fall")
end

local function StartReviving(inst)
	inst.AnimState:PlayAnimation("mutated_hound_reviving")

    inst.SoundEmitter:PlaySound("turnoftides/creatures/together/mutated_hound/mutate")
    play_punch(inst)
    inst:DoTaskInTime(11*FRAMES, play_body_fall)
    inst:DoTaskInTime(21*FRAMES, play_punch)
    inst:DoTaskInTime(31*FRAMES, play_body_fall)
    inst:DoTaskInTime(40*FRAMES, play_punch)
    inst:DoTaskInTime(47*FRAMES, play_punch)
    inst:DoTaskInTime(54*FRAMES, play_punch)
    inst:DoTaskInTime(59*FRAMES, play_body_fall)
    inst:DoTaskInTime(73*FRAMES, play_body_fall)

	inst.spawn_task = inst:DoTaskInTime(104*FRAMES, SpawnMutatedHound)

	inst.components.burnable:SetOnIgniteFn(nil)
	inst.components.burnable:SetOnExtinguishFn(nil)
	inst.components.burnable:SetOnBurntFn(nil)
end

local function ontimerdone(inst, data)
    if data.name == "revive" then
		StartReviving(inst)
    end
end

local function onsave(inst, data)
    data.reviving = inst.spawn_task ~= nil
end

local function onload(inst, data)
    if data ~= nil and data.reviving then
		inst.components.timer:StopTimer("revive")
		StartReviving(inst)
    end
end

local function onignite(inst)
	inst.components.timer:StopTimer("revive")
end

local function getstatus(inst)
    return inst.spawn_task ~= nil and "REVIVING"
			or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) and "BURNING"
			or nil
end

local function RememberWargLeader(inst, warg)
	inst.components.entitytracker:TrackEntity("warg", warg)
	warg:RememberFollowerCorpse(inst)
end

local function OnLoadPostPass(inst, ents, data)
	local warg = inst.components.entitytracker:GetEntity("warg")
	if warg ~= nil then
		warg:RememberFollowerCorpse(inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.DynamicShadow:SetSize(2.5, 1.5)
	inst.Transform:SetFourFaced()

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("hound")
    inst.AnimState:SetBuild("hound")
    inst.AnimState:AddOverrideBuild("hound_basic_transformation")
    inst.AnimState:PlayAnimation("mutated_hound_reviving_pre")

	inst:AddTag("blocker")

    inst:SetPhysicsRadiusOverride(.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("entitytracker")

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("revive", TUNING.MUTATEDHOUND_SPAWN_DELAY + math.random())
    inst:ListenForEvent("timerdone", ontimerdone)

	MakeMediumBurnableCorpse(inst, TUNING.MED_BURNTIME, "hound_body", Vector3(30, -70, 0))
	inst.components.burnable:SetOnIgniteFn(onignite)

    MakeHauntableIgnite(inst)

	inst.RememberWargLeader = RememberWargLeader
	inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("houndcorpse", fn, assets, prefabs)
