    local assets =
{
    Asset("ANIM", "anim/shark_basic.zip"),
    Asset("ANIM", "anim/shark_basic_water.zip"),
    Asset("ANIM", "anim/shark_build.zip"),
}

local prefabs =
{
    "splash_green",
    "splash_green_large",
}

local SHARE_TARGET_DIST = 30
local JUMPDIST = 8
local CHARGEDIST = 10

local brain = require("brains/sharkbrain")

-- 3-5 fishmeat, 1-3 barnacle, 2-3 flint, 3-5 rocks, 0-1 oceanfish_medium_2_inv
SetSharedLootTable( 'shark',
{
    {'fishmeat',            1.00},
    {'fishmeat',            1.00},
    {'fishmeat',            1.00},
    {'fishmeat',            0.50},
    {'fishmeat',            0.25},

    {'barnacle',            1.00},
    {'barnacle',            0.50},
    {'barnacle',            0.25},

    {'flint',               1.00},
    {'flint',               1.00},
    {'flint',               0.50},
    
    {'rocks',               1.00},
    {'rocks',               1.00},
    {'rocks',               1.00},
    {'rocks',               0.50},
    {'rocks',               0.50},
    
    {'oceanfish_medium_2_inv', 0.15},
})

local sounds = {
    -- pant = "dontstarve/creatures/hound/pant",
    -- attack = "dontstarve/creatures/hound/attack",
    -- bite = "dontstarve/creatures/hound/bite",
    -- bark = "dontstarve/creatures/hound/bark",
    -- death = "dontstarve/creatures/hound/death",
    -- sleep = "dontstarve/creatures/hound/sleep",
    -- growl = "dontstarve/creatures/hound/growl",
    -- howl = "dontstarve/creatures/together/clayhound/howl",
    -- hurt = "dontstarve/creatures/hound/hurt",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    return false
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    if data.target:GetDistanceSqToInst(inst) < CHARGEDIST*CHARGEDIST then
        inst.components.timer:StartTimer("getdistance", 3)
    end

end

local function KeepTarget(inst, target)
    if target then
        local x,y,z = target.Transform:GetWorldPosition()
        if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
            return true
        end
    end
end

local function Retarget(inst)
    return FindEntity(
                inst,
                TUNING.SHARK.TARGET_DIST,
                function(guy)
                    local x,y,z = guy.Transform:GetWorldPosition()
                    if not guy:HasTag("shark") and not inst.components.timer:TimerExists("calmtime") and not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
                        return inst.components.combat:CanTarget(guy)
                    end
                end
            )
        or nil
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead()) and dude:HasTag("shark")
        end, 5)
    inst.components.timer:StopTimer("calmtime")
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead()) and dude:HasTag("shark")
        end, 5)
end

local function removefood(inst,target)
    inst.foodtoeat = nil
end

local function testfooddist(inst)
    if not inst.foodtoeat then
        local action = inst:GetBufferedAction()
        if action and action.target and action.target:IsValid() and action.target:HasTag("oceanfish") then
            inst.foodtoeat = action.target
            inst.components.timer:StartTimer("gobble_cooldown", 2 + math.random()*15)
        end
    end
    if inst.foodtoeat then
        if inst.foodtoeat:IsValid() then
            if inst.foodtoeat:GetDistanceSqToInst(inst) < 6*6 then
                inst:PushEvent("dive_eat")
            end
        else
            inst.foodtoeat = nil
        end
    end
end

