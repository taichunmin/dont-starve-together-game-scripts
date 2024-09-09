require("stategraphs/commonstates")

local TIRED_ANIM_INTERVAL = 4
local TIRED_ANIM_CHANCE   = 0.8

-- Not putting this on funnyidle because it needs to be more frequent.
local function GetIdleAnim(inst)
    if not inst:HasTag("guard") then
        return "idle_loop"
    end

    if (
        inst.sg.mem.last_tiredanim_time == nil or
        (GetTime() - inst.sg.mem.last_tiredanim_time > TIRED_ANIM_INTERVAL)
    ) and
        inst:ShouldWaitForHelp() and
        math.random() <= TIRED_ANIM_CHANCE
    then
        inst.sg.mem.last_tiredanim_time = GetTime()

        return "debuff"
    end

    return "idle_loop"
end

local function tool_or_chop(inst)
    local hand_item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return (hand_item ~= nil and hand_item.components.tool ~= nil and "use_tool")
        or "chop"
end

local function tool_or_mine(inst)
    local hand_item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return (hand_item ~= nil and hand_item.components.tool ~= nil and "use_tool")
        or "mine"
end

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.CHOP, tool_or_chop),
    ActionHandler(ACTIONS.MINE, tool_or_mine),
    ActionHandler(ACTIONS.DIG, tool_or_chop),
    ActionHandler(ACTIONS.HAMMER, "hammer"),
    ActionHandler(ACTIONS.MARK, "chop"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.TILL, "use_tool"),
}

