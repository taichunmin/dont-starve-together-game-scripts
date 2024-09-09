local assets =
{
    Asset("ANIM", "anim/wagstaff_setpieces.zip"),
}

local prefabs =
{
    "cutstone",
    "wagpunk_bits",
    "collapse_small",
    "wagstaff_mutations_note",
    "wagstaff_machinery_marker",
    "wagpunkhat_blueprint",
    "armorwagpunk_blueprint",
    "chestupgrade_stacksize_blueprint",
    "wagpunkbits_kit_blueprint",
}

------------------------------------------------------------------------------------------------

SetSharedLootTable("wagstaff_machinery",
{
    {'cutstone',          0.75},
    {'wagpunk_bits',      1.00},
    {'wagpunk_bits',      0.75},
    {'transistor',        0.10},
    {'trinket_6',         0.15},
    {'trinket_10',        0.01},
})

------------------------------------------------------------------------------------------------

local MAX_NUMBER = 3 --5

------------------------------------------------------------------------------------------------

local function OnHammered(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function OnHit(inst, worker)
    inst.AnimState:PlayAnimation("hit"  .. inst.debris_id)
    inst.AnimState:PushAnimation("idle" .. inst.debris_id)
end

------------------------------------------------------------------------------------------------

local function SetDebrisType(inst, index)
    if inst.debris_id == nil or (index ~= nil and inst.debris_id ~= index) then
        inst.debris_id = index or tostring(math.random(MAX_NUMBER))
        inst.AnimState:PlayAnimation("idle"..inst.debris_id, true)
    end
end

------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    data.debris_id = inst.debris_id
end

local function OnLoad(inst, data)
    inst:SetDebrisType(data ~= nil and data.debris_id or nil)
end

------------------------------------------------------------------------------------------------

local function OnSpawned(inst)
    TheWorld:PushEvent("wagstaff_machine_added", inst.GUID)
end

local function OnRemoved(inst)
    TheWorld:PushEvent("wagstaff_machine_destroyed", inst.GUID)
end

-- NOTES(JBK): Keep these up to sync with daywalker2 drops. [WPDROPS]
local WAGPUNK_ITEMS = { -- These are prefab names not their blueprints.
    "wagpunkhat",
    "armorwagpunk",
    "chestupgrade_stacksize",
    "wagpunkbits_kit",
}
local function lootsetfn(lootdropper)
    lootdropper:ClearRandomLoot()
    local needstoknow = nil
    local inst = lootdropper.inst
    for _, player in ipairs(AllPlayers) do
        if player:GetDistanceSqToInst(inst) <= 16 then -- 4 * 4 = 16 = 1 tiles
            local builder = player.components.builder
            for _, recipename in ipairs(WAGPUNK_ITEMS) do
                if not builder:KnowsRecipe(recipename) then
                    if needstoknow == nil then
                        needstoknow = {}
                    end
                    needstoknow[recipename] = (needstoknow[recipename] or 0) + 1
                end
            end
        end
    end
    if needstoknow then
        -- Some one needs something make it only potentially drop these.
        for recipename, _ in pairs(needstoknow) do
            lootdropper:AddRandomLoot(recipename .. "_blueprint", 1)
        end
    else
        -- No one needs anything make it random.
        for _, recipename in ipairs(WAGPUNK_ITEMS) do
            lootdropper:AddRandomLoot(recipename .. "_blueprint", 1)
        end
    end
    lootdropper.numrandomloot = TUNING.WAGSTAFF_MACHINERY_NUM_BLUEPRINTS
    lootdropper.chancerandomloot = TUNING.WAGSTAFF_MACHINERY_BLUEPRINT_CHANCE
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("wagstaff_machinery.png")
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetBank("wagstaff_setpieces")
    inst.AnimState:SetBuild("wagstaff_setpieces")

    inst:AddTag("structure")
    inst:AddTag("wagstaff_machine")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle3"

    inst.SetDebrisType = SetDebrisType
    inst.OnSpawned = OnSpawned

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("wagstaff_machinery")

    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnRemoveEntity = OnRemoved

    if not POPULATING then
        inst:SetDebrisType()
    end

    inst:DoTaskInTime(0, inst.OnSpawned)

    MakeSnowCovered(inst)

    return inst
end

local function markerfn()
    local inst = CreateEntity()
    inst.entity:AddNetwork()    

    inst.entity:AddTransform()
    
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    TheWorld:PushEvent("ms_register_wagstaff_machinery", inst)

    return inst    
end

------------------------------------------------------------------------------------------------

return Prefab("wagstaff_machinery", fn, assets, prefabs),
       Prefab("wagstaff_machinery_marker", markerfn, assets, prefabs)