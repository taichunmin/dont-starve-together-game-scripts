require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/winona_battery_low.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local assets_item =
{
	Asset("ANIM", "anim/winona_battery_low.zip"),
}

local prefabs =
{
    "collapse_small",
	"winona_battery_low_item",
}

local prefabs_item =
{
	"winona_battery_low",
}

--------------------------------------------------------------------------

local function CalcFuelRateRescale(inst)
	return (inst._horror_level > 0 or inst._nightmare_level > 0)
		and TUNING.WINONA_BATTERY_LOW_SHADOW_FUEL_RATE_MULT
		or TUNING.WINONA_BATTERY_LOW_FUEL_RATE_MULT
end

local function CalcEfficiencyMult(inst)
	return TUNING.SKILLS.WINONA.BATTERY_EFFICIENCY_RATE_MULT[inst._efficiency] or 1
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

local BATTERY_COST = TUNING.WINONA_BATTERY_LOW_MAX_FUEL_TIME * 0.9
local function CanBeUsedAsBattery(inst, user)
	if inst.components.fueled then
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

		local actual_fuel =
			(inst._horror_level + inst._nightmare_level) / TUNING.WINONA_BATTERY_LOW_SHADOW_FUEL_RATE_MULT +
			inst._chemical_level / TUNING.WINONA_BATTERY_LOW_FUEL_RATE_MULT

		if actual_fuel >= BATTERY_COST / TUNING.WINONA_BATTERY_LOW_FUEL_RATE_MULT * efficiency_mult then
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
	inst:ConsumeBatteryAmount({ fuel = BATTERY_COST / TUNING.WINONA_BATTERY_LOW_FUEL_RATE_MULT }, 1, user)
end

--------------------------------------------------------------------------

local NUM_LEVELS = 6

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
	if inst._horror_level > 0 and not inst.SoundEmitter:PlayingSound("nm_loop") then
		inst.SoundEmitter:PlaySound("meta4/winona_battery/nightmarefuel_powered", "nm_loop")
	end
end

local function StopSoundLoop(inst)
    inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:KillSound("nm_loop")
end

local function OnEntityWake(inst)
    if inst.components.fueled ~= nil and inst.components.fueled.consuming then
        StartSoundLoop(inst)
    end
end

local function RefreshFuelTypeEffects(inst)
	local section = inst.components.fueled:GetCurrentSection()
	local horror_sections, nightmare_sections
	if inst._horror_level > 0 then
		inst.AnimState:Hide("CHEMICAL")
		inst.AnimState:Show("HORROR")
		horror_sections = math.min(math.ceil(inst._horror_level / inst.components.fueled.maxfuel * NUM_LEVELS), section)
		if inst.SoundEmitter:PlayingSound("loop") and not inst.SoundEmitter:PlayingSound("nm_loop") then
			inst.SoundEmitter:PlaySound("meta4/winona_battery/nightmarefuel_powered", "nm_loop")
		end
	else
		inst.AnimState:Hide("HORROR")
		inst.AnimState:Show("CHEMICAL")
		horror_sections = 0
		inst.SoundEmitter:KillSound("nm_loop")
	end
	if inst._nightmare_level > 0 then
		nightmare_sections = math.min(math.ceil(inst._nightmare_level / inst.components.fueled.maxfuel * NUM_LEVELS), section - horror_sections)
	else
		nightmare_sections = 0
	end
	for i = 1, section - horror_sections - nightmare_sections do
		inst.AnimState:SetSymbolMultColour("m"..tostring(i), 1, 1, 1, 1)
	end
	for i = section - horror_sections - nightmare_sections + 1, section - horror_sections do
		inst.AnimState:SetSymbolMultColour("m"..tostring(i), 1, 0.5, 0, 1)
	end
	for i = section - horror_sections + 1, section do
		inst.AnimState:SetSymbolMultColour("m"..tostring(i), 1, 0, 0, 1)
	end

	inst.components.fueled.rate_modifiers:SetModifier(inst, CalcFuelRateRescale(inst), "rescale")
