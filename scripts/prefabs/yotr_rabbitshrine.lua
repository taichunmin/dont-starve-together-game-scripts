require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/yotr_rabbitshrine.zip"),
    Asset("SCRIPT", "scripts/prefabs/pillow_defs.lua"),
    Asset("ANIM", "anim/firefighter_placement.zip"),
    Asset("MINIMAP_IMAGE", "yotr_rabbitshrine"),
}

local prefabs =
{
    "collapse_small",
    "ash",
    "carrot",
    "spoiled_food",
    "charcoal",
    "cozy_bunnyman",
    "yotr_token",
    "nightcaphat",

    "redpouch_yotr",
    "yotb_post_spotlight",

    "yotr_decor_1",
    "yotr_decor_2",
    "yotr_decor_1_item",
    "yotr_decor_2_item",
}

local NUMOFBUNNIES = TUNING.SLEEPOVER_BUNNY_COUNT
local PLACER_RADIUS = 10

for material in pairs(require("prefabs/pillow_defs")) do
    table.insert(prefabs, "handpillow_"..material)
    table.insert(prefabs, "bodypillow_"..material)
end


local function randomizepillowslot(set)
    if math.random() < 0.5 then
        return {"bodypillow_"..set[1],"handpillow_"..set[2]}
    else
        return {"bodypillow_"..set[2],"handpillow_"..set[1]}
    end
end

local function getlockedpillow(set)
    local choice = math.random()
    if choice < 0.4 then
        table.insert(set,"petals")
    elseif choice < 0.70 then
        table.insert(set,"kelp")
    elseif choice < 0.90 then
        table.insert(set,"beefalowool")
    else
        table.insert(set,"steelwool") 
    end
    return randomizepillowslot(set)
end

local function gettotallyrandomset()
    local set = {}
    for i=1,2 do
        local choice = math.random()
        if choice < 0.4 then
            table.insert(set,"petals")
        elseif choice < 0.70 then
            table.insert(set,"kelp")
        elseif choice < 0.90 then
            table.insert(set,"beefalowool")
        else
            table.insert(set,"steelwool") 
        end
    end
    return randomizepillowslot(set)
end

local set_pillows = {
    {"bodypillow_petals", "handpillow_petals"},

    getlockedpillow({"petals"}),

    getlockedpillow({"kelp"}),
    getlockedpillow({"kelp"}),

    getlockedpillow({"beefalowool"}),
    getlockedpillow({"beefalowool"}),
    getlockedpillow({"beefalowool"}),

    getlockedpillow({"steelwool"}),

    {"bodypillow_steelwool", "handpillow_steelwool"},
}