local events =
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),

    --CommonHandlers.OnAttack(),
    EventHandler("doattack", function(inst)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
                and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState((inst.CanTripleAttack and inst:CanTripleAttack() and "tri_attack")
                or "attack")
        end
    end),
    CommonHandlers.OnAttacked(nil, TUNING.MERM_MAX_STUN_LOCKS),
    EventHandler("attackdodged", function(inst, attacker)
        if inst.components.health ~= nil and not inst.components.health:IsDead() then
            inst.sg:GoToState("dodge_attack", attacker)
        end
    end),

    EventHandler("onarrivedatthrone", function(inst)
        if inst.components.health and inst.components.health:IsDead() then
            return
        end

        local player_close = FindClosestPlayerToInst(inst, 5, true)
        if player_close then
            inst:ForceFacePoint(player_close.Transform:GetWorldPosition())
        end

        if not inst.sg:HasStateTag("transforming") then
            if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:ShouldTransform(inst) then
                if inst.sg:HasStateTag("sitting") then
                    inst.sg:GoToState("getup")
                elseif not inst.sg:HasStateTag("gettingup") then
                    inst.sg:GoToState("transform_to_king")
                end
            elseif not inst.sg:HasStateTag("sitting") and player_close == nil then
                inst.sg:GoToState("sitdown")
            elseif player_close and inst.sg:HasStateTag("sitting") then
                inst.sg:GoToState("getup")
            end
        end
    end),

    EventHandler("getup", function(inst)
        inst.sg:GoToState("getup")
    end),

    EventHandler("mutated", function(inst,data)
        inst.sg:GoToState("lunar_transform",data)
    end),
    EventHandler("demutated", function(inst,data)
        inst.sg:GoToState("lunar_revert",data)
    end),

    EventHandler("onmermkingcreated_anywhere", function(inst)
        inst.sg:GoToState("buff")
    end),
    EventHandler("onmermkingdestroyed_anywhere", function(inst)
        inst.sg:GoToState("debuff")
    end),
    EventHandler("cheer", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("cheer")
        end
    end),
    EventHandler("win_yotb", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("win_yotb")
        end
    end),
    EventHandler("merm_lunar_revive", function(inst)
        if inst.components.health:IsDead() then
            inst.sg:GoToState("revive_lunar")
        end
    end),

    EventHandler("merm_use_building", function(inst,data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("use_building", data)
        end
    end),

    EventHandler("shadowmerm_spawn", function(inst,data)
        inst.sg:GoToState("shadow_spawn", data)
    end),

}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local states =
{
    State{
        name = "funnyidle",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            -- NOTES(JBK): Making merms less expressive than other followers but keeping core information expressed.
            if inst.components.follower and inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() < TUNING.MERM_LOW_LOYALTY_WARNING_PERCENT and not inst.components.follower.neverexpire then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst:HasTag("guard") then
                inst.AnimState:PlayAnimation("idle_angry")
            elseif inst.components.combat:HasTarget() then
                inst.AnimState:PlayAnimation("idle_angry")
            else
                inst.sg:GoToState("idle") -- Not a comedian.
            end
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "idle_sit",
        tags = { "idle", "sitting" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sit_idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_sit")
            end),
        },
    },

    State{
        name = "sitdown",
        tags = { "idle", "sitting" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_sit")
            end),
        },
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_splat" ,nil,.5) end),
        },
    },

    State{
        name = "getup",
        tags = { "busy", "gettingup", "nospellcasting" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("getup")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:ShouldTransform(inst) then
                    inst.sg:GoToState("transform_to_king")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "transform_to_king",
        tags = { "busy", "transforming", "nospellcasting"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("transform_to_king_pre")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/attack")
            end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/transform_pre")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                TheWorld:PushEvent("oncandidatekingarrived", {candidate = inst})
            end),
        },

    },

    State{
        name = "chop",
        tags = { "chopping" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "mine",
        tags = { "mining" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                if inst.bufferedaction ~= nil then
                    PlayMiningFX(inst, inst.bufferedaction.target)
                end
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "hammer",
        tags = { "hammering" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "buff",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            if inst:HasTag("guard") then
                inst.AnimState:PlayAnimation("transform_pre")
            else
                inst.AnimState:PlayAnimation("buff")
            end
            local fx = SpawnPrefab("merm_splash")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/buff")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.buff)
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },
    State{
        name = "debuff",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("debuff")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("eat")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                local food = inst:GetBufferedAction().target
                inst:PerformBufferedAction()
                if food and food:HasTag("moonglass_piece") then
                    inst:TestForLunarMutation(food)
                end
            end),
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/eat") end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/chew") end),
            TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/chew") end),
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
        name = "cheer",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("buff")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "disapproval",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_scared")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "win_yotb",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("win")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "revive_lunar",
        tags = { "busy" },

        onenter = function(inst)
            inst:RemoveTag("lunar_merm_revivable")
            inst.components.health:SetPercent(1)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sleep_pst")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "use_tool",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("work")
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                local act = inst:GetBufferedAction()
                local target = act.target
                local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

                if tool ~= nil and target ~= nil and target:IsValid() and target.components.workable ~= nil and target.components.workable:CanBeWorked() then
                    target.components.workable:WorkedBy(inst,tool.components.tool:GetEffectiveness(act.action))
                    tool:OnUsedAsItem(act.action, inst, target)
                end

                if target ~= nil and act.action == ACTIONS.MINE then
                    PlayMiningFX(inst, target)
                end

                if target ~= nil and  target:HasTag("farm_debris") and act.action == ACTIONS.DIG then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                end

                if act.action == ACTIONS.TILL then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                end

                if target ~= nil and target:HasTag("stump") and act.action == ACTIONS.DIG then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
                end

                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "use_building",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pig_take")
            inst.sg.statemem.target = data.target

            inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.target:OnSupply(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "shadow_spawn",
        tags = { "canrotate", "busy", "jumping" },

        onenter = function(inst, data)
            local dir1 = math.random() > .5 and -1 or 1
            local dir2 = math.random() > .5 and -1 or 1
            local vel1 = math.random(6, 8)
            local vel2 = math.random(6, 8)

            ToggleOffCharacterCollisions(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:SetMotorVelOverride(vel1 * dir1, 0, vel2 * dir2)
            inst.AnimState:PlayAnimation("smacked")

            SpawnPrefab("shadow_merm_spawn_poof_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        onexit = function(inst)
            ToggleOnCharacterCollisions(inst)
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
            inst.Physics:Stop()
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                ToggleOnCharacterCollisions(inst)
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()

                SpawnPrefab("shadow_merm_smacked_poof_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "shadow_loyaltyover",
        tags = { "canrotate", "busy", "jumping" },

        onenter = function(inst, data)
            ToggleOffCharacterCollisions(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:SetMotorVelOverride(-8, 0, 0)
            inst.AnimState:PlayAnimation("smacked")
        end,

        onexit = function(inst) inst:Remove() end,

        timeline =
        {
            FrameEvent(14, function(inst)
                ToggleOnCharacterCollisions(inst)
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()

                SpawnPrefab("shadow_merm_smacked_poof_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
            FrameEvent(15, function(inst)
                inst:Remove()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State{
        name = "tri_attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_triplepunch")

            -- Reduce the combat damage number for the attack, so we get more total damage,
            -- but have some tuning control.
            inst.components.combat.externaldamagemultipliers:SetModifier(
                inst,
                TUNING.MERMKING_TRIDENTBUFF_TRIPLEHIT_DAMAGECHANGE,
                "tri_attack_tuning"
            )
        end,

        timeline =
        {
            FrameEvent(12, function(inst)
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            FrameEvent(18, function(inst)
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            FrameEvent(31, function(inst)
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            FrameEvent(43, function(inst)
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },

        onexit = function(inst)
            inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "tri_attack_tuning")
        end,
    },

    State{
        name = "dodge_attack",
        tags = { "busy", "jumping", "nosleep", "nofreeze" },

        onenter = function(inst, attacker)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("boat_jump_pre")
            inst.AnimState:PushAnimation("boat_jump", false)
            inst.AnimState:PushAnimation("boat_jump_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

            if attacker and attacker:IsValid() then
                inst:ForceFacePoint(attacker.Transform:GetWorldPosition())
            end

            PlayFootstep(inst)
        end,

        timeline =
        {
            FrameEvent(6, function(inst)
                SpawnPrefab("slide_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg:RemoveStateTag("nofreeze")

                ToggleOffCharacterCollisions(inst)
                inst.Physics:SetMotorVelOverride(-TUNING.MERMKING_CROWNBUFF_DODGE_SPEED, 0, 0)
                inst.sg.statemem.started = true
            end),
            FrameEvent(16, function(inst)
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                ToggleOnCharacterCollisions(inst)
                inst.sg.statemem.finished = true

                PlayFootstep(inst)
            end),
            CommonHandlers.OnNoSleepTimeEvent(22 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState((inst.sg.mem.sleeping and "sleep") or "idle")
                end
            end)
        },

        onexit = function(inst)
            if inst.sg.statemem.started and not inst.sg.statemem.finished then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                ToggleOnCharacterCollisions(inst)
            end
        end,
    },

    State{
        name = "hit_shadow",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("disappear")
        end,

        timeline =
        {
            FrameEvent(12, function(inst)

                if inst.components.follower.leader == nil then
                    inst:Remove()
                else
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
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)

                if inst.components.follower.leader == nil then
                    inst:Remove()
                else
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
                end
            end),
        },
    },

    State{
        name = "appear",
        tags = {"busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.Physics:Stop()
            --PlayExtendedSound(inst, "appear")
        end,

        timeline =
        {
            FrameEvent(12, go_to_idle),
        },

        events =
        {
            EventHandler("animover", go_to_idle)
        },
    },


    State{
        name = "lunar_transform",
        tags = {"busy" },

        onenter = function(inst, data)
            if data.oldbuild then
                inst.sg.statemem.newbuild = inst.AnimState:GetBuild()
                inst.sg.statemem.oldbuild = data.oldbuild
                inst.AnimState:SetBuild(data.oldbuild)
            end
            inst.AnimState:PlayAnimation("transform_pre")
            inst.Physics:Stop()

            inst.SoundEmitter:PlaySound("meta4/lunar_merm/transform")

            local fx = SpawnPrefab("merm_splash")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/buff")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            FrameEvent(30, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.newbuild) end),
            FrameEvent(32, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.oldbuild) end),
            FrameEvent(35, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.newbuild) end),
            FrameEvent(40, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.oldbuild) end),
            FrameEvent(44, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.newbuild) end),
        },

        onexit = function(inst)
            inst.AnimState:SetBuild(inst.sg.statemem.newbuild)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "lunar_revert",
        tags = { "busy" },

        onenter = function(inst, data)
            if data.oldbuild then
                inst.sg.statemem.newbuild = inst.AnimState:GetBuild()
                inst.sg.statemem.oldbuild = data.oldbuild
                inst.AnimState:SetBuild(data.oldbuild)
            end
            inst.AnimState:PlayAnimation("idle_scared")
            inst.Physics:Stop()

            inst.SoundEmitter:PlaySound("meta4/lunar_merm/transform")

            local fx = SpawnPrefab("merm_splash")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/buff")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,
        timeline =
        {
            FrameEvent(15, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.newbuild) end),
            FrameEvent(17, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.oldbuild) end),
            FrameEvent(20, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.newbuild) end),
            FrameEvent(25, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.oldbuild) end),
            FrameEvent(29, function(inst) inst.AnimState:SetBuild(inst.sg.statemem.newbuild) end),
        },
        onexit = function(inst)
            inst.AnimState:SetBuild(inst.sg.statemem.newbuild)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddSleepStates(states,
{
	sleeptimeline =
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/sleep") end ),
	},
})

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.attack)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end),
        TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    hittimeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            if inst:HasTag("lunarminion") then
               inst:DoThorns()
            end
            if inst:HasTag("shadowminion") then
                inst.sg:GoToState("hit_shadow")
            end
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
        end),
    },
    deathtimeline =
    {
        TimeEvent(0, function(inst)
            if inst.TestForShadowDeath then
                inst:TestForShadowDeath()
            end
            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end),
    },
})

CommonStates.AddIdle(states, "funnyidle", GetIdleAnim)
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})
CommonStates.AddSimpleState(states, "refuse", "pig_reject", { "busy" })
CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })

return StateGraph("merm", states, events, "idle", actionhandlers)