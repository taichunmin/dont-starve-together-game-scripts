require("stategraphs/commonstates")

--local MUST_TAGS =  {"_combat"}
--local CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "invisible", "notarget", "noattack", "lunarthrall_plant", "lunarthrall_plant_end" }

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "invisible", "notarget", "wall", "noattack", "lunarthrall_plant", "lunarthrall_plant_end" }
local MAX_SIDE_TOSS_STR = 0.8

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
    inst.components.combat.ignorehitrange = true
    local x, y, z = inst.Transform:GetWorldPosition()
    local rot0, x0, z0
    if dist ~= 0 then
        if dist > 0 and ((mult ~= nil and mult > 1) or (heavymult ~= nil and heavymult > 1)) then
            x0, z0 = x, z
        end
        rot0 = inst.Transform:GetRotation() * DEGREES
        x = x + dist * math.cos(rot0)
        z = z - dist * math.sin(rot0)
    end
    for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
        if v ~= inst and
            not (targets ~= nil and targets[v]) and
            v:IsValid() and not v:IsInLimbo()
            and not (v.components.health ~= nil and v.components.health:IsDead())
            then
            local range = radius + v:GetPhysicsRadius(0)
            if v:GetDistanceSqToPoint(x, y, z) < range * range and inst.components.combat:CanTarget(v) then
                inst.components.combat:DoAttack(v)
                if mult ~= nil then
                    local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
                    if strengthmult > MAX_SIDE_TOSS_STR and x0 ~= nil then
                        --Don't toss as far to the side for frontal attacks
                        local rot1 = (v:GetAngleToPoint(x0, 0, z0) + 180) * DEGREES
                        local k = math.max(0, math.cos(math.min(PI, DiffAngleRad(rot1, rot0) * 2)))
                        strengthmult = MAX_SIDE_TOSS_STR + (strengthmult - MAX_SIDE_TOSS_STR) * k * k
                    end
                    v:PushEvent("knockback", { knocker = inst, radius = radius + dist + 3, strengthmult = strengthmult, forcelanded = forcelanded })
                end
                if targets ~= nil then
                    targets[v] = true
                end
            end
        end
    end
    inst.components.combat.ignorehitrange = false
end

local actionhandlers =
{
}

