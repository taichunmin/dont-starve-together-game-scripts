require "prefabs/winter_ornaments"

-- forward delcaration
local queuegifting

local statedata =
{
    { -- empty
        name        = "empty",
        idleanim    = "idle",
        loot        = function(inst) return {inst.seedprefab, "boards", "poop"} end,
        burntloot   = function(inst) return {"boards", "poop"} end,
        burntanim   = "burnt",
        burnfxlevel = 3,
    },
    { -- sapling
        name        = "sapling",
        idleanim    = "idle_sapling",
        burntanim   = "burnt",
        workleft    = 1,
        workaction  = "HAMMER",
        growsound   = "dontstarve/wilson/plant_tree",
        loot        = function(inst)
            local seeds = math.min(inst.maxseeds or 1, 1)
            local items = {"boards", "poop"}
            for i = 1, seeds do
                table.insert(items, inst.seedprefab)
            end
            return items
        end,
        burntloot   = function(inst) return {"ash", "boards", "poop"} end,
        burnfxlevel = 3,
    },
    { -- short
        name        = "short",
        idleanim    = "idle_short",
        sway1anim   = "sway1_loop_short",
        sway2anim   = "sway2_loop_short",
        hitanim     = "chop_short",
        breakrightanim = "fallright_short",
        breakleftanim  = "fallleft_short",
        burntbreakanim = "chop_burnt_short",
        burntanim   = "burnt_short",
        growanim    = "grow_sapling_to_short",
        growsound   = "dontstarve/forest/treeGrow",
        workleft    = TUNING.WINTER_TREE_CHOP_SMALL,
        workaction  = "CHOP",
        loot        = function(inst) return {"log", "boards", "poop"} end,
        burntloot   = function(inst) return {"charcoal", "boards", "poop"} end,
        burnfxlevel = 4,
        burntree    = true,
        shelter     = true,
    },
    { -- normal
        name        = "normal",
        idleanim    = "idle_normal",
        sway1anim   = "sway1_loop_normal",
        sway2anim   = "sway2_loop_normal",
        hitanim     = "chop_normal",
        breakrightanim = "fallright_normal",
        breakleftanim  = "fallleft_normal",
        burntbreakanim = "chop_burnt_normal",
        burntanim   = "burnt_normal",
        growanim    = "grow_short_to_normal",
        growsound   = "dontstarve/forest/treeGrow",
        workleft    = TUNING.WINTER_TREE_CHOP_NORMAL,
        workaction  = "CHOP",
        loot        = function(inst)
            local seeds = math.min(inst.maxseeds or 1, 1)
            local items = {"log", "log", "boards", "poop"}
            for i = 1, seeds do
                table.insert(items, inst.seedprefab)
            end
            return items
        end,
        burntloot   = function(inst) return {"charcoal", "boards", "poop"} end,
        burnfxlevel = 4,
        burntree    = true,
        shelter     = true,
    },
    { -- tall
        name        = "tall",
        idleanim    = "idle_tall",
        sway1anim   = "sway1_loop_tall",
        sway2anim   = "sway2_loop_tall",
        hitanim     = "chop_tall",
        breakrightanim = "fallright_tall",
        breakleftanim  = "fallleft_tall",
        burntbreakanim = "chop_burnt_tall",
        burntanim   = "burnt_tall",
        growanim    = "grow_normal_to_tall",
        growsound   = "dontstarve/forest/treeGrow",
        workleft    = TUNING.WINTER_TREE_CHOP_TALL,
        workaction  = "CHOP",
        loot        = function(inst)
            local seeds = math.min(inst.maxseeds or 2, 2)
            local items = {"log", "log", "log", "boards", "poop"}
            for i = 1, seeds do
                table.insert(items, inst.seedprefab)
            end
            return items
        end,
        burntloot   = function(inst)
            local seeds = math.min(inst.maxseeds or 1, 1)
            local items = {"charcoal", "charcoal", "boards", "poop"}
            for i = 1, seeds do
                table.insert(items, inst.seedprefab)
            end
            return items
        end,
        burnfxlevel = 4,
        burntree    = true,
        shelter     = true,
    },
}

