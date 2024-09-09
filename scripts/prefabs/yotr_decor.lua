require "prefabutil"

local prefabs =
{
	"torchfire",
	"collapse_small",
	"ash",
	"charcoal",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("ash").Transform:SetPosition(x, y, z)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function onignite(inst)
	if inst._fire == nil then
		inst._fire = SpawnPrefab("torchfire")
		inst._fire.entity:SetParent(inst.entity)
		inst._fire.entity:AddFollower()
		inst._fire.Follower:FollowSymbol(inst.GUID, "firefx")
		inst._fire:AttachLightTo(inst)
	end
	inst.AnimState:Hide("shadow")
end

local function onextinguish(inst)
	if inst._fire ~= nil then
		inst._fire:Remove()
		inst._fire = nil
	end
    inst.AnimState:Show("shadow")
    if inst.components.fueled ~= nil then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function ontakefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function updatefuelrate(inst)
	inst.components.fueled.rate = TheWorld.state.israining and inst.components.rainimmunity == nil and 1 + TUNING.FIREPIT_RAIN_RATE * TheWorld.state.precipitationrate or 1
end

local function onupdatefueled(inst)
    if inst.components.burnable ~= nil and inst.components.fueled ~= nil then
        updatefuelrate(inst)
    end
end

local function onfuelchange(newsection, oldsection, inst, doer)
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
		if inst.queued_charcoal then
			inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.queued_charcoal = nil
		end
    else
        if not inst.components.burnable:IsBurning() then
            updatefuelrate(inst)
            inst.components.burnable:Ignite(nil, nil, doer)
        end

		if newsection == inst.components.fueled.sections then
			inst.queued_charcoal = not inst.disable_charcoal
		end
    end
end

local function getstatus(inst)
    return (inst.components.fueled:GetCurrentSection() == 0 and "OUT")
        or "GENERAL"
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    local place_sound = (inst.prefab == "yotr_decor_1" and "yotr_2023/common/decor1_place")
        or "yotr_2023/common/decor2_place"
    inst.SoundEmitter:PlaySound(place_sound)
end



local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE and
        inst.components.fueled ~= nil and
        not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(TUNING.MED_FUEL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

--If fx were spawned during entity construction, follow symbols may not
--be hooked up properly. Call this to fix them.
local function OnInit(inst)
	if inst._fire ~= nil then
		inst._fire.Follower:FollowSymbol(inst.GUID, "firefx")
	end
end

local function makedeco(name,bank,build)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/"..name.."_item.zip"),
        Asset("INV_IMAGE", name),
        Asset("MINIMAP_IMAGE", name),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon(name..".png")
        inst.MiniMapEntity:SetPriority(1)

        inst.AnimState:SetBank(bank or name)
        inst.AnimState:SetBuild(build or name)
        inst.AnimState:PlayAnimation("idle", false)

        inst:AddTag("campfire")
        inst:AddTag("structure")

		inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
        MakeObstaclePhysics(inst, .3)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------
        inst:AddComponent("burnable")
		inst.components.burnable.fxprefab = nil
		inst.components.burnable:SetOnIgniteFn(onignite)
		inst.components.burnable:SetOnExtinguishFn(onextinguish)

        -------------------------
        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        -------------------------
        inst:AddComponent("fueled")
        inst.components.fueled.maxfuel = TUNING.FIREPIT_FUEL_MAX
        inst.components.fueled.accepting = true

        inst.components.fueled:SetSections(4)
        inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT
        inst.components.fueled:SetTakeFuelFn(ontakefuel)
        inst.components.fueled:SetUpdateFn(onupdatefueled)
        inst.components.fueled:SetSectionCallback(onfuelchange)
        inst.components.fueled:InitializeFuelLevel(TUNING.FIREPIT_FUEL_START)

        inst:AddComponent("storytellingprop")

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        -----------------------------

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:ListenForEvent("onbuilt", onbuilt)

        inst:DoTaskInTime(0, OnInit)

        return inst
    end

    local deployable_data =
    {
        deploymode = DEPLOYMODE.CUSTOM,
        custom_candeploy_fn = function(inst, pt, mouseover, deployer)
            local x, y, z = pt:Get()
            return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false)
        end,
    }

    return Prefab(name, fn, assets, prefabs),
            MakeDeployableKitItem(
                    name.."_item",                             -- name
                    name,                                    -- prefab_to_deploy
                    name.."_item",                             -- bank
                    name.."_item",                             -- build
                    "idle",                                             -- anim
                    {Asset("ANIM", "anim/"..name.."_item.zip")},   -- assets
                    {size = "med", scale = 0.77},                       -- float data
                    nil,                                                -- tags
                    {fuelvalue = TUNING.LARGE_FUEL},                    -- burnable
                    deployable_data                   -- deploy
                ),
            MakePlacer(name.."_item_placer", name, name, "placer")
end

local DECO_DEFS = {
    "yotr_decor_1",
    "yotr_decor_2"
}

local pack = {} 
for i,decodata in ipairs(DECO_DEFS) do
    local deco, item, placer = makedeco(decodata)
    table.insert(pack,deco)
    table.insert(pack,item)
    table.insert(pack,placer)
end
return unpack(pack)
