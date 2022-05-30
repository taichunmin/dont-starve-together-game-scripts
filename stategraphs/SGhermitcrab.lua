require("stategraphs/commonstates")

local PLAYER_TAGS = {"player"}

local function DoEquipmentFoleySounds(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end

local DoRunSounds = function(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

local function DoHurtSound(inst)
    if inst.hurtsoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.hurtsoundoverride, nil, inst.hurtsoundvolume)
    else
        inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/hurt", nil, inst.hurtsoundvolume)
    end
end

local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    else
        inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/talk", "talk")
        return true
    end
end

local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end

--V2C: This is for cleaning up interrupted states with legacy stuff, like
--     freeze and pinnable, that aren't consistently controlled by either
--     the stategraph or the component.
local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

local function DoEmoteFX(inst, prefab)
    local fx = SpawnPrefab(prefab)
    if fx ~= nil then
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "emotefx", 0, 0, 0)
    end
end

local function DoForcedEmoteSound(inst, soundpath)
    inst.SoundEmitter:PlaySound(soundpath)
end

local function DoEmoteSound(inst, soundoverride, loop)
    --NOTE: loop only applies to soundoverride
    loop = loop and soundoverride ~= nil and "emotesoundloop" or nil
    local soundname = soundoverride or "emote"
    local emotesoundoverride = soundname.."soundoverride"
    if inst[emotesoundoverride] ~= nil then
        inst.SoundEmitter:PlaySound(inst[emotesoundoverride], loop)
    else
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/"..soundname, loop)
    end
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function StartTeleporting(inst)
    inst.sg.statemem.isteleporting = true

    inst:Hide()
    inst.DynamicShadow:Enable(false)
end

local function DoneTeleporting(inst)
    inst.sg.statemem.isteleporting = false

    inst:Show()
    inst.DynamicShadow:Enable(true)
end

local function GetUnequipState(inst, data)
    return (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
        or (not data.slip and "item_in")
        or (data.item ~= nil and data.item:IsValid() and "tool_slip")
        or "toolbroke"
        , data.item
end

local function ConfigureRunState(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.sg.statemem.heavy = true
    elseif inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    else
        inst.sg.statemem.normal = true
    end
end

local function GetRunStateAnim(inst)
    return (inst.sg.statemem.heavy and "heavy_walk")
        or (inst.sg.statemem.groggy and "idle_walk")
        or (inst.sg.statemem.careful and "careful_walk")
        or "run"
end

local function GetWalkStateAnim(inst)
    return "walk"
    --[[
    return (inst.sg.statemem.heavy and "heavy_walk")
        or (inst.sg.statemem.groggy and "idle_walk")
        or (inst.sg.statemem.careful and "careful_walk")
        or "walk"
        ]]
end

local function OnRemoveCleanupTargetFX(inst)
    if inst.sg.statemem.targetfx.KillFX ~= nil then
        inst.sg.statemem.targetfx:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
        inst.sg.statemem.targetfx:KillFX()
    else
        inst.sg.statemem.targetfx:Remove()
    end
end

local function DoPortalTint(inst, val)
    if val > 0 then
        inst.components.colouradder:PushColour("portaltint", 154 / 255 * val, 23 / 255 * val, 19 / 255 * val, 0)
        val = 1 - val
        inst.AnimState:SetMultColour(val, val, val, 1)
    else
        inst.components.colouradder:PopColour("portaltint")
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),

    ActionHandler(ACTIONS.FISH, "fishing_pre"),
    ActionHandler(ACTIONS.FISH_OCEAN, "fishing_ocean_pre"),
    ActionHandler(ACTIONS.OCEAN_FISHING_POND, "fishing_ocean_pre"),
    ActionHandler(ACTIONS.OCEAN_FISHING_CAST, function(inst,action) inst.restocklures(inst) return "oceanfishing_cast" end),
    ActionHandler(ACTIONS.OCEAN_FISHING_REEL,
        function(inst, action)
            local fishable = action.invobject ~= nil and action.invobject.components.oceanfishingrod.target or nil
            if fishable ~= nil and fishable.components.oceanfishable ~= nil and fishable:HasTag("partiallyhooked") then
                inst.sg.statemem.continue = true
                return "oceanfishing_sethook"
            elseif inst:HasTag("fishing_idle") and not (inst.sg:HasStateTag("reeling") and not inst.sg.statemem.allow_repeat) then
                inst.sg.statemem.continue = true
                return "oceanfishing_reel"
            end
            return nil
        end),

    ActionHandler(ACTIONS.STORE, "doshortaction"),
    ActionHandler(ACTIONS.DROP,
        function(inst)
            return inst.components.inventory:IsHeavyLifting()
                and "heavylifting_drop"
                or "doshortaction"
        end),

    ActionHandler(ACTIONS.PICK,
        function(inst, action)
            return action.target ~= nil
                and action.target.components.pickable ~= nil
                and (   (action.target.components.pickable.jostlepick and "dojostleaction") or
                        (action.target.components.pickable.quickpick and "doshortaction") or
                        (inst:HasTag("fastpicker") and "doshortaction") or
                        (inst:HasTag("quagmire_fasthands") and "domediumaction") or
                        "dolongaction"  )
                or nil
        end),
    ActionHandler(ACTIONS.TAKEITEM,
        function(inst, action)
            return action.target ~= nil
                and action.target.takeitem ~= nil --added for quagmire
                and "give"
                or "dolongaction"
        end),

    ActionHandler(ACTIONS.PICKUP,
        function(inst, action)
            return action.target ~= nil
                and action.target:HasTag("minigameitem")
                and "dosilentshortaction"
                or "doshortaction"
        end),

    ActionHandler(ACTIONS.BAIT, "doshortaction"),
    ActionHandler(ACTIONS.EAT,
        function(inst, action)
            if inst.sg:HasStateTag("busy") then
                return
            end
            local obj = action.target or action.invobject
            if obj == nil then
                return
            elseif obj.components.edible ~= nil then
                if not inst.components.eater:PrefersToEat(obj) then
                    inst:PushEvent("wonteatfood", { food = obj })
                    return
                end
            elseif obj.components.soul ~= nil then
                if inst.components.souleater == nil then
                    inst:PushEvent("wonteatfood", { food = obj })
                    return
                end
            else
                return
            end
            return (obj.components.soul ~= nil and "eat")
                or (obj.components.edible.foodtype == FOODTYPE.MEAT and "eat")
                or "quickeat"
        end),
    ActionHandler(ACTIONS.GIVE,
        function(inst, action)
            return action.invobject ~= nil
                and action.target ~= nil
                and (   (action.target:HasTag("moonportal") and action.invobject:HasTag("moonportalkey") and "dochannelaction") or
                        (action.invobject.prefab == "quagmire_portal_key" and action.target:HasTag("quagmire_altar") and "quagmireportalkey")
                    )
                or "give"
        end),
    ActionHandler(ACTIONS.GIVETOPLAYER, "give"),
    ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
    ActionHandler(ACTIONS.FEEDPLAYER, "give"),
    ActionHandler(ACTIONS.HARVEST,
        function(inst)
            return "harvest"
        end),

    ActionHandler(ACTIONS.BUNDLE, "bundle"),

    ActionHandler(ACTIONS.UNWRAP,
        function(inst, action)
            return "dolongaction"
        end),

    ActionHandler(ACTIONS.TACKLE, "tackle_pre"),

    ActionHandler(ACTIONS.COMPARE_WEIGHABLE, "give"),
    ActionHandler(ACTIONS.WEIGH_ITEM, "use_pocket_scale"),

    ActionHandler(ACTIONS.COMMENT, function(inst, action)
        if not inst.sg:HasStateTag("talking") then  --  and not inst.components.locomotor.dest
            return "talkto"
        end
    end),
    ActionHandler(ACTIONS.WATER_TOSS, "toss"),
}

