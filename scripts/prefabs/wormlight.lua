local assets =
{
    Asset("ANIM", "anim/worm_light.zip"),
}

local lesserassets =
{
    Asset("ANIM", "anim/worm_light_lesser.zip"),
}

local prefabs =
{
    "wormlight_light",
}

local lesserprefabs =
{
    "wormlight_light_lesser",
}

-----------------------------------------------------------------------

--multiplies TUNING.WORMLIGHT_DURATION = seg_time * 8
local DURATION_MULT = 1
local LESSER_DURATION_MULT = .25
local GREATER_DURATION_MULT = 4

-----------------------------------------------------------------------

local function create_light(eater, lightprefab)
    if eater.wormlight ~= nil then
        if eater.wormlight.prefab == lightprefab then
            eater.wormlight.components.spell.lifetime = 0
            eater.wormlight.components.spell:ResumeSpell()
            return
        else
            eater.wormlight.components.spell:OnFinish()
        end
    end

    local light = SpawnPrefab(lightprefab)
    light.components.spell:SetTarget(eater)
    if light:IsValid() then
        if light.components.spell.target == nil then
            light:Remove()
        else
            light.components.spell:StartSpell()
        end
    end
end

local function item_oneaten(inst, eater)
    create_light(eater, "wormlight_light")
end

local function lesseritem_oneaten(inst, eater)
    create_light(eater, "wormlight_light_lesser")
end

