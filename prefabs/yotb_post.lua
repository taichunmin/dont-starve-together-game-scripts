local yotb_common = require("prefabs/yotb_placer_common")

local assets =
{
    Asset("ANIM", "anim/yotb_post.zip"),
    Asset("ANIM", "anim/yotb_post_item.zip"),
    Asset("ANIM", "anim/yotb_post_rug.zip"),
    Asset("MINIMAP_IMAGE", "yotb_post"),
    Asset("SCRIPT", "scripts/prefabs/yotb_placer_common.lua"),
}

local prefabs =
{
    "collapse_big",
    "yotb_post_spotlight",
    "yotb_post_rug",
    "yotb_post_ribbon",
}

local assets_light =
{
    Asset("ANIM", "anim/yotb_spotlight.zip"),
}

local assets_rug =
{
    Asset("ANIM", "anim/yotb_beefalo_rug.zip"),
}

local assets_ribbon =
{
    Asset("ANIM", "anim/yotb_post_ribbons.zip"),
}

local PLACERRING_DATA =
{
    bank =  "firefighter_placement",
    build = "firefighter_placement",
    anim =  "idle",
    scale = 2,
}


local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("yotb_2021/common/hitching_post/place")
    inst.AnimState:PushAnimation("idle", true)
end

local function onburnt(inst)
    inst.AnimState:PlayAnimation("burnt", true)
end

local function onhitch(inst,target)

end

local function onunhitch(inst,oldtarget)
    oldtarget:PushEvent("unhitch")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function mark(inst,doer, id)

    if inst.stage and inst.stage.components.yotb_stager then
        local oldmark = inst.stage.components.yotb_stager:CheckForMarks(inst,doer)
        if oldmark then
            oldmark.components.markable:Mark(doer)
        end
    end

    if not inst.ribbons then
        inst.ribbons = {}
    end
    local ribbon = SpawnPrefab("yotb_post_ribbon")

    ribbon.entity:SetParent(inst.entity)
    ribbon.entity:AddFollower()
    ribbon.Follower:FollowSymbol(inst.GUID, "ribbon"..id,  0, 0, 0)


    ribbon.Transform:SetPosition(inst.Transform:GetWorldPosition())
    ribbon.AnimState:PlayAnimation("ribbon"..id.."_appear")
    ribbon.AnimState:PushAnimation("ribbon"..id.."_idle",true)

    local color = {math.random(),math.random(),math.random(),1}

    if doer.userid then
        local clients = TheNet:GetClientTable()

        for i,client in ipairs(clients)do
            if client.userid == doer.userid then
                color = client.colour
                break
            end
        end
    else
        -- NPC
    end

    ribbon.AnimState:SetMultColour(color[1],color[2],color[3],color[4])

    inst.ribbons[id] = ribbon
end

local function unmark(inst,doer, id)
    if inst.ribbons and inst.ribbons then
        inst.ribbons[id]:Remove()
        inst.ribbons[id] = nil

        if #inst.ribbons == 0 then
            inst.ribbons = nil
        end
    end
end

local function unmarkall(inst)
    if inst.ribbons then
        for i, ribbon in pairs(inst.ribbons) do
            ribbon:Remove()
            ribbon = nil
        end
        inst.ribbons = nil
    end
end

local function onremove(inst)
    if inst.components.hitcher and inst.components.hitcher:GetHitched() then
        inst.components.hitcher:Unhitch()
    end
    if inst.rug then
        inst.rug:Remove()
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("yotb_2021/common/hitching_post/place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle",true)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.4)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("yotb_post.png")

    inst:AddTag("structure")
    inst:AddTag("yotb_post")

    inst.AnimState:SetBank("yotb_post")
    inst.AnimState:SetBuild("yotb_post")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hitcher")
    inst.components.hitcher.hitchedfn = onhitch
    inst.components.hitcher.unhitchfn = onunhitch

    -- TEMP TEMP TEMP -- TO FILL IN FOR THE ARTWORK ON MARKING
    inst:AddComponent("talker")

    inst:AddComponent("markable")
    inst.components.markable:SetMarkable(false)
    inst.components.markable.unmarkfn = unmark
    inst.components.markable.markfn = mark
    inst.components.markable.unmarkallfn = unmarkall
    inst.components.markable.canmarkfn = function(inst,doer)
        local pass = false
        local bell = doer.components.inventory:FindItem(function(item) return item.prefab == "beef_bell" and item:_HasBeefalo() end)

        if bell then
            local beef = bell:GetBeefalo()
            if inst.stage then
                for i,post in pairs(inst.stage.components.yotb_stager.posts) do
                    local postbeef = post.components.hitcher:GetHitched()
                    if postbeef == beef then
                        pass = true
                        break
                    end
                end
            end
        end

        if doer:HasTag("NPC_contestant") then
            pass = true
        end

        if not pass then
            return false, "not_participant"
        else
            return true
        end
    end

    MakeHauntableWork(inst)

    inst:ListenForEvent("onburnt", onburnt)
    inst:ListenForEvent("onremove", onremove)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:DoTaskInTime(0,function()
        inst.rug = SpawnPrefab("yotb_post_rug")
        inst.rug.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst.rug.AnimState:PlayAnimation("place")
        inst.rug.AnimState:PushAnimation("idle",true)
    end)


    return inst
