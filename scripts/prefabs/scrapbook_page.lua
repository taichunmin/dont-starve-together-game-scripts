local assets =
{
    Asset("ANIM", "anim/scrapbook_page.zip"),
}

local function CancelReservation(inst)
    inst.reserved_userid = nil
    inst.cancelreservationtask = nil
end

local function OnScrapbookDataTaught(inst, doer, diduse)
    if doer.userid and inst.reserved_userid == doer.userid then
        inst.reserved_userid = nil
        if inst.cancelreservationtask ~= nil then
            inst.cancelreservationtask:Cancel()
            inst.cancelreservationtask = nil
        end
        if diduse then
            -- Taught things remove this.
            if inst.components.stackable then
                inst.components.stackable:Get(1):Remove()
            else
                inst:Remove()
            end
        else
            -- Their book is full.
            if doer.components.talker then
                doer.components.talker:Say(GetString(doer, "ANNOUNCE_SCRAPBOOK_FULL"))
            end
        end
    end
end

local function OnTeach(inst, doer)
    if inst.reserved_userid then -- One player at a time.
        if doer.components.talker then
            doer.components.talker:Say(GetActionFailString(doer, "STORE", "INUSE"))
        end
        return true
    end

    -- We are mastersim here.
    if doer.userid then
        inst.reserved_userid = doer.userid
        if (TheNet:IsDedicated() or doer ~= ThePlayer) then
            -- The doer is a client let them try to learn things on their end.
            inst.cancelreservationtask = inst:DoTaskInTime(10, CancelReservation) -- This is the time period back and forth before the try is cancelled.
            SendRPCToClient(CLIENT_RPC.TryToTeachScrapbookData, doer.userid, inst)
        else
            -- The doer is also server.
            local diduse = TheScrapbookPartitions:TryToTeachScrapbookData(true, inst)
            inst:OnScrapbookDataTaught(doer, diduse)
        end
    end
    return true
end

local function Special_DisplayNameFn(inst)
    local name = STRINGS.SCRAPBOOK.SPECIAL_SCRAPBOOK_PAGES.UNKNOWN

    local id = inst._id:value()

    local page_data = id > 0 and SPECIAL_SCRAPBOOK_PAGES_LOOKUP[id] or nil

    if page_data ~= nil then
        name = STRINGS.SCRAPBOOK.SPECIAL_SCRAPBOOK_PAGES[page_data.name] or STRINGS.SCRAPBOOK.SPECIAL_SCRAPBOOK_PAGES.UNKNOWN
    end

    return subfmt(STRINGS.NAMES.SCRAPBOOK_PAGE_FMT, { name = name})
end

local function Special_SetId(inst, id)
    local page_data = SPECIAL_SCRAPBOOK_PAGES_LOOKUP[id]

    if page_data ~= nil then
        inst._id:set(id)
    end
end

local function Special_OnSave(inst, data)
    local id = inst._id:value()

    local page_data = id > 0 and SPECIAL_SCRAPBOOK_PAGES_LOOKUP[id] or nil

    data.name = page_data ~= nil and page_data.name or nil
end

local function Special_OnLoad(inst, data)
    if data == nil then return end

    if data.name ~= nil then
        inst:SetId(SPECIAL_SCRAPBOOK_PAGES[data.name])
    end
end

local function commonfn(special)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("scrapbook_page")
    inst.AnimState:SetBuild("scrapbook_page")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")
    inst:AddTag("scrapbook_page")
    inst:AddTag("scrapbook_data")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    if special then
        inst._id = net_smallbyte(inst.GUID, "scrapbook_page._id")

        inst.displaynamefn = Special_DisplayNameFn

        inst:SetPrefabNameOverride("scrapbook_page")

        inst.scrapbook_proxy = "scrapbook_page"
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_specialinfo = "SCRAPBOOKPAGE"

    inst.OnScrapbookDataTaught = OnScrapbookDataTaught

    inst:AddComponent("erasablepaper")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")

    if special then
        inst.components.inventoryitem:ChangeImageName("scrapbook_page")

        inst.SetId = Special_SetId

        inst.OnSave = Special_OnSave
        inst.OnLoad = Special_OnLoad
    else
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    end

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("scrapbookable")
    inst.components.scrapbookable:SetOnTeachFn(OnTeach)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end


local function regularfn()
    return commonfn(false)
end
local function specialfn()
    return commonfn(true)
end

return
        Prefab("scrapbook_page",         regularfn, assets),
        Prefab("scrapbook_page_special", specialfn, assets)
