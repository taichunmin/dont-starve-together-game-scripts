local assets =
{
    Asset("ANIM", "anim/skeletons.zip"),
}

local prefabs =
{
    "boneshard",
    "collapse_small",
}

SetSharedLootTable('skeleton',
{
    {'boneshard',   1.00},
    {'boneshard',   1.00},
})

local function getdesc(inst, viewer)
    if inst.char ~= nil and not viewer:HasTag("playerghost") then
        local mod = GetGenderStrings(inst.char)
        local desc = GetDescription(viewer, inst, mod)
        local name = inst.playername or STRINGS.NAMES[string.upper(inst.char)]

        --no translations for player killer's name
        if inst.pkname ~= nil then
            return string.format(desc, name, inst.pkname)
        end

        --permanent translations for death cause
        if inst.cause == "unknown" then
            inst.cause = "shenanigans"
        elseif inst.cause == "moose" then
            inst.cause = math.random() < .5 and "moose1" or "moose2"
        end

        --viewer based temp translations for death cause
        local cause =
            inst.cause == "nil"
            and (viewer == "waxwell" and
                "charlie" or
                "darkness")
            or inst.cause

        return string.format(desc, name, STRINGS.NAMES[string.upper(cause)] or STRINGS.NAMES.SHENANIGANS)
    end
end

local function decay(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst:Remove()
    SpawnPrefab("ash").Transform:SetPosition(x, y, z)
    SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
end

local function SetSkeletonDescription(inst, char, playername, cause, pkname, userid)
    inst.char = char
    inst.playername = playername
	inst.userid = userid
    inst.pkname = pkname
    inst.cause = pkname == nil and cause:lower() or nil
    inst.components.inspectable.getspecialdescription = getdesc
end

local function SetSkeletonAvatarData(inst, client_obj)
    inst.components.playeravatardata:SetData(client_obj)
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")
    inst:Remove()
end

local function onsave(inst, data)
    data.anim = inst.animnum
end

local function onload(inst, data)
    if data ~= nil and data.anim ~= nil then
        inst.animnum = data.anim
        inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))
    end
end

local function onsaveplayer(inst, data)
    onsave(inst, data)

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

local function onloadplayer(inst, data)
    onload(inst, data)

    if data ~= nil and data.char ~= nil and (data.cause ~= nil or data.pkname ~= nil) then
        inst.char = data.char
        inst.playername = data.playername --backward compatibility for nil playername
		inst.userid = data.userid
        inst.pkname = data.pkname --backward compatibility for nil pkname
        inst.cause = data.cause
        if inst.components.inspectable ~= nil then
            inst.components.inspectable.getspecialdescription = getdesc
        end
        if data.age ~= nil and data.age > 0 then
            inst.skeletonspawntime = -data.age
        end

        if data.avatar ~= nil then
            --Load legacy data
            inst.components.playeravatardata:OnLoad(data.avatar)
        end
    end
end

local function common_fn(custom_init)
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

    --not going to use the spear skeleton until anim to take spear is made
    inst.animnum = math.random(6)
    inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('skeleton')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)

	if not TheSim:HasPlayerSkeletons() then
		inst:Hide()
		inst:DoTaskInTime(0, inst.Remove)
	end

    return inst
end

local function fn()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

local function player_custominit(inst)
    inst:AddTag("playerskeleton")

    inst:AddComponent("playeravatardata")
    inst.components.playeravatardata:AddPlayerData(true)
end

local function fnplayer()
    local inst = common_fn(player_custominit)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnLoad = onloadplayer
    inst.OnSave = onsaveplayer
    inst.SetSkeletonDescription = SetSkeletonDescription
    inst.SetSkeletonAvatarData = SetSkeletonAvatarData
    inst.Decay = decay
    inst.skeletonspawntime = GetTime()
    TheWorld:PushEvent("ms_skeletonspawn", inst)

    return inst
end

return Prefab("skeleton", fn, assets, prefabs),
    Prefab("skeleton_player", fnplayer, assets, prefabs)
