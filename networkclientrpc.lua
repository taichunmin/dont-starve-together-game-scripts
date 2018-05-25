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

--------------------------------------------------------------------------

local function IsPointInRange(player, x, z)
    local px, py, pz = player.Transform:GetWorldPosition()
    return distsq(x, z, px, pz) <= 4096
end

local RPC_HANDLERS =
{
    LeftClick = function(player, action, x, z, target, isreleased, controlmods, noforce, mod_name)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optentity(target) and
                optbool(isreleased) and
                optnumber(controlmods) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("LeftClick", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) then
                playercontroller:OnRemoteLeftClick(action, Vector3(x, 0, z), target, isreleased, controlmods, noforce, mod_name)
            else
                print("Remote left click out of range")
            end
        end
    end,

    RightClick = function(player, action, x, z, target, rotation, isreleased, controlmods, noforce, mod_name)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optentity(target) and
                optnumber(rotation) and
                optbool(isreleased) and
                optnumber(controlmods) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("RightClick", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) and (rotation == nil or (rotation > -360.1 and rotation < 360.1)) then
                playercontroller:OnRemoteRightClick(action, Vector3(x, 0, z), target, rotation, isreleased, controlmods, noforce, mod_name)
            else
                print("Remote right click out of range")
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

    ControllerActionButtonPoint = function(player, action, x, z, isreleased, noforce, mod_name)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optbool(isreleased) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("ControllerActionButtonPoint", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) then
                playercontroller:OnRemoteControllerActionButtonPoint(action, Vector3(x, 0, z), isreleased, noforce, mod_name)
            else
                print("Remote controller action button point out of range")
            end
        end
    end,

    ControllerActionButtonDeploy = function(player, invobject, x, z, rotation, isreleased)
        if not (checkentity(invobject) and
                checknumber(x) and
                checknumber(z) and
                optnumber(rotation) and
                optbool(isreleased)) then
            printinvalid("ControllerActionButtonDeploy", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) and (rotation == nil or (rotation > -360.1 and rotation < 360.1)) then
                playercontroller:OnRemoteControllerActionButtonDeploy(invobject, Vector3(x, 0, z), rotation, isreleased)
            else
                print("Remote controller action button deploy out of range")
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

    ControllerAltActionButtonPoint = function(player, action, x, z, isreleased, noforce, mod_name)
        if not (checknumber(action) and
                checknumber(x) and
                checknumber(z) and
                optbool(isreleased) and
                optbool(noforce) and
                optstring(mod_name)) then
            printinvalid("ControllerAltActionButtonPoint", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) then
                playercontroller:OnRemoteControllerAltActionButtonPoint(action, Vector3(x, 0, z), isreleased, noforce, mod_name)
            else
                print("Remote controller alt action button point out of range")
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
                playercontroller:OnRemoteDirectWalking(x, z)
            else
                print("Remote direct walking out of range")
            end
        end
    end,

    DragWalking = function(player, x, z)
        if not (checknumber(x) and
                checknumber(z)) then
            printinvalid("DragWalking", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) then
                playercontroller:OnRemoteDragWalking(x, z)
            else
                print("Remote drag walking out of range")
            end
        end
    end,

    PredictWalking = function(player, x, z, isdirectwalking)
        if not (checknumber(x) and
                checknumber(z) and
                checkbool(isdirectwalking)) then
            printinvalid("PredictWalking", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            if IsPointInRange(player, x, z) then
                playercontroller:OnRemotePredictWalking(x, z, isdirectwalking)
            else
                print("Remote predict walking out of range")
            end
        end
    end,

    StopWalking = function(player)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil then
            playercontroller:OnRemoteStopWalking()
        end
    end,

    DoWidgetButtonAction = function(player, action, target, mod_name)
        if not (checknumber(action) and
                optentity(target) and
                optstring(mod_name)) then
            printinvalid("DoWidgetButtonAction", player)
            return
        end
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil and playercontroller:IsEnabled() and not player.sg:HasStateTag("busy") then
            if mod_name ~= nil then
                action = ACTION_MOD_IDS[mod_name] ~= nil and ACTION_MOD_IDS[mod_name][action] ~= nil and ACTIONS[ACTION_MOD_IDS[mod_name][action]] or nil
            else
                action = ACTION_IDS[action] ~= nil and ACTIONS[ACTION_IDS[action]] or nil
            end
            if action ~= nil then
                local container = target ~= nil and target.components.container or nil
                if container == nil or container.opener == player then
                    BufferedAction(player, target, action):Do()
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
                    container:PutOneOfActiveItemInSlot(slot)
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
                    container:PutAllOfActiveItemInSlot(slot)
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
                    container:TakeActiveItemFromHalfOfSlot(slot)
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
                    container:TakeActiveItemFromAllOfSlot(slot)
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
                    container:AddOneOfActiveItemToSlot(slot)
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
                    container:AddAllOfActiveItemToSlot(slot)
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
                    container:SwapActiveItemWithSlot(slot)
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
        if container ~= nil then
            container:MoveItemFromAllOfSlot(slot, destcontainer or player)
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
        if container ~= nil then
            container:MoveItemFromHalfOfSlot(slot, destcontainer or player)
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
                    builder:MakeRecipeFromMenu(v, skin_index ~= nil and PREFAB_SKINS[v.name] ~= nil and PREFAB_SKINS[v.name][skin_index] or nil)
                    return
                end
            end
        end
    end,

    MakeRecipeAtPoint = function(player, recipe, x, z, rot, skin_index)
        if not (checknumber(recipe) and
                checknumber(x) and
                checknumber(z) and
                checknumber(rot) and
                optnumber(skin_index)) then
            printinvalid("MakeRecipeAtPoint", player)
            return
        end
        local builder = player.components.builder
        if builder ~= nil then
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

    DoneOpenGift = function(player, usewardrobe)
        if not optbool(usewardrobe) then
            printinvalid("DoneOpenGift", player)
            return
        end
        local giftreceiver = player.components.giftreceiver
        if giftreceiver ~= nil then
            giftreceiver:OnStopOpenGift(usewardrobe)
        end
    end,

    CloseWardrobe = function(player, base_skin, body_skin, hand_skin, legs_skin, feet_skin)
        if not (optstring(base_skin) and
                optstring(body_skin) and
                optstring(hand_skin) and
                optstring(legs_skin) and
                optstring(feet_skin)) then
            printinvalid("CloseWardrobe", player)
            return
        end
        player:PushEvent("ms_closewardrobe", {
            base = base_skin,
            body = body_skin,
            hand = hand_skin,
            legs = legs_skin,
            feet = feet_skin,
        })
    end,
}

RPC = {}

--Generate RPC codes from table of handlers
local i = 1
for k, v in orderedPairs(RPC_HANDLERS) do
    RPC[k] = i
    i = i + 1
end
i = nil

--Switch handler keys from code name to code value
for k, v in orderedPairs(RPC) do
    RPC_HANDLERS[v] = RPC_HANDLERS[k]
    RPC_HANDLERS[k] = nil
end

function SendRPCToServer(code, ...)
    assert(RPC_HANDLERS[code] ~= nil)
    TheNet:SendRPCToServer(code, ...)
end

local RPC_Queue = {}
local RPC_Timeline = {}

function HandleRPC(sender, tick, code, data)
    local fn = RPC_HANDLERS[code]
    if fn ~= nil then
        table.insert(RPC_Queue, { fn, sender, data, tick })
    else
        print("Invalid RPC code: "..tostring(code))
    end
end

function HandleRPCQueue()
    local i = 1
    while i <= #RPC_Queue do
        local fn, sender, data, tick = unpack(RPC_Queue[i])

        if not sender:IsValid() then
            table.remove(RPC_Queue, i)
        elseif RPC_Timeline[sender] == nil or RPC_Timeline[sender] == tick then
            table.remove(RPC_Queue, i)
            if TheNet:CallRPC(fn, sender, data) then
                RPC_Timeline[sender] = tick
            end
        else
            RPC_Timeline[sender] = 0
            i = i + 1
        end
    end
end

function TickRPCQueue()
    RPC_Timeline = {}
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

setmetadata(MOD_RPC)
setmetadata(MOD_RPC_HANDLERS)

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
end

function SendModRPCToServer(id_table, ...)
    assert(id_table.namespace ~= nil and MOD_RPC_HANDLERS[id_table.namespace] ~= nil and MOD_RPC_HANDLERS[id_table.namespace][id_table.id] ~= nil)
    TheNet:SendModRPCToServer(id_table.namespace, id_table.id, ...)
end

function HandleModRPC(sender, tick, namespace, code, data)
    if MOD_RPC_HANDLERS[namespace] ~= nil then
        local fn = MOD_RPC_HANDLERS[namespace][code]
        if fn ~= nil then
            table.insert(RPC_Queue, { fn, sender, data, tick })
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

function GetModRPC(namespace, name)
    return MOD_RPC[namespace][name]
end

--For gamelogic to deactivate world on a client when
--server has initiated a reset or world regeneration
function DisableRPCSending()
    SendRPCToServer = function() end
    SendModRPCToServer = SendRPCToServer
end
