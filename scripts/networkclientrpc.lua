require 'util'

--Global so Mods can use them too
function checkbool(val) return val == nil or type(val) == "boolean" end
function checknumber(val) return type(val) == "number" end
function checkuint(val) return type(val) == "number" and tostring(val):find("%D") == nil end
function checkstring(val) return type(val) == "string" end
function checkentity(val) return type(val) == "table" end
optbool = checkbool
function optnumber(val) return val == nil or type(val) == "number" end
function optuint(val) return val == nil or (type(val) == "number" and tostring(val):find("%D") == nil) end
function optstring(val) return val == nil or type(val) == "string" end
function optentity(val) return val == nil or type(val) == "table" end

--NOTE: checkuint since non-integer inventory slots are not handled gracefully
--      checknumber is generally enough for other cases

local function printinvalid(rpcname, player)
    print(string.format("Invalid %s RPC from (%s) %s", rpcname, player.userid or "", player.name or ""))

    --This event is for MODs that want to handle players sending invalid rpcs
    TheWorld:PushEvent("invalidrpc", { player = player, rpcname = rpcname })

    if BRANCH == "dev" then
        --Internal testing
        assert(false, string.format("Invalid %s RPC from (%s) %s", rpcname, player.userid or "", player.name or ""))
    end
end

local function printinvalidplatform(rpcname, player, action, relative_x, relative_z, platform, platform_relative)
	if platform_relative and platform == nil then
		local player_pt = player ~= nil and player:GetPosition() or Vector3(math.huge, math.huge, math.huge)
		print(string.format("FAILED TO FIND PLATFORM IN RPC: %s, Action: %s, Player: %s (%0.2f, %0.2f), Playform Offset: %0.2f, %0.2f (len: %0.2f)", rpcname, tostring(action), tostring(player), player_pt.x, player_pt.z, relative_x, relative_z, VecUtil_Length(relative_x, relative_z)))
	end
end

--------------------------------------------------------------------------

local function IsPointInRange(player, x, z)
    local px, py, pz = player.Transform:GetWorldPosition()
    return distsq(x, z, px, pz) <= 4096
end

local function ConvertPlatformRelativePositionToAbsolutePosition(relative_x, relative_z, platform, platform_relative)
    if platform_relative then
		if platform == nil then
			return
		end
		local y
		relative_x, y, relative_z = platform.entity:LocalToWorldSpace(relative_x, 0, relative_z)
	end
    return relative_x, relative_z
end

