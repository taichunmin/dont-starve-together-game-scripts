
local BALLOONS = require "prefabs/balloons_common"

local prefabs =
{
	"balloon_held_child_client",
}

local function updateballonrunningstate(inst)
	local owner = inst.entity:GetParent()
	local running
	if owner.sg ~= nil then
		running = owner.sg:HasStateTag("moving")
	else
		running = owner:HasTag("moving")
	end
	if running ~= inst._isrunning then
		inst._isrunning = running
		inst:PushEvent("sg_update_running_state")
	end
end

local function UpdateBalloonSymbol(inst)
	if inst.net_proxy:IsValid() and inst.net_proxy._swap_build:value() ~= 0 then
		inst.AnimState:OverrideSymbol("swap_balloon", inst.net_proxy._swap_build:value(), inst.net_proxy._swap_sym:value())
	else
		inst.AnimState:ClearOverrideSymbol("swap_balloon")
	end
end

local function SetupFromBaseItem(inst, baseitem, owner, picked_up_from_ground, colour_idx)
    inst.entity:SetParent(owner.entity)
	inst._colour_idx:set(baseitem.colour_idx or 0)

	local swap_build, swap_sym = baseitem.AnimState:GetSymbolOverride("swap_balloon")
	inst._swap_build:set(swap_build or 0)
	inst._swap_sym:set(swap_sym or 0)

	if baseitem.components.fueled ~= nil then
		inst:ListenForEvent("onfueldsectionchanged", function()
			local swap_build, swap_sym
			if baseitem:IsValid() then
				swap_build, swap_sym = baseitem.AnimState:GetSymbolOverride("swap_balloon")
			end
			inst._swap_build:set(swap_build or 0)
			inst._swap_sym:set(swap_sym or 0)

			if inst.client_obj ~= nil then
				inst.client_obj.sg:GoToState("deflate")
			end
			inst._deflate_event:push()
		end, baseitem)
	end
end

local function SpawnClientObject(inst)
	local owner = inst.entity:GetParent()
	if owner ~= nil then
		local client_obj = SpawnPrefab("balloon_held_child_client")
		client_obj.entity:SetParent(owner.entity)
		client_obj.entity:AddFollower()
	    client_obj.Follower:FollowSymbol(owner.GUID, "swap_object", 0, 0, 0)
		client_obj.net_proxy = inst

		if inst._colour_idx:value() ~= 0 then
			BALLOONS.SetColour(client_obj, inst._colour_idx:value())
		end
		if inst._swap_build:value() ~= 0 then
			client_obj.AnimState:OverrideSymbol("swap_balloon", inst._swap_build:value(), inst._swap_sym:value())
		end

		client_obj:DoPeriodicTask(0, updateballonrunningstate)
		updateballonrunningstate(client_obj)

		inst.client_obj = client_obj
		inst:ListenForEvent("onremove", function() if inst.client_obj ~= nil then inst.client_obj:Remove() inst.client_obj = nil end end)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("DECOR")

	inst._colour_idx = net_tinybyte(inst.GUID, "ballon_held_child._colour_idx")
	inst._swap_build = net_hash(inst.GUID, "ballon_held_child._swap_build")
	inst._swap_sym = net_hash(inst.GUID, "ballon_held_child._swap_sym")
	inst._deflate_event = net_event(inst.GUID, "ballon_held_child.deflateevent")

	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, SpawnClientObject)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	    inst:ListenForEvent("ballon_held_child.deflateevent", function()
			if inst.client_obj ~= nil then
				inst.client_obj.sg:GoToState("deflate")
			end
		end)

        return inst
    end

    inst.persists = false

	inst.SetupFromBaseItem = SetupFromBaseItem

    return inst
end

local function client_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("balloon2")
    inst.AnimState:SetBuild("balloon2")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:OverrideSymbol("swap_rope", "balloon2", "rope_held")
	inst.AnimState:OverrideSymbol("swap_balloon", "balloon_shapes2", "balloon_1")
	inst.AnimState:SetFinalOffset(-1)

    inst:AddTag("FX")

	inst.Transform:SetFourFaced()

    inst.entity:SetPristine()

    inst.persists = false

	inst._isrunning = false

	inst.UpdateBalloonSymbol = UpdateBalloonSymbol

	inst:SetStateGraph("SGballoonheld")

    if TheNet:IsDedicated() then
		inst:DoTaskInTime(0, inst.Remove) -- this should not be on the dedicated server
    end
    return inst
end

return Prefab("balloon_held_child", fn, nil, prefabs),
	 Prefab("balloon_held_child_client", client_fn)
