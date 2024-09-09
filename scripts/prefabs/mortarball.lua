local assets =
{
    Asset("ANIM", "anim/cannonball_rock.zip"),
    Asset("ANIM", "anim/cannonball_rock_lvl2_build.zip"),
    Asset("ANIM", "anim/cannonball_rock_lvl3_build.zip"),
}

local prefabs_item =
{
    
}

local prefabs =
{
    "bullkelp_root",
    "mortarball_used",
    "mortarball_used_ice",
    "mortarball_used_wood",
    "crab_king_waterspout",
    "wave_splash",
}

local PROJECTILE_MUST_ONE_OF_TAGS = { "_combat", "_health", "blocker" }
local PROJECTILE_EXCLUDE_TAGS = { "crabking_ally", "INLIMBO", "notarget", "noattack", "invisible", "playerghost" }

local ONHIT_MUST_ONE_OF_TAGS = { "oceanfishable", "kelp", "_inventoryitem", "wave" }
local ONHIT_EXCLUDE_TAGS = { "crabking_ally", "INLIMBO", "noattack", "flight", "invisible", "playerghost" }

local AREAATTACK_EXCLUDE_TAGS = { "crabking_ally", "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }

local INITIAL_LAUNCH_HEIGHT = 0.1
local SPEED_XZ = 4
local SPEED_Y = 16
local ANGLE_VARIANCE = 20
local function launch_away(inst, position, use_variant_angle)
    if inst.Physics == nil then
        return
    end

    -- Launch outwards from impact point. Calculate angle from position, with some variance
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)
    inst.Physics:SetFriction(0.2)

    local px, py, pz = position:Get()
    local random = use_variant_angle and math.random() * ANGLE_VARIANCE * - ANGLE_VARIANCE / 2 or 0
    local angle = ((180 - inst:GetAngleToPoint(px, py, pz)) + random) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(SPEED_XZ * cosa, SPEED_Y, SPEED_XZ * sina)

    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem:SetLanded(false, true)
    end
end

local function OnHit(inst, attacker, target)

    local hittype = "mortarball_used"

    -- Do splash damage upon hitting the ground
    inst.components.combat:DoAreaAttack(inst, TUNING.CANNONBALL_SPLASH_RADIUS, nil, nil, nil, AREAATTACK_EXCLUDE_TAGS)

    -- One last check to see if the projectile landed on a boat
    if target == nil then
        local hitpos = inst:GetPosition()
        target = TheWorld.Map:GetPlatformAtPoint(hitpos.x, hitpos.z)
    end

    -- Hit a boat? Cause a leak!
    if target ~= nil and target:HasTag("boat") then
        if inst.redgemcount and inst.redgemcount > 4 then
            local hitpos = inst:GetPosition()

            local size = "small_leak"
            if inst.redgemcount > 7 then
                size = "med_leak"
            end
            target:PushEvent("spawnnewboatleak", { pt = hitpos, leak_size = size, playsoundfx = true, cause ="cannonball" })
        end

        local damage = inst.components.combat.defaultdamage        
        target.components.health:DoDelta(-damage/2)

        if target:HasTag("wood") then
            hittype = "mortarball_used_wood"
        end
    end

    -- Look for stuff on the ocean/ground and launch them
    local x, y, z = inst.Transform:GetWorldPosition()
    local position = inst:GetPosition()

    local affected_entities = TheSim:FindEntities(x, 0, z, TUNING.CANNONBALL_SPLASH_RADIUS, nil, ONHIT_EXCLUDE_TAGS, ONHIT_MUST_ONE_OF_TAGS) -- Set y to zero to look for objects floating on the ocean
    for i, affected_entity in ipairs(affected_entities) do
        -- Look for fish in the splash radius, kill and spawn their loot if hit
        if affected_entity.components.oceanfishable ~= nil then
            if affected_entity.fish_def and affected_entity.fish_def.loot then
                local loot_table = affected_entity.fish_def.loot
                for i, product in ipairs(loot_table) do
                    local loot = SpawnPrefab(product)
                    if loot ~= nil then
                        local ae_x, ae_y, ae_z = affected_entity.Transform:GetWorldPosition()
                        loot.Transform:SetPosition(ae_x, ae_y, ae_z)
                        launch_away(loot, position, true)
                    end
                end
                affected_entity:Remove()
            end
        -- Spawn kelp roots along with kelp is a bullkelp plant is hit
        elseif affected_entity.prefab == "bullkelp_plant" then
            local ae_x, ae_y, ae_z = affected_entity.Transform:GetWorldPosition()

            if affected_entity.components.pickable and affected_entity.components.pickable:CanBePicked() then
                local product = affected_entity.components.pickable.product
                local loot = SpawnPrefab(product)

                if loot ~= nil then
                    loot.Transform:SetPosition(ae_x, ae_y, ae_z)
                    if loot.components.inventoryitem ~= nil then
                        loot.components.inventoryitem:MakeMoistureAtLeast(TUNING.OCEAN_WETNESS)
                    end
                    if loot.components.stackable ~= nil
                            and affected_entity.components.pickable.numtoharvest > 1 then
                        loot.components.stackable:SetStackSize(affected_entity.components.pickable.numtoharvest)
                    end
                    launch_away(loot, position)
                end
            end

            local uprooted_kelp_plant = SpawnPrefab("bullkelp_root")
            if uprooted_kelp_plant ~= nil then
                uprooted_kelp_plant.Transform:SetPosition(ae_x, ae_y, ae_z)
                launch_away(uprooted_kelp_plant, position + Vector3(0.5*math.random(), 0, 0.5*math.random()))
            end

            affected_entity:Remove()
        -- Generic pickup item
        elseif affected_entity.components.inventoryitem ~= nil then
            launch_away(affected_entity, position)
        elseif affected_entity.waveactive then
            affected_entity:DoSplash()
        end
    end

    -- Landed on the ocean
    if inst:IsOnOcean() then
        SpawnPrefab("crab_king_waterspout").Transform:SetPosition(inst.Transform:GetWorldPosition())
    -- Landed on ground
    else
        if TheWorld.Map:IsOceanIceAtPoint(inst.Transform:GetWorldPosition()) then
             hittype = "mortarball_used_ice"
        end

        if TheWorld.components.dockmanager ~= nil then
            -- Damage any docks we hit.
            local damage = inst.components.combat.defaultdamage
            TheWorld.components.dockmanager:DamageDockAtPoint(x, y, z, damage)
             hittype = "mortarball_used_wood"             
        end

        SpawnPrefab(hittype).Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function OnUpdateProjectile(inst)
    -- Look to hit targets while the cannonball is flying through the air
    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, 0, z, TUNING.CANNONBALL_RADIUS, nil, PROJECTILE_EXCLUDE_TAGS, PROJECTILE_MUST_ONE_OF_TAGS) -- Set y to zero to look for objects on the ground
    for i, target in ipairs(targets) do

        -- Ignore hitting bumpers while flying through the air
        if target ~= nil and target ~= inst and target ~= inst.components.complexprojectile.attacker and not target:HasTag("boatbumper") then
            -- Do damage to entities with health
            if target.components.combat and GetTime() - target.components.combat.lastwasattackedtime > TUNING.CANNONBALL_PASS_THROUGH_TIME_BUFFER then
                local damage = inst.components.combat.defaultdamage
                target.components.combat:GetAttacked(inst, damage, nil)
            end

            -- Remove and do splash damage if it hits a wall
            if target:HasTag("wall") and target.components.health then
                if not target.components.health:IsDead() then
                    inst.components.combat:DoAreaAttack(inst, TUNING.CANNONBALL_SPLASH_RADIUS, nil, nil, nil, AREAATTACK_EXCLUDE_TAGS)
                    SpawnPrefab("cannonball_used").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst:Remove()
                    return
                end
            -- Chop/knock down workable objects
            elseif target.components.workable then
                target.components.workable:Destroy(inst)
            end
        end
    end
