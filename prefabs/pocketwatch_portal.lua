
local PocketWatchCommon = require "prefabs/pocketwatch_common"

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/pocketwatch_common.lua"),

    Asset("ANIM", "anim/pocketwatch.zip"),
    Asset("ANIM", "anim/pocketwatch_portal.zip"),
}

local prefabs = 
{
	"pocketwatch_portal_entrance",
}

local portal_assets =
{
    Asset("ANIM", "anim/pocketwatch_portal_fx.zip"),
}

local entrance_prefabs =
{
	"pocketwatch_portal_entrance_overlay",
	"pocketwatch_portal_entrance_underlay",
	"pocketwatch_portal_exit",
}

local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }

local function DelayedMarkTalker(player)
	-- if the player starts moving right away then we can skip this
	if player.sg == nil or player.sg:HasStateTag("idle") then 
		player.components.talker:Say(GetString(player, "ANNOUNCE_POCKETWATCH_MARK"))
	end 
end

local function noentcheckfn(pt)
    return not TheWorld.Map:IsPointNearHole(pt) and #TheSim:FindEntities(pt.x, pt.y, pt.z, 1, nil, NOTENTCHECK_CANT_TAGS) == 0
end

local function DoCastSpell(inst, doer, target, pos)
	local recallmark = inst.components.recallmark

	if recallmark:IsMarked() then
		local pt = inst:GetPosition()
		local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 3 + math.random(), 16, false, true, noentcheckfn, true, true)
						or FindWalkableOffset(pt, math.random() * 2 * PI, 5 + math.random(), 16, false, true, noentcheckfn, true, true)
						or FindWalkableOffset(pt, math.random() * 2 * PI, 7 + math.random(), 16, false, true, noentcheckfn, true, true)
		if offset ~= nil then
			pt = pt + offset
		end

		if not Shard_IsWorldAvailable(recallmark.recall_worldid) then
			return false, "SHARD_UNAVAILABLE"
		end

		local portal = SpawnPrefab("pocketwatch_portal_entrance")
		portal.Transform:SetPosition(pt:Get())
		portal:SpawnExit(recallmark.recall_worldid, recallmark.recall_x, recallmark.recall_y, recallmark.recall_z)
		inst.SoundEmitter:PlaySound("wanda1/wanda/portal_entrance_pre")

        local new_watch = SpawnPrefab("pocketwatch_recall")
		new_watch.components.recallmark:Copy(inst)

		local x, y, z = inst.Transform:GetWorldPosition()
        new_watch.Transform:SetPosition(x, y, z)
		new_watch.components.rechargeable:Discharge(TUNING.POCKETWATCH_RECALL_COOLDOWN)

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
        if holder ~= nil then
            local slot = holder:GetItemSlot(inst)
            inst:Remove()
            holder:GiveItem(new_watch, slot, Vector3(x, y, z))
        else
            inst:Remove()
        end

		return true
	else
		local x, y, z = doer.Transform:GetWorldPosition()
		recallmark:MarkPosition(x, y, z)
		inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/MarkPosition")

		doer:DoTaskInTime(12 * FRAMES, DelayedMarkTalker) 

		return true
	end
end

local function GetActionVerb(inst, doer, target)
	return inst:HasTag("recall_unmarked") and "RECALL_MARK"
			or "RECALL"
end

local function onPreBuilt(inst, builder, materials, recipe)
	if materials ~= nil and materials.pocketwatch_recall ~= nil then
		local from_watch = next(materials.pocketwatch_recall)
		if from_watch ~= nil then
			inst.components.recallmark:Copy(from_watch)
			if not from_watch.components.rechargeable:IsCharged() then
				inst.components.rechargeable:SetChargeTime(from_watch.components.rechargeable.chargetime)
				inst.components.rechargeable:SetCharge(from_watch.components.rechargeable.current)
				inst.components.pocketwatch.inactive = false
			end
		end
	end
end

local function fn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_portal", DoCastSpell, true)

	inst.GetActionVerb_CAST_POCKETWATCH = GetActionVerb

    if not TheWorld.ismastersim then
        return inst
    end

	PocketWatchCommon.MakeRecallMarkable(inst)

	inst.onPreBuilt = onPreBuilt

    return inst
end

-------------------------------------------------------------------------------
local MAX_LIGHT_FRAME = 14

