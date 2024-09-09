local assets1 =
{
    Asset("ANIM", "anim/inspectaclesbox.zip"),
}

local assets2 =
{
	Asset("ANIM", "anim/inspectaclesbox.zip"),
	Asset("ANIM", "anim/inspectaclesbox2_build.zip"),
}

SetSharedLootTable("inspectaclesbox", {
    {"winona_machineparts_1", 1.0},
    {"winona_machineparts_1", 0.5},
    {"winona_recipescanner", 1.0},
    {"wagpunk_bits", 0.75},
    {"wagpunk_bits", 0.5},
    {"transistor", 0.75},
    {"transistor", 0.5},
})
SetSharedLootTable("inspectaclesbox2", {
    {"winona_machineparts_2", 1.0},
    {"winona_machineparts_2", 0.5},
    {"wagpunk_bits", 1.0},
    {"wagpunk_bits", 0.75},
    {"transistor", 1.0},
    {"transistor", 0.75},
})

local prefabs1 =
{
    -- Chance Loot.
	"winona_machineparts_1",
    "wagpunk_bits",
    "transistor",
    -- Setup Loot.
	"winona_recipescanner",
}

local prefabs2 =
{
    -- Chance Loot.
	"winona_machineparts_2",
	"wagpunk_bits",
	"transistor",
    -- Setup Loot.
	"winona_holotelepad",
	"winona_holotelebrella",
}

