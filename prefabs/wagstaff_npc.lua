local assets =
{
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),
    Asset("ANIM", "anim/player_emote_extra.zip"),
    Asset("ANIM", "anim/wagstaff_face_swap.zip"),
    Asset("ANIM", "anim/hat_gogglesnormal.zip"),
    Asset("ANIM", "anim/wagstaff.zip"),
}

local contained_assets =
{
    Asset("ANIM", "anim/alterguardian_contained.zip"),
}

local prefabs =
{
    "alterguardian_contained",
    "wagstaff_tool_1",
    "wagstaff_tool_2",
    "wagstaff_tool_3",
    "wagstaff_tool_4",
    "wagstaff_tool_5",
    "moonstorm_static",
    "winter_ornament_boss_wagstaff",
}


--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer ~= nil and ThePlayer:IsNear(inst, 30) then
        ThePlayer:PushEvent("triggeredevent", { name = "wagstaff_experiment" })
    end
end

local function OnMusicDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if inst._musictask ~= nil then
            inst._musictask:Cancel()
        end
        inst._musictask = inst._music:value() and inst:DoPeriodicTask(1, PushMusic, 0) or nil
    end
end

local function StartMusic(inst)
    if not inst._music:value() then
        inst._music:set(true)
        OnMusicDirty(inst)
    end
end

local function StopMusic(inst)
    if inst._music:value() then
        inst._music:set(false)
        OnMusicDirty(inst)
    end
end

--------------------------------------------------------------------------


local SHADER_CUTOFF_HEIGHT = -0.125

local function getline(data)
    if type(data) == "table" then
        return data[math.random(1,#data)]
    else
        return data
    end
end

local function ShouldAcceptItem(inst, item)
    if inst.tool_wanted and item.prefab == inst.tool_wanted then
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_YES_THIS_TOOL))
    if TheWorld.components.moonstormmanager then
        TheWorld.components.moonstormmanager:foundTool()
        item:Remove()
    end
end

local function OnRefuseItem(inst, item)
    if inst.tool_wanted then
        inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_NOT_THIS_TOOL))
    else
        inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_TOO_BUSY))
    end
end

local function OnAttacked(inst, data)

end

local function OnNewTarget(inst, data)

end

local function RetargetFn(inst)
    return nil
end

local function KeepTargetFn(inst, target)
    return nil
end

local function OnItemGet(inst, data)

end

local function OnItemLose(inst, data)

end

local function OnSave(inst, data)
end

local function OnLoad(inst, data)
end

local function WaitForTool(inst)
    inst:PushEvent("waitfortool")

    local tools =
    {
        "wagstaff_tool_1",
        "wagstaff_tool_2",
        "wagstaff_tool_3",
        "wagstaff_tool_4",
        "wagstaff_tool_5",
    }

    local rand = math.random(1,#tools)
    local tool = tools[rand]
    inst.tool_wanted = tool

    local str = getline(STRINGS["WAGSTAFF_NPC_WANT_TOOL_"..rand])
    inst.components.talker:Say(str)
    inst:PushEvent("talk_experiment")
    inst.need_tool_task = inst:DoPeriodicTask(5,function()
        inst.components.talker:Say(str)
        inst:PushEvent("talk_experiment")
    end)
end

local function OnRestoreItemPhysics(item)
    item.Physics:CollidesWith(COLLISION.OBSTACLES)
end

local function LaunchGameItem(inst, item, angle, minorspeedvariance, target)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spd = 3.5 + math.random() * (minorspeedvariance and 1 or 3.5)
    item.Physics:ClearCollisionMask()
    item.Physics:CollidesWith(COLLISION.WORLD)
    item.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    item.Physics:Teleport(x, 2.5, z)
    item.Physics:SetVel(math.cos(angle) * spd, 11.5, math.sin(angle) * spd)
    item:DoTaskInTime(.6, OnRestoreItemPhysics)
    item:PushEvent("knockbackdropped", { owner = inst, knocker = inst, delayinteraction = .75, delayplayerinteraction = .5 })
    if item.components.burnable ~= nil then
        inst:ListenForEvent("onignite", function()
            for k, v in pairs(inst._minigame_elites) do
                k:SetCheatFlag()
            end
        end, item)
    end

    item:ListenForEvent("onland")
end

local function giveblueprints(inst,player, recipe)
    if player and player.components.timer:TimerExists("wagstaff_npc_blueprints") then
        return
    end
    if player and not player.components.builder:KnowsRecipe(recipe) then
        local blueprint = SpawnPrefab(recipe .. "_blueprint")
        local x,y,z = inst.Transform:GetWorldPosition()
        local angle
        if player ~= nil and player:IsValid() then
            angle = 180 - player:GetAngleToPoint(x, 0, z) + (math.random() *10)-5
        else
            local down = TheCamera:GetDownVec()
            angle = math.atan2(down.z, down.x) / DEGREES
        end
        LaunchGameItem(inst, blueprint, GetRandomWithVariance(angle, 5) * DEGREES, true, player)
    end
end

local function waypointadvance(inst, txt)
    local newpos
    if TheWorld.components.moonstormmanager then
        newpos = TheWorld.components.moonstormmanager:AdvanceWagstaff(inst)
    end
    if newpos then
        local speech = STRINGS.WAGSTAFF_NPC_THIS_WAY
        if txt then
            speech = txt
        end
        inst.components.talker:Say(getline(speech))
        inst.components.knownlocations:RememberLocation("clue",newpos)
    else
        inst.busy = inst.busy and inst.busy + 1 or 1
        inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_NO_WAY1))
        inst:DoTaskInTime(4,function()
            inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_NO_WAY2))
            inst:DoTaskInTime(2,function()
                inst:erode(2,nil,true)
            end)
        end)
    end
