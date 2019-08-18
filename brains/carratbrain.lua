require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local AVOID_PLAYER_DIST = 3
local AVOID_PLAYER_DIST_SQ = AVOID_PLAYER_DIST * AVOID_PLAYER_DIST
local AVOID_PLAYER_STOP = 5

local SEE_BAIT_DIST = 20
local MAX_WANDER_DIST = 20

local CarratBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function edible(inst, item)
    return inst.components.eater:CanEat(item) and item.components.bait and not item:HasTag("planted") and
            not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) and
            item:IsOnPassablePoint() and
            item:GetCurrentPlatform() == inst:GetCurrentPlatform()
end

local function eat_food_action(inst)
    if inst == nil or not inst:IsValid() then
        return nil
    end

    local px, py, pz = inst.Transform:GetWorldPosition()

    local ents_nearby = TheSim:FindEntities(px, py, pz, SEE_BAIT_DIST + AVOID_PLAYER_DIST)

    local foods = {}
    local scaries = {}
    for _, ent in ipairs(ents_nearby) do
        if ent ~= inst and ent.entity:IsVisible() then
            if ent:HasTag("scarytoprey") then
                table.insert(scaries, ent)
            elseif edible(inst, ent) then
                table.insert(foods, ent)
            end
        end
    end

    if #foods == 0 then
        return nil
    end

    local target = nil
    if #scaries == 0 then
        target = foods[1]
    else
        -- We have at least 1 food and at least 1 scary thing in range.
        -- Try to find a food that doesn't come within AVOID_PLAYER_DIST of a scary thing.
        for fi = 1, #foods do
            local food = foods[fi]
            local scary_thing_nearby = false

            for si = 1, #scaries do
                local scary_thing = scaries[si]
                if scary_thing ~= nil and scary_thing.Transform ~= nil then
                    local sq_distance = food:GetDistanceSqToPoint(scary_thing.Transform:GetWorldPosition())
                    if sq_distance < AVOID_PLAYER_DIST_SQ then
                        scary_thing_nearby = true
                        break
                    end
                end
            end

            if not scary_thing_nearby then
                target = food
                break
            end
        end
    end

    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end

function CarratBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function()
            return self.inst.components.hauntable and self.inst.components.hauntable.panic
        end, "PanicHaunted", Panic(self.inst)),

        WhileNode( function()
            return self.inst.components.health.takingfiredamage or self.inst.components.burnable:IsBurning()
        end, "OnFire", Panic(self.inst)),

        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),

        DoAction(self.inst, eat_food_action),

        Wander(self.inst, nil, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return CarratBrain
