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

local function GetTraderFn(inst)
    if inst.components.trader == nil then
        return nil
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for i, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then
            return v
        end
    end
end

local function KeepTraderFn(inst, target)
    if inst.components.trader == nil then
        return false
    end

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

                if inst.hunt_count >= ((TheWorld.components.moonstormmanager and TheWorld.components.moonstormmanager:GetCelestialChampionsKilled() or 0) > 0 and 1 or TUNING.WAGSTAFF_NPC_HUNTS) then
                    inst.hunt_stage = "experiment"
                    local static = SpawnPrefab("moonstorm_static")
                    local radius = 1
                    local theta = (inst.Transform:GetRotation() + 90)*DEGREES
                    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                    static.Transform:SetPosition(pos.x+ offset.x, pos.y, pos.z+ offset.z)
                  --  inst:FacePoint(static:GetPosition())
                    inst:DoTaskInTime(0,function()
                        inst:ForceFacePoint(pos.x+ offset.x, pos.y, pos.z+ offset.z)
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

local function DoMachineHint(inst)
    inst.components.talker:Chatter("WAGSTAFF_GOTTOHINT", math.random(#STRINGS.WAGSTAFF_GOTTOHINT), nil, nil, CHATPRIORITIES.LOW)
end

local function ShouldGoToMachine(inst)
    local machinepos = inst.components.knownlocations:GetLocation("machine")

    if machinepos ~= nil then
        inst:DoTaskInTime(1.5, DoMachineHint)
        inst:DoTaskInTime(3.5, inst.erode, 2, nil, true)

        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, machinepos, nil, .2)
    end
end

local function DoJunkyardHint(inst)
    inst.components.talker:Chatter("WAGSTAFF_JUNK_YARD_OCCUPIED", 1, nil, nil, CHATPRIORITIES.HIGH)
end

local function ShouldGoToJunkYard(inst)
    local junkpos = inst.components.knownlocations:GetLocation("junk")

    if junkpos ~= nil then
        inst:DoTaskInTime(4, DoJunkyardHint)
        inst:DoTaskInTime(6.5, inst.erode, 2, nil, true)
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, junkpos, nil, .2)
    end
end

local Wagstaff_NPCBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function Wagstaff_NPCBrain:OnStart()
    local in_junk = WhileNode( function() return self.inst.components.knownlocations:GetLocation("junk") end, "IsJunkHintingWagstaff",
        PriorityNode{            
            IfNode(function() return self.inst.components.knownlocations:GetLocation("junk") end, "Go To Clue",
                DoAction(self.inst, ShouldGoToJunkYard, "Go to junkyard", true )),
            StandStill(self.inst),
        }, .5)

    local in_hint = WhileNode( function() return self.inst.components.knownlocations:GetLocation("machine") end, "IsHintingWagstaff",
        PriorityNode{            
            IfNode(function() return self.inst.components.knownlocations:GetLocation("machine") end, "Go To Clue",
                DoAction(self.inst, ShouldGoToMachine, "Go to machine", true )),
            StandStill(self.inst),
        }, .5)

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
            in_junk,
            in_hint,
            in_hunt,
            ChattyNode(self.inst, "WAGSTAFF_NPC_ATTEMPT_TRADE",
                FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),
            StandStill(self.inst),
        }, .5)

    self.bt = BT(self.inst, root)
end

return Wagstaff_NPCBrain
