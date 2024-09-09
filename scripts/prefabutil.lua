function MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale, fixedcameraoffset, facing, postinit_fn, offset, onfailedplacement)
    local function fn()
        local inst = CreateEntity()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        if anim then
            inst.AnimState:SetBank(bank)
            inst.AnimState:SetBuild(build)
            inst.AnimState:PlayAnimation(anim, true)
            inst.AnimState:SetLightOverride(1)
        end

        if facing == "two" then
            inst.Transform:SetTwoFaced()
        elseif facing == "four" then
            inst.Transform:SetFourFaced()
        elseif facing == "six" then
            inst.Transform:SetSixFaced()
        elseif facing == "eight" then
            inst.Transform:SetEightFaced()
        end

        local placer = inst:AddComponent("placer")
        placer.snaptogrid = snap
        placer.snap_to_meters = metersnap
        placer.fixedcameraoffset = fixedcameraoffset
        placer.onground = onground

        -- If the user clicks when the placement is invalid this gets called
        placer.onfailedplacement = onfailedplacement

        if offset ~= nil then
            inst.components.placer.offset = offset
        end

        if scale ~= nil and scale ~= 1 then
            inst.Transform:SetScale(scale, scale, scale)
        end

        if onground then
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        end

        if postinit_fn then
            postinit_fn(inst)
        end

        return inst
    end

    return Prefab(name, fn)
end

local function deployablekititem_ondeploy(inst, pt, deployer, rot)
    local structure = SpawnPrefab(inst._prefab_to_deploy, inst.linked_skinname, inst.skin_id )
    if structure ~= nil then
        structure.Transform:SetPosition(pt:Get())
		structure:PushEvent("onbuilt", { builder = deployer, pos = pt, rot = rot, deployable = inst })
        inst:Remove()
    end
end

function MakeDeployableKitItem(name, prefab_to_deploy, bank, build, anim, assets, floatable_data, tags, burnable, deployable_data, stack_size, PostMasterSimfn)
	deployable_data = deployable_data or {}

	return Prefab(name, function(inst)
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build or bank)
		inst.AnimState:PlayAnimation(anim or "idle")

		if floatable_data then
		    MakeInventoryFloatable(inst, floatable_data.size, floatable_data.y_offset, floatable_data.scale)
		end

		if tags then
			for _, tag in pairs(tags) do
				inst:AddTag(tag)
			end
        end
        inst:AddTag("deploykititem")

        if deployable_data.custom_candeploy_fn then
            inst._custom_candeploy_fn = deployable_data.custom_candeploy_fn
        end
        if deployable_data.usedeployspacingasoffset then
            inst:AddTag("usedeployspacingasoffset")
        end

		if deployable_data.common_postinit then
			deployable_data.common_postinit(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		if burnable then
			MakeSmallBurnable(inst)
			MakeSmallPropagator(inst)
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		if not floatable_data then
			inst.components.inventoryitem:SetSinks(true)
		end

		if stack_size then
			inst:AddComponent("stackable")
			inst.components.stackable.maxsize = stack_size
		end

		inst._prefab_to_deploy = prefab_to_deploy
		local deployable = inst:AddComponent("deployable")
		deployable.ondeploy = deployablekititem_ondeploy
        if deployable_data.deploymode then
            deployable:SetDeployMode(deployable_data.deploymode)
        end
        if deployable_data.deployspacing then
			deployable:SetDeploySpacing(deployable_data.deployspacing)
		end

		deployable.restrictedtag = deployable_data.restrictedtag
		deployable:SetUseGridPlacer(deployable_data.usegridplacer)

		if deployable_data.deploytoss_symbol_override then
			deployable:SetDeployTossSymbolOverride(deployable_data.deploytoss_symbol_override)
		end

		if burnable and burnable.fuelvalue then
			inst:AddComponent("fuel")
			inst.components.fuel.fuelvalue = burnable.fuelvalue
		end

        if deployable_data.master_postinit then
            deployable_data.master_postinit(inst)
        end

		MakeHauntableLaunch(inst)

        if PostMasterSimfn then
            PostMasterSimfn(inst)
        end

		inst.OnSave = deployable_data.OnSave
		inst.OnLoad = deployable_data.OnLoad

		return inst
	end,
	assets,
	{prefab_to_deploy})
end
