local assets =
{
    Asset("ANIM", "anim/portal_friends.zip"),
    Asset("SOUND", "sound/common.fsb"),
	Asset("MINIMAP_IMAGE", "wormhole"),
}

local function close(inst)
    inst.AnimState:PlayAnimation("closing")
    inst.AnimState:PushAnimation("idle_closed", true)
end

local function open(inst)
    inst.AnimState:PlayAnimation("opening")
    inst.AnimState:PushAnimation("idle", true)
end

local function full(inst)
    inst.AnimState:PlayAnimation("opening", true)
end

local function activate(inst)
    inst.AnimState:PlayAnimation("activate")
    inst.AnimState:PushAnimation("opening")
    inst.AnimState:PushAnimation("idle")
end

local function GetStatus(inst)
    if inst.components.worldmigrator:IsActive() then
        return "OPEN"
    elseif inst.components.worldmigrator:IsFull() then
        return "FULL"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("wormhole.png")

    inst.AnimState:SetBank("portal_friends")
    inst.AnimState:SetBuild("portal_friends")
    inst.AnimState:PlayAnimation("idle_closed", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("worldmigrator")
    inst:ListenForEvent("migration_available", open)
    inst:ListenForEvent("migration_unavailable", close)
    inst:ListenForEvent("migration_full", full)
    inst:ListenForEvent("migration_activate", activate)

    return inst
end

return Prefab("migration_portal", fn, assets)
