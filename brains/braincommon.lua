require "behaviours/wander"
require "behaviours/panic"

local BrainCommon = {}
--------------------------------------------------------------------------

local TIME_TO_SEEK_SALT = 16

local function OnSaltlickPlaced(inst)
    inst._brainsaltlick = nil
    inst:RemoveEventCallback("saltlick_placed", OnSaltlickPlaced)
end

local FINDSALTLICK_MUST_TAGS = { "saltlick" }
local FINDSALTLICK_CANT_TAGS = { "INLIMBO", "fire", "burnt" }

local function FindSaltlick(inst)
    if inst._brainsaltlick == nil or
        not inst._brainsaltlick:IsValid() or
        not inst:HasTag("saltlick") or
        inst._brainsaltlick:IsInLimbo() or
        (inst._brainsaltlick.components.burnable ~= nil and inst._brainsaltlick.components.burnable:IsBurning()) or
        inst._brainsaltlick:HasTag("burnt") then
        local hadsaltlick = inst._brainsaltlick ~= nil
        inst._brainsaltlick = FindEntity(inst, TUNING.SALTLICK_CHECK_DIST, nil, FINDSALTLICK_MUST_TAGS, FINDSALTLICK_CANT_TAGS)
        if inst._brainsaltlick ~= nil then
            if not hadsaltlick then
                inst:ListenForEvent("saltlick_placed", OnSaltlickPlaced)
            end
        elseif hadsaltlick then
            inst:RemoveEventCallback("saltlick_placed", OnSaltlickPlaced)
        end
    end
    return inst._brainsaltlick ~= nil
end

local function WanderFromSaltlickDistFn(inst)
    local t = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("salt") or 0) or nil
    return t ~= nil
        and t < TIME_TO_SEEK_SALT
        and Remap(math.max(TIME_TO_SEEK_SALT * .5, t), TIME_TO_SEEK_SALT * .5, TIME_TO_SEEK_SALT, TUNING.SALTLICK_USE_DIST * .75, TUNING.SALTLICK_CHECK_DIST * .75)
        or TUNING.SALTLICK_CHECK_DIST * .75
end

local function ShouldSeekSalt(inst)
    return inst._brainsaltlick ~= nil
        and inst.components.timer ~= nil
        and (inst.components.timer:GetTimeLeft("salt") or 0) < TIME_TO_SEEK_SALT
end

local function AnchorToSaltlick(inst)
    local node = WhileNode(
        function()
            return FindSaltlick(inst)
        end,
        "Stay Near Salt",
        Wander(inst,
            function()
                return inst._brainsaltlick ~= nil
                    and inst._brainsaltlick:IsValid()
                    and inst._brainsaltlick:GetPosition()
                    or inst:GetPosition()
            end,
            WanderFromSaltlickDistFn)
    )

    local _OnStop = node.OnStop
    node.OnStop = function()
        if inst._brainsaltlick ~= nil then
            inst:RemoveEventCallback("saltlick_placed", OnSaltlickPlaced)
            inst._brainsaltlick = nil
        end
        if _OnStop ~= nil then
            _OnStop(node)
        end
    end

    return node
end

BrainCommon.ShouldSeekSalt = ShouldSeekSalt
BrainCommon.AnchorToSaltlick = AnchorToSaltlick

--------------------------------------------------------------------------

local function ShouldTriggerPanic(inst)
	return (inst.components.health ~= nil and inst.components.health.takingfiredamage)
		or (inst.components.hauntable ~= nil and inst.components.hauntable.panic)
end

BrainCommon.ShouldTriggerPanic = ShouldTriggerPanic
BrainCommon.PanicTrigger = function(inst)
	return WhileNode(function() return ShouldTriggerPanic(inst) end, "PanicTrigger", Panic(inst))
end

--------------------------------------------------------------------------

