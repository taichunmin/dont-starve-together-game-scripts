local willow_ember_common = require("prefabs/willow_ember_common")

local assets =
{
    Asset("ANIM", "anim/willow_embers.zip"),
	Asset("ANIM", "anim/spell_icons_willow.zip"),

    Asset("INV_IMAGE", "willow_ember"),
    Asset("INV_IMAGE", "willow_ember_open"),
    Asset("SCRIPT", "scripts/prefabs/willow_ember_common.lua"),
}

local prefabs =
{
    "spell_fire_throw",
    "firesplash_fx",
    "firering_fx",
    "flamethrower_fx",
    "willow_shadow_flame",
    "willow_throw_flame",
    "deerclops_laserscorch",
    "reticulemultitarget",
    "reticuleaoe5line",
    "reticuleaoeping5line",
    "willow_frenzy",
}

local SCALE = .8

local SPELLCOSTS = {
    ["firethrow"] = TUNING.WILLOW_EMBER_THROW,
    ["fireburst"] = TUNING.WILLOW_EMBER_BURST,
    ["fireball"] = TUNING.WILLOW_EMBER_BALL,
    ["lunarfire"] = TUNING.WILLOW_EMBER_LUNAR,
    ["firefrenzy"] = TUNING.WILLOW_EMBER_FRENZY,
    ["shadowfire"] = TUNING.WILLOW_EMBER_SHADOW,
}

local function WatchSkillRefresh_Server(inst, owner)
	if inst._owner then
		inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh_server, inst._owner)
		inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh_server, inst._owner)
	end
	inst._owner = owner
	if owner then
		inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh_server, owner)
		inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh_server, owner)
	end
end

local function WatchSkillRefresh_Client(inst, owner)
	if inst._owner then
		inst:RemoveEventCallback("onactivateskill_client", inst._onskillrefresh_client, inst._owner)
		inst:RemoveEventCallback("ondeactivateskill_client", inst._onskillrefresh_client, inst._owner)
	end
	inst._owner = owner
	if owner then
		inst:ListenForEvent("onactivateskill_client", inst._onskillrefresh_client, owner)
		inst:ListenForEvent("ondeactivateskill_client", inst._onskillrefresh_client, owner)
	end
end

------------------------------------------

local function EnablePickupSound(inst)
	inst.pickupsound = nil
end

local function OnTempDisablePickupSound(inst)
	if inst.pickupsound == nil then
		inst.pickupsound = "NONE"
		inst:DoStaticTaskInTime(2 * FRAMES, EnablePickupSound)
	end
end

local function KillEmber(inst)
    inst:ListenForEvent("animover", inst.Remove)

    inst.AnimState:PlayAnimation("idle_pst")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
end

local function toground(inst)
    inst.persists = false

    if inst._task == nil then
        inst._task = inst:DoTaskInTime(TUNING.WILLOW_EMBER_DURATION, KillEmber) -- NOTES(JBK): This is 1.1 max keep it in sync with "[WST]"
    end

    if inst.AnimState:IsCurrentAnimation("idle_loop") then
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    end

	if inst._owner then
		WatchSkillRefresh_Server(inst, nil)
		inst._updatespells:push()
	end
end

local EMBER_TAGS = { "willow_ember" }

local function OnDropped(inst)
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local num = 10 - TheSim:CountEntities(x, y, z, 4, EMBER_TAGS)

        if num > 0 then
            for i = 1, math.min(num, inst.components.stackable:StackSize()) do
                local ember = inst.components.stackable:Get()
                ember.Physics:Teleport(x, y, z)
                ember.components.inventoryitem:OnDropped(true)
            end
        end
    end
end

------------------------------------------
-- MAGIC STUFF

local function CheckStackSize(inst, doer, spell)
    return doer.replica.inventory ~= nil and doer.replica.inventory:Has(inst.prefab, SPELLCOSTS[spell])
end

local function OnOpenSpellBook(inst)
    local inventoryitem = inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:OverrideImage("willow_ember_open")
    end

    TheFocalPoint.SoundEmitter:PlaySound("meta3/willow/ember_container_open","willow_ember_open")
end

local function OnCloseSpellBook(inst)
    local inventoryitem = inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:OverrideImage(nil)
    end

    TheFocalPoint.SoundEmitter:KillSound("willow_ember_open")