end

local function common_fn(bank, build, anim, tag, isinventoryitem)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    if isinventoryitem then
        MakeInventoryPhysics(inst)
    else
        inst.entity:AddPhysics()
        inst.Physics:SetMass(1)
        inst.Physics:SetFriction(0)
        inst.Physics:SetDamping(0)
        inst.Physics:SetRestitution(0)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:SetSphere(TUNING.CANNONBALL_RADIUS)
        inst.Physics:SetCollides(false) -- The cannonball hitting targets will be handled in OnUpdateProjectile() with FindEntities()

        if not TheNet:IsDedicated() then
            -- Delay adding the ground shadow to prevent it from momentarily appearing at (0,0,0)
            inst:DoTaskInTime(0, function(inst)
                inst:AddComponent("groundshadowhandler")
                local x, y, z = inst.Transform:GetWorldPosition()
                inst.components.groundshadowhandler.ground_shadow.Transform:SetPosition(x, 0, z)
                inst.components.groundshadowhandler:SetSize(1, 0.5)
            end)
        end
    end

    if tag ~= nil then
        inst:AddTag(tag)
    end

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)

    if type(anim) ~= "table" then
        inst.AnimState:PlayAnimation(anim, true)
    elseif #anim == 1 then
        inst.AnimState:PlayAnimation(anim[1], true)
    else
        for i, a in ipairs(anim) do
            if i == 1 then
                inst.AnimState:PlayAnimation(a, false)
            elseif i ~= #anim then
                inst.AnimState:PushAnimation(a, false)
            else
                inst.AnimState:PushAnimation(a, true)
            end
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.MORTAR_DAMAGE)
    inst.components.combat:SetAreaDamage(TUNING.CANNONBALL_SPLASH_RADIUS, TUNING.CANNONBALL_SPLASH_DAMAGE_PERCENT)

    return inst
end

local function setdamage(inst, damage)
    inst.damage = damage
    inst.components.combat:SetDefaultDamage(inst.damage)

    if inst.redgemcount and inst.redgemcount > 4 then
        local build = "cannonball_rock_lvl2_build"
        if inst.redgemcount > 7 then
            build = "cannonball_rock_lvl3_build"
        end
        inst.AnimState:SetBuild(build)
    end
end

local function mortar_fn()
    local inst = common_fn("cannonball_rock", "cannonball_rock", "spin_loop", "NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.setdamage = setdamage
    inst:setdamage(TUNING.MORTAR_DAMAGE)

    inst.persists = false

    inst.components.complexprojectile:SetHorizontalSpeed(TUNING.CANNONBALLS.ROCK.SPEED)
    inst.components.complexprojectile:SetGravity(TUNING.CANNONBALLS.ROCK.GRAVITY)
    inst.components.complexprojectile:SetOnHit(OnHit)
    --inst.components.complexprojectile:SetOnUpdate(OnUpdateProjectile)

    return inst
end

return Prefab("mortarball", mortar_fn, assets, prefabs)
