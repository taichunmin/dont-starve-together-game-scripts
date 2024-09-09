require("stategraphs/commonstates")


local BOAT_MUST_TAGS = { "boat" }

local function heal(inst)
    inst.components.health:DoDelta(TUNING.CRABKING_REGEN + math.floor(inst.gemcount.orange/2) * TUNING.CRABKING_REGEN_BUFF )
end

local function testforlostrock(inst, rightarm)
    if inst.sg:HasStateTag("loserock_window") and not inst.components.timer:TimerExists("regen_stun_cooldown") then
        local frame = inst.AnimState:GetCurrentAnimationFrame()

        local frameback = 20
        if inst.gemcount.orange > 4 then
            frameback = 13
        end
        if inst.gemcount.orange > 7 then
            frameback = 8
        end

        frame = frame - frameback

        local minframe = 1
        if inst.sg:HasStateTag("fixpre") then
            minframe = 14
        end
        
        if frame <= minframe then
            if inst.gemcount.orange < 5 then
                 inst.sg:GoToState("fix_lostrock", rightarm)
            else
                inst.AnimState:SetFrame(minframe)
                inst.components.timer:StartTimer("regen_stun_cooldown", 8*FRAMES)
            end
        else
            inst.AnimState:SetFrame(frame)
        end

    end
end

local function gemshine(inst, color)
    if not inst.components.timer:TimerExists("gem_shine") then
        inst:ShineSocketOfColor(color)
        inst.components.timer:StartTimer("gem_shine", 1.5)
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

local NEARBY_PLATFORM_MUST_TAGS = { "boat", "walkableplatform" }
local NEARBY_PLATFORM_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local NEARBY_PLATFORM_TEST_RADIUS = 3 + TUNING.MAX_WALKABLE_PLATFORM_RADIUS
local function push_nearby_boats(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local radius = inst:GetPhysicsRadius(1)
    local min_range_sq = math.max(0, radius - NEARBY_PLATFORM_TEST_RADIUS)
    min_range_sq = min_range_sq * min_range_sq

    local i0
    local platform_ents = TheSim:FindEntities(ix, 0, iz, radius + NEARBY_PLATFORM_TEST_RADIUS, NEARBY_PLATFORM_MUST_TAGS, NEARBY_PLATFORM_CANT_TAGS)
    for i, platform_entity in ipairs(platform_ents) do
        if platform_entity:GetDistanceSqToPoint(ix, 0, iz) >= min_range_sq then
            i0 = i
            break
        end
    end
    if i0 then
        for i = i0, #platform_ents do
            local platform_entity = platform_ents[i]
            if platform_entity ~= inst
                    and platform_entity.Transform
                    and platform_entity.components.boatphysics then
                local v2x, v2y, v2z = platform_entity.Transform:GetWorldPosition()
                local mx, mz = v2x - ix, v2z - iz
                if mx ~= 0 or mz ~= 0 then
                    local normalx, normalz = VecUtil_Normalize(mx, mz)
                    platform_entity.components.boatphysics:ApplyForce(normalx, normalz, 2)
                end
            end
        end
    end
end

local function throwchunk(inst, prefab)
    local chunk = inst:SpawnChunk(prefab, inst:GetPosition())
    chunk.Physics:SetMotorVel(math.random(12,25), math.random(0,10), 0)
end

local function GetTransitionState(inst)
    if inst.components.timer:TimerExists("taunt") then
        return "taunt"
    elseif inst.wantstosummonclaws then
        return "spawnclaws"
    elseif inst.wantstoheal and inst:HasTag("icewall") then
        return "fix_pre"
    elseif inst.wantstofreeze then
        return "cast_pre"
    end
end

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function go_to_inert(inst)
    inst.sg:GoToState("inert")
end

local function play_quarter_light_sound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/electricity/light",nil,.25)
end

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
}

