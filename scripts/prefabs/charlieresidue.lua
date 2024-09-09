local assets =
{
	Asset("ANIM", "anim/charlieresidue.zip"),
}

local prefabs = {
    "charlie_snap",
    "charlie_snap_solid",
}

local ANIM_STATE =
{
	["pre"] = 0,
	["idle"] = 1,
	["pst"] = 2,
}

local function CreateFX()
	local inst = CreateEntity()

	inst:AddTag("NOBLOCK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("charlieresidue")
	inst.AnimState:SetBuild("charlieresidue")
	inst.AnimState:PlayAnimation("pre")
	inst.AnimState:PushAnimation("idle")
	inst.AnimState:Hide("mouseover")
	inst.AnimState:SetFinalOffset(7)

    inst.SoundEmitter:PlaySound("meta4/charlie_residue/idle_lp", "residueloop")

	return inst
end

local function ClearFXTarget(fx)
	if fx.target then
		if fx.target.client_forward_target == fx.client_forward_target then
			fx.target.client_forward_target = nil
		end
		fx.target = nil
		fx.OnRemoveEntity = nil
	end
end

local function SetupFXTarget(inst, fx, target)
	local radius = target and target:GetPhysicsRadius(0) or nil
	fx:SetPhysicsRadiusOverride(radius)
	inst:SetPhysicsRadiusOverride(radius)

	ClearFXTarget(fx)
	if target and target.client_forward_target == nil then
		target.client_forward_target = inst
		inst._fx.target = target
		inst._fx.OnRemoveEntity = ClearFXTarget
	end
end

local function InitClientFX(inst)
	inst._fx = CreateFX()
	inst._fx.entity:SetParent(inst.entity)
	inst._fx.client_forward_target = inst --locally forward mouseover and controller interaction target to our classified parent
	inst.highlightchildren = { inst._fx }

	SetupFXTarget(inst, inst._fx, inst._target:value())
end

local function OnIdle(inst)
	if inst._animstate:value() == ANIM_STATE["pre"] then
		inst._animstate:set_local(ANIM_STATE["idle"])
	end
end

local function SetFXOwner(inst, owner)
	if inst._inittask then
		inst._inittask:Cancel()
		inst._inittask = nil
		inst.Network:SetClassifiedTarget(owner)
		inst:ListenForEvent("onremove", function() inst:Remove() end, owner)
		if owner.HUD then
			InitClientFX(inst)
		end
		if owner.components.playervision and owner.components.playervision:HasRoseGlassesVision() then
			inst:ListenForEvent("ondeactivateskill_server", function(owner, data)
				if data and data.skill == "winona_charlie_1" then
					inst:Decay()
				end
			end, owner)
			inst:ListenForEvent("roseglassesvision", function(owner, data)
				if not data.enabled then
					inst:Decay()
				end
			end, owner)
			inst:DoTaskInTime(0.5, OnIdle)
		else
			inst:Decay()
		end
	end
end

local function OnAnimState_Client(inst)
	if inst._animstate:value() == ANIM_STATE["idle"] then
		if inst._fx.AnimState:IsCurrentAnimation("pre") and
			inst._fx.AnimState:GetCurrentAnimationLength() - inst._fx.AnimState:GetCurrentAnimationTime() > 0.2
		then
			inst._fx.AnimState:PlayAnimation("idle", true)
		end
	elseif inst._animstate:value() == ANIM_STATE["pst"] then
		ClearFXTarget(inst._fx)
		inst._fx.client_forward_target = nil
		inst._fx:AddTag("FX")
		inst._fx:AddTag("NOCLICK")
		inst._fx.entity:SetCanSleep(false)
		inst._fx.entity:SetParent(nil)
		inst._fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst._fx.AnimState:PlayAnimation("pst")
        inst._fx.SoundEmitter:KillSound("residueloop")
		inst._fx:ListenForEvent("animover", inst._fx.Remove)
		inst._fx = nil
		inst.highlightchildren = nil
	end
end

local function Decay(inst)
	if not inst.killed then
		inst.killed = true
		inst._animstate:set(ANIM_STATE["pst"])
		if inst._fx then
			OnAnimState_Client(inst)
		end
		inst:AddTag("NOCLICK")
		inst:DoTaskInTime(0.5, inst.Remove)
	end
end

local function OnActivate(inst, doer)
    inst:Decay()

    local roseinspectableuser = doer and doer.components.roseinspectableuser or nil
    if roseinspectableuser ~= nil then
        roseinspectableuser:OnCharlieResidueActivated(inst)
    end
end

local function SetMapActionContext(inst, context)
    inst._mapactioncontext:set(context)
    if context > CHARLIERESIDUE_MAP_ACTIONS.NONE then
        inst:AddTag("action_pulls_up_map") -- Make the non-map action pull up the map instead.
    else
        inst:RemoveTag("action_pulls_up_map")
    end
end

local function OnTarget_Client(inst)
	if inst._fx then
		SetupFXTarget(inst, inst._fx, inst._target:value())
	end
end

local function SetTarget(inst, target)
    inst._target:set(target)
	OnTarget_Client(inst)
	inst:SetPhysicsRadiusOverride(target and target:GetPhysicsRadius(0) or nil)
end

local function GetMapActionContext(inst)
    return inst._mapactioncontext:value()
end

local function GetTarget(inst)
    return inst._target:value()
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst:AddTag("CLASSIFIED")

	inst._animstate = net_tinybyte(inst.GUID, "charlieresidue._animstate", "animstatedirty")
	inst._mapactioncontext = net_tinybyte(inst.GUID, "charlieresidue._mapactioncontext", "mapactioncontextdirty")
    inst._target = net_entity(inst.GUID, "charlieresidue._target", "targetdirty")

    inst.valid_map_actions = {
        [ACTIONS.ACTIVATE] = true,
    }

    inst.GetMapActionContext = GetMapActionContext
    inst.GetTarget = GetTarget

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		InitClientFX(inst)
		inst:ListenForEvent("animstatedirty", OnAnimState_Client)
		--inst:ListenForEvent("mapactioncontextdirty", OnMapActionContext_Client)
		inst:ListenForEvent("targetdirty", OnTarget_Client)

		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate

	inst.Network:SetClassifiedTarget(inst)
	inst._inittask = inst:DoTaskInTime(0, inst.Remove)

	inst.SetFXOwner = SetFXOwner
    inst.Decay = Decay
	inst.SetMapActionContext = SetMapActionContext
	inst.SetTarget = SetTarget
	inst.OnEntitySleep = inst.Remove
	inst.persists = false

	return inst
end

return Prefab("charlieresidue", fn, assets, prefabs)