end

local function tryconsume(inst, inventory, v, amount)
	local stacksize = v.components.stackable:StackSize()
	if stacksize > amount then
		v.components.stackable:SetStackSize(stacksize - amount)
		return amount, false
	elseif inst == v then
		--this is the stack we used to cast the spell, so defer it's removal
		return stacksize, true
	end
	inventory:RemoveItem(v, true):Remove()
	return stacksize, false
end

local function ConsumeEmbers(inst, doer, amount)
	if amount <= 0 then
		return
	end

	local inventory = doer.components.inventory
	local casting_stack_depleted = false

	--only check inventory slots (& active slot), since embers can't go in containers
	for i = 1, inventory:GetNumSlots() do
		local v = inventory:GetItemInSlot(i)
		if v and v.prefab == inst.prefab then
			local dec, deferred_removal = tryconsume(inst, inventory, v, amount)
			amount = amount - dec
			casting_stack_depleted = casting_stack_depleted or deferred_removal

			if amount <= 0 then
				if casting_stack_depleted then
					--try to swap the casting stack with a remaining stack for removal.
					--this allows us to continue repeat casting using the stack.
					for j = i, inventory:GetNumSlots() do
						local v2 = inventory:GetItemInSlot(j)
						if v2 and v2 ~= inst and v2.prefab == inst.prefab then
							inst._tempdisablepickupsound:push()
							inst.pickupsound = "NONE"
							inst.components.stackable:SetStackSize(v2.components.stackable:StackSize())
							inventory:RemoveItem(v2, true):Remove()
							inventory:RemoveItem(inst, true)
							inventory:GiveItem(inst, j)
							inst.pickupsound = nil
							return
						end
					end
					--nothing to swap with so we have to actually remove it
					inventory:RemoveItem(inst, true):Remove()
				end
				return
			end
		end
	end

	if casting_stack_depleted then
		--we still have to consume more, so just remove it
		inventory:RemoveItem(inst, true):Remove()
	end

	local active_item = inventory:GetActiveItem()
	if active_item and active_item.prefab == inst.prefab then
		tryconsume(inst, inventory, active_item, amount)
	end
end

local SPAWN_FIRE_CANT =     { "player", "INLIMBO", "FX", "NOCLICK" }
local SPAWN_FIRE_CANT_PVP = { "INLIMBO", "FX", "NOCLICK" }

local function ThrowFire_SpawnFire(inst, doer, pos)
    local x, y, z = pos:Get()

    SpawnPrefab("willow_throw_flame").Transform:SetPosition(x, 0, z)

    local ents = TheSim:FindEntities(x, 0, z, 2, nil, TheNet:GetPVPEnabled() and SPAWN_FIRE_CANT_PVP or SPAWN_FIRE_CANT)

    if doer == nil or ents == nil then
        return
    end

    for i, target in ipairs(ents) do
        if target ~= doer and
            target.components.burnable ~= nil
        then
            if target.components.freezable ~= nil and target.components.freezable:IsFrozen() then
                target.components.freezable:Unfreeze()

            elseif target.components.fueled == nil or (
                target.components.fueled.fueltype ~= FUELTYPE.BURNABLE and
                target.components.fueled.secondaryfueltype ~= FUELTYPE.BURNABLE
            ) then
                -- Does not take burnable fuel, so just burn it.
                if target.components.burnable.canlight or target.components.combat ~= nil then
                    target.components.burnable:Ignite(true, inst, doer)
                end

            elseif target.components.fueled.accepting then
                -- Takes burnable fuel, so fuel it.
                local fuel = SpawnPrefab("boards")

                if fuel ~= nil then
                    if fuel.components.fuel ~= nil and
                        fuel.components.fuel.fueltype == FUELTYPE.BURNABLE
                    then
                        target.components.fueled:TakeFuelItem(fuel)
                    else
                        fuel:Remove()
                    end
                end
            end
        elseif target ~= doer and target:HasTag("canlight") then
            target:PushEvent("onlighterlight")
        end
    end
end

local function TryThrowFire(inst, doer, pos)
    if CheckStackSize(inst, doer, "firethrow") then
        ThrowFire_SpawnFire(inst, doer, pos)

        return true
    end

    return false
