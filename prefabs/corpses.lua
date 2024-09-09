local easing = require("easing")

--------------------------------------------------------------------------------------------------------
--V2C: We won't bother adding assets for corpses, since they are so tied
--     to the creatures themselves, which may come with alternate builds

local BUILDS =
{
    deerclops =
    {
        default = "deerclops_build",
        yule = "deerclops_yule",
    },

    warg =
    {
        default = "warg_build",
        gingerbread = "warg_gingerbread_build",
    },

    bearger =
    {
        default = "bearger_build",
        yule = "bearger_yule",
    },

    koalefant =
    {
        default = "koalefant_summer_build",
        winter = "koalefant_winter_build",
    },
}

local FACES =
{
    FOUR = 1,
    SIX  = 2,
}

local GESTALT_TRACK_NAME = "gestalt"

--------------------------------------------------------------------------------------------------------

local function SpawnGestalt(inst)
    if inst.components.burnable == nil or not inst.components.burnable:IsBurning() then
        local gestalt = SpawnPrefab("corpse_gestalt")

        inst.components.entitytracker:TrackEntity(GESTALT_TRACK_NAME, gestalt)

        gestalt:SetTarget(inst)
        gestalt:Spawn()

        return gestalt -- Mods
    end
end

local function OnIgnited(inst)
    local gestalt = inst.components.entitytracker:GetEntity(GESTALT_TRACK_NAME)
	if gestalt ~= nil then
        gestalt:SetTarget(nil)
    end
end

local function OnExtinguish(inst)
    if not inst.sg:HasStateTag("mutating") then
		DefaultExtinguishCorpseFn(inst)
    end
end

local function GetStatus(inst)
    return
           (inst.sg:HasStateTag("mutating") and "REVIVING")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) and "BURNING"
        or nil
end

local function DisplayNameFn(inst)
    return inst.creature ~= nil and STRINGS.NAMES[string.upper(inst.nameoverride or inst.creature)] or nil
end

--------------------------------------------------------------------------------------------------------

local function SetAltBuild(inst, buildid)
    inst.build = buildid
    local builds = BUILDS[inst.creature]
    inst.AnimState:SetBuild(buildid ~= nil and builds[buildid] or builds.default)
end

local function OnSave(inst, data)
    data.ready = inst.sg and inst.sg:HasStateTag("mutating") or nil
    data.build = inst.build
end

local function OnLoad(inst, data)
    if data ~= nil then
        SetAltBuild(inst, data.build)
        if data.ready then
            inst:StartMutation(true)
        end
    end
end

--------------------------------------------------------------------------------------------------------

local FLASH_INTENSITY = 0.5
local LIGHT_OVERRIDE_MOD = 0.1 / FLASH_INTENSITY

local function UpdateFlash(inst)
	if inst._flash > 1 then
		inst._flash = inst._flash - 1
		local c = easing.inQuad(inst._flash, 0, FLASH_INTENSITY, 20)
		inst.AnimState:SetAddColour(c, c, c, 0)
		inst.AnimState:SetLightOverride(c * LIGHT_OVERRIDE_MOD)
	else
		inst._flash = nil
		inst.AnimState:SetAddColour(0, 0, 0, 0)
		inst.AnimState:SetLightOverride(0)
		inst:RemoveComponent("updatelooper")
	end
end

local function StartMutation(inst, loading)
	inst.components.burnable:SetOnIgniteFn(nil)
	inst.components.burnable:SetOnExtinguishFn(nil)
	inst.components.burnable:SetOnBurntFn(nil)

    inst.sg:GoToState(loading and "corpse_mutate" or "corpse_mutate_pre", inst.mutantprefab)

	--Start flash
	local c = FLASH_INTENSITY / 2
	inst.AnimState:SetAddColour(c, c, c, 0)
	inst.AnimState:SetLightOverride(c * LIGHT_OVERRIDE_MOD)
	inst._flash = 21
	if inst.components.updatelooper == nil then
		inst:AddComponent("updatelooper")
	end
	inst.components.updatelooper:AddOnUpdateFn(UpdateFlash)
end

--------------------------------------------------------------------------------------------------------

