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

local function canattack(inst)
    return not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead())
end

local events =
{
    EventHandler("boatteleport", function(inst, data)
        if canteleport(inst) then
            inst.sg:GoToState("boatteleport", data ~= nil and data.force_random_angle_on_boat or nil)
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst, data)
        if canattack(inst) then
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("teleport_to_land", function(inst)
        if canteleport(inst) then
            inst.sg:GoToState("teleport_to_land")
        end
    end),

    CommonHandlers.OnLocomote(false, true),
}

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

local function SetRippleScale(inst, scale)
    scale = math.max(0.01, scale) -- hack to avoid mouse always detected as hovering this creature when holding ocean-targeting equipment (oars, etc)
    inst._ripples.Transform:SetScale(scale, scale, scale)
end

local function TryDropTarget(inst)
	local target = inst.components.combat.target
	if target and not inst:ShouldKeepTarget(target) then
		inst.components.combat:DropTarget()
		return true
	end
end

local function TryDespawn(inst)
	if inst.sg.mem.forcedespawn or (inst.wantstodespawn and not inst.components.combat:HasTarget()) then
		inst.sg:GoToState("disappear")
		return true
	end
end

local TELEPORT_ANGLE_VARIANCE = PI/4
local IN_OCEAN_TELEPORT_RADIUS = 6

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
            TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if math.random() < .333 then
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "boatteleport",
        -- tags = { "busy", "hit", "teleporting" },
        tags = { "busy", "teleporting" },

        onenter = function(inst, force_random_angle_on_boat)
            inst.sg.statemem.force_random_angle_on_boat = force_random_angle_on_boat

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("disappear")

            SetRippleScale(inst, 1)
        end,

        onupdate = function(inst)
            SetRippleScale(inst, 1 - math.clamp((inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()) * 2, 0, 1))
        end,

        onexit = function(inst)
            SetRippleScale(inst, 0)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                local remove_inst = false

                local target = inst.components.combat.target
                local boat = nil

                local tx, ty, tz

                if target ~= nil then
                    tx, ty, tz = target.Transform:GetWorldPosition()
                    local new_boat = target:GetCurrentPlatform()

                    if new_boat ~= nil then
                        boat = new_boat
                    elseif math.random() < 0.333 then
                        boat = inst._current_boat
                    end
                else
                    if math.random() < 0.333 then
                        boat = inst._current_boat
                    end
                end

                if boat ~= nil and boat:IsValid() then
                    if boat ~= inst._current_boat then
                        inst._attach_to_boat_fn(inst, boat)
                    end
                    local bx, by, bz = boat.Transform:GetWorldPosition()

                    local radius = boat.components.walkableplatform.platform_radius + TUNING.OCEANHORROR.ATTACH_OFFSET_PADDING
                    local theta = not inst.sg.statemem.force_random_angle_on_boat and target ~= nil
                        and (math.atan2(tz - bz, tx - bx) - (TELEPORT_ANGLE_VARIANCE * 0.5) + math.random() * TELEPORT_ANGLE_VARIANCE)
                        or (math.random() * TWOPI)

                    inst.Transform:SetPosition(math.cos(theta) * radius, 0, math.sin(theta) * radius)
                else
                    inst._detach_from_boat_fn(inst)

                    local currentpos = inst:GetPosition()
                    local offset = FindSwimmableOffset(currentpos, math.random() * TWOPI, IN_OCEAN_TELEPORT_RADIUS, 8)
                    if offset ~= nil then
                        inst.Transform:SetPosition(currentpos.x + offset.x, 0, currentpos.z + offset.z)
                    else
                        remove_inst = true
                    end
                end

                if remove_inst then
                    inst:Remove()
                else
                    inst.sg:GoToState("appear")
                end
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
        tags = { "busy", "teleporting", "appearing" },

        onenter = function(inst)
			TryDropTarget(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.Physics:Stop()
            PlayExtendedSound(inst, "appear")

            SetRippleScale(inst, 0)
        end,

        onupdate = function(inst)
            SetRippleScale(inst, math.clamp((inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()) * 2, 0, 1))
        end,

        onexit = function(inst)
            SetRippleScale(inst, 1)
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

            SetRippleScale(inst, 1)
        end,

        onupdate = function(inst)
            SetRippleScale(inst, 1 - math.clamp((inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength()) * 2, 0, 1))
        end,

        events =
        {
            EventHandler("animover", OnAnimOverRemoveAfterSounds),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
            SetRippleScale(inst, 0)
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
        name = "teleport_to_land",
        tags = { "busy", "noattack", "teleporting" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt", false)
            inst.AnimState:PushAnimation("disappear", false)

        end,

        timeline =
        {
            TimeEvent(42*FRAMES, function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
                local fx = SpawnPrefab("shadow_teleport_out")
                fx.Transform:SetPosition(x,y,z)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:ExchangeWithTerrorBeak()
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

return StateGraph("oceanshadowcreature", states, events, "appear", actionhandlers)