local events =
{
    EventHandler("freeze", function(inst)
        inst.sg:GoToState("frozen")
    end),
    EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") then
            return
        end
        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if is_moving and not should_move then
     --       if inst.sg:HasStateTag("running") then
      --          inst.sg:GoToState("run_stop")
       --     else
                inst.sg:GoToState("walk_stop")
         --   end
        elseif not is_moving and should_move then
           -- if inst.components.locomotor:WantsToRun() then
            --    inst.sg:GoToState("run_start")
           -- else
                inst.sg:GoToState("walk_start")
          --  end
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle"))  then
            inst.sg:GoToState("idle")
        end
    end),

    EventHandler("blocked", function(inst, data)
        if inst.sg:HasStateTag("shell") then
            inst.sg:GoToState("shell_hit")
        end
    end),

    EventHandler("snared", function(inst)
        inst.sg:GoToState("startle", true)
    end),

    EventHandler("repelled", function(inst, data)
        inst.sg:GoToState("repelled", data)
    end),

    EventHandler("equip", function(inst, data)
        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
            inst.sg:GoToState("heavylifting_start")
        elseif inst.components.inventory:IsHeavyLifting() then
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("heavylifting_item_hat")
            end
        elseif (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
            inst.sg:GoToState(
                (data.item ~= nil and data.item.projectileowner ~= nil and "catch_equip") or
                (data.eslot == EQUIPSLOTS.HANDS and "item_out") or
                "item_hat"
            )
        elseif data.item ~= nil and data.item.projectileowner ~= nil then
            SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
        end
    end),

    EventHandler("unequip", function(inst, data)
        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("heavylifting_stop")
            end
        elseif inst.components.inventory:IsHeavyLifting() then
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("heavylifting_item_hat")
            end
        elseif inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling") then
            inst.sg:GoToState(GetUnequipState(inst, data))
        end
    end),

    EventHandler("ontalk", function(inst, data)
        if not inst.sg:HasStateTag("talking") and not inst.components.locomotor.dest then
            inst.sg:GoToState("talkto")
        end
    end),

    EventHandler("toolbroke",
        function(inst, data)
            inst.sg:GoToState("toolbroke", data.tool)
        end),

    EventHandler("umbrellaranout",
        function(inst, data)
            if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
                local sameTool = inst.components.inventory:FindItem(function(item)
                    return item:HasTag("umbrella") and
                        item.components.equippable ~= nil and
                        item.components.equippable.equipslot == data.equipslot
                end)
                if sameTool ~= nil then
                    inst.components.inventory:Equip(sameTool)
                end
            end
        end),

    EventHandler("itemranout",
        function(inst, data)
            if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
                local sameTool = inst.components.inventory:FindItem(function(item)
                    return item.prefab == data.prefab and
                        item.components.equippable ~= nil and
                        item.components.equippable.equipslot == data.equipslot
                end)
                if sameTool ~= nil then
                    inst.components.inventory:Equip(sameTool)
                end
            end
        end),

    EventHandler("armorbroke",
        function(inst, data)
            inst.sg:GoToState("armorbroke", data.armor)
        end),

    EventHandler("fishingcancel",
        function(inst)
            if inst.sg:HasStateTag("npc_fishing") and not inst:HasTag("busy") then
                inst.sg:GoToState("fishing_pst")
            end
        end),

    EventHandler("emote",
        function(inst, data)
            if not (inst.sg:HasStateTag("busy") or
                    inst.sg:HasStateTag("nopredict") or
                    inst.sg:HasStateTag("sleeping"))
                and not inst.components.inventory:IsHeavyLifting()
                and (not data.requires_validation or TheInventory:CheckClientOwnership(inst.userid, data.item_type)) then
                inst.sg:GoToState("emote", data)
            end
        end),

    EventHandler("wonteatfood",
        function(inst)
            inst.sg:GoToState("refuseeat")
        end),
    EventHandler("oceanfishing_stoppedfishing",
        function(inst, data)
            if inst.sg:HasStateTag("npc_fishing") then
                if data ~= nil and data.reason ~= nil then

                    if data.reason == "linesnapped" or data.reason == "toofaraway" then
                        inst.sg.statemem.continue = true
                        inst.sg:GoToState("oceanfishing_linesnapped", {escaped_str = STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_LINESNAP})
                    else
                        inst.sg.statemem.continue = true
                        inst.sg:GoToState("oceanfishing_stop", {escaped_str = data.reason == "linetooloose" and STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_LINETOOLOOSE
                                                                            or data.reason == "badcast" and STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_BADCAST
                                                                            or (data.reason == "bothered") and STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_BOTHERED[inst.getgeneralfriendlevel(inst)]
                                                                            or (data.reason ~= "reeledin") and STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_GOTAWAY
                                                                            or nil})
                    end
                else
                    inst.sg.statemem.continue = true
                    inst.sg:GoToState("oceanfishing_stop")
                end
            end
        end),
    EventHandler("eat_food",
        function(inst)
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("eat")
            end
        end),
    EventHandler("tossitem",
        function(inst)
            inst.sg:GoToState("tossitem")
        end),
    EventHandler("use_pocket_scale",
        function(inst, data)
            inst.sg:GoToState("use_pocket_scale", data)
        end),

    EventHandler("dance",
        function(inst, data)
            if not inst.sg:HasStateTag("dancing") then
                inst.sg:GoToState("funnyidle_clack_pre")
            end
        end),

	EventHandler("teleported",
		function(inst)
            inst.sg:GoToState("idle")
        end),

    CommonHandlers.OnHop(),
}

local statue_symbols =
{
    "ww_head",
    "ww_limb",
    "ww_meathand",
    "ww_shadow",
    "ww_torso",
    "frame",
    "rope_joints",
    "swap_grown"
}

