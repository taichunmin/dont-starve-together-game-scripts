
local defs =
{
	carnivalcannon_confetti = {
		bank = "carnival_cannon", build = "carnival_cannon",
		fx = "carnival_confetti_fx",
	},

	carnivalcannon_sparkle = {
		bank = "carnival_cannon", build = "carnival_cannon_sparkle",
		fx = "carnival_sparkle_fx",
	},

	carnivalcannon_streamer = {
		bank = "carnival_cannon", build = "carnival_cannon_streamer",
		fx = "carnival_streamer_fx",
	},
}

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function SpawnFx(inst)
	local fx = SpawnPrefab(inst.def.fx)
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function Enable(inst)
	inst.AnimState:PlayAnimation("idle")
	inst.components.activatable.inactive = true
end

local FIND_CHAIN_MUST_TAGS = {"carnivalcannon", "inactive"}
local function ChainActivate(inst)
	if inst.entity:IsAwake() then
		local x, y, z = inst.Transform:GetWorldPosition()
		local chain = TheSim:FindEntities(x, y, z, 4, FIND_CHAIN_MUST_TAGS)
		if chain[1] ~= nil then
			chain[1].components.trader.onaccept(chain[1], true)
		end
	end
end

local function FireCannon(inst, chain)
	inst.components.activatable.inactive = false

	inst.AnimState:PlayAnimation("shoot")
	inst.AnimState:PushAnimation("cooldown", true)

	inst:DoTaskInTime(10 * FRAMES, SpawnFx)
	inst:DoTaskInTime(4, Enable)

	if chain then
		inst:DoTaskInTime(0.3 + math.random() * 0.1, ChainActivate)
		inst._lastchaintime = GetTime()
	end
end

local function OnActivate(inst, doer)
	FireCannon(inst, false)
	return true
end

local function OnAcceptItem(inst, doer)
	FireCannon(inst, true)
	return true
end

local function AbleToAcceptTest(inst, item, giver)
	if not inst:HasTag("inactive") then
		return false
	end

	if item.prefab == "carnival_gametoken" then
		return true
	end
	return false, "CARNIVALGAME_INVALID_ITEM"
end

local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("idle", true)
	inst.SoundEmitter:PlaySound("summerevent/cannon/place")
end

local function GetStatus(inst)
	return not inst.components.activatable.inactive and "COOLDOWN"
			or nil
end

local function common_fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("carnivaldecor")
	inst:AddTag("carnivalcannon")
    inst:AddTag("structure")
    inst:AddTag("cattoy")

	inst:SetPhysicsRadiusOverride(0.5)

	if data.common_postinit then
		data.common_postinit(inst, data)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.def = data

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable.nameoverride = "carnivalcannon"

	inst:AddComponent("lootdropper")

	inst:AddComponent("carnivaldecor")
	inst.components.carnivaldecor.value = 18

	inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
    inst.components.trader.onaccept = OnAcceptItem

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.quickaction = true

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

	inst.FireCannon = FireCannon
	inst:ListenForEvent("onbuilt", OnBuilt)

	if data.master_postinit then
		data.master_postinit(inst)
	end

    return inst
end

local function make_cannon(prefabname, data)
	local assets =
	{
		Asset("ANIM", "anim/"..data.bank..".zip"),
		Asset("ANIM", "anim/"..data.build..".zip"),
	}

	local prefabs = { data.fx }

	local function fn()
		return common_fn(data)
	end

	return Prefab(prefabname, fn, assets, prefabs)
end

local function kit_master_postinit(inst)
	inst.components.inspectable.nameoverride = "carnivalcannon_kit"
end

local function placer_postinit_fn(inst)
	inst.deployhelper_key = "carnival_plaza_decor"
end

local objects = {}
for prefabname, data in pairs(defs) do
    table.insert(objects, make_cannon(prefabname, data))
	table.insert(objects, MakeDeployableKitItem(prefabname.."_kit", prefabname, data.bank, data.build, "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}, {master_postinit = kit_master_postinit, deployspacing = DEPLOYSPACING.MEDIUM}, TUNING.STACK_SIZE_LARGEITEM))
	table.insert(objects, MakePlacer(prefabname.."_kit_placer", data.bank, data.build, data.idleanim or "idle", nil, nil, nil, nil, nil, nil, placer_postinit_fn))
end

return unpack(objects)
