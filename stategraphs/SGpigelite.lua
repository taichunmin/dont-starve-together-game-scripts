require("stategraphs/commonstates")

local PICK_PROP_RANGE = 1 + .1 --with error
local PICK_GOLD_RANGE = 1
local GOLD_DIVE_RANGE_CLAMPED = 4.5
local GOLD_DIVE_RANGE = GOLD_DIVE_RANGE_CLAMPED + .1 --with error
local POSING_MASS = 5000
local DEFAULT_MASS = 50

local DOAOEATTACK_TARGET_MUST_HAVE = { "_combat" }
local DOAOEATTACK_TARGET_CANT_HAVE = { "flying", "shadow", "ghost", "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }
local ENDPOSE_PRE_TARGET_MUST_TAGS = { "pigelite" }

local function IsMinigameItem(inst)
    return inst:HasTag("minigameitem")
end

local events =
{
    CommonHandlers.OnAttack(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),

    EventHandler("locomote", function(inst)
        local can_run = true
        local can_walk = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil

        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()

        if is_moving and not should_move then
            inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
            if can_run and (should_run or not can_walk) then
                inst.sg:GoToState("run_start")
            elseif can_walk then
                inst.sg:GoToState("walk_start")
            end
        end
    end),
    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() and
            (   inst.sg:HasStateTag("frozen") or
                (   (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
                    (   data ~= nil and
                        data.weapon ~= nil and
                        data.weapon:HasTag("propweapon") or
                        (inst.sg.mem.last_hit_time or 0) + TUNING.PIG_ELITE_HIT_RECOVERY < GetTime()
                    )
                )
            ) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("knockback", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("knockback", data)
        end
    end),
    EventHandler("pickprop", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("pickprop", data.prop)
        end
    end),
    EventHandler("diveitem", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) and data.item ~= nil and data.item:IsValid() and not data.item:IsInLimbo() and inst:IsNear(data.item, GOLD_DIVE_RANGE) then
            if not inst.sg:HasStateTag("nodive") then
                inst.sg:GoToState("dive", data.item)
            elseif inst.sg:HasStateTag("running") and inst:IsNear(data.item, GOLD_DIVE_RANGE * .5) then
                inst.sg:GoToState("run_stop", data.item)
            else
                inst.sg.statemem.diveitem = data.item
            end
        end
    end),
    EventHandler("matchover", function(inst)
        if inst.sg:HasStateTag("idle") and not inst.components.health:IsDead() then
            inst.sg:GoToState("endpose_pre")
        end
    end),
}

local function DoAOEAttack(inst, dist, radius)
    local hit = false
    inst.components.combat.ignorehitrange = true
    local x0, y0, z0 = inst.Transform:GetWorldPosition()
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local sinangle = math.sin(angle)
    local cosangle = math.cos(angle)
    local x = x0 + dist * sinangle
    local z = z0 + dist * cosangle
    for i, v in ipairs(TheSim:FindEntities(x, y0, z, radius + 3, DOAOEATTACK_TARGET_MUST_HAVE, DOAOEATTACK_TARGET_CANT_HAVE)) do
        if v:IsValid() and not v:IsInLimbo() and
            not (v.components.health ~= nil and v.components.health:IsDead()) then
            local range = radius + v:GetPhysicsRadius(.5)
            if v:GetDistanceSqToPoint(x, y0, z) < range * range and inst.components.combat:CanTarget(v) then
                --dummy redirected so that players don't get red blood flash
                v:PushEvent("attacked", { attacker = inst, damage = 0, redirected = v })
                v:PushEvent("knockback", { knocker = inst, radius = radius + dist, propsmashed = true })
                hit = true
            end
        end
    end
    inst.components.combat.ignorehitrange = false
    if hit then
        local prop = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if prop ~= nil then
            dist = dist + radius - .5
            return { prop = prop, pos = Vector3(x0 + dist * sinangle, y0, z0 + dist * cosangle) }
        end
    end
end

local function CanTakeItem(inst, item, range)
    return item ~= nil and item:IsValid() and not item:IsInLimbo() and inst:IsNear(item, range)
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            else
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("idle_object_loop", true)
            end
        end,
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_object_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst, diveitem)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("run_object_loop") then
                inst.AnimState:PlayAnimation("run_object_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            inst.sg.statemem.diveitem = diveitem
        end,

        timeline =
        {
            TimeEvent(0, PlayFootstep),
            TimeEvent(FRAMES, function(inst)
                if CanTakeItem(inst, inst.sg.statemem.diveitem, GOLD_DIVE_RANGE) then
                    inst.sg:GoToState("dive", inst.sg.statemem.diveitem)
                else
                    inst.sg.statemem.diveitem = nil
                end
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.sg:AddStateTag("nodive")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nodive")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if CanTakeItem(inst, inst.sg.statemem.diveitem, GOLD_DIVE_RANGE) then
                    inst.sg:GoToState("dive", inst.sg.statemem.diveitem)
                else
                    inst.sg.statemem.diveitem = nil
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                PlayFootstep(inst)
                inst.sg:AddStateTag("nodive")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run", inst.sg.statemem.diveitem)
        end,
    },

    State{
        name = "run_stop",
        tags = { "idle" },

        onenter = function(inst, diveitem)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("run_object_pst")
            inst.sg.statemem.diveitem = diveitem
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                if CanTakeItem(inst, inst.sg.statemem.diveitem, GOLD_DIVE_RANGE) then
                    inst.sg:GoToState("dive", inst.sg.statemem.diveitem)
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
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.sg.mem.last_hit_time = GetTime()
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
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
        name = "knockback",
        tags = { "knockback", "busy", "nosleep", "nofreeze", "jumping" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("smacked")

            if data ~= nil then
                if data.propsmashed then
                    local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    local pos
                    if item ~= nil then
                        pos = inst:GetPosition()
                        pos.y = TUNING.KNOCKBACK_DROP_ITEM_HEIGHT_HIGH
                        local dropped = inst.components.inventory:DropItem(item, true, true, pos)
                        if dropped ~= nil then
                            dropped:PushEvent("knockbackdropped", { owner = inst, knocker = data.knocker, delayinteraction = TUNING.KNOCKBACK_DELAY_INTERACTION_HIGH, delayplayerinteraction = TUNING.KNOCKBACK_DELAY_PLAYER_INTERACTION_HIGH })
                        end
                    end
                    if item == nil or not item:HasTag("propweapon") then
                        item = inst.components.inventory:FindItem(IsMinigameItem)
                        if item ~= nil then
                            pos = pos or inst:GetPosition()
                            pos.y = TUNING.KNOCKBACK_DROP_ITEM_HEIGHT_LOW
                            item = inst.components.inventory:DropItem(item, false, true, pos)
                            if item ~= nil then
                                item:PushEvent("knockbackdropped", { owner = inst, knocker = data.knocker, delayinteraction = TUNING.KNOCKBACK_DELAY_INTERACTION_LOW, delayplayerinteraction = TUNING.KNOCKBACK_DELAY_PLAYER_INTERACTION_LOW })
                            end
                        end
                    end
                end
                if data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                    inst.sg.statemem.speed = (data.strengthmult or 1) * 10 * k
                    inst.sg.statemem.dspeed = 0
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .075
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/scream") end),
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt") end),
            TimeEvent(14 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nofreeze")
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.components.sleeper:WakeUp()
                inst.sg:RemoveStateTag("nosleep")
            end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "attack",
        tags = { "propattack", "attack", "busy" },

        onenter = function(inst, target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.AnimState:PlayAnimation("atk_object")
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.target = target
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg.statemem.smashed = DoAOEAttack(inst, .8, 1.7)
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.smashed ~= nil then
                    local smashed = inst.sg.statemem.smashed
                    inst.sg.statemem.smashed = nil
                    smashed.prop:PushEvent("propsmashed", smashed.pos)
                end
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
                inst.sg:AddStateTag("idle")
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
            if inst.sg.statemem.smashed ~= nil then
                inst.sg.statemem.smashed.prop:PushEvent("propsmashed", inst.sg.statemem.smashed.pos)
            end
        end,
    },

    State{
        name = "pickprop",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst, prop)
            if CanTakeItem(inst, prop, PICK_PROP_RANGE) then
                inst.components.locomotor:Stop()
                inst.components.inventory:DropItem(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
                inst.AnimState:PlayAnimation("pick")
                inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
                inst:ForceFacePoint(prop.Transform:GetWorldPosition())
                inst.sg.statemem.prop = prop
            else
                inst.sg:GoToState("idle")
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                if CanTakeItem(inst, inst.sg.statemem.prop, PICK_PROP_RANGE) then
                    inst.components.inventory:DropItem(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
                    inst.components.inventory:Equip(inst.sg.statemem.prop)
                else
                    inst.sg:GoToState("idle")
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:AddStateTag("idle")
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
        name = "dive",
        tags = { "busy", "jumping", "nosleep", "nofreeze" },

        onenter = function(inst, item)
            if CanTakeItem(inst, item, GOLD_DIVE_RANGE) then
                inst.components.locomotor:Stop()
                inst.components.inventory:DropItem(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
                inst.AnimState:PlayAnimation("slide")
                inst.SoundEmitter:PlaySound("dontstarve/pig/hit")
                inst.sg.statemem.item = item
                local x, y, z = inst.Transform:GetWorldPosition()
                local x1, y1, z1 = item.Transform:GetWorldPosition()
                local dx, dz = x1 - x, z1 - z
                local l = dx * dx + dz * dz
                if l > GOLD_DIVE_RANGE_CLAMPED * GOLD_DIVE_RANGE_CLAMPED then
                    l = GOLD_DIVE_RANGE_CLAMPED / math.sqrt(l)
                    x1 = x + dx * l
                    z1 = z + dz * l
                end
                if x ~= x1 or z ~= z1 then
                    inst:ForceFacePoint(x1, y1, z1)
                    inst.sg.statemem.speed = math.sqrt(distsq(x, z, x1, z1)) / (10 * FRAMES)
                    ToggleOffCharacterCollisions(inst)
                    inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
                end
                PlayFootstep(inst)
            else
                inst.sg:GoToState("idle")
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speedmult ~= nil then
                if inst.sg.statemem.speedmult == false then
                    inst.sg:RemoveStateTag("jumping")
                    inst.sg.statemem.speedmult = nil
                elseif inst.sg.statemem.speedmult > 0 then
                    inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * inst.sg.statemem.speedmult, 0, 0)
                    inst.sg.statemem.speedmult = inst.sg.statemem.speedmult - .06
                else
                    inst.Physics:ClearMotorVelOverride()
                    inst.Physics:Stop()
                    inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                    ToggleOnCharacterCollisions(inst)
                    inst.sg.statemem.speedmult = false
                end
            end
            if inst.sg.statemem.pick and CanTakeItem(inst, inst.sg.statemem.item, PICK_GOLD_RANGE) then
                inst.components.inventory:GiveItem(inst.sg.statemem.item)
            end
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                SpawnPrefab("slide_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.speed ~= nil then
                    inst.sg.statemem.speedmult = .5
                end
                PlayFootstep(inst, .6)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide_dirt", "slide")
            end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nofreeze")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg.statemem.pick = true
            end),
            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("slide")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                inst.sg.statemem.pick = nil
            end),
            CommonHandlers.OnNoSleepTimeEvent(22 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            --don't use nil check because if it's false also don't need to cancel
            if inst.sg.statemem.speedmult then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
            ToggleOnCharacterCollisions(inst)
            inst.SoundEmitter:KillSound("slide")
        end,
    },

    State{
        name = "flipout",
        tags = { "intropose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation(inst.sg.mem.variation == "3" and "side_lob" or "front_lob")
            inst.AnimState:PushAnimation("pose"..inst.sg.mem.variation.."_pre", false)
            inst.SoundEmitter:PlaySound("dontstarve/movement/twirl_LP", "twirl")
            if data ~= nil then
                if data.dest ~= nil then
                    ToggleOffAllObjectCollisions(inst)
                    inst:ForceFacePoint(data.dest)
                    inst.Physics:SetMotorVelOverride(math.sqrt(inst:GetDistanceSqToPoint(data.dest)) / (22 * FRAMES), 0, 0)
                    inst.Physics:SetMass(POSING_MASS)
                end
                inst.sg.statemem.strtbl = data.strtbl
                inst.sg.statemem.strid = data.strid
            end
            inst.sg:SetTimeout(
                (inst.sg.mem.variation == "1" and (21 + 15) * FRAMES) or
                (inst.sg.mem.variation == "2" and (21 + 13) * FRAMES) or
                (inst.sg.mem.variation == "3" and (21 + 9) * FRAMES) or
                (21 + 10) * FRAMES
            )
        end,

        timeline =
        {
            --lob is 21 frames
            TimeEvent(20.5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt") end),
            TimeEvent(21.5 * FRAMES, PlayFootstep),
            TimeEvent(22 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("twirl")
                if inst.sg.mem.isobstaclepassthrough then
                    inst.Physics:ClearMotorVelOverride()
                    inst.Physics:Stop()
                    local x, y, z = inst.Transform:GetWorldPosition()
                    ToggleOnAllObjectCollisionsAt(inst, x, z)
                end
                inst.sg:RemoveStateTag("jumping")
            end),
        },

        ontimeout = function(inst)
            if inst.sg.statemem.strtbl ~= nil and inst.sg.statemem.strid ~= nil then
                inst.components.talker:Chatter(inst.sg.statemem.strtbl, inst.sg.statemem.strid)
            else
                inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.posing = true
                    inst.sg:GoToState("pose", inst.sg.statemem.strid)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.mem.isobstaclepassthrough then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                local x, y, z = inst.Transform:GetWorldPosition()
                ToggleOnAllObjectCollisionsAt(inst, x, z)
            end
            inst.SoundEmitter:KillSound("twirl")
            if not inst.sg.statemem.posing then
                inst.Physics:SetMass(DEFAULT_MASS)
            end
        end,
    },

    State{
        name = "pose",
        tags = { "intropose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },
        --jumping tag to disable brain activity

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pose"..inst.sg.mem.variation.."_loop", true)
            inst.Physics:SetMass(POSING_MASS)
        end,

        events =
        {
            EventHandler("introover", function(inst)
                if inst.sg.mem.sleeping then
                    inst.sg:GoToState("sleep")
                else
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:RemoveStateTag("nofreeze")
                    inst.sg:RemoveStateTag("nosleep")
                    inst.sg:RemoveStateTag("noattack")
                    inst.sg:RemoveStateTag("jumping")
                    inst.sg:AddStateTag("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:SetMass(DEFAULT_MASS)
        end,
    },

    State{
        name = "endpose_pre",
        tags = { "endpose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },
        --jumping tag to disable brain activity

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.inventory:DropItem(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
            inst.AnimState:PlayAnimation("idletopose"..inst.sg.mem.variation)
            inst.sg:SetTimeout(
                (inst.sg.mem.variation == "1" and 19 * FRAMES) or
                (inst.sg.mem.variation == "2" and 18 * FRAMES) or
                (inst.sg.mem.variation == "3" and 14 * FRAMES) or
                15 * FRAMES
            )
            inst.Physics:SetMass(POSING_MASS)
        end,

        ontimeout = function(inst)
            local king = inst.components.entitytracker:GetEntity("king")
            if king == nil then
                inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
                return
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            for i ,v in ipairs(TheSim:FindEntities(x, y, z, 6, ENDPOSE_PRE_TARGET_MUST_TAGS)) do
                if v.sg.mem.postchatter then
                    inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
                    return
                end
            end

            inst.components.talker:Chatter("PIG_ELITE_POST_MATCH", not TheWorld.state.isday and 5 or king:GetMinigameScore())
            inst.sg.mem.postchatter = true
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.posing = true
                    inst.sg:GoToState("endpose_loop")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.posing then
                inst.Physics:SetMass(DEFAULT_MASS)
            end
        end,
    },

    State{
        name = "endpose_loop",
        tags = { "endpose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },
        --jumping tag to disable brain activity

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pose"..inst.sg.mem.variation.."_loop", true)
            inst.sg:SetTimeout(2)
            inst.Physics:SetMass(POSING_MASS)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.posing = true
            inst.sg:GoToState("endpose_jump")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.posing then
                inst.Physics:SetMass(DEFAULT_MASS)
            end
        end,
    },

    State{
        name = "endpose_jump",
        tags = { "endpose", "busy", "nofreeze", "nosleep", "noattack", "jumping" },
        --jumping tag to disable brain activity

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:AddOverrideBuild("player_superjump")
            inst.AnimState:PlayAnimation("superjump_pre")
            inst.AnimState:PushAnimation("superjump", false)
            ToggleOffAllObjectCollisions(inst)
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Remove()
                end
            end),
        },

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            ToggleOnAllObjectCollisionsAt(inst, x, z)
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(12 * FRAMES, PlayFootstep),
    },
})

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(13 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
        end),
    },
    sleeptimeline =
    {
        TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/sleep") end),
    },
},
{
    onsleep = function(inst)
        inst:SetCheatFlag()
        inst.sg:AddStateTag("caninterrupt")
    end,
})

CommonStates.AddFrozenStates(states,
    function(inst)
        inst:SetCheatFlag()
    end
)

return StateGraph("pigelite", states, events, "idle")