local function MakeCreatureCorpse(data)
    local creature = data.creature
    local nameoverride = data.nameoverride

    local mutantprefab = "mutated"..creature
    local prefabname = creature.."corpse"

    local prefabs = {mutantprefab, "corpse_gestalt"}

    local scale = data.scale
    local faces = data.faces

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, data.physicsradius, 1)

        inst.DynamicShadow:SetSize(unpack(data.shadowsize))

        if faces == FACES.FOUR then
            inst.Transform:SetFourFaced()
        elseif faces == FACES.SIX then
            inst.Transform:SetSixFaced()
        end

        if scale ~= nil then
            inst.Transform:SetScale(scale, scale, scale)
        end

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(BUILDS[creature].default)
        inst.AnimState:PlayAnimation("corpse")
		inst.AnimState:SetFinalOffset(1)

		if data.tag ~= nil then
			inst:AddTag(data.tag)
		end

        inst.creature = creature
        inst.nameoverride = nameoverride
        inst.displaynamefn = DisplayNameFn

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.mutantprefab = mutantprefab

        inst.StartMutation = StartMutation
        inst.SpawnGestalt = SpawnGestalt
        inst.SetAltBuild = SetAltBuild

        inst:AddComponent("entitytracker")

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus

		data.makeburnablefn(inst, TUNING.MED_BURNTIME, data.firesymbol)

        inst.components.burnable:SetOnIgniteFn(OnIgnited)
        inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

        inst:SetStateGraph(data.sg)

        -- One time spawn!
        if not POPULATING then
            inst:DoTaskInTime(0, inst.SpawnGestalt)
        end

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        inst.OnEntitySleep = inst.Remove

        MakeHauntableIgnite(inst)

        return inst
    end

    return Prefab(prefabname, fn, nil, prefabs)
end

--------------------------------------------------------------------------------------------------------

local function MakeCreatureCorpse_Prop(data)
    local creature = data.creature
    local nameoverride = data.nameoverride

    local prefabname = creature.."corpse_prop"

    local scale = data.scale
    local faces = data.faces

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst.DynamicShadow:SetSize(unpack(data.shadowsize))

        if faces == FACES.FOUR then
            inst.Transform:SetFourFaced()
        elseif faces == FACES.SIX then
            inst.Transform:SetSixFaced()
        end

        if scale ~= nil then
            inst.Transform:SetScale(scale, scale, scale)
        end

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(BUILDS[creature].default)
        inst.AnimState:PlayAnimation("corpse")

		if data.tag ~= nil then
			inst:AddTag(data.tag)
		end

        inst.creature = creature
        inst.nameoverride = nameoverride
        inst.displaynamefn = DisplayNameFn

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

		if data.onrevealfn ~= nil then
			inst:ListenForEvent("propreveal", data.onrevealfn)
		end

        inst.SetAltBuild = SetAltBuild
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        return inst
    end

    return Prefab(prefabname, fn)
end

return
        -- For search: deerclopscorpse
        MakeCreatureCorpse({
            creature = "deerclops",
            bank = "deerclops",
            sg = "SGdeerclops",
			firesymbol = "swap_fire",
			makeburnablefn = MakeLargeBurnableCorpse,
            faces = FACES.FOUR,
            physicsradius = .5,
            shadowsize = {6, 3.5},
            scale = 1.65,
			tag = "deerclops",
        }),

        -- For search: wargcorpse
        MakeCreatureCorpse({
            creature = "warg",
            bank = "warg",
            sg = "SGwarg",
            firesymbol = "swap_fire",
			makeburnablefn = MakeLargeBurnableCorpse,
            faces = FACES.SIX,
            physicsradius = 1,
            shadowsize = {2.5, 1.5},
        }),

        -- For search: beargercorpse
        MakeCreatureCorpse({
            creature = "bearger",
            bank = "bearger",
            sg = "SGbearger",
            firesymbol = "swap_fire",
			makeburnablefn = MakeLargeBurnableCorpse,
            faces = FACES.FOUR,
            physicsradius = 1.5,
            shadowsize = {6, 3.5},
			tag = "bearger_blocker",
        }),

        -- For search: koalefantcorpse_prop
        MakeCreatureCorpse_Prop({
            creature = "koalefant",
            bank = "koalefant",
            nameoverride = "koalefant_summer",
            faces = FACES.SIX,
            shadowsize = {4.5, 2},
			onrevealfn = function(inst, revealer)
				inst.persists = false
				inst:AddTag("NOCLICK")
				inst:ListenForEvent("animover", inst.Remove)
				inst.AnimState:PlayAnimation("carcass_fake")
			end,
        })

