require("stategraphs/commonstates")

local function heal(inst)
    inst.components.health:DoDelta(TUNING.CRABKING_REGEN + math.floor(inst.countgems(inst).orange/2) * TUNING.CRABKING_REGEN_BUFF )
end

local function testforlostrock(inst, rightarm)
    if not inst.fixhits then
        inst.fixhits = 0
    end

    if inst.fixhits == math.floor(inst.countgems(inst).orange/3) then
        inst.sg:GoToState("fix_lostrock", rightarm)
        inst.fixhits = 0
    else
        inst.fixhits = inst.fixhits + 1
    end
end

local function spawnwaves(inst, numWaves, totalAngle, waveSpeed, wavePrefab, initialOffset, idleTime, instantActivate, random_angle)
    SpawnAttackWaves(
        inst:GetPosition(),
        (not random_angle and inst.Transform:GetRotation()) or nil,
        initialOffset or (inst.Physics and inst.Physics:GetRadius()) or nil,
        numWaves,
        totalAngle,
        waveSpeed,
        wavePrefab,
        idleTime,
        instantActivate
    )
end

local function throwchunk(inst,prefab)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local chunk = inst.spawnchunk(inst,prefab,pos)
    chunk.Physics:SetMotorVel(math.random(12,25), math.random(0,10), 0)
end

local function spawnwave(inst, time)
    spawnwaves(inst, 12, 360, 3, nil, 0, 0, nil, true)  --2 1
end

local function GetTransitionState(inst)
    if inst.wantstosummonclaws then
        return "spawnclaws"
    elseif inst.wantstosummonseatacks then
        return "spawnstacks"
    elseif inst.wantstoheal then
        return "fix_pre"
    elseif inst.wantstocast then
        return "cast_pre"
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
}

