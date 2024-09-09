local assets =
{
    Asset("ANIM", "anim/dragonling_build.zip"),
    Asset("ANIM", "anim/dragonling_basic.zip"),
    Asset("ANIM", "anim/dragonling_emotes.zip"),
    Asset("ANIM", "anim/dragonling_traits.zip"),
}

local brain = require "brains/boatrace_spectator_dragonlingbrain"

local function look_for_reactions(inst)
    local indicator = inst.components.entitytracker:GetEntity("indicator")
    if not indicator then return end

    local boat = indicator.parent
    if not boat then return end

    local walkableplatform = boat.components.walkableplatform
    if not walkableplatform then return end

    local entities_on_platform = walkableplatform:GetEntitiesOnPlatform()
    for entity in pairs(entities_on_platform) do
        if not entity:IsInLimbo()
                and inst._seen_leaks[entity] == nil
                and entity.components.boatleak
                and entity.components.boatleak.has_leaks then
            inst._seen_leaks[entity] = true
            inst.sg:GoToState("emote_collision")
            break
        end
    end
end

local function new_boatrace_indicator(inst, indicator)
    inst.components.entitytracker:TrackEntity("indicator", indicator)

    inst:ListenForEvent("onremove", inst._on_indicator_removed, indicator)

    inst:ListenForEvent("checkpoint_found", inst._on_indicator_found_checkpoint, indicator)

    inst:DoPeriodicTask(0.33, look_for_reactions)

    inst.sg:GoToState("fly_in")
end

local PATHCAPS = { allowocean = true }
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1, .33)

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("dragonling")
    inst.AnimState:SetBuild("dragonling_build")
    inst.AnimState:PlayAnimation("idle_loop")

    -- NOTE: This setup collides with players. Is that ok?
    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:SetCapsule(.5, 1)

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    MakeInventoryFloatable(inst)

    -- We don't need total do entitysleep as it should teleport to near the source,
    -- so there's no point in hitting the physics engine.
    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("companion")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("small_livestock")
    inst:AddTag("NOBLOCK")
    inst:AddTag("nomagic")

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/dragonling/fly_LP", "flying")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst._seen_leaks = {}

    --
    inst:AddComponent("entitytracker")

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("knownlocations")

    --
    local timer = inst:AddComponent("timer")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor:EnableGroundSpeedMultiplier(false)
    locomotor:SetTriggersCreep(false)
    locomotor.softstop = true
    locomotor.walkspeed = TUNING.CRITTER_WALK_SPEED
    locomotor.pathcaps = PATHCAPS

    --
    inst._on_indicator_removed = function(indicator)
        inst:RemoveEventCallback("checkpoint_found", inst._on_indicator_found_checkpoint, indicator)
        local boat = indicator.parent
        if boat then
            inst:RemoveEventCallback("on_collide", inst._on_boat_collided, boat)
        end

        inst.sg:GoToState("fly_away_pre")
    end
    inst._on_indicator_found_checkpoint = function(_)
        if not timer:TimerExists("indicator_found") then
            timer:StartTimer("indicator_found", 1)
            inst.sg:GoToState("emote_checkpoint")
        end
    end

    --
    inst:SetBrain(brain)
    inst:SetStateGraph("SGboatrace_spectator_dragonling")

    --
    inst:ListenForEvent("new_boatrace_indicator", new_boatrace_indicator)

    --
    inst.persists = false

    --
    return inst
end

return Prefab("boatrace_spectator_dragonling", fn, assets)