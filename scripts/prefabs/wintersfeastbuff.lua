local prefabs =
{
	"wintersfeastbuff_fx",
}

local FX_FREQ_MIN = 0.25
local FX_FREQ_MAX = 1.8

local function OnTick(inst, target)
    if target.components.health ~= nil and
        not target.components.health:IsDead() and
        not target:HasTag("playerghost") then

		target.components.health:DoDelta(TUNING.WINTERSFEASTBUFF.HEALTH_GAIN, true)

		if target.components.hunger ~= nil then
			target.components.hunger:DoDelta(TUNING.WINTERSFEASTBUFF.HUNGER_GAIN, true)
		end
		--print("remaining:", inst.components.timer:GetTimeLeft("buffover"))
	else
		inst.components.debuff:Stop()
	end
end

local function CalcIntensity(inst)
	return math.min(inst.components.timer:GetTimeLeft("buffover") / TUNING.WINTERSFEASTBUFF.MAXDURATION, 1)
end

local function OnFxTick(inst, target)
	SpawnPrefab("wintersfeastbuff_fx").Transform:SetPosition(target.Transform:GetWorldPosition())

	local intensity = CalcIntensity(inst)
	inst.SoundEmitter:SetParameter("loop", "intensity", intensity)
	inst:DoTaskInTime(Remap(intensity, 0, 1, FX_FREQ_MAX, FX_FREQ_MIN), OnFxTick, inst, target)
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading

    inst.task = inst:DoPeriodicTask(TUNING.WINTERSFEASTBUFF.TICKRATE, OnTick, nil, target)
	inst.fxtask = inst:DoTaskInTime(0.5 + math.random()*0.75, OnFxTick, inst, target)
    inst:ListenForEvent("death", function()
		local durationleft = inst.components.timer:GetTimeLeft("buffover")
		if durationleft ~= nil and durationleft >= TUNING.WINTERSFEASTBUFF.MAXDURATION * TUNING.WINTERSFEASTBUFF.DROP_SPIRIT_PERCENTAGE_THRESHOLD then
			local item = SpawnPrefab("wintersfeastfuel")
			item.Transform:SetPosition(inst.Transform:GetWorldPosition())
			Launch(item, inst, 2)
		end

        inst.components.debuff:Stop()
    end, target)

	inst.SoundEmitter:PlaySound("wintersfeast2019/winters_feast/feast_buff_LP", "loop")
    inst.SoundEmitter:SetParameter("loop", "intensity", 0)
    target.components.hunger.burnratemodifiers:SetModifier(inst, 0)
    target.components.sanity.externalmodifiers:SetModifier(inst, TUNING.WINTERSFEASTBUFF.SANITY_GAIN)
end

local function OnDetached(inst, target)
    target.components.hunger.burnratemodifiers:RemoveModifier(inst)
    target.components.sanity.externalmodifiers:RemoveModifier(inst)

	if target.components.talker ~= nil then
		target.components.talker:Say(GetString(target, "ANNOUNCE_WINTERS_FEAST_BUFF_OVER"))
	end
    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function AddEffectBonus(inst, num_feasters, num_foodtypes, num_totalfood)
	num_feasters, num_foodtypes = num_feasters or 1, num_foodtypes or 1

	local timeleft = inst.components.timer:GetTimeLeft("buffover")
    --print("timeleft",timeleft)

	--local gainmultiplier = math.min((num_foodtypes - 1) / 2, 1)--

    local score = ((num_feasters^0.3)*0.3* (num_foodtypes))  + ((num_totalfood-num_foodtypes)*0.2)
    local bonus = (score * TUNING.TOTAL_DAY_TIME/2)/TUNING.WINTERSFEASTBUFF.EATTIME
--    print("Score",score,"bonus",bonus)
	if bonus > 0 then
		inst.components.timer:SetTimeLeft("buffover", timeleft + bonus )
--		print("bonus duration:", bonus)
	else
--		print("no bonus duration")
	end

	inst.SoundEmitter:SetParameter("loop", "intensity", CalcIntensity(inst))
end

local function ParticleOnEntitySleep(inst)
	inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

	inst.addeffectbonusfn = AddEffectBonus

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("buffover", TUNING.WINTERSFEASTBUFF.DURATION_GAIN_BASE)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

local function effectfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("winters_feast_fx")
    inst.AnimState:SetBank("winters_feast_fx")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(1)
    inst.AnimState:PlayAnimation(math.random(1, 10))

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	inst.OnEntitySleep = ParticleOnEntitySleep

    return inst
end

return Prefab("wintersfeastbuff", fn, nil, prefabs),
	Prefab("wintersfeastbuff_fx", effectfn, { Asset("ANIM", "anim/winters_feast_fx.zip") })
