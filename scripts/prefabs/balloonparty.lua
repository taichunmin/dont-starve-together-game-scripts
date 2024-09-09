
local BALLOONS = require "prefabs/balloons_common"

local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/balloon.zip"),
    Asset("ANIM", "anim/balloon2.zip"),
    Asset("ANIM", "anim/balloon_shapes_party.zip"),
    Asset("SCRIPT", "scripts/prefabs/balloons_common.lua"),
}

local assets_confetti =
{
    Asset("ANIM", "anim/wes_confetti.zip"),
    Asset("ANIM", "anim/wes_balloon_party.zip"),
}

local prefabs =
{
    "balloon_held_child", -- used in balloons_common.OnEquip_Hand
	"balloonparty_confetti_balloon",
	"balloonparty_confetti_cloud",
	"balloonparty_buff",
}

local function onsave(inst, data)
    data.num = inst.balloon_num
    data.colour_idx = inst.colour_idx
end

local function onload(inst, data)
    if data ~= nil then
        if data.num ~= nil and inst.balloon_num ~= data.num then
            inst.balloon_num = data.num
            inst.AnimState:OverrideSymbol("swap_balloon", inst.balloon_build, "balloon_"..tostring(inst.balloon_num))
        end
        if data.colour_idx ~= nil then
			inst.colour_idx = BALLOONS.SetColour(inst, data.colour_idx)
        end
    end
end