end

local function ClearAllFuelLevels(inst)
	inst._chemical_level = 0
	inst._nightmare_level = 0
	inst._horror_level = 0
	RefreshFuelTypeEffects(inst)
end

--used by winona_battery_low_item prefab as well
local function AdjustLevelsByPriority(inst, hi, mid, low)
	local max = inst.components.fueled.currentfuel
	if inst[hi] >= max then
		inst[hi] = max
		inst[mid] = 0
		inst[low] = 0
	elseif inst[hi] + inst[mid] >= max then
		inst[mid] = max - inst[hi]
		inst[low] = 0
	elseif inst[hi] + inst[mid] + inst[low] >= max then
		inst[low] = max - inst[hi] - inst[mid]
	end
end

local function CopyAllProperties(src, dest)
	dest._chemical_level = src._chemical_level
	dest._nightmare_level = src._nightmare_level
	dest._horror_level = src._horror_level
end

local function CheckElementalBattery(inst)
	return (inst._horror_level > 0 and "horror")
		or (inst._nightmare_level > 0 and "nightmare")
		or nil
end

--------------------------------------------------------------------------

local function ChangeToItem(inst)
	local item = SpawnPrefab("winona_battery_low_item")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	item.AnimState:PlayAnimation("collapse")
	item.AnimState:PushAnimation("idle_ground", false)
	item.SoundEmitter:PlaySound("meta4/winona_battery/battery_low_collapse")
	item.components.fueled:SetPercent(inst.components.fueled:GetPercent())
	CopyAllProperties(inst, item)
end

local function OnHitAnimOver(inst)
    inst:RemoveEventCallback("animover", OnHitAnimOver)
    if inst.AnimState:IsCurrentAnimation("hit") then
        if inst.components.fueled:IsEmpty() then
            inst.AnimState:PlayAnimation("idle_empty")
        else
            inst.AnimState:PlayAnimation("idle_charge", true)
        end
    end
end

local function PlayHitAnim(inst)
    inst:RemoveEventCallback("animover", OnHitAnimOver)
    inst:ListenForEvent("animover", OnHitAnimOver)
    inst.AnimState:PlayAnimation("hit")
end

local function OnWorked(inst)
    if inst.components.fueled.accepting then
        PlayHitAnim(inst)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
end

