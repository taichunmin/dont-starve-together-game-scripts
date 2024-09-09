local assets =
{
    Asset("ANIM", "anim/hermitcrab_home.zip"),
    Asset("MINIMAP_IMAGE", "hermitcrab_home"),
    Asset("MINIMAP_IMAGE", "hermitcrab_home2"),
}

local prefabs =
{
	"construction_container",
}

local construction_data = {
	{level = 1, name = "hermithouse_construction1", construction_product = "hermithouse_construction2" },
	{level = 2, name = "hermithouse_construction2", construction_product = "hermithouse_construction3" },
	{level = 3, name = "hermithouse_construction3", construction_product = "hermithouse" },
}

local function displaynamefn(inst)
    return inst:HasTag("highfriendlevel") and STRINGS.NAMES.HERMITHOUSE_PEARL or STRINGS.NAMES.HERMITHOUSE
end

local function LightsOn(inst)
    if not inst:HasTag("burnt") and not inst.lightson then
        inst.Light:Enable(true)
        inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/light_on")
        inst.lightson = true

        local build_name = inst.AnimState:GetSkinBuild()
        if inst._window ~= nil then
            if build_name ~= "" then
                inst._window.AnimState:SetSkin(build_name)
            end
            inst._window.AnimState:PlayAnimation("windowlight_idle", true)
            inst._window:Show()
        end
        if inst._windowsnow ~= nil then
            if build_name ~= "" then
                inst._windowsnow.AnimState:SetSkin(build_name)
            end
            inst._windowsnow.AnimState:PlayAnimation("windowsnow_idle", true)
            inst._windowsnow:Show()
        end
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") and inst.lightson then
        inst.Light:Enable(false)
        inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/light_off")
        inst.lightson = false
        if inst._window ~= nil then
            inst._window:Hide()
        end
        if inst._windowsnow ~= nil then
            inst._windowsnow:Hide()
        end
    end
end

local function onoccupieddoortask(inst)
    inst.doortask = nil
    if not inst.nolight then
        LightsOn(inst)
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/inside_LP", "hermitsound")

        if inst.level > 1 then
            inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage2_door")
        else
            inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage1_door")
        end

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1, onoccupieddoortask)
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.doortask ~= nil then
            inst.doortask:Cancel()
            inst.doortask = nil
        end

        if inst.level > 1 then
            inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage2_door")
        else
            inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage1_door")
        end

        inst.SoundEmitter:KillSound("hermitsound")
        LightsOff(inst)

        if child ~= nil then
            local child_platform = child:GetCurrentPlatform()
            if (child_platform == nil and not child:IsOnValidGround()) then
                local fx = SpawnPrefab("splash_sink")
                fx.Transform:SetPosition(child.Transform:GetWorldPosition())

                child:Remove()
            else
                if child.components.health ~= nil then
                    child.components.health:SetPercent(1)
                end
			    child:PushEvent("onvacatehome")
            end
        end
    end
end

local function OnConstructed(inst, doer)
    local concluded = true
    for _, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
        end
    end

	if concluded then
        local ishome =  inst.components.spawner:IsOccupied()
        inst.components.spawner:ReleaseChild()
        local child = inst.components.spawner.child -- NOTES(JBK): This must be after ReleaseChild for entity safety because it will create a new one if it no longer exists.

        local new_house = ReplacePrefab(inst, inst._construction_product)
        new_house.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage"..new_house.level.."_place")

        new_house.components.spawner:TakeOwnership(child)
        child:PushEvent("home_upgraded",{house=new_house,doer=doer})
        if ishome then
            new_house.components.spawner:GoHome(child)
        end
        new_house.AnimState:PlayAnimation("stage"..new_house.level.."_placing")
        new_house.AnimState:PushAnimation("idle_stage"..new_house.level)
        if inst:HasTag("highfriendlevel") then
            new_house:AddTag("highfriendlevel")
        end
    end
end

local function onconstruction_built(inst)
    PreventCharacterCollisionsWithPlacedObjects(inst)
    inst.level = 4
    inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage".. inst.level.."_place")
end

local function onsave(inst, data)
    data.highfriendlevel = inst:HasTag("highfriendlevel")
 end

local function onload(inst, data)
    if data and data.highfriendlevel then
        inst:AddTag("highfriendlevel")
    end
 end

local function onstartdaydoortask(inst)
    inst.doortask = nil
    if not inst:HasTag("burnt") then
        inst.components.spawner:ReleaseChild()
    end
end

local function onstartdaylighttask(inst)
    if inst:IsLightGreaterThan(0.8) then -- they have their own light! make sure it's brighter than that out.
        LightsOff(inst)
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaydoortask)
    elseif TheWorld.state.iscaveday then
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    else
        inst.doortask = nil
    end
end

local function OnStartDay(inst)
    --print(inst, "OnStartDay")
    if not inst:HasTag("burnt")
        and inst.components.spawner:IsOccupied() then

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    end
end

