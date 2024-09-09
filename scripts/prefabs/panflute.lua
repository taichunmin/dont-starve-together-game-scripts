local assets =
{
    Asset("ANIM", "anim/pan_flute.zip"),
}

local function HearPanFlute(inst, musician, instrument)
    if inst ~= musician and
        (TheNet:GetPVPEnabled() or not inst:HasTag("player")) and
        not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) and
        not (inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck()) and
        not (inst.components.fossilizable ~= nil and inst.components.fossilizable:IsFossilized()) then
        local mount = inst.components.rider ~= nil and inst.components.rider:GetMount() or nil
        if mount ~= nil then
            mount:PushEvent("ridersleep", { sleepiness = 10, sleeptime = TUNING.PANFLUTE_SLEEPTIME })
        end
		if inst.components.farmplanttendable ~= nil then
			inst.components.farmplanttendable:TendTo(musician)
        elseif inst.components.sleeper ~= nil then
            inst.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
        elseif inst.components.grogginess ~= nil then
            inst.components.grogginess:AddGrogginess(10, TUNING.PANFLUTE_SLEEPTIME)
        else
            inst:PushEvent("knockedout")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("flute")

    inst.AnimState:SetBank("pan_flute")
    inst.AnimState:SetBuild("pan_flute")
    inst.AnimState:PlayAnimation("idle")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.PANFLUTE_SLEEPRANGE
    inst.components.instrument:SetOnHeardFn(HearPanFlute)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PANFLUTE_USES)
    inst.components.finiteuses:SetUses(TUNING.PANFLUTE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:PlayAnimation("float") end)
    inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:PlayAnimation("idle") end)

    return inst
end

return Prefab("panflute", fn, assets)
