local assets =
{
    Asset("ANIM", "anim/skeletons.zip"),
}

local prefabs =
{
    "boneshard",
    "collapse_small",
    "scrapbook_page",
}

SetSharedLootTable('skeleton',
{
    {'boneshard',      1.00},
    {'boneshard',      1.00},
    {'scrapbook_page', 0.10},
})

SetSharedLootTable('skeleton_player',
{
    {'boneshard',   1.00},
    {'boneshard',   1.00},
})

-----------------------------------------------------------------------------------------------

local function Player_GetDescription(inst, viewer)
    if inst.char ~= nil and not viewer:HasTag("playerghost") then
        local mod = GetGenderStrings(inst.char)
        local desc = GetDescription(viewer, inst, mod)
        local name = inst.playername or STRINGS.NAMES[string.upper(inst.char)]

        -- No translations for player killer's name.
        if inst.pkname ~= nil then
            return string.format(desc, name, inst.pkname)
        end

        -- Permanent translations for death cause.
        if inst.cause == "unknown" then
            inst.cause = "shenanigans"

        elseif inst.cause == "moose" then
            inst.cause = math.random() < .5 and "moose1" or "moose2"
        end

        -- Viewer based temp translations for death cause.
        local cause =
            inst.cause == "nil"
            and (
                (viewer == "waxwell" or viewer == "winona") and "charlie" or "darkness"
            )
            or inst.cause

        return string.format(desc, name, STRINGS.NAMES[string.upper(cause)] or STRINGS.NAMES.SHENANIGANS)
    end
end

local function Player_Decay(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst:Remove()
    SpawnPrefab("ash").Transform:SetPosition(x, y, z)
    SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
end

local function Player_SetSkeletonDescription(inst, char, playername, cause, pkname, userid)
    inst.char = char
    inst.playername = playername
    inst.userid = userid
    inst.pkname = pkname
    inst.cause = pkname == nil and cause:lower() or nil
    inst.components.inspectable.getspecialdescription = Player_GetDescription
end

local function Player_SetSkeletonAvatarData(inst, client_obj)
    inst.components.playeravatardata:SetData(client_obj)
end

-----------------------------------------------------------------------------------------------

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")

    inst:Remove()
end

local function OnSave(inst, data)
    data.anim = inst.animnum
end

local function OnLoad(inst, data)
    if data ~= nil and data.anim ~= nil then
        inst.animnum = data.anim
        inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))
    end
end

local function Player_OnSave(inst, data)
    OnSave(inst, data)

    data.char = inst.char
    data.playername = inst.playername
    data.userid = inst.userid
    data.pkname = inst.pkname
    data.cause = inst.cause

    if inst.skeletonspawntime ~= nil then
        local time = GetTime()

        if time > inst.skeletonspawntime then
            data.age = time - inst.skeletonspawntime
        end
    end
end

local function Player_OnLoad(inst, data)
    OnLoad(inst, data)

    if data ~= nil and data.char ~= nil and (data.cause ~= nil or data.pkname ~= nil) then
        inst.char = data.char
        inst.playername = data.playername -- Backward compatibility for nil playername.
        inst.userid = data.userid
        inst.pkname = data.pkname -- Backward compatibility for nil pkname.
        inst.cause = data.cause

        if inst.components.inspectable ~= nil then
            inst.components.inspectable.getspecialdescription = Player_GetDescription
        end

        if data.age ~= nil and data.age > 0 then
            inst.skeletonspawntime = -data.age
        end

        if data.avatar ~= nil then
            -- Load legacy data.
            inst.components.playeravatardata:OnLoad(data.avatar)
        end
    end
end

-----------------------------------------------------------------------------------------------

local function common_fn(custom_init, data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeSmallObstaclePhysics(inst, 0.25)

    inst.AnimState:SetBank("skeleton")
    inst.AnimState:SetBuild("skeletons")

    if custom_init ~= nil then
        custom_init(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle"..tostring(data.animnum_min)

    -- Not going to use the spear skeleton until anim to take spear is made.
    inst.animnum = math.random(data.animnum_min, data.animnum_max)
    inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('skeleton')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.SKELETON_WORK)
    inst.components.workable:SetOnFinishCallback(OnHammered)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    if not TheSim:HasPlayerSkeletons() then
        inst:Hide()
        inst:DoTaskInTime(0, inst.Remove)
    end

    return inst
end

-----------------------------------------------------------------------------------------------

local function regular_fn()
    return common_fn(nil, {animnum_min=1, animnum_max=6})
end

local function creature_custominit(inst)
    inst:SetPrefabNameOverride("skeleton_notplayer")

    inst.scrapbook_proxy = "skeleton_notplayer"
end

local function creature_fn()
    return common_fn(creature_custominit, {animnum_min=7, animnum_max=8})
end

local function creature_1_fn()
    return common_fn(creature_custominit, {animnum_min=7, animnum_max=7})
end

local function creature_2_fn()
    return common_fn(creature_custominit, {animnum_min=8, animnum_max=8})
end

-----------------------------------------------------------------------------------------------

local function player_custominit(inst)
    inst:AddTag("playerskeleton")

    inst:AddComponent("playeravatardata")
    inst.components.playeravatardata:AddPlayerData(true)

    inst.scrapbook_proxy = "skeleton"
end

local function player_fn()
    local inst = common_fn(player_custominit, {animnum_min=1, animnum_max=6})

    if not TheWorld.ismastersim then
        return inst
    end

    inst.skeletonspawntime = GetTime()

    inst.Decay = Player_Decay

    inst.SetSkeletonDescription = Player_SetSkeletonDescription
    inst.SetSkeletonAvatarData  = Player_SetSkeletonAvatarData

    inst.components.lootdropper:SetChanceLootTable('skeleton_player')

    TheWorld:PushEvent("ms_skeletonspawn", inst)

    inst.OnSave = Player_OnSave
    inst.OnLoad = Player_OnLoad

    return inst
end

return
    Prefab("skeleton",             regular_fn,    assets, prefabs),
    Prefab("skeleton_player",      player_fn,     assets, prefabs),
    Prefab("skeleton_notplayer",   creature_fn,   assets, prefabs),
    Prefab("skeleton_notplayer_1", creature_1_fn, assets, prefabs),
    Prefab("skeleton_notplayer_2", creature_2_fn, assets, prefabs)
