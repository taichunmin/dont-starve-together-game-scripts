require("stategraphs/commonstates")

--------------------------------------------------------------------------
local FOCUSTARGET_MUST_TAGS = { "_combat", "_health" }
local FOCUSTARGET_CANT_TAGS = { "INLIMBO", "player", "bee", "notarget", "invisible", "flight" }

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, .15, inst, 30)
end

local function StartFlapping(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/wings_LP", "flying")
end

local function RestoreFlapping(inst)
    if not inst.SoundEmitter:PlayingSound("flying") then
        StartFlapping(inst)
    end
end

local function StopFlapping(inst)
    inst.SoundEmitter:KillSound("flying")
end

local function DoScreech(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1, .015, .3, inst, 30)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/taunt")
end

local function DoScreechAlert(inst)
    inst.components.epicscare:Scare(5)
    inst.components.commander:AlertAllSoldiers()
end

--------------------------------------------------------------------------

local function ChooseAttack(inst)
    inst.sg:GoToState("attack")
    return true
end

local function FaceTarget(inst)
    local target = inst.components.combat.target
    if inst.sg.mem.focustargets ~= nil then
        local mindistsq = math.huge
        for i = #inst.sg.mem.focustargets, 1, -1 do
            local v = inst.sg.mem.focustargets[i]
            if v:IsValid() and v.components.health ~= nil and not v.components.health:IsDead() and not v:HasTag("playerghost") then
                local distsq = inst:GetDistanceSqToInst(v)
                if distsq < mindistsq then
                    mindistsq = distsq
                    target = v
                end
            else
                table.remove(inst.sg.mem.focustargets, i)
                if #inst.sg.mem.focustargets <= 0 then
                    inst.sg.mem.focustargets = nil
                    break
                end
            end
        end
    end
    if target ~= nil and target:IsValid() then
        inst:ForceFacePoint(target.Transform:GetWorldPosition())
    end
end

--------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            ChooseAttack(inst)
        end
    end),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
            not CommonHandlers.HitRecoveryDelay(inst, nil, TUNING.BEEQUEEN_MAX_STUN_LOCKS) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("screech", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("screech")
        elseif not inst.sg:HasStateTag("screech") then
            inst.sg.mem.wantstoscreech = true
        end
    end),
    EventHandler("spawnguards", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("spawnguards")
        elseif not inst.sg:HasStateTag("spawnguards") then
            inst.sg.mem.wantstospawnguards = true
        end
    end),
    EventHandler("focustarget", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("focustarget")
        elseif not inst.sg:HasStateTag("focustarget") then
            inst.sg.mem.wantstofocustarget = true
        end
    end),
    EventHandler("flee", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("flyaway")
        else
            inst.sg.mem.wantstoflyaway = true
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.sg.mem.wantstoscreech then
                inst.sg:GoToState("screech")
            elseif inst.sg.mem.wantstoflyaway then
                inst.sg:GoToState("flyaway")
            elseif inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            elseif inst.sg.mem.focuscount ~= nil then
                inst.sg:GoToState("focustarget_loop")
            elseif inst.sg.mem.wantstospawnguards then
                inst.sg:GoToState("spawnguards")
            elseif inst.sg.mem.wantstofocustarget then
                inst.sg:GoToState("focustarget")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/breath")
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
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/breath")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
        end,

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
        name = "emerge",
        tags = { "busy", "nosleep", "nofreeze", "noattack" },

        onenter = function(inst)
            StopFlapping(inst)
            inst.Transform:SetNoFaced()
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/enter")
            inst.sg.mem.wantstoscreech = true
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, ShakeIfClose),
            TimeEvent(31 * FRAMES, DoScreech),
            TimeEvent(32 * FRAMES, DoScreechAlert),
            TimeEvent(35 * FRAMES, StartFlapping),
            CommonHandlers.OnNoSleepTimeEvent(54 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
                inst.sg:RemoveStateTag("noattack")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("screech"),
        },

        onexit = function(inst)
            RestoreFlapping(inst)
            inst.Transform:SetSixFaced()
            inst.components.health:SetInvincible(false)
        end,
    },

    State{
        name = "flyaway",
        tags = { "busy", "nosleep", "nofreeze", "flight" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop")
            inst.DynamicShadow:Enable(false)
            inst:StopHoney()
            inst.sg.statemem.vel = Vector3(math.random() * 4, 7 + math.random() * 2, 0)
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVel(inst.sg.statemem.vel:Get())
        end,

        timeline =
        {
            TimeEvent(.3, function(inst)
                if inst.sg.mem.focuscount ~= nil then
                    inst.sg.mem.focuscount = nil
                    inst.sg.mem.focustargets = nil
                    inst.components.sanityaura.aura = 0
                    for i, v in ipairs(inst.components.commander:GetAllSoldiers()) do
                        v:FocusTarget(nil)
                    end
                    inst:BoostCommanderRange(false)
                end
                inst.components.commander:PushEventToAllSoldiers("flee")
            end),
            TimeEvent(3.5, function(inst)
                inst:Remove()
            end),
        },

        onexit = function(inst)
            --Should NOT happen!
            if inst.sg.mem.focuscount ~= nil then
                inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            end
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            inst:StartHoney()
        end,
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/hit")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.doattack then
                    if not inst.components.health:IsDead() and ChooseAttack(inst) then
                        return
                    end
                    inst.sg.statemem.doattack = nil
                end
                inst.sg:RemoveStateTag("busy")
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
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst:AddTag("NOCLICK")
            inst.SoundEmitter:KillSound("flying")
            inst:StopHoney()
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, DoScreech),
            TimeEvent(15 * FRAMES, DoScreechAlert),
            TimeEvent(28 * FRAMES, function(inst)
                LandFlyingCreature(inst)
                inst.components.sanityaura.aura = 0
                inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
                ShakeIfClose(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                    if inst.hivebase ~= nil then
                        inst.hivebase.queenkilled = true
                    end
                end
            end),
            TimeEvent(3, function(inst)
                if inst.sg.mem.focuscount ~= nil then
                    inst.sg.mem.focuscount = nil
                    inst.sg.mem.focustargets = nil
                    for i, v in ipairs(inst.components.commander:GetAllSoldiers()) do
                        v:FocusTarget(nil)
                    end
                    inst:BoostCommanderRange(false)
                end
            end),
            TimeEvent(5, function(inst)
                ErodeAway(inst)
                RaiseFlyingCreature(inst)
            end),
        },

        onexit = function(inst)
            --Should NOT happen!
            if inst.sg.mem.focuscount ~= nil then
                inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            end
            inst:RemoveTag("NOCLICK")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/wings_LP", "flying")
            inst:StartHoney()
        end,
    },

    State{
        name = "screech",
        tags = { "screech", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("screech")
            inst.sg.mem.wantstoscreech = nil
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(33 * FRAMES, DoScreech),
            TimeEvent(34 * FRAMES, DoScreechAlert),
            CommonHandlers.OnNoSleepTimeEvent(57 * FRAMES, function(inst)
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
        tags = { "attack", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            CommonHandlers.OnNoSleepTimeEvent(23 * FRAMES, function(inst)
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
        name = "spawnguards",
        tags = { "spawnguards", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("spawn")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/spawn")
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                inst.sg.mem.wantstospawnguards = nil
                if inst.spawnguards_chain < inst.spawnguards_maxchain then
                    inst.spawnguards_chain = inst.spawnguards_chain + 1
                else
                    inst.spawnguards_chain = 0
                    inst.components.timer:StartTimer("spawnguards_cd", inst.spawnguards_cd)
                end

                local oldnum = inst.components.commander:GetNumSoldiers()
                local x, y, z = inst.Transform:GetWorldPosition()
                local rot = inst.Transform:GetRotation()
                local num = math.random(TUNING.BEEQUEEN_MIN_GUARDS_PER_SPAWN, TUNING.BEEQUEEN_MAX_GUARDS_PER_SPAWN)
                if num + oldnum > TUNING.BEEQUEEN_TOTAL_GUARDS then
                    num = math.max(TUNING.BEEQUEEN_MIN_GUARDS_PER_SPAWN, TUNING.BEEQUEEN_TOTAL_GUARDS - oldnum)
                end
                local drot = 360 / num
                for i = 1, num do
                    local minion = SpawnPrefab("beeguard")
                    local angle = rot + i * drot
                    local radius = minion:GetPhysicsRadius(0)
                    minion.Transform:SetRotation(angle)
                    angle = -angle * DEGREES
                    minion.Transform:SetPosition(x + radius * math.cos(angle), 0, z + radius * math.sin(angle))
                    minion:OnSpawnedGuard(inst)
                end

                if oldnum > 0 then
                    local soldiers = inst.components.commander:GetAllSoldiers()
                    num = #soldiers
                    drot = 360 / num
                    for i = 1, num do
                        local angle = -(rot + i * drot) * DEGREES
                        local xoffs = TUNING.BEEGUARD_GUARD_RANGE * math.cos(angle)
                        local zoffs = TUNING.BEEGUARD_GUARD_RANGE * math.sin(angle)
                        local mindistsq = math.huge
                        local closest = 1
                        for i2, v in ipairs(soldiers) do
                            local offset = v.components.knownlocations:GetLocation("queenoffset")
                            if offset ~= nil then
                                local distsq = distsq(xoffs, zoffs, offset.x, offset.z)
                                if distsq < mindistsq then
                                    mindistsq = distsq
                                    closest = i2
                                end
                            end
                        end
                        table.remove(soldiers, closest).components.knownlocations:RememberLocation("queenoffset", Vector3(xoffs, 0, zoffs), false)
                    end
                end
            end),
            CommonHandlers.OnNoSleepTimeEvent(32 * FRAMES, function(inst)
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
        name = "focustarget",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command2")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.sg.mem.wantstofocustarget = nil
                inst.sg.mem.focuscount = 0
                inst.sg.mem.focustargets = nil
                inst.components.timer:StartTimer("focustarget_cd", inst.focustarget_cd)

                local soldiers = inst.components.commander:GetAllSoldiers()
                if #soldiers > 0 then
                    local players = {}
                    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
                        if inst:IsNear(k, TUNING.BEEQUEEN_FOCUSTARGET_RANGE) then
                            table.insert(players, k)
                        end
                    end
                    local maxtargets = math.max(1, math.floor(#soldiers / TUNING.BEEGUARD_SQUAD_SIZE))
                    local targets = {}
                    for i = 1, maxtargets do
                        if #players > 0 then
                            table.insert(targets, table.remove(players, math.random(#players)))
                        else
                            if inst.components.combat.target ~= nil and not inst.components.combat.target:HasTag("player") then
                                table.insert(targets, inst.components.combat.target)
                            end
                            break
                        end
                    end
                    if #targets < maxtargets then
                        local x, y, z = inst.Transform:GetWorldPosition()
                        for i, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.BEEQUEEN_FOCUSTARGET_RANGE, FOCUSTARGET_MUST_TAGS, FOCUSTARGET_CANT_TAGS)) do
                            if v.components.combat.target == inst and not v.components.health:IsDead() then
                                table.insert(targets, v)
                                if #targets >= maxtargets then
                                    break
                                end
                            end
                        end
                    end
                    if #targets > 1 then
                        local sorted = {}
                        for i, v in ipairs(soldiers) do
                            local dists = {}
                            local totaldist = 0
                            for i1, v1 in ipairs(targets) do
                                local distsq = v:GetDistanceSqToInst(v1)
                                table.insert(dists, distsq)
                                totaldist = totaldist + distsq
                            end
                            for i1, v1 in ipairs(dists) do
                                dists[i1] = v1 / totaldist
                            end
                            table.insert(sorted, { inst = v, scores = dists })
                        end
                        for i, v in ipairs(targets) do
                            table.sort(sorted, function(a, b) return a.scores[i] < b.scores[i] end)
                            local squadsize = math.max(#sorted / (#targets - i + 1))
                            for i1 = 1, squadsize do
                                table.remove(sorted, 1).inst:FocusTarget(v)
                            end
                        end
                        inst.sg.mem.focustargets = targets
                        inst:BoostCommanderRange(true)
                    elseif #targets > 0 then
                        for i, v in ipairs(soldiers) do
                            v:FocusTarget(targets[1])
                        end
                        inst.sg.mem.focustargets = targets
                        inst:BoostCommanderRange(true)
                    end
                end
            end),
            CommonHandlers.OnNoSleepTimeEvent(25 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("focustarget_loop"),
        },

        onexit = function(inst)
            if inst.sg.mem.focuscount == nil then
                inst.components.sanityaura.aura = 0
            end
        end,
    },

    State{
        name = "focustarget_loop",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            if inst.sg.mem.focuscount >= 3 or
                inst.sg.mem.focustargets == nil or
                inst.components.commander:GetNumSoldiers() <= 0 then
                inst.sg:GoToState("focustarget_pst")
            else
                inst.sg.statemem.variation = (inst.sg.mem.focuscount % 2) + 1
                inst.sg.mem.focuscount = inst.sg.mem.focuscount + 1
                inst.components.locomotor:StopMoving()
                if inst.sg.statemem.variation > 1 then
                    inst.sg:GoToState("focustarget_loop2")
                else
                    inst.AnimState:PlayAnimation("command1")
                end
            end
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            TimeEvent(7 * FRAMES, DoScreech),
            TimeEvent(8 * FRAMES, DoScreechAlert),
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            TimeEvent(22 * FRAMES, DoScreech),
            TimeEvent(23 * FRAMES, DoScreechAlert),
            CommonHandlers.OnNoSleepTimeEvent(35 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("focustarget_loop"),
        },
    },

    State{
        name = "focustarget_loop2",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("command2")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            CommonHandlers.OnNoSleepTimeEvent(25 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("focustarget_loop"),
        },
    },

    State{
        name = "focustarget_pst",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.sg.mem.focuscount = nil
            inst.sg.mem.focustargets = nil
            if inst.components.commander:GetNumSoldiers() <= 0 then
                inst.sg.statemem.ended = true
                inst.components.sanityaura.aura = 0
                inst:BoostCommanderRange(false)
                inst.sg:GoToState("idle")
            else
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("command3")
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(19 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            TimeEvent(23 * FRAMES, function(inst)
                inst.sg.statemem.ended = true
                inst.components.sanityaura.aura = 0
                for i, v in ipairs(inst.components.commander:GetAllSoldiers()) do
                    v:FocusTarget(nil)
                end
                inst:BoostCommanderRange(false)
            end),
            CommonHandlers.OnNoSleepTimeEvent(32 * FRAMES, function(inst)
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
            if not inst.sg.statemem.ended then
                inst.components.sanityaura.aura = 0
                for i, v in ipairs(inst.components.commander:GetAllSoldiers()) do
                    v:FocusTarget(nil)
                end
                inst:BoostCommanderRange(false)
            end
        end,
    },
}

local function CleanupIfSleepInterrupted(inst)
    if not inst.sg.statemem.continuesleeping then
        RestoreFlapping(inst)
        inst:StartHoney()
    end
    RaiseFlyingCreature(inst)
end
CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(8 * FRAMES, StopFlapping),
        TimeEvent(28 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
            inst.components.sanityaura.aura = 0
            LandFlyingCreature(inst)
        end),
        TimeEvent(31 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
            inst:StopHoney()
            ShakeIfClose(inst)
        end),
    },
    waketimeline =
    {
        TimeEvent(19 * FRAMES, StartFlapping),
        CommonHandlers.OnNoSleepTimeEvent(24 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("nosleep")
            RaiseFlyingCreature(inst)
        end),
    },
},
{
    onsleep = function(inst)
        inst.sg:AddStateTag("caninterrupt")
        inst.sg.mem.wantstododge = true
        inst.sg.mem.wantstoalert = true
    end,
    onexitsleep = CleanupIfSleepInterrupted,
    onsleeping = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/sleep")
        LandFlyingCreature(inst)
    end,
    onexitsleeping = CleanupIfSleepInterrupted,
    onwake = function(inst)
        StopFlapping(inst)
        inst:StartHoney()
        LandFlyingCreature(inst)
    end,
    onexitwake = function(inst)
        RestoreFlapping(inst)
        RaiseFlyingCreature(inst)
    end,
})

local function OnOverrideFrozenSymbols(inst)
    inst.components.sanityaura.aura = 0
    StopFlapping(inst)
    inst:StopHoney()
    inst.sg.mem.wantstododge = true
    inst.sg.mem.wantstoalert = true
    LandFlyingCreature(inst)
end
local function OnClearFrozenSymbols(inst)
    StartFlapping(inst)
    inst:StartHoney()
    RaiseFlyingCreature(inst)
end
CommonStates.AddFrozenStates(states, OnOverrideFrozenSymbols, OnClearFrozenSymbols)

return StateGraph("SGbeequeen", states, events, "idle")
