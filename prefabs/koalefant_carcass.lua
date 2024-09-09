local assets =
{
	Asset("ANIM", "anim/koalefant_actions.zip"),
	Asset("ANIM", "anim/koalefant_summer_build.zip"),
	Asset("ANIM", "anim/koalefant_winter_build.zip"),
}

local NUM_LEVELS = 3 --NOTE: level 4 is "empty"

local function SetLevel(inst, level)
	if inst.level ~= level then
		--assert(inst.level <= NUM_LEVELS) --not supported to go backward
		if level > NUM_LEVELS then
			inst.components.burnable.fastextinguish = true
			inst:RemoveComponent("burnable")
			inst:RemoveTag("meat_carcass")
			inst.persists = false
			inst:DoTaskInTime(10, ErodeAway)
		end
		inst.level = level
		inst.AnimState:PlayAnimation("carcass"..tostring(level))
	end
end

local function SetMeat(inst, meat)
	if inst.meat ~= meat then
		inst.meat = meat
		SetLevel(inst, NUM_LEVELS + 1 - math.ceil(meat / TUNING.KOALEFANT_CARCASS_MEAT_PER_LEVEL))
	end
end

local function SetMeatPct(inst, pct)
	local maxmeat = TUNING.KOALEFANT_CARCASS_MEAT_PER_LEVEL * NUM_LEVELS
	SetMeat(inst, math.clamp(pct * maxmeat, 0, maxmeat))
end

local function OnChomped(inst, data)
	local amount = data ~= nil and data.amount or 1
	SetMeat(inst, math.max(0, inst.meat - amount))

	local anim = "carcass"..tostring(inst.level)
	local anim_shake = anim.."_shake"
	if not inst.AnimState:IsCurrentAnimation(anim_shake) or inst.AnimState:GetCurrentAnimationFrame() > 6 then
		inst.AnimState:PlayAnimation(anim_shake)
		inst.AnimState:PushAnimation(anim, false)
	end

	inst.SoundEmitter:PlaySound(
		inst:GetIsWet() and
		"dontstarve/impacts/impact_flesh_wet_dull" or
		"dontstarve/impacts/impact_flesh_lrg_dull"
	)

	inst.components.timer:SetTimeLeft("decay", TUNING.KOALEFANT_CARCASS_DECAY_TIME)
end

local function OnTimerDone(inst, data)
	if data ~= nil and data.name == "decay" then
		inst:RemoveTag("meat_carcass")
		inst:AddTag("NOCLICK")
		inst.persists = false
		ErodeAway(inst)
	end
end

local function OnSave(inst, data)
	data.meat = inst.meat < TUNING.KOALEFANT_CARCASS_MEAT_PER_LEVEL * NUM_LEVELS and math.floor(inst.meat * 10 + 0.5) * 0.1 or nil
	data.winter = inst.winter or nil
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.meat ~= nil then
			SetMeat(inst, math.clamp(data.meat, 0, TUNING.KOALEFANT_CARCASS_MEAT_PER_LEVEL * NUM_LEVELS))
		end
		if data.winter then
			inst:MakeWinter()
		end
	end
end

local function MakeWinter(inst)
	inst.winter = true
	inst.AnimState:SetBuild("koalefant_winter_build")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, 0.75, 1)

	inst.DynamicShadow:SetSize(4.5, 2)

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("koalefant")
	inst.AnimState:SetBuild("koalefant_summer_build")
	inst.AnimState:PlayAnimation("carcass1")

	inst:AddTag("meat_carcass")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.level = 1
	inst.meat = TUNING.KOALEFANT_CARCASS_MEAT_PER_LEVEL * NUM_LEVELS

	inst:AddComponent("inspectable")

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("decay", TUNING.KOALEFANT_CARCASS_DECAY_TIME)

	MakeLargeBurnableCorpse(inst, TUNING.MED_BURNTIME, "beefalo_body")
	--corpses usually disentegrate when extinguished, but we don't want that here
	inst.components.burnable:SetOnExtinguishFn(nil)

	inst:ListenForEvent("chomped", OnChomped)
	inst:ListenForEvent("timerdone", OnTimerDone)

	inst.SetMeatPct = SetMeatPct
	inst.MakeWinter = MakeWinter
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end

return Prefab("koalefant_carcass", fn, assets)
