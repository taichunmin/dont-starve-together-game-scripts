require("stategraphs/commonstates")

local assets =
{
    Asset("ANIM", "anim/antlion_sinkhole.zip"),
}

local prefabs =
{
    "sinkhole_spawn_fx_1",
    "sinkhole_spawn_fx_2",
    "sinkhole_spawn_fx_3",
    "mining_ice_fx",
    "mining_fx",
    "mining_moonglass_fx",
}

local NUM_CRACKING_STAGES = 1
local COLLAPSE_STAGE_DURATION = 1
local OBJECT_SCALE = 0.6

local NUM_FX = 7
local FX_THETA_DELTA = TWOPI / NUM_FX
local FX_RADIUS = 1.6
local function SpawnFx(inst, scale, pos)
    local theta = math.random() * TWOPI

    pos = pos or inst:GetPosition()

    -- Spawn an fx at the middle of the sinkhole.
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())

    -- Spawn an fx around the edges of the sinkhole circle.
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))

        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )

        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)

        theta = theta + FX_THETA_DELTA
    end

    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "repair" then
        if not inst:IsAsleep() then
			SpawnFx(inst, inst.scale / 2)
        end

        inst.components.unevenground:Disable()
        inst.persists = false
        ErodeAway(inst)
    end
end

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * .5 + math.random()
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 3 * speed + math.random(), math.sin(angle) * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "flying", "bird", "ghost", "locomotor", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoCollapse(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, inst.radius * 6)

    inst.components.unevenground:Enable()

    local pos = inst:GetPosition()
	SpawnFx(inst, inst.scale, pos)

    local ents = TheSim:FindEntities(
        pos.x, 0, pos.z,
        inst.radius + 1, nil,
        NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS
    )

    for _, collapsible_entity in ipairs(ents) do
        local isworkable = false

        if collapsible_entity.components.workable ~= nil then
            local work_action = collapsible_entity.components.workable:GetWorkAction()
            --V2C: nil action for NPC_workable (e.g. campfires)
            --     allow digging spawners (e.g. rabbithole)
            isworkable = (
                (work_action == nil and collapsible_entity:HasTag("NPC_workable")) or
                (collapsible_entity.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
            )
        end

		-- Work the object a little if it can be worked (or destroy if inst.maxwork is true),
        -- and pick stuff that can be picked.
        if isworkable then
			if inst.maxwork then
				collapsible_entity.components.workable:Destroy(inst)
			else
				if collapsible_entity.components.workable:GetWorkAction() == ACTIONS.MINE then
					PlayMiningFX(inst, collapsible_entity, true)
				end
				collapsible_entity.components.workable:WorkedBy(inst, 1)
			end
            if collapsible_entity:IsValid() and collapsible_entity:HasTag("stump") then
                collapsible_entity:Remove()
            end
        elseif collapsible_entity.components.pickable ~= nil
                and collapsible_entity.components.pickable:CanBePicked()
                and not collapsible_entity:HasTag("intense") then

			collapsible_entity.components.pickable:Pick(inst)
        end
    end

    local totoss = TheSim:FindEntities(pos.x, 0, pos.z, inst.radius, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for _, tossible_entity in ipairs(totoss) do
        if tossible_entity.components.mine ~= nil then
            tossible_entity.components.mine:Deactivate()
        end
        if not tossible_entity.components.inventoryitem.nobounce
                and (tossible_entity.Physics ~= nil and tossible_entity.Physics:IsActive()) then
            SmallLaunch(tossible_entity, inst, 1.5)
        end
    end

    inst.components.timer:StartTimer("repair", 20)
end

-------------------------------------------------------------------------------

local function OnLoad(inst)--, data)
	if inst.components.timer:TimerExists("repair") then
        inst.components.unevenground:Enable()
    end
end

local function OnLoadPostPass(inst)--, newents, data)
	if inst.persists and not inst.components.timer:TimerExists("repair") then
		--backup, in case sinkholes got spawned and never started collapsing
		inst:Remove()
	end
end

-------------------------------------------------------------------------------

local function MakeSinkhole(name, radius, scale, maxwork, toughworker)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		inst.AnimState:SetBank("sinkhole")
		inst.AnimState:SetBuild("antlion_sinkhole")
		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
		inst.AnimState:SetLayer(LAYER_BACKGROUND)
		inst.AnimState:SetSortOrder(2)
		inst.AnimState:SetScale(scale, scale)

		inst.Transform:SetEightFaced()

		inst:AddTag("antlion_sinkhole")
		inst:AddTag("antlion_sinkhole_blocker")
		inst:AddTag("NOCLICK")

		if toughworker then
			inst:AddTag("toughworker")
		end

		inst:SetDeploySmartRadius(3 * scale)

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst.radius = radius
		inst.scale = scale
		inst.maxwork = maxwork

		inst:AddComponent("timer")

		inst:AddComponent("unevenground")
		inst.components.unevenground.radius = radius

		inst:ListenForEvent("docollapse", DoCollapse)
		inst:ListenForEvent("timerdone", OnTimerDone)

		inst.OnLoad = OnLoad
		inst.OnLoadPostPass = OnLoadPostPass

		return inst
	end

	return Prefab(name, fn, assets, prefabs)
end

return MakeSinkhole("eyeofterror_sinkhole", TUNING.EYEOFTERROR_CHOMP_SINKHOLERADIUS, OBJECT_SCALE, false, false),
	MakeSinkhole("daywalker_sinkhole", TUNING.DAYWALKER_SLAM_SINKHOLERADIUS, 1, true, true),
	MakeSinkhole("bearger_sinkhole", TUNING.MUTATED_BEARGER_SINKHOLERADIUS, 1, true, true)
