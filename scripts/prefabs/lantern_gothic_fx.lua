local assets =
{
    Asset("DYNAMIC_ANIM", "anim/dynamic/lantern_gothic.zip"),
    Asset("PKGREF", "anim/dynamic/lantern_gothic.dyn"),
}

local function KillFX(inst)
    if inst:GetTimeAlive() > 0 then
        inst.killed = true
    else
        inst:Remove()
    end
end

local function IsMovingStep(step)
    return step ~= 0 and step ~= 3
end

local function OnGlowAnimOver(inst)
    if inst.glowemitter:IsValid() then
        if IsMovingStep(inst.step) then
            if inst.glowemitter.ismoving then
                inst:Show()
            else
                inst:Hide()
            end
        end
        inst.Transform:SetPosition(inst.glowemitter.Transform:GetWorldPosition())
        inst.AnimState:PlayAnimation(inst.anim)
    else
        inst:Remove()
    end
end

local function CreateGlowEmber(glowemitter, variation, step)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lantern_gothic_fx")
    inst.AnimState:SetBuild("lantern")
    inst.AnimState:OverrideItemSkinSymbol("glowflake", "lantern_gothic", "glowflake", 0, "lantern")
    inst.AnimState:SetFinalOffset(1)

    inst.glowemitter = glowemitter
    inst.anim = "glowfall"..tostring(variation)
    inst.step = step
    inst:ListenForEvent("animover", OnGlowAnimOver)
    OnGlowAnimOver(inst)

    return inst
end

local function CheckMoving(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        local newpos = parent:GetPosition()
        inst.ismoving = inst.prevpos ~= nil and inst.prevpos ~= newpos
        inst.prevpos = newpos
    else
        inst.ismoving = false
    end
end

local function heldfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        for i = 0, 5 do
            local delay = i * 86 / 6 * FRAMES
            inst:DoTaskInTime(delay + 1 * FRAMES, CreateGlowEmber, 1, i)
            inst:DoTaskInTime(delay + 7 * FRAMES, CreateGlowEmber, 2, i)
            inst:DoTaskInTime(delay + 13 * FRAMES, CreateGlowEmber, 3, i)
            inst:DoTaskInTime(delay + 30 * FRAMES, CreateGlowEmber, 4, i)
            inst:DoTaskInTime(delay + 41 * FRAMES, CreateGlowEmber, 5, i)
            inst:DoTaskInTime(delay + 58 * FRAMES, CreateGlowEmber, 6, i)
            inst:DoTaskInTime(delay + 67 * FRAMES, CreateGlowEmber, 7, i)
        end
        inst.ismoving = false
        inst:DoPeriodicTask(0, CheckMoving)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function OnGroundAnimOver(inst)
    if not inst.killed then
        if not inst.AnimState:IsCurrentAnimation("glow_pre") then
            inst.AnimState:Show("hidepre")
        end
        inst.AnimState:PlayAnimation("glow_loop")
    elseif inst.AnimState:IsCurrentAnimation("glow_pst") then
        inst:Remove()
    else
        inst.AnimState:PlayAnimation("glow_pst")
    end
end

local function groundfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("lantern_gothic_fx")
    inst.AnimState:SetBuild("lantern")
    inst.AnimState:Hide("hidepre")
    inst.AnimState:PlayAnimation("glow_pre")
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    if POPULATING then
        inst.AnimState:PlayAnimation("glow_loop")
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    end

    inst:ListenForEvent("animover", OnGroundAnimOver)
    inst.KillFX = KillFX

    return inst
end

return Prefab("lantern_gothic_fx_held", heldfn, assets),
    Prefab("lantern_gothic_fx_ground", groundfn, assets)