local function PanicWhenScared(inst, loseloyaltychance, chatty)
    local scareendtime = 0
    local function onepicscarefn(inst, data)
        scareendtime = math.max(scareendtime, data.duration + GetTime() + math.random())
    end
    inst:ListenForEvent("epicscare", onepicscarefn)

    local panicscarednode = Panic(inst)

    if chatty ~= nil then
        panicscarednode = ChattyNode(inst, chatty, panicscarednode)
    end

    if loseloyaltychance ~= nil and loseloyaltychance > 0 then
        panicscarednode = ParallelNode{
            panicscarednode,
            LoopNode({
                WaitNode(3),
                ActionNode(function()
                    if math.random() < loseloyaltychance and
                        inst.components.follower ~= nil and
                        inst.components.follower:GetLoyaltyPercent() > 0 and
                        inst.components.follower:GetLeader() ~= nil then
                        inst.components.follower:SetLeader(nil)
                    end
                end),
            }),
        }
    end

    local scared = false
    panicscarednode = WhileNode(
        function()
            if (GetTime() < scareendtime) ~= scared then
                if inst.components.combat ~= nil then
                    inst.components.combat:SetTarget(nil)
                end
                scared = not scared
            end
            return scared
        end,
        "PanicScared",
        panicscarednode
    )

    local _OnStop = panicscarednode.OnStop
    panicscarednode.OnStop = function()
        inst:RemoveEventCallback("epicscare", onepicscarefn)
        if _OnStop ~= nil then
            _OnStop(panicscarednode)
        end
    end

    return panicscarednode
end

BrainCommon.PanicWhenScared = PanicWhenScared

--------------------------------------------------------------------------

local function IsUnderIpecacsyrupEffect(inst)
    return inst:HasDebuff("ipecacsyrup_buff")
end

BrainCommon.IsUnderIpecacsyrupEffect = IsUnderIpecacsyrupEffect
BrainCommon.IpecacsyrupPanicTrigger = function(inst)
    return WhileNode(function() return BrainCommon.IsUnderIpecacsyrupEffect(inst) end, "IpecacsyrupPanicTrigger", Panic(inst))
end

--------------------------------------------------------------------------
-- Actions: MINE, CHOP

local MINE_TAGS = { "MINE_workable" }
local MINE_CANT_TAGS = { "carnivalgame_part", "event_trigger", "waxedplant" }
local CHOP_TAGS = { "CHOP_workable" }
local CHOP_CANT_TAGS = { "carnivalgame_part", "event_trigger", "waxedplant" }

local function IsDeciduousTreeMonster(guy)
    return guy.monster and guy.prefab == "deciduoustree"
end

local function FindDeciduousTreeMonster(inst, finddist)
    return FindEntity(inst, finddist / 3, IsDeciduousTreeMonster, CHOP_TAGS)
end


local AssistLeaderDefaults = {
    MINE = {
        Starter = function(inst, leaderdist, finddist)
            return inst.components.follower.leader ~= nil and
                    inst.components.follower.leader.sg ~= nil and
                    inst.components.follower.leader.sg:HasStateTag("mining")
        end,
        KeepGoing = function(inst, leaderdist, finddist)
            return inst.components.follower.leader ~= nil and
                    inst:IsNear(inst.components.follower.leader, leaderdist)
        end,
        FindNew = function(inst, leaderdist, finddist)
            local target = FindEntity(inst, finddist, nil, MINE_TAGS, MINE_CANT_TAGS)

            if target == nil and inst.components.follower.leader ~= nil then
                target = FindEntity(inst.components.follower.leader, finddist, nil, MINE_TAGS, MINE_CANT_TAGS)
            end

            if target ~= nil then
                return BufferedAction(inst, target, ACTIONS.MINE)
            end
        end,
    },
    CHOP = {
        Starter = function(inst, finddist)
            return inst.tree_target ~= nil
                or (inst.components.follower.leader ~= nil and
                    inst.components.follower.leader.sg ~= nil and
                    inst.components.follower.leader.sg:HasStateTag("chopping"))
                or FindDeciduousTreeMonster(inst, finddist) ~= nil
        end,
        KeepGoing = function(inst, leaderdist, finddist)
            return inst.tree_target ~= nil
                or (inst.components.follower.leader ~= nil and
                    inst:IsNear(inst.components.follower.leader, leaderdist))
                or FindDeciduousTreeMonster(inst, finddist) ~= nil
        end,
        FindNew = function(inst, leaderdist, finddist)
            local target = FindEntity(inst, finddist, nil, CHOP_TAGS, CHOP_CANT_TAGS)

            if target == nil and inst.components.follower.leader ~= nil then
                target = FindEntity(inst.components.follower.leader, finddist, nil, CHOP_TAGS, CHOP_CANT_TAGS)
            end

            if target ~= nil then
                if inst.tree_target ~= nil then
                    target = inst.tree_target
                    inst.tree_target = nil
                else
                    target = FindDeciduousTreeMonster(inst, finddist) or target
                end

                return BufferedAction(inst, target, ACTIONS.CHOP)
            end
        end,
    },
}
-- Mod support access.
BrainCommon.AssistLeaderDefaults = AssistLeaderDefaults

