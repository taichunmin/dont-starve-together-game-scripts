require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/follow"
require "behaviours/standstill"

local BrainCommon = require "brains/braincommon"

local SEE_PLAYER_DIST     = 5
local SEE_FOOD_DIST       = 5
local MAX_WANDER_DIST     = 15
local MAX_CHASE_TIME      = 25
local MAX_CHASE_DIST      = 40
local RUN_AWAY_DIST       = 5
local STOP_RUN_AWAY_DIST  = 8

local MIN_FOLLOW_DIST     = 3
local MAX_FOLLOW_DIST     = 15

local FACETIME_BASE = 2
local FACETIME_RAND = 2

local TRADE_DIST = 20

local FIND_ARMORY_RANGE     = 15

local MIN_FOLLOW_TARGET_DIST     = 5
local DEFAULT_FOLLOW_TARGET_DIST = 8
local MAX_FOLLOW_TARGET_DIST     = 15

local MermBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-----------------------------------------------------------------------------------------------

local ARMORY_ONEOF_TAGS = { "merm_armory", "merm_armory_upgraded" }

local ARMOR_CANT_TAGS  = { "INLIMBO" }
local ARMOR_ONEOF_TAGS = { "mermarmorhat", "mermarmorupgradedhat" }

local function IsHeadEquip(item)
    return item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD
end

local function NeedsArmor(inst)
    local armor = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil

    if armor ~= nil then
        return false

    elseif inst.components.inventory ~= nil then
        armor = inst.components.inventory:FindItem(IsHeadEquip)

        if armor ~= nil then
            return false
        end
    end

    return true
end

local function GetClosestArmory(inst, dist)
    dist = dist or FIND_ARMORY_RANGE

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, dist, nil, nil, ARMORY_ONEOF_TAGS)

    if #ents <= 0 then
        return nil
    end

    local armory = nil

    for _, ent in ipairs(ents) do
        if ent:CanSupply() then
            if ent:HasTag("merm_armory_upgraded") then
                return ent -- High priority.
            end

            if armory == nil then
                armory = ent
            end
        end
    end

    return armory
end

local function GetClosestArmoryPosition(inst, dist)
    local armory = GetClosestArmory(inst, dist)

    if armory ~= nil then
        local distance = armory:GetPhysicsRadius(0)

        return inst:GetPositionAdjacentTo(armory, distance)
    end
end

local function NeedsArmorAndFoundArmor(inst)
    if not NeedsArmor(inst) then
        return false
    end

    return GetClosestArmory(inst) ~= nil
end

local function CollectArmor(inst)
    if not NeedsArmor(inst) then
        return
    end

    local armory = GetClosestArmory(inst, 2.5)

    if armory ~= nil then
        inst:PushEvent("merm_use_building", { target = armory })
    end
end

local function PickupArmor(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    if NeedsArmor(inst) then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, 0, z, FIND_ARMORY_RANGE, nil, ARMOR_CANT_TAGS, ARMOR_ONEOF_TAGS)

        if #ents <= 0 then
            return nil
        end

        local armor = nil

        for _, ent in ipairs(ents) do
            if ent:HasTag("mermarmorupgradedhat") then
                return BufferedAction(inst, ent, ACTIONS.PICKUP) -- High priority.
            end

            armor = ent
        end

        return armor ~= nil and BufferedAction(inst, armor, ACTIONS.PICKUP) or nil
    end
end

---------------------------------------------------------------------------------------------------

local function GetHealerFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for _, v in ipairs(players) do
        if (v == inst.components.follower:GetLeader() or v:HasTag("merm")) and inst.components.combat.target ~= v then
            local act = v:GetBufferedAction()
            if act
            and act.target == inst
            and act.action == ACTIONS.HEAL then
                return v
            end
        end
    end
end

local function KeepHealerFn(inst, target)
    if (target == inst.components.follower:GetLeader() or target:HasTag("merm")) and inst.components.combat.target ~= target then
        local act = target:GetBufferedAction()
        if act
        and act.target == inst
        and act.action == ACTIONS.HEAL then
            return true
        end
    end