-------------------------------------------------------------------------------
local function PushSway(inst)
    if inst.statedata.sway1anim ~= nil then
        inst.AnimState:PushAnimation(math.random() > .5 and inst.statedata.sway1anim or inst.statedata.sway2anim, true)
    else
        inst.AnimState:PushAnimation(inst.statedata.idleanim, false)
    end
end

local function PlaySway(inst)
    if inst.OnPlayAnim ~= nil then
        inst:OnPlayAnim()
    end
    if inst.statedata.sway1anim ~= nil then
        inst.AnimState:PlayAnimation(math.random() > .5 and inst.statedata.sway1anim or inst.statedata.sway2anim, true)
    else
        inst.AnimState:PlayAnimation(inst.statedata.idleanim, false)
    end
end

local function PlayAnim(inst, anim)
    if inst.OnPlayAnim ~= nil then
        inst:OnPlayAnim()
    end
    inst.AnimState:PlayAnimation(anim)
end

-------------------------------------------------------------------------------
-- Tree Decor

local light_str =
{
    {radius = 3.25, falloff = .85, intensity = 0.75},
}

local function IsLightOn(inst)
    return inst.Light:IsEnabled()
end

local function UpdateLights(inst, light)
    local was_on = IsLightOn(inst)

    local batteries = inst.forceoff ~= true and inst.components.container:FindItems( function(item) return item:HasTag("lightbattery") end ) or {}

    local lightcolour = Vector3(0,0,0)
    local num_lights_on = 0
    for i, v in ipairs(batteries) do
        if v.ornamentlighton then
            lightcolour = lightcolour + Vector3(v.Light:GetColour())
            num_lights_on = num_lights_on + 1
        end
    end

    if light ~= nil then
        local slot = inst.components.container:GetItemSlot(light)
        if slot ~= nil then
            inst.AnimState:OverrideSymbol("plain"..slot, light.winter_ornament_build or "winter_ornaments", light.winter_ornamentid..(light.ornamentlighton and "_on" or "_off"))
        end
    end

    if num_lights_on == 0 then
        if was_on then
            inst.Light:Enable(false)
            inst.AnimState:ClearBloomEffectHandle()
            inst.AnimState:SetLightOverride(0)
        end
    else
        if not was_on then
            inst.Light:Enable(true)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.AnimState:SetLightOverride(0.2)
        end

        inst.Light:SetRadius(light_str[1].radius)
        inst.Light:SetFalloff(light_str[1].falloff)
        inst.Light:SetIntensity(light_str[1].intensity)

        lightcolour:Normalize()
        inst.Light:SetColour(lightcolour.x, lightcolour.y, lightcolour.z)
    end
end

local function RemoveDecor(inst, data)
    inst.AnimState:ClearOverrideSymbol("plain"..data.slot)
    UpdateLights(inst)
end

local function AddDecor(inst, data)
    if inst:HasTag("burnt") or data == nil or data.slot == nil or data.item == nil or data.item.winter_ornamentid == nil then
        return
    end

    if data.item.ornamentlighton ~= nil then
        UpdateLights(inst, data.item)
    else
        inst.AnimState:OverrideSymbol("plain"..data.slot, data.item.winter_ornament_build or "winter_ornaments", data.item.winter_ornamentid)
    end

end

-------------------------------------------------------------------------------
local GIFTING_PLAYER_RADIUS_SQ = 25 * 25

local random_gift1 =
{
    moonrocknugget = 2,
    gears = 1,
    compass = .3,
    sewing_kit = .2,

    --gems
    redgem = .2,
    bluegem = .2,
    greengem = .1,
    orangegem = .1,
    yellowgem = .1,

    --hats
    beefalohat = .5,
    winterhat = .5,
    earmuffshat = .5,
    catcoonhat = .5,
    molehat = .5,
}

