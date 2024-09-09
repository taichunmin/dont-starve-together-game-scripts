local function OnNameDirty(inst)
	if ThePlayer and ThePlayer.components.spellbookcooldowns then
		ThePlayer.components.spellbookcooldowns:RegisterSpellbookCooldown(inst)
	end
end

local function GetSpellName(inst)
	return inst._name:value()
end

local function GetLength(inst)
	return inst._len:value() / 10
end

local function GetPercent(inst)
	return inst.pct
end

local SYNC_INTERVAL = 1

local function SetPercent(inst, percent, overtime)
	if percent <= 0 then
		if TheWorld.ismastersim then
			inst:Remove()
		else
			inst.pct = 0
			inst._pct:set(0)
		end
	elseif percent >= 1 then
		inst.pct = 1
		inst._pct:set(180)
		if inst.syncdelay then
			inst.syncdelay = SYNC_INTERVAL
		end
	else
		inst.pct = percent
		if overtime then
			inst._pct:set_local(math.max(1, math.ceil(percent * 180 - 0.5)))
		else
			inst._pct:set(math.max(1, math.ceil(percent * 180 - 0.5)))
			if inst.syncdelay then
				inst.syncdelay = SYNC_INTERVAL
			end
		end
	end
end

local function OnPctDirty(inst)
	inst.pct = inst._pct:value() / 180
end

local function OnWallUpdate(inst, dt)
	if inst.pct > 0 then
		if inst._len:value() <= 0 then
			SetPercent(inst, 0)
		else
			if inst.syncdelay then
				inst.syncdelay = math.max(0, inst.syncdelay - dt)
			end
			SetPercent(inst, math.max(0, inst.pct - dt / (inst._len:value() / 10)), inst.syncdelay == 0)
		end
	end
end

local function InitSpellCooldown(inst, spellname, duration)
	inst._name:set(spellname)
	inst._len:set(math.clamp(math.floor(duration * 10 + 0.5), 0, 65535))
end

local function RestartSpellCooldown(inst, duration)
	inst._len:set(math.clamp(math.floor(duration * 10 + 0.5), 0, 65535))
	SetPercent(inst, 1)
end

local function fn()
	local inst = CreateEntity()

	if TheWorld.ismastersim then
		inst.entity:AddTransform() --So we can follow parent's sleep state
	end
	inst.entity:AddNetwork()
	inst.entity:Hide()
	inst:AddTag("CLASSIFIED")

	--Variables for tracking local preview state
	--Whenever a server sync is received, all local dirty states are reverted
	inst.pct = 1

	--Network variables
	inst._name = net_hash(inst.GUID, "spellbookcooldown._name", "namedirty")
	inst._pct = net_byte(inst.GUID, "spellbookcooldown._pct", "pctdirty")
	inst._len = net_ushortint(inst.GUID, "spellbookcooldown._len")

	inst._pct:set(180)

	--Common interface
	inst.GetSpellName = GetSpellName
	inst.GetLength = GetLength
	inst.GetPercent = GetPercent

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnWallUpdateFn(OnWallUpdate)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst:ListenForEvent("namedirty", OnNameDirty)
		inst:ListenForEvent("pctdirty", OnPctDirty)

		return inst
	end

	inst.syncdelay = SYNC_INTERVAL

	--Server interface
	inst.InitSpellCooldown = InitSpellCooldown
	inst.RestartSpellCooldown = RestartSpellCooldown
	inst.LongUpdate = OnWallUpdate

	inst.persists = false

	return inst
end

return Prefab("spellbookcooldown", fn)
