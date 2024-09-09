-- inst in this context is the cursed object

local function trytransform(owner, towonkey)
    if owner.sg:HasStateTag("nomorph") or
        owner.sg:HasStateTag("silentmorph") or
        owner.sg:HasStateTag("busy") or
        owner.sg:HasStateTag("pinned") or
        owner.sg:HasStateTag("dead") then
        --delay transform
        return
    elseif towonkey and (
            owner:HasTag("weregoose") or
            owner:HasTag("weremoose") or
            owner:HasTag("beaver")
        ) then
        --don't transform if woodie is in "were"form
        return
    end

    --Don't cancel the task, so it'll automatically retry if transformation states get interrupted
    --owner._trymonkeychangetask:Cancel()
    --owner._trymonkeychangetask = nil
    owner.sg:GoToState("monkeychanger_pre", towonkey)
end

local function tryannounce(owner)
    owner._trymonkeyannouncetask = nil
    if owner.entity:IsVisible() then
        owner.components.talker:Say(GetString(owner, "ANNOUNCE_MONKEY_CURSE_1"))
    end
end

local function uncurse(owner, num)
    SpawnPrefab("monkey_de_morphin_fx").entity:SetParent(owner.entity)

    if owner:HasTag("wonkey") then
        if num > 0 then
            owner:PushEvent("monkeycursehit", { uncurse = true })
        elseif owner._trymonkeychangetask == nil then
            owner._trymonkeychangetask = owner:DoPeriodicTask(.1, trytransform, 0, false)
        end
    else
        if num <= 0 then
            owner.monkeyfeet = nil
            owner.monkeyhands = nil
            owner.monkeytail = nil
            owner.components.skinner:ClearMonkeyCurse("MONKEY_CURSE_1")
            owner:RemoveTag("MONKEY_CURSE_1")
            owner:RemoveTag("MONKEY_CURSE_2")
            owner:RemoveTag("MONKEY_CURSE_3")
        elseif num <= 2 then
            owner.monkeyfeet = true
            owner.monkeyhands = nil
            owner.monkeytail = nil
            owner.components.skinner:SetMonkeyCurse("MONKEY_CURSE_1")
            owner:AddTag("MONKEY_CURSE_1")
            owner:RemoveTag("MONKEY_CURSE_2")
            owner:RemoveTag("MONKEY_CURSE_3")
        elseif num <=5 then
            owner.monkeyfeet = true
            owner.monkeyhands = true
            owner.monkeytail = nil
            owner.components.skinner:SetMonkeyCurse("MONKEY_CURSE_2")
            owner:RemoveTag("MONKEY_CURSE_1")
            owner:AddTag("MONKEY_CURSE_2")
            owner:RemoveTag("MONKEY_CURSE_3")
        else
            owner.monkeyfeet = true
            owner.monkeyhands = true
            owner.monkeytail = true
            owner.components.skinner:SetMonkeyCurse("MONKEY_CURSE_3")
            owner:RemoveTag("MONKEY_CURSE_1")
            owner:RemoveTag("MONKEY_CURSE_2")
            owner:AddTag("MONKEY_CURSE_3")
        end  

        owner:PushEvent("monkeycursehit", { uncurse = true })
    end
end

local function docurse(owner, numitems)
    SpawnPrefab("monkey_morphin_power_players_fx").entity:SetParent(owner.entity)

    local iswonkey = owner:HasTag("wonkey")

    if not iswonkey and numitems >= TUNING.MONKEY_TOKEN_COUNTS.LEVEL_4 then
        if owner._trymonkeychangetask == nil then
            owner._trymonkeychangetask = owner:DoPeriodicTask(.1, trytransform, 0, true)
        end
    else
        if numitems > TUNING.MONKEY_TOKEN_COUNTS.LEVEL_1 and not owner.monkeyfeet then
            if not iswonkey and owner._trymonkeyannouncetask == nil then
                owner._trymonkeyannouncetask = owner:DoTaskInTime(1, tryannounce)
            end
            owner.monkeyfeet = true
            owner.components.skinner:SetMonkeyCurse("MONKEY_CURSE_1")
            owner:AddTag("MONKEY_CURSE_1")
        end
        if numitems > TUNING.MONKEY_TOKEN_COUNTS.LEVEL_2 and not owner.monkeyhands then
            owner.monkeyhands = true
            owner.components.skinner:SetMonkeyCurse("MONKEY_CURSE_2")
            owner:RemoveTag("MONKEY_CURSE_1")
            owner:AddTag("MONKEY_CURSE_2")
        end
        if numitems > TUNING.MONKEY_TOKEN_COUNTS.LEVEL_3 and not owner.monkeytail then
            owner.monkeytail = true
            owner.components.skinner:SetMonkeyCurse("MONKEY_CURSE_3")
            owner:RemoveTag("MONKEY_CURSE_2")
            owner:AddTag("MONKEY_CURSE_3")
        end

        owner:PushEvent("monkeycursehit", { uncurse = false })
    end
end

return {
  docurse = docurse,
  uncurse = uncurse,
}