require("prefabutil")

local assets =
{
	Asset("ANIM", "anim/magician_chest.zip"),
}

local prefabs =
{
	"collapse_small",
}

--local function CreateFX()
--	local inst = CreateEntity()
--
--	inst:AddTag("NOCLICK")
--	inst:AddTag("FX")
--	--[[Non-networked entity]]
--	inst.persists = false
--
--	inst.entity:AddTransform()
--	inst.entity:AddAnimState()
--
--	inst.AnimState:SetBank("magician_chest")
--	inst.AnimState:SetBuild("magician_chest")
--	inst.AnimState:PlayAnimation("FX", true)
--	inst.AnimState:SetFinalOffset(1)
--
--	return inst
--end

--[[local function OnShowOpenFX(inst)
	if inst._showopenfx:value() then
		if inst.fx == nil then
			inst.fx = CreateFX()
			inst.fx.entity:SetParent(inst.entity)
			if inst.highlightchildren == nil then
				inst.highlightchildren = { inst.fx }
			else
				table.insert(inst.highlightchildren, inst.fx)
			end
		end
	elseif inst.fx ~= nil then
		table.removearrayvalue(inst.highlightchildren, inst.fx)
		inst.fx:Remove()
		inst.fx = nil
	end
end]]

local function OnOpen(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")
		inst.AnimState:PushAnimation("loop")
		inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/open")
		inst.SoundEmitter:PlaySound("maxwell_rework/shadow_magic/storage_void_LP", "loop")
		inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/curtain_lp", "curtain_loop")
		--inst._showopenfx:set(true)
	end
end

local function OnClose(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")
		inst.AnimState:PushAnimation("closed", false)
		inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/close")
		--inst.SoundEmitter:KillSound("loop")
		--inst._showopenfx:set(false)
	end
	inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:KillSound("curtain_loop")

end

local function OnHammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function OnHit(inst, worker)
	if not inst:HasTag("burnt") then
		if inst.components.container_proxy ~= nil then
			inst.components.container_proxy:Close()
		end
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", false)
		--inst._showopenfx:set(false)
	end
end

--[[local function OnBurnt(inst)
	DefaultBurntStructureFn(inst)
	inst._showopenfx:set(false)
end]]

local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
	inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/place")
end

local function OnSave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil and data.burnt and inst.components.burnable ~= nil then
		inst.components.burnable.onburnt(inst)
	end
end

local function AttachShadowContainer(inst)
	inst.components.container_proxy:SetMaster(TheWorld:GetPocketDimensionContainer("shadow"))
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(0.75) --recipe min_spacing/2

	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetIcon("magician_chest.png")

	inst:AddTag("structure")
	--inst:AddTag("chest")

	inst.AnimState:SetBank("magician_chest")
	inst.AnimState:SetBuild("magician_chest")
	inst.AnimState:PlayAnimation("closed")
	inst.scrapbook_anim = "closed"

	MakeSnowCoveredPristine(inst)

	inst:AddComponent("container_proxy")

	--[[inst._showopenfx = net_bool(inst.GUID, "magician_chest._showopenfx", "showopenfxdirty")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("showopenfxdirty", OnShowOpenFX)
	end]]

	inst.scrapbook_specialinfo = "MAGICIANCHEST"

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst.components.container_proxy:SetOnOpenFn(OnOpen)
	inst.components.container_proxy:SetOnCloseFn(OnClose)

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(OnHammered)
	inst.components.workable:SetOnWorkCallback(OnHit)

	MakeSmallBurnable(inst, nil, nil, true)
	MakeMediumPropagator(inst)
	--inst.components.burnable:SetOnBurntFn(OnBurnt)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:ListenForEvent("onbuilt", OnBuilt)
	MakeSnowCovered(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = AttachShadowContainer

	if not POPULATING then
		AttachShadowContainer(inst)
	end

	return inst
end

return Prefab("magician_chest", fn, assets, prefabs),
	MakePlacer("magician_chest_placer", "magician_chest", "magician_chest", "closed")
