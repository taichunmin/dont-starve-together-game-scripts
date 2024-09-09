local assets = {
    Asset("ANIM", "anim/bootleg.zip"),
    Asset("ANIM", "anim/swap_bootleg.zip"),
    Asset("INV_IMAGE", "bootleg"),
}
local prefabs = {
    "oceanwhirlportal",
    "dirt_puff",
}

local function CreateOceanWhirlportal(inst, enter_pt, exit_pt)
    local enter = SpawnPrefab("oceanwhirlportal")
    enter.Transform:SetPosition(enter_pt:Get())

    local exit = SpawnPrefab("oceanwhirlportal")
    exit.Transform:SetPosition(exit_pt:Get())

    -- NOTES(JBK): The enter goes to exit and the exit goes to enter as a two way teleport system.
    enter:SetExit(exit)
    exit:SetExit(enter)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bootleg", "swap_bootleg")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onthrown(inst, attacker, targetpos)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.WORLD)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)

    inst._oceanwhirlportal_spawnpos = Vector3(targetpos.x, 0, targetpos.z)
end

local function onhit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()
    if not TheWorld.Map:IsOceanAtPoint(x, y, z) then
        inst:RemoveTag("NOCLICK")
        inst.persists = true
        MakeInventoryPhysics(inst)
        inst.AnimState:PlayAnimation("idle")
        inst._oceanwhirlportal_spawnpos = nil
        inst.SoundEmitter:PlaySound("dontstarve/common/together/infection_burst")
        SpawnPrefab("dirt_puff").Transform:SetPosition(x, y, z)
        return
    end
    inst:CreateOceanWhirlportal(Vector3(x, 0, z), inst._oceanwhirlportal_spawnpos)
    inst.Physics:Teleport(x, 0, z)
    inst.persists = false
    inst.AnimState:PlayAnimation("used")
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/submerge/large")
    inst:ListenForEvent("animqueueover", inst.Remove)
end

local function CanTossOnMap(_, doer)
    local platform = doer:GetCurrentPlatform()
    return (platform ~= nil and platform:HasTag("boat"))
end

local function InitMapDecorations(inst) -- NOTES(JBK): This is used in mapscreen and has access to minimap icons.
    return {
        {
            atlas = GetInventoryItemAtlas("bootleg.tex"),
            image = "bootleg.tex",
            scale = 0.75,
        },
        {
            atlas = GetMinimapAtlas("oceanwhirlportal.png"),
            image = "oceanwhirlportal.png",
            --scale = 1.0,
        },
    }
end

local function CalculateMapDecorations(inst, rmbents, px, pz, rmbx, rmbz)
    local dx, dz = rmbx - px, rmbz - pz
    if dx == 0 and dz == 0 then
        dx = 1
    end

    local dist = math.sqrt(dx * dx + dz * dz)

    rmbents[1].worldx = dx * (ACTIONS.TOSS.distance / dist) + px
    rmbents[1].worldz = dz * (ACTIONS.TOSS.distance / dist) + pz

    rmbents[2].worldx = dx + px
    rmbents[2].worldz = dz + pz
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bootleg")
    inst.AnimState:SetBuild("bootleg")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", nil, 0.62)

    inst:AddTag("allow_action_on_impassable") -- Allow on ocean.
    inst:AddTag("complexprojectile_showoceanaction") -- Show action TOSS on ocean.
    inst:AddTag("action_pulls_up_map") -- Make the non-map action pull up the map instead.
    inst.map_remap_min_dist = ACTIONS.TOSS.distance + TUNING.OCEANWHIRLPORTAL_BOAT_INTERACT_DISTANCE * 2
    inst.CanTossInWorld = CanTossOnMap
    inst.CanTossOnMap = CanTossOnMap
    inst.InitMapDecorations = InitMapDecorations
    inst.CalculateMapDecorations = CalculateMapDecorations
    inst.valid_map_actions = {
        [ACTIONS.TOSS] = true,
    }

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.CreateOceanWhirlportal = CreateOceanWhirlportal

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    local equippable = inst:AddComponent("equippable")
    equippable:SetOnEquip(onequip)
    equippable:SetOnUnequip(onunequip)

    local stackable = inst:AddComponent("stackable")
    stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    -- NOTES(JBK): The component oceanthrowable looks unfinished at this time so I am repurposing the TOSS action.
    local complexprojectile = inst:AddComponent("complexprojectile")
    complexprojectile:SetHorizontalSpeed(15)
    complexprojectile:SetGravity(-35)
    complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    complexprojectile:SetOnLaunch(onthrown)
    complexprojectile:SetOnHit(onhit)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bootleg", fn, assets, prefabs)
	--[[MakeDeployableKitItem("bootleg", "oceanwhirlportal", "bootleg", "bootleg", "idle", assets,
		{ size = "med", scale = 0.62 }, --floatable_data
		nil,--{ "action_pulls_up_map" },
		nil,
		{
			deploymode = DEPLOYMODE.WATER,
			deployspacing = DEPLOYSPACING.LESS, --#TODO
			deploytoss_symbol_override = { build = "swap_bootleg", symbol = "swap_bootleg" },
			common_postinit = function(inst)
				inst.entity:AddSoundEmitter()

				inst.map_remap_min_dist = ACTIONS.TOSS.distance + TUNING.OCEANWHIRLPORTAL_BOAT_INTERACT_DISTANCE * 2
				--inst.CanTossInWorld = CanTossOnMap
				inst.CanTossOnMap = CanTossOnMap
				inst.InitMapDecorations = InitMapDecorations
				inst.CalculateMapDecorations = CalculateMapDecorations
			end,
			master_postinit = function(inst)
				inst.CreateOceanWhirlportal = CreateOceanWhirlportal

				local complexprojectile = inst:AddComponent("complexprojectile")
				complexprojectile:SetHorizontalSpeed(15)
				complexprojectile:SetGravity(-35)
				complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
				complexprojectile:SetOnLaunch(onthrown)
				complexprojectile:SetOnHit(onhit)
			end,
		}
	),
	MakePlacer("bootleg_placer", "bootleg", "bootleg", "idle", nil, nil, nil, nil, nil, nil, nil, 6)
	]]
