local PopupDialogScreen = require "screens/redux/popupdialog"

local assets =
{
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),
    Asset("ANIM", "anim/player_emote_extra.zip"),
    Asset("ANIM", "anim/wagstaff_face_swap.zip"),
    Asset("ANIM", "anim/hat_gogglesnormal.zip"),
    Asset("ANIM", "anim/wagstaff.zip"),
    Asset("ANIM", "anim/player_notes.zip"),
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

local pst_prefabs =
{
	"enable_lunar_rift_construction_container",
}

local mutations_prefabs =
{
	"security_pulse_cage",
}

local WAGSTAFF_CHATTER_COLOUR = Vector3(231/256, 165/256, 75/256)

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
        return data[math.random(#data)]
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
    local chatter_index = math.random(#STRINGS.WAGSTAFF_NPC_YES_THIS_TOOL)
    inst.components.talker:Chatter("WAGSTAFF_NPC_YES_THIS_TOOL", chatter_index, nil, nil, CHATPRIORITIES.LOW)
    if TheWorld.components.moonstormmanager then
        TheWorld.components.moonstormmanager:foundTool()
        item:Remove()
    end
end

local function OnRefuseItem(inst, giver, item)
    local chatter_table, chatter_index
    if inst.tool_wanted then
        chatter_table = "WAGSTAFF_NPC_NOT_THIS_TOOL"
        chatter_index = math.random(#STRINGS.WAGSTAFF_NPC_NOT_THIS_TOOL)
    else
        chatter_table = "WAGSTAFF_NPC_TOO_BUSY"
        chatter_index = math.random(#STRINGS.WAGSTAFF_NPC_TOO_BUSY)
    end
    inst.components.talker:Chatter(chatter_table, chatter_index, nil, nil, CHATPRIORITIES.LOW)
end

local function do_tool_chatter(inst, string_table_name)
    inst.components.talker:Chatter(string_table_name, nil, nil, nil, CHATPRIORITIES.HIGH)
    inst:PushEvent("talk_experiment")
end

local NUMTOOLS = 5
local function WaitForTool(inst)
    inst:PushEvent("waitfortool")

    local rand = math.random(NUMTOOLS)
    local tool = "wagstaff_tool_"..rand
    inst.tool_wanted = tool

    local string_table_name = "WAGSTAFF_NPC_WANT_TOOL_"..rand
    do_tool_chatter(inst, string_table_name)
    inst.need_tool_task = inst:DoPeriodicTask(5, do_tool_chatter, nil, string_table_name)
end

local function OnRestoreItemPhysics(item)
    item.Physics:CollidesWith(COLLISION.OBSTACLES)
end

local function LaunchGameItem(inst, item, angle, minorspeedvariance, target)
    local inst_pos = inst:GetPosition()
    local target_pos = target:GetPosition()

    local pos = (inst_pos * 0.8) + (target_pos * 0.2)

    local spd = 2.5 + math.random() * (minorspeedvariance and 1 or 3.5)
    item.Physics:ClearCollisionMask()
    item.Physics:CollidesWith(COLLISION.WORLD)
    item.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    item.Physics:Teleport(pos.x, 0.75, pos.z)
    item.Physics:SetVel(math.cos(angle) * spd, 5, math.sin(angle) * spd)
    item:DoTaskInTime(.6, OnRestoreItemPhysics)
    item:PushEvent("knockbackdropped", { owner = inst, knocker = inst, delayinteraction = .75, delayplayerinteraction = .5 })
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

local function do_no_way_erode(inst)
    inst:erode(2, nil, true)
end
local function do_no_way_2(inst)
    inst.components.talker:Chatter("WAGSTAFF_NPC_NO_WAY2", 1, nil, nil, CHATPRIORITIES.LOW)
    inst:DoTaskInTime(2, do_no_way_erode)
end
local function waypointadvance(inst, txt)
    local newpos
    if TheWorld.components.moonstormmanager then
        newpos = TheWorld.components.moonstormmanager:AdvanceWagstaff(inst)
    end
    if newpos then
        local speech = txt or "WAGSTAFF_NPC_THIS_WAY"
        inst.components.talker:Chatter(speech, math.random(#STRINGS[speech]), nil, nil, CHATPRIORITIES.LOW)
        inst.components.knownlocations:RememberLocation("clue",newpos)
    else
        inst.busy = inst.busy and inst.busy + 1 or 1
        inst.components.talker:Chatter("WAGSTAFF_NPC_NO_WAY1", 1, nil, nil, CHATPRIORITIES.LOW)
        inst:DoTaskInTime(4, do_no_way_2)
    end
end

local function doblueprintcheck(inst)
    for _, player in ipairs(AllPlayers) do
        --print("FOUND PLAYER", player.prefab)
        if inst:GetDistanceSqToInst(player) < 12*12 then
            giveblueprints(inst,player,"moonstorm_goggleshat")
            giveblueprints(inst,player,"moon_device_construction1")
            if not player.components.timer:TimerExists("wagstaff_npc_blueprints") then
                player.components.timer:StartTimer("wagstaff_npc_blueprints",120)
            end
        end
    end
end

local function onplayernear(inst,player)
    if inst.components.knownlocations:GetLocation("machine") then
        return
    end

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
            inst.components.talker:Chatter("WAGSTAFF_NPC_START", math.random(#STRINGS.WAGSTAFF_NPC_START), nil, nil, CHATPRIORITIES.LOW)
            TheWorld.components.moonstormmanager:beginWagstaffDefence(inst)
        end
    else
        if not TheWorld.components.moonstormmanager.metplayers[player.userid] then

            TheWorld.components.moonstormmanager:AddMetplayer(player.userid)

            inst:PushEvent("talk")
            inst.components.talker:Chatter("WAGSTAFF_NPC_MEETING", 0, nil, nil, CHATPRIORITIES.LOW)

            inst:DoTaskInTime(3,function()
                doblueprintcheck(inst)

                inst:PushEvent("talk")
                inst.components.talker:Chatter("WAGSTAFF_NPC_MEETING2", 0, nil, nil, CHATPRIORITIES.LOW)

                inst:DoTaskInTime(3,function()
                    inst:PushEvent("talk")
                    inst.components.talker:Chatter("WAGSTAFF_NPC_MEETING3", 0, nil, nil, CHATPRIORITIES.LOW)

                    inst:DoTaskInTime(3,function()
                        inst:PushEvent("talk")
                        inst.components.talker:Chatter("WAGSTAFF_NPC_MEETING4", 0, nil, nil, CHATPRIORITIES.LOW)

                        inst:DoTaskInTime(3, waypointadvance, "WAGSTAFF_NPC_MEETING_5")
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
    local offset = FindWalkableOffset(pt, math.random() * TWOPI, 4, 8, true, false) or
                    FindWalkableOffset(pt, math.random() * TWOPI, 8, 8, true, false)
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
            inst:ForceFacePoint(pos.x+ offset.x, pos.y, pos.z+ offset.z)
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
    inst:AddTag("moistureimmunity")

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

    local talker = inst:AddComponent("talker")
    talker.fontsize = 35
    talker.font = TALKINGFONT
    talker.offset = Vector3(0, -400, 0)
    talker.name_colour = WAGSTAFF_CHATTER_COLOUR
    talker.chaticon = "npcchatflair_wagstaff"
    talker:MakeChatter()
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
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }

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

    inst.WaitForTool = WaitForTool
    inst.getline = getline
    inst.erode = erode
    inst.cleartasks = cleartasks
    inst.doblueprintcheck = doblueprintcheck

    inst:SetStateGraph("SGwagstaff_npc")
    inst:SetBrain(wagstaff_npcbrain)

    inst:AddComponent("teleportedoverride")
    inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    inst:ListenForEvent("moonboss_defeated", function()
            inst.busy = inst.busy and inst.busy + 1 or 1
            inst:PushEvent("talk")
            inst.components.talker:Chatter("WAGSTAFF_GOTTAGO1", nil, nil, nil, CHATPRIORITIES.LOW)
            local msm = TheWorld.components.moonstormmanager
            if inst.hunt_stage == "experiment" and msm then
                inst.failtasks = true
                msm:StopExperimentTasks()
                if msm.spawn_wagstaff_test_task then
                    msm.spawn_wagstaff_test_task:Cancel()
                    msm.spawn_wagstaff_test_task = nil
                end
                inst.static:DoTaskInTime(5, function(st) st.components.health:Kill() end)
            end

            inst:DoTaskInTime(4,function(i)
                i:PushEvent("talk")
                i.components.talker:Chatter("WAGSTAFF_GOTTAGO2", nil, nil, nil, CHATPRIORITIES.LOW)
                i:erode(3,nil,true)
            end)

            -- STOP MORE WAGSTAFFS FROM SPAWNING FOR A WHILE

        end, TheWorld)
    inst:ListenForEvent("ontalk", ontalk)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("ms_stormchanged", function(src, data)
        if data and data.stormtype == STORM_TYPES.MOONSTORM and not inst.donexperiment then
            inst.busy = inst.busy and inst.busy + 1 or 1
            cleartasks(inst)
            inst:PushEvent("talk")
            inst.components.talker:Chatter("WAGSTAFF_NPC_STORMPASS", nil, nil, nil, CHATPRIORITIES.LOW)
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
    if not data.erodein then
        inst.erodingout = true
    end

    inst:erode(data.time, data.erodein, data.remove)

    if inst._device ~= nil and inst._device:IsValid() then
        inst._device:erode(data.time, data.erodein, data.remove)
        if not data.norelocate then
            inst.components.timer:StartTimer("relocate_wagstaff",math.min(1,data.time-1))
        end
    end
end

local function spawn_device(inst, erode_data)
    inst._device = SpawnPrefab("alterguardian_contained")

    local ipos = inst:GetPosition()
    local offset = FindWalkableOffset(ipos, TWOPI*math.random(), 2.0, nil, true)
    if offset then
        ipos = ipos + offset
    end

    inst._device.Transform:SetPosition(ipos:Get())

    if erode_data then
        inst._device:erode(erode_data.time, erode_data.erodein, erode_data.remove)
    end
end

local function ConstructionSite_OnConstructed(inst, doer)
	if inst.components.constructionsite:IsComplete() then
		inst.rifts_are_open = true
		inst.sg:SetTimeout(0)
		inst:AddTag("shard_recieved")
		inst:AddTag("NOCLICK")
		TheWorld:PushEvent("lunarrift_opened")
	end
end

local function pstbossShouldAcceptItem(inst, item)
	return false
end

local function pstbossOnRefuseItem(inst, giver, item)
	if item.prefab == "alterguardianhatshard" then
		if inst.AnimState:IsCurrentAnimation("build_loop") or inst.AnimState:IsCurrentAnimation("build_pre") then
			if inst.request_task ~= nil then
				inst.request_task:Cancel()
				inst.request_task = nil
			end

            inst.components.talker:Chatter("WAGSTAFF_NPC_YES_THAT1", nil, nil, nil, CHATPRIORITIES.LOW)
			inst:DoTaskInTime(3, function()
                inst.components.talker:Chatter("WAGSTAFF_NPC_YES_THAT2", nil, nil, nil, CHATPRIORITIES.LOW)
			end)

			inst:RemoveComponent("trader")

			--V2C: NOTE: this works because we only need 1 single item, so there
			--           should never be any save data for partial construction.
			inst:AddComponent("constructionsite")
			inst.components.constructionsite:SetConstructionPrefab("enable_lunar_rift_construction_container")
			inst.components.constructionsite:SetOnConstructedFn(ConstructionSite_OnConstructed)
		end
	else
        inst.components.talker:Chatter("WAGSTAFF_NPC_NOTTHAT", nil, nil, nil, CHATPRIORITIES.LOW)
		if inst.request_task ~= nil then
			inst.request_task:Cancel()
		end
		inst.request_task = inst:DoPeriodicTask(10, inst.doplayerrequest)
	end
end

local function doplayerrequest(inst)
    local echo_priority = (inst.sg.statemem.request >= 3 and CHATPRIORITIES.HIGH) or CHATPRIORITIES.LOW
    inst.components.talker:Chatter("WAGSTAFF_NPC_REQUEST", inst.sg.statemem.request, nil, nil, echo_priority)
    inst.sg.statemem.request = inst.sg.statemem.request +1
    if inst.sg.statemem.request >= 9 then
        inst.sg.statemem.request = math.random(9,#STRINGS.WAGSTAFF_NPC_REQUEST)
    end
end

local RELOCATE_MUST_NOT = {"INLIMBO","noblock","FX"}
local PLAYER_MUST = {"player"}
local ERODEIN =
{
    time = 3.5,
    erodein = true,
    remove = false,
}
local function relocate_wagstaff(inst)
    local nodes = {}
    for i,node in ipairs(TheWorld.topology.nodes)do
        table.insert(nodes,i)
    end
    local location = false
    while location == false and #nodes > 0 do
        local rand = math.random(1,#nodes)
        local testnode = nodes[rand]
        table.remove(nodes,rand)

        local pos = TheWorld.topology.nodes[testnode].cent
        if pos then
            if TheWorld.Map:IsVisualGroundAtPoint(pos[1],0,pos[2]) then
               local ents = TheSim:FindEntities(pos[1], 0, pos[2], 5, nil, RELOCATE_MUST_NOT)
               if #ents <= 0 then
                    local ents2 = TheSim:FindEntities(pos[1], 0, pos[2], PLAYER_CAMERA_SEE_DISTANCE , PLAYER_MUST)
                    if #ents2<=0 then
                        location = pos
                    end
                end
            end
        end
    end

    if location ~= false then
        local wagstaff = SpawnPrefab("wagstaff_npc_pstboss")
        wagstaff.Transform:SetPosition(location[1],0,location[2])
        wagstaff:PushEvent("spawndevice", ERODEIN)
        wagstaff:PushEvent("continuework")
        wagstaff.continuework = true
        wagstaff.persists = true
    end
end

local function pstbossontimerdone(inst,data)
    
    if data and data.name == "relocate_wagstaff" then
        if TUNING.SPAWN_RIFTS == 1 and TheWorld.components.riftspawner and not TheWorld.components.riftspawner:GetEnabled()  then
            relocate_wagstaff(inst)
        end
    end
end

local function PstBossOnSave(inst, data)
   if inst.continuework then
        data.continuework = true
    end
end

local function PstBossOnLoad(inst, data)
    if TUNING.SPAWN_RIFTS ~= 1 then
        inst:Remove()
    else
        if data and data.continuework and data.continuework == true then
            inst:PushEvent("continuework")
            inst:PushEvent("spawndevice", ERODEIN)
            inst.continuework = true
            inst.persists = true
        end
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
	inst:AddTag("character")
    inst:AddTag("wagstaff_npc")
    inst:AddTag("moistureimmunity")
    inst:AddTag("trader_just_show")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

	--Sneak these into pristine state for optimization
	inst:AddTag("__constructionsite")

	-- Offer action strings.
	inst:AddTag("offerconstructionsite")

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

    local talker = inst:AddComponent("talker")
    talker.fontsize = 35
    talker.font = TALKINGFONT
    talker.offset = Vector3(0, -400, 0)
    talker.name_colour = WAGSTAFF_CHATTER_COLOUR
    talker.chaticon = "npcchatflair_wagstaff"
    talker:MakeChatter()

    if not TheNet:IsDedicated() then
        inst:AddComponent("hudindicatable")
        inst.components.hudindicatable:SetShouldTrackFunction(ShouldTrackfn)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

	--Remove these tags so that they can be added properly when replicating components below
	inst:RemoveTag("__constructionsite")

	inst:PrereplicateComponent("constructionsite")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "WAGSTAFF_NPC"

    inst:AddComponent("trader")
    inst.components.trader:Disable()
    inst.components.trader:SetAcceptTest(pstbossShouldAcceptItem)
    inst.components.trader.onrefuse = pstbossOnRefuseItem
    inst.doplayerrequest = doplayerrequest

    inst:SetStateGraph("SGwagstaff_npc")

    inst.erode = erode
    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)

    inst:ListenForEvent("ontalk", ontalk)
    inst:ListenForEvent("spawndevice", spawn_device)
    inst:ListenForEvent("doerode", donpcerode)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", pstbossontimerdone)

	inst:ListenForEvent("ms_despawn_wagstaff_npc_pstboss", function()
		if inst:IsAsleep() then
			inst:Remove()
		else
			inst.persists = false
			inst.sg:GoToState("capture_emote", true) --true for norelocate
			inst:DoTaskInTime(20, inst.Remove)
		end
	end, TheWorld)

    inst.OnSave = PstBossOnSave
    inst.OnLoad = PstBossOnLoad

    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/static_LP", "wagstaffnpc_static_loop")

    return inst
end

----------------------------------------------------------------------------------------------------------------------------------------

local TALK_ABOUT_MUTATED_CREATURE_TIMERNAME = "talkaboutmutatedcreature"

local MUTATIONS_TIME_TAKING_NOTES = 4
local MUTATATIONS_DIALOGUE_LINE_DURATION = 2.5

local MUTATIONS_TASK_DELAYS = {
    SHOW_UP = 3,
    TAKE_NOTES = ERODEIN.time - 0.5, -- Runs at MUTATIONS_TASK_DELAYS.SHOW_UP.
    GIVE_SECURITY_PULSE_CAGE = 2.15 * MUTATATIONS_DIALOGUE_LINE_DURATION,                 -- Run at MUTATIONS_TASK_DELAYS.START_TALKING.
    GIVE_SECURITY_PULSE_CAGE_TASKCOMPLETED = 1.15 * MUTATATIONS_DIALOGUE_LINE_DURATION,   -- Run at MUTATIONS_TASK_DELAYS.START_TALKING_TASKCOMPLETED.
}

MUTATIONS_TASK_DELAYS.START_TALKING = MUTATIONS_TASK_DELAYS.SHOW_UP + MUTATIONS_TASK_DELAYS.TAKE_NOTES + MUTATIONS_TIME_TAKING_NOTES + 1.75
MUTATIONS_TASK_DELAYS.START_TALKING_TASKCOMPLETED = MUTATIONS_TASK_DELAYS.SHOW_UP + MUTATIONS_TASK_DELAYS.TAKE_NOTES + 1


local WAGSTAFF_MUTATIONS_DIALOGUE_LOOKUP =
{
    "WAGSTAFF_NPC_DEFEAT_TWO_MORE_MUTATIONS",
    "WAGSTAFF_NPC_DEFEAT_ONE_MORE_MUTATION",
    "WAGSTAFF_NPC_ALL_MUTATIONS_DEFEATED",
}

local function Mutations_GiveSecurityPulseCage(inst)
    inst._giverewardtask = nil

    local x, y, z = inst.Transform:GetWorldPosition()
    local player = FindClosestPlayer(x, y, z)

    if player ~= nil and player:IsValid() then
        local cage = SpawnPrefab("security_pulse_cage")
        
        local angle = 180 - player:GetAngleToPoint(x, 0, z) + (math.random() * 10) - 5

        LaunchGameItem(inst, cage, GetRandomWithVariance(angle, 5) * DEGREES, true, player)
    end

    if inst._lunarriftmutationsmanager ~= nil then
        inst._lunarriftmutationsmanager:OnRewardGiven()
    end

    inst.persists = false
end

local function ShowUp(inst)
    inst:Show()
    inst:PushEvent("doerode", ERODEIN)

    inst.sg:GoToState("idle", "idle_loop")

    if inst._lunarriftmutationsmanager == nil or not inst._lunarriftmutationsmanager:IsTaskCompleted() then
        inst:DoTaskInTime(MUTATIONS_TASK_DELAYS.TAKE_NOTES, function(inst)
            inst.sg:GoToState("analyzing_pre")
        end)
    end

    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/static_LP", "wagstaffnpc_static_loop")
end

local function _Mutations_TalkAboutMutatedCreature_Internal(inst)
    inst._talktask = nil

    if inst._lunarriftmutationsmanager ~= nil then
        local quest_done = inst._lunarriftmutationsmanager:ShouldGiveReward()

        local giverewardtask_time

        if not inst._lunarriftmutationsmanager:IsTaskCompleted() then
            giverewardtask_time = MUTATIONS_TASK_DELAYS.GIVE_SECURITY_PULSE_CAGE

            local num_defeated = inst._lunarriftmutationsmanager:GetNumDefeatedMutations()

            -- Making sure we are in this state, because this function can be called during analyzing state.
            inst.sg:GoToState("analyzing_pre")

            local strings_index = WAGSTAFF_MUTATIONS_DIALOGUE_LOOKUP[num_defeated]
            inst.components.npc_talker:Chatter(strings_index)
            inst.components.npc_talker:donextline()

        else
            giverewardtask_time = MUTATIONS_TASK_DELAYS.GIVE_SECURITY_PULSE_CAGE_TASKCOMPLETED

            -- Making sure we are in this state, because this function can be called during analyzing state.
            inst.sg:GoToState("idle", "idle_loop")

            local strings_index = "WAGSTAFF_NPC_MUTATION_DEFEATED_AFTER_TASK_COMPLETED"..math.random(3)
            inst.components.npc_talker:Chatter(strings_index)
            inst.components.npc_talker:donextline()
        end

        inst.sg:GoToState("analyzing")

        if quest_done and inst._giverewardtask == nil then
            inst._giverewardtask = inst:DoTaskInTime(giverewardtask_time, inst.GiveSecurityPulseCage)
        end
    end
end

local function Mutations_TalkAboutMutatedCreature(inst, existing)
    if inst._lunarriftmutationsmanager ~= nil then
        local quest_done = inst._lunarriftmutationsmanager:ShouldGiveReward()

        if quest_done then
            inst.persists = true
        end

        local talktask_time = inst._lunarriftmutationsmanager:IsTaskCompleted() and MUTATIONS_TASK_DELAYS.START_TALKING_TASKCOMPLETED or MUTATIONS_TASK_DELAYS.START_TALKING 

        if not existing then
            inst:DoTaskInTime(MUTATIONS_TASK_DELAYS.SHOW_UP, ShowUp)
            inst._talktask = inst:DoTaskInTime(talktask_time, _Mutations_TalkAboutMutatedCreature_Internal)

        elseif inst._talktask == nil then
            _Mutations_TalkAboutMutatedCreature_Internal(inst)
        end
    end
end

local function Mutations_OnLoad(inst)
    -- Wagstaff persist only if the quest is complete.

    if inst._lunarriftmutationsmanager ~= nil then
        inst._lunarriftmutationsmanager:OnRewardGiven()

        inst:DoTaskInTime(0, ReplacePrefab, "security_pulse_cage")
    else
        inst:DoTaskInTime(0, inst.Remove)
    end
end

local function Mutations_OnEntitySleep(inst)
    -- Wagstaff persist only if the quest is complete.
    if inst._lunarriftmutationsmanager ~= nil and inst.persists then
        inst._lunarriftmutationsmanager:OnRewardGiven()

        return ReplacePrefab(inst, "security_pulse_cage")
    end

    inst:Remove()
end

local function MutationsQuestFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.DynamicShadow:Enable(false)
    inst.shadow = true
    inst.Transform:SetFourFaced()

    inst:AddTag("nomagic")
	inst:AddTag("character")
    inst:AddTag("wagstaff_npc")
    inst:AddTag("moistureimmunity")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wagstaff")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("ARM_carry")

    inst.AnimState:AddOverrideBuild("player_notes")

    inst.AnimState:OverrideSymbol("face", "wagstaff_face_swap", "face")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_gogglesnormal", "swap_hat")
    inst.AnimState:Show("HAT")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(255/255, 200/255, 200/255)
    inst.Light:Enable(false)

    local talker = inst:AddComponent("talker")
    talker.fontsize = 35
    talker.font = TALKINGFONT
    talker.offset = Vector3(0, -400, 0)
    talker.name_colour = WAGSTAFF_CHATTER_COLOUR
    talker.chaticon = "npcchatflair_wagstaff"
    talker:MakeChatter()

    local npc_talker = inst:AddComponent("npc_talker")
    npc_talker.default_chatpriority = CHATPRIORITIES.HIGH
    npc_talker.speaktime = 3.5

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._lunarriftmutationsmanager = TheWorld.components.lunarriftmutationsmanager
    inst.TIME_TAKING_NOTES = MUTATIONS_TIME_TAKING_NOTES

    inst:Hide()

    inst.persists = false

    inst:AddComponent("inspectable")

    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)

    inst:ListenForEvent("doerode", donpcerode)

    inst:SetStateGraph("SGwagstaff_npc")
    
    inst.erode = erode
    inst.GiveSecurityPulseCage = Mutations_GiveSecurityPulseCage
    inst.TalkAboutMutatedCreature = Mutations_TalkAboutMutatedCreature

    inst.OnLoad = Mutations_OnLoad

    inst.OnEntitySleep = Mutations_OnEntitySleep

    return inst
end

----------------------------------------------------------------------------------------------------------------------------------------

local function wagpunk_ShowUp(inst)
    inst:Show()
    inst:PushEvent("doerode", ERODEIN)

    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/static_LP", "wagstaffnpc_static_loop")
end

local function WagpunkFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.DynamicShadow:Enable(false)
    inst.shadow = true
    inst.Transform:SetFourFaced()

    inst:AddTag("nomagic")
	inst:AddTag("character")
    inst:AddTag("wagstaff_npc")
    inst:AddTag("moistureimmunity")

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
    inst.Light:Enable(false)

    local talker = inst:AddComponent("talker")
    talker.fontsize = 35
    talker.font = TALKINGFONT
    talker.offset = Vector3(0, -400, 0)
    talker.name_colour = WAGSTAFF_CHATTER_COLOUR
    talker.chaticon = "npcchatflair_wagstaff"
    talker:MakeChatter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:Hide()

    inst.persists = false

    ------------------------------------------
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    ------------------------------------------
    inst:AddComponent("knownlocations")
    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3

    inst:AddComponent("inspectable")

    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)

    inst:ListenForEvent("doerode", donpcerode)

    inst:SetStateGraph("SGwagstaff_npc")
    inst:SetBrain(wagstaff_npcbrain)
    
    inst.erode = erode

    inst:DoTaskInTime(0,wagpunk_ShowUp)

    return inst
end


----------------------------------------------------------------------------------------------------------------------------------------

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

    inst.scrapbook_specialinfo = "ALTERGUARDIANCONTAINED"

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

----------------------------------------------------------------------------

local function EnableRiftContainerFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

	inst:AddTag("bundle")

	-- Offer action strings.
	inst:AddTag("offerconstructionsite")

    -- Blank string for controller action prompt.
    inst.name = " "
	inst.POPUP_STRINGS = STRINGS.UI.START_LUNAR_RIFTS

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("enable_lunar_rift_construction_container")

    inst.persists = false

    return inst
end

----------------------------------------------------------------------------

return Prefab("wagstaff_npc", fn, assets, prefabs),
        Prefab("wagstaff_npc_pstboss", pstbossfn, assets, pst_prefabs),
        Prefab("wagstaff_npc_mutations", MutationsQuestFn, assets, mutations_prefabs),
        Prefab("wagstaff_npc_wagpunk", WagpunkFn, assets),
        Prefab("alterguardian_contained", alterguardian_containedfn, contained_assets),
		Prefab("enable_lunar_rift_construction_container",  EnableRiftContainerFn)