local function OnWorkFinished(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
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
    if inst.components.fueled ~= nil then
		ClearAllFuelLevels(inst)
        inst:RemoveComponent("fueled")
    end
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
	ChangeToItem(inst)
	inst:Remove()
end

--------------------------------------------------------------------------

local function GetStatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        return "BURNING"
    end
    local level = inst.components.fueled ~= nil and inst.components.fueled:GetCurrentSection() or nil
    return level ~= nil
        and (   (level <= 0 and "OFF") or
                (level <= 1 and "LOWPOWER")
            )
        or nil
end

local function SetFuelEmpty(inst, silent)
	ClearAllFuelLevels(inst)

    if inst.components.fueled.accepting then
        inst.components.fueled:StopConsuming()
        BroadcastCircuitChanged(inst)
        StopBattery(inst)
        StopSoundLoop(inst)
		for i = 1, 6 do
			inst.AnimState:Hide("m"..tostring(i))
		end
		inst.AnimState:SetSymbolLightOverride("meter_bar", 0)
		inst.AnimState:ClearSymbolBloom("meter_bar")
        inst.AnimState:OverrideSymbol("plug", "winona_battery_low", "plug_off")
        if inst.AnimState:IsCurrentAnimation("idle_charge") then
            inst.AnimState:PlayAnimation("idle_empty")
        end
		if not silent then
            inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
        end
    end
end

local function OnFuelEmpty(inst)
	SetFuelEmpty(inst, false)
end

--used by item as well
local function CanAddFuelItem(inst, item, doer)
	return not (item and item.components.fuel and item.components.fuel.fueltype == FUELTYPE.NIGHTMARE)
		or (doer ~= nil and
			doer.components.skilltreeupdater ~= nil and
			doer.components.skilltreeupdater:IsActivated(item.prefab == "horrorfuel" and "winona_shadow_2" or "winona_shadow_1"))
end

--used by item as well
local function OnAddFuelAdjustLevels(inst, item, fuelvalue, doer)
	--normally, horror > nightmare > chem,
	--except the item we JUST added jumps to highest priority
	local max = inst.components.fueled.currentfuel
	if not (item.components.fuel and item.components.fuel.fueltype == FUELTYPE.NIGHTMARE) then
		inst._chemical_level = inst._chemical_level + fuelvalue
		AdjustLevelsByPriority(inst, "_chemical_level", "_horror_level", "_nightmare_level")
	elseif item.prefab == "horrorfuel" then
		inst._horror_level = inst._horror_level + fuelvalue
		AdjustLevelsByPriority(inst, "_horror_level", "_nightmare_level", "_chemical_level")
	else
		inst._nightmare_level = inst._nightmare_level + fuelvalue
		AdjustLevelsByPriority(inst, "_nightmare_level", "_horror_level", "_chemical_level")
	end
end

--V2C: this is newly supported callback, that happens earlier, just before the fuel item is destroyed
local function OnAddFuelItem(inst, item, fuelvalue, doer)
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

	local hadhorror = inst._horror_level > 0
	OnAddFuelAdjustLevels(inst, item, fuelvalue)
	RefreshFuelTypeEffects(inst)
	if hadhorror ~= (inst._horror_level > 0) then
		if inst.components.fueled.accepting and not inst.components.fueled:IsEmpty() then
			--don't broadcast now if we're gonna broadcast below in OnAddFuel again
			if inst.components.fueled.consuming then
				BroadcastCircuitChanged(inst)
			end
			dirty = false --BroadcastCircuitChanged here or below, so don't need to UpdateCircuitPower
		end
	end

	if dirty then
		UpdateCircuitPower(inst)
	end
end

local function OnAddFuel(inst)
    if inst.components.fueled.accepting and not inst.components.fueled:IsEmpty() then
        if not inst.components.fueled.consuming then
            inst.components.fueled:StartConsuming()
            BroadcastCircuitChanged(inst)
            if inst.components.circuitnode:IsConnected() then
                StartBattery(inst)
            end
            if not inst:IsAsleep() then
                StartSoundLoop(inst)
            end
        end
        PlayHitAnim(inst)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
    end
end

local function OnUpdateFueled(inst)
	local hadhorror = inst._horror_level > 0
	--reversed priority so we consume strongest fuel first
	AdjustLevelsByPriority(inst, "_chemical_level", "_nightmare_level", "_horror_level")
	RefreshFuelTypeEffects(inst)
	if hadhorror ~= (inst._horror_level > 0) then
		BroadcastCircuitChanged(inst)
	end
end

local function OnFuelSectionChange(new, old, inst)
    if inst.components.fueled.accepting then
		for i = 1, new do
			inst.AnimState:Show("m"..tostring(i))
		end
		for i = new + 1, 6 do
			inst.AnimState:Hide("m"..tostring(i))
		end
		inst.AnimState:SetSymbolLightOverride("meter_bar", 0.2)
		inst.AnimState:SetSymbolBloom("meter_bar")
        inst.AnimState:ClearOverrideSymbol("plug")
        UpdateSoundLoop(inst, new)
    end
end

local function ConsumeBatteryAmount(inst, cost, share, doer)
	local efficiency_mult = CalcEfficiencyMult(inst)
	local fuelrate_mult = CalcFuelRateRescale(inst)
	local amt = cost.fuel / (share or 1) * fuelrate_mult * efficiency_mult
	local shadow_levels = inst._horror_level + inst._nightmare_level
	if shadow_levels > 0 and amt > shadow_levels then
		inst.components.fueled:DoDelta(-shadow_levels, doer)
		inst._horror_level = 0
		inst._nightmare_level = 0
		inst._chemical_level = inst.components.fueled.currentfuel
		amt = (amt - shadow_levels) / fuelrate_mult * CalcFuelRateRescale(inst)
	end
	inst.components.fueled:DoDelta(-amt, doer)
	OnUpdateFueled(inst)
end

local function CalcFuelMultiplier(inst, fuel_obj)
	return fuel_obj.components.fuel.fueltype == FUELTYPE.NIGHTMARE and 0.5 or 1
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

local function OnSave(inst, data)
	if inst.components.burnable and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	else
		data.nightmare = inst._nightmare_level > 0 and inst._nightmare_level or nil
		data.horror = inst._horror_level > 0 and inst._horror_level or nil

		--skilltree
		data.noidledrain = inst._noidledrain or nil
		data.efficiency = inst._efficiency > 0 and inst._efficiency or nil
		data.engineerid = inst._engineerid
	end
end

local function OnLoad(inst, data, ents)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
		inst._noidledrain = data and data.noidledrain or false
		if inst.components.fueled:IsEmpty() then
			SetFuelEmpty(inst, true)
		else
			inst._nightmare_level = data and data.nightmare or 0
			inst._horror_level = data and data.horror or 0
			inst._chemical_level = inst.components.fueled.currentfuel
			AdjustLevelsByPriority(inst, "_horror_level", "_nightmare_level", "_chemical_level")
			RefreshFuelTypeEffects(inst)

			UpdateSoundLoop(inst, inst.components.fueled:GetCurrentSection())
			if inst.AnimState:IsCurrentAnimation("idle_charge") then
				inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
			end
		end

		--skilltree
		if data then
			inst._noidledrain = data.noidledrain or false
			inst._efficiency = data.efficiency or 0
			inst._engineerid = data.engineerid
			ApplyEfficiencyBonus(inst)
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
	if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
        inst:RemoveTag("NOCLICK")
        inst.components.fueled.accepting = true
        if inst.components.fueled:IsEmpty() then
			inst.AnimState:PlayAnimation("idle_empty")
			SetFuelEmpty(inst, true)
        else
            OnFuelSectionChange(inst.components.fueled:GetCurrentSection(), nil, inst)
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
            end
        end
    end
end

local function OnBuilt2(inst)
	if inst.AnimState:IsCurrentAnimation("deploy") or inst.AnimState:IsCurrentAnimation("place") then
        if inst.components.fueled:IsEmpty() then
            StopSoundLoop(inst)
        else
            if not inst.components.fueled.consuming then
                inst.components.fueled:StartConsuming()
                BroadcastCircuitChanged(inst)
            end
            if not inst:IsAsleep() then
                StartSoundLoop(inst)
            end
        end
		inst.components.circuitnode:ConnectTo("engineeringbatterypowered")
    end
end

local function OnBuilt1(inst, section)
	if inst.components.fueled:IsEmpty() or inst:IsAsleep() then
		return
	elseif inst.AnimState:IsCurrentAnimation("deploy") then
		if section > 0 then
			--NOTE: these sounds match section and not (section + 1)
			inst.SoundEmitter:PlaySound("meta4/winona_battery/battery_level_"..tostring(section).."_f19")
		end
		StartSoundLoop(inst)
	elseif inst.AnimState:IsCurrentAnimation("place") then
		inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
		StartSoundLoop(inst)
    end
end

local function DoBuiltOrDeployed(inst, doer, anim, sound, powerupframe, connectframe)
	ConfigureSkillTreeUpgrades(inst, doer)
	ApplyEfficiencyBonus(inst)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst:ListenForEvent("animover", OnBuilt3)
	inst.AnimState:PlayAnimation(anim)
    inst.AnimState:ClearAllOverrideSymbols()
	inst.SoundEmitter:PlaySound(sound)
    inst:AddTag("NOCLICK")
    inst.components.fueled.accepting = false
    inst.components.fueled:StopConsuming()
    BroadcastCircuitChanged(inst)
    StopSoundLoop(inst)

	local section = inst.components.fueled:GetCurrentSection()
	inst:DoTaskInTime(powerupframe * FRAMES, OnBuilt1, section)
	inst:DoTaskInTime(connectframe * FRAMES, OnBuilt2)

	if inst.components.fueled:IsEmpty() then
		inst.AnimState:OverrideSymbol("plug", "winona_battery_low", "plug_off")
		inst.AnimState:SetSymbolLightOverride("meter_bar", 0)
		inst.AnimState:ClearSymbolBloom("meter_bar")
	end
	if section < 6 then
		local maxsymbol = "m"..tostring(math.max(1, section + 1))
		for i = section + 1, 6 do
			inst.AnimState:Hide("m"..tostring(i))
		end
	end
end

local function OnBuilt(inst, data)
	DoBuiltOrDeployed(inst, data and data.builder or nil, "place", "dontstarve/common/together/battery/place", 60, 66)
end

local function OnDeployed(inst, item, deployer)
	inst.components.fueled:SetDepletedFn(nil)
	inst.components.fueled:SetSectionCallback(nil)
	inst.components.fueled:SetPercent(item.components.fueled:GetPercent())
	inst.components.fueled:SetDepletedFn(OnFuelEmpty)
	inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	CopyAllProperties(item, inst)
	RefreshFuelTypeEffects(inst)
	DoBuiltOrDeployed(inst, deployer, "deploy", "meta4/winona_battery/battery_low_deploy", 16, 22)
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(0.5)
	MakeObstaclePhysics(inst, inst.physicsradiusoverride)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2)

    inst:AddTag("structure")
	inst:AddTag("engineering")
    inst:AddTag("engineeringbattery")

    inst.AnimState:SetBank("winona_battery_low")
    inst.AnimState:SetBuild("winona_battery_low")
    inst.AnimState:PlayAnimation("idle_charge", true)
	for i = 1, 6 do
		local sym = "m"..tostring(i)
		inst.AnimState:SetSymbolLightOverride(sym, 0.2)
		inst.AnimState:SetSymbolBloom(sym)
	end
	inst.AnimState:SetSymbolLightOverride("meter_bar", 0.2)
	inst.AnimState:SetSymbolBloom("meter_bar")
	inst.AnimState:SetSymbolLightOverride("sprk_1", 0.3)
	inst.AnimState:SetSymbolLightOverride("sprk_2", 0.3)
	inst.AnimState:SetSymbolLightOverride("horror_fx", 1)
	inst.AnimState:Hide("HORROR")

    inst.MiniMapEntity:SetIcon("winona_battery_low.png")

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

    inst.scrapbook_anim = "idle_charge"
    inst.scrapbook_specialinfo = "WINONABATTERYLOW"
    inst.scrapbook_fueled_max = 36

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("portablestructure")
	inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
	inst.components.fueled:SetCanTakeFuelItemFn(CanAddFuelItem)
	inst.components.fueled:SetTakeFuelItemFn(OnAddFuelItem)
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
	inst.components.fueled:SetUpdateFn(OnUpdateFueled)
    inst.components.fueled:SetSections(NUM_LEVELS)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	inst.components.fueled:SetMultiplierFn(CalcFuelMultiplier)
    inst.components.fueled:InitializeFuelLevel(TUNING.WINONA_BATTERY_LOW_MAX_FUEL_TIME)
    inst.components.fueled.rate = TUNING.WINONA_BATTERY_MIN_LOAD
	inst.components.fueled.rate_modifiers:SetModifier(inst, TUNING.WINONA_BATTERY_LOW_FUEL_RATE_MULT, "rescale")
    inst.components.fueled.fueltype = FUELTYPE.CHEMICAL
	inst.components.fueled.secondaryfueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled.accepting = true
    inst.components.fueled:StartConsuming()

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
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)
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
    inst.OnEntitySleep = StopSoundLoop
    inst.OnEntityWake = OnEntityWake
	inst.CheckElementalBattery = CheckElementalBattery
	inst.ConsumeBatteryAmount = ConsumeBatteryAmount
	inst.OnUsedIndirectly = OnUsedIndirectly

	--skilltree
	inst._noidledrain = false
	inst._efficiency = 0
	inst._engineerid = nil

	inst._chemical_level = inst.components.fueled.currentfuel
	inst._nightmare_level = 0
	inst._horror_level = 0
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

    placer2.AnimState:SetBank("winona_battery_low")
    placer2.AnimState:SetBuild("winona_battery_low")
    placer2.AnimState:PlayAnimation("idle_placer")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

	inst.deployhelper_key = "winona_battery_engineering"
