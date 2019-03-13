require("behaviours/chaseandattackandavoid")
require("behaviours/leashandavoid")
require("behaviours/panicandavoid")
require("behaviours/standstill")
require("behaviours/wander")

local MAX_WANDER_DIST = 8
local MIN_PANIC_DIST_SQ = 2 * 2
local MAX_PANIC_DIST_SQ = 5 * 5
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8
local SEE_OBJ_DIST = 20
local SEE_OBJ_DIST_SQ = SEE_OBJ_DIST * SEE_OBJ_DIST
local KEEP_OBJ_DIST_SQ = 6 * 6
local PICK_PROP_DIST = 1
local DIVE_ITEM_DIST = 4.5
local KEEP_TARGET_THRESHOLD = 4
local AVOID_KING_DIST = 3 --pigking radius + pigelite radius + some breathing room

local FIND_PROP_TAGS =
{
    MUST_TAGS = { "minigameitem", "propweapon" },
    NO_TAGS = { "INLIMBO", "NOCLICK", "fire", "knockbackdelayinteraction" },
}
local FIND_GOLD_TAGS =
{
    MUST_TAGS = { "minigameitem" },
    NO_TAGS = { "INLIMBO", "NOCLICK", "fire", "knockbackdelayinteraction", "propweapon" },
}

local PigEliteBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.pickprop = nil
    self.seekprop = nil
    self.diveitem = nil
    self.seekitem = nil
    self.matchovertime = nil
    self.canpanic = true
end)

local function HasProp(inst)
    local prop = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return prop ~= nil and prop:HasTag("propweapon")
end

local function IsItemTarget(inst, target)
    return inst.brain ~= nil and (inst.brain.seekitem == target or inst.brain.diveitem == target)
end

local function IsPropTarget(inst, target)
    return inst.brain ~= nil and (inst.brain.seekprop == target or inst.brain.pickprop == target)
end

local function IsValidObj(inst, obj, squadcheckfn)
    return obj ~= nil
        and obj:IsValid()
        and not (obj:IsInLimbo() or obj:HasTag("NOCLICK"))
        and not (obj.components.burnable ~= nil and obj.components.burnable:IsBurning())
        and not inst:IsSquadAlreadyTargeting(obj, inst:GetDistanceSqToInst(obj), squadcheckfn)
end

local function FindObj(inst, dist, tags, squadcheckfn)
    return FindEntity(inst, dist, function(obj) return not inst:IsSquadAlreadyTargeting(obj, inst:GetDistanceSqToInst(obj), squadcheckfn) end, tags.MUST_TAGS, tags.NO_TAGS)
end

local function GetSeekObj(inst, old, tags, squadcheckfn)
    local olddist = nil
    if old ~= nil then
        if IsValidObj(inst, old, squadcheckfn) then
            local x, y, z = old.Transform:GetWorldPosition()
            olddist = inst:GetDistanceSqToPoint(x, y, z)
            if olddist < KEEP_OBJ_DIST_SQ then
                --V2C: don't switch if it's close
                return old
            elseif olddist >= SEE_OBJ_DIST_SQ then
                --V2C: forget if it's too far away
                old = nil
                olddist = nil
            else
                --V2C: switch if it's much closer
                olddist = math.sqrt(olddist)
                olddist = math.min(olddist * .75, olddist - KEEP_TARGET_THRESHOLD)
                if olddist <= 0 then
                    --shouldn't be possible
                    return old
                end
            end
        else
            old = nil
        end
    end
    return FindObj(inst, olddist or SEE_OBJ_DIST, tags, squadcheckfn) or old
end

local function ShouldPickProp(self)
    if HasProp(self.inst) then
        self.pickprop = nil
        return false
    elseif IsValidObj(self.inst, self.pickprop, IsPropTarget) and self.inst:IsNear(self.pickprop, PICK_PROP_DIST) then
        return true
    elseif IsValidObj(self.inst, self.seekprop, IsPropTarget) and self.inst:IsNear(self.seekprop, PICK_PROP_DIST) then
        self.pickprop = self.seekprop
        return true
    end
    self.pickprop = FindObj(self.inst, PICK_PROP_DIST, FIND_PROP_TAGS, IsPropTarget)
    return self.pickprop ~= nil
end

local function GetSeekPropPos(self)
    if HasProp(self.inst) then
        self.seekprop = nil
        return
    end
    self.seekprop = GetSeekObj(self.inst, self.seekprop, FIND_PROP_TAGS, IsPropTarget)
    return self.seekprop ~= nil and self.seekprop:GetPosition() or nil
end