end

local function doblueprintcheck(inst)
    for i, v in ipairs(AllPlayers) do
        print("FOUND PLAYER",v.prefab)
        if inst:GetDistanceSqToInst(v) < 12*12 then
            giveblueprints(inst,v,"moonstorm_goggleshat")
            giveblueprints(inst,v,"moon_device_construction1")
            if not v.components.timer:TimerExists("wagstaff_npc_blueprints") then
                v.components.timer:StartTimer("wagstaff_npc_blueprints",120)
            end
        end
    end
end

local function onplayernear(inst,player)

    if inst.busy and inst.busy > 0 then
        return
    end
    if not TheWorld.components.moonstormmanager then
        return
    end

    if inst.sg:HasStateTag("moving") and inst.hunt and inst.hunt_count == 0 then
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end

    inst.playerwasnear = true
    inst.busy = inst.busy and inst.busy + 1 or 1
    if inst.hunt_stage == "experiment" then
        inst:StartMusic()
        if TheWorld.components.moonstormmanager and not TheWorld.components.moonstormmanager.tools_task then
            inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_START))
            TheWorld.components.moonstormmanager:beginWagstaffDefence(inst)
        end
    else
        if not TheWorld.components.moonstormmanager.metplayers[player.userid] then

            TheWorld.components.moonstormmanager:AddMetplayer(player.userid)

            inst:PushEvent("talk")
            inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_MEETING))

            inst:DoTaskInTime(3,function()
                doblueprintcheck(inst)

                inst:PushEvent("talk")
                inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_MEETING_2))

                inst:DoTaskInTime(3,function()

                    inst:PushEvent("talk")
                    inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_MEETING_3))

                    inst:DoTaskInTime(3,function()

                        inst:PushEvent("talk")
                        inst.components.talker:Say(getline(STRINGS.WAGSTAFF_NPC_MEETING_4))

                        inst:DoTaskInTime(3,function()
                            waypointadvance(inst,STRINGS.WAGSTAFF_NPC_MEETING_5)
                        end)
                    end)
                end)
            end)
        else
            doblueprintcheck(inst)
            waypointadvance(inst)
        end
    end

end

local wagstaff_npcbrain = require "brains/wagstaff_npcbrain"

local function ontimerdone(inst, data)
    if data.name == "expiretime" then
        inst:Remove()
    end
    if data.name == "wagstaff_movetime" then
        if inst.hunt_count and inst.hunt_count == 0 and TheWorld.components.moonstormmanager then
            local pos = TheWorld.components.moonstormmanager:FindUnmetCharacter()
            if pos then
                inst.components.knownlocations:RememberLocation("clue",pos)
            else
                inst.components.timer:StartTimer("wagstaff_movetime",10 + (math.random()*5))
            end
        end
    end
end
--[[
local function OnSleep(inst)
    inst:Remove()
end
]]

