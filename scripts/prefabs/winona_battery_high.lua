require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/winona_battery_high.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
    Asset("ANIM", "anim/gems.zip"),
}

local assets_fx =
{
    Asset("ANIM", "anim/gems.zip"),
}

local assets_item =
{
	Asset("ANIM", "anim/winona_battery_high.zip"),
}

local prefabs =
{
    "collapse_small",
    "winona_battery_high_shatterfx",
	"winona_battery_high_item",
	"purebrilliance_symbol_fx",
	"alterguardianhatshard_symbol_fx",
}

local prefabs_item =
{
	"winona_battery_high",
}

--------------------------------------------------------------------------

local function CalcEfficiencyMult(inst, override)
	return TUNING.SKILLS.WINONA.BATTERY_EFFICIENCY_RATE_MULT[override or inst._efficiency] or 1
end

local function ApplyEfficiencyBonus(inst)
	local mult = CalcEfficiencyMult(inst)
	if mult ~= 1 then
		inst.components.fueled.rate_modifiers:SetModifier(inst, mult, "efficiency")
	else
		inst.components.fueled.rate_modifiers:RemoveModifier(inst, "efficiency")
	end
end

local function IsEngineerOnline(inst)
	if inst._engineerid then
		local clients = TheNet:GetClientTable()
		if clients then
			local isdedicated = not TheNet:GetServerIsClientHosted()
			for i, v in ipairs(clients) do
				if not isdedicated or v.performance == nil then
					if v.userid == inst._engineerid then
						--no inst if it's on another shard, so can't test :HasTag("handyperson")
						return v.prefab == "winona"
					end
				end
			end
		end
	end
	return false
end

local function ConfigureSkillTreeUpgrades(inst, builder)
	local skilltreeupdater = builder and builder.components.skilltreeupdater or nil

	local noidledrain = skilltreeupdater ~= nil and skilltreeupdater:IsActivated("winona_battery_idledrain")

	local efficiency = skilltreeupdater and
		(	(skilltreeupdater:IsActivated("winona_battery_efficiency_3") and 3) or
			(skilltreeupdater:IsActivated("winona_battery_efficiency_2") and 2) or
			(skilltreeupdater:IsActivated("winona_battery_efficiency_1") and 1)
		) or 0

	local dirty = inst._noidledrain ~= noidledrain or inst._efficiency ~= efficiency

	inst._noidledrain = noidledrain
	inst._efficiency = efficiency
	inst._engineerid = builder and builder:HasTag("handyperson") and builder.userid or nil

	return dirty
end

local function CalcShardRegenSpeedMult(inst)
	return TUNING.WINONA_BATTERY_HIGH_SHARD_REGEN_MULT[math.clamp(inst._shard_level, 1, 3)]
		* CalcEfficiencyMult(inst)
end

local function CalcShardRegenDelay(inst)
	return TUNING.WINONA_BATTERY_HIGH_SHARD_DELAY * CalcShardRegenSpeedMult(inst)
end

local function CalcOverloadThreshold(inst)
	return TUNING.WINONA_BATTERY_HIGH_OVERLOAD_THRESHOLD --base
		* #inst._gems / 3 --capacity
		* CalcShardRegenSpeedMult(inst)
end

--------------------------------------------------------------------------

local IDLE_CHARGE_SOUND_FRAMES = { 0, 3, 17, 20 }

local function DoIdleChargeSound(inst)
	local t = inst.AnimState:GetCurrentAnimationFrame()
    if (t == 0 or t == 3 or t == 17 or t == 20) and inst._lastchargeframe ~= t then
        inst._lastchargeframe = t
        inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, GetRandomMinMax(.2, .5))
    end
end

local function StartIdleChargeSounds(inst)
	if inst._lastchargeframe == nil then
		inst._lastchargeframe = -1
        inst.components.updatelooper:AddOnUpdateFn(DoIdleChargeSound)
    end
end

local function StopIdleChargeSounds(inst)
	if inst._lastchargeframe ~= nil then
		inst._lastchargeframe = nil
        inst.components.updatelooper:RemoveOnUpdateFn(DoIdleChargeSound)
    end
end

--------------------------------------------------------------------------
--Helper functions for the FX and presentation;
--used by DropGems & UnsetGem

local function FlingGem(inst, gemdata, slot)
	local pt = inst:GetPosition()
	pt.y = 2.5 + .5 * slot
	local gem
	if type(gemdata) == "table" then
		gem = SpawnSaveRecord(gemdata)
	else
		gem = SpawnPrefab(gemdata)
	end
	gem.components.inventoryitem:InheritWorldWetnessAtTarget(inst)
	inst.components.lootdropper:FlingItem(gem, pt)
    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    end
    return gem
end

local function LoseGem(inst, gemname, slot, followsymbol)
	local fx = SpawnPrefab("winona_battery_high_shatterfx")
	local anim = gemname.."_shatter"
	if not fx.AnimState:IsCurrentAnimation(anim) then
		fx.AnimState:PlayAnimation(anim)
	end
	if followsymbol then
		fx.entity:AddFollower():FollowSymbol(inst.GUID, followsymbol)
	else
		local x, y, z = inst.Transform:GetWorldPosition()
		fx.Transform:SetPosition(x, 2.5 + .75 * slot, z)
	end
	inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
end

--------------------------------------------------------------------------

local NUM_LEVELS = 6
local GEMSLOTS = 3
local LEVELS_PER_GEM = 2

local function GetGemSymbol(slot)
    return "gem"..tostring(GEMSLOTS - slot + 1)
end