end

local function spawnfirefx(pos)
    local ring = SpawnPrefab("firering_fx")
    ring.Transform:SetPosition(pos.x,pos.y,pos.z)

    local theta = math.random(TWOPI)

    for i=1,4 do
        local radius = 4
        local newtheta = theta  + (PI/2*i)
        local offset = Vector3(radius * math.cos( newtheta ), 0, -radius * math.sin( newtheta ))
        local puff = SpawnPrefab("firesplash_fx")
        local newpos = pos+offset
        puff.Transform:SetPosition(newpos.x, newpos.y, newpos.z)
    end
end

local function DoBurstFire(doer, inst, ent)
	if ent:IsValid() then
		if ent.components.burnable then
			ent.components.burnable:Ignite(nil, inst, doer)
		else
			ent:PushEvent("onlighterlight")
		end
	end
end

local function TryBurstFire(inst, doer, pos)
    if CheckStackSize(inst, doer, "fireburst") then
        local ents = willow_ember_common.GetBurstTargets(doer)
        local success = false

        if ents == nil then
            return false
        end

        for i, ent in ipairs(ents) do
            if ent ~= doer then
				local distsq = doer:GetDistanceSqToInst(ent)
                local time = Remap(distsq, 0, TUNING.FIRE_BURST_RANGE*TUNING.FIRE_BURST_RANGE, 0, 0.5)
				doer:DoTaskInTime(time, DoBurstFire, inst, ent)
                success = true
            end
        end

        return success
    end

    return false
end

local function TryBallFire(inst, doer, pos)
    if CheckStackSize(inst, doer, "fireball") then
        local ball= SpawnPrefab("emberlight")
        ball.Transform:SetPosition(pos.x,pos.y,pos.z)
        return true
    end
    return false
end

local function EndLunarFire(fx, doer)
	if doer.components.channelcaster then
		doer.components.channelcaster:StopChanneling()
	end
end

local function TryLunarFire(inst, doer, pos)
    if CheckStackSize(inst, doer, "lunarfire") and
		doer.components.channelcaster and
		not doer.components.channelcaster:IsChanneling()
	then
		local fx = SpawnPrefab("flamethrower_fx")
		fx.entity:SetParent(doer.entity)
		fx:SetFlamethrowerAttacker(doer)

		local endtask = fx:DoTaskInTime(TUNING.WILLOW_LUNAR_FIRE_TIME, EndLunarFire, doer)

		fx:ListenForEvent("stopchannelcast", function()
			if fx then
				endtask:Cancel()
				fx:KillFX()
				fx = nil
			end
		end, doer)

		if doer.components.spellbookcooldowns then
			doer.components.spellbookcooldowns:RestartSpellCooldown("lunar_fire", TUNING.WILLOW_LUNAR_FIRE_COOLDOWN)
		end

		if doer.components.channelcaster:StartChanneling() then
			return true
		end

		--channelcast fail
		fx:Remove()
    end
    return false
end

local function DoShadowFire(doer, x, z, rot)
	local fire = SpawnPrefab("willow_shadow_flame")
	fire.Transform:SetRotation(rot)
	fire.Transform:SetPosition(x, 0, z)
	fire:settarget(nil, 50, doer)
end

local function TryShadowFire(inst, doer, pos)
    if CheckStackSize(inst, doer, "shadowfire") then
		local burst = 5
		local radius = 2
		local x, y, z = doer.Transform:GetWorldPosition()
		local theta = x == pos.x and z == pos.z and doer.Transform:GetRotation() * DEGREES or math.atan2(z - pos.z, pos.x - x)
		local delta = PI2 / burst
        for i=1,burst do
			local x1 = x + radius * math.cos(theta)
			local z1 = z - radius * math.sin(theta)
			doer:DoTaskInTime(math.random() * 0.2, DoShadowFire, x1, z1, theta * RADIANS)
			theta = theta + delta
        end

		if doer.components.spellbookcooldowns then
			doer.components.spellbookcooldowns:RestartSpellCooldown("shadow_fire", TUNING.WILLOW_SHADOW_FIRE_COOLDOWN)
		end

        return true
    end
    return false
end

