require("stategraphs/commonstates")

local TRANSITION_PST_MUST_TAGS = { "deergemresistance", "_health", "_combat" }
local TRANSITION_PST_CANT_TAGS = { "epic", "deer", "INLIMBO" }
--------------------------------------------------------------------------

local function ShakeIfClose(inst)
    if inst.enraged then
        ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, .15, inst, 30)
    end
end

local function DoRoarShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1.5, .015, inst.enraged and .3 or .15, inst, 30)
end

local function DoRoarAlert(inst)
    inst.components.epicscare:Scare(5)
end

local function DoChompShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1.5, .015, inst.enraged and .2 or .1, inst, 20)
end

local function DoFoleySounds(inst, volume)
    inst:DoFoleySounds(volume)
end

local function DoFootstep(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/step", nil, volume)
    ShakeIfClose(inst)
end

local function DoLanding(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/step")
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, inst.enraged and .2 or .1, inst, 30)
end

local function DoSwipeSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/swipe", nil, not inst.enraged and .7 or nil)
end

local function DoScratchSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/scratch")
end

local function DoBodyfall(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bodyfall")
    ShakeIfClose(inst)
end

--------------------------------------------------------------------------

local function DeerCanCast(deer)
    return not (deer.shouldavoidmagic or
                deer.components.health.takingfiredamage or
                deer.components.hauntable.panic or
                deer.components.health:IsDead() or
                deer.components.sleeper:IsAsleep() or
                (deer.components.freezable ~= nil and deer.components.freezable:IsFrozen()) or
                (deer.components.burnable ~= nil and deer.components.burnable:IsBurning()))
end

local function PickCommandDeer(inst, highprio, lowprio)
    local deer, lowpriodeer
    for i, v in ipairs(inst.components.commander:GetAllSoldiers()) do
        if DeerCanCast(v) and v:FindCastTargets() ~= nil then
            if v == highprio then
                return v
            elseif v == lowprio then
                lowpriodeer = v
            elseif highprio == nil then
                return v
            elseif deer == nil then
                deer = v
            end
        end
    end
    return deer or lowpriodeer
end

local function ChooseAttack(inst)
    if inst.components.commander:GetNumSoldiers() > 0 and
        not inst.components.timer:TimerExists("command_cd") then
        local deer = PickCommandDeer(inst, nil, inst.sg.mem.last_command_deer)
        if deer ~= nil then
            inst.sg:GoToState("command_pre", deer)
            return true
        end
    end
    inst.sg:GoToState("attack")
    return true
end

local function TryChomp(inst)
    local target = inst:FindChompTarget()
    if target ~= nil then
        if not inst.components.combat:TargetIs(target) then
            inst.components.combat:SetTarget(target)
        end
        inst.sg:GoToState("attack_chomp", target)
        return true
    end
end

local function CalcChompSpeed(inst, target)
    local x, y, z = target.Transform:GetWorldPosition()
    local distsq = inst:GetDistanceSqToPoint(x, y, z)
    if distsq > 0 then
        inst:ForceFacePoint(x, y, z)
        local dist = math.sqrt(distsq) - (inst:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))
        if dist > 0 then
            return math.min(inst.chomp_range, dist) / (10 * FRAMES)
        end
    end
    return 0
end

--------------------------------------------------------------------------

local function StartLaughing(inst)
    inst.sg.mem.laughsremaining = 10
end

local function ReduceLaughing(inst, amt)
    inst.sg.mem.laughsremaining = (inst.sg.mem.laughsremaining or 0) > amt and inst.sg.mem.laughsremaining - amt or nil
end

local function StopLaughing(inst)
    inst.sg.mem.laughsremaining = nil
end

--------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnSink(),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            ChooseAttack(inst)
        end
    end),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
            not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("chomp", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            TryChomp(inst)
        else
            inst.sg.mem.wantstochomp = true
        end
    end),
    EventHandler("enrage", function(inst)
        if not inst.enraged then
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
                inst.sg:GoToState("transition", "enrage")
            elseif not inst.sg:HasStateTag("enrage") then
                inst.sg.mem.wantstotransition = "enrage"
            end
        end
    end),
    EventHandler("transition", function(inst)
        if not inst.enraged and inst.sg.mem.wantstotransition ~= "enrage" then
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
                inst.sg:GoToState("transition", "callforhelp")
            elseif not inst.sg:HasStateTag("transition") then
                inst.sg.mem.wantstotransition = "callforhelp"
            end
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            elseif inst.sg.mem.wantstotransition ~= nil then
                inst.sg:GoToState("transition", inst.sg.mem.wantstotransition)
            elseif inst.sg.mem.laughsremaining ~= nil then
                inst.sg:GoToState("laugh_pre")
            elseif not (inst.sg.mem.wantstochomp and TryChomp(inst)) then
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                DoFoleySounds(inst, .25)
            end),
            TimeEvent(27 * FRAMES, function(inst)
                DoFoleySounds(inst, .2)
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
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/hit")
        end,

        timeline =
        {
            TimeEvent(0, DoFoleySounds),
            TimeEvent(12 * FRAMES, function(inst)
                DoFoleySounds(inst)
                DoFootstep(inst, .6)
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.health:IsDead() then
                    inst.sg:RemoveStateTag("busy")
                elseif inst.sg.mem.wantstotransition ~= nil then
                    inst.sg:GoToState("transition", inst.sg.mem.wantstotransition)
                elseif inst.sg.mem.laughsremaining ~= nil then
                    inst.sg:GoToState("laugh_pre")
                elseif not ((inst.sg.mem.wantstochomp and TryChomp(inst)) or
                            (inst.sg.statemem.doattack and ChooseAttack(inst))) then
                    inst.sg.statemem.doattack = nil
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.wantstotransition ~= nil then
                        inst.sg:GoToState("transition", inst.sg.mem.wantstotransition)
                    elseif inst.sg.mem.laughsremaining ~= nil then
                        inst.sg:GoToState("laugh_pre")
                    elseif not ((inst.sg.mem.wantstochomp and TryChomp(inst)) or
                                (inst.sg.statemem.doattack and ChooseAttack(inst))) then
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            if inst:IsUnchained() then
                inst:AddTag("NOCLICK")
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, DoFoleySounds),
            TimeEvent(3 * FRAMES, function(inst)
                DoBodyfall(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/death")
            end),
            TimeEvent(23 * FRAMES, DoFoleySounds),
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bodyfall_dirt")
                ShakeIfClose(inst)
                if inst.components.burnable:IsBurning() and inst.components.burnable.nocharring then
                    inst.components.burnable:Extinguish()
                end
            end),
            TimeEvent(27 * FRAMES, function(inst)
                if inst.enraged then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
                end
                if inst:IsUnchained() and inst.persists then
                    inst.persists = false
                    inst.components.commander:DropAllSoldierTargets()
                    local key = SpawnPrefab("klaussackkey")
                    inst:PushEvent("dropkey", key)
                    inst.components.lootdropper:FlingItem(key)
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(3, function(inst)
                if not inst:IsUnchained() then
                    inst.sg.statemem.resurrecting = true
					if inst.brain.stopped then
						inst.brain:Start()
					end
                    inst.sg:GoToState("resurrect")
                end
            end),
            TimeEvent(5, function(inst)
                if inst:IsUnchained() then
                    ErodeAway(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst:IsUnchained() and inst.AnimState:AnimDone() then
                    inst:PauseMusic(true)
                end
            end),
        },

        onexit = function(inst)
            if inst:IsUnchained() then
                --Should NOT happen!
                inst:RemoveTag("NOCLICK")
            end
            inst:PauseMusic(inst.sg.statemem.resurrecting)
        end,
    },

    State{
        name = "resurrect",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death_amulet")
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                local stafflight = SpawnPrefab("staff_castinglight")
                stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                stafflight:SetUp({ 150 / 255, 46 / 255, 46 / 255 }, 1, 20 * FRAMES)
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_raise")
            end),
            TimeEvent(39 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_poof")
            end),
            TimeEvent(48 * FRAMES, DoBodyfall),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.resurrecting = true
                    inst.sg:GoToState("resurrect_pst")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.resurrecting then
                inst.components.health:SetPercent(TUNING.KLAUS_HEALTH_REZ)
                inst:Unchain(true)
                inst:PauseMusic(false)
            end
        end,
    },

    State{
        name = "resurrect_pst",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death_pst")
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                DoFoleySounds(inst, .3)
                DoScratchSound(inst)
            end),
            TimeEvent(4 * FRAMES, DoBodyfall),
            TimeEvent(10 * FRAMES, function(inst)
                DoFoleySounds(inst, .2)
            end),
            TimeEvent(23 * FRAMES, DoFoleySounds),
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/lock_break")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_out")
            end),
            TimeEvent(26 * FRAMES, DoFoleySounds),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver(function(inst)
                inst.sg.statemem.resurrected = true
                inst.components.health:SetPercent(TUNING.KLAUS_HEALTH_REZ)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.resurrected then
                inst.components.health:SetPercent(TUNING.KLAUS_HEALTH_REZ)
            end
            inst:Unchain(true)
            inst:PauseMusic(false)
        end,
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            if inst:IsUnchained() then
                inst.sg:GoToState("taunt_roar")
            else
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("taunt1")
            end
        end,

        timeline =
        {
            TimeEvent(0, DoFoleySounds),
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_in_fast")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_in_fast", nil, .75)
            end),
            TimeEvent(12 * FRAMES, function(inst)
                DoFoleySounds(inst, .5)
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_in_fast", nil, .8)
            end),
            TimeEvent(25 * FRAMES, function(inst)
                DoFoleySounds(inst, .7)
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_in_fast")
            end),
            TimeEvent(43 * FRAMES, DoFoleySounds),
            TimeEvent(48 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        name = "taunt_roar",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt2")
        end,

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst)
                inst.sg:AddStateTag("nofreeze")
                inst.sg:AddStateTag("nosleep")
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/taunt")
            end),
            TimeEvent(14 * FRAMES, DoRoarShake),
            TimeEvent(15 * FRAMES, DoRoarAlert),
            CommonHandlers.OnNoSleepTimeEvent(56 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_doubleclaw")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
        end,

        timeline =
        {
            TimeEvent(FRAMES, DoFoleySounds),
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
            TimeEvent(13 * FRAMES, DoSwipeSound),
            TimeEvent(14 * FRAMES, DoFoleySounds),
            TimeEvent(16 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            TimeEvent(23 * FRAMES, DoSwipeSound),
            TimeEvent(24 * FRAMES, DoFoleySounds),
            TimeEvent(27 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            CommonHandlers.OnNoSleepTimeEvent(40 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "quickattack",
        tags = { "attack", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_doubleclaw")
			inst.AnimState:SetFrame(15)
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
            DoFoleySounds(inst)
            DoSwipeSound(inst)
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            TimeEvent(8 * FRAMES, DoSwipeSound),
            TimeEvent(9 * FRAMES, DoFoleySounds),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            CommonHandlers.OnNoSleepTimeEvent(25 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "attack_chomp",
        tags = { "attack", "busy", "nosleep", "nofreeze" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_chomp")
            if target ~= nil then
                inst.sg.statemem.target = target
                inst.sg.statemem.speed = CalcChompSpeed(inst, target)
            end
            inst.sg.mem.wantstochomp = nil
            inst.components.timer:StartTimer("chomp_cd", inst.chomp_cd)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.jump then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/attack_3", nil, not inst.enraged and .8 or nil)
            end),
            TimeEvent(6 * FRAMES, DoChompShake),
            TimeEvent(7 * FRAMES, DoRoarAlert),
            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                    --update in case target moved, if target still exists
                    inst.sg.statemem.speed = CalcChompSpeed(inst, inst.sg.statemem.target)
                end
                if (inst.sg.statemem.speed or 0) > 0 then
                    inst.sg.statemem.jump = true
                    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
                end
            end),
            TimeEvent(33 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bite")
            end),
            TimeEvent(34 * FRAMES, DoLanding),
            TimeEvent(35 * FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil then
                    inst.components.combat:SetRange(inst.chomp_hit_range)
                    inst.components.combat:DoAttack(inst.sg.statemem.target)
                    inst.components.combat:SetRange(inst.attack_range, inst.hit_range)
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                if inst.sg.statemem.jump then
                    inst.sg.statemem.jump = nil
                    inst.components.locomotor:Stop()
                    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                end
            end),
            CommonHandlers.OnNoSleepTimeEvent(49 * FRAMES, function(inst)
                local target = inst.components.combat.target
                if target ~= nil and
                    target:IsValid() and
                    target:IsNear(inst, inst.attack_range + target:GetPhysicsRadius(0)) then
                    inst.sg:GoToState("quickattack")
                else
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:RemoveStateTag("nosleep")
                    inst.sg:RemoveStateTag("nofreeze")
                end
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            if inst.sg.statemem.jump then
                inst.sg.statemem.jump = nil
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            end
        end,
    },

    State{
        name = "command_pre",
        tags = { "busy" },

        onenter = function(inst, deer)
            inst.sg.statemem.deer = deer
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command_pre")
            DoFoleySounds(inst, .5)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoFoleySounds),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local deer = PickCommandDeer(inst, inst.sg.statemem.deer)
                    if deer ~= nil then
                        inst.sg.mem.last_command_deer = deer
                        deer:PushEvent("deercast")
                    end
                    inst.sg:GoToState("command_loop", deer)
                end
            end),
        },
    },

    State{
        name = "command_loop",
        tags = { "busy" },

        onenter = function(inst, deer)
            inst.sg.statemem.deer = deer
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("command_loop") then
                inst.AnimState:PlayAnimation("command_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                DoFoleySounds(inst, .3)
            end),
        },

        ontimeout = function(inst)
            local deer = inst.sg.statemem.deer
            if deer ~= nil and deer:IsValid() and inst.components.commander:IsSoldier(deer) and deer.sg ~= nil then
                if deer.sg:HasStateTag("casting") then
                    inst.sg.statemem.commanding = true
                    inst.sg:GoToState("command_loop", deer)
                    return
                elseif deer.sg.mem.wantstocast then
                    if deer.sg:HasStateTag("attack") or deer.sg:HasStateTag("hit") then
                        inst.sg.statemem.commanding = true
                        inst.sg:GoToState("command_loop", deer)
                        return
                    end
                    deer.sg.mem.wantstocast = nil
                end
            end
            inst.sg:GoToState("command_pst")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.commanding then
                inst.components.timer:StopTimer("command_cd")
                inst.components.timer:StartTimer("command_cd", TUNING.KLAUS_COMMAND_CD)
            end
        end,
    },

    State{
        name = "command_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command_pst")
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, DoFoleySounds),
            TimeEvent(10 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        name = "laugh_pre",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("lol_pre")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                DoFoleySounds(inst, .3)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.laughing = true
                inst.sg:GoToState("laugh_loop")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.laughing then
                ReduceLaughing(inst, 2)
            end
        end,
    },

    State{
        name = "laugh_loop",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("lol_loop") then
                inst.AnimState:PlayAnimation("lol_loop", true)
            end
            ReduceLaughing(inst, 1)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/lol")
        end,

        timeline =
        {
            TimeEvent(0, DoFoleySounds),
            TimeEvent(13 * FRAMES, function(inst)
                DoFoleySounds(inst, .7)
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.laughing = true
            inst.sg:GoToState(inst.sg.mem.laughsremaining ~= nil and "laugh_loop" or "laugh_pst")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.laughing then
                ReduceLaughing(inst, 2)
            end
        end,
    },

    State{
        name = "laugh_pst",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("lol_pst")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        name = "transition",
        tags = { "transition", "busy", "nosleep", "nofreeze" },

        onenter = function(inst, transition)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("transform_pre")
            inst.sg.statemem.transition = inst.sg.mem.wantstotransition == "enrage" and "enrage" or transition
            if inst.sg.statemem.transition ~= nil then
                inst.sg:AddStateTag(inst.sg.statemem.transition)
                if inst.sg.statemem.transition == "callforhelp" and not inst:SummonHelpers(true) then
                    inst.sg.statemem.transition = nil
                    inst.sg:RemoveStateTag("callforhelp")
                end
            end
            inst.sg.mem.wantstotransition = nil
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, DoFoleySounds),
            TimeEvent(9 * FRAMES, DoBodyfall),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("transition_loop", inst.sg.statemem.transition)
                end
            end),
        },
    },

    State{
        name = "transition_loop",
        tags = { "transition", "busy", "nosleep", "nofreeze" },

        onenter = function(inst, transition)
            if not inst.AnimState:IsCurrentAnimation("transform_loop") then
                inst.AnimState:PlayAnimation("transform_loop", true)
            end
            inst.sg.statemem.transition = inst.sg.mem.wantstotransition == "enrage" and "enrage" or transition
            if inst.sg.statemem.transition ~= nil then
                inst.sg:AddStateTag(inst.sg.statemem.transition)
            end
            inst.sg.mem.wantstotransition = nil
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, DoFoleySounds),
            TimeEvent(29 * FRAMES, function(inst)
                DoFoleySounds(inst, .6)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState(
                (inst.sg.statemem.transition == "enrage" and "transition_enrage") or
                (inst.sg.statemem.transition == "callforhelp" and "transition_loop") or
                "transition_pst"
            )
        end,
    },

    State{
        name = "transition_pst",
        tags = { "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("transform_pst2")
            local x, y, z = inst.Transform:GetWorldPosition()
            for i, v in ipairs(TheSim:FindEntities(x, y, z, 30, TRANSITION_PST_MUST_TAGS, TRANSITION_PST_CANT_TAGS)) do
                if not v.components.health:IsDead() and inst.components.grouptargeter:IsTargeting(v.components.combat.target) then
                    StartLaughing(inst)
                    break
                end
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                DoFoleySounds(inst, .4)
            end),
            CommonHandlers.OnNoSleepTimeEvent(7 * FRAMES, function(inst)
                DoFootstep(inst, .5)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "transition_enrage",
        tags = { "enrage", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("transform_pst")
            --Cancel all other transitions when enraged
            inst.sg.mem.wantstotransition = nil
        end,

        timeline =
        {
            TimeEvent(FRAMES, DoFoleySounds),
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_poof")
                inst:Enrage(true)
                DoFootstep(inst, .5)
            end),
            TimeEvent(6 * FRAMES, DoFoleySounds),
            CommonHandlers.OnNoSleepTimeEvent(25 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            inst:Enrage(true)
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(8 * FRAMES, DoFoleySounds),
        TimeEvent(9 * FRAMES, DoFootstep),
    },
    walktimeline =
    {
        TimeEvent(20 * FRAMES, DoFoleySounds),
        TimeEvent(21 * FRAMES, DoFootstep),
        TimeEvent(44 * FRAMES, DoFoleySounds),
        TimeEvent(45 * FRAMES, DoFootstep),
    },
    endtimeline =
    {
        TimeEvent(0, function(inst)
            DoFoleySounds(inst)
            DoFootstep(inst, .6)
        end),
        TimeEvent(10 * FRAMES, DoFoleySounds),
    },
})

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(7 * FRAMES, DoScratchSound),
        TimeEvent(14 * FRAMES, function(inst)
            DoFoleySounds(inst, .5)
            DoScratchSound(inst)
        end),
        TimeEvent(19 * FRAMES, DoScratchSound),
        TimeEvent(24 * FRAMES, DoScratchSound),
        TimeEvent(29 * FRAMES, DoScratchSound),
        TimeEvent(33 * FRAMES, function(inst)
            DoFoleySounds(inst, .5)
        end),
        TimeEvent(34 * FRAMES, DoScratchSound),
        TimeEvent(39 * FRAMES, DoScratchSound),
        TimeEvent(55 * FRAMES, function(inst)
            DoFootstep(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_out", nil, .5)
        end),
        TimeEvent(57 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
            DoFoleySounds(inst)
        end),
        TimeEvent(58 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bodyfall")
        end),
        TimeEvent(60 * FRAMES, ShakeIfClose),
    },
    sleeptimeline =
    {
        TimeEvent(0, function(inst)
            DoFoleySounds(inst, .3)
        end),
        TimeEvent(7 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_in")
        end),
        TimeEvent(29 * FRAMES, function(inst)
            DoFoleySounds(inst, .2)
        end),
        TimeEvent(32 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/breath_out")
        end),
    },
    waketimeline =
    {
        TimeEvent(0, function(inst)
            DoFoleySounds(inst, .3)
        end),
        TimeEvent(3 * FRAMES, DoBodyfall),
        CommonHandlers.OnNoSleepTimeEvent(23 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("nosleep")
        end),
        TimeEvent(24 * FRAMES, DoFoleySounds),
    },
},
{
    onsleep = function(inst)
        inst.sg:AddStateTag("caninterrupt")
        DoFoleySounds(inst, .3)
    end,
    onexitsleep = StopLaughing,
    onexitsleeping = StopLaughing,
    onexitwake = StopLaughing,
})

CommonStates.AddFrozenStates(states, nil, StopLaughing)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("SGklaus", states, events, "idle")