-- NOTES(JBK): This helps followers do a task once they see the leader is doing an act.
--            Since actions are very context sensitive, there are defaults above to help clarify context.
local function NodeAssistLeaderDoAction(self, parameters)
    local action = parameters.action
    local defaults = AssistLeaderDefaults[action]

    local starter = parameters.starter or defaults.Starter
    local keepgoing = parameters.keepgoing or defaults.KeepGoing
    local finder = parameters.finder or defaults.FindNew

    local keepgoing_leaderdist = parameters.keepgoing_leaderdist or TUNING.FOLLOWER_HELP_LEADERDIST
    local finder_finddist = parameters.finder_finddist or TUNING.FOLLOWER_HELP_FINDDIST

    local function ifnode()
        return starter(self.inst, keepgoing_leaderdist, finder_finddist)
    end
    local function whilenode()
        return keepgoing(self.inst, keepgoing_leaderdist, finder_finddist)
    end
    local function findnode()
        return finder(self.inst, keepgoing_leaderdist, finder_finddist)
    end
    local looper
    if parameters.chatterstring then
        looper = LoopNode{ConditionNode(whilenode), ChattyNode(self.inst, parameters.chatterstring, DoAction(self.inst, findnode, "DoAction_Chatty", nil, 3))}
    else
        looper = LoopNode{ConditionNode(whilenode), DoAction(self.inst, findnode, "DoAction_NoChatty", nil, 3)}
    end

    return IfThenDoWhileNode(ifnode, whilenode, action, looper)
end

BrainCommon.NodeAssistLeaderDoAction = NodeAssistLeaderDoAction

--------------------------------------------------------------------------
-- NOTES(JBK): This helps followers pickup items for a PLAYER leader.
--            They pickup if they are able to, then give them to their leader, or drop them onto the ground if unable to.

local function Unignore(inst, sometarget, ignorethese)
    ignorethese[sometarget] = nil
end
local function IgnoreThis(sometarget, ignorethese, leader, worker)
    if ignorethese[sometarget] and ignorethese[sometarget].task ~= nil then
        ignorethese[sometarget].task:Cancel()
        ignorethese[sometarget].task = nil
    else
        ignorethese[sometarget] = {worker = worker,}
    end
    ignorethese[sometarget].task = leader:DoTaskInTime(5, Unignore, sometarget, ignorethese)
end

