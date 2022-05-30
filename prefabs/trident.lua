local assets =
{
    Asset("ANIM", "anim/trident.zip"),
    Asset("ANIM", "anim/swap_trident.zip"),
    Asset("INV_IMAGE", "trident"),
}

local prefabs =
{
    "crab_king_waterspout",
}

local function reticule_target_function(inst)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(3.5, 0.001, 0))
end

local function trident_damage_calculation(inst, attacker, target)
    local is_over_ground = TheWorld.Map:IsVisualGroundAtPoint(attacker:GetPosition():Get())
    return (is_over_ground and TUNING.TRIDENT.DAMAGE) or TUNING.TRIDENT.OCEAN_DAMAGE
end

local function on_uses_finished(inst)
    if inst.components.inventoryitem.owner ~= nil then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", { tool = inst })
    end

    inst:Remove()
end

local function on_equipped(inst, equipper)
    equipper.AnimState:OverrideSymbol("swap_object", "swap_trident", "swap_trident")
    equipper.AnimState:Show("ARM_carry")
    equipper.AnimState:Hide("ARM_normal")
end

local function on_unequipped(inst, equipper)
    equipper.AnimState:Hide("ARM_carry")
    equipper.AnimState:Show("ARM_normal")
end

local INITIAL_LAUNCH_HEIGHT = 0.1
local SPEED = 8
local function launch_away(inst, position)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

    local px, py, pz = position:Get()
    local angle = (180 - inst:GetAngleToPoint(px, py, pz)) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(SPEED * cosa, 4 + SPEED, SPEED * sina)
end

local function do_water_explosion_effect(inst, affected_entity, owner, position)
    if affected_entity.components.health then
        local ae_combat = affected_entity.components.combat
        if ae_combat then
            ae_combat:GetAttacked(owner, TUNING.TRIDENT.SPELL.DAMAGE, inst)
        else
            affected_entity.components.health:DoDelta(-TUNING.TRIDENT.SPELL.DAMAGE, nil, inst.prefab, nil, owner)
        end
    elseif affected_entity.components.oceanfishable ~= nil then
		if affected_entity.components.weighable ~= nil then
	        affected_entity.components.weighable:SetPlayerAsOwner(owner)
		end

        local projectile = affected_entity.components.oceanfishable:MakeProjectile()

        local ae_cp = projectile.components.complexprojectile
        if ae_cp then
            ae_cp:SetHorizontalSpeed(16)
            ae_cp:SetGravity(-30)
            ae_cp:SetLaunchOffset(Vector3(0, 0.5, 0))
            ae_cp:SetTargetOffset(Vector3(0, 0.5, 0))

            local v_position = affected_entity:GetPosition()
            local launch_position = v_position + (v_position - position):Normalize() * SPEED
            ae_cp:Launch(launch_position, projectile)
        else
            launch_away(projectile, position)
        end
    elseif affected_entity.prefab == "bullkelp_plant" then
        local ae_x, ae_y, ae_z = affected_entity.Transform:GetWorldPosition()

        if affected_entity.components.pickable and affected_entity.components.pickable:CanBePicked() then
            local product = affected_entity.components.pickable.product
            local loot = SpawnPrefab(product)
            if loot ~= nil then
                loot.Transform:SetPosition(ae_x, ae_y, ae_z)
                if loot.components.inventoryitem ~= nil then
                    loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
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
    elseif affected_entity.components.inventoryitem ~= nil then
        launch_away(affected_entity, position)
        affected_entity.components.inventoryitem:SetLanded(false, true)
    elseif affected_entity.waveactive then
        affected_entity:DoSplash()
    elseif affected_entity.components.workable ~= nil and affected_entity.components.workable:GetWorkAction() == ACTIONS.MINE then
        affected_entity.components.workable:WorkedBy(owner, TUNING.TRIDENT.SPELL.MINES)
    end
end