end

--------------------------------------------------------------------------

local function OnDeploy(inst, pt, deployer)
	local obj = SpawnPrefab("winona_battery_low")
	if obj then
		obj.Physics:SetCollides(false)
		obj.Physics:Teleport(pt.x, 0, pt.z)
		obj.Physics:SetCollides(true)
		OnDeployed(obj, inst, deployer)
		PreventCharacterCollisionsWithPlacedObjects(obj)
	end
	inst:Remove()
end

local function CLIENT_PlayFuelSound(inst)
	local parent = inst.entity:GetParent()
	local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
	if container ~= nil and container:IsOpenedBy(ThePlayer) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
	end
end

local function SERVER_PlayFuelSound(inst)
	if not inst.components.inventoryitem:IsHeld() then
		inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
	else
		inst.playfuelsound:push()
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			CLIENT_PlayFuelSound(inst)
		end
	end
end

local function Item_OnSave(inst, data)
	data.nightmare = inst._nightmare_level > 0 and inst._nightmare_level or nil
	data.horror = inst._horror_level > 0 and inst._horror_level or nil
end

local function Item_OnLoad(inst, data, ents)
	if data then
		inst._nightmare_level = data.nightmare or 0
		inst._horror_level = data.horror or 0
		inst._chemical_level = inst.components.fueled.currentfuel
		AdjustLevelsByPriority(inst, "_horror_level", "_nightmare_level", "_chemical_level")
	end