local function OnUpdateLight(inst, dframes)
    local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes * (inst.lightupdaterate or 1)
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes*3
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(2.5 * inst._lightframe:value() / MAX_LIGHT_FRAME)

    if done then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function CloseExit(inst)
	if not inst.components.teleporter:IsBusy() then
		inst:Remove()
	elseif not inst.queued_close then
		inst.queued_close = true
		inst:ListenForEvent("doneteleporting", CloseExit)
	end
end

local function CloseEntrance(inst)
	if inst.components.teleporter:GetTarget() ~= nil then
		local exit = inst.components.teleporter.targetTeleporter
		inst.components.teleporter:Target(nil)
		CloseExit(exit)
	end

	inst._islighton:set(false)
	OnLightDirty(inst)

	inst.AnimState:PlayAnimation("portal_entrance_pst")
    inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("wanda1/wanda/portal_entrance_pst")

	if inst.overlay ~= nil and inst.overlay:IsValid() then
		inst.overlay.AnimState:PlayAnimation("portal_entrance_pst")
	end
	if inst.underlay ~= nil and inst.underlay:IsValid() then
		inst.underlay.AnimState:PlayAnimation("portal_entrance_pst")
	end
	inst.persists = false
	inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 1, inst.Remove)
end

local function OnTimerDone(inst, data)
	if data ~= nil then
		if data.name == "closeportal" then
			CloseEntrance(inst)
		elseif data.name == "start_loop_sfx" then
			if inst.components.teleporter.targetTeleporter ~= nil then
	            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/portal_LP", "loop")
			end
		elseif data.name == "turn_on_light" then
			inst._islighton:set(true)
			OnLightDirty(inst)
		end
	end
end

local function SpawnExit(inst, worldid, x, y, z)
	if worldid ~= nil and worldid ~= TheShard:GetShardId() then
		inst.components.teleporter:MigrationTarget(worldid, x, y, z)
	else
		local exit = SpawnPrefab("pocketwatch_portal_exit")
		exit.Transform:SetPosition(x, y, z)

		inst.components.teleporter:Target(exit)

		-- if one is removed, then shutdown the other
		inst:ListenForEvent("onremove", function() if inst:IsValid() then inst.components.teleporter:Target(nil) end end, exit) -- if the exit is removed, then shutdown the entrance
		exit:ListenForEvent("onremove", function() CloseExit(exit) end, inst) -- if the entance is removed, then shutdown the entrance
	end

    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/portal_LP", "loop")
end

local function OnActivate(inst, doer)
    if doer.components.talker ~= nil then
        doer.components.talker:ShutUp()
    end

    if doer.components.sanity ~= nil and not (doer:HasTag("pocketwatchcaster") or doer:HasTag("nowormholesanityloss")) then
        doer.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
    end
end

local function GetStatus(inst)
	return inst.components.teleporter.migration_data ~= nil and "DIFFERENTSHARD"
			or nil
end