local function SetBrillianceEnergyEnabled(inst, enable)
	if enable then
		inst.AnimState:Show("PB_ENERGY")
		inst.AnimState:SetSymbolLightOverride("rack_frame", 0.1)
		inst.AnimState:SetSymbolLightOverride("rack_frame_back", 0.1)
		inst.AnimState:SetSymbolLightOverride("rack_base", 0.05)
		if inst.components.inventoryitem then
			inst.AnimState:SetSymbolLightOverride("plug_off", 0.1)
			inst.AnimState:SetSymbolLightOverride("wire_red", 0.1)
			inst.AnimState:SetSymbolLightOverride("wire_blue", 0.1)
		else
			inst.AnimState:SetSymbolLightOverride("plug", 0.1)
		end
		for i = 1, 3 do
			local count = 0
			for j = math.max(1, i - 1), math.min(3, i + 1) do
				if inst._gemsymfollowers[j] then
					count = count + 1
				end
			end
			inst.AnimState:SetSymbolLightOverride(GetGemSymbol(i), 0.1 * count)
		end
		if inst.SoundEmitter:PlayingSound("loop") and not inst.SoundEmitter:PlayingSound("pb_loop") then
			inst.SoundEmitter:PlaySound("meta4/winona_battery/purebrillance_powered", "pb_loop")
		end
	else
		inst.AnimState:Hide("PB_ENERGY")
		inst.AnimState:SetSymbolLightOverride("rack", 0)
		inst.AnimState:SetSymbolLightOverride("rack_frame_back", 0)
		inst.AnimState:SetSymbolLightOverride("rack_base", 0)
		if inst.components.inventoryitem then
			inst.AnimState:SetSymbolLightOverride("plug_off", 0)
			inst.AnimState:SetSymbolLightOverride("wire_red", 0)
			inst.AnimState:SetSymbolLightOverride("wire_blue", 0)
		else
			inst.AnimState:SetSymbolLightOverride("plug", 0)
		end
		for i = 1, 3 do
			inst.AnimState:SetSymbolLightOverride("gem"..tostring(i), 0)
		end
		inst.SoundEmitter:KillSound("pb_loop")
	end
end

local BRILLIANCE_HUE = 0.3083
local BRILLIANCE_SAT = 0.65
local SHARD_HUE = 0.1833
local SHARD_SAT = 0.5

local function RefreshEnergyFX(inst)
	if inst._brilliance_level > 0 then
		inst.AnimState:SetSymbolHue("m2", BRILLIANCE_HUE)
		inst.AnimState:SetSymbolSaturation("m2", BRILLIANCE_SAT)
	elseif inst._shard_level > 0 then
		inst.AnimState:SetSymbolHue("m2", SHARD_HUE)
		inst.AnimState:SetSymbolSaturation("m2", SHARD_SAT)
	else
		inst.AnimState:SetSymbolHue("m2", 0)
		inst.AnimState:SetSymbolSaturation("m2", 1)
	end
	SetBrillianceEnergyEnabled(inst, inst._brilliance_level > 0)
end

local function OnUpdateShardLoad(inst)
	local t = inst.components.timer:GetTimeLeft("shardload") or 0
	local max = CalcOverloadThreshold(inst)
	local n = math.ceil((1 - t / max) * #inst._gems * NUM_LEVELS / 3)
	if n == 1 then
		inst.AnimState:ClearOverrideSymbol("m2")
	else
		inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m"..tostring(math.clamp(n + 1, 1, 7)))
	end
end

local function StartUpdatingShardLoad(inst)
	if not inst._updatingshardload then
		inst._updatingshardload = true
		inst.components.updatelooper:AddOnUpdateFn(OnUpdateShardLoad)
	end
end

local function StopUpdatingShardLoad(inst)
	if inst._updatingshardload then
		inst._updatingshardload = false
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateShardLoad)
	end
end

--used by item as well
local function SetGem(inst, slot, gemname, item)
	if inst._gemsymfollowers[slot] then
		inst._gemsymfollowers[slot]:Remove()
	end
	local symbol = GetGemSymbol(slot)
	if gemname == "purebrilliance" then
		local fx = SpawnPrefab("purebrilliance_symbol_fx")
		fx.entity:SetParent(inst.entity)
		fx.Follower:FollowSymbol(inst.GUID, symbol, 0, 0, 0, true)
		inst._gemsymfollowers[slot] = fx
		inst.AnimState:ClearOverrideSymbol(symbol)
		inst._brilliance_level = inst._brilliance_level + 1
	elseif gemname == "alterguardianhatshard" then
		local fx = SpawnPrefab("alterguardianhatshard_symbol_fx")
		fx.entity:SetParent(inst.entity)
		fx.Follower:FollowSymbol(inst.GUID, symbol, 0, 0, 0, true)
		if item then
			fx:SetupFxFromHatShard(item)
		end
		inst._gemsymfollowers[slot] = fx
		inst.AnimState:ClearOverrideSymbol(symbol)
		if inst._shard_level == 0 then
			inst.components.fueled.rate_modifiers:SetModifier(inst, 0, "shard")
		end
		inst._shard_level = inst._shard_level + 1
	else
		inst._gemsymfollowers[slot] = nil
		inst.AnimState:OverrideSymbol(symbol, "gems", "swap_"..gemname)
	end
end

local function UnsetGem(inst, slot, gemdata)
    local symbol = GetGemSymbol(slot)
    inst.AnimState:ClearOverrideSymbol(symbol)
	if inst._gemsymfollowers[slot] then
		inst._gemsymfollowers[slot]:Remove()
		inst._gemsymfollowers[slot] = nil
	end
	local gemname = type(gemdata) == "table" and gemdata.prefab or gemdata
	if gemname == "purebrilliance" then
		inst._brilliance_level = inst._brilliance_level - 1
	elseif gemname == "alterguardianhatshard" then
		inst._shard_level = inst._shard_level - 1
		if inst._shard_level <= 0 then
			inst.components.fueled.rate_modifiers:RemoveModifier(inst, "shard")
		end
	end
    if not POPULATING then
		if gemname == "alterguardianhatshard" then
			FlingGem(inst, gemdata, slot)
		elseif not POPULATING then
			LoseGem(inst, gemname, slot, symbol)
		end
    end