function do_bunnyman_spawn(inst, index)
    local bunspawn = inst.bunnylocations[index]
    if bunspawn == nil then
        return
    end

    local bunbun = SpawnPrefab("cozy_bunnyman")
    bunbun.sg:GoToState("spawn_pre")

    inst.components.entitytracker:TrackEntity("bunny"..index, bunbun)

    bunbun.components.entitytracker:TrackEntity("shrine", inst)

    local pos = inst:GetPosition()
    bunbun.Transform:SetPosition((pos + bunspawn):Get())
    bunbun.components.knownlocations:RememberLocation("pillowSpot", pos + inst.bunnyhomelocations[index])

    local pillows =  {"bodypillow_petals", "handpillow_petals"}
    if #set_pillows >0 then
        local choice = math.random(1,#set_pillows)
        pillows = set_pillows[choice]
        table.remove(set_pillows,choice)
    else
        pillows = gettotallyrandomset()
    end

    local pillow1 = SpawnPrefab(pillows[1])
    bunbun.components.inventory:GiveItem(pillow1)

    local pillow2 = SpawnPrefab(pillows[2])
    bunbun.components.inventory:GiveItem(pillow2)
    bunbun.components.inventory:Equip(pillow2)

    local hat = SpawnPrefab("nightcaphat")
    bunbun.components.inventory:GiveItem(hat)
    bunbun.components.inventory:Equip(hat)
end

local function getrabbits(inst, fn)
    local bunnies = {}
    for i=1,NUMOFBUNNIES do
        local check = true
        if fn and not fn(inst,inst.components.entitytracker:GetEntity("bunny"..i)) then
            check = false
        end
        if check then table.insert(bunnies,inst.components.entitytracker:GetEntity("bunny"..i)) end
    end
    return bunnies
end

local function CheckForSpawn(inst)
    if not IsSpecialEventActive(SPECIAL_EVENTS.YOTR) then
        return
    end

    local radiushome = PLACER_RADIUS - 3 -- Use a radius a bit inside of the full radius.
    local tweakradius = 4
    local pos = inst:GetPosition()

    inst.bunnylocations = {}
    inst.bunnyhomelocations = {}
    for i=1,NUMOFBUNNIES do
        local theta = i * (PI2/NUMOFBUNNIES)
        inst.bunnyhomelocations[i] = Vector3(radiushome * math.cos( theta ), 0, -radiushome * math.sin( theta ))
        local tweak = FindWalkableOffset(pos + inst.bunnyhomelocations[i], theta, tweakradius, 12, true, true)
        if tweak then
            inst.bunnylocations[i] = inst.bunnyhomelocations[i]+tweak
        end
    end

    for i=1,NUMOFBUNNIES do
        if not inst.components.entitytracker:GetEntity("bunny"..i) then
            inst:DoTaskInTime(math.random()*5, do_bunnyman_spawn, i)
        end
    end
end

--

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.offering then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst.offering:Remove()
        inst.offering = nil
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    inst.AnimState:Hide("offering")
    if inst.components.trader then
        inst:RemoveComponent("trader")
    end
end

local function MakePrototyper(inst)
    if inst.components.trader then
        inst:RemoveComponent("trader")
    end

    if not inst.components.prototyper then
        inst:AddComponent("prototyper")
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.RABBITSHRINE
    end
end

local function DropOffering(inst, worker)
    if inst.offering then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst:RemoveChild(inst.offering)
        inst.offering:ReturnToScene()
        if worker then
            LaunchAt(inst.offering, inst, worker, 1, 0.6, .6)
        else
            inst.components.lootdropper:FlingItem(inst.offering, inst:GetPosition())
        end
        inst.offering = nil
    end
end

local function SetOffering(inst, offering, loading)
    if offering == inst.offering then
        return
    end

    DropOffering(inst) --Shouldn't happen, but w/e (just in case!?)

    inst.offering = offering
    inst:ListenForEvent("onremove", inst._onofferingremoved, offering)
    inst:ListenForEvent("perished", inst._onofferingperished, offering)
    inst:AddChild(offering)
    offering:RemoveFromScene()
    offering.Transform:SetPosition(0, 0, 0)

    inst.AnimState:Show("offering")

    if not loading then
        inst.SoundEmitter:PlaySound("dontstarve/common/plant")
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("idle", false)
    end

    inst:DoTaskInTime(3, CheckForSpawn)

    MakePrototyper(inst)
end

local function ongivenitem(inst, giver, item)
    SetOffering(inst, item, false)
end

local function abletoaccepttest(inst, item)
    return item.prefab == "carrot"
end

local function MakeEmpty(inst)
    if inst.offering then
        inst:RemoveEventCallback("onremove", inst._onofferingremoved, inst.offering)
        inst:RemoveEventCallback("perished", inst._onofferingperished, inst.offering)
        inst.offering:Remove()
        inst.offering = nil
    end

    inst.AnimState:Hide("offering")

    if inst.components.prototyper then
        inst:RemoveComponent("prototyper")
    end

    if not inst.components.trader then
        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(abletoaccepttest)
        inst.components.trader.acceptnontradable = true
        inst.components.trader.deleteitemonaccept = false
        inst.components.trader.onaccept = ongivenitem
    end
end

local function OnIgnite(inst)
    if inst.offering ~= nil then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    MakeEmpty(inst)
    inst.components.trader:Disable()
    DefaultBurnFn(inst)
end

local function OnExtinguish(inst)
    if inst.components.trader then
        inst.components.trader:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function onbuilt(inst)
    --Make empty when first built.
    --Pristine state is not empty.
    MakeEmpty(inst)

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("yotr_2023/common/shrine_place")
end

local function onhammered(inst, worker)
    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    DropOffering(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")

    inst:Remove()
end

local function onhit(inst, worker, workleft)
    DropOffering(inst, worker)
    MakeEmpty(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function OnOfferingPerished(inst)
    if inst.offering ~= nil then
        MakeEmpty(inst)
        local rot = SpawnPrefab("spoiled_food")
        rot.Transform:SetPosition(inst.Transform:GetWorldPosition())
        LaunchAt(rot, inst, nil, .5, 0.6, .6)
    end
end

local function onsave(inst, data)
    if (inst.components.burnable and inst.components.burnable:IsBurning()) or inst:HasTag("burnt") then
        data.burnt = true
    elseif inst.offering then
        data.offering = inst.offering:GetSaveRecord()
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    elseif data and data.offering then
        SetOffering(inst, SpawnSaveRecord(data.offering), true)
    else
        MakeEmpty(inst)
    end
end

local function GetStatus(inst)
    --return BURNT here otherwise EMPTY will always have priority over BURNT
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.trader ~= nil and "EMPTY")
        or nil
end

local function SetShrineWinner(shrine, winner)
    local oldwinner = shrine.gamewinner
    if oldwinner == winner then
        return -- Nothing to do.
    end

    shrine.gamewinner = winner

    if shrine.gamewinner_onremove ~= nil then
        shrine:RemoveEventCallback("onremove", shrine.gamewinner_onremove, oldwinner)
        shrine.gamewinner_onremove = nil
    end

    if winner ~= nil then
        shrine.gamewinner_onremove = function() shrine:SetShrineWinner(nil) end
        shrine:ListenForEvent("onremove", shrine.gamewinner_onremove, winner)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .6)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("yotr_rabbitshrine.png")

    inst.AnimState:SetBank("rabbitshrine")
    inst.AnimState:SetBuild("yotr_rabbitshrine")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("pigshrine")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        if not TheWorld.ismastersim then
            return inst
        end
    end

    inst.SetShrineWinner = SetShrineWinner

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    MakePrototyper(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst.offering = nil

    inst:AddComponent("entitytracker")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

    inst._onofferingremoved = function() MakeEmpty(inst) end
    inst._onofferingperished = function() OnOfferingPerished(inst) end

    inst:AddComponent("timer")

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.getrabbits = getrabbits

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("ondeconstructstructure", DropOffering)

    return inst
end

local ANGLE_PER_PLACER_TEST = PI2 / NUMOFBUNNIES
local function placer_override_testfn(inst)
    local can_build, mouse_blocked = true, false

    local x, y, z = inst.Transform:GetWorldPosition()
    local ipos = inst:GetPosition()
    if not TheWorld.Map:IsDeployPointClear2(ipos, inst, 0.7) then
        can_build = false
    end

    if can_build then
        for i = 1, NUMOFBUNNIES do
            local angle = i * ANGLE_PER_PLACER_TEST
            if not TheWorld.Map:IsAboveGroundAtPoint(x + PLACER_RADIUS*math.sin(angle), 0, z + PLACER_RADIUS*math.cos(angle)) then
                can_build = false
                break
            end
        end
    end

    return can_build, mouse_blocked
end

local function placer_postinit_fn(inst)
    inst.AnimState:Hide("offering")

    inst.components.placer.override_testfn = placer_override_testfn

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1.3
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("firefighter_placement")
    placer2.AnimState:SetBuild("firefighter_placement")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    placer2.AnimState:SetLayer(LAYER_BACKGROUND)
    placer2.AnimState:SetSortOrder(3)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("yotr_rabbitshrine", fn, assets, prefabs),
    MakePlacer("yotr_rabbitshrine_placer",         "rabbitshrine",  "yotr_rabbitshrine", "idle",        nil, nil, nil, nil, nil, nil, placer_postinit_fn)
