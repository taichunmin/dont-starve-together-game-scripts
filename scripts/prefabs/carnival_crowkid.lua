local assets =
{
    Asset("ANIM", "anim/crow_kids.zip"),
    Asset("ANIM", "anim/crow_kids2.zip"),
}

local prefabs =
{
    "carnival_gametoken",
	"carnival_prizeticket",
}

local brain = require "brains/carnival_crowkidbrain"

local function SetScarfBuild(inst)
	if inst.shape == 1 then
		inst.AnimState:ClearOverrideSymbol("scarf_1")
	else
		inst.AnimState:OverrideSymbol("scarf_1", "crow_kids", "scarf_"..tostring(inst.shape))
	end
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "has_snack" then
        inst.has_snack = nil
    end
end

local function AcceptTest(inst, item, giver)
    return inst.has_snack == nil and (item.prefab == "corn_cooked" or item.prefab == "carnivalfood_corntea")
end

local function OnGetItemFromPlayer(inst, giver, item)
	inst.has_snack = item.prefab

	inst.components.timer:StartTimer("has_snack", item.components.perishable ~= nil and (item.components.perishable.perishremainingtime * 0.5) or TUNING.TOTAL_DAY_TIME )
	inst.sg:GoToState("give_reward", giver)

	item:Remove()
end

local function OnRefuseItem(inst, giver, item)
	if not inst:HasTag("busy") then
		if inst.has_snack then
			inst.components.talker:Say(STRINGS.CARNIVAL_CROWKID_HASGIFT[math.random(#STRINGS.CARNIVAL_CROWKID_HASGIFT)])
		else
			inst.components.talker:Say(STRINGS.CARNIVAL_CROWKID_REFUSEGIFT[math.random(#STRINGS.CARNIVAL_CROWKID_REFUSEGIFT)])
		end
	end
end

local function onsave(inst, data)
    data.shape = inst.shape
	data.has_snack = inst.has_snack
end

local function onload(inst, data)
	if data ~= nil then
		inst.shape = data.shape or 1
		inst.has_snack = data.has_snack
	end

	SetScarfBuild(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("crow_kids")
    inst.AnimState:SetBuild("crow_kids")
    inst.AnimState:PlayAnimation("idle", true)

	-- TODO: Remove this when the art is done
	inst.AnimState:AddOverrideBuild("crow_kids2")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(165/255, 180/255, 200/255)
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    inst:AddTag("character")
    inst:AddTag("_named")
    inst:AddTag("NOBLOCK")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.ShouldFlyAway = not IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL)

    --Remove this tag so that they can be added properly when replicating components below
    inst:RemoveTag("_named")
    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.CROWNAMES
    inst.components.named:PickNewName()

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.CARNIVAL_CROWKID_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.CARNIVAL_CROWKID_WALK_SPEED

    inst:AddComponent("knownlocations")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    inst.components.eater:SetCanEatRaw()

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
	inst.components.trader.deleteitemonaccept = false -- will be deleted in trader.onaccept

    inst:AddComponent("inspectable")

    inst:AddComponent("fueler")
    inst.components.fueler.fuelvalue = TUNING.SMALL_FUEL

	inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    MakeHauntablePanic(inst)

	inst.shape = math.random(3)
	SetScarfBuild(inst)

	inst.has_snack = nil

    inst:SetStateGraph("SGcarnival_crowkid")
    inst:SetBrain(brain)

	inst.OnSave = onsave
	inst.OnLoad = onload

    return inst
end

return Prefab("carnival_crowkid", fn, assets, prefabs)