local function GetBiasedLoot(lootdropper, lookup, fallbacktorandomloot)
    local inst = lootdropper.inst
    local item = nil
    local owner = inst._inspectaclesowner
    if owner ~= inst then
        local builder = owner.components.builder
        if builder then
            local biasedloot = {}
            for _, v in ipairs(lookup) do
                if not builder:KnowsRecipe(v.recipename) then
                    table.insert(biasedloot, v.lootname)
                end
            end
            if biasedloot[1] then
                item = biasedloot[math.random(#biasedloot)]
            elseif fallbacktorandomloot then
                item = lootdropper:PickRandomLoot()
            elseif lookup[1] then
                item = lookup[math.random(#lookup)].lootname
            end
        end
    end
    if item then
        return {item}
    end
    return nil
end


local BiasedLoot = {
}
local function OnLootSetup(lootdropper)
    lootdropper.loot = GetBiasedLoot(lootdropper, BiasedLoot, false)
end

local BiasedLoot2 = {
    {recipename = "winona_teleport_pad_item", lootname = "winona_holotelepad",},
    {recipename = "winona_telebrella", lootname = "winona_holotelebrella",},
}
local function OnLootSetup2(lootdropper)
    lootdropper.loot = GetBiasedLoot(lootdropper, BiasedLoot2, true)
end

local LOOT_VERTICAL_OFFSET = 1.5 -- Vertical offset to make it appear out of the top better.

local ANIM_STATE =
{
	["idle_broken_loop"] = 0,
	["idle_fixed_loop"] = 1,
	["repair"] = 2,
	["open_pre"] = 3,
	["open_loop"] = 4,
	["open_pst"] = 5,
	["closed"] = 6,
}

local function CreateAnim(build)
	local inst = CreateEntity()

	inst:AddTag("NOBLOCK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("inspectaclesbox")
	inst.AnimState:SetBuild(build)
	inst.AnimState:PlayAnimation("idle_broken_loop", true)
	inst.AnimState:SetErosionParams(1, 20, -1) -- Default values for projectedeffects setup below.

	local projectedeffects = inst:AddComponent("projectedeffects")
	projectedeffects:SetDecayTime(0.5)
	projectedeffects:SetConstructTime(0.25)
	projectedeffects:SetCutoffHeight(-1)
	projectedeffects:SetIntensity(-1.0)
	projectedeffects:SetOnDecayCallback(inst.Remove)
    
    inst.SoundEmitter:PlaySound("meta4/wires_minigame/hologram_idle_lp", "hololoop")

	return inst
end

local function InitClientAnim(inst)
	if inst._anim == nil then
		inst._anim = CreateAnim(inst._ANIMBUILD)
		inst._anim.entity:SetParent(inst.entity)
		inst._anim.client_forward_target = inst --locally forward mouseover and controller interaction target to our classified parent
		inst.highlightchildren = { inst._anim }
	end
end

local function KillClientAnim(inst)
	if inst._anim then
        inst._anim.SoundEmitter:KillSound("hololoop")
		inst._anim:AddTag("FX")
		inst._anim:AddTag("NOCLICK")
		inst._anim.entity:SetCanSleep(false)
		inst._anim.entity:SetParent(nil)
		inst._anim.Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst._anim.components.projectedeffects:Decay()
		inst._anim.client_forward_target = nil
		inst._anim = nil
		inst.highlightchildren = nil
	end
end

local function OnAnimState_Client(inst)
	if inst._anim then
		if inst._animstate:value() == ANIM_STATE["idle_broken_loop"] then
			--spawned in broken
			inst._anim.AnimState:PlayAnimation("idle_broken_loop", true)
			inst._anim.components.projectedeffects:Construct()
		elseif inst._animstate:value() == ANIM_STATE["idle_fixed_loop"] then
			--spawned in repaired
			inst._anim.AnimState:PlayAnimation("idle_fixed_loop", true)
			inst._anim.components.projectedeffects:Construct()
			if not inst._anim.SoundEmitter:PlayingSound("fixed") then
                inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/machine_fixed_idle_LP", "fixed")
            end
		elseif inst._animstate:value() == ANIM_STATE["repair"] then
			--users repaired (will auto open for loot fling after)
			inst._anim.AnimState:PlayAnimation("repair")
			inst._anim.components.projectedeffects:MakeOpaque()
			inst._anim.components.projectedeffects:LockDecay(true)
            inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/machine_repair")
		elseif inst._animstate:value() == ANIM_STATE["open_pre"] then
			--open for loot fling
			inst._anim.AnimState:PlayAnimation("open_pre")
			inst._anim.AnimState:PushAnimation("open_loop")
			inst._anim.components.projectedeffects:MakeOpaque()
			inst._anim.components.projectedeffects:LockDecay(true)
			if not inst._anim.SoundEmitter:PlayingSound("fixed") then
                inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/machine_fixed_idle_LP", "fixed")
            end
			if not inst._anim.SoundEmitter:PlayingSound("chuffing") then
                inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/item_dispense_lp", "chuffing")
            end
		elseif inst._animstate:value() == ANIM_STATE["open_loop"] then
			--open for loot fling
			inst._anim.AnimState:PlayAnimation("open_loop", true)
			inst._anim.components.projectedeffects:MakeOpaque()
			inst._anim.components.projectedeffects:LockDecay(true)
			if not inst._anim.SoundEmitter:PlayingSound("fixed") then
                inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/machine_fixed_idle_LP", "fixed")
            end
			if not inst._anim.SoundEmitter:PlayingSound("chuffing") then
                inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/item_dispense_lp", "chuffing")
            end
		elseif inst._animstate:value() == ANIM_STATE["open_pst"] then
			--close and decay after loot fling
			inst._anim.AnimState:PlayAnimation("open_pst")
			inst._anim.AnimState:PushAnimation("idle_fixed_loop")
			inst._anim.components.projectedeffects:MakeOpaque()
			inst._anim.components.projectedeffects:SetDecayTime(1.5)
			inst._anim.components.projectedeffects:LockDecay(false)
			inst._anim.SoundEmitter:KillSound("fixed")
			inst._anim.SoundEmitter:KillSound("chuffing")
			KillClientAnim(inst)
		elseif inst._animstate:value() == ANIM_STATE["closed"] then
			--close and decay after loot fling
			inst._anim.AnimState:PlayAnimation("idle_fixed_loop", true)
			inst._anim.components.projectedeffects:MakeOpaque()
			inst._anim.components.projectedeffects:SetDecayTime(0.5)
			inst._anim.components.projectedeffects:LockDecay(false)
			inst._anim.SoundEmitter:KillSound("fixed")
			inst._anim.SoundEmitter:KillSound("chuffing")
			KillClientAnim(inst)
		end
	end
end

local function SetAnimState(inst, state, delay, cb)
	if (state == "open_loop" and inst._animstate:value() == ANIM_STATE["open_pre"]) or
		(state == "closed" and inst._animstate:value() == ANIM_STATE["open_pst"])
	then
		--client normally would've pushed these anims already
		inst._animstate:set_local(ANIM_STATE[state])
	else
		inst._animstate:set(ANIM_STATE[state])
		OnAnimState_Client(inst)
		if state == "open_pst" or state == "closed" then
			inst:AddTag("NOCLICK")
			inst:DoTaskInTime(0.5, inst.Remove)
		end
	end

	--NOTE: _animtask doesn't get cleared when task finishes, but that doesn't matter here
	if inst._animtask then
		inst._animtask:Cancel()
	end
	inst._animtask = cb and inst:DoTaskInTime(delay, cb) or nil
end

local function OnChuffSnd_Client(inst)
    if inst._anim then
        inst._anim.SoundEmitter:PlaySound("meta4/wires_minigame/item_dispense_pst")
    end
end

local function OnIsProjected_Client(inst)
	if inst._isprojected:value() then
		InitClientAnim(inst)
		OnAnimState_Client(inst)
	else
		KillClientAnim(inst)
	end
end

local function ToggleProjection(inst, enabled)
	if not enabled and
		(	inst._animstate:value() ~= ANIM_STATE["idle_broken_loop"] and
			inst._animstate:value() ~= ANIM_STATE["idle_fixed_loop"]
		)
	then
		--can no longer toggle off once the box is complete and loot sequence started
		return
	end

	if inst._isprojected:value() ~= enabled then
		inst._isprojected:set(enabled)

		if inst._inspectaclesowner.HUD then
			OnIsProjected_Client(inst)
		else
			KillClientAnim(inst)
		end

		if not enabled then
			inst:AddTag("NOCLICK")
			inst:DoTaskInTime(0.5, inst.Remove)
		end
	end
end

local function SetViewingOwner(inst, owner)
    local inspectaclesowner = owner or inst -- Only one target at a time or no targets at all but never all players (nil).
    inst.Network:SetClassifiedTarget(inspectaclesowner)

    if inst._inspectaclesvisionfn ~= nil then
        inst:RemoveEventCallback("inspectaclesvision", inst._inspectaclesvisionfn, inst._inspectaclesowner)
    end

	inst._inspectaclesowner = inspectaclesowner

    if inspectaclesowner ~= inst then
        inst._inspectaclesvisionfn = function(owner, data)
			ToggleProjection(inst, data.enabled or false)
        end
        inst:ListenForEvent("inspectaclesvision", inst._inspectaclesvisionfn, inspectaclesowner)
		ToggleProjection(inst, inspectaclesowner.components.playervision and inspectaclesowner.components.playervision:HasInspectaclesVision() or false)
	else
		ToggleProjection(inst, false)
    end
end

local function OnActivate(inst, doer)
    inst.components.activatable.inactive = true
    if doer.components.inventory then
        local items = doer.components.inventory:ReferenceAllItems()
        for _, item in ipairs(items) do
            if item:HasTag("inspectaclesvision") and item.components.equippable and item.components.equippable:IsEquipped() and item.components.useableitem then
                if item.components.useableitem:StartUsingItem() then
                    return true
                end
            end
        end
    end
    return false
end

local function DoLootPinata_OnClosed(inst)
	SetAnimState(inst, "closed")
end

local function DoLootPinata_DoFling(inst)
    local loot = inst._inspectaclesloots[inst._inspectacleslootsindex]

    if loot:IsValid() then
        loot:ReturnToScene()
        local pt = inst:GetPosition()
        pt.y = LOOT_VERTICAL_OFFSET
        inst.components.lootdropper:FlingItem(loot, pt)
        inst._chuffsnd:push()
        if inst._inspectaclesowner.HUD then
            OnChuffSnd_Client(inst)
        end
    end

    inst._inspectacleslootsindex = inst._inspectacleslootsindex + 1
    if inst._inspectacleslootsindex > inst._inspectacleslootscount then
        if inst._inspectaclesloottask ~= nil then
            inst._inspectaclesloottask:Cancel()
            inst._inspectaclesloottask = nil
        end
        inst._inspectaclesloots = nil
        inst._inspectacleslootscount = nil
        inst._inspectacleslootsindex = nil
		SetAnimState(inst, "open_pst", 24 * FRAMES, DoLootPinata_OnClosed)
    end
end

local function DoLootPinata3(inst)
	SetAnimState(inst, "open_loop")
	inst._inspectaclesloottask = inst:DoPeriodicTask(0.25, DoLootPinata_DoFling)
end

local function DoLootPinata2(inst)
	SetAnimState(inst, "open_pre", 24 * FRAMES, DoLootPinata3)
end

local function DoLootPinata(inst)
    if inst._inspectaclesloots ~= nil then
        return
    end
    -- NOTES(JBK): Create all of the loot now to make this save stateless but temporarily remove from scene for presentation.
    -- This includes setting the transform of the prefab at the box origin in case of save load cycles.
    local x, y, z = inst.Transform:GetWorldPosition()
    local loots = inst.components.lootdropper:GenerateLoot()
    local lootscount = #loots
    inst._inspectaclesloots = {}
    inst._inspectacleslootscount = lootscount
    inst._inspectacleslootsindex = 1
    for i = 1, lootscount do
        local loot = SpawnPrefab(loots[i])
        loot.Transform:SetPosition(x, y, z)
        loot:RemoveFromScene()
        if loot.SetItemClassifiedOwner and inst._inspectaclesowner ~= inst then
            loot:SetItemClassifiedOwner(inst._inspectaclesowner)
        end
        inst._inspectaclesloots[i] = loot
    end
	inst:RemoveComponent("activatable")
    if inst._repaired then
		DoLootPinata2(inst)
    else
		SetAnimState(inst, "repair", 37 * FRAMES, DoLootPinata2)
    end
end

local function SetRepaired(inst)
    inst._repaired = true
	SetAnimState(inst, "idle_fixed_loop")
end

local function OnInit_Client(inst)
	inst:ListenForEvent("inspectaclesbox._chuffsndevent", OnChuffSnd_Client)
end

local function commonfn(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("ignorewalkableplatforms")
	inst:AddTag("CLASSIFIED")

    inst._chuffsnd = net_event(inst.GUID, "inspectaclesbox._chuffsndevent")
	inst._isprojected = net_bool(inst.GUID, "inspectaclesbox._isprojected", "isprojecteddirty")
	inst._animstate = net_tinybyte(inst.GUID, "inspectaclesbox._animstate", "animstatedirty")
	inst._ANIMBUILD = build

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst:DoTaskInTime(0, OnInit_Client)
		inst:ListenForEvent("isprojecteddirty", OnIsProjected_Client)
		inst:ListenForEvent("animstatedirty", OnAnimState_Client)

        return inst
    end

    inst.SetViewingOwner = SetViewingOwner
    inst.DoLootPinata = DoLootPinata
    inst.SetRepaired = SetRepaired

    inst.Network:SetClassifiedTarget(inst)
    inst._inspectaclesowner = inst

	inst:AddComponent("inspectable")
	local lootdropper = inst:AddComponent("lootdropper")

    local activatable = inst:AddComponent("activatable")
    activatable.OnActivate = OnActivate
    activatable.quickaction = true

	inst.persists = false

    return inst
end

local function fn1()
	local inst = commonfn("inspectaclesbox")

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.lootdropper:SetChanceLootTable("inspectaclesbox")
    inst.components.lootdropper:SetLootSetupFn(OnLootSetup)

	return inst
end

local function fn2()
	local inst = commonfn("inspectaclesbox2_build")

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.lootdropper:SetChanceLootTable("inspectaclesbox2")
    inst.components.lootdropper:SetLootSetupFn(OnLootSetup2)

	return inst
end

return Prefab("inspectaclesbox", fn1, assets1, prefabs1),
	Prefab("inspectaclesbox2", fn2, assets2, prefabs2)
