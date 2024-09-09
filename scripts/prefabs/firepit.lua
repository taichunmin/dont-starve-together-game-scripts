require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/firepit.zip"),
}

local prefabs =
{
    "campfirefire",
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

local function onextinguish(inst)
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
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
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
        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())

		if newsection == inst.components.fueled.sections then
			inst.queued_charcoal = not inst.disable_charcoal
		end
    end
end

local SECTION_STATUS =
{
    [0] = "OUT",
    [1] = "EMBERS",
    [2] = "LOW",
    [3] = "NORMAL",
    [4] = "HIGH",
}
local function getstatus(inst)
    return SECTION_STATUS[inst.components.fueled:GetCurrentSection()]
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE and
        inst.components.fueled ~= nil and
        not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(TUNING.MED_FUEL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    --#HAUNTFIX
    --elseif math.random() <= TUNING.HAUNT_CHANCE_HALF and
        --inst.components.workable ~= nil and
        --inst.components.workable:CanBeWorked() then
        --inst.components.workable:WorkedBy(haunter, 1)
        --inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        --return true
    end
    return false
end

local function OnInit(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:FixFX()
    end
end

local function OnSave(inst, data)
    data.queued_charcoal = inst.queued_charcoal or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.queued_charcoal then
		inst.queued_charcoal = true
    end
end

--------------------------------------------------------------------------
--quagmire

local function OnPrefabOverrideDirty(inst)
    if inst.prefaboverride:value() ~= nil then
        inst:SetPrefabNameOverride(inst.prefaboverride:value().prefab)
        if not TheWorld.ismastersim and inst.replica.container:CanBeOpened() then
            inst.replica.container:WidgetSetup(inst.prefaboverride:value().prefab)
        end
    end
end

local function OnRadiusDirty(inst)
    inst:SetPhysicsRadiusOverride(inst.radius:value() > 0 and inst.radius:value() / 100 or nil)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2

    inst.MiniMapEntity:SetIcon("firepit.png")
    inst.MiniMapEntity:SetPriority(1)

    inst.AnimState:SetBank("firepit")
    inst.AnimState:SetBuild("firepit")
    inst.AnimState:PlayAnimation("idle", false)

    inst:AddTag("campfire")
    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

	-- for storytellingprop component
	inst:AddTag("storytellingprop")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("installations")
        inst:AddTag("quagmire_stewer")
        inst:AddTag("quagmire_cookwaretrader")

        inst.takeitem = net_entity(inst.GUID, "firepit.takeitem")
        inst.prefaboverride = net_entity(inst.GUID, "firepit.prefaboverride", "prefaboverridedirty")
        inst.radius = net_byte(inst.GUID, "firepit.radius", "radiusdirty")

        if not TheWorld.ismastersim then
            inst:ListenForEvent("prefaboverridedirty", OnPrefabOverrideDirty)
            inst:ListenForEvent("radiusdirty", OnRadiusDirty)
        end

        inst.curradius = .6
        MakeObstaclePhysics(inst, inst.curradius)
    else
        MakeObstaclePhysics(inst, .3)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 25, 0), "firefx", true, nil, true)
    inst:ListenForEvent("onextinguish", onextinguish)

    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -------------------------
    inst:AddComponent("cooker")
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

    -----------------------------
    if TheNet:GetServerGameMode() == "quagmire" then
		inst.disable_charcoal = true
        event_server_data("quagmire", "prefabs/firepit").master_postinit(inst, OnPrefabOverrideDirty, OnRadiusDirty)
    end
    -----------------------------

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    -----------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:DoTaskInTime(0, OnInit)

    inst.restart_firepit = function( inst )
        -- HACK(JBK): In order to stop making more charcoals this reset function for the reskin_tool needs to make it not work while it updates animation frames.
        local queued = inst.queued_charcoal
        inst.queued_charcoal = nil

        local fuel_percent = inst.components.fueled:GetPercent()
        inst.components.fueled:MakeEmpty()
        inst.components.fueled:SetPercent( fuel_percent )

        inst.queued_charcoal = queued
    end

    return inst
end



return Prefab("firepit", fn, assets, prefabs),
    MakePlacer("firepit_placer", "firepit", "firepit", "preview")