local random_gift2 =
{
    gears = .2,
    moonrocknugget = .2,

    --gems
    redgem = .1,
    bluegem = .1,
    greengem = .1,
    orangegem = .1,
    yellowgem = .1,

    --special
    walrushat = .2,
    cane = .2,
    panflute = .1,
}

--V2C: function pasted here for searching
--[[
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end
]]

local function NobodySeesPoint(pt)
    if TheWorld.Map:IsPointNearHole(pt) then
        return false
    end
    for i, v in ipairs(AllPlayers) do
        if CanEntitySeePoint(v, pt.x, pt.y, pt.z) then
            return false
        end
    end
    return true
end

local INLIMBO_TAGS = { "INLIMBO" }
local function NoOverlap(pt)
    return NobodySeesPoint(pt) and #TheSim:FindEntities(pt.x, 0, pt.z, .75, nil, INLIMBO_TAGS) <= 0
end

local function dogifting(inst)
    if TheWorld.state.isnight then
        local players = {}
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(AllPlayers) do
            if v:GetDistanceSqToPoint(x, y, z) < GIFTING_PLAYER_RADIUS_SQ then
                table.insert(players, v)
            end
        end

        if #players > 0 then
            local fully_decorated = inst.components.container:IsFull()
            for _, player in ipairs(players) do
                local loot = {}

                if player.components.wintertreegiftable ~= nil and player.components.wintertreegiftable:GetDaysSinceLastGift() >= 4 then
					player.components.wintertreegiftable:OnGiftGiven()
                    table.insert(loot, { prefab = "winter_food".. math.random(NUM_WINTERFOOD), stack = math.random(3) + (fully_decorated and 3 or 0)})
                    table.insert(loot, { prefab = not fully_decorated and GetRandomBasicWinterOrnament()
											or math.random() < 0.5 and GetRandomFancyWinterOrnament()
											or GetRandomFestivalEventWinterOrnament() })

					table.insert(loot, { prefab = weighted_random_choice(random_gift1) })

					if fully_decorated then
						table.insert(loot, { prefab = weighted_random_choice(random_gift2) })
					else
	                    table.insert(loot, { prefab = PickRandomTrinket() })
					end
                else
                    table.insert(loot, { prefab = "winter_food".. math.random(NUM_WINTERFOOD), stack = math.random(3) })
                    table.insert(loot, { prefab = "charcoal" })
                end

                local items = {}
                for i, v in ipairs(loot) do
                    local item = SpawnPrefab(v.prefab)
                    if item ~= nil then
                        if item.components.stackable ~= nil then
							item.components.stackable:SetStackSize(math.max(1, v.stack or 1))
                        end
                        table.insert(items, item)
                    end
                end
                if #items > 0 then
                    local gift = SpawnPrefab("gift")
                    gift.components.unwrappable:WrapItems(items)
                    for i, v in ipairs(items) do
                        v:Remove()
                    end
                    local pos = inst:GetPosition()
                    local radius = inst:GetPhysicsRadius(0) + .7 + math.random() * .5
                    local theta = inst:GetAngleToPoint(player.Transform:GetWorldPosition()) * DEGREES
                    local offset =
                        FindWalkableOffset(pos, theta, radius, 8, false, true, NoOverlap) or
                        FindWalkableOffset(pos, theta, radius + .5, 8, false, true, NoOverlap) or
                        FindWalkableOffset(pos, theta, radius, 8, false, true, NobodySeesPoint) or
                        FindWalkableOffset(pos, theta, radius + .5, 8, false, true, NobodySeesPoint)
                    if offset ~= nil then
                        gift.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
                    else
                        inst.components.lootdropper:FlingItem(gift)
                    end
                end

                if inst.forceoff then
                    inst:DoTaskInTime(1, function() inst.forceoff = false end, inst)
                end

                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain")
                inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")

                return true
            end
        end
    end