local events =
{
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and 
            not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst:customPlayAnimation("idle_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("spawn_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/spawn")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    

    State{
        name = "hit",
        tags = {"busy","nointerrupt"},

        onenter = function(inst)
			inst.SoundEmitter:PlaySound("rifts/lunarthrall/hit")
            if inst.tired then
				if not inst.SoundEmitter:PlayingSound("wakeLP") then
					inst.SoundEmitter:PlaySound("rifts/lunarthrall/rustle_wakeup_LP", "wakeLP")
					inst:customPlayAnimation("tired_hit_"..inst.targetsize)
				end
            else
				--inst:customPlayAnimation("hit_"..inst.targetsize)
				inst.sg:GoToState("attack")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                if inst.tired then
                    if inst.wake then
						inst.sg.statemem.tired_wake = true
                        inst.sg:GoToState("tired_wake")
                    else
                        inst.sg:GoToState("tired")
                    end
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if not inst.sg.statemem.tired_wake then
				inst.SoundEmitter:KillSound("wakeLP")
			end
        end,
    },

	State{
		name = "attack",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("atk_"..inst.targetsize)
			inst.SoundEmitter:PlaySound("rifts/lunarthrall/attack")
        end,

        timeline=
        {
			FrameEvent(4, function(inst)
				inst.sg.statemem.targets = {}
				DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
			end),
			FrameEvent(5, function(inst)
				DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
			end),
			FrameEvent(6, function(inst)
				DoAOEAttack(inst, 0, 4, 1, 1, false, inst.sg.statemem.targets)
			end),
        },

        events =
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst:customPlayAnimation("death_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/death")
        end,
    }, 

    State{
        name = "tired_pre",
        tags = {"busy","tired"},

        onenter = function(inst)
            inst.tired = true
            inst:RemoveTag("retaliates")
            inst:customPlayAnimation("tired_pre_"..inst.targetsize)
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/tired_pre")
        end,

        onexit = function(inst)
            inst:AddTag("retaliates")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("tired") end end),
        },
    },

    State{
        name = "tired",
        tags = {"idle","tired"},

        onenter = function(inst)
            inst:RemoveTag("retaliates")
            inst.tired = true
            inst:customPlayAnimation("tired_loop_"..inst.targetsize)
        end,

        onexit = function(inst)
            inst:AddTag("retaliates")
        end,

        events =
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("tired") end end),
        },
    },

    State{
        name = "tired_wake",
        tags = {"idle","tried","wake"},

        onenter = function(inst)
            inst:RemoveTag("retaliates")
			if not inst.SoundEmitter:PlayingSound("wakeLP") then
				inst.SoundEmitter:PlaySound("rifts/lunarthrall/rustle_wakeup_LP", "wakeLP")
			end
            inst.wake = true
            inst:customPlayAnimation("tired_wakeup_loop_"..inst.targetsize)
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                if inst.AnimState:AnimDone() then 
                    inst.sg.statemem.tired_wake = true
                    inst.sg:GoToState("tired_wake") 
                end 
            end),
        },

        onexit = function(inst)
            inst:AddTag("retaliates")
            if not inst.sg.statemem.tired_wake then
                inst.SoundEmitter:KillSound("wakeLP")                
            end
        end,
    },

    State{
        name = "tired_pst",
        tags = {"busy"},

        onenter = function(inst)
            inst:RemoveTag("retaliates")
            inst:customPlayAnimation("tired_pst_"..inst.targetsize)
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("wakeLP")
            inst:AddTag("retaliates")
            inst.wake = nil
            inst.tired = nil
            inst.vinelimit = TUNING.LUNARTHRALL_PLANT_VINE_LIMIT
        end,

        events =
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("attack") end end),
        },
    },


    State{
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = function(inst)
            inst:customPlayAnimation("frozen_"..inst.targetsize, true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
			inst.back.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

            if inst.components.freezable == nil then
				inst.sg:GoToState("hit")
            elseif inst.components.freezable:IsThawing() then
				inst.sg.statemem.thawing = true
				inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
				inst.sg:GoToState("hit")
			else
				for i, v in ipairs(inst.vines) do
					if not v.components.health:IsDead() then
						v.sg:GoToState("sync_frozen")
					end
				end
            end
        end,

        events =
        {
            EventHandler("unfreeze", function(inst) inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle") end),
			EventHandler("onthaw", function(inst)
				inst.sg.statemem.thawing = true
				inst.sg:GoToState("thaw")
			end),
        },

        onexit = function(inst)
			if not inst.sg.statemem.thawing then
				inst.AnimState:ClearOverrideSymbol("swap_frozen")
				inst.back.AnimState:ClearOverrideSymbol("swap_frozen")
				for i, v in ipairs(inst.vines) do
					if not v.components.health:IsDead() then
						v.sg:GoToState("hit")
					end
				end
				inst.components.freezable:Unfreeze()
			end
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing" },

        onenter = function(inst)
            inst:customPlayAnimation("frozen_loop_pst_"..inst.targetsize, true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
			inst.back.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

            if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
				inst.sg:GoToState("hit")
			else
				for i, v in ipairs(inst.vines) do
					if not v.components.health:IsDead() then
						v.sg.statemem.thawing = true
						v.sg:GoToState("sync_thaw")
					end
				end
            end
        end,

        events =
        {
            EventHandler("unfreeze", function(inst) inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle") end ),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
			inst.back.AnimState:ClearOverrideSymbol("swap_frozen")
			for i, v in ipairs(inst.vines) do
				if not v.components.health:IsDead() then
					v.sg:GoToState("hit")
				end
			end
			inst.components.freezable:Unfreeze()
        end,
    },
}


return StateGraph("lunarthrall_plant", states, events, "idle", actionhandlers)
