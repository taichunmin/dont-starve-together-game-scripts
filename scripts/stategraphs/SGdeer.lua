require("stategraphs/commonstates")

--------------------------------------------------------------------------

local function DoChainSound(inst, volume)
    inst:DoChainSound(volume)
end

local function DoChainIdleSound(inst, volume)
    inst:DoChainIdleSound(volume)
end

local function DoBellSound(inst, volume)
    inst:DoBellSound(volume)
end

local function DoBellIdleSound(inst, volume)
    inst:DoBellIdleSound(volume)
end

local function DoFootstep(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/footstep", nil, volume)
    PlayFootstep(inst, volume)
end

local function DoFootstepRun(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/footstep_run", nil, volume)
    PlayFootstep(inst, volume)
end

--------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(TUNING.DEER_HIT_RECOVERY, TUNING.DEER_MAX_STUN_LOCKS),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            if inst.gem ~= nil and
                inst.components.entitytracker:GetEntity("keeper") == nil and
                not inst.components.timer:TimerExists("deercast_cd") then
                local targets = inst:FindCastTargets(data ~= nil and data.target or nil)
                if targets ~= nil then
                    inst.sg:GoToState("magic_pre", targets)
                    return
                end
            end
            inst.sg:GoToState("attack", data ~= nil and data.target or nil)
        end
    end),
    EventHandler("deercast", function(inst)
        if inst.gem ~= nil and not inst.components.health:IsDead() then
            if not inst.sg:HasStateTag("busy") then
                local targets = inst:FindCastTargets()
                if targets ~= nil then
                    inst.sg:GoToState("magic_pre", targets)
                end
            else
                inst.sg.mem.wantstocast = true
            end
        end
    end),
    EventHandler("growantler", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("growantler")
        else
            inst.sg.mem.wantstogrowantler = true
        end
    end),
    EventHandler("unshackle", function(inst)
        if not inst.engaged then
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
                inst.sg:GoToState("unshackle")
            else
                inst.sg.mem.wantstounshackle = true
            end
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, playanim)
            if inst.sg.mem.wantstocast then
                local targets = inst:FindCastTargets()
                if targets ~= nil then
                    inst.sg:GoToState("magic_pre", targets)
                    return
                end
                inst.sg.mem.wantstocast = nil
            end
            if inst.sg.mem.wantstogrowantler then
                inst.sg:GoToState("growantler")
            elseif inst.sg.mem.wantstounshackle and not inst.engaged then
                inst.sg:GoToState("unshackle")
            elseif inst.gem == nil and math.random() < .25 then
                inst.sg:GoToState("idle_grazing")
            else
                inst.sg.mem.wantstounshackle = nil
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, DoBellIdleSound),
            TimeEvent(12 * FRAMES, DoChainIdleSound),
            TimeEvent(20 * FRAMES, function(inst)
                DoBellIdleSound(inst, .4)
            end),
            TimeEvent(23 * FRAMES, function(inst)
                DoChainIdleSound(inst, .4)
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
        name = "alert",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("alert_pre")
            inst.AnimState:PushAnimation("alert_idle", true)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/curious")
            --don't need gem deer chain sounds
        end,
    },

    State{
        name = "idle_grazing",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("eat")
        end,

        timeline =
        {
            TimeEvent(0, DoChainSound),
            TimeEvent(6 * FRAMES, DoBellSound),
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/eat")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                DoChainIdleSound(inst, .5)
            end),
            TimeEvent(19 * FRAMES, function(inst)
                DoBellIdleSound(inst, .3)
            end),
            TimeEvent(20 * FRAMES, function(inst)
                DoChainIdleSound(inst, .5)
            end),
            TimeEvent(32 * FRAMES, function(inst)
                DoBellIdleSound(inst, .7)
            end),
            TimeEvent(33 * FRAMES, function(inst)
                DoChainIdleSound(inst, .5)
            end),
            TimeEvent(47 * FRAMES, DoChainSound),
            TimeEvent(48 * FRAMES, DoBellSound),
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
        name = "growantler",
        tags = { "busy" },

        onenter = function(inst)
            inst.sg.mem.wantstogrowantler = nil
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("unshackle")
            --don't need gem deer chain sounds
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, DoFootstep),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local fx = SpawnPrefab("deer_growantler_fx")
                    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    fx.Transform:SetRotation(inst.Transform:GetRotation())

                    inst.sg:GoToState("unshackle_pst")
                end
            end),
        },

        onexit = function(inst)
            inst:ShowAntler()
        end,
    },

    State{
        name = "knockoffantler",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit_2")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/hit")
            --don't need gem deer chain sounds
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
        name = "magic_pre",
        tags = { "attack", "busy", "casting" },

        onenter = function(inst, targets)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk_magic_pre")

            inst.sg.statemem.targets = targets
            inst.sg.mem.wantstocast = nil

            inst.sg.statemem.fx = SpawnPrefab(inst.gem == "red" and "deer_fire_charge" or "deer_ice_charge")
            inst.sg.statemem.fx.entity:SetParent(inst.entity)
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "swap_antler_red", 0, 0, 0)
        end,

        timeline =
        {
            TimeEvent(0, DoChainIdleSound),
            TimeEvent(FRAMES, DoBellIdleSound),
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/huff")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                DoChainSound(inst)
                DoBellSound(inst)
            end),
            TimeEvent(19.5 * FRAMES, function(inst)
                if inst.gem ~= "red" then
                    inst.sg.statemem.spells = inst:DoCast(inst.sg.statemem.targets)
                    inst.sg.statemem.targets = nil
                end
            end),
            TimeEvent(22 * FRAMES, DoBellSound),
            TimeEvent(23 * FRAMES, DoChainSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.magic = true
                    if inst.sg.statemem.spells == nil and inst.sg.statemem.targets == nil then
                        inst.sg:GoToState("magic_pst", { fx = inst.sg.statemem.fx })
                    else
                        inst.sg:GoToState("magic_loop", { fx = inst.sg.statemem.fx, spells = inst.sg.statemem.spells, targets = inst.sg.statemem.targets })
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.magic then
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },

    State{
        name = "magic_loop",
        tags = { "attack", "busy", "casting" },

        onenter = function(inst, data)
            if inst.gem == "red" then
                inst.sg.statemem.magic = true
                inst.sg:GoToState("magic_pst", data)
            else
                data.looped = (data.looped or 0) + 1
                inst.sg.statemem.data = data
                if not inst.AnimState:IsCurrentAnimation("atk_magic_loop") then
                    inst.AnimState:PlayAnimation("atk_magic_loop", true)
                end
                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            end
        end,

        timeline =
        {
            TimeEvent(0, DoChainIdleSound),
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/scratch")
            end),
            TimeEvent(14 * FRAMES, DoBellIdleSound),
        },

        ontimeout = function(inst)
            inst.sg.statemem.magic = true
            inst.sg:GoToState(inst.sg.statemem.data.looped < 3 and "magic_loop" or "magic_pst", inst.sg.statemem.data)
        end,

        onexit = function(inst)
            if not inst.sg.statemem.magic and inst.sg.statemem.data ~= nil and inst.sg.statemem.data.fx ~= nil then
                inst.sg.statemem.data.fx:KillFX()
            end
        end,
    },

    State{
        name = "magic_pst",
        tags = { "attack", "busy", "casting" },

        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.fx = data.fx
                inst.sg.statemem.spells = data.spells
                inst.sg.statemem.targets = data.targets
            end
            inst.AnimState:PlayAnimation("atk_magic_pst")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/grrr")
            end),
            TimeEvent(5 * FRAMES, DoBellSound),
            TimeEvent(11 * FRAMES, DoChainSound),
            TimeEvent(20 * FRAMES, DoBellSound),
            TimeEvent(21 * FRAMES, DoFootstepRun),
            TimeEvent(22 * FRAMES, DoChainSound),
            TimeEvent(25 * FRAMES, function(inst)
                local success = false
                if inst.sg.statemem.spells ~= nil then
                    for i, v in ipairs(inst.sg.statemem.spells) do
                        if v:IsValid() then
                            success = true
                            v:TriggerFX()
                        end
                    end
                elseif inst.gem == "red" then
                    local spells = inst:DoCast(inst.sg.statemem.targets)
                    if spells ~= nil then
                        success = true
                        for i, v in pairs(spells) do
                            v:TriggerFX()
                        end
                    end
                end
                if inst.sg.statemem.fx ~= nil then
                    inst.sg.statemem.fx:KillFX(success and "blast" or nil)
                    inst.sg.statemem.fx = nil
                end
                inst.sg:RemoveStateTag("casting")
            end),
            TimeEvent(26 * FRAMES, function (inst)
                DoChainSound(inst)
                DoBellIdleSound(inst)
            end),
            TimeEvent(35 * FRAMES, DoBellSound),
            TimeEvent(36 * FRAMES, DoFootstep),
            TimeEvent(39 * FRAMES, DoChainSound),
            TimeEvent(41 * FRAMES, DoBellSound),
            TimeEvent(45 * FRAMES, DoFootstep),
            TimeEvent(46 * FRAMES, DoBellIdleSound),
            TimeEvent(47 * FRAMES, function(inst)
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

        onexit = function(inst)
            if inst.sg.statemem.fx ~= nil then
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },

    State{
        name = "unshackle",
        tags = { "busy" },

        onenter = function(inst)
            inst.sg.mem.wantstounshackle = nil
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("unshackle")
        end,

        timeline =
        {
            TimeEvent(0, DoBellIdleSound),
            TimeEvent(2 * FRAMES, DoChainSound),
            TimeEvent(13 * FRAMES, DoFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.gem ~= nil then
                        local player--[[, rangesq]] = inst:GetNearestPlayer()
                        LaunchAt(SpawnPrefab(inst.gem.."gem"), inst, player, 1, 4, .5)
                    end
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local rot = inst.Transform:GetRotation()
                    inst:Remove()

                    inst = SpawnPrefab("deer")
                    inst.Transform:SetPosition(x, y, z)
                    inst.Transform:SetRotation(rot)
                    inst.sg:GoToState("unshackle_pst")

                    inst = SpawnPrefab("deer_unshackle_fx")
                    inst.Transform:SetPosition(x, y, z)
                    inst.Transform:SetRotation(rot)
                end
            end),
        },
    },

    State{
        name = "unshackle_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("unshackle_pst")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/huff")
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
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
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            DoChainIdleSound(inst, .5)
            DoBellIdleSound(inst, .5)
        end),
    },
    walktimeline =
    {
        TimeEvent(0, function(inst)
            DoFootstep(inst)
            DoChainIdleSound(inst)
            DoBellIdleSound(inst)
        end),
        TimeEvent(6 * FRAMES, DoBellIdleSound),
        TimeEvent(7 * FRAMES, DoFootstep),
        TimeEvent(8 * FRAMES, DoChainIdleSound),
        TimeEvent(9 * FRAMES, DoFootstep),
        TimeEvent(10 * FRAMES, DoChainIdleSound),
        TimeEvent(12 * FRAMES, DoBellIdleSound),
        TimeEvent(17 * FRAMES, function(inst)
            DoFootstep(inst)
            DoBellIdleSound(inst)
        end),
        TimeEvent(18 * FRAMES, DoChainIdleSound),
    },
    endtimeline =
    {
        TimeEvent(3 * FRAMES, function(inst)
            DoFootstep(inst, .5)
            DoBellIdleSound(inst, .5)
            DoChainIdleSound(inst, .5)
        end),
    },
})
CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(4 * FRAMES, DoBellSound),
        TimeEvent(5 * FRAMES, DoChainSound),
        TimeEvent(8 * FRAMES, DoFootstepRun),
    },
    runtimeline =
    {
        TimeEvent(0, DoFootstepRun),
        TimeEvent(3 * FRAMES, DoBellSound),
        TimeEvent(4 * FRAMES, DoChainSound),
        TimeEvent(14 * FRAMES, DoFootstepRun),
    },
    endtimeline =
    {
        TimeEvent(FRAMES, function(inst)
            DoChainSound(inst)
            DoBellSound(inst)
        end),
        TimeEvent(2 * FRAMES, DoFootstep),
        TimeEvent(4 * FRAMES, DoFootstep),
    },
})
CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(0, DoBellSound),
        TimeEvent(FRAMES, function(inst)
            DoChainSound(inst, .6)
        end),
        TimeEvent(3 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/swish")
        end),
        TimeEvent(5 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/taunt")
        end),
        TimeEvent(11 * FRAMES, DoBellSound),
        TimeEvent(12 * FRAMES, function(inst)
            inst.components.combat:DoAttack(inst.sg.statemem.target)
            DoChainSound(inst)
        end),
        TimeEvent(23 * FRAMES, DoFootstep),
        TimeEvent(25 * FRAMES, DoFootstepRun),
        TimeEvent(26 * FRAMES, function(inst)
            DoBellSound(inst)
            DoChainSound(inst)
        end),
        TimeEvent(28 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end)
    },
    hittimeline =
    {
        TimeEvent(0, DoChainSound),
        TimeEvent(FRAMES, DoBellSound),
        TimeEvent(12 * FRAMES, function(inst)
            if inst.gem == nil then
                DoFootstep(inst)
            end
        end),
        TimeEvent(13 * FRAMES, function(inst)
            if inst.gem == nil then
                inst.sg:RemoveStateTag("busy")
            end
        end),
        TimeEvent(14 * FRAMES, DoChainSound),
        TimeEvent(18 * FRAMES, DoBellSound),
        TimeEvent(22 * FRAMES, function(inst)
            if inst.gem ~= nil then
                inst.sg:RemoveStateTag("busy")
            end
        end),
    },
    deathtimeline =
    {
        TimeEvent(0, DoChainIdleSound),
        TimeEvent(5 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bodyfall_2")
            DoBellIdleSound(inst)
        end),
        TimeEvent(15 * FRAMES, DoChainSound),
        TimeEvent(20 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/hit")
        end),
        TimeEvent(23 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bodyfall_2")
            DoBellSound(inst)
            if inst.gem ~= nil then
                local pt = inst:GetPosition()
                pt.y = 1
                inst.AnimState:Hide("swap_antler")
                inst.components.lootdropper:SpawnLootPrefab(inst.gem.."gem", pt)
            elseif inst.hasantler ~= nil then
                local pt = inst:GetPosition()
                pt.y = 1
                inst:SetAntlered(nil, false)
                for i = 1, math.random(2) do
                    inst.components.lootdropper:SpawnLootPrefab("boneshard", pt)
                end
            end
        end),
        TimeEvent(24 * FRAMES, DoChainSound),
    },
},
{
    hit = function(inst)
        return inst.gem ~= nil and "hit_2" or "hit"
    end,
})

CommonStates.AddFrozenStates(states)

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            DoChainSound(inst)
            DoBellSound(inst, .3)
        end),
        TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bodyfall")
            DoBellSound(inst, .5)
        end),
        TimeEvent(16 * FRAMES, DoChainSound),
    },
    sleeptimeline =
    {
        TimeEvent(9 * FRAMES, function(inst)
            DoBellSound(inst, .2)
        end),
        TimeEvent(31 * FRAMES, function(inst)
            DoBellIdleSound(inst, .2)
        end),
    },
    waketimeline =
    {
        TimeEvent(2 * FRAMES, DoBellIdleSound),
        TimeEvent(22 * FRAMES, DoChainSound),
        TimeEvent(24 * FRAMES, DoBellSound),
    },
})

return StateGraph("deer", states, events, "idle")
