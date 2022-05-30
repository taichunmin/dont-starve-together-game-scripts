local assets =
{
    Asset("ANIM", "anim/shadow_oceanhorror.zip"),
}

local prefabs =
{
    "shadow_teleport_in",
    "shadow_teleport_out",
    "nightmarefuel",
    "oceanhorror_attachpivot",
    "oceanhorror_ripples",
}

local sounds =
{
    attack = "dontstarve/sanity/creature1/attack",
    attack_grunt = "dontstarve/sanity/creature1/attack_grunt",
    death = "dontstarve/sanity/creature1/die",
    idle = "dontstarve/sanity/creature1/idle",
    taunt = "dontstarve/sanity/creature1/taunt",
    appear = "dontstarve/sanity/creature1/appear",
    disappear = "dontstarve/sanity/creature1/dissappear",
}

local brain = require("brains/oceanshadowcreaturebrain")

local ATTACH_OFFSET_PADDING = 0.5
local COLLISION_RADIUS_ON_OCEAN = 1.5
local COLLISION_RADIUS_ON_BOAT = 0.5

local findboattags = { "boat" }

SetSharedLootTable("ocean_shadow_creature",
{
    { "nightmarefuel",  1.0 },
    { "nightmarefuel",  0.5 },
})

local function update(inst)
    local current_boat = inst._current_boat

    if current_boat == nil then
        if not inst.sg:HasStateTag("teleporting") then
            local x, y, z = inst.Transform:GetWorldPosition()
            local boats = TheSim:FindEntities(x, y, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + ATTACH_OFFSET_PADDING, findboattags)
            if boats ~= nil then
                for _, boat in ipairs(boats) do
                    if boat.components.walkableplatform ~= nil then
                        local bx, by, bz = boat.Transform:GetWorldPosition()
                        if VecUtil_Length(bx - x, bz - z) <= boat.components.walkableplatform.platform_radius + TUNING.OCEANHORROR.ATTACH_OFFSET_PADDING then
                            inst._attach_to_boat_fn(inst, boat)
                            break
                        end
                    end
                end
            end
        end
    else
        local current_boat = inst._current_boat

        local x, y, z = inst.Transform:GetWorldPosition()
        local bx, by, bz = current_boat.Transform:GetWorldPosition()

        local dir_x, dir_z = VecUtil_Normalize(x - bx, z - bz)
        local radius = current_boat.components.walkableplatform.platform_radius

        local boat_collision_radius_padding = 0.4
        if not TheWorld.Map:IsOceanAtPoint(
            bx + dir_x * (radius + TUNING.OCEANHORROR.ATTACH_OFFSET_PADDING + boat_collision_radius_padding),
            0,
            bz + dir_z * (radius + TUNING.OCEANHORROR.ATTACH_OFFSET_PADDING + boat_collision_radius_padding)) then

            inst:PushEvent("boatteleport", {force_random_angle_on_boat=true})
        end
    end
end

local function AttachToBoat(inst, boat)
    inst.Physics:Stop()
    inst.components.locomotor:Stop()

    inst._current_boat = boat

    local x, y, z = inst.Transform:GetWorldPosition()
    local bx, by, bz = boat.Transform:GetWorldPosition()

    local pivot = inst.entity:GetParent()
    if pivot == nil then
        -- Creature was previously not attached to a boat
        pivot = SpawnPrefab("oceanhorror_attachpivot")
        inst.entity:SetParent(pivot.entity)

        pivot._creature = inst

        inst.Physics:SetCapsule(COLLISION_RADIUS_ON_BOAT, 1)
    -- else
    --     -- Creature is teleporting from one boat to another, or to a different position on the same boat
    end
    pivot.Transform:SetPosition(bx, 0, bz)

    local dirx, dirz = VecUtil_Normalize(x - bx, z - bz)
    local boat_radius = boat.components.walkableplatform.platform_radius

    inst.Transform:SetPosition(
        dirx * (boat_radius + ATTACH_OFFSET_PADDING),
        0,
        dirz * (boat_radius + ATTACH_OFFSET_PADDING))

    --

    inst._should_teleport_time = GetTime()
