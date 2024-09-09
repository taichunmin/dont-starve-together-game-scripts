local assets =
{
    Asset("ANIM", "anim/dumbbell.zip"),
    Asset("ANIM", "anim/dumbbell_golden.zip"),
    Asset("ANIM", "anim/dumbbell_marble.zip"),
    Asset("ANIM", "anim/dumbbell_gem.zip"),

    Asset("ANIM", "anim/dumbbell_heat.zip"),
    Asset("ANIM", "anim/dumbbell_redgem.zip"),
    Asset("ANIM", "anim/dumbbell_bluegem.zip"),

    Asset("INV_IMAGE", "dumbbell_heat1"),
    Asset("INV_IMAGE", "dumbbell_heat2"),
    Asset("INV_IMAGE", "dumbbell_heat3"),
    Asset("INV_IMAGE", "dumbbell_heat4"),
    Asset("INV_IMAGE", "dumbbell_heat5"),

    Asset("ANIM", "anim/swap_dumbbell.zip"),
    Asset("ANIM", "anim/swap_dumbbell_golden.zip"),
    Asset("ANIM", "anim/swap_dumbbell_marble.zip"),
    Asset("ANIM", "anim/swap_dumbbell_gem.zip"),

    Asset("ANIM", "anim/swap_dumbbell_heat.zip"),
    Asset("ANIM", "anim/swap_dumbbell_heat1.zip"),
    Asset("ANIM", "anim/swap_dumbbell_heat2.zip"),
    Asset("ANIM", "anim/swap_dumbbell_heat3.zip"),
    Asset("ANIM", "anim/swap_dumbbell_heat4.zip"),   
    Asset("ANIM", "anim/swap_dumbbell_heat5.zip"),

    Asset("ANIM", "anim/dumbbell_heat1.zip"),
    Asset("ANIM", "anim/dumbbell_heat2.zip"),
    Asset("ANIM", "anim/dumbbell_heat3.zip"),
    Asset("ANIM", "anim/dumbbell_heat4.zip"),
    Asset("ANIM", "anim/dumbbell_heat5.zip"),    

    Asset("ANIM", "anim/swap_dumbbell_redgem.zip"),
    Asset("ANIM", "anim/swap_dumbbell_bluegem.zip"),    
}

local prefabs = 
{
    "houndfire",
}

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ReticuleShouldHideFn(inst)
	return not inst:HasTag("projectile")
end

local function HasFriendlyLeader(inst, target, attacker)
    local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil
    
    if target_leader ~= nil then

        if target_leader.components.inventoryitem then
            target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        end

        local PVP_enabled = TheNet:GetPVPEnabled()
        return (target_leader ~= nil 
                and (target_leader:HasTag("player") 
                and not PVP_enabled)) or
                (target.components.domesticatable and target.components.domesticatable:IsDomesticated() 
                and not PVP_enabled) or
                (target.components.saltlicker and target.components.saltlicker.salted
                and not PVP_enabled)
    end

    return false
end

local function CanDamage(inst, target, attacker)
    if target.components.minigame_participator ~= nil or target.components.combat == nil then
		return false
	end

    --if attacker == target then -- NOTES(JBK): Uncomment this to able to hit yourself with physical damage.
    --    return true
    --end

    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return false
    end

    if target:HasTag("playerghost") and not target:HasTag("INLIMBO") then
        return false
    end

    if target:HasTag("monster") and not TheNet:GetPVPEnabled() and 
       ((target.components.follower and target.components.follower.leader ~= nil and 
         target.components.follower.leader:HasTag("player")) or target.bedazzled) then
        return false
    end

    if HasFriendlyLeader(inst, target, attacker) then
        return false
    end

    return true
end

local function ResetPhysics(inst)
	inst.Physics:SetFriction(0.1)
	inst.Physics:SetRestitution(0.5)
	inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    local attacker = inst.components.complexprojectile.attacker
    if attacker then
        inst.components.mightydumbbell:DoAttackWorkout(attacker)
    end
    
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/throw_twirl", "spin_loop")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local AOE_ATTACK_MUST_TAGS = {"_combat", "_health"}
local AOE_ATTACK_NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
local function OnThrownHit(inst, attacker, target)
    if inst.isfireattack then
        for i = 1, 3 do
            local fire = SpawnPrefab("houndfire")
            inst.components.lootdropper:FlingItem(fire)
        end
    end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 2, AOE_ATTACK_MUST_TAGS, AOE_ATTACK_NO_TAGS)