end

local function CheckElementalBattery(inst)
	return (inst._brilliance_level > 0 and "brilliance")
		or (inst._shard_level > 0 and "shard")
		or nil
end

--------------------------------------------------------------------------

local PERIOD = .5

local function DoAddBatteryPower(inst, node)
    node:AddBatteryPower(PERIOD + math.random(2, 6) * FRAMES)
end

local function OnBatteryTask(inst)
    inst.components.circuitnode:ForEachNode(DoAddBatteryPower)
end

local function StartBattery(inst)
    if inst._batterytask == nil then
        inst._batterytask = inst:DoPeriodicTask(PERIOD, OnBatteryTask, 0)
    end
end

local function StopBattery(inst)
    if inst._batterytask ~= nil then
        inst._batterytask:Cancel()
        inst._batterytask = nil
    end
end

local function UpdateCircuitPower(inst)
	if inst._circuittask then
		inst._circuittask:Cancel()
		inst._circuittask = nil
	end
    if inst.components.fueled ~= nil then
        if inst.components.fueled.consuming then
			local total_load = 0
            inst.components.circuitnode:ForEachNode(function(inst, node)
				local _load = 1
				if node.components.powerload then
					if inst._noidledrain and node.components.powerload:IsIdle() then
						return
					end
					_load = node.components.powerload:GetLoad()
					if _load <= 0 then
						return
					end
				end
                local batteries = 0
                node.components.circuitnode:ForEachNode(function(node, battery)
                    if battery.components.fueled ~= nil and battery.components.fueled.consuming then
                        batteries = batteries + 1
                    end
                end)
				total_load = total_load + _load / batteries
            end)
			inst.components.fueled.rate = inst._noidledrain and total_load or math.max(total_load, TUNING.WINONA_BATTERY_MIN_LOAD)
        else
            inst.components.fueled.rate = 0
        end
    end
end

local function OnCircuitChanged(inst)
    if inst._circuittask == nil then
        inst._circuittask = inst:DoTaskInTime(0, UpdateCircuitPower)
    end
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function BroadcastCircuitChanged(inst)
    --Notify other connected nodes, so that they can notify their connected batteries
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
    UpdateCircuitPower(inst)
end

local function OnConnectCircuit(inst)--, node)
    if inst.components.fueled ~= nil and inst.components.fueled.consuming then
        StartBattery(inst)
    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if not inst.components.circuitnode:IsConnected() then
        StopBattery(inst)
    end
    OnCircuitChanged(inst)
end

--------------------------------------------------------------------------

local BATTERY_COST = { fuel = TUNING.WINONA_BATTERY_LOW_MAX_FUEL_TIME * 0.9, shard = 1 }
local function CanBeUsedAsBattery(inst, user)
	if inst._shard_level > 0 then
		if not inst:IsOverloaded() then
			return true
		end
	elseif inst.components.fueled then
		local efficiency_mult
		if not (user and user:HasTag("handyperson")) and IsEngineerOnline(inst) then
			efficiency_mult = CalcEfficiencyMult(inst)
		else
			local skilltreeupdater = user and user.components.skilltreeupdater or nil
			local efficiency = skilltreeupdater and
				(	(skilltreeupdater:IsActivated("winona_battery_efficiency_3") and 3) or
					(skilltreeupdater:IsActivated("winona_battery_efficiency_2") and 2) or
					(skilltreeupdater:IsActivated("winona_battery_efficiency_1") and 1)
				) or 0
			efficiency_mult = CalcEfficiencyMult(inst, efficiency)
		end
		if inst.components.fueled.currentfuel >= BATTERY_COST.fuel * efficiency_mult then
			return true
		end
	end
	return false, "NOT_ENOUGH_CHARGE"
end

local function UseAsBattery(inst, user)
	if not (user and user:HasTag("handyperson")) and IsEngineerOnline(inst) then
		--original winona still online, don't de-level
	elseif ConfigureSkillTreeUpgrades(inst, user) then
		ApplyEfficiencyBonus(inst)
		UpdateCircuitPower(inst)
	end
	inst:ConsumeBatteryAmount(BATTERY_COST, 1, user)
end

--------------------------------------------------------------------------

local function UpdateSoundLoop(inst, level)
    if inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:SetParameter("loop", "intensity", 1 - level / NUM_LEVELS)
    end
end

