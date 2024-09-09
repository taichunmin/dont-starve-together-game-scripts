require("stategraphs/commonstates")

local function onattackedfn(inst)
    if (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and not inst.components.health:IsDead() then
        if inst.sg:HasStateTag("grounded") then
            inst.sg.statemem.knockdown = true
            inst.sg:GoToState("knockdown_hit")
        elseif not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end
end

local function ChooseAttack(inst)
    inst.sg:GoToState(inst.enraged and inst.can_ground_pound and "pound_pre" or "attack")
    return true
end

local function onattackfn(inst)
    if not (inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("grounded") or
            inst.components.health:IsDead()) then
        ChooseAttack(inst)
    end
end

local function onstunnedfn(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("knockdown")
    end
end

local function onstunfinishedfn(inst)
    if inst.sg:HasStateTag("grounded") and not inst.components.health:IsDead() then
        if inst.sg.mem.sleeping then
            inst.sg.statemem.continuesleeping = true
            inst.sg:GoToState("sleeping")
        else
            inst.sg.statemem.knockdown = true
            inst.sg:GoToState("knockdown_pst")
        end
    end
end

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .8, inst, 40)
end

local function onspawnlavae(inst)
    if not inst.sg.mem.wantstospawn then
        inst.sg.mem.wantstospawn = true
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("lavae")
        end
    end
end

local function transform(inst, data)
    if not (inst.sg:HasStateTag("frozen") or
            inst.sg:HasStateTag("grounded") or
            inst.sg:HasStateTag("sleeping") or
            inst.sg:HasStateTag("flight") or
            inst.components.health:IsDead()) then
        inst.sg:GoToState("transform_"..data.transformstate)
    end
end

local function SwitchToFlyOverPhysics(inst)
    if not inst.sg.mem.flyoverphysics then
        inst.sg.mem.flyoverphysics = true
        CommonHandlers.UpdateHitRecoveryDelay(inst)
        inst.hit_recovery = TUNING.DRAGONFLY_FLYING_HIT_RECOVERY
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local function SwitchToCombatPhysics(inst)
    if inst.sg.mem.flyoverphysics then
        inst.sg.mem.flyoverphysics = false
        inst.hit_recovery = TUNING.DRAGONFLY_HIT_RECOVERY
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "flyaway"),
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    EventHandler("doattack", onattackfn),
    EventHandler("attacked", onattackedfn),
    EventHandler("stunned", onstunnedfn),
    EventHandler("stun_finished", onstunfinishedfn),
    EventHandler("spawnlavae", onspawnlavae),
    EventHandler("transform", transform),
    --Because this comes from an event players can prevent it by having dragonfly
    --in sleep/ freeze/ knockdown states when this is triggered.
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            elseif inst.sg.mem.wantstospawn then
                inst.sg:GoToState("lavae")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if inst.enraged then
                inst.AnimState:PlayAnimation("walk_angry_pre")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
            else
                inst.AnimState:PlayAnimation("walk_pre")
            end
            if inst.sg.mem.flyover then
                SwitchToFlyOverPhysics(inst)
            end
            inst.components.locomotor:WalkForward()
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) if not inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
            TimeEvent(2*FRAMES, function(inst) if inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.walking = true
                    inst.sg:GoToState("walk")
                end
            end),
        },

        onexit = function(inst)
            if not (inst.sg.statemem.walking and inst.sg.mem.flyover) then
                SwitchToCombatPhysics(inst)
            end
        end,
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if inst.enraged then
                inst.AnimState:PlayAnimation("walk_angry")
                if math.random() < .5 then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
                end
            else
                inst.AnimState:PlayAnimation("walk")
            end
            if inst.sg.mem.flyover then
                SwitchToFlyOverPhysics(inst)
            end
            inst.components.locomotor:WalkForward()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.walking = true
                    inst.sg:GoToState("walk")
                end
            end),
        },

        onexit = function(inst)
            if not (inst.sg.statemem.walking and inst.sg.mem.flyover) then
                SwitchToCombatPhysics(inst)
            end
        end,
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(inst.enraged and "walk_angry_pst" or "walk_pst")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) if not inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
            TimeEvent(2*FRAMES, function(inst) if inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst, cb)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.doattack then
                    if not inst.components.health:IsDead() and ChooseAttack(inst) then
                        return
                    end
                    inst.sg.statemem.doattack = nil
                end
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.sg:AddStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.doattack and ChooseAttack(inst) then
                        return
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "knockdown",
        tags = { "busy", "nosleep" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            --Start tracking progress towards breakoff loot
            inst.AnimState:PlayAnimation("hit_large")
            inst.components.damagetracker:Start()
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("flying")
            end),
            TimeEvent(22*FRAMES, function(inst)
                if inst.enraged then
                    inst:TransformNormal()
                    inst.SoundEmitter:KillSound("fireflying")
                end
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.knockdown = true
                    inst.sg:GoToState("knockdown_idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.knockdown then
                inst.SoundEmitter:KillSound("flying")
                if inst.enraged then
                    inst:TransformNormal()
                    inst.SoundEmitter:KillSound("fireflying")
                end
            else
                inst.components.damagetracker:Stop()
                if not inst.SoundEmitter:PlayingSound("flying") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                end
            end
        end,
    },

    State{
        name = "knockdown_idle",
        tags = { "grounded", "nosleep" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.knockdown = true
                    inst.sg:GoToState("knockdown_idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.knockdown then
                inst.components.damagetracker:Stop()
                if not (inst.sg.statemem.continuesleeping or inst.SoundEmitter:PlayingSound("flying")) then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                end
            end
        end,
    },

    State{
        name = "knockdown_hit",
        tags = { "busy", "grounded", "nosleep" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit_ground")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.knockdown = true
                    inst.sg:GoToState("knockdown_idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.knockdown then
                inst.components.damagetracker:Stop()
                if not (inst.sg.statemem.continuesleeping or inst.SoundEmitter:PlayingSound("flying")) then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                end
            end
        end,
    },

    State{
        name = "knockdown_pst",
        tags = { "busy", "nosleep" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.components.damagetracker:Stop()
            --Stop tracking progress towards breakoff loot
        end,

        timeline =
        {
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying") end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            if not inst.SoundEmitter:PlayingSound("flying") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
            end
        end,
    },

    State{
        name = "flyaway",
        tags = { "flight", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.DynamicShadow:Enable(false)
            inst.components.health:SetInvincible(true)

            inst.AnimState:PlayAnimation("taunt_pre")
            inst.AnimState:PushAnimation("taunt")
            inst.AnimState:PushAnimation("taunt_pst") --59 frames

            inst.AnimState:PushAnimation("walk_angry_pre") -- 75 frames
            inst.AnimState:PushAnimation("walk_angry", true)
        end,

        timeline =
        {
            TimeEvent(75*FRAMES, function(inst)
                local x, y, z = 0.5019684438612,7.5216834009827,2.7178563798944
                inst.Physics:SetMotorVel(x, y, z)
            end),
            TimeEvent(6, function(inst)
                inst:DoDespawn()
            end)
        },

        onexit = function(inst)
            --You somehow left this state?! (not supposed to happen).
            --Cancel the action to avoid getting stuck.
            print("Dragonfly left the flyaway state! How could this happen?!")
            inst.components.health:SetInvincible(false)
            inst:ClearBufferedAction()
            inst.DynamicShadow:Enable(true)
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
            inst.AnimState:PlayAnimation("atk")
            if inst.enraged then
                local attackfx = SpawnPrefab("attackfire_fx")
                attackfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                attackfx.Transform:SetRotation(inst.Transform:GetRotation())
            end
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/swipe") end),
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/punchimpact")
				local target = inst.sg.statemem.target
				inst.components.combat:DoAttack(target)
				if inst.enraged and target ~= nil and target.components.health ~= nil and not target.components.health:IsDead() and target:IsValid() then
					target.components.health:DoFireDamage(5, inst, true)
                end
            end),
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
        name = "transform_fire",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()

            if inst.enraged then
                inst.sg:GoToState("idle")
            else
                inst.AnimState:PlayAnimation("fire_on")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(7*FRAMES, function(inst)
                inst:TransformFire()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/firedup", "fireflying")
            end),
        },
    },

    State{
        name = "transform_normal",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()

            if not inst.enraged then
                inst.sg:GoToState("idle")
            else
                inst.AnimState:PlayAnimation("fire_off")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(17*FRAMES, function(inst)
                inst:TransformNormal()
                inst.SoundEmitter:KillSound("fireflying")
            end),
        },
    },

    State{
        name = "pound_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pound")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
            end),
        },
    },

    State{
        name = "pound",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")
            local tauntfx = SpawnPrefab("tauntfire_fx")
            tauntfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            tauntfx.Transform:SetRotation(inst.Transform:GetRotation())

            inst.can_ground_pound = false
            inst.components.timer:StartTimer("groundpound_cd", TUNING.DRAGONFLY_POUND_CD)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pound_post")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                inst.components.groundpounder:GroundPound()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
            end),
            TimeEvent(9*FRAMES, function(inst)
                inst.components.groundpounder:GroundPound()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
            end),
            TimeEvent(20*FRAMES, function(inst)
                inst.components.groundpounder:GroundPound()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
            end),
        },
    },

    State{
        name = "pound_post",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
        },
    },

    State{
        name = "lavae",
        tags = { "busy" },

        onenter = function(inst)
            inst.Transform:SetTwoFaced()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("vomit")
            inst.vomitfx = SpawnPrefab("vomitfire_fx")
            inst.vomitfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.vomitfx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/vomitrumble", "vomitrumble")
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(55*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("vomitrumble")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/vomit")
            end),
            TimeEvent(59*FRAMES, function(inst)
                inst.sg.mem.wantstospawn = nil
                if inst.brain ~= nil then
                    inst.brain:OnSpawnLavae()
                end
            end),
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
            inst.Transform:SetSixFaced()
            if inst.vomitfx then
                inst.vomitfx:Remove()
            end
            inst.vomitfx = nil
            inst.SoundEmitter:KillSound("vomitrumble")
        end,
    },

    State{
        name = "sleep",
        tags = { "busy", "sleeping", "nowake", "caninterrupt" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("land")
            inst.AnimState:PushAnimation("land_idle", false)
            inst.AnimState:PushAnimation("takeoff", false)
            inst.AnimState:PushAnimation("sleep_pre", false)
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:KillSound("flying") end),
            TimeEvent(16*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land")
                if inst.enraged then
                    inst:TransformNormal()
                    inst.SoundEmitter:KillSound("fireflying")
                end
            end),
            TimeEvent(74*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(78*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying") end),
            TimeEvent(91*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(111*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/sleep_pre") end),
            TimeEvent(202*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
                inst.SoundEmitter:KillSound("flying")
                inst.sg:RemoveStateTag("caninterrupt")
            end),
            TimeEvent(203*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.continuesleeping = true
                    inst.sg:GoToState(inst.sg.mem.sleeping and "sleeping" or "wake")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping then
                --V2C: interrupted? bad! restore sound tho
                if not inst.SoundEmitter:PlayingSound("flying") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                end
                if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                    inst.components.sleeper:WakeUp()
                end
            end
        end,
    },

    State{
        name = "sleeping",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_loop")
            if not inst.SoundEmitter:PlayingSound("sleep") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/sleep", "sleep")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.continuesleeping = true
                    inst.sg:GoToState("sleeping")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping then
                --V2C: interrupted? bad! restore sound tho
                inst.SoundEmitter:KillSound("sleep")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                    inst.components.sleeper:WakeUp()
                end
            end
        end,
    },

    State{
        name = "wake",
        tags = { "busy", "waking", "nosleep" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.SoundEmitter:KillSound("sleep")
            inst.SoundEmitter:KillSound("flying")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/wake")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
        end,

        timeline =
        {
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            CommonHandlers.OnNoSleepTimeEvent(26 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            --V2C: in case we got interrupted
            if not inst.SoundEmitter:PlayingSound("flying") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
            end
        end,
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Light:Enable(false)
            inst.components.propagator:StopSpreading()
            inst.AnimState:PlayAnimation("death")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/death")
            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(26*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("flying")
                inst.SoundEmitter:KillSound("fireflying")
            end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land") end),
            TimeEvent(29*FRAMES, function(inst)
                ShakeIfClose(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(5, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT reach here!
            inst:RemoveTag("NOCLICK")
        end,
    },

    State{
        name = "land",
        tags = { "flight", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_angry", true)
            inst.Physics:SetMotorVelOverride(0, -11, 0)
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVelOverride(0, -15, 0)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 2 or inst:IsAsleep() then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.sg:GoToState("idle", { softstop = true })
                ShakeIfClose(inst)
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 0 then
                inst.Transform:SetPosition(x, 0, z)
            end
            inst.Physics:ClearMotorVelOverride()
        end,
    },
}

CommonStates.AddFrozenStates(states,
    function(inst) --onoverridesymbols
        inst.SoundEmitter:KillSound("flying")
        if inst.enraged then
            inst:TransformNormal()
            inst.SoundEmitter:KillSound("fireflying")
        end
    end,
    function(inst) --onclearsymbols
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
    end
)

return StateGraph("dragonfly", states, events, "idle", actionhandlers)
