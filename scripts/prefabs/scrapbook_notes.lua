local DEFAULT_ASSETS =
{
    Asset("ANIM", "anim/blueprint_tackle.zip"),
}

local NOTES =
{
    {
        name = "wagstaff_mutations",
        tags = { "mutationsnote" },
        build = "wagstaff_notes",
    },
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

local function MakeScrapbookNote(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.build  or "blueprint_tackle")
        inst.AnimState:SetBuild(data.build or "blueprint_tackle")
        inst.AnimState:PlayAnimation("idle")

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        inst:AddTag("scrapbook_note")

        if data.tags ~= nil then
            for _, tag in ipairs(data.tags) do
                inst:AddTag(tag)
            end
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.OnScrapbookDataTaught = OnScrapbookDataTaught

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("erasablepaper")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

        inst:AddComponent("scrapbookable")
        inst.components.scrapbookable:SetOnTeachFn(OnTeach)

        MakeHauntableLaunch(inst)

        return inst
    end

    local assets = data.build ~= nil and { Asset("ANIM", "anim/"..data.build..".zip") } or DEFAULT_ASSETS

    return Prefab(data.name.."_note", fn, assets)
end


local ret = {}

for _, data in ipairs(NOTES) do
    table.insert(ret, MakeScrapbookNote(data))
end

return unpack(ret)
