local assets =
{
	Asset("ANIM", "anim/cookiecutter_build.zip"),
	Asset("ANIM", "anim/cookiecutter.zip"),
	Asset("ANIM", "anim/cookiecutter_water.zip"),
}

local prefabs =
{
    "monstermeat",
	"cookiecuttershell",
	"wood_splinter_jump",
	"wood_splinter_drill",
	"splash",

	"fx_kelp_boat_fluff",
}

local brain = require("brains/cookiecutterbrain")

SetSharedLootTable("cookiecutter",
{
    {"monstermeat",			1.00},
    {"cookiecuttershell",	0.50},
    {"cookiecuttershell",	0.25},
})

local function OnAttacked(inst, data)
	if inst.sg == nil or (not inst.sg:HasStateTag("drilling") and not inst.sg:HasStateTag("jumping")) then
		inst.target_wood = nil
		inst.is_fleeing = true
		inst:AddTag("scarytocookiecutters")
		if inst.onattacked_task ~= nil then
			inst.onattacked_task:Cancel()
		end
		inst.onattacked_task = inst:DoTaskInTime(TUNING.COOKIECUTTER.FLEE_DURATION, function()
			inst.is_fleeing = false
			inst:RemoveTag("scarytocookiecutters")
		end)
	end
end

local function DoReturn(inst)
	local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
	if home ~= nil and home.components.childspawner ~= nil then
		home.components.childspawner:GoHome(inst)
	else
		inst:Remove()
	end
end

local function findtargetcheck(target)
	local x, y, z = target.Transform:GetWorldPosition()
	return TheWorld.Map:IsOceanAtPoint(x, y, z, target:HasTag("boat"))
end

local function CanTargetBoats(inst)
	return not inst.is_fleeing and (inst.components.eater == nil or inst.components.eater:HasBeen(TUNING.COOKIECUTTER.EAT_DELAY))
end

local COOKIECUTTER_TAGS = {"cookiecutter"}
local function ShareBoatTarget(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local other_cookiecutters = TheSim:FindEntities(x, y, z, TUNING.COOKIECUTTER.BOAT_DETECTION_SHARE_DIST, COOKIECUTTER_TAGS)
	for k, v in pairs(other_cookiecutters) do
		if v.target_wood == nil and CanTargetBoats(v) then
			v.target_wood = inst.target_wood
		end
	end
end

local function ValidateTargetWood(inst)
	local wood = inst.target_wood
	return (wood ~= nil and wood:IsValid()
			and inst:IsNear(wood, TUNING.COOKIECUTTER.BOAT_DETECTION_DIST + TUNING.COOKIECUTTER.BOAT_DETECTION_SHARE_DIST + 1) -- max follow dist
			and not (wood:HasTag("INLIMBO") or wood:HasTag("fire") or wood:HasTag("smolder")))
			and wood
			or nil
end

local FINDEDIBLE_CANT_TAGS = { "INLIMBO", "fire", "smolder" }
local FINDEDIBLE_ONEOF_TAGS = { "wood", "edible_WOOD" }
local function CheckForBoats(inst)
	if inst.sg ~= nil and not (inst.sg:HasStateTag("drilling") or inst.sg:HasStateTag("jumping") or inst.sg:HasStateTag("busy")) then
		if not CanTargetBoats(inst) then
			inst.target_wood = nil
		else
			inst.target_wood = FindEntity(inst, TUNING.COOKIECUTTER.BOAT_DETECTION_DIST, findtargetcheck, nil, FINDEDIBLE_CANT_TAGS, FINDEDIBLE_ONEOF_TAGS)
								or ValidateTargetWood(inst)

			if inst.target_wood ~= nil then
				ShareBoatTarget(inst)
			end
		end
	end
end

local function OnEatFn(inst)
	inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/bite")
end

local function ValidateSpawnPt(inst)
	inst.onspawntask = nil
	if TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) then
		inst:Remove()
		return false
	end

	return true
end

local function OnEntitySleep(inst)
	if inst.findtargetstask ~= nil then
		inst.findtargetstask:Cancel()
		inst.findtargetstask = nil
	end
end

local function OnEntityWake(inst)
	if inst.findtargetstask ~= nil then
		inst.findtargetstask:Cancel()
	end
	inst.findtargetstask = inst:DoPeriodicTask(.25, CheckForBoats)
end

local BOAT_TAGS = { "boat" }
local function OnLoadPostPass(inst)
	if inst.onspawntask ~= nil then
		inst.onspawntask:Cancel()
		inst.onspawntask = nil
	end
	if ValidateSpawnPt(inst) then
		if FindEntity(inst, TUNING.MAX_WALKABLE_PLATFORM_RADIUS, nil, BOAT_TAGS) ~= nil then
			inst.sg:GoToState("resurface", true)
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .6)

    inst.Transform:SetSixFaced()

    inst:AddTag("monster")
	inst:AddTag("smallcreature")
    inst:AddTag("hostile")
	inst:AddTag("cookiecutter")
	inst:AddTag("ignorewalkableplatformdrowning")

    inst.AnimState:SetBank("cookiecutter")
    inst.AnimState:SetBuild("cookiecutter_build")
    inst.AnimState:PlayAnimation("idle")

	inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor.runspeed = TUNING.COOKIECUTTER.RUN_SPEED
	inst.components.locomotor.walkspeed = TUNING.COOKIECUTTER.WANDER_SPEED
	inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

	inst:AddComponent("knownlocations")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.COOKIECUTTER.HEALTH)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("saltydog/creatures/cookiecutter/hit")
	inst.components.combat.defaultdamage = TUNING.COOKIECUTTER.DAMAGE

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("cookiecutter")

    inst:AddComponent("inspectable")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.WOOD }, { FOODTYPE.WOOD })
	inst.components.eater:SetOnEatFn(OnEatFn)

	inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
	inst.components.sleeper.sleeptestfn = nil -- they don't sleep at night or day

	inst:AddComponent("cookiecutterdrill")
	inst.components.cookiecutterdrill.drill_duration = TUNING.COOKIECUTTER.DRILL_TIME

	inst:SetStateGraph("SGcookiecutter")
    inst:SetBrain(brain)

    MakeHauntablePanic(inst)

	inst.onspawntask = inst:DoTaskInTime(0, function(i) ValidateSpawnPt(i) end)

	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	inst.DoReturnHome = DoReturn

	inst.OnLoadPostPass = OnLoadPostPass

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("cookiecutter", fn, assets, prefabs)