end


local function GetTraderFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for _, player in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(player) then
            return player
        end
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetFaceTargetFn(inst)
    if inst.components.timer:TimerExists("dontfacetime") then
        return nil
    end
    local shouldface = inst.components.follower.leader or FindClosestPlayerToInst(inst, SEE_PLAYER_DIST, true)
    if shouldface and not inst.components.timer:TimerExists("facetime") then
        inst.components.timer:StartTimer("facetime", FACETIME_BASE + math.random()*FACETIME_RAND)
    end
    return shouldface
end

local function KeepFaceTargetFn(inst, target)
    if inst.components.timer:TimerExists("dontfacetime") then
        return nil
    end
    local keepface = (inst.components.follower.leader and inst.components.follower.leader == target)
        or (target:IsValid() and inst:IsNear(target, SEE_PLAYER_DIST))
    if not keepface then
        inst.components.timer:StopTimer("facetime")
    end
    return keepface
end

------------------------------------------------------------------------------
local EATFOOD_MUST_TAGS = { "edible_VEGGIE" }
local EATFOOD_CANT_TAGS = { "INLIMBO" }
local SCARY_TAGS = { "scarytoprey" }

local function EatFoodAction(inst)
    local target = nil

    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        target = inst.components.inventory:FindItem(function(item) return item:HasTag("moonglass_piece") or inst.components.eater:CanEat(item) end)
    end

    if target == nil and inst.components.follower.leader == nil then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item)
            return inst.components.eater ~= nil and inst.components.eater:CanEat(item)
        end, EATFOOD_MUST_TAGS, EATFOOD_CANT_TAGS)
        --check for scary things near the food
        if target ~= nil and (GetClosestInstWithTag(SCARY_TAGS, target, SEE_PLAYER_DIST) ~= nil or not target:IsOnValidGround()) then  -- NOTE this ValidGround check should be removed if merms start swimming
            target = nil
        end
    end
    if target ~= nil then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return target.components.inventoryitem == nil
                                    or target.components.inventoryitem.owner == nil
                                    or target.components.inventoryitem.owner == inst end
        return act
    end
end

local function GetNoLeaderHomePos(inst)
    if inst.components.follower ~= nil and inst.components.follower.leader ~= nil then
        return nil
    else
        return inst.components.knownlocations:GetLocation("home")
    end
end

local function TargetFollowDistFn(inst)
    local loyalty = inst.components.follower ~= nil and inst.components.follower:GetLoyaltyPercent() or 0.5
    local boatmod = inst:GetCurrentPlatform() ~= nil and 0.2 or 1.0
    -- As loyalty rises the further out the follower will potentially stay back.
    -- If on a boat lower max range.
    -- Randomize the range from min to max with the bias modulation.
    return (MAX_FOLLOW_DIST - MIN_FOLLOW_DIST) * (1.0 - loyalty) * boatmod * math.random() + MIN_FOLLOW_DIST
end

local function TargetFollowTargetDistFn(inst)
    local target = inst.components.target

    if target == nil or target.compoponents.combat == nil then
        return DEFAULT_FOLLOW_TARGET_DIST
    end

    return math.max(math.sqrt(target.compoponents.combat:CalcAttackRangeSq()) + MIN_FOLLOW_TARGET_DIST, DEFAULT_FOLLOW_TARGET_DIST)
end


-----------------------------------------------

local OFFERINGPOT_MUST_TAGS = { "offering_pot" }

local function shouldanswercall(inst)
    if inst:HasTag("lunarminion") or inst:HasTag("shadowminion") or inst.components.follower.leader ~= nil then
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local pots = TheSim:FindEntities(x, 0, z, 30, OFFERINGPOT_MUST_TAGS)

    if #pots <= 0 then
        return false
    end

    for _, pot in ipairs(pots) do
        if pot.merm_caller ~= nil and pot.merm_caller:IsValid() and pot.components.container ~= nil and not pot.components.container:IsEmpty() then
            inst.answerpotcall = pot

            return true
        end
    end