local function oncollide(inst, other)
    if (inst:IsValid() and Vector3(inst.Physics:GetVelocity()):LengthSq() > .1) or
        (other ~= nil and other:IsValid() and other.Physics ~= nil and Vector3(other.Physics:GetVelocity()):LengthSq() > .1) then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function onpop(inst)
	inst:DoTaskInTime(FRAMES * 5, function()
		local fx = SpawnPrefab("balloonparty_confetti_cloud")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end)

	BALLOONS.DoPop_Floating(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	BALLOONS.MakeFloatingBallonPhysics(inst)

    inst.AnimState:SetBank("balloon2")
    inst.AnimState:SetBuild("balloon2")
    inst.AnimState:OverrideSymbol("swap_balloon", "balloon_shapes_party", "balloon_1")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst.DynamicShadow:SetSize(1, .5)

    inst:AddTag("nopunch")
    inst:AddTag("cattoyairborne")
    inst:AddTag("balloon")
    inst:AddTag("noepicmusic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.balloon_build = "balloon_shapes_party"

	BALLOONS.MakeBalloonMasterInit(inst, onpop)

    inst.Physics:SetCollisionCallback(oncollide)

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst.balloon_num = 1

    BALLOONS.SetRopeShape(inst)

    inst.scrapbook_overridedata={}
    table.insert( inst.scrapbook_overridedata, {"swap_balloon", "balloon_shapes_party", "balloon_1"})
    table.insert( inst.scrapbook_overridedata, {"swap_rope", "balloon2", "rope_1"})


	--inst.colour_idx = BALLOONS.SetColour(inst)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(BALLOONS.OnEquip_Hand)
    inst.components.equippable:SetOnUnequip(BALLOONS.OnUnequip_Hand)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local CONFFETI_CLOUD_DIST = 2.6
local CONFFETI_CLOUD_DIST_SQ = CONFFETI_CLOUD_DIST*CONFFETI_CLOUD_DIST
local CONFFETI_PARTY_DIST = 4

local function ApplyBuff(inst)
	-- find all players near CONFFETI_CLOUD_DIST, add partyballoon_buff
	local x, y, z = inst.Transform:GetWorldPosition()
	for i, v in ipairs(AllPlayers) do
	    local x1, y1, z1 = v.Transform:GetWorldPosition()
		if distsq(x, z, x1, z1) < CONFFETI_CLOUD_DIST_SQ then
            v:AddDebuff("balloonparty_buff", "balloonparty_buff")
		end
	end
end

local function confetti_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("wes_confetti")
    inst.AnimState:SetBuild("wes_confetti")
    inst.AnimState:PlayAnimation("confetti_pre")

    inst.SoundEmitter:PlaySound("wes/characters/wes/balloon_party")

    inst:AddTag("confetti_cloud")
    inst:AddTag("FX")

    inst.entity:SetPristine()

	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, function(_inst)
			local x, y, z = _inst.Transform:GetWorldPosition()
			local r = 1.0
			local mini_balloons = SpawnPrefab("balloonparty_confetti_balloon")
			mini_balloons.Transform:SetPosition(x + math.random()*r, y, z + math.random()*r)

			mini_balloons = SpawnPrefab("balloonparty_confetti_balloon")
			mini_balloons.Transform:SetPosition(x + math.random()*r, y, z + math.random()*r)

			mini_balloons = SpawnPrefab("balloonparty_confetti_balloon")
			mini_balloons.Transform:SetPosition(x + math.random()*r, y, z + math.random()*r)

			mini_balloons = SpawnPrefab("balloonparty_confetti_balloon")
			mini_balloons.Transform:SetPosition(x + math.random()*r, y, z + math.random()*r)
		end)
	end

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("confetti_loop", false)
    inst.AnimState:PushAnimation("confetti_loop", false)
    inst.AnimState:PushAnimation("confetti_loop", false)
    inst.AnimState:PushAnimation("confetti_loop", false)
    inst.AnimState:PushAnimation("confetti_pst", false)

	inst:ListenForEvent("animqueueover", inst.Remove)
	--inst.SoundEmitter:PlaySound("dontstarve_DLC001/fall/leaf_rustle")

	inst:DoPeriodicTask(1, ApplyBuff, 0.5)
    return inst
end

local COUNT_PARTYGOERS_TAGS = {"CLASSIFIED", "confetti_buff"}
local COUNT_PARTYCONFETTI_TAGS = {"confetti_cloud"}

local function buff_OnTick(inst, target)
	local x, y, z = target.Transform:GetWorldPosition()
    if target.components.health ~= nil
        and not target.components.health:IsDead()
		and target.components.sanity ~= nil
        and not target:HasTag("playerghost")
		and #TheSim:FindEntities(x, y, z, CONFFETI_CLOUD_DIST, {"confetti_cloud"}) > 0
		then
			local partysize = TheSim:CountEntities(x, y, z, CONFFETI_PARTY_DIST, COUNT_PARTYGOERS_TAGS) + TheSim:CountEntities(x, y, z, CONFFETI_PARTY_DIST, COUNT_PARTYCONFETTI_TAGS)
			if partysize > 0 then
				local delta = TUNING.CONFFETI_PARTY_SANITY_DELTA[math.min(partysize, #TUNING.CONFFETI_PARTY_SANITY_DELTA)]
				--print("buff_OnTick tick", inst, partysize, TUNING.CONFFETI_PARTY_SANITY_DELTA[math.min(partysize, #TUNING.CONFFETI_PARTY_SANITY_DELTA)])
				if delta > 0 then
					target.components.sanity:DoDelta(delta)
				end
			end
    else
		--print("buff_OnTick done", inst)
        inst.components.debuff:Stop()
    end
end

local function buff_OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
    inst.task = inst:DoPeriodicTask(TUNING.CONFFETI_PARTY_SANITY_TICKRATE, buff_OnTick, nil, target)
	buff_OnTick(inst, target)
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function buff_fn(tunings, dodelta_fn)
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

	inst.potion_tunings = tunings

    inst:AddTag("confetti_buff")
    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff.keepondespawn = true

    return inst
end

local function confettiballoon_updatemotorvel(inst, xvel, yvel, zvel, t0)
    local x, y, z = inst.Transform:GetWorldPosition()
    local time = GetTime() - t0
    if y >= 35 or time >= 15 then
        inst:Remove()
        return
    end

	local hthrottle = easing.inQuad(math.clamp(time - 1, 0, 3), 0, 1, 3)
	yvel = easing.inQuad(math.min(time, 3), 2.5, yvel - 1, 3)
	inst.Physics:SetMotorVel(xvel * hthrottle, yvel, zvel * hthrottle)
end

local function confettiballoon_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

	local phys = inst.entity:AddPhysics()
	phys:SetMass(1)
	phys:SetFriction(.1)
	phys:SetDamping(0)
	phys:SetRestitution(.5)
	phys:SetSphere(0.5)

    inst.AnimState:SetBank("wes_balloon_party")
    inst.AnimState:SetBuild("wes_balloon_party")
    inst.AnimState:PlayAnimation("float", true)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
	BALLOONS.SetColour(inst)

	local s = 0.9 + math.random() * 0.1
	inst.Transform:SetScale(s, s, s)

    inst:AddTag("CLASSIFIED")
    inst:AddTag("FX")

    local xvel = math.random() * 4 - 2
    local yvel = 5
    local zvel = math.random() * 4 - 2
	inst:DoPeriodicTask(0, confettiballoon_updatemotorvel, nil, xvel, yvel, zvel, GetTime())
	confettiballoon_updatemotorvel(inst, xvel, yvel, zvel, GetTime())

    return inst
end


return Prefab("balloonparty", fn, assets, prefabs),
	Prefab("balloonparty_confetti_cloud", confetti_fn, assets_confetti),
	Prefab("balloonparty_confetti_balloon", confettiballoon_fn, assets_confetti),
	Prefab("balloonparty_buff", buff_fn)