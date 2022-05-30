require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events =
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death", inst.sg.statemem.dead) end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnFreeze(),

    EventHandler("startle", function(inst)
        if not (inst.sg:HasStateTag("startled") or
                inst.sg:HasStateTag("statue") or
                inst.components.health:IsDead() or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            inst.components.combat:SetTarget(nil)
            inst.sg:GoToState("startle")
        end
    end),

    EventHandler("heardwhistle", function(inst, data)
        if not (inst.sg:HasStateTag("statue") or
                inst.components.health:IsDead() or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
                inst.components.combat:SetTarget(nil)
            else
                if inst.components.combat:TargetIs(data.musician) then
                    inst.components.combat:SetTarget(nil)
                end
                if not inst.sg:HasStateTag("howling") then
                    inst.sg:GoToState("howl", {count =2} )
                end
            end
        end
    end),

    --Moon hounds
    EventHandler("workmoonbase", function(inst, data)
        if data ~= nil and data.moonbase ~= nil and not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("workmoonbase", data.moonbase)
        end
    end),

    --Clay hounds
    EventHandler("becomestatue", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("transformstatue")
        end
    end),
}

local function SpawnHound(inst)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil then
        local num = inst:NumHoundsToSpawn()
        if inst.max_hound_spawns then
            num = math.min(num,inst.max_hound_spawns)
            inst.max_hound_spawns = inst.max_hound_spawns - num
        end
        local pt = inst:GetPosition()
        for i = 1, num do
            local hound = hounded:SummonSpawn(pt)
            if hound ~= nil and hound.components.follower ~= nil then
                hound.components.follower:SetLeader(inst)
            end
        end
    end
end

local function PlayClayShakeSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/stone_shake", nil, .6)
end

local function PlayClayFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/footstep_hound")
end

local function StartAura(inst)
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
end

local function StopAura(inst)
    inst.components.sanityaura.aura = 0
end

local function ShowEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(true)
    end
end

local function HideEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(false)
    end
end

local function MakeStatue(inst)
    if not inst.sg.mem.statue then
        inst.sg.mem.statue = true
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:Stop()
        ChangeToObstaclePhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:AddTag("notarget")
        inst.components.health:SetInvincible(true)

        --Snap to nearest 45 degrees + 15 degree offset for better facing update during camera rotation
        inst.Transform:SetRotation(math.floor(inst.Transform:GetRotation() / 45 + .5) * 45 + 15)
    end
end

local function MakeReanimated(inst)
    if inst.sg.mem.statue then
        inst.sg.mem.statue = nil
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:SetMass(10)
        ChangeToCharacterPhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)
    end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.SoundEmitter:PlaySound(inst.sounds.pant)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(2*math.random()+.5)
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
        end,

        timeline =
        {

            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) if math.random() < .333 then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

    State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bite) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) if inst:PerformBufferedAction() then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "startle",
        tags = { "busy", "startled" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("scared_pre")
            inst.AnimState:PushAnimation("scared_loop", true)
            inst.SoundEmitter:PlaySound(inst.components.combat.hurtsound)
            inst.sg:SetTimeout(.8 + .3 * math.random())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "scared_pst")
        end,
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst, norepeat)
            if inst:HasTag("clay") then
                inst.sg:GoToState("howl", {count = norepeat and -1 or 0})
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("taunt")
                inst.sg.statemem.norepeat = norepeat
            end
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bark) end),
            TimeEvent(24 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bark) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.sg.statemem.norepeat and math.random() < .333 then
                    inst.sg:GoToState("taunt", inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("player"))
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "howl",
        tags = { "busy", "howling" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("howl")
            if data.howl == true then
                inst.sg.statemem.spawnhounds = true
            else
                inst.sg.statemem.count = data.count or 0
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.howl) end),
            TimeEvent(10 * FRAMES, function(inst)
                    if inst.sg.statemem.spawnhounds then
                        SpawnHound(inst)
                    end
                end),
        },

        events =
        {
            EventHandler("heardwhistle", function(inst)
                inst.sg.statemem.count = 2
            end),
            EventHandler("animover", function(inst)
                if inst.sg.statemem.spawnhounds then
                    inst.sg:GoToState("idle")
                elseif inst.sg.statemem.count > 0 then
                    inst.sg:GoToState("howl", {count= inst.sg.statemem.count > 1 and inst.sg.statemem.count - 1 or -1})
                elseif inst.sg.statemem.count == 0 and math.random() < 0.333 then
                    inst.sg:GoToState("howl", {count= inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("player") and -1 or 0 })
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst, reanimating)
            if reanimating then
                inst.AnimState:Pause()
            else
                inst.AnimState:PlayAnimation("death")
				if inst.components.amphibiouscreature ~= nil and inst.components.amphibiouscreature.in_water then
		            inst.AnimState:PushAnimation("death_idle", true)
				end
            end
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            if inst:HasTag("clay") then
                inst.sg.statemem.clay = true
                HideEyeFX(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
            end
            inst.SoundEmitter:PlaySound(inst.sounds.death)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
            TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.clay then
                    PlayClayFootstep(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst._CanMutateFromCorpse ~= nil and inst:_CanMutateFromCorpse() then
					SpawnPrefab("houndcorpse").Transform:SetPosition(inst.Transform:GetWorldPosition())
					inst:Remove()
				end
            end),
        },


        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
            if inst.sg.statemem.clay then
                ShowEyeFX(inst)
            end
        end,
    },

    State{
        name = "forcesleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_loop", true)
        end,
    },

    --Moon hound
    State{
        name = "workmoonbase",
        tags = { "busy", "working" },

        onenter = function(inst, moonbase)
            inst.sg.statemem.moonbase = moonbase
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {
            --TimeEvent(14 * FRAMES, function(inst)
            --    inst.SoundEmitter:PlaySound(inst.sounds.attack)
            --end),
            TimeEvent(16 * FRAMES, function(inst)
                local moonbase = inst.sg.statemem.moonbase
                if moonbase ~= nil and
                    moonbase.components.workable ~= nil and
                    moonbase.components.workable:CanBeWorked() then
                    moonbase.components.workable:WorkedBy(inst, 1)
                    SpawnPrefab("mining_fx").Transform:SetPosition(moonbase.Transform:GetWorldPosition())
                    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_stone_wall_sharp")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.components.combat:SetTarget(nil)
                if math.random() < .333 then
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle", "atk_pst")
                end
            end),
        },
    },

    State{
        name = "reanimate",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.sg.statemem.taunted = data.anim == "taunt"
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(data.anim)
            inst.AnimState:Pause()
            if data.time ~= nil then
                inst.AnimState:SetTime(data.time)
            end
            inst.sg.statemem.dead = data.dead
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.taunted and "idle" or "taunt")
            end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },

    --Clay hound
    State{
        name = "statue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            HideEyeFX(inst)
            StopAura(inst)
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("idle_statue")
        end,

        events =
        {
            EventHandler("reanimate", function(inst, data)
                inst.sg.statemem.statue = true
                inst.sg:GoToState("reanimatestatue", data ~= nil and data.target or nil)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.statue then
                MakeReanimated(inst)
                ShowEyeFX(inst)
                StartAura(inst)
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "reanimatestatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst, target)
            MakeStatue(inst)
            ShowEyeFX(inst)
            StartAura(inst)
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("statue_pst")
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, PlayClayShakeSound),
            TimeEvent(4 * FRAMES, PlayClayShakeSound),
            TimeEvent(6 * FRAMES, PlayClayShakeSound),
            TimeEvent(8 * FRAMES, PlayClayShakeSound),
            TimeEvent(10 * FRAMES, PlayClayShakeSound),
            TimeEvent(12 * FRAMES, PlayClayShakeSound),
            TimeEvent(14 * FRAMES, function(inst)
                PlayClayShakeSound(inst)
                PlayClayFootstep(inst)
            end),
            TimeEvent(16 * FRAMES, PlayClayShakeSound),
            TimeEvent(41 * FRAMES, PlayClayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            MakeReanimated(inst)
            if inst.sg.statemem.target ~= nil then
                inst.components.combat:SetTarget(inst.sg.statemem.target)
            end
            inst.Transform:SetFourFaced()
        end,
    },

    State{
        name = "transformstatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("statue_pre")
            local leader = inst.components.follower.leader
            if leader ~= nil then
                inst.Transform:SetRotation(leader.Transform:GetRotation())
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, PlayClayShakeSound),
            TimeEvent(4 * FRAMES, PlayClayShakeSound),
            TimeEvent(6 * FRAMES, PlayClayShakeSound),
            TimeEvent(8 * FRAMES, PlayClayShakeSound),
            TimeEvent(9 * FRAMES, PlayClayFootstep),
            TimeEvent(10 * FRAMES, function(inst)
                PlayClayShakeSound(inst)
                HideEyeFX(inst)
            end),
            TimeEvent(12 * FRAMES, PlayClayShakeSound),
            TimeEvent(14 * FRAMES, PlayClayShakeSound),
            TimeEvent(16 * FRAMES, PlayClayShakeSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.statue = true
                    inst.sg:GoToState("statue")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.statue then
                MakeReanimated(inst)
                ShowEyeFX(inst)
                StartAura(inst)
                inst.Transform:SetFourFaced()
            end
        end,
    },


    State{
        name = "mutated_spawn",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mutated_hound_spawn")
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("taunt")
            end),
        },

        onexit = function(inst)
        end,
    },
}

CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- config
	swimming_clear_collision_frame = 9 * FRAMES,
},
{ -- anims
},
{ -- timeline
	hop_pre =
	{
		TimeEvent(0, function(inst)
			if inst:HasTag("swimming") then
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
	},
	hop_pst = {
		TimeEvent(4 * FRAMES, function(inst)
			if inst:HasTag("swimming") then
				inst.components.locomotor:Stop()
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
		TimeEvent(6 * FRAMES, function(inst)
			if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
			end
		end),
	}
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.growl)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                if inst:HasTag("clay") then
                    PlayClayFootstep(inst)
                else
                    PlayFootstep(inst)
                end
            end
        end),
        TimeEvent(4 * FRAMES, function(inst)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                if inst:HasTag("clay") then
                    PlayClayFootstep(inst)
                else
                    PlayFootstep(inst)
                end
            end
        end),
    },
})
CommonStates.AddFrozenStates(states, HideEyeFX, ShowEyeFX)

return StateGraph("hound", states, events, "taunt", actionhandlers)