end

local function DetachFromBoat(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local pivot = inst.entity:GetParent()
    if pivot ~= nil then
        inst.entity:SetParent(nil)
        pivot:Remove()
    end

    inst.Transform:SetPosition(x, y, z)

    inst._should_teleport_time = GetTime()

    inst._current_boat = nil

    inst.Physics:SetCapsule(COLLISION_RADIUS_ON_OCEAN, 1)
end

local function NotifyBrainOfTarget(inst, target)
    if inst.brain ~= nil and inst.brain.SetTarget ~= nil then
        inst.brain:SetTarget(target)
    end
end

local function retargetfn(inst)
    local maxrangesq = TUNING.SHADOWCREATURE_TARGET_DIST * TUNING.SHADOWCREATURE_TARGET_DIST
    local rangesq, rangesq1, rangesq2 = maxrangesq, math.huge, math.huge
    local target1, target2 = nil, nil
    for i, v in ipairs(AllPlayers) do
        if v.components.sanity:IsCrazy() and not v:HasTag("playerghost") then
            local distsq = v:GetDistanceSqToInst(inst)
            if distsq < rangesq then
                if inst.components.shadowsubmissive:TargetHasDominance(v) then
                    if distsq < rangesq1 and inst.components.combat:CanTarget(v) then
                        target1 = v
                        rangesq1 = distsq
                        rangesq = math.max(rangesq1, rangesq2)
                    end
                elseif distsq < rangesq2 and inst.components.combat:CanTarget(v) then
                    target2 = v
                    rangesq2 = distsq
                    rangesq = math.max(rangesq1, rangesq2)
                end
            end
        end
    end

    if target1 ~= nil and rangesq1 <= math.max(rangesq2, maxrangesq * .25) then
        --Targets with shadow dominance have higher priority within half targeting range
        --Force target switch if current target does not have shadow dominance
        return target1, not inst.components.shadowsubmissive:TargetHasDominance(inst.components.combat.target)
    end
    return target2
end

local function onkilledbyother(inst, attacker)
    if attacker ~= nil and attacker.components.sanity ~= nil then
        attacker.components.sanity:DoDelta(inst.sanityreward or TUNING.SANITY_SMALL)
    end
end

local function CalcSanityAura(inst, observer)
    return inst.components.combat:HasTarget()
        and observer.components.sanity:IsCrazy()
        and -TUNING.SANITYAURA_LARGE
        or 0
end

local function ShareTargetFn(dude)
    return dude:HasTag("shadowcreature") and not dude.components.health:IsDead()
end

local function EnableTeleportOnHit(inst)
    inst._block_teleport_on_hit_task = nil
end

local function OnAttacked(inst, data)
    if inst._block_teleport_on_hit_task == nil then
        inst._block_teleport_on_hit_task = inst:DoTaskInTime(TUNING.OCEANHORROR.BLOCK_TELEPORT_ON_HIT_DURATION + math.random() * TUNING.OCEANHORROR.BLOCK_TELEPORT_ON_HIT_DURATION_VARIANCE, EnableTeleportOnHit)

        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, ShareTargetFn, 1)

        inst:PushEvent("boatteleport", {force_random_angle_on_boat=true})
    end
end

local function OnNewCombatTarget(inst, data)
    NotifyBrainOfTarget(inst, data.target)
end

local function OnDeath(inst, data)
    if data ~= nil and data.afflicter ~= nil and data.afflicter:HasTag("crazy") then
        --max one nightmarefuel if killed by a crazy NPC (e.g. Bernie)
        inst.components.lootdropper:SetLoot({ "nightmarefuel" })
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end

local function OnAlphaChanged(inst, alpha, most_alpha)
    inst._ripples.AnimState:OverrideMultColour(alpha, alpha, alpha, alpha)
end

local function OnAttackOther(inst)
    inst._should_teleport_time = GetTime()
end