local states =
{

    --------------------------------------------------------------------------

    State{
        name = "electrocute",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.fx = SpawnPrefab("shock_fx")

            inst.fx.entity:SetParent(inst.entity)
            inst.fx.entity:AddFollower()
            inst.fx.Follower:FollowSymbol(inst.GUID, "swap_shock_fx", 0, 0, 0)

            inst.components.bloomer:PushBloom("electrocute", "shaders/anim.ksh", -2)
            inst.Light:Enable(true)

            inst.AnimState:PlayAnimation("shock")
            inst.AnimState:PushAnimation("shock_pst", false)

            DoHurtSound(inst)

            inst.sg:SetTimeout(8 * FRAMES + inst.AnimState:GetCurrentAnimationLength())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.fx ~= nil then
                    if not inst:HasTag("electricdamageimmune") then
                        inst.Light:Enable(false)
                        inst.components.bloomer:PopBloom("electrocute")
                    end
                    inst.fx:Remove()
                    inst.fx = nil
                end
            end),

            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.fx ~= nil then
                if not inst:HasTag("electricdamageimmune") then
                    inst.Light:Enable(false)
                    inst.components.bloomer:PopBloom("electrocute")
                end
                inst.fx:Remove()
                inst.fx = nil
            end
        end,
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            if inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() then
                inst.sg:GoToState("sink_fast")
                return
            end

            if not inst.components.timer:TimerExists("complain_time") and not inst.components.timer:TimerExists("speak_time") then
                inst.complain(inst)
            end

            inst.sg.statemem.ignoresandstorm = true

            local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if equippedArmor ~= nil and equippedArmor:HasTag("band") then
                inst.sg:GoToState("enter_onemanband", pushanim)
                return
            end

            local anims = {}
            local dofunny = true

            if inst.components.inventory:IsHeavyLifting() then
                table.insert(anims, "heavy_idle")
                dofunny = false
            else
                if inst:HasTag("groggy") then
                    table.insert(anims, "idle_groggy_pre")
                    table.insert(anims, "idle_groggy")
                else
                    table.insert(anims, "idle_loop")
                end
            end

            if pushanim then
                for k, v in pairs(anims) do
                    inst.AnimState:PushAnimation(v, k == #anims)
                end
            else
                inst.AnimState:PlayAnimation(anims[1], #anims == 1)
                for k, v in pairs(anims) do
                    if k > 1 then
                        inst.AnimState:PushAnimation(v, k == #anims)
                    end
                end
            end

            if dofunny then
                inst.sg:SetTimeout(math.random() * 4 + 2)
            end
        end,

        ontimeout = function(inst)
            local royalty = nil
            local mindistsq = 25
            for i, v in ipairs(AllPlayers) do
                if v ~= inst and
                    v.entity:IsVisible() and
                    v.components.inventory:EquipHasTag("regal") then
                    local distsq = v:GetDistanceSqToInst(inst)
                    if distsq < mindistsq then
                        mindistsq = distsq
                        royalty = v
                    end
                end
            end
            if royalty ~= nil then
                inst.sg:GoToState("bow", royalty)
            else
                inst.sg:GoToState("idle")
            end
        end,
    },


    State{
        name = "alert",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            if inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() then
                inst.sg:GoToState("sink_fast")
                return
            end

            if not inst.components.timer:TimerExists("complain_time") and not inst.components.timer:TimerExists("speak_time") then
                inst.complain(inst)
            end

            inst.sg.statemem.ignoresandstorm = true

            local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if equippedArmor ~= nil and equippedArmor:HasTag("band") then
                inst.sg:GoToState("enter_onemanband", pushanim)
                return
            end

            local anims = {}
            local dofunny = true

            if inst.components.inventory:IsHeavyLifting() then
                table.insert(anims, "heavy_idle")
                dofunny = false
            else
                if inst:HasTag("groggy") then
                    table.insert(anims, "idle_groggy_pre")
                    table.insert(anims, "idle_groggy")
                else
                    table.insert(anims, "idle_loop")
                end
            end

            if pushanim then
                for k, v in pairs(anims) do
                    inst.AnimState:PushAnimation(v, k == #anims)
                end
            else
                inst.AnimState:PlayAnimation(anims[1], #anims == 1)
                for k, v in pairs(anims) do
                    if k > 1 then
                        inst.AnimState:PushAnimation(v, k == #anims)
                    end
                end
            end

            if dofunny then
                inst.sg:SetTimeout(math.random() * 4 + 2)
            end
        end,

        ontimeout = function(inst)
            local royalty = nil
            local mindistsq = 25
            for i, v in ipairs(AllPlayers) do
                if v ~= inst and
                    v.entity:IsVisible() and
                    v.components.inventory:EquipHasTag("regal") then
                    local distsq = v:GetDistanceSqToInst(inst)
                    if distsq < mindistsq then
                        mindistsq = distsq
                        royalty = v
                    end
                end
            end
            if royalty ~= nil then
                inst.sg:GoToState("bow", royalty)
            else
                if inst.getgeneralfriendlevel(inst) == "LOW" then
                    inst.sg:GoToState("funnyidle_tap_pre")
                elseif inst.getgeneralfriendlevel(inst) == "MED" then
                    inst.sg:GoToState("funnyidle_clack_pre")
                else
                    inst.sg:GoToState("funnyidle_tango_pre")
                end
            end
        end,
    },

    -- TAP idle
    State{
        name = "funnyidle_tap_pre",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_tap_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("funnyidle_tap")
            end),
        },
    },

    State{
        name = "funnyidle_tap",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)

            inst.AnimState:PushAnimation("idle_tap_loop")

            inst.sg:SetTimeout(math.random(2,4) * (22 * FRAMES))
        end,

        timeline =
        {

            TimeEvent(1*FRAMES,         function(inst) PlayFootstep(inst) end),
            TimeEvent(11*FRAMES,        function(inst) PlayFootstep(inst) end),
            TimeEvent((1+22)*FRAMES,    function(inst) PlayFootstep(inst) end),
            TimeEvent((11+22)*FRAMES,   function(inst) PlayFootstep(inst) end),
            TimeEvent((1+44)*FRAMES,    function(inst) PlayFootstep(inst) end),
            TimeEvent((11+44)*FRAMES,   function(inst) PlayFootstep(inst) end),
            TimeEvent((1+66)*FRAMES,    function(inst) PlayFootstep(inst) end),
            TimeEvent((11+66)*FRAMES,   function(inst) PlayFootstep(inst) end),
            TimeEvent((1+88)*FRAMES,    function(inst) PlayFootstep(inst) end),
            TimeEvent((11+88)*FRAMES,   function(inst) PlayFootstep(inst) end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("funnyidle_tap_pst")
        end,
    },

    State{
        name = "funnyidle_tap_pst",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_tap_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    -- CLACK idle
    State{
        name = "funnyidle_clack_pre",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_clack_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("funnyidle_clack")
            end),
        },
    },

    State{
        name = "funnyidle_clack",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)

            inst.AnimState:PushAnimation("idle_clack_loop")

            inst.sg:SetTimeout(math.random(2,4) * (31 * FRAMES))
        end,

        timeline = ----jason
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(29*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((13+31)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((29+31)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((13+62)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((29+62)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((13+93)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((29+93)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
        },

        ontimeout = function(inst)
            local dancing = nil
            if inst.getgeneralfriendlevel(inst) == "HIGH" then
                local x,y,z = inst.Transform:GetWorldPosition()
                local players = TheSim:FindEntities(x,y,z, TUNING.HERMITCRAB.DANCE_RANGE, PLAYER_TAGS)

                for i,player in pairs(players)do
                    if player.sg and player.sg:HasStateTag("dancing") then
                        dancing = true
                        break
                    end
                end
            end
            if dancing then
                inst.sg:GoToState("funnyidle_clack")
            else
                inst.sg:GoToState("funnyidle_clack_pst")
            end
        end,
    },

    State{
        name = "funnyidle_clack_pst",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_clack_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    -- TANGO idle
    State{
        name = "funnyidle_tango_pre",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_tango_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("funnyidle_tango")
            end),
        },
    },

    State{
        name = "funnyidle_tango",
        tags = { "idle", "canrotate", "dancing", "alert"},

        onenter = function(inst)

            inst.AnimState:PlayAnimation("idle_tango_loop", true)

            inst.sg:SetTimeout(2 * (81 * FRAMES))
        end,

        timeline = ----jason
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(27*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(44*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent(68*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),

            TimeEvent((3+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((11+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((19+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((27+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((44+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((52+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((60+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
            TimeEvent((68+81)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/clap") end),
        },

        ontimeout = function(inst)
            local dancing = nil
            if inst.getgeneralfriendlevel(inst) == "HIGH" then
                local x,y,z = inst.Transform:GetWorldPosition()

                local player = FindClosestPlayerInRangeSq(x,y,z, TUNING.HERMITCRAB.DANCE_RANGE* TUNING.HERMITCRAB.DANCE_RANGE,true)
                if player and player.sg:HasStateTag("dancing") then
                    dancing = true
                end
            end
            if dancing then
                inst.sg:GoToState("funnyidle_tango")
            else
                inst.sg:GoToState("funnyidle_tango_pst")
            end
        end,
    },

    State{
        name = "funnyidle_tango_pst",
        tags = { "idle", "canrotate", "dancing", "alert" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_tango_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    -- end idles

    State{
        name = "bow",
        tags = { "notalking", "busy", "nopredict", "forcedangle" },

        onenter = function(inst, target)
            if target ~= nil then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("bow_pre")
        end,

        timeline =
        {
            TimeEvent(24 * FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and
                    inst.sg.statemem.target:IsValid() and
                    inst.sg.statemem.target:IsNear(inst, 6) and
                    inst.sg.statemem.target.components.inventory:EquipHasTag("regal") and
                    inst.components.talker ~= nil then
                    inst.dotalkingtimers(inst)
                    inst.components.npc_talker:Say(STRINGS.HERMITCRAB_ANNOUNCE_ROYALTY[math.random(#STRINGS.HERMITCRAB_ANNOUNCE_ROYALTY)])
                else
                    inst.sg.statemem.notalk = true
                end
            end),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.target == nil or
                        (   not inst.sg.statemem.notalk and
                            inst.sg.statemem.target:IsValid() and
                            inst.sg.statemem.target:IsNear(inst, 6) and
                            inst.sg.statemem.target.components.inventory:EquipHasTag("regal")
                        ) then
                        inst.sg.statemem.bowing = true
                        inst.sg:GoToState("bow_loop", { target = inst.sg.statemem.target, talktask = inst.sg.statemem.talktask })
                    else
                        inst.sg:GoToState("bow_pst")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.bowing and inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
    },

    State{
        name = "bow_loop",
        tags = { "notalking", "idle", "canrotate", "forcedangle" },

        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.target = data.target
                inst.sg.statemem.talktask = data.talktask
            end
            inst.AnimState:PlayAnimation("bow_loop", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil and
                not (   inst.sg.statemem.target:IsValid() and
                        inst.sg.statemem.target:IsNear(inst, 6) and
                        inst.sg.statemem.target.components.inventory:EquipHasTag("regal")
                    ) then
                inst.sg:GoToState("bow_pst")
            end
        end,

        events =
        {
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
    },

    State{
        name = "bow_pst",
        tags = { "idle", "canrotate", "forcedangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bow_pst")
            inst.sg:SetTimeout(8 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("bow_pst2")
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
        name = "bow_pst2",
        tags = { "idle", "canrotate" },

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
        name = "chop_start",
        tags = { "prechop", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("chop")
                end
            end),
        },
    },

    State{
        name = "chop",
        tags = { "prechop", "chopping", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation( "chop_loop")
        end,

        timeline =
        {

            TimeEvent(2 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prechop")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_PRIMARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("chopping")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    --We don't have a chop_pst animation
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "mine_start",
        tags = { "premine", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mine")
                end
            end),
        },
    },

    State{
        name = "mine",
        tags = { "premine", "mining", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    local target = inst.sg.statemem.action.target
                    if target ~= nil and target:IsValid() then
                        local frozen = target:HasTag("frozen")
                        local moonglass = target:HasTag("moonglass")
                        if target.Transform ~= nil then
                            local mine_fx = (frozen and "mining_ice_fx") or (moonglass and "mining_moonglass_fx") or "mining_fx"
                            SpawnPrefab(mine_fx).Transform:SetPosition(target.Transform:GetWorldPosition())
                        end
                        inst.SoundEmitter:PlaySound((frozen and "dontstarve_DLC001/common/iceboulder_hit") or (moonglass and "turnoftides/common/together/moon_glass/mine") or "dontstarve/wilson/use_pick_rock")
                    end
                end
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("premine")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_PRIMARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "hammer_start",
        tags = { "prehammer", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hammer")
                end
            end),
        },
    },

    State{
        name = "hammer",
        tags = { "prehammer", "hammering", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("prehammer")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehammer")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_SECONDARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ALTACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "dig_start",
        tags = { "predig", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dig")
                end
            end),
        },
    },

    State{
        name = "dig",
        tags = { "predig", "digging", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("predig")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
            end),

            TimeEvent(35 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_SECONDARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "bugnet_start",
        tags = { "prenet", "working", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("bugnet_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("bugnet")
                end
            end),
        },
    },

    State{
        name = "bugnet",
        tags = { "prenet", "netting", "working", "autopredict" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bugnet")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bugnet", nil, nil, true)
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                local buffaction = inst:GetBufferedAction()
                local tool = buffaction ~= nil and buffaction.invobject or nil
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("prenet")
                inst.SoundEmitter:PlaySound(tool ~= nil and tool.overridebugnetsound or "dontstarve/wilson/dig")
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
        name = "fishing_ocean_pre",
        onenter = function(inst)
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "fishing_pre",
        tags = { "prefish", "npc_fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre")
            inst.AnimState:PushAnimation("fishing_cast", false)
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast") end),
            TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash")
                    inst.sg.statemem.continue = true
                    inst.sg:GoToState("fishing")
                end
            end),
        },
    },

    State{
        name = "fishing",
        tags = { "npc_fishing" },

        onenter = function(inst, pushanim)
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("fishing_idle", true)
            else
                inst.AnimState:PlayAnimation("fishing_idle", true)
            end
            local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equippedTool and equippedTool.components.fishingrod then
                equippedTool.components.fishingrod:WaitForFish()
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("fishingnibble", function(inst)
                inst.sg.statemem.continue = true
                inst.sg:GoToState("fishing_nibble")
            end),
        },
    },

    State{
        name = "fishing_pst",

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pst")
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
        name = "fishing_nibble",
        tags = { "npc_fishing", "nibble" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bite_light_pre")
            inst.AnimState:PushAnimation("bite_light_loop", true)
            inst.sg:SetTimeout(1 + math.random())
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash")
        end,

        ontimeout = function(inst)
            inst.sg.statemem.continue = true
            inst.sg:GoToState("fishing", "bite_light_pst")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("splash")
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("fishingstrain", function(inst)
                inst.sg.statemem.continue = true
                inst.sg:GoToState("fishing_strain")
            end),
        },
    },

    State{
        name = "fishing_strain",
        tags = { "npc_fishing" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bite_heavy_pre")
            inst.AnimState:PushAnimation("bite_heavy_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash")
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_strain", "strain")
        end,

        events =
        {
            EventHandler("fishingcatch", function(inst, data)
                inst.sg.statemem.continue = true
                inst.sg:GoToState("catchfish", data.build)
            end),
            EventHandler("fishingloserod", function(inst)
                inst.sg.statemem.continue = true
                inst.sg:GoToState("loserod")
            end),

        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("splash")
            inst.SoundEmitter:KillSound("strain")

            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,
    },

    State{
        name = "catchfish",
        tags = { "npc_fishing", "catchfish", "busy" },

        onenter = function(inst, build)
            inst.AnimState:PlayAnimation("fish_catch")
            inst.AnimState:OverrideSymbol("fish01", build, "fish01")
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught") end),
            TimeEvent(10*FRAMES, function(inst) inst.sg:RemoveStateTag("npc_fishing") end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland") end),
            TimeEvent(24*FRAMES, function(inst)
                local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equippedTool and equippedTool.components.fishingrod then
                    equippedTool.components.fishingrod:Collect()
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.stopfishing(inst)
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "loserod",
        tags = { "busy", "nopredict" },

        onenter = function(inst)
            local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equippedTool and equippedTool.components.fishingrod then
                equippedTool.components.fishingrod:Release()
                equippedTool:Remove()
            end
            inst.AnimState:PlayAnimation("fish_nocatch")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_lostrod") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.stopfishing(inst)
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "eat",
        tags = { "busy", "nodangle" },

        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()

            local feed = foodinfo and foodinfo.feed
            if feed ~= nil then
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                inst.sg.statemem.feed = foodinfo.feed
                inst.sg.statemem.feeder = foodinfo.feeder
                inst.sg:AddStateTag("pausepredict")
            elseif inst:GetBufferedAction() then
                feed = inst:GetBufferedAction().invobject
            end

            if feed == nil or
                feed.components.edible == nil or
                feed.components.edible.foodtype ~= FOODTYPE.GEARS then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            end

            if feed ~= nil and feed.components.soul ~= nil then
                inst.sg.statemem.soulfx = SpawnPrefab("wortox_eat_soul_fx")
                inst.sg.statemem.soulfx.Transform:SetRotation(inst.Transform:GetRotation())
                inst.sg.statemem.soulfx.entity:SetParent(inst.entity)
            end

            if inst.components.inventory:IsHeavyLifting() then
                inst.AnimState:PlayAnimation("heavy_eat")
            else
                inst.AnimState:PlayAnimation("eat_pre")
                inst.AnimState:PushAnimation("eat", false)
            end
        end,

        timeline =
        {
            TimeEvent(28 * FRAMES, function(inst)
                if inst.sg.statemem.feed == nil then
                    inst:PerformBufferedAction()
                elseif inst.sg.statemem.feed.components.soul == nil then
                    inst.components.eater:Eat(inst.sg.statemem.feed, inst.sg.statemem.feeder)
                elseif inst.components.souleater ~= nil then
                    inst.components.souleater:EatSoul(inst.sg.statemem.feed)
                end
            end),

            TimeEvent(30 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),

            TimeEvent(70 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("eating")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
            if inst.sg.statemem.soulfx ~= nil then
                inst.sg.statemem.soulfx:Remove()
            end
        end,
    },

    State{
        name = "quickeat",
        tags = { "busy" },

        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()

            local feed = foodinfo and foodinfo.feed
            if feed ~= nil then
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                inst.sg.statemem.feed = foodinfo.feed
                inst.sg.statemem.feeder = foodinfo.feeder
                inst.sg:AddStateTag("pausepredict")
            elseif inst:GetBufferedAction() then
                feed = inst:GetBufferedAction().invobject
            end

            if feed == nil or
                feed.components.edible == nil or
                feed.components.edible.foodtype ~= FOODTYPE.GEARS then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            end

            if inst.components.inventory:IsHeavyLifting() then
                inst.AnimState:PlayAnimation("heavy_quick_eat")
            else
                inst.AnimState:PlayAnimation("quick_eat_pre")
                inst.AnimState:PushAnimation("quick_eat", false)
            end
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.feed ~= nil then
                    inst.components.eater:Eat(inst.sg.statemem.feed, inst.sg.statemem.feeder)
                else
                    inst:PerformBufferedAction()
                end
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
        end,
    },

    State{
        name = "refuseeat",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation(inst.components.inventory:IsHeavyLifting() and "heavy_refuseeat" or "refuseeat")
            inst.sg:SetTimeout(22 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(22 * FRAMES, function(inst)
                if inst.sg.statemem.talking then
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:RemoveStateTag("pausepredict")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = StopTalkSound,
    },

    State{
        name = "talk",
        tags = { "idle", "talking" ,"busy"},

        onenter = function(inst, noanim)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            if not noanim then
                inst.AnimState:PlayAnimation(
                    inst.components.inventory:IsHeavyLifting() and
                    "heavy_dial_loop" or
                    "dial_loop",
                    true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = StopTalkSound,
    },

    -- this state runs a buffered action, "talk" does not.
    State{
        name = "talkto",
        tags = { "idle", "talking", "canrotate", "mandatory" },

        onenter = function(inst, noanim)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:PerformBufferedAction()
            if not noanim then
                inst.AnimState:PlayAnimation(
                    inst.components.inventory:IsHeavyLifting() and
                    "heavy_dial_loop" or
                    "dial_loop",
                    true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(TUNING.HERMITCRAB.SPEAKTIME - 0.5)
            inst.stoptalktask = inst:DoTaskInTime(2,function()
                StopTalkSound(inst)
                inst.AnimState:PlayAnimation("idle")
            end)
        end,

        ontimeout = function(inst)

            if inst.delayfriendtask then
                inst.components.friendlevels:CompleteTask(inst.delayfriendtask)
                inst.delayfriendtask = nil
            end

            if inst.itemstotoss then
                inst.sg:GoToState("tossitem")
            else
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()
                    inst.sg:GoToState("talkto")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end,

        onexit = function(inst)
            inst.stoptalktask:Cancel()
            inst.stoptalktask = nil
            StopTalkSound(inst)
        end,
    },

    State{
        name = "unsaddle",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("unsaddle_pre")
            inst.AnimState:PushAnimation("unsaddle", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(21 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "heavylifting_start",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("heavy_pickup_pst")
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
        name = "heavylifting_stop",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)

            local stun_frames = 6
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "heavylifting_item_hat",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_pst", false)

            inst.sg:SetTimeout(12 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "heavylifting_drop",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(12 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "dostandingaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(14 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --give_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "doshortaction",
        tags = { "doing", "busy" },

        onenter = function(inst, silent)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg.statemem.silent = silent
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.silent then
                    inst.components.talker:IgnoreAll("silentpickup")
                    inst:PerformBufferedAction()
                    inst.components.talker:StopIgnoringAll("silentpickup")
                else
                    inst:PerformBufferedAction()
                end
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "dosilentshortaction",

        onenter = function(inst)
            inst.sg:GoToState("doshortaction", true)
        end,
    },

    State{
        name = "domediumaction",

        onenter = function(inst)
            inst.sg:GoToState("dolongaction", .5)
        end,
    },

    State{
        name = "dolongaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, timeout)
            if timeout == nil then
                timeout = 1
            elseif timeout > 1 then
                inst.sg:AddStateTag("slowaction")
            end
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
                    inst.bufferedaction.target:PushEvent("startlongaction")
                end
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("build_pst")
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "harvest",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, timeout)
            if timeout == nil then
                timeout = 1
            elseif timeout > 1 then
                inst.sg:AddStateTag("slowaction")
            end
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
                    inst.bufferedaction.target:PushEvent("startlongaction")
                end
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("build_pst")
            inst:PerformBufferedAction()
            local food = inst.components.inventory:FindItems(function(testitem)
                    if testitem.components.edible and testitem.components.edible.foodtype == FOODTYPE.MEAT then
                        return true
                    end
                end)

            for i=#food,1,-1 do
                food[i]:Remove()
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    local gfl = inst.getgeneralfriendlevel(inst)
                    inst.components.npc_talker:Say( STRINGS.HERMITCRAB_HARVESTMEAT[gfl][math.random(1,#STRINGS.HERMITCRAB_HARVESTMEAT[gfl])]  )
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        --Alternative to doshortaction but animated with your held tool
        --Animation mirrors attack action, but are not "auto" predicted
        --by clients (also no sound prediction)
        name = "dojostleaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()
            local cooldown
            if equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip", false)
                inst.sg.statemem.iswhip = true
                inst.SoundEmitter:PlaySound("dontstarve/common/whip_large")
                cooldown = 17 * FRAMES
            elseif equip ~= nil and equip.components.weapon ~= nil and not equip:HasTag("punch") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                cooldown = 13 * FRAMES
            elseif equip ~= nil and (equip:HasTag("light") or equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                cooldown = 13 * FRAMES
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
                cooldown = 24 * FRAMES
            end

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target:GetPosition())
            end

            inst.sg.statemem.action = buffaction
            inst.sg:SetTimeout(cooldown)
        end,

        timeline =
        {
            --whip: frame 8 remove busy, frame 10 action
            --other: frame 6 remove busy, frame 8 action

            TimeEvent(6 * FRAMES, function(inst)
                if not inst.sg.statemem.iswhip then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip then
                    inst.sg:RemoveStateTag("busy")
                else
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip then
                    inst:PerformBufferedAction()
                end
            end),
        },

        ontimeout = function(inst)
            --anim pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "use_pocket_scale",
        tags = { "doing", "busy", "mandatory" },

        onenter = function(inst, data)

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("pocket_scale_weigh", false)
            inst.SoundEmitter:PlaySound("hookline/common/trophyscale_fish/pocket")

            inst.AnimState:OverrideSymbol("swap_pocket_scale_body", "pocket_scale", "pocket_scale_body")

            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            inst.sg.statemem.str = data.str

            inst.sg.statemem.target = data.target

            if inst.sg.statemem.target then
                inst.sg.statemem.target_build = inst.sg.statemem.target.AnimState:GetBuild()
                inst.AnimState:AddOverrideBuild(inst.sg.statemem.target_build)
            end
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                local weight = inst.sg.statemem.target ~= nil and inst.sg.statemem.target.components.weighable:GetWeight() or nil
                if inst.sg.statemem.str then
                    inst.dotalkingtimers(inst)
                    inst.components.npc_talker:Say(inst.sg.statemem.str)
                else
                    inst.AnimState:ClearOverrideBuild(inst.sg.statemem.target_build)
                    inst.AnimState:SetTime(51 * FRAMES)
                end
                inst:ClearBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)

                if inst.itemstotoss then
                    inst.sg:GoToState("tossitem")
                else
                    if inst.components.npc_talker:haslines() then
                        inst.components.npc_talker:donextline()
                        inst.sg:GoToState("talkto")
                    else
                       inst.sg:GoToState("idle")
                   end
                end

            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideBuild(inst.sg.statemem.target_build)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "tossitem",
        tags = { "doing", "busy", "canrotate", "mandatory" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,


        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)

                if inst.itemstotoss then
                    local player = inst:GetNearestPlayer(true)
                    if player then
                        inst:FacePoint(player.Transform:GetWorldPosition())
                        inst.components.lootdropper:SetFlingTarget(player:GetPosition(), 20)
                    end

                    for i,gift in ipairs(inst.itemstotoss) do
                        if gift and gift:IsValid() then
                            inst.components.inventory:DropItem(gift)
                            inst.components.lootdropper:FlingItem(gift)
                        end
                    end
                    inst.itemstotoss = nil
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.components.npc_talker:haslines() then
                    inst.components.npc_talker:donextline()
                    inst.sg:GoToState("talkto")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "throw",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            --inst.components.combat:SetTarget(target)
            --inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown =  1 -- math.max(inst.components.combat.min_attack_period + .5 * FRAMES, 11 * FRAMES)

            inst.AnimState:PlayAnimation("throw")

            inst.sg:SetTimeout(cooldown)

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg.statemem.thrown = true
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst, data)
                if data.eslot ~= EQUIPSLOTS.HANDS or not inst.sg.statemem.thrown then
                    inst.sg:GoToState("idle")
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "toss",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" ,"busy" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            --inst.components.combat:SetTarget(target)
            --inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("throw")
            inst.AnimState:PushAnimation("look", false)

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg.statemem.thrown = true
                inst.components.timer:StartTimer("bottledelay", 20 + (math.random() * TUNING.TOTAL_DAY_TIME))
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        events =
        {

            EventHandler("animqueueover", function(inst)
                local gfl = inst.getgeneralfriendlevel(inst)
                inst.components.npc_talker:Say( STRINGS.HERMITCRAB_THROWBOTTLE[gfl][math.random(1,#STRINGS.HERMITCRAB_THROWBOTTLE[gfl])]  )
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "catch_pre",
        tags = { "notalking", "readytocatch" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.AnimState:IsCurrentAnimation("catch_pre") then
                inst.AnimState:PlayAnimation("catch_pre")
            end

            inst.sg:SetTimeout(3)
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("catch", function(inst)
                inst:ClearBufferedAction()
                inst.sg:GoToState("catch")
            end),
            EventHandler("cancelcatch", function(inst)
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "catch",
        tags = { "busy", "notalking", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("catch")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_catch")
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

-- WALK
    State{
        name = "walk_start",
        tags = { "moving", "walk", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation(GetWalkStateAnim(inst).."_pre")

            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:WalkForward()
        end,

        timeline =
        {
            --[[
            --heavy lifting
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),
            ]]
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
        name = "walk",
        tags = { "moving", "walking", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:WalkForward()

            local anim = GetWalkStateAnim(inst)
            if anim == "walk" then
                anim = "walk_loop"
            end
            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end

            --V2C: adding half a frame time so it rounds up
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + .5 * FRAMES)
        end,

        onupdate = function(inst)
            inst.components.locomotor:WalkForward()
        end,

        timeline =
        {
            --unmounted
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.normal then

                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --groggy
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.groggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.groggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --heavy lifting
            TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                elseif inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 12 then
                        inst.sg.mem.footsteps = math.random(4, 6)
                        inst:PushEvent("encumberedwalking")
                    elseif inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                end
            end),
        },

        events =
        {
            EventHandler("carefulwalking", function(inst, data)
                if not data.careful then
                    if inst.sg.statemem.careful then
                        inst.sg:GoToState("walk")
                    end
                elseif not (inst.sg.statemem.heavy or
                            inst.sg.statemem.groggy or
                            inst.sg.statemem.careful) then
                    inst.sg:GoToState("walk")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("walk")
        end,
    },

    State{
        name = "walk_stop",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(GetWalkStateAnim(inst).."_pst")
        end,

        timeline =
        {

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


-- RUN
    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pre")

            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            --heavy lifting
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),
        },

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
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:RunForward()

            local anim = GetRunStateAnim(inst)
            if anim == "run" then
                anim = "run_loop"
            end
            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end

            --V2C: adding half a frame time so it rounds up
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + .5 * FRAMES)
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            --unmounted
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --groggy
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.groggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.groggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --heavy lifting
            TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                elseif inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 12 then
                        inst.sg.mem.footsteps = math.random(4, 6)
                        inst:PushEvent("encumberedwalking")
                    elseif inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                end
            end),
        },

        events =
        {
            EventHandler("carefulwalking", function(inst, data)
                if not data.careful then
                    if inst.sg.statemem.careful then
                        inst.sg:GoToState("run")
                    end
                elseif not (inst.sg.statemem.heavy or
                            inst.sg.statemem.groggy or
                            inst.sg.statemem.careful) then
                    inst.sg:GoToState("run")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pst")
        end,

        timeline =
        {

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
        name = "item_hat",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
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
        name = "item_in",
        tags = { "idle", "nodangle", "busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.followfx ~= nil then
                for i, v in ipairs(inst.sg.statemem.followfx) do
                    v:Remove()
                end
            end
        end,
    },

    State{
        name = "item_out",
        tags = { "idle", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
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
        name = "give",
        tags = { "giving" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, frozen)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit")

            if frozen == "noimpactsound" then
                frozen = nil
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end
            DoHurtSound(inst)

            --V2C: some of the woodie's were-transforms have shorter hit anims
            local stun_frames = math.min(math.floor(inst.AnimState:GetCurrentAnimationLength() / FRAMES + .5), frozen and 10 or 6)
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
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
        name = "hit_spike",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst, spike)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if spike ~= nil then
                inst:ForceFacePoint(spike.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("hit_spike_"..(spike ~= nil and spike.spikesize or "short"))

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            DoHurtSound(inst)

            inst.sg:SetTimeout(15 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "hit_push",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            DoHurtSound(inst)

            inst.sg:SetTimeout(6 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "startle",
        tags = { "busy" },

        onenter = function(inst, snap)
            local usehit = inst:HasTag("wereplayer")
            local stun_frames = usehit and 6 or 9

            if snap then
                inst.sg:AddStateTag("nopredict")
            else
                inst.sg:AddStateTag("pausepredict")
            end

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if usehit then
                inst.AnimState:PlayAnimation("hit")
            else
                inst.AnimState:PlayAnimation("distress_pre")
                inst.AnimState:PushAnimation("distress_pst", false)
            end

            DoHurtSound(inst)

            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "oceanfishing_cast",
        tags = { "prefish", "npc_fishing" },
        onenter = function(inst)
            inst.components.timer:StartTimer("fishingtime",20+(math.random()*40))

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_ocean_pre")
        inst.AnimState:PushAnimation("fishing_ocean_cast", false)
            inst.AnimState:PushAnimation("fishing_ocean_cast_loop", true)
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast")
                inst.sg:RemoveStateTag("prefish")
                inst:PerformBufferedAction()
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("newfishingtarget", function(inst, data)
                if data ~= nil and data.target ~= nil and not data.target:HasTag("projectile") then
                    inst.sg.statemem.hooklanded = true
                    inst.AnimState:PushAnimation("fishing_ocean_cast_pst", false)
                end
            end),

            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.hooklanded and inst.AnimState:AnimDone() then
                    inst.sg.statemem.continue = true
                    inst.sg:GoToState("oceanfishing_idle")
                end
            end),
        },
    },

    State{
        name = "oceanfishing_idle",
        tags = { "npc_fishing", "canrotate" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local target = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod.components.oceanfishingrod.target or nil
            if target ~= nil and target.components.oceanfishinghook ~= nil and TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_MIN > 0 then
                inst.sg:SetTimeout(TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_MIN + math.random() * TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_VAR)
            end
        end,

        onupdate = function(inst)
            local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil
            local target = rod ~= nil and rod.components.oceanfishingrod.target or nil
            if target ~= nil then
                if target.components.oceanfishinghook ~= nil or rod.components.oceanfishingrod:IsLineTensionLow() then
                    if not inst.AnimState:IsCurrentAnimation("hooked_loose_idle") then
                        inst.SoundEmitter:KillSound("unreel_loop")
                        inst.AnimState:PlayAnimation("hooked_loose_idle", true)
                    end
                elseif rod.components.oceanfishingrod:IsLineTensionGood() then
                    if not inst.AnimState:IsCurrentAnimation("hooked_good_idle") then
                        inst.SoundEmitter:KillSound("unreel_loop")
                        inst.AnimState:PlayAnimation("hooked_good_idle", true)
                    end
                elseif not inst.AnimState:IsCurrentAnimation("hooked_tight_idle") then
                    inst.SoundEmitter:KillSound("unreel_loop")
                    --inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in1_LP", "unreel_loop") -- SFX WIP
                        inst.AnimState:PlayAnimation("hooked_tight_idle", true)
                    end
                end
        end,

        ontimeout = function(inst)
            if inst.components.talker ~= nil then
                inst.dotalkingtimers(inst)
                inst.components.npc_talker:Say(STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_IDLE_QUOTE, nil, nil, true)

                inst.sg:SetTimeout(inst.sg.timeinstate + TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_MIN + math.random() * TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_VAR)
            end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("unreel_loop")
            inst:RemoveTag("fishing_idle")
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,
    },

    State{
        name = "oceanfishing_reel",
        tags = { "npc_fishing", "doing", "reeling", "canrotate" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            inst.components.locomotor:Stop()

            local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil
            local target = rod ~= nil and rod.components.oceanfishingrod.target or nil
            if target == nil then
                inst:ClearBufferedAction()
            else
                if inst:PerformBufferedAction() then
                    if target.components.oceanfishinghook ~= nil or rod.components.oceanfishingrod:IsLineTensionLow() then
                        if not inst.AnimState:IsCurrentAnimation("hooked_loose_reeling") then
                            inst.SoundEmitter:KillSound("reel_loop")
                            inst.AnimState:PlayAnimation("hooked_loose_reeling", true)
                        end
                    elseif rod.components.oceanfishingrod:IsLineTensionGood() then
                        if not inst.AnimState:IsCurrentAnimation("hooked_good_reeling") then
                            inst.SoundEmitter:KillSound("reel_loop")
                            --inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in2", "reel_loop")
                            inst.AnimState:PlayAnimation("hooked_good_reeling", true)
                        end
                    elseif not inst.AnimState:IsCurrentAnimation("hooked_tight_reeling") then
                            inst.SoundEmitter:KillSound("reel_loop")
                        --inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in3_LP", "reel_loop") -- SFX WIP
                            inst.AnimState:PlayAnimation("hooked_tight_reeling", true)
                        end

                    inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
                end

            end
        end,

        timeline =
        {
            TimeEvent(TUNING.OCEAN_FISHING.REEL_ACTION_REPEAT_DELAY, function(inst) inst.sg.statemem.allow_repeat = true end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.continue = true
            inst.sg:GoToState("oceanfishing_idle")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("reel_loop")
            inst:RemoveTag("fishing_idle")

            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end

        end,
    },


    State{
        name = "oceanfishing_sethook",
        tags = { "npc_fishing", "doing", "busy" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            inst.components.locomotor:Stop()

            --inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in1_LP", "sethook_loop") -- SFX WIP
            inst.AnimState:PlayAnimation("fishing_ocean_bite_heavy_pre")
            inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_loop", false)

            inst:PerformBufferedAction()
        end,

        timeline =
        {
--            TimeEvent(2*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg.statemem.continue = true inst.sg:GoToState("oceanfishing_idle") end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("sethook_loop")
            inst:RemoveTag("fishing_idle")
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,
    },

    State{
        name = "oceanfishing_catch",
        tags = { "npc_fishing", "catchfish", "busy" },

        onenter = function(inst, build)
            inst.AnimState:PlayAnimation("fishing_ocean_catch")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,
    },

    State{
        name = "oceanfishing_stop",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_ocean_pst")

            if data ~= nil and data.escaped_str and inst.components.talker ~= nil then
                inst.dotalkingtimers(inst)
                inst.components.npc_talker:Say(data.escaped_str, nil, nil, true)
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "oceanfishing_linesnapped",
        tags = { "busy", "nomorph"},

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("line_snap")
            inst.sg.statemem.escaped_str = data ~= nil and data.escaped_str or nil
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_linebreak")
            end),
            TimeEvent(29*FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.dotalkingtimers(inst)
                    inst.components.npc_talker:Say(inst.sg.statemem.escaped_str or STRINGS.HERMITCRAB_ANNOUNCE_OCEANFISHING_LINESNAP, nil, nil, true)
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                inst.stopfishing(inst)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "repelled",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("distress_pre")
            inst.AnimState:PushAnimation("distress_pst", false)

            DoHurtSound(inst)

            if data ~= nil and data.radius ~= nil and data.repeller ~= nil and data.repeller:IsValid() then
                local x, y, z = data.repeller.Transform:GetWorldPosition()
                local distsq = inst:GetDistanceSqToPoint(x, y, z)
                local rangesq = data.radius * data.radius
                if distsq < rangesq then
                    if distsq > 0 then
                        inst:ForceFacePoint(x, y, z)
                    end
                    local k = .5 * distsq / rangesq - 1
                    inst.sg.statemem.speed = 25 * k
                    inst.sg.statemem.dspeed = 2
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                end
            end

            inst.sg:SetTimeout(9 * FRAMES)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .25
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "toolbroke",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, tool)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            if tool == nil or not tool.nobrokentoolfx then
                SpawnPrefab("brokentool").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end

            inst.sg.statemem.toolname = tool ~= nil and tool.prefab or nil

            inst.sg:SetTimeout(10 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.toolname ~= nil then
                local sameTool = inst.components.inventory:FindItem(function(item)
                    return item.prefab == inst.sg.statemem.toolname
                end)
                if sameTool ~= nil then
                    inst.components.inventory:Equip(sameTool)
                end
            end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "tool_slip",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/common/tool_slip")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            local splash = SpawnPrefab("splash")
            splash.entity:SetParent(inst.entity)
            splash.entity:AddFollower()
            splash.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0)

            if inst.components.talker ~= nil then
                inst.dotalkingtimers(inst)
                inst.components.npc_talker:Say(GetString(inst, "ANNOUNCE_TOOL_SLIP"))
            end

            inst.sg:SetTimeout(10 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "armorbroke",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, armor)
            ForceStopHeavyLifting(inst)

            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")

            if armor ~= nil then
                local sameArmor = inst.components.inventory:FindItem(function(item)
                    return item.prefab == armor.prefab
                end)
                if sameArmor ~= nil then
                    inst.components.inventory:Equip(sameArmor)
                end
            end

            inst.sg:SetTimeout(10 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "spooked",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("spooked")
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.dotalkingtimers(inst)
                    inst.components.npc_talker:Say(GetString(inst, "ANNOUNCE_SPOOKED"))
                end
            end),
            TimeEvent(49 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
    },


    State{
        name = "emote",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            if data.tags ~= nil then
                for i, v in ipairs(data.tags) do
                    inst.sg:AddStateTag(v)
                    if v == "dancing" then
                        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                        if hat ~= nil and hat.OnStartDancing ~= nil then
                            local newdata = hat:OnStartDancing(inst, data)
                            if newdata ~= nil then
                                inst.sg.statemem.dancinghat = hat
                                data = newdata
                            end
                        end
                    end
                end
                if inst.sg.statemem.dancinghat ~= nil and data.tags ~= nil then
                    for i, v in ipairs(data.tags) do
                        if not inst.sg:HasStateTag(v) then
                            inst.sg:AddStateTag(v)
                        end
                    end
                end
            end

            local anim = data.anim
            local animtype = type(anim)
            if data.randomanim and animtype == "table" then
                anim = anim[math.random(#anim)]
                animtype = type(anim)
            end
            if animtype == "table" and #anim <= 1 then
                anim = anim[1]
                animtype = type(anim)
            end

            if animtype == "string" then
                inst.AnimState:PlayAnimation(anim, data.loop)
            elseif animtype == "table" then
                inst.AnimState:PlayAnimation(anim[1])
                for i = 2, #anim - 1 do
                    inst.AnimState:PushAnimation(anim[i])
                end
                inst.AnimState:PushAnimation(anim[#anim], data.loop == true)
            end

            if data.fx then --fx might be a boolean, so don't do ~= nil
                if data.fxdelay == nil or data.fxdelay == 0 then
                    DoEmoteFX(inst, data.fx)
                else
                    inst.sg.statemem.emotefxtask = inst:DoTaskInTime(data.fxdelay, DoEmoteFX, data.fx)
                end
            elseif data.fx ~= false then
                DoEmoteFX(inst, "emote_fx", nil)
            end

            if data.sound then --sound might be a boolean, so don't do ~= nil
                if (data.sounddelay or 0) <= 0 then
                    inst.SoundEmitter:PlaySound(data.sound)
                else
                    inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoForcedEmoteSound, data.sound)
                end
            elseif data.sound ~= false then
                if (data.sounddelay or 0) <= 0 then
                    DoEmoteSound(inst, data.soundoverride, data.soundlooped)
                else
                    inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoEmoteSound, data.soundoverride, data.soundlooped)
                end
            end

            if data.zoom ~= nil then
                inst.sg.statemem.iszoomed = true
                inst:SetCameraZoomed(true)
                inst:ShowHUD(false)
            end
        end,

        timeline =
        {
            TimeEvent(.5, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.emotefxtask ~= nil then
                inst.sg.statemem.emotefxtask:Cancel()
                inst.sg.statemem.emotefxtask = nil
            end
            if inst.sg.statemem.emotesoundtask ~= nil then
                inst.sg.statemem.emotesoundtask:Cancel()
                inst.sg.statemem.emotesoundtask = nil
            end
            if inst.SoundEmitter:PlayingSound("emotesoundloop") then
                inst.SoundEmitter:KillSound("emotesoundloop")
            end
            if inst.sg.statemem.iszoomed then
                inst:SetCameraZoomed(false)
                inst:ShowHUD(true)
            end
            if inst.sg.statemem.dancinghat ~= nil and
                inst.sg.statemem.dancinghat == inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and
                inst.sg.statemem.dancinghat.OnStopDancing ~= nil then
                inst.sg.statemem.dancinghat:OnStopDancing(inst)
            end
        end,
    },

    State{
        name = "frozen",
        tags = { "busy", "frozen", "nopredict", "nodangle" },

        onenter = function(inst)
            if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
                inst.components.pinnable:Unstick()
            end

            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            --V2C: cuz... freezable component and SG need to match state,
            --     but messages to SG are queued, so it is not great when
            --     when freezable component tries to change state several
            --     times within one frame...
            if inst.components.freezable == nil then
                inst.sg:GoToState("hit", true)
            elseif inst.components.freezable:IsThawing() then
                inst.sg.statemem.isstillfrozen = true
                inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
                inst.sg:GoToState("hit", true)
            end
        end,

        events =
        {
            EventHandler("onthaw", function(inst)
                inst.sg.statemem.isstillfrozen = true
                inst.sg:GoToState("thaw")
            end),
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.isstillfrozen then
                inst.components.inventory:Show()
            end
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing", "nopredict", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },

        onexit = function(inst)
            inst.components.inventory:Show()
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "yawn",
        tags = { "busy", "yawn", "pausepredict" },

        onenter = function(inst, data)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if data ~= nil and
                data.grogginess ~= nil and
                data.grogginess > 0 and
                inst.components.grogginess ~= nil then
                --Because we have the yawn state tag, we will not get
                --knocked out no matter what our grogginess level is.
                inst.sg.statemem.groggy = true
                inst.sg.statemem.knockoutduration = data.knockoutduration
                inst.components.grogginess:AddGrogginess(data.grogginess, data.knockoutduration)
            end

            inst.AnimState:PlayAnimation("yawn")
        end,

        timeline =
        {

        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:RemoveStateTag("yawn")
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.groggy and
                not inst.sg:HasStateTag("yawn") and
                inst.components.grogginess ~= nil then
                --Add a little grogginess to see if it triggers
                --knock out now that we don't have the yawn tag
                inst.components.grogginess:AddGrogginess(.01, inst.sg.statemem.knockoutduration)
            end
        end,
    },

    State{
        name = "bundle",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("wrap_pre")
            inst.AnimState:PushAnimation("wrap_loop", true)
            inst.sg:SetTimeout(.7)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("wrap_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.bundling then
                inst.SoundEmitter:KillSound("make")
            end
        end,
    },

    State{
        name = "bundling",
        tags = { "doing", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            if not inst.AnimState:IsCurrentAnimation("wrap_loop") then
                inst.AnimState:PlayAnimation("wrap_loop", true)
            end
        end,

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst) then
                inst.AnimState:PlayAnimation("wrap_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.bundling then
                inst.SoundEmitter:KillSound("make")
                inst.components.bundler:StopBundling()
            end
        end,
    },

    State{
        name = "bundle_pst",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            if not inst.AnimState:IsCurrentAnimation("wrap_loop") then
                inst.AnimState:PlayAnimation("wrap_loop", true)
            end
            inst.sg:SetTimeout(.7)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.AnimState:PlayAnimation("wrap_pst")
            inst.sg.statemem.finished = true
            inst.components.bundler:OnFinishBundling()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            if not inst.sg.statemem.finished then
                inst.components.bundler:StopBundling()
            end
        end,
    },

}

local function landed_in_water_state(inst)
    return (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() and "sink") or nil
end
CommonStates.AddSimpleState(states, "refuse", "idle_loop", { "busy" })
CommonStates.AddSimpleActionState(states, "gohome", "pickup", 4 * FRAMES, { "busy", "ishome" })
CommonStates.AddSimpleActionState(states, "pickup", "pickup", 10 * FRAMES, { "busy" })

return StateGraph("hermit", states, events, "idle", actionhandlers)