local PLANT_TAGS = {"tendable_farmplant"}
local MUST_HAVE_SPELL_TAGS = nil
local CANT_HAVE_SPELL_TAGS = {"INLIMBO", "outofreach", "DECOR"}
local MUST_HAVE_ONE_OF_SPELL_TAGS = nil
local FX_RADIUS = TUNING.TRIDENT.SPELL.RADIUS * 0.65
local COST_PER_EXPLOSION = TUNING.TRIDENT.USES / TUNING.TRIDENT.SPELL.USE_COUNT
local function create_water_explosion(inst, target, position)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end

    local px, py, pz = position:Get()

    -- Do gameplay effects.
    local affected_entities = TheSim:FindEntities(px, py, pz, TUNING.TRIDENT.SPELL.RADIUS, MUST_HAVE_SPELL_TAGS, CANT_HAVE_SPELL_TAGS, MUST_HAVE_ONE_OF_SPELL_TAGS)
    for _, v in ipairs(affected_entities) do
        if v:IsOnOcean(false) then
            inst:DoWaterExplosionEffect(v, owner, position)
        end
    end

    -- Spawn visual fx.
    local angle = GetRandomWithVariance(-45, 20)
    for _ = 1, 4 do
        angle = angle + 90
        local offset_x = FX_RADIUS * math.cos(angle * DEGREES)
        local offset_z = FX_RADIUS * math.sin(angle * DEGREES)
        local ox = px + offset_x
        local oz = pz - offset_z

        if TheWorld.Map:IsOceanTileAtPoint(ox, py, oz) and not TheWorld.Map:IsVisualGroundAtPoint(ox, py, oz) then
            local platform_at_point = TheWorld.Map:GetPlatformAtPoint(ox, oz)
            if platform_at_point ~= nil then
                -- Spawn a boat leak slightly further in to help avoid being on the edge of the boat and sliding off.
                local bx, by, bz = platform_at_point.Transform:GetWorldPosition()
                if bx == ox and bz == oz then
                    platform_at_point:PushEvent("spawnnewboatleak", {pt = Vector3(ox, py, oz), leak_size = "med_leak", playsoundfx = true})
                else
                    local p_to_ox, p_to_oz = VecUtil_Normalize(bx - ox, bz - oz)
                    local ox_mod, oz_mod = ox + (0.5 * p_to_ox), oz + (0.5 * p_to_oz)
                    platform_at_point:PushEvent("spawnnewboatleak", {pt = Vector3(ox_mod, py, oz_mod), leak_size = "med_leak", playsoundfx = true})
                end

                local boatphysics = platform_at_point.components.boatphysics
                if boatphysics ~= nil then
                    boatphysics:ApplyForce(offset_x, -offset_z, 1)
                end
            else
                local fx = SpawnPrefab("crab_king_waterspout")
                fx.Transform:SetPosition(ox, py, oz)
            end
        end
    end

	local x, y, z = owner.Transform:GetWorldPosition()
    for _, v in pairs(TheSim:FindEntities(x, y, z, TUNING.TRIDENT_FARM_PLANT_INTERACT_RANGE, PLANT_TAGS)) do
		if v.components.farmplanttendable ~= nil then
			v.components.farmplanttendable:TendTo(owner)
		end
	end


    inst.components.finiteuses:Use(COST_PER_EXPLOSION)
end

local FLOATER_SWAP_DATA = {sym_build = "swap_trident"}
local function trident()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("guitar")
    inst:AddTag("pointy")
    inst:AddTag("sharp")
    inst:AddTag("weapon")

    inst.spelltype = "MUSIC"

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = reticule_target_function
    inst.components.reticule.ease = true
    inst.components.reticule.ispassableatallpoints = true

    inst.AnimState:SetBank("trident")
    inst.AnimState:SetBuild("trident")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9, FLOATER_SWAP_DATA)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -------

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(trident_damage_calculation)

    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TRIDENT.USES)
    inst.components.finiteuses:SetUses(TUNING.TRIDENT.USES)
    inst.components.finiteuses:SetOnFinished(on_uses_finished)

    -------

    inst:AddComponent("inspectable")

    -------

    inst:AddComponent("inventoryitem")

    -------

    inst:AddComponent("tradable")

    -------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(on_equipped)
    inst.components.equippable:SetOnUnequip(on_unequipped)

    -------

    inst.DoWaterExplosionEffect = do_water_explosion_effect

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(create_water_explosion)
    inst.components.spellcaster.canuseonpoint_water = true

    return inst
end

return Prefab("trident", trident, assets, prefabs)
