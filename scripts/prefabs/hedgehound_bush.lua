require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/hedgehound_bush.zip"),
}

local prefabs =
{
    "petals",
}

local function OnSave(inst, data)
    data.hedgeitem = inst.hedgeitem
    data.holdasbush = inst.holdasbush
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.hedgeitem then
            inst.hedgeitem = data.hedgeitem
            inst:SetReward(inst.hedgeitem)
        end

        if data.holdasbush then
            inst.holdasbush = data.holdasbush
        end
    end
end

local function grow(inst)
    inst.AnimState:PlayAnimation("reward_pre", false)
    inst.AnimState:PushAnimation("reward_to_bush", false)
end

local SPAWNER_MUST = {"hedgespawner"}
local function SignalRespawn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 6, SPAWNER_MUST)
    for _, ent in ipairs(ents) do
        ent:PushEvent("trigger_hedge_respawn")
    end
end

local function do_bush_to_hound(inst)
    inst.SoundEmitter:PlaySound("stageplay_set/briar_wolf/spawn")
    inst.AnimState:PlayAnimation("bush_to_hound", false)

    inst.components.activatable.inactive = false

    SignalRespawn(inst)
end

local function onanimover(inst)
    if inst.AnimState:IsCurrentAnimation("reward_to_bush") then
        inst.AnimState:PlayAnimation("bush_idle", true)
        if not inst.holdasbush then
            inst:DoTaskInTime(1.5, do_bush_to_hound)
        end
    elseif inst.AnimState:IsCurrentAnimation("bush_to_hound") then
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local hedgeitem = inst.hedgeitem
        inst:Remove()

        local hound = SpawnPrefab("hedgehound")
        hound.Transform:SetPosition(ix, iy, iz)
        hound.hedgeitem = hedgeitem
        hound.sg:GoToState("hit")
    end
end

local BUSH_MUST = {"hedge_hound_bush"}
local function do_transform_and_wake(inst)
    if not inst.AnimState:IsCurrentAnimation("bush_idle") then
        return false
    end

    do_bush_to_hound(inst)

    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local bushes = TheSim:FindEntities(tx, ty, tz, 10, BUSH_MUST)
    for _, bush in ipairs(bushes) do
        if bush ~= inst then
            bush:DoTaskInTime(0.3*math.random() + 0.2, bush.OnActivate)
        end
    end

    return true
end

local function OnActivate(inst, doer)
    local did_transform = do_transform_and_wake(inst)
    if did_transform and doer ~= nil then
        local doer_has_inventory = (doer.components.inventory ~= nil)
        if doer_has_inventory then
            doer.components.inventory:GiveItem(SpawnPrefab("petals"))
        end
        if doer.components.combat ~= nil
                and not (doer_has_inventory and doer.components.inventory:EquipHasTag("bramble_resistant")) then
            doer.components.combat:GetAttacked(inst, TUNING.ROSE_DAMAGE)
            doer:PushEvent("thorns")
        end
    end
end

local function SetReward(inst, reward_prefab)
    inst.hedgeitem = reward_prefab

    local item = SpawnPrefab(reward_prefab)
    item.entity:AddFollower()
    inst:AddChild(item)
    item.persists = false

    item:AddTag("NOCLICK")
    item:AddTag("FX")
    item.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0, true)
end

local function GetVerb()
    return "PICK_FLOWER"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("hedge_hound_bush")

    inst.AnimState:SetBank("hedgehound_bush")
    inst.AnimState:SetBuild("hedgehound_bush")
    inst.AnimState:PlayAnimation("idle", true)
    inst.scrapbook_anim = "bush_idle"

    inst:AddTag("thorny")

    inst.GetActivateVerb = GetVerb

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_hidehealth = true
    inst.scrapbook_adddeps = { "hedgehound" }

    inst:AddComponent("inspectable")

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true

    inst:AddComponent("combat")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(2)
    inst.components.health:SetMinHealth(1)

    inst.SetReward = SetReward
    inst.OnActivate = OnActivate

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("animqueueover", onanimover)
    inst:ListenForEvent("attacked", do_transform_and_wake)

    grow(inst)

    return inst
end

return Prefab("hedgehound_bush", fn, assets, prefabs)