end

local function itemfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("winona_battery_low")
	inst.AnimState:SetBuild("winona_battery_low")
	inst.AnimState:PlayAnimation("idle_ground")
	inst.scrapbook_anim = "idle_ground"

	inst:AddTag("portableitem")

	MakeInventoryFloatable(inst, "large", 0.4, { 0.6, 0.95, 1 })

	inst.playfuelsound = net_event(inst.GUID, "winona_battery_low_item.playfuelsound")

	inst:SetPrefabNameOverride("winona_battery_low")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("deployable")
	inst.components.deployable.restrictedtag = "handyperson"
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

	inst:AddComponent("fueled")
	inst.components.fueled:SetCanTakeFuelItemFn(CanAddFuelItem)
	inst.components.fueled:InitializeFuelLevel(TUNING.WINONA_BATTERY_LOW_MAX_FUEL_TIME)
	inst.components.fueled:SetMultiplierFn(CalcFuelMultiplier)
	inst.components.fueled:SetTakeFuelItemFn(OnAddFuelAdjustLevels)
	inst.components.fueled:SetTakeFuelFn(SERVER_PlayFuelSound)
	inst.components.fueled.fueltype = FUELTYPE.CHEMICAL
	inst.components.fueled.secondaryfueltype = FUELTYPE.NIGHTMARE
	inst.components.fueled.accepting = true

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HUANT_TINY)

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)

	inst._chemical_level = inst.components.fueled.currentfuel
	inst._nightmare_level = 0
	inst._horror_level = 0

	inst.OnSave = Item_OnSave
	inst.OnLoad = Item_OnLoad

	return inst
end

--------------------------------------------------------------------------

return Prefab("winona_battery_low", fn, assets, prefabs),
	MakePlacer("winona_battery_low_item_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn),
	Prefab("winona_battery_low_item", itemfn, assets_item)
