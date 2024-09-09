local assets =
{
    Asset("DYNAMIC_ANIM", "anim/dynamic/lantern_tesla.zip"),
    Asset("PKGREF", "anim/dynamic/lantern_tesla.dyn"),
}

local BLANK_FRAMES = { 0, 14, 15, 29, 30, 31, 42 }

local function MakeFX(suffix)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.AnimState:SetBank("lantern_tesla_fx")
        inst.AnimState:SetBuild("lantern")
        inst.AnimState:PlayAnimation("idle_"..suffix, true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        if POPULATING then
			inst.AnimState:SetFrame(BLANK_FRAMES[math.random(#BLANK_FRAMES)])
        end

        return inst
    end

    return Prefab("lantern_tesla_fx_"..suffix, fn, assets)
end

--For searching: "lantern_tesla_fx_held", "lantern_tesla_fx_ground"
return MakeFX("held"),
    MakeFX("ground")