--local damage = inst.components.weapon.damage

    local olddamage = inst.components.weapon.damage

    inst.components.weapon.damage = function(inst, attacker, target)
        local damage = olddamage
        if attacker and attacker.components.skilltreeupdater and attacker.components.skilltreeupdater:IsActivated("wolfgang_dumbbell_throwing_2") then
            damage = damage * TUNING.SKILLS.WOLFGANG_DUMBELL_TOSS_2
        elseif attacker and attacker.components.skilltreeupdater and attacker.components.skilltreeupdater:IsActivated("wolfgang_dumbbell_throwing_1") then
            damage = damage * TUNING.SKILLS.WOLFGANG_DUMBELL_TOSS_1
        end
        return damage
    end

	for i, ent in ipairs(ents) do
        local canfreeze = false
	    if CanDamage(inst, ent, attacker) then
			if attacker ~= nil and attacker:IsValid() then
				attacker.components.combat.ignorehitrange = true
				attacker.components.combat:DoAttack(ent, inst, inst)
				attacker.components.combat.ignorehitrange = false
			else
				ent.components.combat:GetAttacked(attacker, inst.components.weapon.damage(inst, inst.components.complexprojectile.attacker, ent) )
			end
            canfreeze = true
        elseif attacker == ent then
            canfreeze = true -- NOTES(JBK): Allow the thrower to still freeze themselves for cooling benefits.
	    end
        if canfreeze then
            if inst.isiceattack and ent.components.freezable ~= nil then
                ent.components.freezable:AddColdness(2)
            end
        end
	end
    
    inst.components.weapon.damage = olddamage


    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.AnimState:PlayAnimation("land")
    inst.AnimState:PushAnimation("idle", true)

    inst:RemoveTag("NOCLICK")
    inst.persists = true

    inst.SoundEmitter:KillSound("spin_loop")
    inst.SoundEmitter:PlaySound(inst.impact_sound)

    inst.components.finiteuses:Use(inst.thrown_consumption)

    if inst.components.finiteuses:GetUses() > 0 then
        ResetPhysics(inst) 
    end
end

local function MakeTossable(inst)
    if inst.components.complexprojectile == nil then
        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(15)
        inst.components.complexprojectile:SetGravity(-35)
        inst.components.complexprojectile:SetLaunchOffset(Vector3(1, 1, 0))
        inst.components.complexprojectile:SetOnLaunch(onthrown)
        inst.components.complexprojectile:SetOnHit(OnThrownHit)
		inst.components.complexprojectile.ismeleeweapon = true
    end
end

local function RemoveTossable(inst)
    if inst.components.complexprojectile ~= nil then
        inst:RemoveComponent("complexprojectile")
    end
end

local function MakeWeapon(inst)
    inst:RemoveTag("punch")
end

local function MakePunch(inst)
    inst:AddTag("punch")
end