local function spawncheckday(inst)
    inst.inittask = nil
    inst:WatchWorldState("startcaveday", OnStartDay)
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        if TheWorld.state.iscaveday or
            (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            inst.components.spawner:ReleaseChild()
        else
            onoccupieddoortask(inst)
        end
    end
end

local function oninit(inst)
    inst.inittask = inst:DoTaskInTime(math.random(), spawncheckday)
    if inst.components.spawner ~= nil and
        inst.components.spawner.child == nil and
        inst.components.spawner.childname ~= nil and
        not inst.components.spawner:IsSpawnPending() then
        local child = SpawnPrefab(inst.components.spawner.childname)
        if child ~= nil then
            inst.components.spawner:TakeOwnership(child)
            inst.components.spawner:GoHome(child)
			if child.retrofitconstuctiontasks ~= nil then
				child:retrofitconstuctiontasks(inst.prefab)
			end
        end
    end

	if inst.components.spawner.child ~= nil and inst.components.spawner.child.retrofitconstuctiontasks ~= nil then
		inst.components.spawner.child:retrofitconstuctiontasks(inst.prefab)
	end
end

local function dowind(inst)
    if inst.AnimState:IsCurrentAnimation("idle_stage"..inst.level) then
        inst.AnimState:PlayAnimation("idle_stage"..inst.level.."_wind")
        inst.AnimState:PushAnimation("idle_stage"..inst.level)
    end
    inst:DoTaskInTime(math.random()*5, function() inst.dowind(inst) end)
end

local function getstatus(inst)
    if inst.prefab ~= "hermithouse_construction1"  then
        return "BUILTUP"
    end
end

local function MakeHermitCrabHouse(name, client_postinit, master_postinit, house_data)
	local function fn()

        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

		inst.MiniMapEntity:SetIcon("hermitcrab_home2.png")

        inst:AddTag("structure")

        inst.level = (house_data and house_data.level) or 4

		inst:SetPhysicsRadiusOverride(1.5)
		MakeObstaclePhysics(inst, inst.physicsradiusoverride)

		inst.Light:SetFalloff(1)
		inst.Light:SetIntensity(.5)
		inst.Light:SetRadius(1)
		inst.Light:Enable(false)
		inst.Light:SetColour(180/255, 195/255, 50/255)

		inst.AnimState:SetBank("hermitcrab_home")
		inst.AnimState:SetBuild("hermitcrab_home")
		inst.AnimState:PlayAnimation("idle_stage4", true)
        inst.scrapbook_anim = "idle_stage1"

		if house_data then
            inst.AnimState:PlayAnimation("idle_stage"..(house_data.level), true)

			inst:AddTag("constructionsite")
		end

        inst.displaynamefn = displaynamefn

		inst:AddTag("antlion_sinkhole_blocker")

        MakeSnowCoveredPristine(inst)

        inst.scrapbook_proxy = "hermithouse"

        if client_postinit then
            client_postinit(inst)
        end

		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end

        if name == "hermithouse_construction1" then
            inst.nolight = true
            inst.MiniMapEntity:SetIcon("hermitcrab_home.png")
        end

		local spawner = inst:AddComponent("spawner")
		spawner:Configure("hermitcrab", TUNING.TOTAL_DAY_TIME*1)
		spawner.onoccupied = onoccupied
		spawner.onvacate = onvacate
		spawner:SetWaterSpawning(false, true)
		spawner:CancelSpawning()

		if house_data then
			inst._construction_product = house_data.construction_product

			local constructionsite = inst:AddComponent("constructionsite")
			constructionsite:SetConstructionPrefab("construction_container")
			constructionsite:SetOnConstructedFn(OnConstructed)
		end

		inst:SetPrefabNameOverride("hermithouse")

		local inspectable = inst:AddComponent("inspectable")
        inspectable.getstatus = getstatus

		inst:ListenForEvent("onbuilt", onconstruction_built)
		inst.inittask = inst:DoTaskInTime(0, oninit)
        inst.dowind = dowind

        inst:ListenForEvent("clocksegschanged", function(world, data)
            inst.segs = data
            if inst.segs["night"] + inst.segs["dusk"] >= 16 then
                inst.components.spawner:ReleaseChild()
            end
        end, TheWorld)

        if inst.level == 3 or inst.level == 4 then
            inst:DoTaskInTime(math.random()*5, function() inst.dowind(inst) end)
        end

		inst.OnSave = onsave
		inst.OnLoad = onload

        if master_postinit then
           master_postinit(inst)
        end

        return inst
	end

	local product = (house_data and house_data.construction_product) or nil
	return Prefab(name, fn, assets, prefabs, product)
end

local ret = {}
table.insert(ret, MakeHermitCrabHouse("hermithouse"))
for i = 1, #construction_data do
	table.insert(ret, MakeHermitCrabHouse(
        construction_data[i].name,
        construction_data[i].client_postinit,
        construction_data[i].master_postinit,
        construction_data[i]))
end

return unpack(ret)
