local assets =
{
    Asset("ANIM", "anim/crow_kids.zip"),
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

local function onsave(inst, data)
    data.shape = inst.shape
end

local function onload(inst, data)
	inst.shape = data ~= nil and data.shape or 1
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

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(165/255, 180/255, 200/255)
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    inst:AddTag("character")
    inst:AddTag("_named")
    inst:AddTag("NOBLOCK")

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

    --inst:AddComponent("sleeper")
    --inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:AddComponent("inspectable")

    MakeHauntablePanic(inst)

	inst.shape = math.random(3)
	SetScarfBuild(inst)


    inst:SetStateGraph("SGcarnival_crowkid")
    inst:SetBrain(brain)

	inst.OnSave = onsave
	inst.OnLoad = onload

    return inst
end

return Prefab("carnival_crowkid", fn, assets, prefabs)
