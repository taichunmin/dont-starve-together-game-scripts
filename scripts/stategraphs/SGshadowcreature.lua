require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local function canteleport(inst)
    return not (inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("hit")
        or inst.sg:HasStateTag("teleporting") or inst.sg:HasStateTag("noattack")
        or inst.components.health:IsDead())
end

local events =
{
    EventHandler("attacked", function(inst)
        if not (inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("hit") or inst.sg:HasStateTag("noattack") or inst.components.health:IsDead()) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("attack", data.target)
        end
    end),
    EventHandler("teleport_to_sea", function(inst) if canteleport(inst) then inst.sg:GoToState("teleport_to_sea") end end),

    CommonHandlers.OnLocomote(false, true),
}

local function onattackreflected(inst)
	inst.sg.statemem.attackreflected = true
end

local function FinishExtendedSound(inst, soundid)
    inst.SoundEmitter:KillSound("sound_"..tostring(soundid))
    inst.sg.mem.soundcache[soundid] = nil
    if inst.sg.statemem.readytoremove and next(inst.sg.mem.soundcache) == nil then
        inst:Remove()
    end
end

local function PlayExtendedSound(inst, soundname)
    if inst.sg.mem.soundcache == nil then
        inst.sg.mem.soundcache = {}
        inst.sg.mem.soundid = 0
    else
        inst.sg.mem.soundid = inst.sg.mem.soundid + 1
    end
    inst.sg.mem.soundcache[inst.sg.mem.soundid] = true
    inst.SoundEmitter:PlaySound(inst.sounds[soundname], "sound_"..tostring(inst.sg.mem.soundid))
    inst:DoTaskInTime(5, FinishExtendedSound, inst.sg.mem.soundid)
end

local function OnAnimOverRemoveAfterSounds(inst)
    if inst.sg.mem.soundcache == nil or next(inst.sg.mem.soundcache) == nil then
        inst:Remove()
    else
        inst:Hide()
        inst.sg.statemem.readytoremove = true
    end
end

local function TryDropTarget(inst)
	if inst.ShouldKeepTarget then --nightmarecreatures don't drop target
		local target = inst.components.combat.target
		if target and not inst:ShouldKeepTarget(target) then
			inst.components.combat:DropTarget()
			return true
		end
	end
end

local function TryDespawn(inst)
	if inst.sg.mem.forcedespawn or (inst.wantstodespawn and not inst.components.combat:HasTarget()) then
		inst.sg:GoToState("disappear")
		return true
	end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
			local dropped = TryDropTarget(inst)
			if TryDespawn(inst) then
				return
			elseif dropped then
				inst.sg:GoToState("taunt")
				return
			end
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("idle_loop") then
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

		ontimeout = function(inst)
			inst.sg:GoToState("idle")
		end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            PlayExtendedSound(inst, "attack_grunt")
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst) PlayExtendedSound(inst, "attack") end),
			TimeEvent(16*FRAMES, function(inst)
				--The stategraph event handler is delayed, so it won't be
				--accurate for detecting attacks due to damage reflection
				inst:ListenForEvent("attacked", onattackreflected)
				inst.components.combat:DoAttack(inst.sg.statemem.target)
				inst:RemoveEventCallback("attacked", onattackreflected)
			end),
			FrameEvent(17, function(inst)
				if inst.sg.statemem.attackreflected and not inst.components.health:IsDead() then
					inst.sg:GoToState("hit")
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if math.random() < .333 then
					TryDropTarget(inst)
					inst.forceretarget = true --V2C: try to keep legacy behaviour; it used SetTarget(nil) here, which would always result in a retarget
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("disappear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
				local x0, y0, z0 = inst.Transform:GetWorldPosition()
				for k = 1, 4 --[[# of attempts]] do
					local x = x0 + math.random() * 20 - 10
					local z = z0 + math.random() * 20 - 10
					if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
						inst.Physics:Teleport(x, 0, z)
                        break
                    end
                end

                inst.sg:GoToState("appear")
            end),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            PlayExtendedSound(inst, "taunt")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "appear",
        tags = { "busy" },

        onenter = function(inst)
			TryDropTarget(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.Physics:Stop()
            PlayExtendedSound(inst, "appear")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            PlayExtendedSound(inst, "death")
            inst.AnimState:PlayAnimation("disappear")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
            inst:AddTag("NOCLICK")
            inst.persists = false
        end,

        events =
        {
            EventHandler("animover", OnAnimOverRemoveAfterSounds),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
        end
    },

    State{
        name = "disappear",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            PlayExtendedSound(inst, "death")
            inst.AnimState:PlayAnimation("disappear")
            inst.Physics:Stop()
            inst:AddTag("NOCLICK")
            inst.persists = false
        end,

        events =
        {
            EventHandler("animover", OnAnimOverRemoveAfterSounds),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
        end,
    },

    State{
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "teleport_to_sea",
        tags = { "busy", "noattack", "teleporting" },
        onenter = function(inst, playanim)

                local x,y,z = inst.Transform:GetWorldPosition()
                local fx = SpawnPrefab("shadow_teleport_out")
                fx.Transform:SetPosition(x,y,z)

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt", false)
            inst.AnimState:PushAnimation("disappear", false)
        end,

        timeline =
        {
            TimeEvent(40*FRAMES, function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
				--print("TELEPORT OUT TERRORBEAK")
                local fx = SpawnPrefab("shadow_teleport_out")
                fx.Transform:SetPosition(x,y,z)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
				--print("EXCHANGE TERROR BEAK")
                inst:ExchangeWithOceanTerror()
                inst:Remove()
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
	walktimeline =
	{
		FrameEvent(0, function(inst)
			local dropped = TryDropTarget(inst)
			if TryDespawn(inst) then
				return
			elseif dropped then
				inst.sg:GoToState("taunt")
			end
		end),
	},
})

return StateGraph("shadowcreature", states, events, "appear", actionhandlers)
