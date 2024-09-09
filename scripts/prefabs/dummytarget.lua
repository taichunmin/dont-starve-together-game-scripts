local assets =
{
    Asset("ANIM", "anim/wilsonstatue.zip"),
}

local function OnHealthDelta(inst, data)
    if data.amount <= 0 then
        inst.Label:SetText(data.amount)
        inst.Label:SetUIOffset(math.random() * 20 - 10, math.random() * 20 - 10, 0)
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
    end
end

local function MakeDummy(name, common_postinit, master_postinit)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()
		inst.entity:AddLabel()

		inst.Label:SetFontSize(50)
		inst.Label:SetFont(DEFAULTFONT)
		inst.Label:SetWorldOffset(0, 3, 0)
		inst.Label:SetUIOffset(0, 0, 0)
		inst.Label:SetColour(1, 1, 1)
		inst.Label:Enable(true)

		inst:SetDeploySmartRadius(1)
		MakeObstaclePhysics(inst, .3)

		inst.AnimState:SetBank("wilsonstatue")
		inst.AnimState:SetBuild("wilsonstatue")
		inst.AnimState:PlayAnimation("idle")

		inst:AddTag("monster")

		MakeSnowCoveredPristine(inst)

		if common_postinit ~= nil then
			common_postinit(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("bloomer")
		inst:AddComponent("colouradder")

		inst:AddComponent("inspectable")

		inst:AddComponent("combat")
		inst:AddComponent("debuffable")
		inst.components.debuffable:SetFollowSymbol("ww_head", 0, -250, 0)

		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(1000)
		inst.components.health:StartRegen(1000, .1)
		inst:ListenForEvent("healthdelta", OnHealthDelta)

		if TheNet:GetServerGameMode() == "lavaarena" then
			TheWorld:PushEvent("ms_register_for_damage_tracking", { inst = inst })
		end

		if master_postinit ~= nil then
			master_postinit(inst)
		end

		return inst
	end
	return Prefab(name, fn, assets)
end

local function lunar_common_postinit(inst)
	inst:AddTag("lunar_aligned")
	inst.AnimState:SetBrightness(3)
end

local function shadow_common_postinit(inst)
	inst:AddTag("shadow_aligned")
	inst.AnimState:SetBrightness(.3)
end

local function make_planar(inst)
	inst:AddComponent("planarentity")
end

return MakeDummy("dummytarget"),
	MakeDummy("dummytarget_lunar", lunar_common_postinit, make_planar),
	MakeDummy("dummytarget_shadow", shadow_common_postinit, make_planar)
