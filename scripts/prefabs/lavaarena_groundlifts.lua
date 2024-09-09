local assets =
{
    Asset("ANIM", "anim/lavaarena_boarrior_fx.zip"),
}

local function MakeGroundLift(name, radius, hasanim, hassound, excludesymbols)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        if hassound then
            inst.entity:AddSoundEmitter()
        end
        inst.entity:AddNetwork()

        if hasanim then
            inst.entity:AddAnimState()
            inst.AnimState:SetBank("lavaarena_boarrior_fx")
            inst.AnimState:SetBuild("lavaarena_boarrior_fx")
            if excludesymbols ~= nil then
                for i, v in ipairs(excludesymbols) do
                    inst.AnimState:Hide(v)
                end
            end
        else
            inst:AddTag("CLASSIFIED")
        end

        inst:Hide()

        inst:AddTag("notarget")
        inst:AddTag("hostile")
        inst:AddTag("groundspike")

        --For impact sound
        inst:AddTag("object")
        inst:AddTag("stone")

        inst:SetPrefabNameOverride("boarrior")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/lavaarena_groundlifts").master_postinit(inst, radius, hasanim, hassound)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeGroundLift("lavaarena_groundlift", .7, true, false, { "embers" }),
    MakeGroundLift("lavaarena_groundliftembers", .7, true, false),
    MakeGroundLift("lavaarena_groundliftrocks", .7, true, false, { "embers", "splash" }),
    MakeGroundLift("lavaarena_groundliftwarning", .7, false, false),
    MakeGroundLift("lavaarena_groundliftempty", 1, false, true)
