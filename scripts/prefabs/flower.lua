local assets =
{
    Asset("ANIM", "anim/flowers.zip"),
}

local prefabs =
{
    "petals",
    "flower_evil",
    "flower_withered",
    "planted_flower",
	"small_puff",
	"charlierose",
}

local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10"}
local ROSE_NAME = "rose"
local ROSE_CHANCE = 0.01

local function setflowertype(inst, name)
    if inst.animname == nil or (name ~= nil and inst.animname ~= name) then
        if inst.animname == ROSE_NAME then
            inst:RemoveTag("thorny")

            inst._isrose:set(false)
            inst:OnIsRoseDirty()
        end

        inst.animname = name or (math.random() < ROSE_CHANCE and ROSE_NAME or names[math.random(#names)])

        inst.AnimState:PlayAnimation(inst.animname)

        if inst.animname == ROSE_NAME then
            inst:AddTag("thorny")

            inst._isrose:set(true)
            inst:OnIsRoseDirty()
        end
    end
end

local function onsave(inst, data)
    data.anim = inst.animname
    data.planted = inst.planted
end

local function onload(inst, data)
    setflowertype(inst, data ~= nil and data.anim or nil)
    inst.planted = data ~= nil and data.planted or nil
end

local function onpickedfn(inst, picker)
    local pos = inst:GetPosition()

    if picker ~= nil then
        if picker.components.sanity ~= nil and not picker:HasTag("plantkin") then
            picker.components.sanity:DoDelta(TUNING.SANITY_TINY)
        end

        if inst.animname == ROSE_NAME and
            picker.components.combat ~= nil and
            not (picker.components.inventory ~= nil and picker.components.inventory:EquipHasTag("bramble_resistant")) and not picker:HasTag("shadowminion") then
            picker.components.combat:GetAttacked(inst, TUNING.ROSE_DAMAGE)
            picker:PushEvent("thorns")
        end
    end

    TheWorld:PushEvent("plantkilled", { doer = picker, pos = pos }) --this event is pushed in other places too
end

local function GetStatus(inst)
    return inst.animname == ROSE_NAME and "ROSE" or nil
end

local function testfortransformonload(inst)
    return TheWorld.state.isfullmoon
end

local FINDLIGHT_MUST_TAGS = { "daylight", "lightsource" }
local function DieInDarkness(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,0,z, TUNING.DAYLIGHT_SEARCH_RANGE, FINDLIGHT_MUST_TAGS)
    for i,v in ipairs(ents) do
        local lightrad = v.Light:GetCalculatedRadius() * .7
        if v:GetDistanceSqToPoint(x,y,z) < lightrad * lightrad then
            --found light
            return
        end
    end
    --in darkness
    inst:Remove()
    SpawnPrefab("flower_withered").Transform:SetPosition(x,y,z)
end

local function OnIsCaveDay(inst, isday)
    if isday then
        inst:DoTaskInTime(5.0 + math.random()*5.0, DieInDarkness)
    end
end

local function CheckForPlanted(inst)
    if not inst.planted then
        AddToRegrowthManager(inst)
    end
end

local function OnIsRoseDirty(inst)
    inst.scrapbook_proxy = inst._isrose:value() and "flower_rose" or nil
end

--------------------------------------------------------------------------

local function CanResidueBeSpawnedBy(inst, doer)
    local skilltreeupdater = doer and doer.components.skilltreeupdater or nil
    return skilltreeupdater and skilltreeupdater:IsActivated("winona_charlie_2") or false
end

local function OnResidueCreated(inst, owner, residue)
	if not inst._isrose:value() then
		setflowertype(inst, ROSE_NAME)
		SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function OnResidueActivated(inst, doer)
	if inst._isrose:value() and doer and doer.components.inventory then
		local rose = SpawnPrefab("charlierose")
		doer.components.inventory:GiveItem(rose, nil, inst:GetPosition())
		if doer.SoundEmitter then
			doer.SoundEmitter:PlaySound("meta4/charlie_residue/rose_activate")
		end
		inst:Remove()
	end
end

--------------------------------------------------------------------------

local function commonfn(isplanted)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("flowers")
    inst.AnimState:SetBuild("flowers")
    inst.AnimState:SetRayTestOnBB(true)
    inst.scrapbook_anim = "f1"

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2) --butterfly deployspacing/2

    inst:AddTag("flower")
    inst:AddTag("cattoy")

    inst.OnIsRoseDirty = OnIsRoseDirty

    inst._isrose = net_bool(inst.GUID, "flower._isrose", "isrosedirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("isrosedirty", inst.OnIsRoseDirty)

        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("petals", 10)
    inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.remove_when_picked = true
    inst.components.pickable.quickpick = true
    inst.components.pickable.wildfirestarter = true

    --inst:AddComponent("transformer")
    --inst.components.transformer:SetTransformWorldEvent("isfullmoon", true)
    --inst.components.transformer:SetRevertWorldEvent("isfullmoon", false)
    --inst.components.transformer:SetOnLoadCheck(testfortransformonload)
    --inst.components.transformer.transformPrefab = "flower_evil"

    MakeSmallBurnable(inst)
    if not isplanted then -- This will be true during load but it will be false and cut down on runtime.
        inst:DoTaskInTime(0, CheckForPlanted)
    end
    MakeSmallPropagator(inst)

	inst:AddComponent("halloweenmoonmutable")
	inst.components.halloweenmoonmutable:SetPrefabMutated("moonbutterfly_sapling")

	local roseinspectable = inst:AddComponent("roseinspectable")
	roseinspectable:SetCanResidueBeSpawnedBy(CanResidueBeSpawnedBy)
	roseinspectable:SetOnResidueCreated(OnResidueCreated)
	roseinspectable:SetOnResidueActivated(OnResidueActivated)
	roseinspectable:SetForcedInduceCooldownOnActivate(true)

    if TheWorld:HasTag("cave") then
        inst:WatchWorldState("iscaveday", OnIsCaveDay)
    end

    MakeHauntableChangePrefab(inst, "flower_evil")

    if not POPULATING then
        setflowertype(inst)
    end
    --------SaveLoad
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function plainfn()
    -- NOTES(JBK): This is here to stop TheSim from appearing in the commonfn callback.
    return commonfn()
end

local function DoRoseBounceAnim(inst)
	inst.AnimState:PlayAnimation("rose_bounce")
	inst.AnimState:PushAnimation(inst.animname, false)
end

local function rosefn()
    local inst = commonfn()

    inst:SetPrefabName("flower")
    inst.scrapbook_anim = "rose"
    inst.scrapbook_damage = TUNING.ROSE_DAMAGE
    inst.scrapbook_speechname = "FLOWER"

    inst.scrapbook_proxy = "flower_rose"

    if not TheWorld.ismastersim then
        return inst
    end

    setflowertype(inst, ROSE_NAME)
    inst.DoRoseBounceAnim = DoRoseBounceAnim

    return inst
end

local function plantedflowerfn()
    local inst = commonfn(true)

    inst:SetPrefabName("flower")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.planted = true

    return inst
end

return Prefab("flower", plainfn, assets, prefabs),
	Prefab("flower_rose", rosefn, assets, prefabs),
	Prefab("planted_flower", plantedflowerfn, assets, prefabs)