local function erode(inst,time, erodein, removewhendone)

    local time_to_erode  = time or 1
    local tick_time = TheSim:GetTickTime()

    inst:StartThread(function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            if erodein then
                erode_amount = 1 - erode_amount
            end
            inst.AnimState:SetErosionParams(erode_amount, SHADER_CUTOFF_HEIGHT, -1.0)
            ticks = ticks + 1

            local truetest = erode_amount
            local falsetest = 1-erode_amount
            if erodein then
                truetest = 1- erode_amount
                falsetest = erode_amount
            end

            if inst.shadow == true then
                if math.random() < truetest then
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(false)
                    end
                    inst.shadow = false
                    inst.Light:Enable(false)
                end
            else
                if math.random() < falsetest then
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(true)
                    end
                    inst.shadow = true
                    inst.Light:Enable(true)
                end
            end

            if ticks * tick_time > time_to_erode then
                if erodein then
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(true)
                    end
                    inst.shadow = true
                    inst.Light:Enable(true)
                else
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(false)
                    end
                    inst.shadow = false
                    inst.Light:Enable(false)
                end
                if removewhendone then
                    inst:Remove()
                end
            end

            Yield()
        end
    end)
end

local function cleartasks(inst)
    if inst.need_tool_task then
        inst.need_tool_task:Cancel()
        inst.need_tool_task = nil
    end
end

local function OnEntitySleep(inst)
    if inst.hunt_stage and inst.hunt_count and inst.hunt_stage == "hunt" and inst.hunt_count == 0 then
        inst:Remove()
    end
end


local function ontalk(inst)
    inst.SoundEmitter:PlaySound("moonstorm/characters/wagstaff/talk_single")
end

local max_range = TUNING.MAX_INDICATOR_RANGE * 1.5

local function ShouldTrackfn(inst, viewer)
    return inst:IsValid() and
        viewer:HasTag("wagstaff_detector") and
        inst:IsNear(inst, max_range) and
        not inst.entity:FrustumCheck() and
        CanEntitySeeTarget(viewer, inst)
end

local function teleport_override_fn(inst)

    local pt = inst:GetPosition()
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 4, 8, true, false) or
                    FindWalkableOffset(pt, math.random() * 2 * PI, 8, 8, true, false)
    if offset ~= nil then
        pt = pt + offset
    end

    return pt
end

local function OnTeleported(inst)
    if inst.static then
        local pos = inst:GetPosition()
        local radius = 1
        local theta = (inst.Transform:GetRotation() + 90)*DEGREES
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        inst.static.Transform:SetPosition(pos.x+ offset.x, pos.y, pos.z+ offset.z)
      --  inst:FacePoint(static:GetPosition())
        inst:DoTaskInTime(0,function()
            inst:ForceFacePoint(pos.x, pos.y, pos.z)
        end)
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.shadow = true
    inst.Transform:SetFourFaced()

    inst:AddTag("character")
    inst:AddTag("wagstaff_npc")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wagstaff")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("ARM_carry")

    --inst.AnimState:AddOverrideBuild("hat_gogglesnormal")
    inst.AnimState:OverrideSymbol("face", "wagstaff_face_swap", "face")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_gogglesnormal", "swap_hat")
    inst.AnimState:Show("HAT")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(255/255, 200/255, 200/255) --179/255, 107/255)
    inst.Light:Enable(true)

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
    --inst.talksoundoverride = "moonboss/characters/wagstaff/talk_LP"

    if not TheNet:IsDedicated() then
        inst:AddComponent("hudindicatable")
        inst.components.hudindicatable:SetShouldTrackFunction(ShouldTrackfn)
    end

    inst.persists = false

    inst._music = net_bool(inst.GUID, "wagstaff_npc._music", "musicdirty")

    inst.StartMusic = StartMusic
    inst.StopMusic = StopMusic

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3

    --inst:AddComponent("health")
    --inst:AddComponent("combat")
    --inst.components.combat.hiteffectsymbol = "torso"

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    ------------------------------------------

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(7, 9)
    inst.components.playerprox:SetOnPlayerNear(onplayernear)

    ------------------------------------------
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    ------------------------------------------

    inst:AddComponent("inspectable")
    -- inst.components.inspectable.getstatus = GetStatus
    ------------------------------------------

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.WaitForTool = WaitForTool
    inst.getline = getline
    inst.erode = erode
    inst.cleartasks = cleartasks
    inst.doblueprintcheck = doblueprintcheck

    inst:SetStateGraph("SGwagstaff_npc")
    inst:SetBrain(wagstaff_npcbrain)

    inst:AddComponent("teleportedoverride")
    inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    --inst:ListenForEvent("entitysleep", OnSleep)
    inst:ListenForEvent("moonboss_defeated", function()
            inst.busy = inst.busy and inst.busy + 1 or 1
            inst:PushEvent("talk")
            inst.components.talker:Say(getline(STRINGS.WAGSTAFF_GOTTAGO1))
            local msm = TheWorld.components.moonstormmanager
            if inst.hunt_stage == "experiment" and msm then
                inst.failtasks = true
                msm:StopExperimentTasks()
                if msm.spawn_wagstaff_test_task then
                    msm.spawn_wagstaff_test_task:Cancel()
                    msm.spawn_wagstaff_test_task = nil
                end
                inst.static:DoTaskInTime(5,function() inst.static.components.health:Kill() end)
            end

            inst:DoTaskInTime(4,function()
                inst:PushEvent("talk")
                inst.components.talker:Say(getline(STRINGS.WAGSTAFF_GOTTAGO2))
                inst:erode(3,nil,true)
            end)

            -- STOP MORE WAGSTAFFS FROM SPAWNING FOR A WHILE

        end, TheWorld)
    inst:ListenForEvent("ontalk", ontalk)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("ms_stormchanged", function(src, data)
        if data and data.stormtype == STORM_TYPES.MOONSTORM and not inst.donexperiment then
            inst.busy = inst.busy and inst.busy + 1 or 1
            cleartasks(inst)
            inst:PushEvent("talk")
            inst.components.talker:Say(inst.getline(STRINGS.WAGSTAFF_NPC_STORMPASS))
            inst:DoTaskInTime(3, function()
                inst:erode(2,nil,true)
            end)
        end
    end, TheWorld)
    inst:ListenForEvent("teleported", OnTeleported)


    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)

    return inst