local function TryFireFrenzy(inst, doer, pos)
    if CheckStackSize(inst, doer, "firefrenzy") then

        doer:AddDebuff("buff_firefrenzy", "buff_firefrenzy")

        return true
    end
    return false
end

local function FireBurstSpellFn(inst, doer, pos)
    if not CheckStackSize(inst, doer, "fireburst") then
        return false, "NOT_ENOUGH_EMBERS"
    elseif TryBurstFire(inst, doer, pos) then
		ConsumeEmbers(inst, doer, SPELLCOSTS["fireburst"])

        return true
    end
    return false, "NO_TARGETS"
end

local function FireThrowSpellFn(inst, doer, pos)
    if not CheckStackSize(inst, doer, "firethrow") then
        return false, "NOT_ENOUGH_EMBERS"
    elseif TryThrowFire(inst, doer, pos) then
		ConsumeEmbers(inst, doer, SPELLCOSTS["firethrow"])
        return true
    end
    return false
end

local function FireBallSpellFn(inst, doer, pos)
    if not CheckStackSize(inst, doer, "fireball") then
        return false, "NOT_ENOUGH_EMBERS"
    elseif TryBallFire(inst, doer, pos) then
		ConsumeEmbers(inst, doer, SPELLCOSTS["fireball"])
        return true
    end
    return false
end

local function LunarFireSpellFn(inst, doer, pos)
	if doer.components.spellbookcooldowns and doer.components.spellbookcooldowns:IsInCooldown("lunar_fire") then
        return false, "SPELL_ON_COOLDOWN"
	elseif doer.components.rider and doer.components.rider:IsRiding() then
        return false, "CANT_SPELL_MOUNTED"
    elseif not CheckStackSize(inst, doer, "lunarfire") then
        return false, "NOT_ENOUGH_EMBERS"
    elseif TryLunarFire(inst, doer, pos) then
		ConsumeEmbers(inst, doer, SPELLCOSTS["lunarfire"])
        return true
    end
    return false
end

local function ShadowFireSpellFn(inst, doer, pos)
	if doer.components.spellbookcooldowns and doer.components.spellbookcooldowns:IsInCooldown("shadow_fire") then
        return false, "SPELL_ON_COOLDOWN"    
    elseif not CheckStackSize(inst, doer, "shadowfire") then
        return false, "NOT_ENOUGH_EMBERS"
    elseif TryShadowFire(inst, doer, pos) then
		ConsumeEmbers(inst, doer, SPELLCOSTS["shadowfire"])
        return true
    end
    return false
end

local function FireFrenzySpellFn(inst, doer, pos)
    if not CheckStackSize(inst, doer, "firefrenzy") then
        return false, "NOT_ENOUGH_EMBERS"
    elseif TryFireFrenzy(inst, doer, pos) then
		ConsumeEmbers(inst, doer, SPELLCOSTS["firefrenzy"])
        return true
    end
    return false
end

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ReticuleFireBallTargetFn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0.001, 0)) -- Raised this off the ground a touch so it wont have any z-fighting with the ground biome transition tiles.
end

local function ReticuleFireThrowTargetFn(inst)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(7, 0.001, 0)) -- Raised this off the ground a touch so it wont have any z-fighting with the ground biome transition tiles.
end

local function StartAOETargeting(inst)
    local playercontroller = ThePlayer.components.playercontroller
    if playercontroller ~= nil then
        playercontroller:StartAOETargetingUsing(inst)
    end
end

local function ShouldRepeatFireThrow(inst, doer)
    return CheckStackSize(inst, doer, "firethrow")
end

local function ShouldRepeatFireBurst(inst, doer)
    return CheckStackSize(inst, doer, "fireburst")
end

local function ShouldRepeatFireBall(inst, doer)
    return CheckStackSize(inst, doer, "fireball")
end

-------------------------------------------------------------
local function burst_reticule_mouse_target_function(inst, mousepos)
    if mousepos == nil then
        return nil
    end
    local inventoryitem = inst.replica.inventoryitem
    local owner = inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
    if owner then
        local pos = Vector3(owner.Transform:GetWorldPosition())
        return pos
    end
end