local function OnRemove(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        parent:Remove()
    end
end

local function ExchangeWithTerrorBeak(inst)
    if inst.components.combat.target then
        local target = inst.components.combat.target
        local x,y,z = target.Transform:GetWorldPosition()
        if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
            local sx,sy,sz = inst.Transform:GetWorldPosition()
            local radius = 0
            local theta = inst:GetAngleToPoint(Vector3(x,y,z)) * DEGREES
            while not TheWorld.Map:IsVisualGroundAtPoint(sx,sy,sz) and radius < 30 do
                radius = radius + 2
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                sx = sx + offset.x
                sy = sy + offset.y
                sz = sz + offset.z
            end

            if radius >= 30 then
                return nil
            else
                local shadow = SpawnPrefab("terrorbeak")
                shadow.components.health:SetPercent(inst.components.health:GetPercent())
                shadow.Transform:SetPosition(sx,sy,sz)
                shadow.sg:GoToState("appear")
                shadow.components.combat:SetTarget(target)
                TheWorld:PushEvent("ms_exchangeshadowcreature", {ent = inst, exchangedent = shadow})
                local fx = SpawnPrefab("shadow_teleport_in")
                fx.Transform:SetPosition(sx,sy,sz)
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, COLLISION_RADIUS_ON_OCEAN)
    RemovePhysicsColliders(inst)
    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
    inst.Physics:CollidesWith(COLLISION.SANITY)

    inst.Transform:SetFourFaced()

    inst:AddTag("shadowcreature")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("shadow")
    inst:AddTag("notraptrigger")
    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("oceanhorror")
    inst.AnimState:SetBuild("shadow_oceanhorror")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, .5)

    inst._ripples = SpawnPrefab("oceanhorror_ripples")
    inst._ripples.entity:SetParent(inst.entity)

    -- this is purely view related
    inst:AddComponent("transparentonsanity")
    inst.components.transparentonsanity.onalphachangedfn = OnAlphaChanged

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst._should_teleport_time = GetTime()
    -- inst._current_boat = nil

    -- these are cached so that they can be accessed from the stategraph
    inst._attach_to_boat_fn = AttachToBoat
    inst._detach_from_boat_fn = DetachFromBoat

    -- inst._block_teleport_on_hit_task = nil

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }
    inst.components.locomotor.walkspeed = TUNING.OCEANHORROR.SPEED
    inst.sounds = sounds
    inst:SetStateGraph("SGoceanshadowcreature")

    inst:SetBrain(brain)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.OCEANHORROR.HEALTH)
    inst.components.health.nofadeout = true

    inst.sanityreward = TUNING.SANITY_MED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.OCEANHORROR.DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.OCEANHORROR.ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat.onkilledbyother = onkilledbyother
    inst.components.combat:SetRange(TUNING.OCEANHORROR.ATTACK_RANGE)

    inst:AddComponent("shadowsubmissive")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ocean_shadow_creature')

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("death", OnDeath)

    inst:ListenForEvent("onattackother", OnAttackOther)

    inst._update_task = inst:DoPeriodicTask(FRAMES, update)

    inst.ExchangeWithTerrorBeak = ExchangeWithTerrorBeak

    inst:ListenForEvent("onremove", OnRemove)

    return inst
end

local function ripplesfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("oceanhorror")
    inst.AnimState:SetBuild("shadow_oceanhorror")
    inst.AnimState:PlayAnimation("water", true)
    inst.AnimState:SetMultColour(1, 1, 1, .5)
    -- transparency set from oceanhorror parent object

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    -- if not TheWorld.ismastersim then
    --     return inst
    -- end

    return inst
end

local function attachpivot_onsink(inst)
    if inst._creature ~= nil and inst._creature:IsValid() then
        inst._creature._detach_from_boat_fn(inst._creature)
    end
end

local function attachpivotfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")

    inst:AddTag("ignorewalkableplatformdrowning")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("onsink", attachpivot_onsink)

    return inst
end

return Prefab("oceanhorror", fn, assets, prefabs),
    Prefab("oceanhorror_ripples", ripplesfn, assets),
    Prefab("oceanhorror_attachpivot", attachpivotfn)
