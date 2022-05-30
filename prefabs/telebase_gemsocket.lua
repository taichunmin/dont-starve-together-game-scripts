local assets =
{
    Asset("ANIM", "anim/staff_purple_base.zip"),
}

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab ~= "purplegem" then
        return false, string.sub(item.prefab, -3) == "gem" and "WRONGGEM" or "NOTGEM"
    end
    return true
end

local function OnGemGiven(inst, giver, item)
    --Disable trading, enable picking.
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_hum", "hover_loop")
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    inst.components.trader:Disable()
    inst.components.pickable:SetUp("purplegem", 1000000)
    inst.components.pickable:Pause()
    inst.components.pickable.caninteractwith = true
    inst.AnimState:PlayAnimation("idle_full_loop", true)
end

local function OnGemTaken(inst)
    inst.SoundEmitter:KillSound("hover_loop")
    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst.AnimState:PlayAnimation("idle_empty")
end

local function ShatterGem(inst)
    inst.SoundEmitter:KillSound("hover_loop")
    inst.AnimState:ClearBloomEffectHandle()
    inst.AnimState:PlayAnimation("shatter")
    inst.AnimState:PushAnimation("idle_empty")
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
end

local function DestroyGem(inst)
    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst:DoTaskInTime(math.random() * 0.5, ShatterGem)
end

local function OnLoad(inst, data)
    if not inst.components.pickable.caninteractwith then
        OnGemTaken(inst)
    else
        OnGemGiven(inst)
    end
end

local function getstatus(inst)
    return inst.components.pickable.caninteractwith and "VALID" or "GEMS"
end

local function onhaunt(inst)
    --#HAUNTFIX
    --if inst.components.trader ~= nil and not inst.components.trader.enabled and math.random() <= TUNING.HAUNT_CHANCE_RARE then
        --DestroyGem(inst)
        --return true
    --end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("staff_purple_base")
    inst.AnimState:SetBuild("staff_purple_base")
    inst.AnimState:PlayAnimation("idle_empty")

    inst:AddTag("gemsocket")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = OnGemTaken

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven

    inst.DestroyGemFn = DestroyGem

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_MEDIUM)
    inst.components.hauntable:SetOnHauntFn(onhaunt)

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("gemsocket", fn, assets)