local function ShouldDiveItem(self)
    if IsValidObj(self.inst, self.diveitem, IsItemTarget) and self.inst:IsNear(self.diveitem, DIVE_ITEM_DIST) then
        return true
    elseif IsValidObj(self.inst, self.seekitem, IsItemTarget) then
        if self.inst:IsNear(self.seekitem, DIVE_ITEM_DIST) then
            self.diveitem = self.seekitem
            return true
        elseif self.inst:IsNear(self.seekitem, DIVE_ITEM_DIST + KEEP_TARGET_THRESHOLD) then
            self.diveitem = nil
            return false
        end
    end
    self.diveitem = FindObj(self.inst, DIVE_ITEM_DIST, FIND_GOLD_TAGS, IsItemTarget)
    return self.diveitem ~= nil
end

local function GetSeekItemPos(self)
    self.seekitem = GetSeekObj(self.inst, self.seekitem, FIND_GOLD_TAGS, IsItemTarget)
    return self.seekitem ~= nil and self.seekitem:GetPosition() or nil
end

local function GetHome(inst)
    return inst.components.knownlocations:GetLocation("home")
end

local function GetPigKing(inst)
    return inst.components.entitytracker:GetEntity("king")
end

local function ShouldPanic(self)
    if self.canpanic then
        if self.inst:GetDistanceSqToPoint(GetHome(self.inst)) < MAX_PANIC_DIST_SQ then
            return true
        end
        self.canpanic = false
    elseif self.inst:GetDistanceSqToPoint(GetHome(self.inst)) < MIN_PANIC_DIST_SQ then
        self.canpanic = true
        return true
    end
    return false
end

local function IsMatchOver(inst)
    if inst.flagmatchover then
        return true
    end
    local king = GetPigKing(inst)
    return king == nil or not king:IsMinigameActive()
end

local function ShouldMatchOverPose(self)
    if self.matchovertime == nil then
        if IsMatchOver(self.inst) then
            self.matchovertime = GetTime()
        end
        return false
    elseif self.matchovertime + 2 > GetTime() then
        return false
    end
    local king = GetPigKing(self.inst)
    if king ~= nil then
        for k, v in pairs(king._minigame_elites) do
            if k ~= self.inst and not (k.sg:HasStateTag("idle") or k.sg:HasStateTag("endpose")) then
                return false
            end
        end
    end
    return true
end

local function GetMatchOverPos(inst)
    return IsMatchOver(inst) and GetHome(inst) or nil
end

function PigEliteBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.sg:HasStateTag("jumping") end, "Standby",
            ActionNode(function() --[[do nothing]] end)),
        WhileNode(function() return self.inst.components.hauntable.panic end, "PanicHaunted",
            ChattyNode(self.inst, "PIG_TALK_PANICHAUNT",
                PanicAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST))),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
            ChattyNode(self.inst, "PIG_TALK_PANICFIRE",
                PanicAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST))),
        ChattyNode(self.inst, "PIG_ELITE_SMACK",
            WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                ParallelNode{
                    ChaseAndAttackAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST),
                    ActionNode(function()
                        self.pickprop = nil
                        self.seekprop = nil
                        self.diveitem = nil
                        self.seekitem = nil
                    end),
                })),
        --Dive for gold
        WhileNode(function() return ShouldDiveItem(self) end, "Dive",
            ActionNode(function()
                self.pickprop = nil
                self.seekprop = nil
                self.inst:PushEvent("diveitem", { item = self.diveitem })
            end)),
        ChattyNode(self.inst, "PIG_ELITE_GOLD",
            ParallelNode{
                LeashAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST, function() return GetSeekItemPos(self) end, DIVE_ITEM_DIST, 0, true),
                ActionNode(function()
                    self.pickprop = nil
                    self.seekprop = nil
                end),
            }),
        --Pick up prop
        WhileNode(function()
                self.diveitem = nil
                self.seekitem = nil
                return ShouldPickProp(self)
            end,
            "PickProp",
            ActionNode(function() self.inst:PushEvent("pickprop", { prop = self.pickprop }) end)),
        LeashAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST, function() return GetSeekPropPos(self) end, PICK_PROP_DIST, 0, true),
        --
        WhileNode(function()
                self.pickprop = nil
                self.seekprop = nil
                return ShouldMatchOverPose(self)
            end,
            "MatchOverPose",
            ParallelNode{
                StandStill(self.inst),
                LoopNode({ ActionNode(function() self.inst:PushEvent("matchover") end) }),
            }),
        LeashAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST, GetMatchOverPos, 0, 0, true),
        --
        WhileNode(function() return not IsMatchOver(self.inst) and ShouldPanic(self) end, "Panic",
            PanicAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST)),
        LeashAndAvoid(self.inst, GetPigKing, AVOID_KING_DIST, GetHome, 0, 0, true),
        Wander(self.inst, GetHome, MAX_WANDER_DIST),
    }, .1)

    self.bt = BT(self.inst, root)
end

function PigEliteBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition(), true)
end

return PigEliteBrain
