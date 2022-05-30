local assets =
{
	Asset("ANIM", "anim/sounddebug.zip"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddLabel()

    inst.Label:SetFontSize(20)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetWorldOffset(0, .1, 0)
    inst.Label:SetUIOffset(0, 0, 0)
    inst.Label:SetColour(.73, .05, .02)
    inst.Label:Enable(true)

    inst.AnimState:SetBank("sound")
    inst.AnimState:SetBuild("sounddebug")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    inst.autokilltask = inst:DoTaskInTime(0.5, inst.Remove)
    return inst
end

return Prefab("sounddebugicon", fn, assets)
