require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/wander"

local SEE_FOOD_DIST = 13

local SEE_THREAT_DIST = 3.5
local STOP_RUN_DIST = 6

local EAT_FOOD_DIST = 32
local DUSTOFF_DIST = 14

local STUCK_MAX_TIME = 6
local UNSTUCK_WANDER_DURATION = 4

local SEARCH_ANIM_CHANCE = .35

local NOTAGS = { "INLIMBO" }

local HUNTERPARAMS_NOPLAYER =
{
    tags = { "scarytoprey" },
    notags = { "player", "NOCLICK" },
}

local DustMothBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function AttemptPlaySearchAnim(inst, target)
    local time = GetTime()
    if time - inst._last_played_search_anim_time > TUNING.DUSTMOTH.SEARCH_ANIM_COOLDOWN and math.random() < SEARCH_ANIM_CHANCE then
        inst._last_played_search_anim_time = time

        if target ~= nil and target:IsValid() then
            inst.Transform:SetRotation(inst:GetAngleToPoint(target:GetPosition():Get()))
        end

        inst:PushEvent("dustmothsearch")
    end
end

local function RepairDenAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    if inst._charged and inst.components.homeseeker ~= nil
        and inst.components.homeseeker.home ~= nil and inst.components.homeseeker.home:IsValid()
        and not inst.components.homeseeker.home.components.workable.workable then

        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.REPAIR)
    end
end

local EATFOOD_TAGS = { "dustmothfood" }
local EATFOOD_CANT_TAGS = { "outofreach", "INLIMBO" }
local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") or inst._charged then
        return
    end

    local target = inst.components.inventory:GetItemInSlot(1)
    local attempt_play_search_anim = false

    if target == nil or not target:HasTag("dustmothfood") then
        attempt_play_search_anim = true

        target = FindEntity(inst,
            EAT_FOOD_DIST,
            function(item)
                return item:GetTimeAlive() >= 1 and item:IsOnValidGround()
            end,
            EATFOOD_TAGS,
            EATFOOD_CANT_TAGS
        )
    end

    if target ~= nil then
        if attempt_play_search_anim then
            AttemptPlaySearchAnim(inst, target)
        end

        local ba = BufferedAction(inst, target, ACTIONS.EAT)
        return ba
    end
end

local DUSTOFF_TAGS = { "dustable" }
local function DustOffAction(inst)
    if inst.sg:HasStateTag("busy") or not inst._find_dustables then
        return
    end

    local target = FindEntity(inst, DUSTOFF_DIST, nil, DUSTOFF_TAGS, NOTAGS)

    if target ~= nil then
        AttemptPlaySearchAnim(inst, target)

        -- This is a hack to bring the moth to a certain sg state,
        -- the action is cleared before it is actually performed.
        local ba = BufferedAction(inst, target, ACTIONS.PET)
        ba.distance = target.Physics ~= nil and (target.Physics:GetRadius() + 1) or 1.5
        return ba
    end
end

function DustMothBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage or self.inst.components.burnable:IsBurning() end, "OnFire",
            Panic(self.inst)),

        WhileNode(function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.inventory:GetItemInSlot(1) == nil end, "RunAwayAll",
            RunAway(self.inst, "scarytoprey", SEE_THREAT_DIST, STOP_RUN_DIST)),
        RunAway(self.inst, HUNTERPARAMS_NOPLAYER, SEE_THREAT_DIST, STOP_RUN_DIST),

        WhileNode(function() return self.inst:GetBufferedAction() ~= nil and self.inst._time_spent_stuck >= STUCK_MAX_TIME and not self.inst.sg:HasStateTag("busy") end, "CheckStuck",
            ActionNode(function()
                self.inst._time_spent_stuck = 0
                self.inst._force_unstuck_wander = true
                self.inst:DoTaskInTime(UNSTUCK_WANDER_DURATION, function(inst) inst._force_unstuck_wander = nil end)
                self.inst:ClearBufferedAction()
            end)),
        WhileNode(function() return self.inst._force_unstuck_wander end, "UndoStuck", Wander(self.inst, function() return self.inst:GetPosition() end, 10)),

        DoAction(self.inst, RepairDenAction, "RepairDen"),
        DoAction(self.inst, EatFoodAction, "EatFood"),
        DoAction(self.inst, DustOffAction, "DustOff"),

        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 40),
    }, .25)

    self.bt = BT(self.inst, root)
end

return DustMothBrain