end

local function Getcalledofferingpot(inst)
    if inst.answerpotcall ~= nil and inst.answerpotcall:IsValid() and inst.answerpotcall.merm_caller ~= nil then
        local distance = inst.answerpotcall:GetPhysicsRadius(0)

        return inst:GetPositionAdjacentTo(inst.answerpotcall, distance)
    end
end

local function answercall(inst)
    if inst.answerpotcall ~= nil and inst.answerpotcall:IsValid() then
        inst.answerpotcall:AnswerCall(inst)
    end
end

-------------------------------------------

function MermBrain:OnStart()
    local NODES = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),

        ChattyNode(self.inst, "MERM_TALK_GET_HEALED",
            FaceEntity(self.inst, GetHealerFn, KeepHealerFn)
        ),

        DoAction(self.inst, PickupArmor, "collect armor", true ),

        IfNode(function() return NeedsArmorAndFoundArmor(self.inst) end, "needs armor",
            PriorityNode({
                Leash(self.inst, GetClosestArmoryPosition , 2.1, 2, true),
                DoAction(self.inst, CollectArmor, "collect armor", true ),
            }, 0.25)),

        WhileNode(function() return self.inst:ShouldWaitForHelp() end, "WaitingForHelp",
            PriorityNode({
                Follow(self.inst, function() return self.inst.components.combat.target end, MIN_FOLLOW_TARGET_DIST, TargetFollowTargetDistFn, MAX_FOLLOW_TARGET_DIST),
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
                ChattyNode(self.inst, "MERM_TALK_NEED_HEAL",
                    StandStill(self.inst)
                ),
            }, .25)
        ),

        WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
            ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))
        ),

        WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
        ),

        WhileNode(function()
                if not self.inst.king or (not self.inst.king:IsValid() or (self.inst.king.components.health and self.inst.king.components.health:IsDead())) then
                    self.inst.return_to_king = false
                    if self.inst.king then
                        self.inst.king.OnGuardDeath(self.inst)
                    end
                    self.inst.king = nil
                end

                return self.inst.return_to_king
            end, "ShouldGoToThrone",
            PriorityNode({
                Leash(self.inst, function() return self.inst.king:GetPosition() end,
                2, 2, true),
                IfNode(function() return true end, "IsThroneValid",
                    ActionNode(function()
                        local fx = SpawnPrefab("merm_spawn_fx")
                        fx.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
                        self.inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/buff") -- Splash sound
                        self.inst:Remove()
                    end)
                ),
            }, .25)),

        BrainCommon.NodeAssistLeaderDoAction(self, {
            action = "CHOP", -- Required.
            chatterstring = "MERM_TALK_HELP_CHOP_WOOD",
        }),

        BrainCommon.NodeAssistLeaderDoAction(self, {
            action = "MINE", -- Required.
            chatterstring = "MERM_TALK_HELP_MINE_ROCK",
        }),

        IfNode(function() return shouldanswercall(self.inst) end, "answering call",
            PriorityNode({
                Leash(self.inst, Getcalledofferingpot , 2.1, 2, true),
                DoAction(self.inst, answercall, "answe call", true ),
            }, 0.25)),

        ChattyNode(self.inst, "MERM_TALK_FIND_FOOD", -- TODO(JBK): MERM_TALK_ATTEMPT_TRADE
            FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),

        ChattyNode(self.inst, "MERM_TALK_FIND_FOOD",
            DoAction(self.inst, EatFoodAction, "Eat Food")),

        ChattyNode(self.inst, "MERM_TALK_FOLLOWWILSON",
            Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TargetFollowDistFn, MAX_FOLLOW_DIST, nil, true)),

        IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader",
            ChattyNode(self.inst, "MERM_TALK_FOLLOWWILSON",
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn ))),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST),
    }, .25)

    local root = PriorityNode({
        WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "pause for jump", NODES)
    }, .25)

    self.bt = BT(self.inst, root)
end

return MermBrain