local events =
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),

    EventHandler("activate", function(inst, data)
        inst.sg:GoToState(data.isload and "idle" or "inert_pst")

        if not data.isload then
            inst.components.timer:StartTimer("freeze_cooldown", 30)
            inst:SpawnCannons()
        end
    end),
    EventHandler("ck_taunt", function(inst, data)
        inst.sg:GoToState("taunt")
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
            EventHandler("animover", go_to_idle),
        },
    },

    --------------------------------------------------------
    -- TAUNT
    --------------------------------------------------------

    State{
        name = "taunt",
        tags = { "busy", "canrotate" },

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("taunt_pre")
        end,

        timeline=
        {
            SoundFrameEvent(1, "meta4/crabking/water_move"),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("taunt_loop")
            end),
        },
    },

    State{
        name = "taunt_loop",
        tags = { "canrotate" },

        onenter = function(inst, pushanim)
            inst.AnimState:PlayAnimation("taunt_loop")
        end,

        timeline=
        {
            SoundFrameEvent(5, "meta4/crabking/taunt"),
        },

        onupdate = function(inst)
            if not inst.components.timer:TimerExists("taunt") then
                inst.sg:GoToState("taunt_pst")
            end
        end,

        events =
        {
            EventHandler("attacked", function(inst)
                inst.components.timer:StopTimer("taunt")
                inst.sg:GoToState("taunt_pst")
            end),

            EventHandler("animover", function(inst)
                inst.sg:GoToState("taunt_loop")
            end),
        },
    },

    State{
        name = "taunt_pst",
        tags = { "busy", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt_pst")
        end,

        timeline=
        {
            SoundFrameEvent(8, "meta4/crabking/water_move"),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
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
            SoundFrameEvent(16, "hookline_2/creatures/boss/crabking/bubble"),
            SoundFrameEvent(21, "hookline_2/creatures/boss/crabking/bubble"),
            SoundFrameEvent(32, "hookline_2/creatures/boss/crabking/bubble"),
            SoundFrameEvent(34, "hookline_2/creatures/boss/crabking/bubble"),
            SoundFrameEvent(41, "hookline_2/creatures/boss/crabking/bubble"),
            SoundFrameEvent(51, "hookline_2/creatures/boss/crabking/bubble"),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState((math.random() < 0.9 and "inert") or "inert_blink")
            end),
        },
    },

    State{
        name = "reappear",
        tags = { "inert", "canrotate", "noattack", "busy", "canwxscan", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("reappear")
        end,

        timeline=
        {
            SoundFrameEvent(1, "turnoftides/common/together/water/submerge/large"),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState((math.random() < 0.9 and "inert") or "inert_blink")
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
            SoundFrameEvent(5, "hookline_2/creatures/boss/crabking/inert_growl"),
            SoundFrameEvent(7, "hookline_2/creatures/boss/crabking/idle"),
            SoundFrameEvent(16, "hookline_2/creatures/boss/crabking/idle"),
            SoundFrameEvent(26, "hookline_2/creatures/boss/crabking/bubble"),
            SoundFrameEvent(40, "hookline_2/creatures/boss/crabking/bubble"),
        },

        events =
        {
            EventHandler("animover", go_to_inert),
        },
    },

    State{
        name = "inert_pst",
        tags = { "inert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("inert_pst")
            inst:ShineSocketOfColor("red")
        end,

        timeline=
        {
            SoundFrameEvent(15, "hookline_2/creatures/boss/crabking/inert_hide"),
            SoundFrameEvent(25, "hookline_2/creatures/boss/crabking/vocal"),
            SoundFrameEvent(27, "turnoftides/common/together/water/submerge/large"),
            SoundFrameEvent(28, "turnoftides/common/together/water/submerge/large"),
        },

        events =
        {
            EventHandler("animqueueover", go_to_idle),
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
            EventHandler("animover", go_to_inert),
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
            EventHandler("animover", go_to_inert),
        },
    },

    --------------------------------------------------------
    -- CAST attack
    --------------------------------------------------------

    State{
        name = "cast_pre",
        tags = { "busy", "canrotate", "casting"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cast_blue_pre")

            inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre")
        end,

        timeline=
        {
            SoundFrameEvent(2, "dontstarve/common/together/electricity/light"),
            SoundFrameEvent(6, "dontstarve/common/together/electricity/light"),
            SoundFrameEvent(4, "hookline_2/creatures/boss/crabking/spell"),
            SoundFrameEvent(17, "hookline_2/creatures/boss/crabking/cast_pre"),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.geysers then
                    inst.geysers = {}
                end

                local x,y,z = inst.Transform:GetWorldPosition()
                for i=1,6 do
                    local radius = 8
                    local theta = PI*2/8 *i
                    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                    local geyser = SpawnPrefab("crabking_geyserspawner")
                    geyser.Transform:SetPosition(x+offset.x,0,z+offset.z)        

                    table.insert(inst.geysers,geyser)                    
                end

                inst.sg:GoToState("cast_loop")
            end),
        },
    },

    State{
        name = "cast_loop",
        tags = { "busy", "canrotate", "casting"},

        onenter = function(inst, wavetime)
            inst:StartCastSpell(inst.dofreezecast)
            inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/magic_LP","crabmagic")
            inst.AnimState:PlayAnimation("cast_blue_loop")
            inst.SoundEmitter:SetParameter("crabmagic", "intensity", 0)
            inst.sg.statemem.elapsedtime = 0
            inst.sg.statemem.wavetime = wavetime


            push_nearby_boats(inst)
        end,

        onupdate = function(inst, dt)
            inst.sg.statemem.elapsedtime = inst.sg.statemem.elapsedtime +dt

            if not inst.sg.statemem.wavetime then
                SpawnAttackWaves(inst:GetPosition(), nil, 2.2, 8, nil, 2.25, nil, 2, true)
                inst.sg.statemem.wavetime = 1
            else
                inst.sg.statemem.wavetime = inst.sg.statemem.wavetime - dt
                if inst.sg.statemem.wavetime <= 0 then
                    inst.sg.statemem.wavetime = nil
                end
            end

            local totaltime = TUNING.CRABKING_CAST_TIME_FREEZE
            local intensity = 1- math.min(inst.sg.statemem.elapsedtime/totaltime,1)
            inst.SoundEmitter:SetParameter("crabmagic", "intensity", intensity)
            gemshine(inst, "blue")

            if not inst.components.timer:TimerExists("do_end_cast") then
                local x, y, z = inst.Transform:GetWorldPosition()

                -- Keep casting until there are no boats nearby. (also times out)   
                if TheSim:CountEntities(x, 0, z, 14, BOAT_MUST_TAGS) <= 0 then            
                    inst.components.timer:StartTimer("do_end_cast",2)
                end
            end
        end,

        timeline=
        {
            TimeEvent(2*FRAMES, play_quarter_light_sound),
            TimeEvent(5*FRAMES, function(inst)
                if math.random() < 0.5 then
                    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre")
                end
            end),
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/chatter")
            end),
            TimeEvent(6*FRAMES, play_quarter_light_sound),
            TimeEvent(18*FRAMES, play_quarter_light_sound),
            TimeEvent(19*FRAMES, play_quarter_light_sound),
            TimeEvent(22*FRAMES, play_quarter_light_sound),
            TimeEvent(23*FRAMES, function(inst)
                if math.random() < 0.5 then
                    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/cast_pre")
                end
            end),
            TimeEvent(23*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/chatter")
            end),
            TimeEvent(25*FRAMES, play_quarter_light_sound),
        },

        onexit = function(inst)
            inst.wavetime = nil

            if not inst.sg.statemem.keepcast then
                inst.SoundEmitter:KillSound("crabmagic")
                inst.components.timer:StopTimer("do_wave_push")
            end
        end,

        events =
        {
        
            EventHandler("timerdone", function(inst,data)
                if data.name == "do_end_cast" then
                    inst.sg:GoToState("cast_pst")
                end
            end),
       
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepcast = true
                inst.sg:GoToState("cast_loop", inst.sg.statemem.wavetime)
            end),
        },
    },

    State{
        name = "cast_pst",
        tags = { "busy", "canrotate"},

        onenter = function(inst, freezecast)
            inst.AnimState:PlayAnimation((freezecast and "cast_blue_pst") or "cast_purple_pst")
            inst:EndCastSpell()
        end,

        timeline=
        {
            SoundFrameEvent(5, "turnoftides/common/together/water/splash/medium"),
            SoundFrameEvent(6, "turnoftides/common/together/water/splash/medium"),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    --------------------------------------------------------
    -- SPAWN CLAWS
    --------------------------------------------------------

    State{
        name = "spawnclaws",
        tags = { "busy", "canrotate", "spawning"},

        onenter = function(inst)
            inst.wantstosummonclaws = nil
            inst.AnimState:PlayAnimation("inert_pre")
            inst.AnimState:PushAnimation("inert_pst",false)
        end,

        timeline = {
            SoundFrameEvent(39*FRAMES, "hookline_2/creatures/boss/crabking/inert_hide"),
            TimeEvent(65*FRAMES, function(inst)
                inst:SpawnClawArms()
                inst:ShineSocketOfColor("green")
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
            SoundFrameEvent(39, "hookline_2/creatures/boss/crabking/inert_hide"),
            TimeEvent(65*FRAMES, function(inst) inst:spawnstacks() end),
        },

        events =
        {
            EventHandler("animqueueover", go_to_idle),
        },
    },

    --------------------------------------------------------
    -- HEAL
    --------------------------------------------------------

    State{
        name = "fix_pre",
        tags = { "canrotate", "fixing","fixpre"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fix_pre")
        end,

        onupdate = function(inst,dt)
            if inst.AnimState:GetCurrentAnimationFrame() == 14 and not inst.sg:HasStateTag("loserock_window") then
                inst.sg:AddStateTag("loserock_window")             
            end

            if inst.AnimState:GetCurrentAnimationFrame() >= 27 and inst.sg:HasStateTag("loserock_window") then
                inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/repair")
                inst.sg:RemoveStateTag("loserock_window")
                inst:ShineSocketOfColor("orange")

                inst.fixhits = 0
                heal(inst)                
            end
        end,

        timeline=
        {
            TimeEvent(14*FRAMES, function(inst)

            end),

            TimeEvent(27*FRAMES, function(inst)

            end),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                testforlostrock(inst,  not inst.sg.statemem.rightarm)
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("fix_loop")
            end),
        },
    },

    State{
        name = "fix_loop",
        tags = { "canrotate", "fixing", "loserock_window"},

        onenter = function(inst, rightarm)
            local randomlist = {1,2,3,4}
            if inst.lastfixloop then
                table.remove(randomlist,inst.lastfixloop)
            end
            local randomchoice = randomlist[math.random(#randomlist)]
            inst.lastfixloop = randomchoice
            local arm = rightarm and "right" or "left"
            inst.sg.statemem.rightarm = rightarm

            inst.AnimState:PlayAnimation("fix_"..arm.."_loop_"..randomchoice)      

        end,

        onupdate = function(inst,dt)


            if inst.AnimState:GetCurrentAnimationFrame() >= 16 then
                if inst.sg:HasStateTag("loserock_window") then
                    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/repair")

                    inst.sg:RemoveStateTag("loserock_window")
                    inst:ShineSocketOfColor("orange")
                    inst.fixhits = 0
                    heal(inst)
                end                
            end

        end,

        timeline=
        {

            TimeEvent(8*FRAMES, function(inst)
              --  inst.sg:AddStateTag("loserock_window")
            end),

            TimeEvent(13*FRAMES, function(inst)
              
            end),

            TimeEvent(16*FRAMES, function(inst)

            end),
        },

        events =
        {
            EventHandler("attacked", function(inst)                
                testforlostrock(inst, inst.sg.statemem.rightarm)
            end),
            EventHandler("animover", function(inst)
                local done_healing = (inst.components.health:GetPercent() >= 1) or not inst:HasTag("icewall")
                inst.sg:GoToState((done_healing and "fix_pst") or "fix_loop", not inst.sg.statemem.rightarm)
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
            SoundTimeEvent(0, "hookline_2/creatures/boss/crabking/rock_hit"),
            TimeEvent(2*FRAMES, function(inst)
                if math.random() < 0.5 then
                    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit")
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                local done_healing = (inst.components.health:GetPercent() >= 1) or not inst:HasTag("icewall")
                inst.sg:GoToState((done_healing and "fix_pst") or "fix_loop", not inst.sg.statemem.rightarm)
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

        events =
        {
            EventHandler("animover", go_to_idle),
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

        timeline =
        {
            SoundTimeEvent(0, "hookline_2/creatures/boss/crabking/hit"),
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
        SoundTimeEvent(0, "hookline_2/creatures/boss/crabking/death2"),
        TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/hit",nil,.5) end),
        SoundFrameEvent(5, "hookline_2/creatures/boss/crabking/hit"),
        TimeEvent(26 * FRAMES, function(inst)
                if inst.gemcount.pearl >= 1 then
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
                if inst.gemcount.pearl > 0 then
                    inst:RemoveGem("hermit_pearl")
                    inst:AddGem("hermit_cracked_pearl")
                end
                inst:DropSocketedGems()
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
        TimeEvent(75 * FRAMES, function(inst)
            spawnwaves(inst, 8, 360, 3, nil, (inst.Physics and inst.Physics:GetRadius() - 1.5) or nil, 0, nil, true)
        end),

    },
    hittimeline ={
        SoundTimeEvent(0, "hookline_2/creatures/boss/crabking/hit"),
    },

},{hit = "hit_light", death="death2"})


return StateGraph("crabking", states, events, "inert", actionhandlers)

