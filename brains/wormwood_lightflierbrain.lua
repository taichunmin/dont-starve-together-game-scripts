require("behaviours/panic")
local BrainCommon = require("brains/braincommon")

local Wormwood_LightFlierBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function Wormwood_LightFlierBrain:OnStart()
    local root = PriorityNode({
        ParallelNode{
            ActionNode(function()
                self.inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
                self.inst.components.locomotor.directdrive = false
            end),

            PriorityNode({
                EventNode(self.inst, "panic",
                    ParallelNode{
                        Panic(self.inst),
                        WaitNode(6),
                    }),
				BrainCommon.PanicTrigger(self.inst),

                -- Else no need to do anything from here, movement is handled on update from outside sources.
                ActionNode(function()
                    self.inst.components.locomotor.directdrive = true
                end),
            }, .25)
        }
    }, .25)

    self.bt = BT(self.inst, root)
end

return Wormwood_LightFlierBrain
