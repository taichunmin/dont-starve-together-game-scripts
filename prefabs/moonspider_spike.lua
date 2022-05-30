local assets =
{
    Asset("ANIM", "anim/spider_spike.zip"),
}

local prefabs =
{
    "erode_ash",
}

local NUM_VARIATIONS = 3

local function KeepTargetFn()
    return false
end

local ATTACK_RADIUS = 0.5

local function shouldhit(inst, target)
	-- not casting spider
    if inst.spider == target then
		return false
	end

	-- other player's and their followers
	if inst.spider_leader_isplayer and not TheNet:GetPVPEnabled()
		and (target:HasTag("player") or (target.components.follower ~= nil and target.components.follower.leader ~= nil and target.components.follower.leader:HasTag("player"))) then
		return false
	end

	-- if the spider has a leader, check if the target is on the same team
    if inst.spider_leader ~= nil then
        return not (inst.spider_leader == target or (target.components.follower ~= nil and target.components.follower.leader == inst.spider_leader))
    end

	return not target:HasTag("spider_moon")
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "flying", "shadow", "ghost", "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }

local function DoAttack(inst)
	local attacker = (inst.spider ~= nil and inst.spider:IsValid()) and inst.spider or inst
	local old_damage = attacker.components.combat.defaultdamage

    attacker.components.combat.ignorehitrange = true
    attacker.components.combat:SetDefaultDamage(TUNING.SPIDER_MOON_SPIKE_DAMAGE)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, ATTACK_RADIUS + 3, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS)) do
        if v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and shouldhit(inst, v) then
            local range = ATTACK_RADIUS + v:GetPhysicsRadius(.5)
            if v:GetDistanceSqToPoint(x, y, z) < range * range and inst.components.combat:CanTarget(v) then
                attacker.components.combat:DoAttack(v)
            end
        end
    end
    attacker.components.combat.ignorehitrange = false
    attacker.components.combat:SetDefaultDamage(old_damage)
end

local function KillSpike(inst)
	if not inst.killed then
		if inst.attack_task ~= nil then
			inst.attack_task:Cancel()
			inst.attack_task = nil
			inst:Remove()
		else
			inst.killed = true

			if inst.lifespan_task ~= nil then
				inst.lifespan_task:Cancel()
				inst.lifespan_task = nil
			end

			inst.AnimState:PlayAnimation("spike_pst")
			DoAttack(inst)
            inst.SoundEmitter:PlaySound("turnoftides/creatures/together/spider_moon/break")
			inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)
		end
	end
end

local function StartAttack(inst)
	inst.attack_task = nil

    inst.AnimState:PlayAnimation("spike_pre")
    inst.SoundEmitter:PlaySoundWithParams("turnoftides/creatures/together/spider_moon/spike", {intensity= math.random()})
    inst.AnimState:PushAnimation("spike_loop")

    inst.lifespan_task = inst:DoTaskInTime(2 + math.random() * 0.5, KillSpike)

	DoAttack(inst)
end

local function SetOwner(inst, spider)
	inst.spider = spider
	inst.spider_leader = spider.components.follower ~= nil and spider.components.follower.leader or nil
	inst.spider_leader_isplayer = inst.spider_leader ~= nil and inst.spider_leader:HasTag("player")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("spider_spike")
    inst.AnimState:SetBuild("spider_spike")
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")
    inst:AddTag("groundspike")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_MOON_SPIKE_DAMAGE)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst.persists = false

	inst.KillSpike = function() KillSpike(inst) end

	inst.attack_task = inst:DoTaskInTime(math.random() * 0.25, StartAttack)

	inst.SetOwner = SetOwner

    return inst
end

return Prefab("moonspider_spike", fn, assets, prefabs)