end

local function trygifting(inst)
    inst.giftingtask = nil

    --print("trygifting")

    if TheWorld.state.isnight and inst.components.container ~= nil and not inst.components.container:IsEmpty() then
        local x, y, z = inst.Transform:GetWorldPosition()

        local players_near = {}
        for i, v in ipairs(AllPlayers) do
            if v:GetDistanceSqToPoint(x, y, z) < GIFTING_PLAYER_RADIUS_SQ then
                table.insert(players_near, v)
            end
        end

        local all_players_sleeping = true
        if #players_near > 0 then
            for i, v in ipairs(players_near) do
                if not v:HasTag("sleeping") then
                    all_players_sleeping = false
                    break
                end
            end

            if all_players_sleeping then
                local tree_is_visible = false
                for i, v in ipairs(players_near) do
                    if CanEntitySeePoint(v, x, y, z) then
                        tree_is_visible = true
                        break
                    end
                end

                if tree_is_visible then
                    local batteries = inst.components.container:FindItems( function(item) return item:HasTag("lightbattery") end )
                    if #batteries > 0 then
                        inst.forceoff = true
                        UpdateLights(inst)

                        inst.giftingtask = inst:DoTaskInTime(.2, trygifting, inst)
                        return
                    end
                else
                    if dogifting(inst) then
                        return
                    end
                end
            end
        end

        inst.forceoff = false
        queuegifting(inst)
    end
end

queuegifting = function(inst)
    if IsSpecialEventActive( SPECIAL_EVENTS.WINTERS_FEAST ) and
		TheWorld.state.isnight and
        inst.components.container ~= nil and
        not inst.components.container:IsEmpty() and
        inst.giftingtask == nil then

        --print("queuegifting")
        inst.giftingtask = inst:DoTaskInTime(2, trygifting, inst)
    end
end

-------------------------------------------------------------------------------
local function SetGrowth(inst)
    if inst.components.burnable == nil then
        -- NOTES(JBK): This thing got burnt in the time between the thing growing and now so do nothing.
        return
    end
    local new_size = inst.components.growable.stage
    inst.statedata = statedata[new_size]
    PlaySway(inst)

    inst.components.workable:SetWorkAction(ACTIONS[inst.statedata.workaction])
    inst.components.workable:SetWorkLeft(inst.statedata.workleft)

    inst.components.burnable:SetFXLevel(inst.statedata.burnfxlevel)
    inst.components.burnable:SetBurnTime(inst.statedata.burntree and TUNING.TREE_BURN_TIME or 20)

    if inst.canshelter and inst.statedata.shelter then
        inst:AddTag("shelter")
    end

    if new_size >= #statedata then
        inst.components.container.canbeopened = true
        inst.components.growable:StopGrowing()

        inst:WatchWorldState("isnight", queuegifting)
    end
end

local function DoGrow(inst)
    if inst.statedata.growanim ~= nil then
        PlayAnim(inst, inst.statedata.growanim)
    end
    if inst.statedata.growsound ~= nil then
        inst.SoundEmitter:PlaySound(inst.statedata.growsound)
    end

    PushSway(inst)
end

local GROWTH_STAGES =
{
    {
        time = function(inst) return 0 end,
        fn = SetGrowth,
        growfn = function() end,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[2].base, TUNING.WINTER_TREE_GROW_TIME[2].random) end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[3].base, TUNING.WINTER_TREE_GROW_TIME[3].random) end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[4].base, TUNING.WINTER_TREE_GROW_TIME[4].random) end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
    {
        time = function(inst) return GetRandomWithVariance(TUNING.WINTER_TREE_GROW_TIME[5].base, TUNING.WINTER_TREE_GROW_TIME[5].random) end,
        fn = SetGrowth,
        growfn = DoGrow,
    },
}

