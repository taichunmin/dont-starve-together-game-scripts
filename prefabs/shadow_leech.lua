local assets =
{
	Asset("ANIM", "anim/shadow_leech.zip"),
}

local prefabs =
{
	"nightmarefuel",
}

local brain = require("brains/shadow_leechbrain")

local LOOT = { "nightmarefuel" }

local function CalcSanityAura(inst, observer)
	return observer.components.sanity:IsCrazy()
		and -TUNING.SANITYAURA_MED
		or 0
end

local function ToggleBrain(inst, enable)
	if enable then
		inst:SetBrain(brain)
		if inst.brain == nil and not inst:IsAsleep() then
			inst:RestartBrain()
		end
	else
		inst:SetBrain(nil)
	end
end

local function StartTrackingDaywalker(inst, daywalker)
	inst.components.entitytracker:TrackEntity("daywalker", daywalker)
	if daywalker.StartTrackingLeech ~= nil then
		daywalker:StartTrackingLeech(inst)
	end
end

local function OnSpawnFor(inst, daywalker, delay)
	StartTrackingDaywalker(inst, daywalker)
	inst:ForceFacePoint(daywalker.Transform:GetWorldPosition())
	inst.sg:GoToState("spawn_delay", delay)
end

local function OnFlungFrom(inst, daywalker, speedmult, randomdir)
	inst.Follower:StopFollowing()

	local x, y, z = daywalker.Transform:GetWorldPosition()
	local rot = randomdir and math.random() * 360 or daywalker.Transform:GetRotation() + math.random() * 10 - 5
	inst.Transform:SetRotation(rot + 180) --flung backwards
	rot = rot * DEGREES
	speedmult = speedmult or 1
	inst.Physics:Teleport(x + math.cos(rot) * speedmult, y, z - math.sin(rot) * speedmult)
	inst.sg:GoToState("flung", speedmult)
end

local function OnLoadPostPass(inst)--, ents, data)
	local daywalker = inst.components.entitytracker:GetEntity("daywalker")
	if daywalker ~= nil and daywalker.StartTrackingLeech ~= nil then
		daywalker:StartTrackingLeech(inst)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	MakeCharacterPhysics(inst, 10, 0.9)
	inst.Physics:ClearCollisionMask()
	inst.Physics:SetCollisionGroup(COLLISION.SANITY)
	inst.Physics:CollidesWith(COLLISION.SANITY)
	inst.Physics:CollidesWith(COLLISION.WORLD)

	inst.Transform:SetSixFaced()

	inst:AddTag("shadowcreature")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("shadow")
	inst:AddTag("notraptrigger")
	inst:AddTag("shadow_aligned")

	inst.AnimState:SetBank("shadow_leech")
	inst.AnimState:SetBuild("shadow_leech")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetMultColour(1, 1, 1, .5)

	if not TheNet:IsDedicated() then
		-- this is purely view related
		inst:AddComponent("transparentonsanity")
		inst.components.transparentonsanity.most_alpha = .8
		inst.components.transparentonsanity.osc_amp = .1
		inst.components.transparentonsanity:ForceUpdate()
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("entitytracker")

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aurafn = CalcSanityAura

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.SHADOW_LEECH_HEALTH)
	inst.components.health.nofadeout = true

	inst:AddComponent("combat")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(LOOT)

	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = TUNING.SHADOW_LEECH_RUNSPEED
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = { ignorecreep = true }

	inst:SetStateGraph("SGshadow_leech")
	inst:SetBrain(brain)

	inst.ToggleBrain = ToggleBrain
	inst.OnSpawnFor = OnSpawnFor
	inst.OnFlungFrom = OnFlungFrom
	inst.OnLoadPostPass = OnLoadPostPass

	return inst
end

return Prefab("shadow_leech", fn, assets, prefabs)