local function burst_reticule_target_function(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        local inventoryitem = inst.replica.inventoryitem
        local owner =  inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
        if owner then
            local pos = Vector3(owner.Transform:GetWorldPosition())
            return pos
        end
    end
end

local function burst_reticule_update_position_function(inst, pos, reticule, ease, smoothing, dt)
    local inventoryitem = inst.replica.inventoryitem
    local owner = inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer

    if owner then
        reticule.Transform:SetPosition(Vector3(owner.Transform:GetWorldPosition()):Get())
        reticule.Transform:SetRotation(0)
    end
end

--------------------------------------------------

local function single_reticule_mouse_target_function(inst, mousepos)
    if mousepos == nil then
        return nil
    end
    local inventoryitem = inst.replica.inventoryitem
    local owner = inventoryitem:IsHeldBy(ThePlayer) and ThePlayer
    if owner then
        local pos = Vector3(owner.Transform:GetWorldPosition())
        return pos
    end
end

local function single_reticule_target_function(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        local inventoryitem = inst.replica.inventoryitem
        local owner = inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
        if owner then
            local pos = Vector3(owner.Transform:GetWorldPosition())
            return pos
        end
    end
end

local function single_reticule_update_position_function(inst, pos, reticule, ease, smoothing, dt)

    local inventoryitem = inst.replica.inventoryitem
    local owner = inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer

    if owner then
        reticule.Transform:SetPosition(Vector3(owner.Transform:GetWorldPosition()):Get())
        reticule.Transform:SetRotation(0)
    end
end

-------------------------------------------------

local function line_reticule_target_function(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        local inventoryitem = inst.replica.inventoryitem
        local owner =  inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
        if owner then
			return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
        end
    end
end

local function line_reticule_mouse_target_function(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function line_reticule_update_position_function(inst, pos, reticule, ease, smoothing, dt)
    local inventoryitem = inst.replica.inventoryitem
	if inventoryitem and inventoryitem:IsHeldBy(ThePlayer) then
		reticule.Transform:SetPosition(ThePlayer.Transform:GetWorldPosition())
		local rot1 = reticule:GetAngleToPoint(inst.components.reticule.targetpos)
		if ease and dt then
			local rot = reticule.Transform:GetRotation()
			local drot = ReduceAngle(rot1 - rot)
			rot1 = Lerp(rot, rot + drot, dt * smoothing)
		end
		reticule.Transform:SetRotation(rot1)
    end
end

---------------------------------------------------

local ICON_SCALE = .6
local ICON_RADIUS = 50
local SPELLBOOK_RADIUS = 100
local SPELLBOOK_FOCUS_RADIUS = SPELLBOOK_RADIUS + 2
local BASESPELLS = {}

local SKILLTREE_SPELL_DEFS =
{
	["willow_embers"] =
    {
        label = STRINGS.PYROMANCY.FIRE_THROW,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.PYROMANCY.FIRE_THROW)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatFireThrow)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoefiretarget_1"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoefiretarget_1ping"

            inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.targetfn = ReticuleFireThrowTargetFn 
            inst.components.aoetargeting.reticule.updatepositionfn = nil

            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoefiretarget_1")
                inst.components.aoespell:SetSpellFn(FireThrowSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "fire_throw" },
			focus = { anim = "fire_throw_focus", loop = true },
			down = { anim = "fire_throw_pressed" },
		},
        widget_scale = ICON_SCALE,
    },

	["willow_fire_burst"] =
    {
        label = STRINGS.PYROMANCY.FIRE_BURST,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.PYROMANCY.FIRE_BURST)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatFireBurst)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticulemultitarget"
            inst.components.aoetargeting.reticule.pingprefab = "reticulemultitargetping"

            inst.components.aoetargeting.reticule.mousetargetfn = burst_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = burst_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = burst_reticule_update_position_function

            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(FireBurstSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "fire_burst" },
			focus = { anim = "fire_burst_focus", loop = true },
			down = { anim = "fire_burst_pressed" },
		},
        widget_scale = ICON_SCALE,
    },

	["willow_fire_ball"] =
    {
        label = STRINGS.PYROMANCY.FIRE_BALL,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.PYROMANCY.FIRE_BALL)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatFireBall)
            
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoefiretarget_1"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoefiretarget_1ping"

            inst.components.aoetargeting.reticule.mousetargetfn = nil
            inst.components.aoetargeting.reticule.updatepositionfn = nil
            inst.components.aoetargeting.reticule.targetfn = ReticuleFireBallTargetFn

            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoefiretarget_1")
                inst.components.aoespell:SetSpellFn(FireBallSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "fire_ball" },
			focus = { anim = "fire_ball_focus", loop = true },
			down = { anim = "fire_ball_pressed" },
		},
        widget_scale = ICON_SCALE,
    },

	["willow_fire_frenzy"] =
    {
        label = STRINGS.PYROMANCY.FIRE_FRENZY,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.PYROMANCY.FIRE_FRENZY)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoefiretarget_1"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoefiretarget_1ping"

            inst.components.aoetargeting.reticule.mousetargetfn = single_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = single_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = single_reticule_update_position_function

            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(FireFrenzySpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "fire_frenzy" },
			focus = { anim = "fire_frenzy_focus", loop = true },
			down = { anim = "fire_frenzy_pressed" },
		},
        widget_scale = ICON_SCALE,
    },

	["willow_allegiance_lunar_fire"] =
    {
        label = STRINGS.PYROMANCY.LUNAR_FIRE,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.PYROMANCY.LUNAR_FIRE)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
            inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"

            inst.components.aoetargeting.reticule.mousetargetfn = line_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = line_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = line_reticule_update_position_function

            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(LunarFireSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "lunar_fire" },
			focus = { anim = "lunar_fire_focus", loop = true },
			down = { anim = "lunar_fire_pressed" },
			disabled = { anim = "lunar_fire_disabled" },
			cooldown = { anim = "lunar_fire_cooldown" },
		},
        widget_scale = ICON_SCALE,
		checkenabled = function(user)
			--client safe
			local rider = user and user.replica.rider
			return not (rider and rider:IsRiding())
		end,
		checkcooldown = function(user)
			--client safe
			return user
				and user.components.spellbookcooldowns
				and user.components.spellbookcooldowns:GetSpellCooldownPercent("lunar_fire")
				or nil
		end,
		cooldowncolor = { 0.65,0.65,0.65, 0.75 },
    },

	["willow_allegiance_shadow_fire"] =
    {
        label = STRINGS.PYROMANCY.SHADOW_FIRE,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.PYROMANCY.SHADOW_FIRE)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe5line"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping5line"

            inst.components.aoetargeting.reticule.mousetargetfn = line_reticule_mouse_target_function
            inst.components.aoetargeting.reticule.targetfn = line_reticule_target_function
            inst.components.aoetargeting.reticule.updatepositionfn = line_reticule_update_position_function

            if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX(nil)
                inst.components.aoespell:SetSpellFn(ShadowFireSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
		bank = "spell_icons_willow",
		build = "spell_icons_willow",
		anims =
		{
			idle = { anim = "shadow_fire" },
			focus = { anim = "shadow_fire_focus", loop = true },
			down = { anim = "shadow_fire_pressed" },
			cooldown = { anim = "shadow_fire_cooldown" },
		},
        widget_scale = ICON_SCALE,
		checkcooldown = function(user)
			--client safe
			return user
				and user.components.spellbookcooldowns
				and user.components.spellbookcooldowns:GetSpellCooldownPercent("shadow_fire")
				or nil
		end,
		cooldowncolor = { 0.5,0.5,0.5, 0.75 },
    },
}