end

local function invalid_placement_fn(player, placer)
    if placer and placer.mouse_blocked then
        return
    end

    if player and player.components.talker then
        player.components.talker:Say(GetString(player, "ANNOUNCE_CANTBUILDHERE_YOTB_POST"))
    end
end


local function rugfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("post_rug")
    inst.AnimState:SetBuild("yotb_post_rug")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end



-- SPOTLIGHT CODE
local INTENSITY = 0.8

local function randomizefadein()
    return math.random(1, 31)
end

local function randomizefadeout()
    return math.random(32, 63)
end

local function immediatefadeout()
    return 0
end

local function resolvefaderate(x)
    --immediate fadeout -> 0
    --randomize fadein -> INTENSITY * FRAMES / (3 + math.random() * 2)
    --randomize fadeout -> -INTENSITY * FRAMES / (.75 + math.random())
    return (x == 0 and 0)
        or (x < 32 and INTENSITY * FRAMES / (3 + (x - 1) / 15))
        or INTENSITY * FRAMES / ((32 - x) / 31 - .75)
end

local function updatefade(inst, rate)
    inst._fadeval:set_local(math.clamp(inst._fadeval:value() + rate, 0, INTENSITY))

    --Client light modulation is enabled:
    inst.Light:SetIntensity(inst._fadeval:value())

    if rate == 0 or
        (rate < 0 and inst._fadeval:value() <= 0) or
        (rate > 0 and inst._fadeval:value() >= INTENSITY) then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        if inst._fadeval:value() <= 0 and TheWorld.ismastersim then
            inst.Light:Enable(false)
        end
    end
end

local function fadein(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) <= 0 then
        if ismastersim then
            inst.Light:Enable(true)
            inst.AnimState:PlayAnimation("on")
            inst.AnimState:PushAnimation("idle_loop", true)
            inst._faderate:set(randomizefadein())
        end
        if inst._fadetask ~= nil then
            inst._fadetask:Cancel()
        end
        local rate = resolvefaderate(inst._faderate:value()) * math.clamp(1 - inst._fadeval:value() / INTENSITY, 0, 1)
        inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
        if not ismastersim then
            updatefade(inst, rate)
        end
    end
end

local function fadeout(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) > 0 then
        if ismastersim then
            inst.AnimState:PlayAnimation("off")
            inst._faderate:set(randomizefadeout())
        end
        if inst._fadetask ~= nil then
            inst._fadetask:Cancel()
        end
        local rate = resolvefaderate(inst._faderate:value()) * math.clamp(inst._fadeval:value() / INTENSITY, 0, 1)
        inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
        if not ismastersim then
            updatefade(inst, rate)
        end
    end
end

local function OnFadeRateDirty(inst)
    local rate = resolvefaderate(inst._faderate:value())
    if rate > 0 then
        fadein(inst)
    elseif rate < 0 then
        fadeout(inst)
    elseif inst._fadetask ~= nil then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        inst._fadeval:set_local(0)

        --Client light modulation is enabled:
        inst.Light:SetIntensity(0)
    end
end

local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("yotb_spotlight")
    inst.AnimState:SetBuild("yotb_spotlight")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst._fadeval = net_float(inst.GUID, "yotb_spotlight._fadeval")
    inst._faderate = net_smallbyte(inst.GUID, "yotb_spotlight._faderate", "onfaderatedirty")
    inst._fadetask = nil

    fadein(inst)
    inst.fadeout = fadeout

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("onfaderatedirty", OnFadeRateDirty)

        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", function() if inst.AnimState:IsCurrentAnimation("off") then inst:Remove() end end)

    return inst
end

-- RIBBON

local function ribbonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("yotb_post_ribbons")
    inst.AnimState:SetBuild("yotb_post_ribbons")
    inst.AnimState:PlayAnimation("ribbon1_idle", true)
    --inst.AnimState:SetFinalOffset( 2 )

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

-- placer
local function placer_postinit_fn(inst)
    return yotb_common.AddPlacerRing(inst, PLACERRING_DATA, "yotb_post")
end

local function can_deploy(inst, pt, mouseover, deployer)
    local stage_tags = { "yotb_stage" }
    local post_tags = { "yotb_post" }

    local stage_ents =  TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.YOTB_STAGERANGE, stage_tags)
    local post_ents =  TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.YOTB_POSTDISTANCE, post_tags)

    return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and #stage_ents > 0 and #post_ents == 0
end

local deployable_data =
{
    deploymode = DEPLOYMODE.CUSTOM,
    custom_candeploy_fn = can_deploy
}

return Prefab("yotb_post", fn, assets, prefabs),
       Prefab("yotb_post_rug", rugfn, assets_rug, prefabs),
       MakeDeployableKitItem("yotb_post_item", "yotb_post", "yotb_post_item", "yotb_post_item", "idle", {Asset("ANIM", "anim/yotb_post_item.zip")}, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.MED_LARGE_FUEL}, deployable_data),
       Prefab("yotb_post_ribbon", ribbonfn, assets_ribbon, prefabs),
       Prefab("yotb_post_spotlight", lightfn, assets_light, prefabs),
       MakePlacer("yotb_post_item_placer", "post_rug", "yotb_post_rug", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn, nil, invalid_placement_fn)