local function item_commonfn(bank, build, masterfn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    MakeInventoryPhysics(inst)

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(true)

    inst:AddTag("lightbattery")
    inst:AddTag("vasedecoration")
    inst:AddTag("light")

    MakeInventoryFloatable(inst, "small", 0.1, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")
    inst:AddComponent("vasedecoration")
    inst:AddComponent("edible")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = FUELTYPE.WORMLIGHT

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    if masterfn ~= nil then
        masterfn(inst)
    end

    return inst
end

local function itemfn()
    return item_commonfn(
        "worm_light",
        "worm_light",
        function(inst)
            inst.components.edible.foodtype = FOODTYPE.VEGGIE
            inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL + TUNING.HEALING_SMALL
            inst.components.edible.hungervalue = TUNING.CALORIES_MED
            inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
            inst.components.edible:SetOnEatenFn(item_oneaten)

            inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL * 1.33
        end
    )
end

local function lesseritemfn()
    return item_commonfn(
        "worm_light_lesser",
        "worm_light_lesser",
        function(inst)
        inst.components.edible.foodtype = FOODTYPE.VEGGIE
        inst.components.edible.healthvalue = TUNING.HEALING_SMALL
        inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
        inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
        inst.components.edible:SetOnEatenFn(lesseritem_oneaten)

        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        end
    )
end

-----------------------------------------------------------------------

local lightprefabs =
{
    "wormlight_light_fx",
}

local lesserlightprefabs =
{
    "wormlight_light_fx_lesser",
}

local greaterlightprefabs =
{
    "wormlight_light_fx_greater",
}

local function light_resume(inst, time)
    inst.fx:setprogress(1 - time / inst.components.spell.duration)
end

local function light_start(inst)
    inst.fx:setprogress(0)
end

local function pushbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
    else
        target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function popbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PopBloom(inst)
    else
        target.AnimState:ClearBloomEffectHandle()
    end
end


local function OnOwnerChange(inst)
    local newowners = {}
    local owner = inst._target
    local isrider = false
    while true do
        newowners[owner] = true

        local rider = owner.components.rideable and owner.components.rideable:GetRider()
        local invowner = owner.components.inventoryitem and owner.components.inventoryitem.owner

        if inst._owners[owner] then
            inst._owners[owner] = nil
        else
            if owner.components.rideable then
                inst:ListenForEvent("riderchanged", inst._onownerchange, owner)
            end
            if not rider and owner.components.inventoryitem then
                inst:ListenForEvent("onputininventory", inst._onownerchange, owner)
                inst:ListenForEvent("ondropped", inst._onownerchange, owner)
            end
        end

        local nextowner = rider or invowner
        if not nextowner then break end
        isrider = rider ~= nil
        owner = nextowner
    end

    inst.fx.entity:SetParent(owner.entity)

    if inst._popbloom ~= nil and inst._popbloom ~= owner then
        popbloom(inst, inst._popbloom)
        if isrider then
            pushbloom(inst, owner)
            inst._popbloom = owner
        else
            inst._popbloom = nil
        end
    end

    for k, v in pairs(inst._owners) do
        if k:IsValid() then
            if k.components.inventoryitem then
                inst:RemoveEventCallback("onputininventory", inst._onownerchange, k)
                inst:RemoveEventCallback("ondropped", inst._onownerchange, k)
            end
            if k.components.rideable then
                inst:RemoveEventCallback("riderchanged", inst._onownerchange, k)
            end
        end
    end

    inst._owners = newowners
end

local function light_ontarget(inst, target)
    if target == nil or target:HasTag("playerghost") or target:HasTag("overcharge") then
        inst:Remove()
        return
    end

    local function forceremove()
        inst.components.spell:OnFinish()
    end

    inst._target = target
    target.wormlight = inst
    --FollowSymbol position still works on blank symbol, just
    --won't be visible, but we are an invisible proxy anyway.
    inst.Follower:FollowSymbol(target.GUID, "", 0, 0, 0)
    inst:ListenForEvent("onremove", forceremove, target)
    inst:ListenForEvent("death", function() inst.fx:setdead() end, target)

    if target:HasTag("player") then
        inst:ListenForEvent("ms_becameghost", forceremove, target)
        if target:HasTag("electricdamageimmune") then
            inst:ListenForEvent("ms_overcharge", forceremove, target)
        end
        inst.persists = false
    else
        inst.persists = not target:HasTag("critter")
    end

    pushbloom(inst, target)
    OnOwnerChange(inst)
end

local function light_onfinish(inst)
    local target = inst.components.spell.target
    if target ~= nil then
        target.wormlight = nil

        popbloom(inst, target)

        if target.components.rideable ~= nil then
            local rider = target.components.rideable:GetRider()
            if rider ~= nil then
                popbloom(inst, rider)
            end
        end
    end
end

local function light_onremove(inst)
    inst.fx:Remove()
end

local function light_commonfn(duration, fxprefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst:Hide()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]

    inst:AddComponent("spell")
    inst.components.spell.spellname = "wormlight"
    inst.components.spell.duration = duration
    inst.components.spell.ontargetfn = light_ontarget
    inst.components.spell.onstartfn = light_start
    inst.components.spell.onfinishfn = light_onfinish
    inst.components.spell.resumefn = light_resume
    inst.components.spell.removeonfinish = true

    inst.persists = false --until we get a target
    inst.fx = SpawnPrefab(fxprefab)
    inst.OnRemoveEntity = light_onremove

    inst._owners = {}
    inst._onownerchange = function() OnOwnerChange(inst) end

    return inst
end

local function lightfn()
    return light_commonfn(TUNING.WORMLIGHT_DURATION * DURATION_MULT, "wormlight_light_fx")
end

local function lesserlightfn()
    return light_commonfn(TUNING.WORMLIGHT_DURATION * LESSER_DURATION_MULT, "wormlight_light_fx_lesser")
end

local function greaterlightfn()
    return light_commonfn(TUNING.WORMLIGHT_DURATION * GREATER_DURATION_MULT, "wormlight_light_fx_greater")
end

-----------------------------------------------------------------------

local function OnUpdateLight(inst, dframes)
    local frame =
        inst._lightdead:value() and
        math.ceil(inst._lightframe:value() * .9 + inst._lightmaxframe * .1) or
        (inst._lightframe:value() + dframes)

    if frame >= inst._lightmaxframe then
        inst._lightframe:set_local(inst._lightmaxframe)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
        inst._lightframe:set_local(frame)
    end

    inst.Light:SetRadius(TUNING.WORMLIGHT_RADIUS * (1 - inst._lightframe:value() / inst._lightmaxframe))
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function setprogress(inst, percent)
    inst._lightframe:set(math.max(0, math.min(inst._lightmaxframe, math.floor(percent * inst._lightmaxframe + .5))))
    OnLightDirty(inst)
end

local function setdead(inst)
    inst._lightdead:set(true)
    inst._lightframe:set(inst._lightframe:value())
end

local function lightfx_commonfn(duration)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.8)
    inst.Light:SetFalloff(.5)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst._lightmaxframe = math.floor(duration / FRAMES + .5)
    inst._lightframe = net_ushortint(inst.GUID, "wormlight_light_fx._lightframe", "lightdirty")
    inst._lightframe:set(inst._lightmaxframe)
    inst._lightdead = net_bool(inst.GUID, "wormlight_light_fx._lightdead")
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.setprogress = setprogress
    inst.setdead = setdead
    inst.persists = false

    return inst
end

local function lightfxfn()
    return lightfx_commonfn(TUNING.WORMLIGHT_DURATION * DURATION_MULT)
end

local function lesserlightfxfn()
    return lightfx_commonfn(TUNING.WORMLIGHT_DURATION * LESSER_DURATION_MULT)
end

local function greaterlightfxfn()
    return lightfx_commonfn(TUNING.WORMLIGHT_DURATION * GREATER_DURATION_MULT)
end

return  Prefab("wormlight", itemfn, assets, prefabs),
        Prefab("wormlight_lesser", lesseritemfn, lesserassets, lesserprefabs),
        Prefab("wormlight_light", lightfn, nil, lightprefabs),
        Prefab("wormlight_light_lesser", lesserlightfn, nil, lesserlightprefabs),
        Prefab("wormlight_light_greater", greaterlightfn, nil, greaterlightprefabs),
        Prefab("wormlight_light_fx", lightfxfn),
        Prefab("wormlight_light_fx_lesser", lesserlightfxfn),
        Prefab("wormlight_light_fx_greater", greaterlightfxfn)