local SKILLTREE_SPELL_ORDER =
{
	"willow_embers",
	"willow_fire_burst",
	"willow_fire_ball",
	"willow_fire_frenzy",
	"willow_allegiance_lunar_fire",
	"willow_allegiance_shadow_fire",
}

local function updatespells(inst,owner)
    local spells = shallowcopy(BASESPELLS)
	if owner then
		for i, v in ipairs(SKILLTREE_SPELL_ORDER) do
			if owner.components.skilltreeupdater:IsActivated(v) then
				table.insert(spells, SKILLTREE_SPELL_DEFS[v])
			end
		end
	end
    inst.components.spellbook:SetItems(spells)
end

local function DoClientUpdateSpells(inst, force)
	--V2C: inst.replica.inventoryitem:IsHeldBy(ThePlayer) won't work for new ember
	--     spawned directly in pocket, because inventory preview won't have been
	--     resolved yet.
	--     Use IsHeld(), and assume it's ours, since this can only go into pockets
	--     and not containers.
	local owner = inst.replica.inventoryitem:IsHeld() and ThePlayer or nil
	if owner ~= inst._owner then
		if owner then
			updatespells(inst, owner)
		end
		WatchSkillRefresh_Client(inst, owner)
	elseif force and owner then
		updatespells(inst, owner)
	end