local UP_VECTOR = Vector3(0, 1, 0)
local SEPARATION_AMOUNT = 25.0
local SEPARATION_MUST_NOT_TAGS = {"flying", "FX", "DECOR", "INLIMBO"}
local SEPARATION_MUST_ONE_TAGS = {"blocker", "shark"}
local MAX_STEER_FORCE = 2.0
local MAX_STEER_FORCE_SQ = MAX_STEER_FORCE*MAX_STEER_FORCE
local DESIRED_BOAT_DISTANCE = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4
local function GetFormationOffsetNormal(inst,boat_velocity)
    if not inst.targetboat then
        return Vector3(1, 0, 0)
    end

    local my_location = inst:GetPosition()

    -- calculate desired position
    local boat_p_position = inst.targetboat:GetPosition()
    local mtlp_normal, mtlp_length = (boat_p_position - my_location):GetNormalizedAndLength()

    local boat_direction, boat_speed = boat_velocity:GetNormalizedAndLength()
    local my_locomotor = inst.components.locomotor
    local inst_move_speed = (my_locomotor.isrunning and my_locomotor:GetRunSpeed()) or my_locomotor:GetWalkSpeed()
    local speed = math.min(boat_speed, inst_move_speed)

    -- separation steering --
    local separation_steering = Vector3(0, 0, 0)
    local mx, my, mz = inst.Transform:GetWorldPosition()
    local separation_entities = TheSim:FindEntities(mx, my, mz, SEPARATION_AMOUNT, nil, SEPARATION_MUST_NOT_TAGS, SEPARATION_MUST_ONE_TAGS)
    local separation_affecting_ents_count = 0
    for _, se in ipairs(separation_entities) do
        if se ~= inst then
            -- Generate a vector pointing directly away from this entity, length inversely proportional to its distance away
            local se_to_me_normal, se_to_me_length = (my_location - se:GetPosition()):GetNormalizedAndLength()
            separation_steering = separation_steering + (se_to_me_normal * speed / se_to_me_length)
            separation_affecting_ents_count = separation_affecting_ents_count + 1
        end
    end
    if separation_affecting_ents_count > 0 then
        separation_steering = separation_steering / separation_affecting_ents_count
    end
    if separation_steering:LengthSq() > 0 then
        local recalculated_separation_steering = (separation_steering:Normalize() * speed) - (mtlp_normal * speed)
        if recalculated_separation_steering:LengthSq() > MAX_STEER_FORCE_SQ then
            recalculated_separation_steering = recalculated_separation_steering:GetNormalized() * MAX_STEER_FORCE
        end
        separation_steering = recalculated_separation_steering
    end
    -- separation steering --

    local desired_position_offset = mtlp_normal * (mtlp_length - DESIRED_BOAT_DISTANCE)
    return desired_position_offset + separation_steering
end

local function OnEntitySleep(inst)
    if not inst.components.combat.target then
        inst._sleep_remove_task = inst:DoTaskInTime(3, inst.Remove)
    end
end

local function OnEntityWake(inst)
    if inst._sleep_remove_task ~= nil then
        inst._sleep_remove_task:Cancel()
        inst._sleep_remove_task = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("shark")
    inst.AnimState:SetBuild("shark_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("scarytoprey")
    inst:AddTag("scarytooceanprey")
    inst:AddTag("monster")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
    inst:AddTag("shark")
	inst:AddTag("wet")

    inst.scrapbook_deps = {"fishmeat"}

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "shark_parts"
    inst.components.combat:SetDefaultDamage(TUNING.SHARK.DAMAGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAreaDamage(TUNING.SHARK.AOE_RANGE, TUNING.SHARK.AOE_SCALE)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SHARK.HEALTH)
    inst.components.health:StartRegen(TUNING.BEEFALO_HEALTH_REGEN, TUNING.BEEFALO_HEALTH_REGEN_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('shark')


    inst:AddComponent("inspectable")

    --MakeLargeBurnableCharacter(inst, "shark_parts")
    MakeLargeFreezableCharacter(inst, "shark_parts")

    inst:AddComponent("timer")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.SHARK.WALK_SPEED_LAND
    inst.components.locomotor.runspeed = TUNING.SHARK.RUN_SPEED_LAND

	inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetBanks("shark", "shark_water")
    inst.components.amphibiouscreature:SetEnterWaterFn(
        function(inst)
            inst.landspeed = inst.components.locomotor.runspeed
            inst.landspeedwalk = inst.components.locomotor.walkspeed
            inst.components.locomotor.runspeed = TUNING.SHARK.RUN_SPEED
            inst.components.locomotor.walkspeed = TUNING.SHARK.WALK_SPEED
            inst.DynamicShadow:Enable(false)
        end)

    inst.components.amphibiouscreature:SetExitWaterFn(
        function(inst)
            if inst.landspeed then
                inst.components.locomotor.runspeed = inst.landspeed
            end
            if inst.landspeedwalk then
                inst.components.locomotor.walkspeed = inst.landspeedwalk
            end
            inst.DynamicShadow:Enable(true)
			if inst.sg:HasStateTag("moving") then
				--land shark has no walk or run anims and will crash if we don't force them out of those states
				inst.sg:GoToState("leap")
			end
        end)

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnWallUpdateFn(function()

        if inst:GetCurrentPlatform() then
            if inst.readytoswim then
                inst:PushEvent("leap")
            end
        else
            local target = inst.components.combat.target
            if target then
                if target:GetCurrentPlatform() then
                    if not inst.sg:HasStateTag("jumping") and
                       not inst.components.timer:TimerExists("getdistance") and
                       target:GetDistanceSqToInst(inst) < JUMPDIST*JUMPDIST then
                        inst:PushEvent("leap")
                    end
                end
            end
        end
    end)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst.removefood = removefood
    inst.testfooddist = testfooddist
    inst.GetFormationOffsetNormal = GetFormationOffsetNormal
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    MakeHauntablePanic(inst)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGshark")
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    TheWorld:PushEvent("sharkspawned", {target= inst})

    return inst
end

return Prefab("shark", fn, assets, prefabs)
