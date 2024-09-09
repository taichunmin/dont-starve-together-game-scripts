
local prefabs =
{
	"alterguardian_hat_equipped_client",
}

local assets =
{
	Asset("ANIM", "anim/hat_alterguardian_equipped.zip"),
}

local function OnActivated(inst, owner, is_front)
	inst.entity:SetParent(owner.entity)
	inst.entity:AddFollower()
	inst.Follower:FollowSymbol(owner.GUID, "hair", 0, 0, 0) -- "swap_hat"

	inst.AnimState:Hide(is_front and "back" or "front")
	inst.AnimState:SetFinalOffset(is_front and 1 or -1)

	inst.AnimState:PlayAnimation("activate_pre")
	inst.AnimState:PushAnimation("activate_loop", true)
end

local function OnDeactivated(inst)
	inst.AnimState:PlayAnimation("activate_pst")
	inst:ListenForEvent("animover", inst.Remove)
end

local function SetSkin(inst, skin_build, GUID)
    inst.AnimState:OverrideItemSkinSymbol("p4_piece", skin_build, "p4_piece", GUID, "hat_alterguardian_equipped")
    inst.AnimState:OverrideItemSkinSymbol("fx_glow", skin_build, "fx_glow", GUID, "hat_alterguardian_equipped")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("hat_alterguardian_equipped")
    inst.AnimState:SetBuild("hat_alterguardian_equipped")
    inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetFinalOffset(1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	inst.Transform:SetNoFaced()

    inst:AddTag("FX")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SetSkin = SetSkin
	inst.OnActivated = OnActivated
	inst.OnDeactivated = OnDeactivated

    return inst
end

local function client_fn()
    local inst = CreateEntity()

    return inst
end

return Prefab("alterguardian_hat_equipped", fn, nil, prefabs),
	 Prefab("alterguardian_hat_equipped_client", client_fn, assets)
