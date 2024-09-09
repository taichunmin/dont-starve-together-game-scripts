local assets =
{
    Asset("ANIM", "anim/shadow_creatures_ground.zip"),
}

local prefabs =
{
    "enable_shadow_rift_construction_container",
}

----------------------------------------------------------------------------

-- Locomotion functions

local function ShowUp(inst, walkspeed)
    inst.AnimState:PushAnimation("hand_in_loop", true)
    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    inst.components.locomotor.walkspeed = walkspeed or 2

    inst.SoundEmitter:PlaySound("rifts2/charlie/charlie_hand_arrive")

    inst:RemoveTag("NOCLICK")

    local showup_pos = inst.components.knownlocations:GetLocation("showup")
    inst.components.locomotor:PushAction(BufferedAction(inst, nil, ACTIONS.WALKTO, nil, showup_pos))
end

local function RunAway(inst, walkspeed)
    if not inst.arm then return end

    inst:AddTag("NOCLICK")

    if not walkspeed then
        inst.SoundEmitter:PlaySound("rifts2/charlie/charlie_hand_decline")
    end

    inst.components.locomotor:Stop()
    inst.components.locomotor:Clear()
    inst.components.locomotor.walkspeed = walkspeed or -8
    inst.components.locomotor:PushAction(BufferedAction(inst, inst.arm, ACTIONS.GOHOME, nil, inst.arm:GetPosition()))
end

----------------------------------------------------------------------------

-- Event Listening functions

local function HandleAction(inst, data)
    if data.action ~= nil and data.action.action == ACTIONS.GOHOME then
        inst.AnimState:PlayAnimation("hand_in_loop", true)

        if not inst.persists then
            inst:Remove()
        end
    end
end

local function OnAtriumPowered(inst, ispowered)
    if ispowered then
        inst.AnimState:PlayAnimation("scared_loop", true)
        inst:RunAway()
    else
        inst:ShowUp()
    end
end

----------------------------------------------------------------------------

-- Construction site functions

local function OnGetMaterials(inst)
    inst.AnimState:PlayAnimation("grab")
    inst.AnimState:PushAnimation("grab_pst")
    
    inst.persists = false

    inst.SoundEmitter:PlaySound("rifts2/charlie/charlie_hand_accept")

    inst:RunAway(-3)
end

local function StartCutScene(atrium)
    atrium.components.charliecutscene:Start()
end

local function ConstructionSite_OnConstructed(inst, doer)
    if inst.components.constructionsite:IsComplete() then
        local atrium = inst.components.entitytracker:GetEntity("atrium")

        if atrium ~= nil and atrium.components.charliecutscene ~= nil then
            local was_destabilizing = atrium:ForceDestabilizeExplode()

            atrium.components.entitytracker:ForgetEntity("charlie_hand")

            atrium:DoTaskInTime(was_destabilizing and 2 or 0, inst.StartCutScene)
            atrium.components.charliecutscene._running = true
        end

        inst:OnGetMaterials()
    end
end

----------------------------------------------------------------------------

local function SpawnShadowArm(inst, pos, atrium_pos)
    local arm = SpawnPrefab("shadowhand_arm")

    arm.Transform:SetPosition(pos.x, 0, pos.z)
    arm:FacePoint(atrium_pos.x, 0, atrium_pos.z)

    arm.components.stretcher:SetStretchTarget(inst)
    arm.components.highlightchild:SetOwner(inst)

    return arm
end

local function Initialize(inst, pos)
    local atrium = inst.components.entitytracker:GetEntity("atrium")

    if atrium ~= nil then
        local atrium_pos = atrium:GetPosition()

        inst.Transform:SetPosition(pos.x, 0, pos.z)
        inst.arm = inst:SpawnShadowArm(pos, atrium_pos)

        local showup_pos = (pos + Vector3(atrium_pos.x, 0, atrium_pos.z)) * 0.5

        inst.components.knownlocations:RememberLocation("origin", pos)
        inst.components.knownlocations:RememberLocation("showup", showup_pos)
    end
end

local function OnLoadPostPass(inst, data)
    local origin = inst.components.knownlocations:GetLocation("origin")
    local atrium = inst.components.entitytracker:GetEntity("atrium")

    if atrium ~= nil and origin ~= nil then
        local atrium_pos = atrium:GetPosition()

        inst.arm = inst:SpawnShadowArm(origin, atrium_pos)

        inst:FacePoint(atrium_pos.x, 0, atrium_pos.z)

        inst:DoTaskInTime(0, function ()
            -- Stay out when the atrium is destabilizing.
            inst:OnAtriumPowered(atrium.components.pickable ~= nil and atrium.components.pickable.caninteractwith)
        end)
    end

    -- Remove us if shadow rifts are already active or should not be possible to activate.
    if TUNING.SPAWN_RIFTS ~= 1 then
    	inst.persists = false
        inst:Hide()
        inst:DoTaskInTime(0, inst.Remove)
    end
end

local function OnRemove(inst)
    if inst.arm ~= nil then
        inst.arm:Remove()
    end
end

----------------------------------------------------------------------------

local function CharlieHandFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:PlayAnimation("hand_in")
    inst.AnimState:PushAnimation("hand_in_loop", true)

    -- constructionsite (from constructionsite component) added to pristine state for optimization.
    inst:AddTag("constructionsite")

    -- Offer action strings.
    inst:AddTag("offerconstructionsite")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.arm = nil

    inst.Initialize = Initialize
    inst.ShowUp = ShowUp
    inst.RunAway = RunAway
    inst.OnGetMaterials = OnGetMaterials
    inst.SpawnShadowArm = SpawnShadowArm
    inst.OnAtriumPowered = OnAtriumPowered
    inst.HandleAction = HandleAction
    inst.StartCutScene = StartCutScene

    inst:AddComponent("entitytracker")
    inst:AddComponent("knownlocations")
    inst:AddComponent("inspectable")

    local constructionsite = inst:AddComponent("constructionsite")
    constructionsite:SetConstructionPrefab("enable_shadow_rift_construction_container")
    constructionsite:SetOnConstructedFn(ConstructionSite_OnConstructed)

    local locomotor = inst:AddComponent("locomotor")
    locomotor.walkspeed = 2
    locomotor.directdrive = true
    locomotor.slowmultiplier = 1
    locomotor.fastmultiplier = 1
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = { ignorecreep = true }

    local sanityaura = inst:AddComponent("sanityaura")
    sanityaura.aura = -TUNING.SANITYAURA_MED

    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnRemoveEntity = OnRemove

    inst:ListenForEvent("atriumpowered", function(_, ispowered) inst:OnAtriumPowered(ispowered) end, TheWorld)
    inst:ListenForEvent("startaction",   inst.HandleAction)

    return inst
end

----------------------------------------------------------------------------


local function EnableRiftContainerFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

	inst:AddTag("bundle")

	-- Offer action strings.
	inst:AddTag("offerconstructionsite")

    -- Blank string for controller action prompt.
    inst.name = " "
	inst.POPUP_STRINGS = STRINGS.UI.START_SHADOW_RIFTS

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("enable_shadow_rift_construction_container")

    inst.persists = false

    return inst
end

----------------------------------------------------------------------------


return
        Prefab("charlie_hand",                               CharlieHandFn,          assets, prefabs ),
        Prefab("enable_shadow_rift_construction_container",  EnableRiftContainerFn                   )