local function lootsetfn(lootdropper)
    lootdropper:SetLoot(lootdropper.inst:HasTag("burnt") and lootdropper.inst.statedata.burntloot(lootdropper.inst) or lootdropper.inst.statedata.loot(lootdropper.inst))
end

local function onworked(inst, worker, workleft)
    if workleft > 0 then
        --Beaver can reach here when it's hammer instead of chop
        if inst.statedata.hitanim ~= nil then
            PlayAnim(inst, inst.statedata.hitanim)
            PushSway(inst)
            if not inst.components.container:IsEmpty() then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell")
            end
            if not (worker ~= nil and worker:HasTag("playerghost")) then
                inst.SoundEmitter:PlaySound(
                    worker ~= nil and worker:HasTag("beaver") and
                    "dontstarve/characters/woodie/beaver_chop_tree" or
                    "dontstarve/wilson/use_axe_tree"
                )
            end
            if inst.OnChop ~= nil then
                inst:OnChop(worker, workleft)
            end
        end
    elseif inst:HasTag("burnt") then
        inst.components.lootdropper:DropLoot()

        if inst.statedata.burntbreakanim ~= nil then
            PlayAnim(inst, inst.statedata.burntbreakanim)
            inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
            if not (worker ~= nil and worker:HasTag("playerghost")) then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
            end

            inst.persists = false
            inst:AddTag("NOCLICK")
            inst:DoTaskInTime(1.5, ErodeAway)
        else
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx:SetMaterial("wood")
            inst:Remove()
        end
    else
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("wood")

        inst.components.lootdropper:DropLoot()
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
            inst.components.container.canbeopened = false
        end

        if inst.statedata.breakrightanim ~= nil then
            inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

            if inst.components.growable ~= nil then
                inst.components.growable:StopGrowing()
            end

            local worker_is_to_right = worker and ((worker:GetPosition() - inst:GetPosition()):Dot(TheCamera:GetRightVec()) > 0) or (math.random() > 0.5)
            PlayAnim(inst, worker_is_to_right and inst.statedata.breakleftanim or inst.statedata.breakrightanim)

            inst:ListenForEvent("animover", inst.Remove)
            inst.persists = false
        else
            inst:Remove()
        end
    end
end

-------------------------------------------------------------------------------
local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst:HasTag("fire") and "BURNING")
        or (inst.components.growable.stage == #statedata and "CANDECORATE")
        or "YOUNG"
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)

    if inst.canshelter then
        inst:RemoveTag("shelter")
    end

    if inst.components.growable ~= nil then
        inst.components.growable:StopGrowing()
    end

    PlayAnim(inst, inst.statedata.burntanim)
end

-------------------------------------------------------------------------------

local function onloadpostpass(inst, ents, data)
    inst.statedata = statedata[inst.components.growable.stage]

    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
        PlaySway(inst)
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

        queuegifting(inst)
    end
end

local function onentitywake(inst)
    if inst.giftingtask ~= nil then
        inst.giftingtask:Cancel()
        inst.giftingtask = nil
    end

    queuegifting(inst)
end

local function onentitysleep(inst)
    if inst.giftingtask ~= nil then
        inst.giftingtask:Cancel()
        inst.giftingtask = nil
    end
end

-------------------------------------------------------------------------------

local DECIDUOUS_COLORFUL_COLORS =
{
    "red",
    "orange",
    "yellow",
}
local DECIDUOUS_COLORFUL_BUILDS = {}
local DECIDUOUS_COLORFUL_FX = {}
local DECIDUOUS_COLORFUL_IDS = {}
for i, v in ipairs(DECIDUOUS_COLORFUL_COLORS) do
    local build = "tree_leaf_"..v.."_build"
    table.insert(DECIDUOUS_COLORFUL_BUILDS, build)
    table.insert(DECIDUOUS_COLORFUL_FX, v.."_leaves")
    DECIDUOUS_COLORFUL_IDS[build] = i