local events =
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst, data)
    end),
    EventHandler("activate", function(inst, data)
        inst.sg:GoToState("inert_pst")
    end),
    EventHandler("socket", function(inst, data)
        inst.sg:GoToState("socket")
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            --pushanim could be bool or string?
            local transitionstate = GetTransitionState(inst)
            if transitionstate then
                inst.sg:GoToState(transitionstate)
            else
                if pushanim then
                    if type(pushanim) == "string" then
                        inst.AnimState:PlayAnimation(pushanim)
                    end
                    inst.AnimState:PushAnimation("idle")
                elseif not inst.AnimState:IsCurrentAnimation("idle_loop") then
                    inst.AnimState:PlayAnimation("idle")
                end
            end
        end,

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/vocal",nil,.25) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/vocal",nil,.25) end),

        },

        onupdate = function(inst)
            local transitionstate = GetTransitionState(inst)
            if transitionstate then
                inst.sg:GoToState(transitionstate)
            end
        end,

        events =
        {
            EventHandler("attacked", function(inst)
                inst.sg:GoToState("hit_light")
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    --------------------------------------------------------
    -- INERT states
    --------------------------------------------------------

    State{
        name = "inert",
        tags = { "inert", "canrotate", "noattack", "canwxscan", },

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("inert")
        end,

        timeline=
        {
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
            TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
            TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
            TimeEvent(34*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
            TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
            TimeEvent(51*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if math.random() < 0.90 then
                    inst.sg:GoToState("inert")
                else
                    inst.sg:GoToState("inert_blink")
                end
            end),
        },
    },

    State{
        name = "reappear",
        tags = { "inert", "canrotate", "noattack", "busy", "canwxscan", },

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("reappear")
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/submerge/large") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if math.random() < 0.90 then
                    inst.sg:GoToState("inert")
                else
                    inst.sg:GoToState("inert_blink")
                end
            end),
        },
    },

    State{
        name = "inert_blink",
        tags = { "inert", "canrotate", "noattack", "canwxscan", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("inert_blink")
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/inert_growl") end),
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/idle") end),
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/idle") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("inert")
            end),
        },
    },

    State{
        name = "inert_pst",
        tags = { "inert" },

        onenter = function(inst, pushanim)
         --   inst.AnimState:PlayAnimation("red_fx")
          --  inst.AnimState:PushAnimation("inert_pst",false)
            inst.AnimState:PlayAnimation("inert_pst")
            inst.gemshine(inst,"red")
        end,

        timeline=
        {
            TimeEvent((15)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/inert_hide") end),
            TimeEvent((25)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/vocal") end),
            TimeEvent((27)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/submerge/large") end),
            TimeEvent((28)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/submerge/large") end),
        },


        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "disappear",
        tags = { "idle", "canrotate", "noattack", "inert", "canwxscan", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("disappear")
            inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/disappear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.Physics:SetActive(false)
                inst:Hide()
            end),
        },
    },

    State{
        name = "reappear",
        tags = { "idle", "canrotate", "noattack", "inert", "canwxscan", },

        onenter = function(inst)
            inst.Physics:SetActive(true)
            inst:Show()
            inst.AnimState:PlayAnimation("reappear")
            inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/appear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("inert")
            end),
        },
    },

    State{
        name = "socket",
        tags = { "idle", "canrotate", "noattack", "inert", "canwxscan", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("gem_insert")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("inert")
            end),
        },
    },




    --------------------------------------------------------
    -- CAST attack
    --------------------------------------------------------

    State{
        name = "cast_pre",
        tags = { "busy", "canrotate", "casting"},

        onenter = function(inst)
            inst.wantstocast = nil
            if inst.dofreezecast then
                inst.AnimState:PlayAnimation("cast_blue_pre")
            else
                inst.AnimState:PlayAnimation("cast_purple_pre")
            end
            inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre")
        end,

        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light") end),
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light") end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/spell") end),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("cast_loop")
            end),
        },
    },
    State{
        name = "cast_loop",
        tags = { "busy", "canrotate", "casting"},

        onenter = function(inst)

            if not inst.components.timer:TimerExists("casting_timer") then
                inst.startcastspell(inst,inst.dofreezecast)
                if inst.dofreezecast then
                    inst.isfreezecast = true
                    inst.components.timer:StartTimer("casting_timer",TUNING.CRABKING_CAST_TIME_FREEZE - math.floor(inst.countgems(inst).yellow/2))
                else
                    inst.components.timer:StartTimer("casting_timer",TUNING.CRABKING_CAST_TIME - math.floor(inst.countgems(inst).yellow/2))
                end
                inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/magic_LP","crabmagic")
            end

            if inst.isfreezecast then
                inst.AnimState:PlayAnimation("cast_blue_loop")
            else
                inst.AnimState:PlayAnimation("cast_purple_loop")
            end

            inst.dofreezecast = nil

            inst.SoundEmitter:SetParameter("crabmagic", "intensity", 0)
        end,

        onupdate = function(inst)
            if inst.components.timer:TimerExists("casting_timer") then
                local totaltime = TUNING.CRABKING_CAST_TIME - math.floor(inst.countgems(inst).yellow/2)
                if inst.isfreezecast then
                    totaltime = TUNING.CRABKING_CAST_TIME_FREEZE - math.floor(inst.countgems(inst).yellow/2)
                end
                local intensity = 1- inst.components.timer:GetTimeLeft("casting_timer")/totaltime
                inst.SoundEmitter:SetParameter("crabmagic", "intensity", intensity)
            end
            if not inst.components.timer:TimerExists("gem_shine") then
                inst.gemshine(inst,"yellow")
                inst.components.timer:StartTimer("gem_shine",1.5)
            end
        end,

        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25) end),
            TimeEvent(5*FRAMES, function(inst) if math.random() < 0.5 then inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre") end end),
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/chatter")  end),
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25) end),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25) end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25) end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25) end),
            TimeEvent(23*FRAMES, function(inst) if math.random() < 0.5 then inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre") end end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/chatter")  end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25) end),
            -- TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:KillSound("crabmagic") end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.keepcast then

                inst:DoTaskInTime(0,function()
                    inst.endcastspell(inst, inst.isfreezecast)
                end)

                inst.SoundEmitter:KillSound("crabmagic")
                inst.isfreezecast = nil
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepcast = true
                inst.sg:GoToState("cast_loop")
            end),
            EventHandler("timerdone", function(inst,data)
                if data.name == "casting_timer" then
                    inst.sg:GoToState("cast_pst", inst.isfreezecast)
                end
            end),
        },
    },

    State{
        name = "cast_pst",
        tags = { "busy", "canrotate"},

        onenter = function(inst, freezecast)
            if freezecast then
                inst.AnimState:PlayAnimation("cast_blue_pst")
            else
                inst.AnimState:PlayAnimation("cast_purple_pst")
            end
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium") end),
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    --------------------------------------------------------
    -- SPAWN CLAWS
    --------------------------------------------------------

    State{
        name = "spawnclaws",
        tags = { "busy", "canrotate", "spawning"},

        onenter = function(inst)
            --inst.components.timer:StartTimer("clawsummon_cooldown",TUNING.CRABKING_CLAW_SUMMON_DELAY)
            inst.wantstosummonclaws = nil
            inst.AnimState:PlayAnimation("inert_pre")
            inst.AnimState:PushAnimation("inert_pst",false)
        end,

        timeline = {
            TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/inert_hide") end),
            TimeEvent(65*FRAMES, function(inst)
                inst.spawnarms(inst)
                inst.gemshine(inst,"green")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg.statemem.keepcast = true
                inst.sg:GoToState("idle")
            end),
        },
    },

    --------------------------------------------------------
    -- SPAWN SEASTACKS
    --------------------------------------------------------

    State{
        name = "spawnstacks",
        tags = { "busy", "canrotate", "spawning"},

        onenter = function(inst)
            inst.components.timer:StartTimer("seastacksummon_cooldown",TUNING.CRABKING_STACK_SUMMON_DELAY)

            inst.wantstosummonseatacks = nil
            inst.AnimState:PlayAnimation("inert_pre")
            inst.AnimState:PushAnimation("inert_pst",false)
        end,

        timeline = {
            TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/inert_hide") end),
            TimeEvent(65*FRAMES, function(inst) inst.spawnstacks(inst) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },


    --------------------------------------------------------
    -- HEAL
    --------------------------------------------------------

    State{
        name = "fix_pre",
        tags = { "canrotate", "fixing"},

        onenter = function(inst)
            inst.sg.statemem.past_interrupt = true
            inst.lastfixloop = nil
            if not inst.components.timer:TimerExists("fix_timer") then
                inst.components.timer:StartTimer("fix_timer",TUNING.CRABKING_FIX_TIME)
            end
            inst.AnimState:PlayAnimation("fix_pre")

            if not inst.components.timer:TimerExists("claw_regen_timer") then
                inst.regenarm(inst)
            end
            inst.gemshine(inst,"orange")
        end,

        timeline=
        {
            TimeEvent(16*FRAMES, function(inst)
                inst.sg.statemem.past_interrupt = nil
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst.sg.statemem.past_interrupt = true
                inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/repair")
            end),
            TimeEvent(31*FRAMES, function(inst)
                inst.fixhits = 0
                heal(inst)
            end),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.sg.statemem.past_interrupt then
                    testforlostrock(inst,  not inst.sg.statemem.rightarm)
                   -- inst.sg:GoToState("fix_lostrock", not inst.sg.statemem.rightarm)
                end
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("fix_loop")
            end),
        },
    },

    State{
        name = "fix_loop",
        tags = { "canrotate", "fixing", "nointerrupt"},

        onenter = function(inst, rightarm)
            inst.sg.statemem.past_interrupt = true
            local randomlist = {1,2,3,4}
            if inst.lastfixloop then
                table.remove(randomlist,inst.lastfixloop)
            end
            local randomchoice = randomlist[math.random(1,#randomlist)]
            inst.lastfixloop = randomchoice
            local arm = rightarm and "right" or "left"
            inst.sg.statemem.rightarm = rightarm

            inst.AnimState:PlayAnimation("fix_"..arm.."_loop_"..randomchoice)
            inst.gemshine(inst,"orange")
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
                --inst.sg.statemem.past_interrupt = nil
             end),
            TimeEvent(12*FRAMES, function(inst)
                if inst.sg.statemem.rightarm then
                    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/repair")
                    end
             end),
             TimeEvent(16*FRAMES, function(inst)
                if not inst.sg.statemem.rightarm then
                    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/repair")
                    end
             end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:AddStateTag("nointerrupt")  end), -- inst.sg.statemem.past_interrupt = true
            TimeEvent(29*FRAMES, function(inst)
                inst.fixhits = 0
                heal(inst)
            end),
        },

        onexit = function(inst)

        end,

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.sg:HasStateTag("nointerrupt") then -- inst.sg.statemem.past_interrupt
                    testforlostrock(inst, inst.sg.statemem.rightarm)
                    --inst.sg:GoToState("fix_lostrock",inst.sg.statemem.rightarm)
                end
            end),
            EventHandler("animover", function(inst)
                if inst.components.health:GetPercent() >= 1 or not inst.wantstoheal then
                    inst.finishfixing(inst)
                    inst.sg:GoToState("fix_pst", not  inst.sg.statemem.rightarm)
                else

                    inst.sg:GoToState("fix_loop", not inst.sg.statemem.rightarm)
                end
            end),
        },
    },

    State{
        name = "fix_lostrock",
        tags = { "canrotate", "fixing"},

        onenter = function(inst, rightarm)
            local arm = "left"
            if rightarm then
                arm = "right"
                inst.sg.statemem.rightarm = rightarm
            end
            inst.AnimState:PlayAnimation("fix_"..arm.."_lostrock")
            inst.fixhits = 0
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/rock_hit") end),
            TimeEvent(2*FRAMES, function(inst) if math.random() < 0.5 then inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit") end end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.health:GetPercent() >= 1 or not inst.wantstoheal then
                    inst.finishfixing(inst)
                    inst.sg:GoToState("fix_pst", not  inst.sg.statemem.rightarm)
                else

                    inst.sg:GoToState("fix_loop", not inst.sg.statemem.rightarm)
                end
            end),
        },
    },

    State{
        name = "fix_pst",
        tags = { "canrotate"},

        onenter = function(inst, rightarm)

            local arm = "left"
            if rightarm then
                arm = "right"
                inst.sg.statemem.rightarm = rightarm
            end
            inst.AnimState:PlayAnimation("fix_"..arm.."_pst")
            inst.fixhits = 0
        end,

        timeline=
        {

        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit_light",
        tags = { "hit", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("hit_light")
        end,

        timeline=
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit") end),
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

CommonStates.AddFrozenStates(states)
CommonStates.AddCombatStates(states,{
    deathtimeline ={
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/death2") end),
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit",nil,.5) end),
        TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit") end),
        TimeEvent(26 * FRAMES, function(inst)
                if inst.countgems(inst).pearl >= 1 then
                    local crown = SpawnPrefab("moon_altar_crown")
                    local pos = Vector3(inst.Transform:GetWorldPosition())
                    crown.components.heavyobstaclephysics:AddFallingStates()
                    crown.Transform:SetPosition(pos.x, 4, pos.z)
                    crown:PushEvent("startfalling")
                    crown.Physics:SetVel(0, 20, 0)
                    crown.AnimState:PlayAnimation("spin_loop",true)
                    crown.falltask = crown:DoPeriodicTask(1/30,function()
                            local cpos = Vector3(crown.Transform:GetWorldPosition())
                            if cpos.y <= 0.2 then
                                crown.Transform:SetPosition(cpos.x,0,cpos.z)
                                crown:PushEvent("stopfalling")
                                crown.AnimState:PlayAnimation("anim")
                                if crown.falltask then
                                    crown.falltask:Cancel()
                                    crown.falltask = nil
                                end
                            end
                        end)
                end
                if inst.countgems(inst).pearl > 0 then
                    inst.removegem(inst,"hermit_pearl")
                    inst.addgem(inst,"hermit_cracked_pearl")
                end
                inst.dropgems(inst)
            end),
        TimeEvent(28 * FRAMES, function(inst)
                throwchunk(inst,"crabking_chip_high")
                throwchunk(inst,"crabking_chip_high")
                throwchunk(inst,"crabking_chip_med")
                throwchunk(inst,"crabking_chip_med")
                throwchunk(inst,"crabking_chip_low")
                throwchunk(inst,"crabking_chip_low")
                throwchunk(inst,"crabking_chip_high")
                throwchunk(inst,"crabking_chip_high")
                throwchunk(inst,"crabking_chip_med")
                throwchunk(inst,"crabking_chip_med")
                throwchunk(inst,"crabking_chip_low")
                throwchunk(inst,"crabking_chip_low")
            end),
        TimeEvent(75 * FRAMES, function(inst) spawnwave(inst) end),

    },
    hittimeline ={
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit") end),
    },

},{hit = "hit_light", death="death2"})


return StateGraph("crabking", states, events, "inert", actionhandlers)

