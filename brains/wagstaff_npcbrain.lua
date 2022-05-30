require "behaviours/standstill"
require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"

local BrainCommon = require "brains/braincommon"

local MAX_WANDER_DIST = 20

local TRADE_DIST = 20

local HUNT_NUM = TUNING.WAGSTAFF_NPC_HUNTS

local function GetTraderFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for i, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then
            return v
        end
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function failexperiment(inst,item)
    if TheWorld.components.moonstormmanager and not item.experimentcomplete then
        TheWorld.components.moonstormmanager:FailExperiment()
    end
end


local function ShouldGoToClue(inst)
    if inst.components.knownlocations:GetLocation("clue") then
--        inst.busy = inst.busy and inst.busy + 1 or 1
        if inst.playerwasnear then
            inst.hunt_count = inst.hunt_count +1
        end

        local pos = inst.components.knownlocations:GetLocation("clue")

        inst.components.knownlocations:ForgetLocation("clue")
        if inst.hunt_count ~= 0 then
            inst:erode(3)
            inst:DoTaskInTime(3,function()
                local pos = pos
                --inst.busy = inst.busy and math.max(inst.busy - 2,0) or nil
                inst.busy = inst.busy and inst.busy > 0 and inst.busy - 1 or nil

                inst.meetingplayer = nil
                inst.Transform:SetPosition(pos.x, pos.y, pos.z)
                if inst.hunt_count and inst.hunt_count == 0 then
                    inst.components.timer:StartTimer("wagstaff_movetime",10 + (math.random()*5))
                end
                if inst.hunt_count >= HUNT_NUM then
                    inst.hunt_stage = "experiment"
                    local static = SpawnPrefab("moonstorm_static")
                    local radius = 1
                    local theta = (inst.Transform:GetRotation() + 90)*DEGREES
                    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                    static.Transform:SetPosition(pos.x+ offset.x, pos.y, pos.z+ offset.z)
                  --  inst:FacePoint(static:GetPosition())
                    inst:DoTaskInTime(0,function()
                        inst:ForceFacePoint(pos.x, pos.y, pos.z)
                    end)
                    inst.static = static
                    inst:ListenForEvent("onremove", function()
                            failexperiment(inst,static)
                        end ,inst.static)
                    inst:ListenForEvent("death", function()
                            failexperiment(inst,static)
                        end ,inst.static)
                end
                inst:erode(1,true)
            end)
        end
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos, nil, .2)
    end
end

local Wagstaff_NPCBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function Wagstaff_NPCBrain:OnStart()
    local in_hunt = WhileNode( function() return self.inst.hunt_stage == "hunt" end, "IsHuntWagstaff",
        PriorityNode{
            IfNode(function() return self.inst.components.knownlocations:GetLocation("clue") end, "Go To Clue",
                DoAction(self.inst, ShouldGoToClue, "Go to clue", true )),
            WhileNode(function() return not self.inst.busy or self.inst.busy < 1 end, "looking around",
                ChattyNode(self.inst, "WAGSTAFF_NPC_MUMBLE_1",
                    StandStill(self.inst))),
            StandStill(self.inst),
        }, .5)

    local root =
        PriorityNode(
        {
            in_hunt,
            ChattyNode(self.inst, "WAGSTAFF_NPC_ATTEMPT_TRADE",
                FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),
            StandStill(self.inst),
        }, .5)

    self.bt = BT(self.inst, root)
end

return Wagstaff_NPCBrain