local function StartSoundLoop(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/on_LP", "loop")
        UpdateSoundLoop(inst, inst.components.fueled:GetCurrentSection())
    end
	if inst._brilliance_level > 0 and not inst.SoundEmitter:PlayingSound("pb_loop") then
		inst.SoundEmitter:PlaySound("meta4/winona_battery/purebrillance_powered", "pb_loop")
	end
end

local function StopSoundLoop(inst)
    inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:KillSound("pb_loop")
end

local function StartOverloadedSoundLoop(inst)
	if not inst.SoundEmitter:PlayingSound("ol_loop") then
		inst.SoundEmitter:PlaySound("meta4/winona_battery/purebrillance_overloaded_lp", "ol_loop")
	end
end

local function StopOverloadedSoundLoop(inst)
	inst.SoundEmitter:KillSound("ol_loop")
end

local function OnEntitySleep(inst)
    StopSoundLoop(inst)
    StopIdleChargeSounds(inst)
	StopOverloadedSoundLoop(inst)
end

local function OnEntityWake(inst)
    if inst.components.fueled ~= nil and inst.components.fueled.consuming then
        StartSoundLoop(inst)
    end
    if inst.AnimState:IsCurrentAnimation("idle_charge") then
        StartIdleChargeSounds(inst)
    end
	if inst:IsOverloaded() then
		StartOverloadedSoundLoop(inst)
	end
end

--------------------------------------------------------------------------

local function CopyAllProperties(src, dest)
	for i, v in ipairs(src._gems) do
		table.insert(dest._gems, v)
		if type(v) == "table" then
			local gem = SpawnSaveRecord(v)
			SetGem(dest, #dest._gems, v.prefab, gem)
			gem:Remove()
		else
			SetGem(dest, #dest._gems, v)
		end
	end
end

local function ChangeToItem(inst)
	local item = SpawnPrefab("winona_battery_high_item")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	item.AnimState:PlayAnimation("collapse")
	item.AnimState:PushAnimation("idle_ground", false)
	item.SoundEmitter:PlaySound("meta4/winona_battery/battery_high_collapse")
	item.components.fueled:SetPercent(inst.components.fueled:GetPercent())
	CopyAllProperties(inst, item)
end

local function OnHitAnimOver(inst)
    inst:RemoveEventCallback("animover", OnHitAnimOver)
	if inst.AnimState:IsCurrentAnimation(inst._hitanim) then
        if inst.components.fueled:IsEmpty() then
            inst.AnimState:PlayAnimation("idle_empty")
            StopIdleChargeSounds(inst)
		elseif inst:IsOverloaded() then
			inst.AnimState:PlayAnimation("overload_idle", true)
			StopIdleChargeSounds(inst)
        else
            inst.AnimState:PlayAnimation("idle_charge", true)
            if not inst:IsAsleep() then
                StartIdleChargeSounds(inst)
            end
        end
    end
	inst._hitanim = nil
end

local function PlayHitAnim(inst, customanim)
    inst:RemoveEventCallback("animover", OnHitAnimOver)
    inst:ListenForEvent("animover", OnHitAnimOver)
	inst._hitanim = customanim or (inst:IsOverloaded() and "overload_hit") or "hit"
	inst.AnimState:PlayAnimation(inst._hitanim)
    StopIdleChargeSounds(inst)
end

local function OnWorked(inst)
    if not inst:HasTag("NOCLICK") then
        PlayHitAnim(inst)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
end

--V2C: this only called when we're about to remove inst
local function DropGems(inst)
	local numgems = #inst._gems
	if numgems > 0 then
		local noloss = (inst.components.fueled:GetCurrentSection() % 2) == 0
		for i = 1, numgems - 1 do
			local gemdata = table.remove(inst._gems, 1)
			if FlingGem(inst, gemdata, i).prefab == "alterguardianhatshard" then
				noloss = true
			end
		end
		local gemdata = table.remove(inst._gems)
		local gemname = type(gemdata) == "table" and gemdata.prefab or gemdata
		if noloss or gemname == "alterguardianhatshard" then
			FlingGem(inst, gemdata, numgems)
		elseif not POPULATING then
			LoseGem(inst, gemname, numgems, nil)
		end
	end
	inst._shard_level = 0
	inst._brilliance_level = 0
end

local function OnWorkFinished(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    DropGems(inst)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function OnWorkedBurnt(inst)
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    StopSoundLoop(inst)
	DropGems(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
    if inst.components.fueled ~= nil then
        inst:RemoveComponent("fueled")
    end
	inst.components.timer:StopTimer("overloaded")
	inst.components.timer:StopTimer("shardload")
	StopUpdatingShardLoad(inst)
	StopIdleChargeSounds(inst)
	StopOverloadedSoundLoop(inst)
	inst:RemoveComponent("portablestructure")
    inst.components.workable:SetOnWorkCallback(nil)
	inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)
    inst:RemoveTag("NOCLICK")
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
end

local function OnDismantle(inst)--, doer)
	--DropGems(inst)
	ChangeToItem(inst)
	inst:Remove()
end

--------------------------------------------------------------------------

local function GetStatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        return "BURNING"
	elseif inst:IsOverloaded() then
		return "OVERLOADED"
    end
	local level = inst._shard_level <= 0 and inst.components.fueled and inst.components.fueled:GetCurrentSection() or nil
    return level ~= nil
        and (   (level <= 0 and "OFF") or
                (level <= 1 and "LOWPOWER")
            )
        or nil
end

--used by item as well
local function ShatterGems(inst, keepnumgems)
    local i = #inst._gems
    if i > keepnumgems then
        if i == GEMSLOTS then
            inst.components.trader:Enable()
        end
        while i > keepnumgems do
            UnsetGem(inst, i, table.remove(inst._gems))
            i = i - 1
        end
    end
end

local function SetOverloaded(inst, overloaded)
	if not overloaded then
		inst.components.timer:StopTimer("overloaded")
		local section = inst._shard_level > 0 and #inst._gems * NUM_LEVELS / 3 or inst.components.fueled:GetCurrentSection()
		if section > 0 then
			inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m"..tostring(math.clamp(section + 1, 1, 7)))
			inst.AnimState:SetSymbolLightOverride("m2", 0.2)
			inst.AnimState:SetSymbolBloom("m2")
			inst.AnimState:ClearOverrideSymbol("plug")
			StopOverloadedSoundLoop(inst)
			if not inst.components.fueled.consuming then
				inst.components.fueled:StartConsuming()
				BroadcastCircuitChanged(inst)
				if inst.components.circuitnode:IsConnected() then
					StartBattery(inst)
				end
				if not inst:IsAsleep() then
					StartSoundLoop(inst)
				end
			else
				--might have reached here via setting a gem to insta cancel overload
				BroadcastCircuitChanged(inst)
			end
			if not POPULATING then
				PlayHitAnim(inst, "overload_pst")
				inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
			else
				inst.AnimState:PlayAnimation("idle_charge", true)
				if not inst:IsAsleep() then
					StartIdleChargeSounds(inst)
				end
			end
		end
	else
		if not inst.components.timer:TimerExists("overloaded") then
			inst.components.timer:StartTimer("overloaded", TUNING.WINONA_BATTERY_HIGH_OVERLOAD_DURATION)
		end
		inst.components.fueled:StopConsuming()
		BroadcastCircuitChanged(inst)
		StopBattery(inst)
		StopSoundLoop(inst)
		inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m1")
		inst.AnimState:SetSymbolLightOverride("m2", 0)
		inst.AnimState:ClearSymbolBloom("m2")
		inst.AnimState:OverrideSymbol("plug", "winona_battery_high", "plug_off")
		if not POPULATING then
			PlayHitAnim(inst, "overload_pre")
			inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
			inst.SoundEmitter:PlaySound("meta4/winona_battery/purebrillance_overload")
		else
			inst.AnimState:PlayAnimation("overload_idle", true)
			StopIdleChargeSounds(inst)
		end
		if not inst:IsAsleep() then
			StartOverloadedSoundLoop(inst)
		end
	end
end

local function IsOverloaded(inst)
	return inst.components.timer:TimerExists("overloaded")
end

local function OnTimerDone(inst, data)
	if data then
		if data.name == "shardloaddelay" then
			inst.components.timer:ResumeTimer("shardload")
			StartUpdatingShardLoad(inst)
		elseif data.name == "shardload" then
			StopUpdatingShardLoad(inst)
			OnUpdateShardLoad(inst)
		elseif data.name == "overloaded" then
			SetOverloaded(inst, false)
			inst.components.timer:StartTimer("shardload", CalcOverloadThreshold(inst))
			StartUpdatingShardLoad(inst)
			OnUpdateShardLoad(inst)
		end
	end
end

local function OnFuelEmpty(inst)
    inst.components.fueled:StopConsuming()
    StopBattery(inst)
    StopSoundLoop(inst)
    inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m1")
	inst.AnimState:SetSymbolLightOverride("m2", 0)
	inst.AnimState:ClearSymbolBloom("m2")
    inst.AnimState:OverrideSymbol("plug", "winona_battery_high", "plug_off")
    if inst.AnimState:IsCurrentAnimation("idle_charge") then
        inst.AnimState:PlayAnimation("idle_empty")
        StopIdleChargeSounds(inst)
    end
    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
    end
    ShatterGems(inst, 0)
	RefreshEnergyFX(inst)
	BroadcastCircuitChanged(inst)
end

local function OnFuelSectionChange(new, old, inst)
	if inst._shard_level > 0 then
		OnUpdateShardLoad(inst)
	elseif new == 1 then
		inst.AnimState:ClearOverrideSymbol("m2")
	else
		inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m"..tostring(math.clamp(new + 1, 1, 7)))
	end
	inst.AnimState:SetSymbolLightOverride("m2", 0.2)
	inst.AnimState:SetSymbolBloom("m2")
    inst.AnimState:ClearOverrideSymbol("plug")
    UpdateSoundLoop(inst, new)
    if new > 0 then
		local hadbrilliance = inst._brilliance_level > 0
        ShatterGems(inst, math.ceil(new / LEVELS_PER_GEM))
		RefreshEnergyFX(inst)
		if hadbrilliance ~= (inst._brilliance_level > 0) then
			BroadcastCircuitChanged(inst)
		end
    end
end

local function ConsumeBatteryAmount(inst, cost, share, doer)
	if inst._shard_level > 0 then
		local amt = TUNING.WINONA_BATTERY_HIGH_OVERLOAD_THRESHOLD / NUM_LEVELS --cost of one bar
		amt = cost.shard * amt + 0.0001 --0.0001 to prevent bar flicker
		amt = amt * CalcShardRegenSpeedMult(inst) / (share or 1) * CalcEfficiencyMult(inst)
		local threshold = CalcOverloadThreshold(inst)
		local t = inst.components.timer:GetTimeLeft("shardload")
		if t then
			t = t + amt
			if t < threshold then
				inst.components.timer:PauseTimer("shardload")
				inst.components.timer:SetTimeLeft("shardload", t)
				StopUpdatingShardLoad(inst)
				OnUpdateShardLoad(inst)
			else
				t = nil
				inst.components.timer:StopTimer("shardload")
				StopUpdatingShardLoad(inst)
				SetOverloaded(inst, true)
			end
		elseif amt < threshold then
			t = amt
			inst.components.timer:StartTimer("shardload", t, true)
			StopUpdatingShardLoad(inst)
			OnUpdateShardLoad(inst)
		else
			SetOverloaded(inst, true)
		end

		inst.components.timer:StopTimer("shardloaddelay")
		if t then
			inst.components.timer:StartTimer("shardloaddelay", CalcShardRegenDelay(inst))
		end
	else
		inst.components.fueled:DoDelta(-cost.fuel / (share or 1) * CalcEfficiencyMult(inst), doer)
	end
end

local function OnSave(inst, data)
	--NOTE: even if burning, save our gems, so we can drop them on loading into burnt state
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") or nil
    data.gems = #inst._gems > 0 and inst._gems or nil

	if not data.burnt then
		--fueled component does not save max fuel! assumes prefabs initialize fuel
		data.initfuel = inst.components.fueled:IsFull() or nil

		--skilltree
		data.noidledrain = inst._noidledrain or nil
		data.efficiency = inst._efficiency > 0 and inst._efficiency or nil
		data.engineerid = inst._engineerid
	end
end

local function OnLoad(inst, data, ents)
    if data ~= nil then
		if data.initfuel then
			--fueled component does not save max fuel! assumes prefabs initialize fuel
			inst.components.fueled:InitializeFuelLevel(inst.components.fueled.maxfuel)
		end

        if data.gems ~= nil and #inst._gems < GEMSLOTS then
			local keepnumgems = math.ceil(inst.components.fueled:GetCurrentSection() / LEVELS_PER_GEM)
            for i, v in ipairs(data.gems) do
				if #inst._gems >= keepnumgems then
					break
				end
                table.insert(inst._gems, v)
				if type(v) == "table" then
					local gem = SpawnSaveRecord(v)
					SetGem(inst, #inst._gems, v.prefab, gem)
					gem:Remove()
				else
					SetGem(inst, #inst._gems, v)
				end
                if #inst._gems >= GEMSLOTS then
                    inst.components.trader:Disable()
                    break
                end
            end
			ShatterGems(inst, keepnumgems)
			RefreshEnergyFX(inst)
        end
        if data.burnt then
            inst.components.burnable.onburnt(inst)
		else
			--skilltree
			inst._noidledrain = data.noidledrain or false
			inst._efficiency = data.efficiency or 0
			inst._engineerid = data.engineerid
			ApplyEfficiencyBonus(inst)

			if not inst.components.fueled:IsEmpty() then
				if inst:IsOverloaded() then
					SetOverloaded(inst, true)
				else
					if not inst.components.fueled.consuming then
						inst.components.fueled:StartConsuming()
						BroadcastCircuitChanged(inst)
					end
					if inst._shard_level > 0 then
						if inst.components.timer:TimerExists("shardload") then
							StartUpdatingShardLoad(inst)
						end
						OnUpdateShardLoad(inst)
					end
					inst.AnimState:PlayAnimation("idle_charge", true)
					if not inst:IsAsleep() then
						StartSoundLoop(inst)
						StartIdleChargeSounds(inst)
					end
				end
				inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
			end
        end
    end
end

local function OnInit(inst)
    inst._inittask = nil
	inst.components.circuitnode:ConnectTo("engineeringbatterypowered")
end

local function OnLoadPostPass(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        OnInit(inst)
    end
end

--------------------------------------------------------------------------

local function OnBuilt3(inst)
    inst:RemoveEventCallback("animover", OnBuilt3)
	for i = 3, 7 do
		local sym = "m"..tostring(i)
		inst.AnimState:ClearOverrideSymbol(sym)
		inst.AnimState:SetSymbolLightOverride(sym, 0)
		inst.AnimState:ClearSymbolBloom(sym)
		inst.AnimState:SetSymbolHue(sym, 0)
		inst.AnimState:SetSymbolSaturation(sym, 1)
	end
	local section = inst._shard_level > 0 and #inst._gems * NUM_LEVELS / 3 or inst.components.fueled:GetCurrentSection()
	if section <= 0 then
		inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m1")
	elseif section == 1 then
		inst.AnimState:ClearOverrideSymbol("m2")
	else
		inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m"..tostring(math.min(7, section + 1)))
	end
	if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
		if #inst._gems < GEMSLOTS then
			inst.components.trader:Enable()
		end
		if inst.components.fueled:IsEmpty() then
			inst.AnimState:PlayAnimation("idle_empty")
		else
			inst.AnimState:PlayAnimation("idle_charge", true)
			if not inst.components.fueled.consuming then
				inst.components.fueled:StartConsuming()
				BroadcastCircuitChanged(inst)
			end
			if inst.components.circuitnode:IsConnected() then
				StartBattery(inst)
			end
			if not inst:IsAsleep() then
				StartSoundLoop(inst)
				StartIdleChargeSounds(inst)
			end
		end
        inst:RemoveTag("NOCLICK")
    end
end

local function OnBuilt2(inst)
	if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
		inst.components.circuitnode:ConnectTo("engineeringbatterypowered")
    end
end

local function DoBuiltOrDeployed(inst, doer, anim, sound, connectframe)
	ConfigureSkillTreeUpgrades(inst, doer)
	ApplyEfficiencyBonus(inst)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst:ListenForEvent("animover", OnBuilt3)
	inst.AnimState:PlayAnimation(anim)
	inst.SoundEmitter:PlaySound(sound)
    inst:AddTag("NOCLICK")
    inst.components.trader:Disable()
	inst.components.fueled:StopConsuming()
	BroadcastCircuitChanged(inst)
	StopIdleChargeSounds(inst)
	inst:DoTaskInTime(connectframe * FRAMES, OnBuilt2)
end

local function OnBuilt(inst, data)
	DoBuiltOrDeployed(inst, data and data.builder or nil, "place", "dontstarve/common/together/battery/place_2", 60)
end

local function OnDeployed(inst, deployer)
	local section = inst._shard_level > 0 and #inst._gems * NUM_LEVELS / 3 or inst.components.fueled:GetCurrentSection()
	local maxsymbol = "m"..tostring(section + 1)
	inst.AnimState:ClearOverrideSymbol("m2")
	for i = section + 2, 7 do
		inst.AnimState:OverrideSymbol("m"..tostring(i), "winona_battery_high", maxsymbol)
	end
	if section > 0 then
		local hue, sat
		if inst._brilliance_level > 0 then
			hue, sat = BRILLIANCE_HUE, BRILLIANCE_SAT
		elseif inst._shard_level > 0 then
			hue, sat = SHARD_HUE, SHARD_SAT
		else
			hue, sat = 0, 1
		end
		for i = 3, 7 do
			local sym = "m"..tostring(i)
			inst.AnimState:SetSymbolLightOverride(sym, 0.2)
			inst.AnimState:SetSymbolBloom(sym)
			inst.AnimState:SetSymbolHue(sym, hue)
			inst.AnimState:SetSymbolSaturation(sym, sat)
		end
	end
	DoBuiltOrDeployed(inst, deployer, "deploy", "meta4/winona_battery/battery_high_deploy", 22)
end

--------------------------------------------------------------------------

local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	else
		local footprint = helperinst.placerinst.engineering_footprint_override or TUNING.WINONA_ENGINEERING_FOOTPRINT
		local range = TUNING.WINONA_BATTERY_RANGE - footprint
		local hx, hy, hz = helperinst.Transform:GetWorldPosition()
		local px, py, pz = helperinst.placerinst.Transform:GetWorldPosition()
		--<= match circuitnode FindEntities range tests
		if distsq(hx, hz, px, pz) <= range * range and TheWorld.Map:GetPlatformAtPoint(hx, hz) == TheWorld.Map:GetPlatformAtPoint(px, pz) then
            helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
        else
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.AnimState:SetBank("winona_battery_placement")
            inst.helper.AnimState:SetBuild("winona_battery_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

            inst.helper.entity:SetParent(inst.entity)

			if placerinst and
				placerinst.prefab ~= "winona_battery_low_item_placer" and
				placerinst.prefab ~= "winona_battery_high_item_placer" and
				recipename ~= "winona_battery_low" and
				recipename ~= "winona_battery_high"
			then
                inst.helper:AddComponent("updatelooper")
                inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                inst.helper.placerinst = placerinst
                OnUpdatePlacerHelper(inst.helper)
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnStartHelper(inst)--, recipename, placerinst)
	if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
		inst.components.deployhelper:StopHelper()
	end
end

--------------------------------------------------------------------------

local function ItemTradeTest(inst, item, doer)
    if item == nil then
        return false
	elseif item.prefab == "purebrilliance" then
		if doer and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("winona_lunar_2") then
			return true
		end
		return false, "NOGENERATORSKILL"
	elseif item.prefab == "alterguardianhatshard" then
		if doer and doer.components.skilltreeupdater and doer.components.skilltreeupdater:IsActivated("winona_lunar_1") then
			return true
		end
		return false, "NOGENERATORSKILL"
    elseif string.sub(item.prefab, -3) ~= "gem" then
        return false, "NOTGEM"
    elseif string.sub(item.prefab, -11, -4) == "precious" then
        return false, "WRONGGEM"
    end
    return true
end

local function OnGemGiven(inst, doer, item)
	local dirty
	if not (doer and doer:HasTag("handyperson")) and IsEngineerOnline(inst) then
		--original winona still online, don't de-level
		dirty = false
	else
		dirty = ConfigureSkillTreeUpgrades(inst, doer)
		if dirty then
			ApplyEfficiencyBonus(inst)
		end
	end

    if #inst._gems < GEMSLOTS then
		if item.prefab == "alterguardianhatshard" then
			local data, refs = item:GetSaveRecord()
			table.insert(inst._gems, data)
		else
			table.insert(inst._gems, item.prefab)
		end
        SetGem(inst, #inst._gems, item.prefab, item)
		RefreshEnergyFX(inst)
        if #inst._gems >= GEMSLOTS then
            inst.components.trader:Disable()
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
		inst.components.timer:StopTimer("shardloaddelay")
		inst.components.timer:StopTimer("shardload")
    end

	local curamt = inst.components.fueled.currentfuel
	local newamt = inst.components.fueled.maxfuel
	if #inst._gems < GEMSLOTS then
		newamt = newamt * #inst._gems / GEMSLOTS - 0.000001
		--prevent battery level flicker by subtracting a tiny bit from initial fuel
	end
	if newamt > curamt then
		inst.components.fueled:DoDelta(newamt - curamt)
	end

    if not inst.components.fueled.consuming then
        inst.components.fueled:StartConsuming()
        BroadcastCircuitChanged(inst)
        if inst.components.circuitnode:IsConnected() then
            StartBattery(inst)
        end
        if not inst:IsAsleep() then
            StartSoundLoop(inst)
        end
	elseif item.prefab == "purebrilliance" and inst._brilliance_level == 1 then
		BroadcastCircuitChanged(inst)
	elseif dirty then
		UpdateCircuitPower(inst) --since we didn't BroadcastCircuitChanged
    end

	item:Remove()

	if inst:IsOverloaded() then
		SetOverloaded(inst, false)
	else
		PlayHitAnim(inst)
		inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
	end
end

local function OnUsedIndirectly(inst, doer)
	if doer and doer.userid == inst._engineerid then
		if doer:HasTag("engineerid") then
			--skip if this is already mine and I'm still an engineer (didn't swap chars)
			return
		end
	elseif IsEngineerOnline(inst) then
		--skip if engineer is still online
		return
	end
	if ConfigureSkillTreeUpgrades(inst, doer) then
		ApplyEfficiencyBonus(inst)
		UpdateCircuitPower(inst)
	end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(0.8)
	MakeObstaclePhysics(inst, inst.physicsradiusoverride)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2)

    inst:AddTag("structure")
	inst:AddTag("engineering")
    inst:AddTag("engineeringbattery")
    inst:AddTag("gemsocket")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.AnimState:SetBank("winona_battery_high")
    inst.AnimState:SetBuild("winona_battery_high")
    inst.AnimState:PlayAnimation("idle_empty")
    inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m1")
    inst.AnimState:OverrideSymbol("plug", "winona_battery_high", "plug_off")
	inst.AnimState:SetSymbolLightOverride("electric_fx", 0.3)
	inst.AnimState:SetSymbolLightOverride("sprk_1", 0.3)
	inst.AnimState:SetSymbolLightOverride("sprk_2", 0.3)
	inst.AnimState:SetSymbolLightOverride("pb_energy_loop", 0.5)
	inst.AnimState:SetSymbolBloom("pb_energy_loop")
	--for overloaded
	inst.AnimState:SetSymbolLightOverride("panel_glow_outer", 0.2)
	inst.AnimState:SetSymbolBloom("panel_glow_other")
	inst.AnimState:SetSymbolLightOverride("panel_edge", 0.2)
	inst.AnimState:SetSymbolBloom("panel_edge")
	--
	inst.AnimState:Hide("PB_ENERGY")

    inst.MiniMapEntity:SetIcon("winona_battery_high.png")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
		inst.components.deployhelper:AddKeyFilter("winona_battery_engineering")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
		inst.components.deployhelper.onstarthelper = OnStartHelper
    end

    inst.scrapbook_anim = "idle_empty"
    inst.scrapbook_specialinfo = "WINONABATTERYHIGH"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("updatelooper")

	inst:AddComponent("portablestructure")
	inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
	inst.components.trader.deleteitemonaccept = false
    inst.components.trader.onaccept = OnGemGiven

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetSections(NUM_LEVELS)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
    inst.components.fueled.maxfuel = TUNING.WINONA_BATTERY_HIGH_MAX_FUEL_TIME
    inst.components.fueled.fueltype = FUELTYPE.MAGIC

	inst:AddComponent("timer")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
	inst.components.circuitnode:SetFootprint(TUNING.WINONA_ENGINEERING_FOOTPRINT)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false
	inst.components.circuitnode.rangeincludesfootprint = true

    inst:AddComponent("battery")
    inst.components.battery.canbeused = CanBeUsedAsBattery
    inst.components.battery.onused = UseAsBattery

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("ondeconstructstructure", DropGems)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
	inst:ListenForEvent("timerdone", OnTimerDone)
	inst:ListenForEvent("winona_batteryskillchanged", function(world, user)
		if user.userid == inst._engineerid and not inst:HasTag("burnt") then
			if ConfigureSkillTreeUpgrades(inst, user) then
				ApplyEfficiencyBonus(inst)
				UpdateCircuitPower(inst)
			end
		end
	end, TheWorld)

    MakeHauntableWork(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.burnable.ignorefuel = true --igniting/extinguishing should not start/stop fuel consumption

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
	inst.CheckElementalBattery = CheckElementalBattery
	inst.ConsumeBatteryAmount = ConsumeBatteryAmount
	inst.IsOverloaded = IsOverloaded
	inst.OnUsedIndirectly = OnUsedIndirectly

	--skilltree
	inst._noidledrain = false
	inst._efficiency = 0
	inst._engineerid = nil

    inst._gems = {}
	inst._gemsymfollowers = {}
	inst._shard_level = 0
	inst._brilliance_level = 0
    inst._batterytask = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)
    UpdateCircuitPower(inst)

    return inst
end

--------------------------------------------------------------------------

local function placer_postinit_fn(inst)
    --Show the battery placer on top of the battery range ground placer

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    placer2.AnimState:SetBank("winona_battery_high")
    placer2.AnimState:SetBuild("winona_battery_high")
    placer2.AnimState:PlayAnimation("idle_placer")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

	inst.deployhelper_key = "winona_battery_engineering"
end

--------------------------------------------------------------------------

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gems")
    inst.AnimState:SetBuild("gems")
    inst.AnimState:PlayAnimation("redgem_shatter")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

--------------------------------------------------------------------------

local function OnDeploy(inst, pt, deployer)
	local obj = SpawnPrefab("winona_battery_high")
	if obj then
		obj.Physics:SetCollides(false)
		obj.Physics:Teleport(pt.x, 0, pt.z)
		obj.Physics:SetCollides(true)
		obj.components.fueled:SetPercent(inst.components.fueled:GetPercent())
		CopyAllProperties(inst, obj)
		RefreshEnergyFX(obj)
		OnDeployed(obj, deployer)
		PreventCharacterCollisionsWithPlacedObjects(obj)
	end
	inst:Remove()
end

local function Item_OnSave(inst, data)
	data.gems = #inst._gems > 0 and inst._gems or nil

	--fueled component does not save max fuel! assumes prefabs initialize fuel
	data.initfuel = inst.components.fueled:IsFull() or nil
end

local function Item_OnLoad(inst, data, ents)
	if data then
		if data.initfuel then
			--fueled component does not save max fuel! assumes prefabs initialize fuel
			inst.components.fueled:InitializeFuelLevel(inst.components.fueled.maxfuel)
		end

		if data.gems and #inst._gems < GEMSLOTS then
			local keepnumgems = math.ceil(inst.components.fueled:GetCurrentSection() / LEVELS_PER_GEM)
			for i, v in ipairs(data.gems) do
				if #inst._gems >= keepnumgems then
					break
				end
				table.insert(inst._gems, v)
				if type(v) == "table" then
					local gem = SpawnSaveRecord(v)
					SetGem(inst, #inst._gems, v.prefab, gem)
                    gem:Remove()
				else
					SetGem(inst, #inst._gems, v)
				end
			end
			ShatterGems(inst, keepnumgems)
		end
	end
end

local function itemfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("winona_battery_high")
	inst.AnimState:SetBuild("winona_battery_high")
	inst.AnimState:PlayAnimation("idle_ground")
	inst.scrapbook_anim = "idle_ground"

	inst:AddTag("portableitem")

	MakeInventoryFloatable(inst, "large", 0.5, { 0.9, 1.1, 1 })

	inst:SetPrefabNameOverride("winona_battery_high")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst:AddComponent("lootdropper")

	inst:AddComponent("fueled")
	inst.components.fueled:SetSections(NUM_LEVELS)
	inst.components.fueled.maxfuel = TUNING.WINONA_BATTERY_HIGH_MAX_FUEL_TIME
	inst.components.fueled.fueltype = FUELTYPE.MAGIC

	inst:AddComponent("deployable")
	inst.components.deployable.restrictedtag = "handyperson"
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HUANT_TINY)

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)

	inst:ListenForEvent("ondeconstructstructure", DropGems)

	inst._gems = {}
	inst._gemsymfollowers = {}
	inst._shard_level = 0
	inst._brilliance_level = 0

	inst.OnSave = Item_OnSave
	inst.OnLoad = Item_OnLoad

	return inst
end

--------------------------------------------------------------------------

return Prefab("winona_battery_high", fn, assets, prefabs),
	MakePlacer("winona_battery_high_item_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn),
	Prefab("winona_battery_high_shatterfx", fxfn, assets_fx),
	Prefab("winona_battery_high_item", itemfn, assets_item, prefabs_item)
