require("stategraphs/commonstates")

local OnRemoveDebris = function(child)
    child.shadow:Remove()
end or nil

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

local TWIGS_MUST = {"cattoy"}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnHop(),

    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("attack") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),

    EventHandler("startfalling", function(inst)  inst.sg:GoToState("fall_pre")  end),

    EventHandler("shed", function(inst)  
        local x,y,z = inst.Transform:GetWorldPosition()      
        local ents = TheSim:FindEntities(x,y,z,30,TWIGS_MUST)
        local twignums = 0
        for i,ent in ipairs(ents)do
            if ent.prefab == "twigs" then
                twignums = twignums + 1
            end
        end
        if twignums < 3 and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("attack") then 
            inst.sg:GoToState("shed") 
        end 
    end),

    EventHandler("diveandrelocate", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("dive") end end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)            
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.sg:SetTimeout(1 + 2*math.random())            
        end,

        ontimeout = function(inst)            
            if inst.shed_ready then
                inst.sg:GoToState("shed")
            else                    
                local rand = math.random()
                if rand < .5 then
                    inst.sg:GoToState("bellow")
                else
                    inst.sg:GoToState("shake")
                end
            end
        end,
    },

    State{
        name = "shake",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/shake")

        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "bellow",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("bellow")
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/alert")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name="graze",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("graze_loop", true)
            inst.sg:SetTimeout(5+math.random()*5)
            -- inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/chew")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "alert",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/alert")
            inst.AnimState:PlayAnimation("alert_pre")
            inst.AnimState:PushAnimation("alert_idle", true)
        end,
    },

    State{
        name = "attack",
        tags = {"attack"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/attack")
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,


        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/death")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,

    },

    State{
        name = "shed",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
            inst.components.locomotor:StopMoving()
        end,

        timeline=
        {
            
            TimeEvent(4*FRAMES, function(inst)inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/shake") end),

            TimeEvent(8*FRAMES, function(inst) 
                inst.shed_ready = nil

                if inst.components.timer:TimerExists("shed") then
                    inst.components.timer:StopTimer("shed")
                end

                inst.components.timer:StartTimer("shed", TUNING.GRASSGATOR_SHEDTIME_SET + (math.random()* TUNING.GRASSGATOR_SHEDTIME_VAR))                
                inst.components.lootdropper:SpawnLootPrefab("twigs") 
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    

    State{
        name = "fall_pre",
        tags = { "busy" },
        onenter = function(inst)   
            inst.sg:SetTimeout(2)
            inst:Hide()
        end,

        ontimeout = function(inst)            
            inst.sg:GoToState("fall")
        end,

        onexit = function(inst)
            inst:Show()
        end,
    }, 

    State{
        name = "fall",
        tags = { "busy" },
        onenter = function(inst)   
            --inst.AnimState:SetBank("grass_gator_water")         
            --ChangeToCharacterPhysics(inst)
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0, math.random() * 10 - 20, 0)
            inst.AnimState:PlayAnimation("fall_loop", true)
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/fall")
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if not inst.shadow then
                inst.shadow = SpawnPrefab("warningshadow")
                inst.shadow:ListenForEvent("onremove", OnRemoveDebris, inst)
                inst.shadow.Transform:SetPosition(x, 0, z)
            end
            if inst.UpdateShadowSize then
            inst.UpdateShadowSize(inst.shadow, 35-y)
            end

            if y < 2 then
                inst.Physics:SetMotorVel(0, 0, 0)
                if y <= .1 then
                    inst.Physics:Stop()
                    inst.Physics:SetDamping(5)
                    inst.Physics:Teleport(x, 0, z)
                    inst.sg:GoToState(inst.components.amphibiouscreature ~= nil and inst.components.amphibiouscreature.in_water and "land" or "land_on_ground")
                end
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x, 0, z)
            if inst.shadow then inst.shadow:Remove() end
        end,
    },  

    State{
        name = "land",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("fall_pst")
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) 
               spawnwaves(inst, 6, 360, 4, nil, nil, 2, nil, true)
            end),
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large") end),
            
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "land_on_ground",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("fall_land")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, PlayFootstep),
            TimeEvent(26 * FRAMES, PlayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "dive",
        tags = {"canrotate","busy","diving"},

        onenter = function(inst, pushanim)                
            inst.movetoshallow = nil
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("dive")
            
        end,
        
        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) 
                inst.DynamicShadow:Enable(false)
            end),

            TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/submerge/medium") end),

            TimeEvent(27*FRAMES, function(inst) 
                spawnwaves(inst, 6, 360, 4, nil, nil, 2, nil, true)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("dive_loop") end),
        },

        onexit = function(inst)
           inst.DynamicShadow:Enable(true)
        end,
    },

    State{
        name = "dive_loop",
        tags = {"canrotate","noattack","busy","diving"},

        onenter = function(inst, pushanim)   
            inst.DynamicShadow:Enable(false)  
        -- TURN OFF PHYSICS?   
       -- inst.Physics:ClearCollisionMask()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst:Hide()
            inst.sg:SetTimeout(2 + 2*math.random())
        end,

        onupdate = function(inst)            
            if inst.surfacetime then
                if not inst.surfacelocation then
                    if not inst.searchrange then 
                        inst.searchrange = 15 + (math.random()*5) -- Keep in sync with grassgator [GGRANGECHECK]
                    end
                    inst.surfacelocation = inst.findnewshallowlocation(inst, inst.searchrange)
                    inst.searchrange = inst.searchrange + 8
                end
                if inst.surfacelocation then
                    inst.surfacetime = nil
                    inst.searchrange = nil              
                    inst.Transform:SetPosition(inst.surfacelocation.x, 0, inst.surfacelocation.z)
                    inst.surfacelocation = nil
                    inst.sg:GoToState("surface")
                end
            end
        end,

        ontimeout = function(inst)            
            inst.surfacetime = true
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
          
           -- TURN ON PHYSICS
           --MakeCharacterPhysics(inst, 100, .75)

            inst:Show()
        end,
    },

    State{
        name = "surface",
        tags = {"canrotate","busy", "diving"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emerge")
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) 
                spawnwaves(inst, 6, 360, 4, nil, nil, 2, nil, true)
            end),
            TimeEvent(5*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/emerge/medium") 
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
 }

