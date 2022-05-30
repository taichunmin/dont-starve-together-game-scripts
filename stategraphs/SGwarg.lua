require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(true, false),

    EventHandler("doattack", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead()
			and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
			if inst:HasTag("gingerbread") and (inst._next_goo_time == nil or inst._next_goo_time < GetTime()) then
				inst.sg:GoToState("attack_icing")
			else
				inst.sg:GoToState("attack")
			end
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
                    inst.sg:GoToState("howl", {count=2})
                end
            end
        end
    end),

    --Clay warg
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

local function PlayClayShakeSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/stone_shake")
end

local function PlayClayFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/footstep")
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

        inst:OnBecameStatue()
    end
end

local function MakeReanimated(inst)
    if inst.sg.mem.statue then
        inst.sg.mem.statue = nil
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:SetMass(1000)
        ChangeToCharacterPhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)

        inst:OnReanimated()
    end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            if not inst.noidlesound then
                inst.SoundEmitter:PlaySound(inst.sounds.idle)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "howl",
        tags = { "busy", "howling" },

        onenter = function(inst, data)

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("howl")
            inst.SoundEmitter:PlaySound(inst.sounds.howl)
            inst.sg.statemem.count = data and data.count or nil
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.count == nil then
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
                if inst.sg.statemem.count ~= nil and inst.sg.statemem.count > 1 then
                    inst.sg:GoToState("howl", {count=inst.sg.statemem.count - 1})
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

	--Gingerbread warg
    State{
        name = "attack_icing",
        tags = { "attack", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack_icing")
            inst.components.combat:StartAttack()
        end,

        timeline =
		{
            TimeEvent(14 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(17 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(26 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(33 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(33*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(42 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(42*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
            TimeEvent(49 * FRAMES, function(inst) inst:LaunchGooIcing() end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/whoosh") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
			        inst.sg:GoToState("idle")
			    end
			end),
        },
    },

    State{
        name = "gingerbread_intro",
        tags = { "intro_state" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("gingerbread_eat_loop")
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/eat") end),
            TimeEvent(6*FRAMES, function(inst) if math.random() < 0.5 then inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/vocal") end end),
            TimeEvent(12*FRAMES, function(inst) if math.random() < 0.7 then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/vargr/idle") end end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/eat") end),
            -- TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/vocal") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbread_vargr/eat") end),
            -- TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wintersfeast2019/creatures/gingerbreadpig/vocal") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.components.combat == nil or inst.components.combat:HasTarget() then
				        inst.sg:GoToState("idle")
					else
				        inst.sg:GoToState("gingerbread_intro")
					end
			    end
			end),
        },
    },

    --Clay warg
    State{
        name = "statue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            HideEyeFX(inst)
            inst.AnimState:PlayAnimation("statue")
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
            end
        end,
    },

    State{
        name = "reanimatestatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst, target)
            MakeStatue(inst)
            ShowEyeFX(inst)
            inst.AnimState:PlayAnimation("statue_pst")
            inst.SoundEmitter:PlaySound("dontstarve/music/clay_resurrection")
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, PlayClayShakeSound),
            TimeEvent(3 * FRAMES, PlayClayShakeSound),
            TimeEvent(5 * FRAMES, PlayClayShakeSound),
            TimeEvent(7 * FRAMES, PlayClayShakeSound),
            TimeEvent(21 * FRAMES, PlayClayShakeSound),
            TimeEvent(23 * FRAMES, PlayClayShakeSound),
            TimeEvent(25 * FRAMES, PlayClayShakeSound),
            TimeEvent(29 * FRAMES, PlayClayShakeSound),
            TimeEvent(32 * FRAMES, PlayClayShakeSound),
            TimeEvent(34 * FRAMES, PlayClayShakeSound),
            TimeEvent(36 * FRAMES, PlayClayShakeSound),
            TimeEvent(38 * FRAMES, PlayClayShakeSound),
            TimeEvent(39 * FRAMES, PlayClayShakeSound),
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
        end,
    },

    State{
        name = "transformstatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            inst.AnimState:PlayAnimation("statue_pre")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, PlayClayShakeSound),
            TimeEvent(4 * FRAMES, PlayClayShakeSound),
            TimeEvent(6 * FRAMES, function(inst)
                PlayClayShakeSound(inst)
                PlayClayFootstep(inst)
            end),
            TimeEvent(8 * FRAMES, PlayClayShakeSound),
            TimeEvent(10 * FRAMES, function(inst)
                PlayClayShakeSound(inst)
                HideEyeFX(inst)
            end),
            TimeEvent(12 * FRAMES, PlayClayShakeSound),
            TimeEvent(14 * FRAMES, PlayClayShakeSound),
            TimeEvent(16 * FRAMES, PlayClayShakeSound),
            TimeEvent(18 * FRAMES, PlayClayShakeSound),
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
            end
        end,
    },
}

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.hit) end),
    },
    attacktimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
        TimeEvent(12 * FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    deathtimeline =
    {
        TimeEvent(0 * FRAMES, function(inst)
            if inst:HasTag("clay") then
                inst.sg.statemem.clay = true
                HideEyeFX(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
                inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = .1 })
            end
            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end),
        TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.clay then
                PlayClayFootstep(inst)
            end
        end),
        TimeEvent(6 * FRAMES, function(inst)
            if inst.sg.statemem.clay then
                PlayClayFootstep(inst)
            end
        end),
    },
})
CommonStates.AddRunStates(states,
{
    starttimeline = {},
    runtimeline =
    {
        TimeEvent(5 * FRAMES, function(inst)
            if inst:HasTag("clay") then
                PlayClayFootstep(inst)
            else
                PlayFootstep(inst)
            end
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
        end),
    },
    endtimeline = {},
})
CommonStates.AddSleepStates(states,
{
    starttimeline = {},
    sleeptimeline =
    {
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
    endtimeline = {},
})
CommonStates.AddFrozenStates(states, HideEyeFX, ShowEyeFX)

return StateGraph("warg", states, events, "idle", actionhandlers)
