local assets =
{
   Asset("ANIM", "anim/abigail_attack_fx.zip"),
}

local function normal_kill_fx(inst, attack_level)
    inst.AnimState:PlayAnimation("attack" .. tostring(attack_level) .. "_pst")
    inst:DoTaskInTime(FRAMES * 15, function() inst:Remove() end)
end

local function ground_kill_fx(inst, attack_level)
    inst.AnimState:PlayAnimation("attack" .. tostring(attack_level) .. "_ground_pst")
    inst:DoTaskInTime(FRAMES * 12, function() inst:Remove() end)
end

local function ground_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("abigail_attack_fx")
    inst.AnimState:SetBuild("abigail_attack_fx")

    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.kill_fx = ground_kill_fx

    return inst
end

local function normal_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("abigail_attack_fx")
    inst.AnimState:SetBuild("abigail_attack_fx")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.kill_fx = normal_kill_fx

    return inst
end

return Prefab("abigail_attack_fx", normal_fn, assets),
       Prefab("abigail_attack_fx_ground", ground_fn, assets)