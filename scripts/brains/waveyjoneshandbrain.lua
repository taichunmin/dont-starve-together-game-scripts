require "behaviours/wander"

local MAX_WANDER_DIST =0.5


local WaveyJonesHand = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function rotatorcheck(ent)
    if ent.components.boatrotator and ent.sg and  ent.sg.mem and  ent.sg.mem.direction and ent.sg.mem.direction == 0 then
        return true
    end
end

local function mastcheck(ent)
    if ent.components.mast and ent:HasTag("saillowered") and not ent:HasTag("sail_transitioning") then
        return true
    end
end

local function anchorcheck(ent)
    if ent.components.anchor and ent:HasTag("anchor_lowered") and not ent:HasTag("anchor_transitioning") then
        return true
    end
end

local function patchcheck(ent)
    if ent.components.boatleak and ent:HasTag("boat_repaired_patch") then
        return true
    end
end

local function firecheck(ent)
    if ent:HasTag("fire") then
        return true
    end
end

local function fuelcheck(ent)
    if ent.components.fueled and ent.components.fueled:GetPercent() > 0 and ent.components.fueled.canbespecialextinguished then
        return true
    end
end

local function getboatsanity(boat)
    local x,y,z = boat.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x,y,z,boat.components.hull:GetRadius(),true)
    local sanity = 1
    for i, player in ipairs(players)do
        if player.components.sanity and player.components.sanity:GetPercent() < sanity then
            sanity = player.components.sanity:GetPercent()
        end
    end
    return sanity
end

local DOTINKER_CAN_HAVE = {"boat_repaired_patch", "structure" }
local function Dotinker(inst)
    if  inst.components.timer and inst.components.timer:TimerExists("reactiondelay") then
        return nil
    end

    local platform = inst:GetCurrentPlatform()
    local target = nil
    if platform and platform.components.hull then
        local x,y,z = platform.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, platform.components.hull:GetRadius(),nil,nil, DOTINKER_CAN_HAVE)

        if #ents > 0 then
            for i=#ents,1,-1 do

                local ent = ents[i]
                local keep = false

                if mastcheck(ent) or anchorcheck(ent) or patchcheck(ent) or firecheck(ent) or fuelcheck(ent) or rotatorcheck(ent) then
                    keep = true
                end

                if TheWorld:checkwaveyjonestarget(ent) and keep == true then
                    keep = false
                end
                if not keep then
                    table.remove(ents,i)
                end
            end
        end
        if #ents > 0 then
            local shortest = {}
            for i,ent in ipairs(ents)do
                local dist = inst:GetDistanceSqToInst(ent)
                if shortest.dist == nil or shortest.dist > dist then
                    shortest = {dist = dist, id = i}
                end
            end
            if shortest.id then
                target = ents[shortest.id] -- math.random(1,#ents)
            end
        end
    end
    if target then
        inst.waveyjonestarget = target
        TheWorld:reservewaveyjonestarget(inst.waveyjonestarget)
        local sanity = getboatsanity(platform)

        if patchcheck(target) and sanity <= 0.25 then
            return BufferedAction(inst, target, ACTIONS.UNPATCH)
        end
        if anchorcheck(target) then
            return BufferedAction(inst, target, ACTIONS.RAISE_ANCHOR)
        end
        if rotatorcheck(target) then
            if math.random() < 0.5 then
                return BufferedAction(inst, target, ACTIONS.ROTATE_BOAT_CLOCKWISE)
            else
                return BufferedAction(inst, target, ACTIONS.ROTATE_BOAT_COUNTERCLOCKWISE)
            end
        end
        if mastcheck(target) then
            return BufferedAction(inst, target, ACTIONS.RAISE_SAIL)
        end
        if firecheck(target) or fuelcheck(target) and sanity <= 0.5 then
            return BufferedAction(inst, target, ACTIONS.EXTINGUISH)
        end
    end
end

local wandertimes = {
    minwalktime = 0.5,
    randwalktime = 0,
    minwaittime = 3,
    randwaittime = 5,
}

local function getdirectionFn(inst)
    if inst.arm then
        local dir = inst.arm.Transform:GetRotation()
        dir = dir + math.random(60) - 30
        return dir * DEGREES
    end
end

function WaveyJonesHand:OnStart()
    local root = PriorityNode(
    {
        IfNode( function() return not self.inst.sg:HasStateTag("trapped") end, "not trapped",
            PriorityNode({
                DoAction(self.inst, Dotinker, "tinker", true ),
                StandStill(self.inst),
            }, .25)),
    }, .25)
    self.bt = BT(self.inst, root)
end

return WaveyJonesHand