end

local function OnDropLeavesFX(inst)
    inst._dropleavestask = nil
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab(inst._dropleavesfx).Transform:SetPosition(x, inst.components.growable.stage == 4 and y - .3 or y, z)
    inst._dropleavesfx = nil
end

local function OnDropDedciduousLeaves(inst)
    inst._droppingleaves = nil
    if inst._dropleavestask ~= nil then
        inst._dropleavestask:Cancel()
        OnDropLeavesFX(inst)
    end
    inst:RemoveEventCallback("animover", OnDropDedciduousLeaves)
    inst.AnimState:ClearOverrideSymbol("swap_leaves")
    inst.AnimState:ClearOverrideSymbol("mouseover")
end

local function SetDeciduousLeaves(inst, build, immediate)
    if inst.leaf_build ~= build then
        if inst._droppingleaves then
            OnDropDedciduousLeaves(inst)
        end
        if build ~= nil then
            inst.AnimState:OverrideSymbol("swap_leaves", build, "swap_leaves")
            if inst.leaf_build == nil then
                inst.AnimState:OverrideSymbol("mouseover", "tree_leaf_trunk_build", "toggle_mouseover")
                if not immediate and inst.components.growable.stage > 2 then
                    PlayAnim(inst, "grow_leaves_"..inst.statedata.name)
                    PushSway(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
                end
                inst.canshelter = true
                if inst.statedata.shelter then
                    inst:AddTag("shelter")
                end
            end
            inst.leaf_id = DECIDUOUS_COLORFUL_IDS[build]
        else
            if not immediate and inst.components.growable.stage > 2 then
                PlayAnim(inst, "drop_leaves_"..inst.statedata.name)
                PushSway(inst)
                inst.SoundEmitter:PlaySound("dontstarve/forest/treeWilt")
                inst._droppingleaves = true
                inst._dropleavesfx = inst.leaf_id ~= nil and DECIDUOUS_COLORFUL_FX[inst.leaf_id] or "green_leaves"
                inst._dropleavestask = inst:DoTaskInTime(11 * FRAMES, OnDropLeavesFX)
                inst:ListenForEvent("animover", OnDropDedciduousLeaves)
            else
                inst.AnimState:ClearOverrideSymbol("swap_leaves")
                inst.AnimState:ClearOverrideSymbol("mouseover")
            end
            inst.canshelter = false
            if inst.statedata.shelter then
                inst:RemoveTag("shelter")
            end
            inst.leaf_id = nil
        end
        inst.leaf_build = build
    end
end

local function deciduous_seasonchanged(inst, season)
    if inst.components.workable:CanBeWorked() then
        SetDeciduousLeaves(inst,
            (season == SEASONS.AUTUMN and DECIDUOUS_COLORFUL_BUILDS[math.random(#DECIDUOUS_COLORFUL_BUILDS)]) or
            (season ~= SEASONS.WINTER and "tree_leaf_green_build") or
            nil,
            false
        )
    end
end

local function deciduous_common_postinit_fn(inst)
    inst.AnimState:Hide("mouseover")
    inst.AnimState:OverrideSymbol("swap_leaves", "tree_leaf_red_build", "swap_leaves")
    inst.AnimState:OverrideSymbol("mouseover", "tree_leaf_trunk_build", "toggle_mouseover")
    if TheWorld.ismastersim then
        inst.leaf_build = "tree_leaf_red_build"
        inst.leaf_id = DECIDUOUS_COLORFUL_IDS[inst.leaf_build]
    end
end

local function deciduous_onextinguish(inst)
    if not inst:HasTag("burnt") then
        inst:WatchWorldState("season", deciduous_seasonchanged)
        deciduous_seasonchanged(inst, TheWorld.state.season)
    end
end

local function deciduous_onburnt(inst)
    inst:StopWatchingWorldState("season", deciduous_seasonchanged)
end

local function deciduous_master_postinit_fn(inst)
    inst:ListenForEvent("onignite", deciduous_onburnt)
    inst:ListenForEvent("onextinguish", deciduous_onextinguish)
    inst:ListenForEvent("burntup", deciduous_onburnt)
    if not inst:HasTag("burnt") then
        deciduous_onextinguish(inst)
    end
end

local function deciduous_onsave(inst, data)
    data.leaf = inst.leaf_id
end

local function deciduous_onload(inst, data)
    if data ~= nil and data.leaf ~= nil then
        local build = DECIDUOUS_COLORFUL_BUILDS[data.leaf]
        if build ~= nil then
            SetDeciduousLeaves(inst, build, true)
        end
    end
end

local function deciduous_onplayanim(inst)
    if inst._droppingleaves then
        OnDropDedciduousLeaves(inst)
    end
end

local function deciduous_onchop(inst)
    if inst.leaf_build ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab((inst.leaf_id ~= nil and DECIDUOUS_COLORFUL_FX[inst.leaf_id] or "green_leaves").."_chop").Transform:SetPosition(x, (inst.components.growable.stage == 4 and y - .3 or y) + math.random() * 2, z)
    end
end

-------------------------------------------------------------------------------

local function evergreen_onchop(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("pine_needles_chop").Transform:SetPosition(x, y + math.random() * 2, z)
end

-------------------------------------------------------------------------------

local palmcone_has_leaf_fx = {["short"] = true, ["normal"] = true, ["tall"] = true,}
local function palmcone_onchop(inst)
    if palmcone_has_leaf_fx[inst.statedata.name] then
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("palmcone_leaf_fx_" .. inst.statedata.name).Transform:SetPosition(x, y + math.random() * 2, z)
    end
end

-------------------------------------------------------------------------------

local trees = {}

local function AddWinterTree(treetype)
    local assets =
    {
        Asset("ANIM", "anim/wintertree_build.zip"),
        Asset("ANIM", "anim/"..treetype.build..".zip"),
        Asset("ANIM", "anim/"..treetype.bank..".zip"),
    }
    if treetype.extrabuilds ~= nil then
        for i, v in ipairs(treetype.extrabuilds) do
            table.insert(assets, Asset("ANIM", "anim/"..v..".zip"))
        end
    end

    local prefabs =
    {
        "charcoal",
        "ash",
        "collapse_small",
        "gift",
    }
    table.insert(prefabs, treetype.seedprefab)
    for i, v in ipairs(GetAllWinterOrnamentPrefabs()) do
        table.insert(prefabs, v)
    end
    for i = 1, NUM_WINTERFOOD do
        table.insert(prefabs, "winter_food"..i)
    end
    if treetype.extraprefabs ~= nil then
        for i, v in ipairs(treetype.extraprefabs) do
            table.insert(prefabs, v)
        end
    end
    for k, v in pairs(random_gift1) do
        table.insert(prefabs, k)
    end
    for k, v in pairs(random_gift2) do
        if random_gift1[k] == nil then
            table.insert(prefabs, k)
        end
    end

    local function onsave(inst, data)
        if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
            data.burnt = true
        end

        data.previousgiftday = inst.previousgiftday

        if treetype.onsave ~= nil then
            treetype.onsave(inst, data)
        end
    end

    local function onload(inst, data)
        if data ~= nil then
            inst.previousgiftday = data.previousgiftday
        end

        if treetype.onload ~= nil then
            treetype.onload(inst, data)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .5)

        inst.MiniMapEntity:SetIcon(treetype.name..".png")
        inst.MiniMapEntity:SetPriority(-1)

        inst.AnimState:SetBank(treetype.bank)
        inst.AnimState:SetBuild(treetype.build)
        inst.AnimState:AddOverrideBuild("wintertree_build")
        inst.AnimState:PlayAnimation("idle")

        inst.Light:Enable(false)

        MakeSnowCoveredPristine(inst)

        inst:AddTag("winter_tree")
		inst:AddTag("decoratable")
        inst:AddTag("structure")
        inst:AddTag("event_trigger")

        inst:SetPrefabNameOverride("winter_tree")

        if treetype.common_postinit ~= nil then
            treetype.common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.OnPlayAnim = treetype.onplayanim
        inst.OnChop = treetype.onchop

        inst.statedata = statedata[1]
        inst.seedprefab = treetype.seedprefab
        inst.canshelter = treetype.shelter
        inst.maxseeds = treetype.maxseeds

        inst:AddComponent("growable")
        inst.components.growable.stages = GROWTH_STAGES
        inst.components.growable.magicgrowable = true

        inst:AddComponent("simplemagicgrower")
        inst.components.simplemagicgrower:SetLastStage(#inst.components.growable.stages)

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLootSetupFn(lootsetfn)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(onworked)

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(treetype.name)
        inst.components.container.canbeopened = false
        -- inst.components.container.skipclosesnd = true
        -- inst.components.container.skipopensnd = true


        inst:AddComponent("timer")

        ---------------------
        MakeHauntableWork(inst)
        MakeSnowCovered(inst)
        MakeMediumBurnable(inst, nil, nil, true)
        MakeMediumPropagator(inst)
        inst.components.burnable:SetOnBurntFn(onburnt)

        inst.OnSave = onsave
        inst.OnLoad = onload
        inst.OnLoadPostPass = onloadpostpass

        inst.components.growable:SetStage(1)

        inst:ListenForEvent("itemget", AddDecor)
        inst:ListenForEvent("itemlose", RemoveDecor)
        inst:ListenForEvent("updatelight", UpdateLights)

        inst.OnEntitySleep = onentitysleep
        inst.OnEntityWake = onentitywake

        if treetype.master_postinit ~= nil then
            treetype.master_postinit(inst)
        end

        return inst
    end

    table.insert(trees, Prefab(treetype.name, fn, assets, prefabs))
end

for i, v in ipairs({
    {
        name = "winter_tree",
        bank = "wintertree",
        build = "evergreen_new",
        seedprefab = "pinecone",
        extraprefabs =
        {
            "pine_needles_chop",
        },
        shelter = true,
        onchop = evergreen_onchop,
    },
    {
        name = "winter_twiggytree",
        bank = "wintertree_twiggy",
        build = "twiggy_build",
        seedprefab = "twiggy_nut",
    },
    {
        name = "winter_deciduoustree",
        bank = "wintertree_deciduous",
        build = "tree_leaf_trunk_build",
        seedprefab = "acorn",
        extrabuilds =
        {
            "tree_leaf_green_build",
            "tree_leaf_red_build",
            "tree_leaf_orange_build",
            "tree_leaf_yellow_build",
        },
        extraprefabs =
        {
            "green_leaves",
            "green_leaves_chop",
            "red_leaves",
            "red_leaves_chop",
            "orange_leaves",
            "orange_leaves_chop",
            "yellow_leaves",
            "yellow_leaves_chop",
        },
        shelter = true, --dynamic
        common_postinit = deciduous_common_postinit_fn,
        master_postinit = deciduous_master_postinit_fn,
        onsave = deciduous_onsave,
        onload = deciduous_onload,
        onplayanim = deciduous_onplayanim,
        onchop = deciduous_onchop,
    },
    {
        name = "winter_palmconetree",
        bank = "wintertree_palmcone",
        build = "wintertree_palmcone",
        seedprefab = "palmcone_seed",
        maxseeds = 1,
        extraprefabs =
        {
            "palmcone_leaf_fx_tall",
            "palmcone_leaf_fx_normal",
            "palmcone_leaf_fx_short",
        },
        onchop = palmcone_onchop,
        shelter = true,
    },
}) do
    AddWinterTree(v)
end

return unpack(trees)