CommonStates.AddWalkStates(
    states,
    {
        walktimeline =
        {
           
            TimeEvent(11*FRAMES, function(inst)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/swim/walk_water_med",nil,.25)
            end
        end),
           TimeEvent(12*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
            end),
           TimeEvent(23*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
            end),
           TimeEvent(36*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                   PlayFootstep(inst)
                end
            end),
            TimeEvent(38*FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/swim/walk_water_med",nil,.25)
                    end
            end),
           TimeEvent(43*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
            end),
        }
    })

CommonStates.AddRunStates(
    states,
    {
        runtimeline =
        {
        TimeEvent(0, function(inst)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/swim/run_water_med")
            else   
            end
        end),
        TimeEvent(1*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
        end),
        TimeEvent(2*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
        end),
        TimeEvent(7*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
        end),
        TimeEvent(8*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    PlayFootstep(inst)
                end
        end),
        }
    })

CommonStates.AddSimpleState(states,"hit", "hit", {"hit", "busy"}, nil, 
    {
        TimeEvent(1*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/sleep_in") 
        end),
    }
)

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

    starttimeline =
    {
        TimeEvent(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/sleep_out")
        end),
    },

    sleeptimeline =
    {
        TimeEvent(4*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/sleep_in") 
        end),
        TimeEvent(49*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("waterlogged2/creatures/grass_gator/sleep_out") 
        end),
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("grassgator", states, events, "idle")