end

local function donpcerode(inst, data)
    inst:erode(data.time, data.erodein, data.remove)
    if inst._device ~= nil and inst._device:IsValid() then
        inst._device:erode(data.time, data.erodein, data.remove)
    end
end

local function spawn_device(inst, erode_data)
    inst._device = SpawnPrefab("alterguardian_contained")

    local ipos = inst:GetPosition()
    local offset = FindWalkableOffset(ipos, 2*PI*math.random(), 2.0, nil, true)
    if offset then
        ipos = ipos + offset
    end

    inst._device.Transform:SetPosition(ipos:Get())

    if erode_data then
        inst._device:erode(erode_data.time, erode_data.erodein, erode_data.remove)
    end
end

local function pstbossfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.shadow = true
    inst.Transform:SetFourFaced()

    inst:AddTag("nomagic")
    inst:AddTag("wagstaff_npc")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wagstaff")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("ARM_carry")

    inst.AnimState:OverrideSymbol("face", "wagstaff_face_swap", "face")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_gogglesnormal", "swap_hat")
    inst.AnimState:Show("HAT")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(255/255, 200/255, 200/255)
    inst.Light:Enable(true)

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    if not TheNet:IsDedicated() then
        inst:AddComponent("hudindicatable")
        inst.components.hudindicatable:SetShouldTrackFunction(ShouldTrackfn)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "WAGSTAFF_NPC"

    inst:SetStateGraph("SGwagstaff_npc")

    inst.erode = erode
    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)

    inst:ListenForEvent("ontalk", ontalk)
    inst:ListenForEvent("spawndevice", spawn_device)
    inst:ListenForEvent("doerode", donpcerode)

    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/static_LP", "wagstaffnpc_static_loop")

    return inst
end

local function contained_animover(inst)
    inst.AnimState:PlayAnimation("close_idle")
    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/close")
end

local function docollect(inst)
    inst.Light:Enable(true)

    inst.AnimState:PlayAnimation("collect")
    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/collect")

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        local ornament = SpawnPrefab("winter_ornament_boss_wagstaff")
        inst.components.lootdropper:FlingItem(ornament)
    end

    inst:ListenForEvent("animover", contained_animover)
end

local function alterguardian_containedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 50, .5)

    inst.AnimState:SetBank("alterguardian_contained")
    inst.AnimState:SetBuild("alterguardian_contained")
    inst.AnimState:PlayAnimation("idle")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(255/255, 179/255, 107/255)
    inst.Light:Enable(false)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst.erode = erode
    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)

    inst:ListenForEvent("docollect", docollect)

    return inst
end

return Prefab("wagstaff_npc", fn, assets, prefabs),
        Prefab("wagstaff_npc_pstboss", pstbossfn, assets),
        Prefab("alterguardian_contained", alterguardian_containedfn, contained_assets)
