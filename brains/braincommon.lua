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
-- Actions: MINE, CHOP

local MINE_TAGS = { "MINE_workable" }
local CHOP_TAGS = { "CHOP_workable" }

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
            local target = FindEntity(inst, finddist, nil, MINE_TAGS)

            if target == nil and inst.components.follower.leader ~= nil then
                target = FindEntity(inst.components.follower.leader, finddist, nil, MINE_TAGS)
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
            local target = FindEntity(inst, finddist, nil, CHOP_TAGS)

            if target == nil and inst.components.follower.leader ~= nil then
                target = FindEntity(inst.components.follower.leader, finddist, nil, CHOP_TAGS)
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

--NOTES(JBK): This helps followers do a task once they see the leader is doing an act.
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
        looper = LoopNode{ConditionNode(whilenode), ChattyNode(self.inst, parameters.chatterstring, DoAction(self.inst, findnode))}
    else
        looper = LoopNode{ConditionNode(whilenode), DoAction(self.inst, findnode)}
    end

    return IfThenDoWhileNode(ifnode, whilenode, action, looper)
end

BrainCommon.NodeAssistLeaderDoAction = NodeAssistLeaderDoAction

--------------------------------------------------------------------------
return BrainCommon
