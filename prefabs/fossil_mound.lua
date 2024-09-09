local assets =
{
    Asset("ANIM", "anim/fossil_stalker.zip"),
}

local prefabs =
{
    "fossil_piece",
    "collapse_small",
    "stalker",
    "stalker_forest",
    "stalker_atrium",
}

local NUM_FORMS = 3
local MAX_MOUND_SIZE = 8
local MOUND_WRONG_START_SIZE = 5
local ATRIUM_RANGE = 8.5

local function ActiveStargate(gate)
    return gate:IsWaitingForStalker()
end

local STARGET_TAGS = { "stargate" }
local STALKER_TAGS = { "stalker" }
local SHADOWHEART_TAGS = {"shadowheart"}
local function ItemTradeTest(inst, item, giver)
    if item == nil or item.prefab ~= "shadowheart" or
        giver == nil or giver.components.areaaware == nil then
        return false
    elseif inst.form ~= 1 then
        return false, "WRONGSHADOWFORM"
    elseif not TheWorld.state.isnight then
        return false, "CANTSHADOWREVIVE"
    elseif giver.components.areaaware:CurrentlyInTag("Atrium")
        and (   FindEntity(inst, ATRIUM_RANGE, ActiveStargate, STARGET_TAGS) == nil or
                GetClosestInstWithTag(STALKER_TAGS, inst, 40) ~= nil   ) then
        return false, "CANTSHADOWREVIVE"
    end

    return true
end

local function OnAccept(inst, giver, item)
    if item.prefab == "shadowheart" then
        local stalker
        if not TheWorld:HasTag("cave") then
            stalker = SpawnPrefab("stalker_forest")
        elseif not giver.components.areaaware:CurrentlyInTag("Atrium") then
            stalker = SpawnPrefab("stalker")
        else
            local stargate = FindEntity(inst, ATRIUM_RANGE, ActiveStargate, STARGET_TAGS)
            if stargate ~= nil then
                stalker = SpawnPrefab("stalker_atrium")
                -- override the spawn point so stalker stays around the gate
                stalker.components.entitytracker:TrackEntity("stargate", stargate)
                stargate:TrackStalker(stalker)
            else
                --should not be possible
                stalker = SpawnPrefab("stalker")
            end
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        local rot = inst.Transform:GetRotation()
        inst:Remove()

        stalker.Transform:SetPosition(x, y, z)
        stalker.Transform:SetRotation(rot)
        stalker.sg:GoToState("resurrect")

        giver.components.sanity:DoDelta(TUNING.REVIVE_SHADOW_SANITY_PENALTY)
    end
end

local function CountAllEntities(inst, range, tags)
    -- NOTES(JBK): Workaround for FindEntity's visibility check and not wanting to edit a core util function.
    -- Players may have this item in their inventory.
    -- We only care about the count.
    -- If this function is moved to a core util make it much more generic than this.
    local x, y, z = inst.Transform:GetWorldPosition()
    return TheSim:CountEntities(x, y, z, range, tags)
end

local function UpdateFossileMound(inst, size, checkforwrong)
    if size < MOUND_WRONG_START_SIZE then
        --reset case, not really used tho
        inst.form = 1
    elseif checkforwrong and inst.moundsize < MOUND_WRONG_START_SIZE then
        -- NOTES(JBK): If the mound is in the atrium, the key is in the gate, and there is a shadow heart nearby make the odds 100%.
        -- The first check is wrapped in ActiveStargate because this can only happen in the Atrium with the key in it.
        if FindEntity(inst, ATRIUM_RANGE, ActiveStargate, STARGET_TAGS) ~= nil and CountAllEntities(inst, ATRIUM_RANGE, SHADOWHEART_TAGS) > 0 then
            inst.form = 1
        else
            -- 3/5 = 60% chance of form 1 (correct form)
            -- [-1, 0, 1, 2, 3] random()
            -- [ 1, 1, 1, 2, 3] max()
            inst.form = math.max(1, math.random(-1, NUM_FORMS))
        end
    end

    inst.moundsize = size
    inst.components.workable:SetWorkLeft(size)
    inst.AnimState:PlayAnimation(tostring(inst.form).."_"..tostring(inst.moundsize))

    if size >= MAX_MOUND_SIZE then
        inst.components.trader:Enable()
    else
        inst.components.trader:Disable()
    end
end

local function lootsetfn(lootdropper)
    local loot = {}
    for i = 1, lootdropper.inst.moundsize do
        table.insert(loot, "fossil_piece")
    end
    lootdropper:SetLoot(loot)
end

local function onworked(inst)
    local pos = inst:GetPosition()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(pos:Get())
    fx:SetMaterial("rock")

    inst.components.lootdropper:DropLoot(pos)
    inst:Remove()
end

local function onrepaired(inst)
    UpdateFossileMound(inst, inst.moundsize + 1, true)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
end

local function getstatus(inst)
    return inst.moundsize >= MAX_MOUND_SIZE
        and (inst.form > 1 and "FUNNY" or "COMPLETE")
        or nil
end

local function onsave(inst, data)
    data.moundsize = inst.moundsize > 1 and inst.moundsize or nil
    data.form = inst.form > 1 and inst.form or nil
end

local function onload(inst, data)
    if data ~= nil then
        --backward compatibility for data.wrong
        inst.form = math.clamp(data.form or (data.wrong and 2 or 1), 1, NUM_FORMS)
        UpdateFossileMound(inst, math.clamp(data.moundsize or 1, 1, MAX_MOUND_SIZE), false)
    end
end

local function makemound(name)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

		inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2) --fossil_piece deployspacing/2
		inst:SetPhysicsRadiusOverride(0.45)
		MakeObstaclePhysics(inst, inst.physicsradiusoverride)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("1_1")
        inst.scrapbook_anim ="1_8"

        inst:AddTag("structure")

        --trader (from trader component) added to pristine state for optimization
        --inst:AddTag("trader")
        --Trader will be disabled by default constructor

        inst.scrapbook_specialinfo = "FOSSILSTALKER"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLootSetupFn(lootsetfn)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetMaxWork(MAX_MOUND_SIZE)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(onworked)
        inst.components.workable.savestate = true

        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.FOSSIL
        inst.components.repairable.onrepaired = onrepaired
        inst.components.repairable.noannounce = true

        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
        inst.components.trader.onaccept = OnAccept

        MakeHauntableWork(inst)

        inst.form = 1
        UpdateFossileMound(inst, 1)

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return makemound("fossil_stalker")
