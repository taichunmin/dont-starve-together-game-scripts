local assets =
{
    Asset("ANIM", "anim/wagstaff_tools.zip"),
}

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end

local function displaynamefn(inst)
    if ThePlayer and ThePlayer.prefab ~= "winona" then
        return STRINGS.NAMES[string.upper(inst.prefab.."_LAYMAN")]
    else
        return STRINGS.NAMES[string.upper(inst.prefab)]
    end
end

local function erode(inst,time, erodein,removewhendone)

    local time_to_erode  = time or 1
    local tick_time = TheSim:GetTickTime()

    inst:StartThread(function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            if erodein then
                erode_amount = 1 - erode_amount
            end
            inst.AnimState:SetErosionParams(erode_amount, inst.erodeparam, -1.0)
            ticks = ticks + 1

            local truetest = erode_amount
            local falsetest = 1-erode_amount
            if erodein then
                truetest = 1- erode_amount
                falsetest = erode_amount
            end

            if inst.shadow == true then
                if math.random() < truetest then
                    inst.shadow = false
                    inst.Light:Enable(false)
                end
            else
                if math.random() < falsetest then
                    inst.shadow = true
                    inst.Light:Enable(true)
                end
            end

            if ticks * tick_time > time_to_erode then
                if erodein then
                    inst.shadow = true
                    inst.Light:Enable(true)
                else
                    inst.shadow = false
                    inst.Light:Enable(false)
                end
                if removewhendone then
                    inst:Remove()
                end
            end

            Yield()
        end
        -- inst:Remove()
    end)
end

local function maketool(name, build, bank, state ,erodeparam)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(state)
        inst.scrapbook_anim = state

        inst.AnimState:SetErosionParams(0, erodeparam, -1.0)

        inst.Light:SetFalloff(0.5)
        inst.Light:SetIntensity(.8)
        inst.Light:SetRadius(1)
        inst.Light:SetColour(255/255, 200/255, 200/255) --179/255, 107/255)
        inst.Light:Enable(true)

        inst:AddTag("irreplaceable")
        inst:AddTag("wagstafftool")

        MakeInventoryFloatable(inst, "med", 0.05, 0.68)

        inst.displaynamefn = displaynamefn

        inst.scrapbook_specialinfo = "WAGSTAFF_TOOL"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
        inst.components.inventoryitem:SetOnPickupFn(OnPickup)

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")
        inst.erodeparam = erodeparam or 1
        inst.erode = erode
        inst:erode(2,true)

        return inst
    end
    return Prefab(name, fn, assets)
end

return maketool("wagstaff_tool_1", "wagstaff_tools","wagstaff_tools_all", "stethescope", -0.20),
       maketool("wagstaff_tool_2", "wagstaff_tools","wagstaff_tools_all", "wrench", -0.172),
       maketool("wagstaff_tool_3", "wagstaff_tools","wagstaff_tools_all", "book", -0.175),
       maketool("wagstaff_tool_4", "wagstaff_tools","wagstaff_tools_all", "multitool",-0.136),
       maketool("wagstaff_tool_5", "wagstaff_tools","wagstaff_tools_all", "radio", -0.3)