local function PickUpAction(inst, pickup_range, pickup_range_local, furthestfirst, positionoverride, ignorethese, wholestacks, allowpickables, custom_pickup_filter)
    local activeitem = inst.components.inventory:GetActiveItem()
    if activeitem ~= nil then
        inst.components.inventory:DropItem(activeitem, true, true)
        if ignorethese ~= nil then
            if ignorethese[activeitem] and ignorethese[activeitem].task ~= nil then
                ignorethese[activeitem].task:Cancel()
                ignorethese[activeitem].task = nil
            end
            ignorethese[activeitem] = nil
        end
    end
    local onlytheseprefabs
    if wholestacks then
        local item = inst.components.inventory:GetFirstItemInAnySlot()
        if item ~= nil then
            if (item.components.stackable == nil or item.components.stackable:IsFull()) then
                return nil
            end
            onlytheseprefabs = {[item.prefab] = true}
        end
    elseif inst.components.inventory:IsFull() then
        return nil
    end

    local leader = inst.components.follower and inst.components.follower.leader or nil
    if leader == nil or leader.components.trader == nil then -- Trader component is needed for ACTIONS.GIVEALLTOPLAYER
        return nil
    end

    if not leader:HasTag("player") then -- Stop things from trying to help non-players due to trader mechanics.
        return nil
    end

    local item, pickable
    if pickup_range_local ~= nil then
        item, pickable = FindPickupableItem(leader, pickup_range_local, furthestfirst, inst:GetPosition(), ignorethese, onlytheseprefabs, allowpickables, inst, custom_pickup_filter)
    end
    if item == nil then
        item, pickable = FindPickupableItem(leader, pickup_range, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, inst, custom_pickup_filter)
    end
    if item == nil then
        return nil
    end

    if ignorethese ~= nil then
        IgnoreThis(item, ignorethese, leader, inst)
    end

    return BufferedAction(inst, item, item.components.trap ~= nil and ACTIONS.CHECKTRAP or pickable and ACTIONS.PICK or ACTIONS.PICKUP)
end

local function GiveAction(inst)
    local leader = inst.components.follower and inst.components.follower.leader or nil
    local leaderinv = leader and leader.components.inventory or nil
    local item = inst.components.inventory:GetFirstItemInAnySlot() or inst.components.inventory:GetActiveItem() -- This is intentionally backwards to give the bigger stacks first.
    if leader == nil or leaderinv == nil or item == nil then
        return nil
    end

    return leaderinv:CanAcceptCount(item, 1) > 0 and BufferedAction(inst, leader, ACTIONS.GIVEALLTOPLAYER, item) or nil
end

local function DropAction(inst)
    local leader = inst.components.follower and inst.components.follower.leader or nil
    local item = inst.components.inventory:GetFirstItemInAnySlot()
    if leader == nil or item == nil then
        return nil
    end

    local ba = BufferedAction(inst, leader, ACTIONS.DROP, item)
    ba.options.wholestack = true
    return ba
end

local function AlwaysTrue() return true end
local function NodeAssistLeaderPickUps(self, parameters)
    local cond = parameters.cond or AlwaysTrue
    local pickup_range = parameters.range
    local pickup_range_local = parameters.range_local
	local give_cond = parameters.give_cond
	local give_range_sq = parameters.give_range ~= nil and parameters.give_range * parameters.give_range or nil
    local furthestfirst = parameters.furthestfirst
	local positionoverridefn = type(parameters.positionoverride) == "function" and parameters.positionoverride or nil
	local positionoverride = positionoverridefn == nil and parameters.positionoverride or nil
    local ignorethese = parameters.ignorethese
    local wholestacks = parameters.wholestacks
    local allowpickables = parameters.allowpickables
    local custom_pickup_filter = parameters.custom_pickup_filter

    local function CustomPickUpAction(inst)
        return PickUpAction(inst, pickup_range, pickup_range_local, furthestfirst, positionoverridefn ~= nil and positionoverridefn(inst) or positionoverride, ignorethese, wholestacks, allowpickables, custom_pickup_filter)
    end

	local give_cond_fn = give_range_sq ~= nil and
		function()
			return (give_cond == nil or give_cond())
				and self.inst.components.follower ~= nil
				and self.inst.components.follower.leader ~= nil
				and self.inst.components.follower.leader:GetDistanceSqToPoint(positionoverridefn ~= nil and positionoverridefn(self.inst) or positionoverride or self.inst:GetPosition()) < give_range_sq
		end
		or give_cond
		or AlwaysTrue

    return PriorityNode({
        WhileNode(cond, "BC KeepPickup",
            DoAction(self.inst, CustomPickUpAction, "BC CustomPickUpAction", true)),
        WhileNode(give_cond_fn, "BC Should Bring To Leader",
			PriorityNode({
				DoAction(self.inst, GiveAction, "BC GiveAction", true),
				DoAction(self.inst, DropAction, "BC DropAction", true),
			}, .25)),
    },.25)
end
BrainCommon.NodeAssistLeaderPickUps = NodeAssistLeaderPickUps

return BrainCommon