local function CheckMightiness(inst, data)
    local dumbbell = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if data and dumbbell then
        if data.state == "mighty" then
            MakeTossable(dumbbell)
        else
            RemoveTossable(dumbbell)
        end

        if data.state == "wimpy" then
            MakePunch(dumbbell)
        else
            MakeWeapon(dumbbell)
        end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", inst.swap_dumbbell, inst.swap_dumbbell_symbol)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    CheckMightiness(owner, {
        state = (owner.components.mightiness ~= nil and owner.components.mightiness:GetState()) or nil,
    })

    inst:ListenForEvent("mightiness_statechange", CheckMightiness, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    
    if inst:HasTag("lifting") then
        owner:PushEvent("stopliftingdumbbell", {instant = true})
    end

    inst:RemoveEventCallback("mightiness_statechange", CheckMightiness, owner)
end

local function OnAttack(inst, attacker, target)
	if inst.components.inventoryitem:IsHeldBy(attacker) then
	    inst.components.mightydumbbell:DoAttackWorkout(attacker)
	end
end

local function OnPickup(inst, owner)
    if owner then
        if owner:HasTag("mightiness_mighty") then
            MakeTossable(inst)
        else
            RemoveTossable(inst)
        end

        if owner:HasTag("mightiness_wimpy") then
            MakePunch(inst)
        else
            MakeWeapon(inst)
        end
    end
end
------------------------------------------------------------------------------------
--- HEATROCK 
------------------------------------------------------------------------------------

local function OnSave(inst, data)
    if inst.highTemp ~= nil then
        data.highTemp = math.ceil(inst.highTemp)
    elseif inst.lowTemp ~= nil then
        data.lowTemp = math.floor(inst.lowTemp)
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.highTemp ~= nil then
            inst.highTemp = data.highTemp
            inst.lowTemp = nil
        elseif data.lowTemp ~= nil then
            inst.lowTemp = data.lowTemp
            inst.highTemp = nil
        end
    end
end

local function OnRemove(inst)
    inst._light:Remove()
    if IsSteam() then -- Only Steam consoles will not get logs so this would be wasted memory for them.
        inst._JBK_DEBUG_TRACE = _TRACEBACK() -- FIXME(JBK): Remove this when no longer needed.
    end
end

-- These represent the boundaries between the ranges (relative to ambient, so ambient is always "0")
local relative_temperature_thresholds = { -30, -10, 10, 30 }

local function GetRangeForTemperature(temp, ambient)
    local range = 1
    for i,v in ipairs(relative_temperature_thresholds) do
        if temp > ambient + v then
            range = range + 1
        end
    end
    return range
end

-- Heatrock emits constant temperatures depending on the temperature range it's in
local emitted_temperatures = { -10, 10, 25, 40, 60 }

local function HeatFn(inst, observer)
    local range = GetRangeForTemperature(inst.components.temperature:GetCurrent(), TheWorld.state.temperature)
    if range <= 2 then
        inst.components.heater:SetThermics(false, true)
    elseif range >= 4 then
        inst.components.heater:SetThermics(true, false)
    else
        inst.components.heater:SetThermics(false, false)
    end
    return emitted_temperatures[range]
end

local function GetStatus(inst)
    if inst.currentTempRange == 1 then
        return "FROZEN"
    elseif inst.currentTempRange == 2 then
        return "COLD"
    elseif inst.currentTempRange == 4 then
        return "WARM"
    elseif inst.currentTempRange == 5 then
        return "HOT"
    end
end

local function AdjustLighting(inst, range, ambient)
    if inst._JBK_DEBUG_TRACE then -- FIXME(JBK): Remove this when no longer needed.
        -- This is not important enough for a crash this issue has been around for a while and it generates log file bloat.
        print(">>> A thermal stone somehow deleted its light entity but still exists and is a bad state.")
        print(">>> Please add a bug report with this log file to help diagnose what went wrong!")
        print("--- Trace:")
        print(inst._JBK_DEBUG_TRACE)
        print("<<< Please add a bug report with this log file to help diagnose what went wrong!")
        inst._JBK_DEBUG_TRACE = nil
        return
    end
    if range == 5 then
        local relativetemp = inst.components.temperature:GetCurrent() - ambient
        local baseline = relativetemp - relative_temperature_thresholds[4]
        local brightline = relative_temperature_thresholds[4] + 20
        inst._light.Light:SetIntensity( math.clamp(0.5 * baseline/brightline, 0, 0.5 ) )
    else
        inst._light.Light:SetIntensity(0)
    end
end

local function UpdateImages(inst, range)
    inst.currentTempRange = range

    --inst.AnimState:PlayAnimation(tostring(range), true)
    inst.AnimState:SetBuild("dumbbell_heat"..tostring(range) )
    inst.swap_dumbbell = "swap_dumbbell_heat"..tostring(range)
    inst.swap_dumbbell_symbol = "swap_dumbbell_heat"

    if inst.components.inventoryitem.owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:OverrideSymbol("swap_object", inst.swap_dumbbell, inst.swap_dumbbell_symbol)
    end

    local skinname = inst:GetSkinName()
    inst.components.inventoryitem:ChangeImageName((skinname or "dumbbell_heat")..tostring(range))
    if range == 5 then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst._light.Light:Enable(true)
    else
        inst.AnimState:ClearBloomEffectHandle()
        inst._light.Light:Enable(false)
    end
end

local function TemperatureChange(inst, data)
    local ambient_temp = TheWorld.state.temperature
    local cur_temp = inst.components.temperature:GetCurrent()
    local range = GetRangeForTemperature(cur_temp, ambient_temp)

    AdjustLighting(inst, range, ambient_temp)

    if range <= 1 then
        if inst.lowTemp == nil or inst.lowTemp > cur_temp then
            inst.lowTemp = math.floor(cur_temp)
        end
        inst.highTemp = nil
    elseif range >= 5 then
        if inst.highTemp == nil or inst.highTemp < cur_temp then
            inst.highTemp = math.ceil(cur_temp)
        end
        inst.lowTemp = nil
    elseif inst.lowTemp ~= nil then
        if GetRangeForTemperature(inst.lowTemp, ambient_temp) >= 3 then
            inst.lowTemp = nil
        end
    elseif inst.highTemp ~= nil and GetRangeForTemperature(inst.highTemp, ambient_temp) <= 3 then
        inst.highTemp = nil
    end

    if range ~= inst.currentTempRange then
        UpdateImages(inst, range)

        if (inst.lowTemp ~= nil and range >= 3) or
            (inst.highTemp ~= nil and range <= 3) then
            inst.lowTemp = nil
            inst.highTemp = nil
            inst.components.finiteuses:SetPercent(inst.components.finiteuses:GetPercent() - 1 / TUNING.HEATROCK_NUMUSES)
        end
    end
end

local function OnOwnerChange(inst)
    local newowners = {}
    local owner = inst
    while owner.components.inventoryitem ~= nil do
        newowners[owner] = true

        if inst._owners[owner] then
            inst._owners[owner] = nil
        else
            inst:ListenForEvent("onputininventory", inst._onownerchange, owner)
            inst:ListenForEvent("ondropped", inst._onownerchange, owner)
        end

        local nextowner = owner.components.inventoryitem.owner
        if nextowner == nil then
            break
        end

        owner = nextowner
    end

    if owner:HasTag("pocketdimension_container") or owner:HasTag("buried") then
        inst._light.entity:SetParent(inst.entity)
        if not inst._light:IsInLimbo() then
            inst._light:RemoveFromScene()
        end
    else
        inst._light.entity:SetParent(owner.entity)
        if inst._light:IsInLimbo() then
            inst._light:ReturnToScene()
        end
    end

    for k, v in pairs(inst._owners) do
        if k:IsValid() then
            inst:RemoveEventCallback("onputininventory", inst._onownerchange, k)
            inst:RemoveEventCallback("ondropped", inst._onownerchange, k)
        end
    end

    inst._owners = newowners
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

local function MakeDumbbell(name, consumption, efficiency, damage, impact_sound, walkspeedmult)
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
    
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle", true)
        MakeInventoryPhysics(inst)
    
        MakeInventoryFloatable(inst, "small", 0.15, 0.9)

        inst:AddTag("dumbbell")
		inst:AddTag("keep_equip_toss")
        
        if name == "dumbbell_bluegem" then
            inst.isiceattack = true
            inst.scrapbook_specialinfo = "DUMBBELLBLUE"
        elseif name == "dumbbell_redgem" then
            inst.isfireattack = true
            inst.scrapbook_specialinfo = "DUMBBELLRED"
        elseif name == "dumbbell_heat" then
            inst:AddTag("HASHEATER")
            inst:AddTag("icebox_valid")
            inst:AddTag("heatrock")
            inst.scrapbook_anim = "idle"
            inst.scrapbook_specialinfo = "DUMBBELLHEAT"
        else
            inst.scrapbook_specialinfo = "DUMBBELL"
        end

        inst:AddComponent("reticule")
        inst.components.reticule.targetfn = ReticuleTargetFn
		inst.components.reticule.shouldhidefn = ReticuleShouldHideFn
        inst.components.reticule.ease = true

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("inventoryitem")
        inst:AddComponent("inspectable")
        
        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.restrictedtag = "strongman"
		if walkspeedmult ~= nil then
		    inst.components.equippable.walkspeedmult = walkspeedmult
		end

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(damage)
        inst.components.weapon:SetOnAttack(OnAttack)
        inst.components.weapon.attackwear = consumption * TUNING.DUMBBELL_ATTACK_CONSUMPTION_MULT

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetOnFinished(function() 
            if inst.components.inventoryitem:GetGrandOwner() == nil then
                inst.components.inventoryitem.canbepickedup = false
                inst:DoTaskInTime(1, ErodeAway)
            else
                inst:Remove()        
            end
        end)

        if name == "dumbbell_heat" then

            inst.components.finiteuses:SetMaxUses(TUNING.DUMBBELL_HEAT_MAX_USES)
            inst.components.finiteuses:SetUses(TUNING.DUMBBELL_HEAT_MAX_USES)

            inst:AddComponent("tradable")
            inst.components.tradable.rocktribute = 6

            inst:AddComponent("temperature")
            inst.components.temperature.current = TheWorld.state.temperature
            inst.components.temperature.inherentinsulation = TUNING.INSULATION_MED
            inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_MED
            inst.components.temperature:IgnoreTags("heatrock")

            inst:AddComponent("heater")
            inst.components.heater.heatfn = HeatFn
            inst.components.heater.carriedheatfn = HeatFn
            inst.components.heater.carriedheatmultiplier = TUNING.HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR
            inst.components.heater:SetThermics(false, false)

            inst:ListenForEvent("temperaturedelta", TemperatureChange)
            inst.currentTempRange = 0

            --Create light
            inst._light = SpawnPrefab("heatrocklight")
            inst._owners = {}
            inst._onownerchange = function() OnOwnerChange(inst) end
            --

            UpdateImages(inst, 3)
            OnOwnerChange(inst)

            inst.OnSave = OnSave
            inst.OnLoad = OnLoad
            inst.OnRemoveEntity = OnRemove
        end

        MakeHauntableLaunch(inst)
    
        if name == "dumbbell_redgem" then
            inst:AddComponent("lootdropper")
        end

        inst:AddComponent("mightydumbbell")
        inst.components.mightydumbbell:SetConsumption(consumption)
        inst.components.mightydumbbell:SetEfficiency(efficiency[1], efficiency[2], efficiency[3])

        inst.swap_dumbbell = "swap_" .. name
        inst.swap_dumbbell_symbol = "swap_" .. name
        inst.thrown_consumption = consumption * TUNING.DUMBBELL_THROWN_CONSUMPTION_MULT
        inst.impact_sound = impact_sound

        inst:ListenForEvent("onputininventory", OnPickup)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeDumbbell("dumbbell",             TUNING.DUMBBELL_CONSUMPTION_ROCK,       { TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_LOW  }, TUNING.DUMBBELL_DAMAGE_ROCK,    "wolfgang1/dumbbell/stone_impact"),
       MakeDumbbell("dumbbell_golden",      TUNING.DUMBBELL_CONSUMPTION_GOLD,       { TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_LOW  }, TUNING.DUMBBELL_DAMAGE_GOLD,    "wolfgang1/dumbbell/gold_impact"),
       MakeDumbbell("dumbbell_marble",      TUNING.DUMBBELL_CONSUMPTION_MARBLE,	    { TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_MED  }, TUNING.DUMBBELL_DAMAGE_MARBLE,  "wolfgang1/dumbbell/stone_impact", TUNING.DUMBBELL_SLOW_MARBEL),
       MakeDumbbell("dumbbell_gem",         TUNING.DUMBBELL_CONSUMPTION_GEM,        { TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH }, TUNING.DUMBBELL_DAMAGE_GEM,     "wolfgang1/dumbbell/gem_impact"),
       MakeDumbbell("dumbbell_heat",        TUNING.DUMBBELL_CONSUMPTION_HEAT,       { TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_MED,  TUNING.DUMBBELL_EFFICIENCY_LOW },  TUNING.DUMBBELL_DAMAGE_HEAT,    "wolfgang1/dumbbell/gem_impact"),
       MakeDumbbell("dumbbell_redgem",      TUNING.DUMBBELL_CONSUMPTION_REDEM,      { TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH }, TUNING.DUMBBELL_DAMAGE_REDGEM,  "wolfgang1/dumbbell/gem_impact"),
       MakeDumbbell("dumbbell_bluegem",     TUNING.DUMBBELL_CONSUMPTION_BLUEGEM,    { TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH, TUNING.DUMBBELL_EFFICIENCY_HIGH }, TUNING.DUMBBELL_DAMAGE_BLUEGEM, "wolfgang1/dumbbell/gem_impact")
