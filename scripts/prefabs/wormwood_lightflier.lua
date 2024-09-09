local assets =
{
    Asset("ANIM", "anim/lightflier.zip"),
}

local prefabs = {
    "lightbulb",
    "wormwood_lunar_transformation_finish",
}


local brain = require "brains/wormwood_lightflierbrain"


local function EnableBuzz(inst, enable)
    if enable then
        if not inst.buzzing then
            inst.buzzing = true
            if not (inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
                inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/fly_LP", "loop")
            end
        end
    elseif inst.buzzing then
        inst.buzzing = false
        inst.SoundEmitter:KillSound("loop")
    end
end

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local bulb = SpawnPrefab("lightbulb")
    bulb.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(bulb)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetPosition(ix, iy, iz)

    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "finish_transformed_life" then
        finish_transformed_life(inst)
    end
end



local FORMATION_MAX_SPEED = 10.5
local FORMATION_RADIUS = 5.5
local FORMATION_ROTATION_SPEED = 0.5
local function OnUpdate(inst, dt)
    local leader = inst.components.follower and inst.components.follower:GetLeader() or nil
    if leader and leader.wormwood_lightflier_pattern and inst.brain and not inst.brain.stopped then
        local index = (leader.wormwood_lightflier_pattern[inst] or 1) - 1
        local maxpets = leader.wormwood_lightflier_pattern.maxpets

        local theta = (index / maxpets) * TWOPI + GetTime() * FORMATION_ROTATION_SPEED
        local lx, ly, lz = leader.Transform:GetWorldPosition()

        lx, lz = lx + FORMATION_RADIUS * math.cos(theta), lz + FORMATION_RADIUS * math.sin(theta)

        local px, py, pz = inst.Transform:GetWorldPosition()
        local dx, dz = px - lx, pz - lz
        local dist = math.sqrt(dx*dx + dz*dz)

        inst.components.locomotor.walkspeed = math.min(dist * 8, FORMATION_MAX_SPEED)
        inst:FacePoint(lx, 0, lz)
        if inst.updatecomponents[inst.components.locomotor] == nil then
            inst.components.locomotor:WalkForward(true)
        end
    end
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash and data.attacker.components.petleash:IsPet(inst) then
            local timer = inst.components.timer
            if timer and timer:TimerExists("finish_transformed_life") then
                timer:StopTimer("finish_transformed_life")
				finish_transformed_life(inst)
            end
        end
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeGhostPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(1, .5)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("lightflier")
    inst.AnimState:SetBuild("lightflier")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetScale(.8, .8)
    inst.AnimState:SetSymbolMultColour("lightbulb", 0.7, 1, 0.7, 1)

    inst.scrapbook_deps = {"lightbulb"}

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1.8)
    inst.Light:SetColour(237/255 * 0.7, 237/255, 209/255 * 0.7)
    inst.Light:Enable(true)

    inst:AddTag("lightflier")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("lightbattery")
    inst:AddTag("lunar_aligned")

    inst:AddTag("NOBLOCK")
    inst:AddTag("notraptrigger")
    inst:AddTag("wormwood_pet")
    inst:AddTag("noauradamage")
    inst:AddTag("soulless")

    MakeInventoryFloatable(inst)

    inst:SetPrefabNameOverride("lightflier")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- inst._formation_distribution_toggle = nil
    -- inst._find_target_task = nil
    inst._time_since_formation_attacked = -TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:SetStateGraph("SGwormwood_lightflier")
    inst:SetBrain(brain)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "lightbulb"
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LIGHTFLIER.HEALTH)

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:AddComponent("homeseeker")

    MakeSmallBurnableCharacter(inst, "lightbulb")
    MakeSmallFreezableCharacter(inst, "lightbulb")

    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/fly_LP", "loop")

    inst.EnableBuzz = EnableBuzz

    local timer = inst:AddComponent("timer")
	timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_LIGHTFLIER_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.no_spawn_fx = true
    inst.RemoveWormwoodPet = finish_transformed_life

    local updatelooper = inst:AddComponent("updatelooper")
    updatelooper:AddOnUpdateFn(OnUpdate)

    return inst
end

return Prefab("wormwood_lightflier", fn, assets, prefabs)