local RPC_HANDLERS =
{
    LeftClick = function(player, action, x, z, target, isreleased, controlmods, noforce, mod_name, platform, platform_relative, spellbook, spell_id)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optentity(target) and
                optbool(isreleased) and
                optnumber(controlmods) and
                optbool(noforce) and
                optstring(mod_name) and
				optentity(platform) and
				checkbool(platform_relative) and
				optentity(spellbook) and
				optuint(spell_id)) then
            printinvalid("LeftClick", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller ~= nil then
			printinvalidplatform("LeftClick", player, action, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) then
					playercontroller:OnRemoteLeftClick(action, Vector3(x, 0, z), target, isreleased, controlmods, noforce, mod_name, spellbook, spell_id)
				else
					print("Remote left click out of range")
				end
			end
		end
    end,

    RightClick = function(player, action, x, z, target, rotation, isreleased, controlmods, noforce, mod_name, platform, platform_relative)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optentity(target) and
                optnumber(rotation) and
                optbool(isreleased) and
                optnumber(controlmods) and
                optbool(noforce) and
                optstring(mod_name) and
				optentity(platform) and
				checkbool(platform_relative)) then
            printinvalid("RightClick", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller ~= nil then
			printinvalidplatform("RightClick", player, action, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) and (rotation == nil or (rotation > -360.1 and rotation < 360.1)) then
					playercontroller:OnRemoteRightClick(action, Vector3(x, 0, z), target, rotation, isreleased, controlmods, noforce, mod_name)
				else
					print("Remote right click out of range")
				end
			end
		end
    end,

    ActionButton = function(player, action, target, isreleased, noforce, mod_name)
        if not (optnumber(action) and
                optentity(target) and
                optbool(isreleased) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("ActionButton", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteActionButton(action, target, isreleased, noforce, mod_name)
        end
    end,

    AttackButton = function(player, target, forceattack, noforce)
        if not (optentity(target) and
                optbool(forceattack) and
                optbool(noforce)) then
            printinvalid("AttackButton", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteAttackButton(target, forceattack, noforce)
        end
    end,

    InspectButton = function(player, target)
        if not checkentity(target) then
            printinvalid("InspectButton", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteInspectButton(target)
        end
    end,

    ResurrectButton = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteResurrectButton()
        end
    end,

    ControllerActionButton = function(player, action, target, isreleased, noforce, mod_name)
        if not (checknumber(action) and
                checkentity(target) and
                optbool(isreleased) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("ControllerActionButton", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteControllerActionButton(action, target, isreleased, noforce, mod_name)
        end
    end,

	ControllerActionButtonPoint = function(player, action, x, z, isreleased, noforce, mod_name, platform, platform_relative, isspecial, spellbook, spell_id)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optbool(isreleased) and
                optbool(noforce) and
                optstring(mod_name) and
				optentity(platform) and
				checkbool(platform_relative) and
				optbool(isspecial) and
				optentity(spellbook) and
				optuint(spell_id)) then
            printinvalid("ControllerActionButtonPoint", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller ~= nil then
			printinvalidplatform("ControllerActionButtonPoint", player, action, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) then
					playercontroller:OnRemoteControllerActionButtonPoint(action, Vector3(x, 0, z), isreleased, noforce, mod_name, isspecial, spellbook, spell_id)
				else
					print("Remote controller action button point out of range")
				end
			end
		end
    end,

    ControllerActionButtonDeploy = function(player, invobject, x, z, rotation, isreleased, platform, platform_relative)
        if not (checkentity(invobject) and
                checknumber(x) and
                checknumber(z) and
                optnumber(rotation) and
                optbool(isreleased) and
				optentity(platform) and
				checkbool(platform_relative)) then
            printinvalid("ControllerActionButtonDeploy", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller ~= nil then
			printinvalidplatform("ControllerActionButtonDeploy", player, nil, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) and (rotation == nil or (rotation > -360.1 and rotation < 360.1)) then
					playercontroller:OnRemoteControllerActionButtonDeploy(invobject, Vector3(x, 0, z), rotation, isreleased)
				else
					print("Remote controller action button deploy out of range")
				end
			end
		end
    end,

    ControllerAltActionButton = function(player, action, target, isreleased, noforce, mod_name)
        if not (checknumber(action) and
                checkentity(target) and
                optbool(isreleased) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("ControllerAltActionButton", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteControllerAltActionButton(action, target, isreleased, noforce, mod_name)
        end
    end,

    ControllerAltActionButtonPoint = function(player, action, x, z, isreleased, noforce, isspecial, mod_name, platform, platform_relative)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optbool(isreleased) and
                optbool(noforce) and
                optbool(isspecial) and
                optstring(mod_name) and
				optentity(platform) and
				checkbool(platform_relative)) then
            printinvalid("ControllerAltActionButtonPoint", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller ~= nil then
			printinvalidplatform("ControllerAltActionButtonPoint", player, action, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) then
					playercontroller:OnRemoteControllerAltActionButtonPoint(action, Vector3(x, 0, z), isreleased, noforce, isspecial, mod_name)
				else
					print("Remote controller alt action button point out of range")
				end
			end
		end
    end,

    ControllerAttackButton = function(player, target, isreleased, noforce)
        if not ((target == true or optentity(target)) and
                optbool(isreleased) and
                optbool(noforce)) then
            printinvalid("ControllerAttackButton", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteControllerAttackButton(target, isreleased, noforce)
        end
    end,

    StopControl = function(player, control)
        if not checknumber(control) then
            printinvalid("StopControl", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteStopControl(control)
        end
    end,

    StopAllControls = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteStopAllControls()
        end
    end,

    DirectWalking = function(player, x, z)
        if not (checknumber(x) and
                checknumber(z)) then
            printinvalid("DirectWalking", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if x * x + z * z < 1.01 then
                playercontroller:OnRemoteDirectWalking(x, z) -- x and z are directions, not positions, so we don't need it to be platform relative
            else
                print("Remote direct walking out of range")
            end
        end
    end,

    DragWalking = function(player, x, z, platform, platform_relative)
        if not (checknumber(x) and
                checknumber(z) and
				optentity(platform) and
				checkbool(platform_relative)) then
            printinvalid("DragWalking", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
			printinvalidplatform("DragWalking", player, nil, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) then
					playercontroller:OnRemoteDragWalking(x, z)
				else
					print("Remote drag walking out of range")
				end
			end
        end
    end,

    PredictWalking = function(player, x, z, isdirectwalking, isstart, platform, platform_relative)
        if not (checknumber(x) and
                checknumber(z) and
                checkbool(isdirectwalking) and
                checkbool(isstart) and
				optentity(platform) and
				checkbool(platform_relative)) then
            printinvalid("PredictWalking", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
			printinvalidplatform("PredictWalking", player, nil, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				if IsPointInRange(player, x, z) then
					playercontroller:OnRemotePredictWalking(x, z, isdirectwalking, isstart)
				else
					print("Remote predict walking out of range")
				end
			end
        end
    end,

	PredictOverrideLocomote = function(player, dir)
		if not checknumber(dir) then
			printinvalid("PredictOverrideLocomote", player)
			return
		end
		local playercontroller = player.components.playercontroller
		if playercontroller ~= nil then
			playercontroller:OnRemotePredictOverrideLocomote(dir)
		end
	end,

	StrafeFacing = function(player, dir)
		if not checknumber(dir) then
			printinvalid("StrafeFacing", player)
			return
		end
		local locomotor = player.components.locomotor
		if locomotor and not (player.sg and player.sg:HasStateTag("busy")) then
			locomotor:OnStrafeFacingChanged(dir)
		end
	end,

    StartHop = function(player, x, z, platform, has_platform)
        if not (checknumber(x) and
                checknumber(z) and
                optentity(platform) and
                checkbool(has_platform)) then
            printinvalid("StartHop", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller == nil then return end
        if has_platform and (platform == nil or platform.components.walkableplatform == nil) then return end
        if platform ~= nil and not has_platform then return end

        playercontroller:OnRemoteStartHop(x, z, platform)

    end,

    SteerBoat = function(player, dir_x, dir_z)
        if not (checknumber(dir_x) and
                checknumber(dir_z)) then
            printinvalid("SteerBoat", player)
            return
        end
        local steering_wheel_user = player.components.steeringwheeluser
        if steering_wheel_user ~= nil then
            steering_wheel_user:SteerInDir(dir_x, dir_z)
        end
    end,

    StopWalking = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteStopWalking()
        end
    end,

    --"action" and "mod_name" are deprecated, but keep them for mod compatibility
    DoWidgetButtonAction = function(player, action, target, mod_name)
        if not optentity(target) then
            printinvalid("DoWidgetButtonAction", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil and playercontroller:IsEnabled() and not player.sg:HasStateTag("busy") then
            local container = target ~= nil and target.components.container or nil
            if container ~= nil and container:IsOpenedBy(player) then
                local widget = container:GetWidget()
                local buttoninfo = widget ~= nil and widget.buttoninfo or nil
                if buttoninfo ~= nil and (buttoninfo.validfn == nil or buttoninfo.validfn(target)) and buttoninfo.fn ~= nil then
                    buttoninfo.fn(target, player)
                end
            end
        end
    end,

    ReturnActiveItem = function(player)
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:ReturnActiveItem()
        end
    end,

    PutOneOfActiveItemInSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("PutOneOfActiveItemInSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:PutOneOfActiveItemInSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:PutOneOfActiveItemInSlot(slot, player)
                end
            end
        end
    end,

    PutAllOfActiveItemInSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("PutAllOfActiveItemInSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:PutAllOfActiveItemInSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:PutAllOfActiveItemInSlot(slot, player)
                end
            end
        end
    end,

    TakeActiveItemFromHalfOfSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("TakeActiveItemFromHalfOfSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:TakeActiveItemFromHalfOfSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:TakeActiveItemFromHalfOfSlot(slot, player, player)
                end
            end
        end
    end,

    TakeActiveItemFromAllOfSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("TakeActiveItemFromAllOfSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:TakeActiveItemFromAllOfSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:TakeActiveItemFromAllOfSlot(slot, player)
                end
            end
        end
    end,

    AddOneOfActiveItemToSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("AddOneOfActiveItemToSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:AddOneOfActiveItemToSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:AddOneOfActiveItemToSlot(slot, player)
                end
            end
        end
    end,

    AddAllOfActiveItemToSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("AddAllOfActiveItemToSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:AddAllOfActiveItemToSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:AddAllOfActiveItemToSlot(slot, player)
                end
            end
        end
    end,

    SwapActiveItemWithSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("SwapActiveItemWithSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                inventory:SwapActiveItemWithSlot(slot)
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:SwapActiveItemWithSlot(slot, player)
                end
            end
        end
    end,

    SwapOneOfActiveItemWithSlot = function(player, slot, container)
        if not (checkuint(slot) and
                optentity(container)) then
            printinvalid("SwapOneOfActiveItemWithSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            if container == nil then
                --inventory:SwapOneOfActiveItemWithSlot(slot) -- TODO: Make this!
            else
                container = container.components.container
                if container ~= nil and container:IsOpenedBy(player) then
                    container:SwapOneOfActiveItemWithSlot(slot, player)
                end
            end
        end
    end,

    UseItemFromInvTile = function(player, action, item, controlmods, mod_name)
        if not (checknumber(action) and
                checkentity(item) and
                optnumber(controlmods) and
                optstring(mod_name)) then
            printinvalid("UseItemFromInvTile", player)
            return
        end
        local playercontroller = player.components.playercontroller
        local inventory = player.components.inventory
        if playercontroller ~= nil and inventory ~= nil then
            playercontroller:DecodeControlMods(controlmods)
            inventory:UseItemFromInvTile(item, action, mod_name)
            playercontroller:ClearControlMods()
        end
    end,

    ControllerUseItemOnItemFromInvTile = function(player, action, item, active_item, mod_name)
        if not (checknumber(action) and
                checkentity(item) and
                checkentity(active_item) and
                optstring(mod_name)) then
            printinvalid("ControllerUseItemOnItemFromInvTile", player)
            return
        end
        local playercontroller = player.components.playercontroller
        local inventory = player.components.inventory
        if playercontroller ~= nil and inventory ~= nil then
            playercontroller:ClearControlMods()
            inventory:ControllerUseItemOnItemFromInvTile(item, active_item, action, mod_name)
        end
    end,

    ControllerUseItemOnSelfFromInvTile = function(player, action, item, mod_name)
        if not (checknumber(action) and
                checkentity(item) and
                optstring(mod_name)) then
            printinvalid("ControllerUseItemOnSelfFromInvTile", player)
            return
        end
        local playercontroller = player.components.playercontroller
        local inventory = player.components.inventory
        if playercontroller ~= nil and inventory ~= nil then
            playercontroller:ClearControlMods()
            inventory:ControllerUseItemOnSelfFromInvTile(item, action, mod_name)
        end
    end,

    ControllerUseItemOnSceneFromInvTile = function(player, action, item, target, mod_name)
        if not (checknumber(action) and
                checkentity(item) and
                optentity(target) and
                optstring(mod_name)) then
            printinvalid("ControllerUseItemOnSceneFromInvTile", player)
            return
        end
        local playercontroller = player.components.playercontroller
        local inventory = player.components.inventory
        if playercontroller ~= nil and inventory ~= nil then
            playercontroller:ClearControlMods()
            inventory:ControllerUseItemOnSceneFromInvTile(item, target, action, mod_name)
        end
    end,

    InspectItemFromInvTile = function(player, item)
        if not checkentity(item) then
            printinvalid("InspectItemFromInvTile", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:InspectItemFromInvTile(item)
        end
    end,

    DropItemFromInvTile = function(player, item, single)
        if not (checkentity(item) and
                optbool(single)) then
            printinvalid("DropItemFromInvTile", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:DropItemFromInvTile(item, single)
        end
    end,

	CastSpellBookFromInv = function(player, item, spell_id)
		if not (checkentity(item) and
				checkuint(spell_id)) then
			printinvalid("CastSpellBookFromInv", player)
			return
		end
		local inventory = player.components.inventory
		if inventory ~= nil then
			inventory:CastSpellBookFromInv(item, spell_id)
		end
	end,

    EquipActiveItem = function(player)
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:EquipActiveItem()
        end
    end,

    EquipActionItem = function(player, item)
        if not optentity(item) then
            printinvalid("EquipActionItem", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:EquipActionItem(item)
        end
    end,

    SwapEquipWithActiveItem = function(player)
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:SwapEquipWithActiveItem()
        end
    end,

    TakeActiveItemFromEquipSlot = function(player, eslot)
        if not checknumber(eslot) then
            printinvalid("TakeActiveItemFromEquipSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:TakeActiveItemFromEquipSlotID(eslot)
        end
    end,

    MoveInvItemFromAllOfSlot = function(player, slot, destcontainer)
        if not (checkuint(slot) and
                checkentity(destcontainer)) then
            printinvalid("MoveInvItemFromAllOfSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:MoveItemFromAllOfSlot(slot, destcontainer)
        end
    end,

    MoveInvItemFromHalfOfSlot = function(player, slot, destcontainer)
        if not (checkuint(slot) and
                checkentity(destcontainer)) then
            printinvalid("MoveInvItemFromHalfOfSlot", player)
            return
        end
        local inventory = player.components.inventory
        if inventory ~= nil then
            inventory:MoveItemFromHalfOfSlot(slot, destcontainer)
        end
    end,

    MoveItemFromAllOfSlot = function(player, slot, srccontainer, destcontainer)
        if not (checkuint(slot) and
                checkentity(srccontainer) and
                optentity(destcontainer)) then
            printinvalid("MoveItemFromAllOfSlot", player)
            return
        end
        local container = srccontainer.components.container
        if container ~= nil and container:IsOpenedBy(player) then
            container:MoveItemFromAllOfSlot(slot, destcontainer or player, player)
        end
    end,

    MoveItemFromHalfOfSlot = function(player, slot, srccontainer, destcontainer)
        if not (checkuint(slot) and
                checkentity(srccontainer) and
                optentity(destcontainer)) then
            printinvalid("MoveItemFromHalfOfSlot", player)
            return
        end
        local container = srccontainer.components.container
        if container ~= nil and container:IsOpenedBy(player) then
            container:MoveItemFromHalfOfSlot(slot, destcontainer or player, player)
        end
    end,

    MakeRecipeFromMenu = function(player, recipe, skin_index)
        if not (checknumber(recipe) and
                optnumber(skin_index)) then
            printinvalid("MakeRecipeFromMenu", player)
            return
        end
        local builder = player.components.builder
        if builder ~= nil then
            for k, v in pairs(AllRecipes) do
                if v.rpc_id == recipe then
                    builder:MakeRecipeFromMenu(v, skin_index ~= nil and PREFAB_SKINS[v.product] ~= nil and PREFAB_SKINS[v.product][skin_index] or nil)
                    return
                end
            end
        end
    end,

    SetMovementPredictionEnabled = function(player, enabled)
        if not (checkbool(enabled)) then
            printinvalid("SetMovementPredictionEnabled", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller then
			playercontroller:OnRemoteToggleMovementPrediction(enabled)
        end
    end,

    MakeRecipeAtPoint = function(player, recipe, x, z, rot, skin_index, platform, platform_relative)
        if not (checknumber(recipe) and
                checknumber(x) and
                checknumber(z) and
                checknumber(rot) and
                optnumber(skin_index) and
				optentity(platform) and
				checkbool(platform_relative)) then
            printinvalid("MakeRecipeAtPoint", player)
            return
        end
		local builder = player.components.builder
		if builder ~= nil then
			printinvalidplatform("MakeRecipeAtPoint", player, nil, x, z, platform, platform_relative)
			x, z = ConvertPlatformRelativePositionToAbsolutePosition(x, z, platform, platform_relative)
			if x ~= nil then
				--rot supported range really only needs to be [-180, 180]
				if IsPointInRange(player, x, z) and rot >= -360 and rot <= 360 then
					for k, v in pairs(AllRecipes) do
						if v.rpc_id == recipe then
							builder:MakeRecipeAtPoint(v, Vector3(x, 0, z), rot, skin_index ~= nil and PREFAB_SKINS[v.name] ~= nil and PREFAB_SKINS[v.name][skin_index] or nil)
							return
						end
					end
				else
					print("Remote make recipe at point out of range")
				end
			end
		end
    end,

    BufferBuild = function(player, recipe)
        if not checknumber(recipe) then
            printinvalid("BufferBuild", player)
            return
        end
        local builder = player.components.builder
        if builder ~= nil then
            for k, v in pairs(AllRecipes) do
                if v.rpc_id == recipe then
                    builder:BufferBuild(k)
                end
            end
        end
    end,

	CannotBuild = function(player, reason)
        if not checkstring(reason) then
            printinvalid("CannotBuild", player)
            return
        end
		local str = GetString(player, "ANNOUNCE_CANNOT_BUILD", reason, true)
		if str ~= nil then
			local talker = player.components.talker
			if talker ~= nil then
				talker:Say(str)
			end
		end
	end,

    WakeUp = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil and
            playercontroller:IsEnabled() and
            player.sleepingbag ~= nil and
            player.sg:HasStateTag("sleeping") and
            (player.sg:HasStateTag("bedroll") or player.sg:HasStateTag("tent")) then
            player:PushEvent("locomote")
        end
    end,

    exitgym = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil and
            playercontroller:IsEnabled() then
            player:PushEvent("locomote")
        end
    end,

    SetWriteableText = function(player, target, text)
        if not (checkentity(target) and
                optstring(text)) then
            printinvalid("SetWriteableText", player)
            return
        end
        local writeable = target.components.writeable
        if writeable ~= nil then
            writeable:Write(player, text)
        end
    end,

    ToggleController = function(player, isattached)
        if not checkbool(isattached) then
            printinvalid("ToggleController", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:ToggleController(isattached)
        end
    end,

    OpenGift = function(player)
        local giftreceiver = player.components.giftreceiver
        if giftreceiver ~= nil then
            giftreceiver:OpenNextGift()
        end
    end,

    ClosePopup = function(player, popupcode, mod_name, ...)
        if not (checkuint(popupcode) and
                optstring(mod_name) and
                GetPopupFromPopupCode(popupcode, mod_name)) then
            printinvalid("ClosePopup", player)
            return
        end
        local popup = GetPopupFromPopupCode(popupcode, mod_name)
        if not popup.validaterpcfn(...) then
            printinvalid("ClosePopup"..tostring(popup.id), player)
        end
        popup:Close(player, ...)
    end,

    RepeatHeldAction = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller then
            playercontroller:RepeatHeldAction()
        end
    end,

    ClearActionHold = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller then
            playercontroller:ClearActionHold()
        end
    end,

    GetChatHistory = function(player, last_message_hash, first_message_hash)
        if not (checkuint(last_message_hash) and
                optuint(first_message_hash)) then
            printinvalid("GetChatHistory", player)
            return
        end

        --if the player is not yet spawned, "player" will be that clients userid.
        if not player.sent_chat_history then
            player.sent_chat_history = true
            ChatHistory:SendChatHistory(player.userid, last_message_hash, first_message_hash)
        end
    end,

    -- NOTES(JBK): OnMap RPCs are always world relative.
    DoActionOnMap = function(player, actioncode, x, z, maptarget)
        if not (checknumber(actioncode) and
                checknumber(x) and
                checknumber(z) and
                optentity(maptarget)) then
            printinvalid("DoActionOnMap PARAMS", player)
            return
        end
		local playercontroller = player.components.playercontroller
		if playercontroller then
			playercontroller:OnMapAction(actioncode, Vector3(x, 0, z), maptarget)
        end
    end,

    SetSkillActivatedState = function(player, skill_rpc_id, isunlocked)
        if not (checknumber(skill_rpc_id) and
                checkbool(isunlocked)) then
            printinvalid("SetSkillActivatedState arguments", player)
            return
        end

        local skill = TheSkillTree:GetSkillNameFromID(player.prefab, skill_rpc_id)
        if skill == nil then
            printinvalid("SetSkillActivatedState no skill with id", player, skill_rpc_id)
            return
        end

        local skilltreeupdater = player.components.skilltreeupdater
        if skilltreeupdater then
            if isunlocked then
                skilltreeupdater:ActivateSkill(skill, nil, true)
            else
                -- NOTES(JBK): If design changes this should be uncommented for now respec only happens during player selection screens or when we redefine the skill tree.
                --skilltreeupdater:DeactivateSkill(skill, nil, true)
                -- Clients manually sending this in with the console will now be in a desync state with their UI.
                -- Similar actions like removing entities locally we can not protect against console use for all cases.
            end
        end
    end,

    AddSkillXP = function(player, amount)
        if not (checknumber(amount)) then
            printinvalid("AddSkillXP", player)
            return
        end
        local skilltreeupdater = player.components.skilltreeupdater
        if skilltreeupdater then
            skilltreeupdater:AddSkillXP(amount, nil, true)
        end
    end,

    PostActivateHandshake = function(player, state)
        if not (checkuint(state)) then
            printinvalid("PostActivateHandshake", player)
            return
        end

        player:OnPostActivateHandshake_Server(state)
    end,

    OnScrapbookDataTaught = function(player, inst, response)
        if not checkentity(inst) then
            printinvalid("OnScrapbookDataTaught", player)
            return
        end

        if inst.OnScrapbookDataTaught then
            inst:OnScrapbookDataTaught(player, response)
        end
    end,

    SetClientAuthoritativeSetting = function(player, variable, value)
        -- NOTES(JBK): Check passed in variables in the callback not in the RPC here.
        player:SetClientAuthoritativeSetting(variable, value)
    end,

    -- NOTES(JBK): RPC limit is at 128, with 1-127 usable.
}

RPC = {}

--Generate RPC codes from table of handlers
local i = 1
for k, v in orderedPairs(RPC_HANDLERS) do
    RPC[k] = i
    i = i + 1
end
i = nil

local USERID_RPCS = {}

--Switch handler keys from code name to code value
for k, v in orderedPairs(RPC) do
    RPC_HANDLERS[v] = RPC_HANDLERS[k]
    RPC_HANDLERS[k] = nil
end

--these rpc's don't need special verification because server->client communication is already trusted.
local CLIENT_RPC_HANDLERS =
{
    ShowPopup = function(popupcode, mod_name, show, ...)
        local popup = GetPopupFromPopupCode(popupcode, mod_name)

        if popup then
            popup.fn(ThePlayer, show, ...)
        end
    end,

    LearnRecipe = function(product, ...)
        local cookbookupdater = ThePlayer.components.cookbookupdater
        local ingredients = {...}
        if cookbookupdater and product and not IsTableEmpty(ingredients) then
            cookbookupdater:LearnRecipe(product, ingredients)
        end
    end,

    LearnFoodStats = function(product)
        local cookbookupdater = ThePlayer.components.cookbookupdater
        if cookbookupdater and product then
            cookbookupdater:LearnFoodStats(product)
        end
    end,

    LearnPlantStage = function(plant, stage)
        local plantregistryupdater = ThePlayer.components.plantregistryupdater
        if plantregistryupdater and plant and stage then
            plantregistryupdater:LearnPlantStage(plant, stage)
        end
    end,

    LearnFertilizerStage = function(fertilizer)
        local plantregistryupdater = ThePlayer.components.plantregistryupdater
        if plantregistryupdater and fertilizer then
            plantregistryupdater:LearnFertilizer(fertilizer)
        end
    end,

    TakeOversizedPicture = function(plant, weight, beardskin, beardlength)
        local plantregistryupdater = ThePlayer.components.plantregistryupdater
        if plantregistryupdater and plant and weight then
            plantregistryupdater:TakeOversizedPicture(plant, weight, beardskin, beardlength)
        end
    end,

    RecieveChatHistory = function(chat_history)
        ChatHistory:RecieveChatHistory(chat_history)
    end,

    LearnBuilderRecipe = function(product)
        ThePlayer:PushEvent("LearnBuilderRecipe",{recipe=product})
    end,

    UpdateAccomplishment = function(name)
        TheGenericKV:SetKV(name, "1")
    end,

    UpdateCountAccomplishment = function(name, maxvalue)
        local current = tonumber(TheGenericKV:GetKV(name) or 0)

        if maxvalue ~= nil and current >= maxvalue then
            return
        end

        TheGenericKV:SetKV(name, tostring(current + 1))
    end,

    SetSkillActivatedState = function(skill_rpc_id, isunlocked)
        local characterprefab = ThePlayer.prefab or nil
        if characterprefab == nil then
            return
        end

        local skill = TheSkillTree:GetSkillNameFromID(characterprefab, skill_rpc_id)

        if skill == nil then
            return
        end

        local skilltreeupdater = ThePlayer.components.skilltreeupdater
        if skilltreeupdater then
            if isunlocked then
                skilltreeupdater:ActivateSkill(skill, nil, true)
            else
                skilltreeupdater:DeactivateSkill(skill, nil, true)
            end
        end
    end,

    AddSkillXP = function(amount)
        local skilltreeupdater = ThePlayer.components.skilltreeupdater
        if skilltreeupdater and amount then
            skilltreeupdater:AddSkillXP(amount, nil, true)
        end
    end,

    PostActivateHandshake = function(state)
        ThePlayer:OnPostActivateHandshake_Client(state)
    end,

    TryToTeachScrapbookData = function(inst)
        TheScrapbookPartitions:TryToTeachScrapbookData(false, inst)
    end,
}

CLIENT_RPC = {}

--Generate RPC codes from table of handlers
i = 1
for k, v in orderedPairs(CLIENT_RPC_HANDLERS) do
    CLIENT_RPC[k] = i
    i = i + 1
end
i = nil

--Switch handler keys from code name to code value
for k, v in orderedPairs(CLIENT_RPC) do
    CLIENT_RPC_HANDLERS[v] = CLIENT_RPC_HANDLERS[k]
    CLIENT_RPC_HANDLERS[k] = nil
end

--these rpc's don't need special verification because server<->server communication is already trusted.
local WorldSettings_Overrides = require("worldsettings_overrides")
local SHARD_RPC_HANDLERS =
{
    ReskinWorldMigrator = function(shardid, migrator, skin_theme, skin_id, sessionid)
        for i,v in ipairs(ShardPortals) do
            if v.components.worldmigrator.id == migrator then
                local skinname = nil
                if skin_theme ~= "" then
                    skinname = v.prefab.."_"..skin_theme
                end
                TheSim:ReskinEntity( v.GUID, v.skinname, skinname, skin_id, nil, sessionid )
            end
        end
    end,

    SyncWorldSettings = function(shardid, options_string)
        local success, data = RunInSandboxSafe(options_string)
		print("[SyncWorldSettings] recieved world settings from master shard.", success)
        if success then
            for option, value in pairs(data) do
				print("[SyncWorldSettings] applying " .. option .. " = " .. value .. " from master shard.")

                if WorldSettings_Overrides.Sync[option] then
                    WorldSettings_Overrides.Sync[option](value)
                else
                    if WorldSettings_Overrides.Pre[option] then
                        WorldSettings_Overrides.Pre[option](value)
                    end
                    if WorldSettings_Overrides.Post[option] then
                        WorldSettings_Overrides.Post[option](value)
                    end
                end
            end
        end
    end,

    ResyncWorldSettings = function(shardid)
        Shard_SyncWorldSettings(shardid, true)
    end,

    SyncBossDefeated = function(shardid, bossprefab) -- NOTES(JBK): This should not be called often enough to warrant a lookup table for bossprefab as an enum.
        Shard_SyncBossDefeated(bossprefab, shardid)
    end,

    SyncMermKingExists = function(shardid, exists)
        Shard_SyncMermKingExists(exists, shardid)
    end,

    SyncMermKingTrident = function(shardid, exists)
        Shard_SyncMermKingTrident(exists, shardid)
    end,
    SyncMermKingCrown = function(shardid, exists)
        Shard_SyncMermKingCrown(exists, shardid)
    end,
    SyncMermKingPauldron = function(shardid, exists)
        Shard_SyncMermKingPauldron(exists, shardid)
    end,
}

SHARD_RPC = {}

--Generate RPC codes from table of handlers
i = 1
for k, v in orderedPairs(SHARD_RPC_HANDLERS) do
    SHARD_RPC[k] = i
    i = i + 1
end
i = nil

--Switch handler keys from code name to code value
for k, v in orderedPairs(SHARD_RPC) do
    SHARD_RPC_HANDLERS[v] = SHARD_RPC_HANDLERS[k]
    SHARD_RPC_HANDLERS[k] = nil
end

function SendRPCToServer(code, ...)
    assert(RPC_HANDLERS[code] ~= nil)
    TheNet:SendRPCToServer(code, ...)
end

--SendRPCToClient(CLIENT_RPC.RPCNAME, users, ...)
--users is either:
--nil == all connected clients
--userid == send to that userid
--table == list of userids to send to
--all users must be connected to the shard this command originated from
function SendRPCToClient(code, ...)
    assert(CLIENT_RPC_HANDLERS[code] ~= nil)
    TheNet:SendRPCToClient(code, ...)
end

--SendRPCToShard(SHARD_RPC.RPCNAME, shards, ...)
--shards is either:
--nil == all connected shards
--shardid == send to that shard
--table == list of shards to send to
function SendRPCToShard(code, ...)
    assert(SHARD_RPC_HANDLERS[code] ~= nil)
    TheNet:SendRPCToShard(code, ...)
end

local RPC_QUEUE_RATE_LIMIT = 20 -- Per logic tick.
local RPC_QUEUE_RATE_LIMIT_PER_MOD = 5 -- +this for every mod RPC added.
local RPC_Queue_Limiter = {}
local RPC_Queue_Warned = {}
local RPC_Queue = {}
local RPC_Timeline = {}

local RPC_Client_Queue = {}
local RPC_Client_Timeline

local RPC_Shard_Queue = {}
local RPC_Shard_Timeline = {}

function HandleRPC(sender, tick, code, data)
    local fn = RPC_HANDLERS[code]
    if fn ~= nil then
        local senderistable = type(sender) == "table"
        if USERID_RPCS[fn] or senderistable then
            local userid = senderistable and sender.userid or nil

            if USERID_RPCS[fn] then
                sender = userid or sender
            end

            local limit = RPC_Queue_Limiter[sender] or 0
            if limit < RPC_QUEUE_RATE_LIMIT then
                RPC_Queue_Limiter[sender] = limit + 1
                table.insert(RPC_Queue, { fn, sender, data, tick })
            else
                 -- This user is sending way too much for normal activity so take note of it.
                if not RPC_Queue_Warned[sender] then
                    RPC_Queue_Warned[sender] = true
                    print("Rate limiting RPCs from", sender, userid, "last one being ID", tostring(code))
                end
            end
        else
            print("Invalid RPC sender: expected player, got userid")
        end
    else
        print("Invalid RPC code: "..tostring(code))
    end
end

function HandleClientRPC(tick, code, data)
    if not ThePlayer then return end --ThePlayer being nil means all rpc's are invalid.
    local fn = CLIENT_RPC_HANDLERS[code]
    if fn ~= nil then
        table.insert(RPC_Client_Queue, { fn, data, tick })
    else
        print("Invalid RPC code: "..tostring(code))
    end
end

function HandleShardRPC(sender, tick, code, data)
    local fn = SHARD_RPC_HANDLERS[code]
    if fn ~= nil then
        table.insert(RPC_Shard_Queue, { fn, sender, data, tick })
    else
        print("Invalid RPC code: "..tostring(code))
    end
end

function HandleRPCQueue()
    local RPC_Queue_new = {}
    local RPC_Queue_len = #RPC_Queue
    for i = 1, RPC_Queue_len do
        local rpcdata = RPC_Queue[i]
        local fn, sender, data, tick = unpack(rpcdata)

        local limit = (RPC_Queue_Limiter[sender] or 1) - 1
        if limit == 0 then
            RPC_Queue_Limiter[sender] = nil
            RPC_Queue_Warned[sender] = nil
        else
            RPC_Queue_Limiter[sender] = limit
        end

        if type(sender) == "table" and not sender:IsValid() then
            -- Ignore.
        elseif RPC_Timeline[sender] == nil or RPC_Timeline[sender] == tick then
            -- Invoke.
            if TheNet:CallRPC(fn, sender, data) then
                RPC_Timeline[sender] = tick
            end
        else
            -- Pending.
            table.insert(RPC_Queue_new, rpcdata)
            RPC_Timeline[sender] = 0
        end
    end
    RPC_Queue = RPC_Queue_new

    local RPC_Client_Queue_new = {}
    local RPC_Client_Queue_len = #RPC_Client_Queue
    for i = 1, RPC_Client_Queue_len do
        local rpcdata = RPC_Client_Queue[i]
        local fn, data, tick = unpack(rpcdata)

        if RPC_Client_Timeline == nil or RPC_Client_Timeline == tick then
            -- Invoke.
            if TheNet:CallClientRPC(fn, data) then
                RPC_Client_Timeline = tick
            end
        else
            -- Pending.
            table.insert(RPC_Client_Queue_new, rpcdata)
            RPC_Client_Timeline = 0
        end
    end
    RPC_Client_Queue = RPC_Client_Queue_new

    local RPC_Shard_Queue_new = {}
    local RPC_Shard_Queue_len = #RPC_Shard_Queue
    for i = 1, RPC_Shard_Queue_len do
        local rpcdata = RPC_Shard_Queue[i]
        local fn, sender, data, tick = unpack(rpcdata)

        if not Shard_IsWorldAvailable(tostring(sender)) and tostring(sender) ~= TheShard:GetShardId() then
            -- Ignore.
        elseif RPC_Shard_Timeline[sender] == nil or RPC_Shard_Timeline[sender] == tick then
            -- Invoke.
            if TheNet:CallShardRPC(fn, sender, data) then
                RPC_Shard_Timeline[sender] = tick
            end
            if RPC_Shard_Queue[RPC_Shard_Queue_len + 1] then
                print("Shard RPC invoked another RPC in the same frame and will be dropped! Delay shard RPCs sending more shard RPCs to itself by a frame minimally or try handling RPCs in a different way.")
            end
        else
            -- Pending.
            table.insert(RPC_Shard_Queue_new, rpcdata)
            RPC_Shard_Timeline[sender] = 0
        end
    end
    RPC_Shard_Queue = RPC_Shard_Queue_new
end

function TickRPCQueue()
    RPC_Timeline = {}
    RPC_Client_Timeline = nil
    RPC_Shard_Timeline = {}
end

local function __index_lower(t, k)
    return rawget(t, string.lower(k))
end

local function __newindex_lower(t, k, v)
    rawset(t, string.lower(k), v)
end

local function setmetadata( tab )
    setmetatable(tab, { __index = __index_lower, __newindex = __newindex_lower })
end

MOD_RPC = {}
MOD_RPC_HANDLERS = {}

CLIENT_MOD_RPC = {}
CLIENT_MOD_RPC_HANDLERS = {}

SHARD_MOD_RPC = {}
SHARD_MOD_RPC_HANDLERS = {}

setmetadata(MOD_RPC)
setmetadata(MOD_RPC_HANDLERS)

setmetadata(CLIENT_MOD_RPC)
setmetadata(CLIENT_MOD_RPC_HANDLERS)

setmetadata(SHARD_MOD_RPC)
setmetadata(SHARD_MOD_RPC_HANDLERS)

function AddModRPCHandler(namespace, name, fn)
    if MOD_RPC[namespace] == nil then
        MOD_RPC[namespace] = {}
        MOD_RPC_HANDLERS[namespace] = {}

        setmetadata(MOD_RPC[namespace])
        setmetadata(MOD_RPC_HANDLERS[namespace])
    end

    table.insert(MOD_RPC_HANDLERS[namespace], fn)
    MOD_RPC[namespace][name] = { namespace = namespace, id = #MOD_RPC_HANDLERS[namespace] }

    setmetadata(MOD_RPC[namespace][name])

    RPC_QUEUE_RATE_LIMIT = RPC_QUEUE_RATE_LIMIT + RPC_QUEUE_RATE_LIMIT_PER_MOD
end

function AddClientModRPCHandler(namespace, name, fn)
    if CLIENT_MOD_RPC[namespace] == nil then
        CLIENT_MOD_RPC[namespace] = {}
        CLIENT_MOD_RPC_HANDLERS[namespace] = {}

        setmetadata(CLIENT_MOD_RPC[namespace])
        setmetadata(CLIENT_MOD_RPC_HANDLERS[namespace])
    end

    table.insert(CLIENT_MOD_RPC_HANDLERS[namespace], fn)
    CLIENT_MOD_RPC[namespace][name] = { namespace = namespace, id = #CLIENT_MOD_RPC_HANDLERS[namespace] }

    setmetadata(CLIENT_MOD_RPC[namespace][name])
end

function AddShardModRPCHandler(namespace, name, fn)
    if SHARD_MOD_RPC[namespace] == nil then
        SHARD_MOD_RPC[namespace] = {}
        SHARD_MOD_RPC_HANDLERS[namespace] = {}

        setmetadata(SHARD_MOD_RPC[namespace])
        setmetadata(SHARD_MOD_RPC_HANDLERS[namespace])
    end

    table.insert(SHARD_MOD_RPC_HANDLERS[namespace], fn)
    SHARD_MOD_RPC[namespace][name] = { namespace = namespace, id = #SHARD_MOD_RPC_HANDLERS[namespace] }

    setmetadata(SHARD_MOD_RPC[namespace][name])
end

function SendModRPCToServer(id_table, ...)
    assert(id_table.namespace ~= nil and MOD_RPC_HANDLERS[id_table.namespace] ~= nil and MOD_RPC_HANDLERS[id_table.namespace][id_table.id] ~= nil)
    TheNet:SendModRPCToServer(id_table.namespace, id_table.id, ...)
end

function SendModRPCToClient(id_table, ...)
    assert(id_table.namespace ~= nil and CLIENT_MOD_RPC_HANDLERS[id_table.namespace] ~= nil and CLIENT_MOD_RPC_HANDLERS[id_table.namespace][id_table.id] ~= nil)
    TheNet:SendModRPCToClient(id_table.namespace, id_table.id, ...)
end

function SendModRPCToShard(id_table, ...)
    assert(id_table.namespace ~= nil and SHARD_MOD_RPC_HANDLERS[id_table.namespace] ~= nil and SHARD_MOD_RPC_HANDLERS[id_table.namespace][id_table.id] ~= nil)
    TheNet:SendModRPCToShard(id_table.namespace, id_table.id, ...)
end

function HandleModRPC(sender, tick, namespace, code, data)
    if MOD_RPC_HANDLERS[namespace] ~= nil then
        local fn = MOD_RPC_HANDLERS[namespace][code]
        if fn ~= nil then
            local senderistable = type(sender) == "table"
            if USERID_RPCS[fn] or senderistable then
                local userid = senderistable and sender.userid or nil

                if USERID_RPCS[fn] then
                    sender = userid or sender
                end

                local limit = RPC_Queue_Limiter[sender] or 0
                if limit < RPC_QUEUE_RATE_LIMIT then
                    RPC_Queue_Limiter[sender] = limit + 1
                    table.insert(RPC_Queue, { fn, sender, data, tick })
                else
                     -- This user is sending way too much for normal activity so take note of it.
                    if not RPC_Queue_Warned[sender] then
                        RPC_Queue_Warned[sender] = true
                        print("Rate limiting RPCs from [MOD]", sender, userid, "last one being ID", tostring(code), "of namespace", tostring(namespace))
                    end
                end
            else
                print("Invalid RPC sender: expected player, got userid")
            end
        else
            print("Invalid RPC code: ", namespace, code)
        end
    else
        print("Invalid RPC namespace: ", namespace, code)
    end
end

function HandleClientModRPC(tick, namespace, code, data)
    if CLIENT_MOD_RPC_HANDLERS[namespace] ~= nil then
        local fn = CLIENT_MOD_RPC_HANDLERS[namespace][code]
        if fn ~= nil then
            table.insert(RPC_Client_Queue, { fn, data, tick })
        else
            print("Invalid RPC code: ", namespace, code)
        end
    else
        print("Invalid RPC namespace: ", namespace, code)
    end
end

function HandleShardModRPC(sender, tick, namespace, code, data)
    if SHARD_MOD_RPC_HANDLERS[namespace] ~= nil then
        local fn = SHARD_MOD_RPC_HANDLERS[namespace][code]
        if fn ~= nil then
            table.insert(RPC_Shard_Queue, { fn, sender, data, tick })
        else
            print("Invalid RPC code: ", namespace, code)
        end
    else
        print("Invalid RPC namespace: ", namespace, code)
    end
end

function GetModRPCHandler(namespace, name)
    return MOD_RPC_HANDLERS[namespace][MOD_RPC[namespace][name].id]
end

function GetClientModRPCHandler(namespace, name)
    return CLIENT_MOD_RPC_HANDLERS[namespace][CLIENT_MOD_RPC[namespace][name].id]
end

function GetShardModRPCHandler(namespace, name)
    return SHARD_MOD_RPC_HANDLERS[namespace][SHARD_MOD_RPC[namespace][name].id]
end

function GetModRPC(namespace, name)
    return MOD_RPC[namespace][name]
end

function GetClientModRPC(namespace, name)
    return CLIENT_MOD_RPC[namespace][name]
end

function GetShardModRPC(namespace, name)
    return SHARD_MOD_RPC[namespace][name]
end

function MarkUserIDRPC(namespace, name)
    if not name then
        name = namespace
        namespace = nil
    end

    local fn
    if namespace then
        fn = GetModRPCHandler(namespace, name)
    else
        fn = RPC_HANDLERS[RPC[name]]
    end
    USERID_RPCS[fn] = true
end

--For gamelogic to deactivate world on a client when
--server has initiated a reset or world regeneration
function DisableRPCSending()
    SendRPCToServer = function() end
    SendModRPCToServer = SendRPCToServer
    SendRPCToClient = function() end
    SendModRPCToClient = SendRPCToClient
    SendRPCToShard = function() end
    SendModRPCToShard = SendRPCToShard
end