end

local function OnUpdateSpellsDirty(inst)
	inst:DoTaskInTime(0, DoClientUpdateSpells)
end

local function DoOnClientInit(inst)
	inst:ListenForEvent("willow_ember._tempdisablepickupsound", OnTempDisablePickupSound)
    inst:ListenForEvent("willow_ember._updatespells", OnUpdateSpellsDirty)
	DoClientUpdateSpells(inst)
end

local function topocket(inst, owner)
    inst.persists = true
    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end

	if owner ~= inst._owner then
		inst._updatespells:push()
		updatespells(inst, owner)
		WatchSkillRefresh_Server(inst, owner)
	end
end

-- END MAGIC STUFF
-----------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("willow_embers")
    inst.AnimState:SetBuild("willow_embers")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetScale(SCALE, SCALE)

    inst:AddTag("nosteal")
    inst:AddTag("NOCLICK")

    inst:AddTag("willow_ember")

    inst.scrapbook_specialinfo = "WILLOWEMBER"

    inst:AddComponent("spellbook")
    inst.components.spellbook:SetRequiredTag("ember_master")
    inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
    inst.components.spellbook:SetFocusRadius(SPELLBOOK_RADIUS)--UIAnimButton don't use focus radius SPELLBOOK_FOCUS_RADIUS)
    inst.components.spellbook:SetItems(BASESPELLS)
    inst.components.spellbook:SetOnOpenFn(OnOpenSpellBook)
    inst.components.spellbook:SetOnCloseFn(OnCloseSpellBook)
    inst.components.spellbook.closesound = "meta3/willow/ember_container_close"

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8

    inst._updatespells = net_event(inst.GUID, "willow_ember._updatespells")
	inst._tempdisablepickupsound = net_event(inst.GUID, "willow_ember._tempdisablepickupsound")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0,DoOnClientInit)
		inst._onskillrefresh_client = function(owner) DoClientUpdateSpells(inst, true) end

        return inst
    end

	inst._onskillrefresh_server = function(owner) updatespells(inst, owner) end

    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = FUELTYPE.LIGHTER
    inst.components.fuel.fuelvalue = TUNING.HUGE_FUEL

    inst:AddComponent("aoespell")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("locomotor")

    --inst.components.inventoryitem:ChangeImageName("willow_ember")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst._activetask = nil
    inst._soundtasks = {}

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.castsound = "maxwell_rework/shadow_magic/cast"

    inst._task = nil
    toground(inst)

    return inst
end

local function Buff_OnKill(inst)
    inst.components.debuff:Stop()
end

local function Buff_OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    inst.bufftask = inst:DoTaskInTime(TUNING.WILLOW_FIREFRENZY_DURATION, Buff_OnKill)

    if target ~= nil and target:IsValid() then
        target:AddTag("firefrenzy")

        local fx = SpawnPrefab("willow_frenzy")
        fx.entity:SetParent(target.entity)

        inst.bufffx = fx
    end
end

local function Buff_OnDetached(inst, target)
    if target ~= nil and target:IsValid() then
        target:RemoveTag("firefrenzy")
    end

    if inst.bufffx and inst.bufffx:IsValid() then
        inst.bufffx:Kill()
    end

    inst.bufffx = nil
    inst:Remove()
end

local function Buff_OnExtended(inst, target)
    if inst.bufftask ~= nil then
        inst.bufftask:Cancel()
        inst.bufftask = inst:DoTaskInTime(TUNING.WILLOW_FIREFRENZY_DURATION, Buff_OnKill)
    end
end

local function bufffn()
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

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(Buff_OnAttached)
    inst.components.debuff:SetDetachedFn(Buff_OnDetached)
    inst.components.debuff:SetExtendedFn(Buff_OnExtended)
    inst.components.debuff.keepondespawn = true

    return inst
end

return Prefab("willow_ember", fn, assets, prefabs),
       Prefab("buff_firefrenzy", bufffn, nil, prefabs)
