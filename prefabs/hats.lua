local function MakeHat(name)
    local fname = "hat_"..name
    local symname = name.."hat"
    local prefabname = symname

    --If you want to use generic_perish to do more, it's still
    --commented in all the relevant places below in this file.
    --[[local function generic_perish(inst)
        inst:Remove()
    end]]

    local function onequip(inst, owner, symbol_override)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, symbol_override or "swap_hat")
        end
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function opentop_onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)

        MakeHauntableLaunch(inst)

        return inst
    end

    local function straw_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function straw()
        local inst = simple(straw_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.STRAWHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        return inst
    end

    local function default()
        return simple()
    end

    local function bee_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function bee()
        local inst = simple(bee_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.73)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
        inst.components.armor:SetTags({ "bee" })

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function earmuffs_custom_init(inst)
        inst:AddTag("open_top_hat")

        inst.AnimState:SetRayTestOnBB(true)
    end

    local function earmuffs()
        local inst = simple(earmuffs_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
        inst.components.equippable:SetOnEquip(opentop_onequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.EARMUFF_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function winter()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WINTERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function football_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function football()
        local inst = simple(football_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function ruinshat_fxanim(inst)
        inst._fx.AnimState:PlayAnimation("hit")
        inst._fx.AnimState:PushAnimation("idle_loop")
    end

    local function ruinshat_oncooldown(inst)
        inst._task = nil
    end

    local function ruinshat_unproc(inst)
        if inst:HasTag("forcefield") then
            inst:RemoveTag("forcefield")
            if inst._fx ~= nil then
                inst._fx:kill_fx()
                inst._fx = nil
            end
            inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)

            inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
            inst.components.armor.ontakedamage = nil

            if inst._task ~= nil then
                inst._task:Cancel()
            end
            inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, ruinshat_oncooldown)
        end
    end

    local function ruinshat_proc(inst, owner)
        inst:AddTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
        end
        inst._fx = SpawnPrefab("forcefieldfx")
        inst._fx.entity:SetParent(owner.entity)
        inst._fx.Transform:SetPosition(0, 0.2, 0)
        inst:ListenForEvent("armordamaged", ruinshat_fxanim)

        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner ~= nil and owner.components.sanity ~= nil then
                owner.components.sanity:DoDelta(-damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY, false)
            end
        end

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, ruinshat_unproc)
    end

    local function tryproc(inst, owner, data)
        if inst._task == nil and
            not data.redirected and
            math.random() < TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
            ruinshat_proc(inst, owner)
        end
    end

    local function ruins_onunequip(inst, owner)
        onunequip(inst, owner)
        inst.ondetach()
    end

    local function ruins_onequip(inst, owner)
        opentop_onequip(inst, owner)
        inst.onattach(owner)
    end

    local function ruins_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("metal")
    end

    local function ruins_onremove(inst)
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
    end

    local function ruins()
        local inst = simple(ruins_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT, TUNING.ARMOR_RUINSHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(ruins_onequip)
        inst.components.equippable:SetOnUnequip(ruins_onunequip)

        MakeHauntableLaunch(inst)

        inst.OnRemoveEntity = ruins_onremove

        inst._fx = nil
        inst._task = nil
        inst._owner = nil
        inst.procfn = function(owner, data) tryproc(inst, owner, data) end
        inst.onattach = function(owner)
            if inst._owner ~= nil then
                inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
                inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            end
            inst:ListenForEvent("attacked", inst.procfn, owner)
            inst:ListenForEvent("onremove", inst.ondetach, owner)
            inst._owner = owner
            inst._fx = nil
        end
        inst.ondetach = function()
            ruinshat_unproc(inst)
            if inst._owner ~= nil then
                inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
                inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
                inst._owner = nil
                inst._fx = nil
            end
        end

        return inst
    end

    local function feather_equip(inst, owner)
        onequip(inst, owner)
        local attractor = owner.components.birdattractor
        if attractor then
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_MAXDELTA_FEATHERHAT, "maxbirds")
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MIN, "mindelay")
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MAX, "maxdelay")
            
            local birdspawner = TheWorld.components.birdspawner
            if birdspawner ~= nil then
                birdspawner:ToggleUpdate(true)
            end
        end
    end

    local function feather_unequip(inst, owner)
        onunequip(inst, owner)

        local attractor = owner.components.birdattractor
        if attractor then
            attractor.spawnmodifier:RemoveModifier(inst)

            local birdspawner = TheWorld.components.birdspawner
            if birdspawner ~= nil then
                birdspawner:ToggleUpdate(true)
            end
        end
    end

    local function feather()
        local inst = simple()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
        inst.components.equippable:SetOnEquip(feather_equip)
        inst.components.equippable:SetOnUnequip(feather_unequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.FEATHERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function beefalo_equip(inst, owner)
        onequip(inst, owner)
        owner:AddTag("beefalo")
    end

    local function beefalo_unequip(inst, owner)
        onunequip(inst, owner)
        owner:RemoveTag("beefalo")
    end

    local function beefalo_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function beefalo()
        local inst = simple(beefalo_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(beefalo_equip)
        inst.components.equippable:SetOnUnequip(beefalo_unequip)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
 
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function walrus()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.63)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function miner_turnon(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if not inst.components.fueled:IsEmpty() then
            if inst._light == nil or not inst._light:IsValid() then
                inst._light = SpawnPrefab("minerhatlight")
            end
            if owner ~= nil then
                onequip(inst, owner)
                inst._light.entity:SetParent(owner.entity)
            end
            inst.components.fueled:StartConsuming()
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")
        elseif owner ~= nil then
            onequip(inst, owner, "swap_hat_off")
        end
    end

    local function miner_turnoff(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            onequip(inst, owner, "swap_hat_off")
        end
        inst.components.fueled:StopConsuming()
        if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatOut")
        end
    end

    local function miner_unequip(inst, owner)
        onunequip(inst, owner)
        miner_turnoff(inst)
    end

    local function miner_perish(inst)
        local equippable = inst.components.equippable
        if equippable ~= nil and equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                }
                miner_turnoff(inst)
                owner:PushEvent("torchranout", data)
                return
            end
        end
        miner_turnoff(inst)
    end

    local function miner_takefuel(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            miner_turnon(inst)
        end
    end

    local function miner_custom_init(inst)
        inst.entity:AddSoundEmitter()
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function miner_onremove(inst)
        if inst._light ~= nil and inst._light:IsValid() then
            inst._light:Remove()
        end
    end

    local function miner()
        local inst = simple(miner_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:SetOnDroppedFn(miner_turnoff)
        inst.components.equippable:SetOnEquip(miner_turnon)
        inst.components.equippable:SetOnUnequip(miner_unequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.CAVE
        inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
        inst.components.fueled:SetDepletedFn(miner_perish)
        inst.components.fueled:SetTakeFuelFn(miner_takefuel)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst._light = nil
        inst.OnRemoveEntity = miner_onremove

        return inst
    end

    local function spider_disable(inst)
        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = nil
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            if not owner:HasTag("spiderwhisperer") then
                if not owner:HasTag("playermonster") then
                    owner:RemoveTag("monster")
                end
                owner:RemoveTag("spiderdisguise")

                for k,v in pairs(owner.components.leader.followers) do
                    if k:HasTag("spider") and k.components.combat then
                        k.components.combat:SuggestTarget(owner)
                    end
                end
                owner.components.leader:RemoveFollowersByTag("spider")
            else
                owner.components.leader:RemoveFollowersByTag("spider", function(follower)
                    if follower and follower.components.follower then
                        if follower.components.follower:GetLoyaltyPercent() > 0 then
                            return false
                        else
                            return true
                        end
                    end
                end)
            end

        end
    end

    local function spider_update(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            local x,y,z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE, {"spider"})
            for k,v in pairs(ents) do
                if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                    owner.components.leader:AddFollower(v)
                end
            end
        end
    end

    local function spider_enable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            owner:AddTag("monster")
            owner:AddTag("spiderdisguise")
        end
        inst.updatetask = inst:DoPeriodicTask(0.5, spider_update, 1)
    end

    local function spider_equip(inst, owner)
        onequip(inst, owner)
        spider_enable(inst)
    end

    local function spider_unequip(inst, owner)
        onunequip(inst, owner)
        spider_disable(inst)
    end

    local function spider_perish(inst)
        spider_disable(inst)
        inst:Remove()--generic_perish(inst)
    end

    local function spider_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function spider()
        local inst = simple(spider_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.62)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:SetOnDroppedFn(spider_disable)

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL
        inst.components.equippable:SetOnEquip(spider_equip)
        inst.components.equippable:SetOnUnequip(spider_unequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(spider_perish)
        inst.components.fueled.no_sewing = true

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function top_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function top()
        local inst = simple(top_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function stopusingbush(inst, data)
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat ~= nil and data.statename ~= "hide" then
            hat.components.useableitem:StopUsingItem()
        end
    end

    local function bush_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        inst:ListenForEvent("newstate", stopusingbush, owner)
    end

    local function bush_onunequip(inst, owner)
        owner.AnimState:ClearOverrideSymbol("swap_hat")

        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()        
        end

        inst:RemoveEventCallback("newstate", stopusingbush, owner)
    end

    local function bush_onuse(inst)
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.sg:GoToState("hide")
        end
    end

    local function bush_custom_init(inst)
        inst:AddTag("hide")
    end

    local function bush()
        local inst = simple(bush_custom_init)

        inst.foleysound = "dontstarve/movement/foley/bushhat"

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(bush_onuse)

        inst.components.equippable:SetOnEquip(bush_onequip)
        inst.components.equippable:SetOnUnequip(bush_onunequip)

        return inst
    end

    local function flower_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("show_spoilage")
    end

    local function flower()
        local inst = simple(flower_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst.components.equippable:SetOnEquip(opentop_onequip)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function kelp_custom_init(inst)
        inst:AddTag("show_spoilage")
    end

    local function kelp()
        local inst = simple(kelp_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_TINY
        inst.components.equippable:SetOnEquip(opentop_onequip)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function slurtle_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function slurtle_equip(inst, owner)
        onequip(inst, owner)

        -- check for the armor_snurtleshell pairing achievement
        if owner:HasTag("player") then
			local equipped_body = owner.components.inventory ~= nil and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
			if equipped_body ~= nil and equipped_body.prefab == "armorsnurtleshell" then
				AwardPlayerAchievement("snail_armour_set", owner)
			end
		end

    end

    local function slurtle()
        local inst = simple(slurtle_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SLURTLEHAT, TUNING.ARMOR_SLURTLEHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable:SetOnEquip( slurtle_equip )

        return inst
    end

    local function rain_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function rain()
        local inst = simple(rain_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.RAINHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst.components.equippable.insulated = true

        return inst
    end

    local function eyebrella_onequip(inst, owner) 
        opentop_onequip(inst, owner)

        owner.DynamicShadow:SetSize(2.2, 1.4)
    end

    local function eyebrella_onunequip(inst, owner) 
        onunequip(inst, owner)

        owner.DynamicShadow:SetSize(1.3, 0.6)
    end

    local function eyebrella_perish(inst)
        local equippable = inst.components.equippable
        if equippable ~= nil and equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                owner.DynamicShadow:SetSize(1.3, 0.6)
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                }
                inst:Remove()--generic_perish(inst)
                owner:PushEvent("umbrellaranout", data)
                return
            end
        end
        inst:Remove()--generic_perish(inst)
    end

    local function eyebrella_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("umbrella")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function eyebrella()
        local inst = simple(eyebrella_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.95)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.EYEBRELLA_PERISHTIME)
        inst.components.fueled:SetDepletedFn(eyebrella_perish)

        inst.components.equippable:SetOnEquip(eyebrella_onequip)
        inst.components.equippable:SetOnUnequip(eyebrella_onunequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true

        return inst
    end

    local function wathgrithr_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function wathgrithr()
        local inst = simple(wathgrithr_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function ice_custom_init(inst)
        inst:AddTag("show_spoilage")
        inst:AddTag("frozen")
        inst:AddTag("icebox_valid")

        --HASHEATER (from heater component) added to pristine state for optimization
        inst:AddTag("HASHEATER")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function ice()
        local inst = simple(ice_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.66)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heater")
        inst.components.heater:SetThermics(false, true)
        inst.components.heater.equippedheat = TUNING.ICEHAT_COOLER

        inst.components.equippable.walkspeedmult = 0.9
        inst.components.equippable.equippedmoisture = 1
        inst.components.equippable.maxequippedmoisture = 49 -- Meter reading rounds up, so set 1 below

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst:AddComponent("waterproofer")
        inst.components.waterproofer.effectiveness = 0

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(function(inst)
            local owner = inst.components.inventoryitem.owner
            if owner ~= nil then
                if owner.components.moisture ~= nil then
                    owner.components.moisture:DoDelta(30)
                elseif owner.components.inventoryitem ~= nil then
                    owner.components.inventoryitem:AddMoisture(50)
                end
            end
            inst:Remove()--generic_perish(inst)
        end)

        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.ICE
        inst.components.repairable.announcecanfix = false

        return inst
    end

    local function catcoon()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.63)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.CATCOONHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        return inst
    end

    local function watermelon_custom_init(inst)
        inst:AddTag("show_spoilage")
        inst:AddTag("icebox_valid")

        --HASHEATER (from heater component) added to pristine state for optimization
        inst:AddTag("HASHEATER")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function watermelon()
        local inst = simple(watermelon_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heater")
        inst.components.heater:SetThermics(false, true)
        inst.components.heater.equippedheat = TUNING.WATERMELON_COOLER

        inst.components.equippable.equippedmoisture = 0.5
        inst.components.equippable.maxequippedmoisture = 32 -- Meter reading rounds up, so set 1 below

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        inst.components.insulator:SetSummer()

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL

        inst.components.floater:SetVerticalOffset(0.1)

        return inst
    end

    local function mole_turnon(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
    end

    local function mole_turnoff(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
    end

    local function mole_onequip(inst, owner)
        onequip(inst, owner)
        mole_turnon(owner)
    end

    local function mole_onunequip(inst, owner)
        onunequip(inst, owner)
        mole_turnoff(owner)
    end

    local function mole_perish(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                mole_turnoff(owner)
            end
        end
        inst:Remove()--generic_perish(inst)
    end

    local function mole_custom_init(inst)
        inst:AddTag("nightvision")
    end

    local function mole()
        local inst = simple(mole_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(mole_onequip)
        inst.components.equippable:SetOnUnequip(mole_onunequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.WORMLIGHT
        inst.components.fueled:InitializeFuelLevel(TUNING.MOLEHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(mole_perish)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true

        return inst
    end

    local function mushroom_onequip(inst, owner)
        onequip(inst, owner)
        owner:AddTag("spoiler")

        inst.components.periodicspawner:Start()

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.MUSHROOMHAT_SLOW_HUNGER)
        end

    end

    local function mushroom_onunequip(inst, owner)
        onunequip(inst, owner)
        owner:RemoveTag("spoiler")

        inst.components.periodicspawner:Stop()

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
    end

    local function mushroom_displaynamefn(inst)
        return STRINGS.NAMES[string.upper(inst.prefab)]
    end

    local function mushroom_custom_init(inst)
        inst:AddTag("show_spoilage")

        --Use common inspect strings, but unique display names
        inst:SetPrefabNameOverride("mushroomhat")
        inst.displaynamefn = mushroom_displaynamefn

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function common_mushroom(spore_prefab)
        local inst = simple(mushroom_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(mushroom_onequip)
        inst.components.equippable:SetOnUnequip(mushroom_onunequip)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        inst:AddComponent("periodicspawner")
        inst.components.periodicspawner:SetPrefab(spore_prefab)
        inst.components.periodicspawner:SetRandomTimes(TUNING.MUSHROOMHAT_SPORE_TIME, 1, true)
        --inst.components.periodicspawner:SetOnSpawnFn(onspawnfn) -- maybe we should add a spawn animation to the hat?

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function red_mushroom()
        local inst = common_mushroom("spore_medium")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.95)

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    local function green_mushroom()
        local inst = common_mushroom("spore_small")

        inst.components.floater:SetSize("med")

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    local function blue_mushroom()
        local inst = common_mushroom("spore_tall")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.7)

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    local function hive_onunequip(inst, owner)
        onunequip(inst, owner)

        if owner ~= nil and owner.components.sanity ~= nil then
            owner.components.sanity.neg_aura_absorb = 0
        end
    end

    local function hive_onequip(inst, owner)
        onequip(inst, owner)

        if owner ~= nil and owner.components.sanity ~= nil then
            owner.components.sanity.neg_aura_absorb = TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION
        end
    end

    local function hive_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("regal")
    end

    local function hive()
        local inst = simple(hive_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.8)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_HIVEHAT, TUNING.ARMOR_HIVEHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable:SetOnEquip(hive_onequip)
        inst.components.equippable:SetOnUnequip(hive_onunequip)

        return inst
    end

    local function dragon_countpieces(node, dancers, pieces, count)
        local nodes = {}
        for i = #dancers, 1, -1 do
            local dancer = dancers[i]
            if dancer:IsNear(node, 2) then
                table.remove(dancers, i)
                local piece =
                    (dancer.sg:HasStateTag("dragonhead") and "head") or
                    (dancer.sg:HasStateTag("dragonbody") and "body") or
                    (dancer.sg:HasStateTag("dragontail") and "tail") or
                    nil
                if piece ~= nil then
                    if not pieces[piece] then
                        count = count + 1
                        if count >= 3 then
                            return count
                        end
                        pieces[piece] = true
                    end
                    table.insert(nodes, dancer)
                end
            end
        end
        for i, v in ipairs(nodes) do
            count = dragon_countpieces(v, dancers, pieces, count)
            if count >= 3 then
                return count
            end
        end
        return count
    end

    local function dragon_ondancing(inst)
        local pieces = {}
        local dancers = {}
        for i, v in ipairs(AllPlayers) do
            if v.sg:HasStateTag("dragondance") then
                table.insert(dancers, v)
            end
        end
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE * dragon_countpieces(inst, dancers, pieces, 0)
    end

    local function dragon_startdancing(inst, doer, data)
        if not (doer.components.rider ~= nil and doer.components.rider:IsRiding()) then
            if inst.dancetask == nil then
                inst.dancetask = inst:DoPeriodicTask(1, dragon_ondancing)
            end
            inst.components.fueled:StartConsuming()
            return {
                anim = inst.prefab == "dragonheadhat" and
                    { "hatdance2_pre", "hatdance2_loop" } or
                    { "hatdance_pre", "hatdance_loop" },
                loop = true,
                fx = false,
                tags = { "nodangle", "dragondance", string.sub(inst.prefab, 1, -4) },
            }
        end
    end

    local function dragon_stopdancing(inst, doer)
        inst.components.fueled:StopConsuming()
        inst.components.equippable.dapperness = 0
        if inst.dancetask ~= nil then
            inst.dancetask:Cancel()
            inst.dancetask = nil
        end
    end

    local function dragon_equip(inst, owner)
        onequip(inst, owner)
        dragon_stopdancing(inst, owner)
    end

    local function dragon_unequip(inst, owner)
        onunequip(inst, owner)
        dragon_stopdancing(inst, owner)
        if owner.sg ~= nil and owner.sg:HasStateTag("dragondance") then
            owner.sg:GoToState("idle")
        end
    end

    local function dragon()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.DRAGONHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        inst.components.equippable:SetOnEquip(dragon_equip)
        inst.components.equippable:SetOnUnequip(dragon_unequip)

        inst.OnStartDancing = dragon_startdancing
        inst.OnStopDancing = dragon_stopdancing

        return inst
    end

    local function desert_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("goggles")
    end

    local function desert()
        local inst = simple(desert_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    --NOTE: goggleshat do NOT provide "goggles" tag benefits because you do not
    --      actually wear them over your eyes, and they're just for style -_ -"
    local function goggles_custom_init(inst)
        inst:AddTag("open_top_hat")
    end

    local function goggles()
        local inst = simple(goggles_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
        inst.components.equippable:SetOnEquip(opentop_onequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        return inst
    end

    local function skeleton_onequip(inst, owner)
        onequip(inst, owner)
        if owner.components.sanity ~= nil then
            owner.components.sanity:SetInducedInsanity(inst, true)
        end
    end

    local function skeleton_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner.components.sanity ~= nil then
            owner.components.sanity:SetInducedInsanity(inst, false)
        end
    end

    local function skeleton_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("shadowdominance")
    end

    local function skeleton()
        local inst = simple(skeleton_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
        inst.components.equippable:SetOnEquip(skeleton_onequip)
        inst.components.equippable:SetOnUnequip(skeleton_onunequip)

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SKELETONHAT, TUNING.ARMOR_SKELETONHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local fn = nil
    local assets = { Asset("ANIM", "anim/"..fname..".zip") }
    local prefabs = nil

    if name == "bee" then
        fn = bee
    elseif name == "straw" then
        fn = straw
    elseif name == "top" then
        fn = top
    elseif name == "feather" then
        fn = feather
    elseif name == "football" then
        fn = football
    elseif name == "flower" then
        fn = flower
    elseif name == "spider" then
        fn = spider
    elseif name == "miner" then
        fn = miner
        prefabs = { "minerhatlight" }
    elseif name == "earmuffs" then
        fn = earmuffs
    elseif name == "winter" then
        fn = winter
    elseif name == "beefalo" then
        fn = beefalo
    elseif name == "bush" then
        fn = bush
    elseif name == "walrus" then
        fn = walrus
    elseif name == "slurtle" then
        fn = slurtle
    elseif name == "ruins" then
        fn = ruins
        prefabs = { "forcefieldfx" }
    elseif name == "mole" then
        fn = mole
    elseif name == "wathgrithr" then
        fn = wathgrithr
    elseif name == "ice" then
        fn = ice
    elseif name == "rain" then
        fn = rain
    elseif name == "catcoon" then
        fn = catcoon
    elseif name == "watermelon" then
        fn = watermelon
    elseif name == "eyebrella" then 
        fn = eyebrella
    elseif name == "red_mushroom" then
        fn = red_mushroom
    elseif name == "green_mushroom" then
        fn = green_mushroom
    elseif name == "blue_mushroom" then
        fn = blue_mushroom
    elseif name == "hive" then
        fn = hive
    elseif name == "dragonhead" then
        fn = dragon
    elseif name == "dragonbody" then
        fn = dragon
    elseif name == "dragontail" then
        fn = dragon
    elseif name == "desert" then
        fn = desert
    elseif name == "goggles" then
        fn = goggles
    elseif name == "skeleton" then
        fn = skeleton
    elseif name == "kelp" then
        fn = kelp
    end

    return Prefab(prefabname, fn or default, assets, prefabs)
end

local function minerhatlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return  MakeHat("straw"),
        MakeHat("top"),
        MakeHat("beefalo"),
        MakeHat("feather"),
        MakeHat("bee"),
        MakeHat("miner"),
        MakeHat("spider"),
        MakeHat("football"),
        MakeHat("earmuffs"),
        MakeHat("winter"),
        MakeHat("bush"),
        MakeHat("flower"),
        MakeHat("walrus"),
        MakeHat("slurtle"),
        MakeHat("ruins"),
        MakeHat("mole"),
        MakeHat("wathgrithr"),
        MakeHat("ice"),
        MakeHat("rain"),
        MakeHat("catcoon"),
        MakeHat("watermelon"),
        MakeHat("eyebrella"),
        MakeHat("red_mushroom"),
        MakeHat("green_mushroom"),
        MakeHat("blue_mushroom"),
        MakeHat("hive"),
        MakeHat("dragonhead"),
        MakeHat("dragonbody"),
        MakeHat("dragontail"),
        MakeHat("desert"),
        MakeHat("goggles"),
        MakeHat("skeleton"),
        MakeHat("kelp"),
        Prefab("minerhatlight", minerhatlightfn)
