local function PostInit(inst)
    inst:LongUpdate(0)
    inst.entity:FlushLocalDirtyNetVars()

    for k, v in pairs(inst.components) do
        if v.OnPostInit ~= nil then
            v:OnPostInit()
        end
    end
end

local function OnRemoveEntity(inst)
    if TheWorld ~= nil then
        assert(TheWorld.net == inst)
        TheWorld.net = nil
    end
end

local function DoPostInit(inst)
    if not TheWorld.ismastersim then
        if TheWorld.isdeactivated then
            --wow what bad timing!
            return
        end
        --master sim would have already done a proper PostInit in loading
        TheWorld:PostInit()
    end
    if not TheNet:IsDedicated() then
        if ThePlayer == nil then
            TheNet:SendResumeRequestToServer(TheNet:GetUserID())
        end
        PlayerHistory:StartListening()
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    assert(TheWorld ~= nil and TheWorld.net == nil)
    TheWorld.net = inst

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddNetwork()
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    inst:AddComponent("autosaver")
    inst:AddComponent("quagmire_music")
    inst:AddComponent("quagmire_recipebook")
    inst:AddComponent("quagmire_recipeprices")
    inst:AddComponent("quagmire_hangriness") --must add before worldcharacterselectlobby
    inst:AddComponent("worldcharacterselectlobby")

    inst.PostInit = PostInit
    inst.OnRemoveEntity = OnRemoveEntity

    inst:DoStaticTaskInTime(0, DoPostInit)

    return inst
end

return Prefab("quagmire_network", fn)