local function portal_entrance_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pocketwatch_portal_fx")
    inst.AnimState:SetBuild("pocketwatch_portal_fx")
    inst.AnimState:PlayAnimation("portal_entrance_pre")
    inst.AnimState:PushAnimation("portal_entrance_loop", true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetSortOrder(-1)
	inst.AnimState:Hide("front")
	inst.AnimState:Hide("water_shadow")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetFalloff(1.5)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst:AddTag("scarytoprey")
	inst:AddTag("ignorewalkableplatforms")

	inst:SetPhysicsRadiusOverride(1)

    inst._lightframe = net_smallbyte(inst.GUID, "portalwatch._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "portalwatch._islighton", "lightdirty")
    inst._lighttask = nil
    inst._islighton:set(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("timer")
	inst.components.timer:StartTimer("closeportal", 10)
	inst:ListenForEvent("timerdone", OnTimerDone)

    inst:AddComponent("teleporter")
    inst.components.teleporter.onActivate = OnActivate
    inst.components.teleporter.offset = 0
	inst.components.teleporter.jumpinanim = "jumpportal" -- this still uses the standard jumpin_pre

	inst.components.timer:StartTimer("start_loop_sfx", 25*FRAMES)
	inst.components.timer:StartTimer("turn_on_light", 10*FRAMES)

	inst.SpawnExit = SpawnExit

	inst.overlay = SpawnPrefab("pocketwatch_portal_entrance_overlay")
	inst.overlay.entity:SetParent(inst.entity)
	inst.highlightchildren = { inst.overlay } -- for local host
	inst.underlay = SpawnPrefab("pocketwatch_portal_entrance_underlay")
	inst.underlay.entity:SetParent(inst.entity)

    return inst
end

local function overlay_OnEntityReplicated(inst)
	if inst.entity:GetParent() ~= nil then
		inst.entity:GetParent().highlightchildren = { inst }
	end
end

local function portal_entrance_overlayfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pocketwatch_portal_fx")
    inst.AnimState:SetBuild("pocketwatch_portal_fx")
    inst.AnimState:PlayAnimation("portal_entrance_pre")
    inst.AnimState:PushAnimation("portal_entrance_loop", true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetInheritsSortKey(false)
	inst.AnimState:Hide("back")
	inst.AnimState:Hide("water_shadow")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = overlay_OnEntityReplicated

        return inst
    end

    inst.persists = false

	return inst
end

local function portal_entrance_underlayfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pocketwatch_portal_fx")
    inst.AnimState:SetBuild("pocketwatch_portal_fx")
    inst.AnimState:PlayAnimation("portal_entrance_pre")
    inst.AnimState:PushAnimation("portal_entrance_loop", true)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.BOAT_LIP)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
    inst.AnimState:SetInheritsSortKey(false)
	inst.AnimState:Hide("front")
	inst.AnimState:Hide("back")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

	return inst
end


-------------------------------------------------------------------------------

local function OnSave(inst, data)
	data.queued_close = inst.queued_close 
end

local function OnLoadPostPass(inst, newents, data)
	if data.queued_close then
		inst.queued_close = true
		inst:ListenForEvent("doneteleporting", CloseExit)
	end 
end

local function Exit_DoneTeleportingTalker(player)
	player.components.talker:Say(GetString(player, "ANNOUNCE_POCKETWATCH_PORTAL"))
end

local function Exit_OnDoneTeleporting(inst, obj)
	if obj ~= nil then
		if obj.components.positionalwarp ~= nil then -- calling function already handles IsValid
			obj.components.positionalwarp:Reset()
		end

		if obj:HasTag("player") then
			obj:DoTaskInTime(obj:HasTag("pocketwatchcaster") and 1.25 or 2.5, Exit_DoneTeleportingTalker) -- for talker
		end
	end
end

local function portal_exit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("CLASSIFIED")

	inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("teleporter")
    inst.components.teleporter.trynooffset = true
    inst.components.teleporter.offset = 3
	inst.components.teleporter.overrideteleportarrivestate = "pocketwatch_portal_land"
	inst.components.teleporter.OnDoneTeleporting = Exit_OnDoneTeleporting

	inst.OnSave = OnSave
	inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function portal_fx_close(inst)
	if not inst.closing then
		inst.closing = true
		inst.AnimState:PlayAnimation("portal_exit_pst", false)
		inst.SoundEmitter:KillSound("loop")
		inst.SoundEmitter:PlaySound("wanda1/wanda/portal_exit_pst")

		inst._islighton:set(false)
		OnLightDirty(inst)
		inst:DoTaskInTime(1, inst.Remove)
	end
end

local function portal_exit_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pocketwatch_portal_fx")
    inst.AnimState:SetBuild("pocketwatch_portal_fx")
    inst.AnimState:PlayAnimation("portal_exit_pre")
    inst.AnimState:PushAnimation("portal_exit_loop", false)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

	inst.Transform:SetScale(.9, .9, .9)

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetFalloff(1.5)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

	inst:AddTag("ignorewalkableplatforms")

    inst._lightframe = net_smallbyte(inst.GUID, "portalwatch._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "portalwatch._islighton", "lightdirty")
    inst._lighttask = nil
    inst._islighton:set(true)

	inst.lightupdaterate = 2

	inst:SetPrefabNameOverride("pocketwatch_portal_exit")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

	
	inst:ListenForEvent("animqueueover", portal_fx_close)
	
	inst.SoundEmitter:PlaySound("wanda1/wanda/portal_exit_pre")
    inst:DoTaskInTime(FRAMES * 10, function(i) i.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/portal_LP", "loop") end)

    inst:AddComponent("inspectable")

	OnLightDirty(inst)

    return inst
end

--------------------------------------------------------------------------------

return Prefab("pocketwatch_portal", fn, assets, prefabs),
		Prefab("pocketwatch_portal_entrance", portal_entrance_fn, portal_assets, entrance_prefabs),
		Prefab("pocketwatch_portal_entrance_overlay", portal_entrance_overlayfn, portal_assets),
		Prefab("pocketwatch_portal_entrance_underlay", portal_entrance_underlayfn, portal_assets),
		Prefab("pocketwatch_portal_exit", portal_exit_fn, portal_assets),
		Prefab("pocketwatch_portal_exit_fx", portal_exit_fx_fn, portal_assets)
