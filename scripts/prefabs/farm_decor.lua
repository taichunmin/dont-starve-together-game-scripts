local function makeassetlist(bankname, buildname)
    return {
        Asset("ANIM", "anim/"..buildname..".zip"),
        Asset("ANIM", "anim/"..bankname..".zip"),
    }
end

local function makefn(bankname, buildname, animname, tag)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("DECOR")
        if tag ~= nil then
            inst:AddTag(tag)
        end
        --[[Non-networked entity]]
        inst.persists = false

        inst.AnimState:SetBank(bankname)
        inst.AnimState:SetBuild(buildname)
        inst.AnimState:PlayAnimation(animname)

        return inst
    end
end

local function item(name, bankname, buildname, animname, tag)
    return Prefab(name, makefn(bankname, buildname, animname, tag), makeassetlist(bankname, buildname))
end

return item("farmrock", "farm_decor", "farm_decor", "1"),
        item("farmrocktall", "farm_decor", "farm_decor", "2"),
        item("farmrockflat", "farm_decor", "farm_decor", "8"),
        item("stick", "farm_decor", "farm_decor", "3", "NOCLICK"),
        item("stickright", "farm_decor", "farm_decor", "6", "NOCLICK"),
        item("stickleft", "farm_decor", "farm_decor", "7", "NOCLICK"),
        item("signleft", "farm_decor", "farm_decor", "4", "NOCLICK"),
        item("fencepost", "farm_decor", "farm_decor", "5"),
        item("fencepostright", "farm_decor", "farm_decor", "9"),
        item("signright", "farm_decor", "farm_decor", "10", "NOCLICK"),
        item("burntstickleft", "farm_decor", "farm_decor", "11", "NOCLICK"),
        item("burntstick", "farm_decor", "farm_decor", "12", "NOCLICK"),
        item("burntfencepostright", "farm_decor", "farm_decor", "13"),
        item("burntfencepost", "farm_decor", "farm_decor", "14"),
        item("burntstickright", "farm_decor", "farm_decor", "15", "NOCLICK")
