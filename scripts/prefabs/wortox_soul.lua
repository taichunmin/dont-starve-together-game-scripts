local wortox_soul_common = require("prefabs/wortox_soul_common")

local assets =
{
    Asset("ANIM", "anim/wortox_soul_ball.zip"),
    Asset("SCRIPT", "scripts/prefabs/wortox_soul_common.lua"),
}

local prefabs =
{
    "wortox_soul_heal_fx",
}

local SCALE = .8

local function topocket(inst)
    inst.persists = true
    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function KillSoul(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("idle_pst")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
    wortox_soul_common.DoHeal(inst)
end

local function toground(inst)
    inst.persists = false
    if inst._task == nil then
        inst._task = inst:DoTaskInTime(.4 + math.random() * .7, KillSoul) -- NOTES(JBK): This is 1.1 max keep it in sync with "[WST]"
    end
    if inst.AnimState:IsCurrentAnimation("idle_loop") then
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    end
end

local SOUL_TAGS = { "soul" }
local function OnDropped(inst)
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local num = 10 - #TheSim:FindEntities(x, y, z, 4, SOUL_TAGS)
        if num > 0 then
            for i = 1, math.min(num, inst.components.stackable:StackSize()) do
                local soul = inst.components.stackable:Get()
                soul.Physics:Teleport(x, y, z)
                soul.components.inventoryitem:OnDropped(true)
            end
        end
    end
end

local function OnCharged(inst)
    if inst.components.inventoryitem ~= nil then
        local owner = inst.components.inventoryitem.owner
        if owner and owner.FinishPortalHop then
            owner:FinishPortalHop()
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("wortox_soul_ball")
    inst.AnimState:SetBuild("wortox_soul_ball")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetScale(SCALE, SCALE)

    inst:AddTag("nosteal")
    inst:AddTag("NOCLICK")

    --souleater (from soul component) added to pristine state for optimization
    inst:AddTag("soul")

    -- Tag rechargeable (from rechargeable component) added to pristine state for optimization.
    inst:AddTag("rechargeable")
    -- Optional tag to control if the item is not a "cooldown until" meter but a "bonus while" meter.
    inst:AddTag("rechargeable_bonus")
	--waterproofer (from waterproofer component) added to pristine state for optimization
	inst:AddTag("waterproofer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst:AddComponent("inspectable")
    inst:AddComponent("soul")

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    inst._task = nil
    toground(inst)

    return inst
end

return Prefab("wortox_soul", fn, assets, prefabs)
