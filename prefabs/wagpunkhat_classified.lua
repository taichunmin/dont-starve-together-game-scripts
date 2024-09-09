local _STRINGS = {}
for k, v in pairs(STRINGS.WARBIS) do
    table.insert(_STRINGS, v)
end

local STRINGS_IDS = table.invert(_STRINGS)

local TALK_SOUNDS =
{
    "rifts3/warbis/talk_LP",
}

local TALK_SOUND_IDS = table.invert(TALK_SOUNDS)

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

local function IsStringDirty(inst)
    return inst.sound_override:value() > 0
end

local function OnSayDirty(inst)
    if inst._parent == nil then return end

    if IsStringDirty(inst) then
        local string = _STRINGS[inst.string:value()]

        if string ~= nil then
            inst._parent.components.talker:Say(string, nil, nil, nil, true)
        end
    else
        inst._parent.components.talker:ShutUp()
    end
end

local function GetTalkSound(inst)
    return TALK_SOUNDS[inst.sound_override:value()] or GetRandomItem(TALK_SOUNDS)
end

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

local function ClearString(inst)
    inst.sound_override:set_local(0)
end

local function OnSayTimeout(inst)
    inst.timeouttask = nil
    ClearString(inst)
end

local function Say(inst, string, sound_override)
    ClearString(inst)
    inst.string:set(STRINGS_IDS[string])
    inst.sound_override:set(TALK_SOUND_IDS[sound_override] or #TALK_SOUNDS + 1)
    if inst.timeouttask ~= nil then
        inst.timeouttask:Cancel()
    end
    inst.timeouttask = inst:DoTaskInTime(1, OnSayTimeout)
end

local function ShutUp(inst)
    inst.sound_override:set(0)
end

local function SetTarget(inst, target)
    inst.Network:SetClassifiedTarget(target)
    local istarget = target == nil or target == ThePlayer
    if istarget ~= inst.istarget then
        inst.istarget = istarget
        if istarget then
            inst:ListenForEvent("saydirty", OnSayDirty)
        else
            inst:RemoveEventCallback("saydirty", OnSayDirty)
        end
    end
end

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for Wagpunk Hat")
    else
        inst._parent:AttachClassified(inst)
    end
end

--------------------------------------------------------------------------

local function RegisterNetListeners(inst)
    inst:ListenForEvent("saydirty", OnSayDirty)
    OnSayDirty(inst)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform() --So we can follow parent's sleep state
    end
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.string = net_smallbyte(inst.GUID, "wagpunkhat_classified.string")
    inst.sound_override = net_tinybyte(inst.GUID, "wagpunkhat_classified.sound_override", "saydirty")
    inst.enabled = false

    inst.entity:SetPristine()

    --Common interface
    inst.GetTalkSound = GetTalkSound

    if not TheWorld.ismastersim then
        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated

        --Delay net listeners until after initial values are deserialized
        inst:DoStaticTaskInTime(0, RegisterNetListeners)

        return inst
    end

    --Server interface
    inst.Say = Say
    inst.ShutUp = ShutUp
    inst.SetTarget = SetTarget

    inst.timeouttask = nil
    inst.istarget = nil

    inst.persists = false

    return inst
end

return Prefab("wagpunkhat_classified", fn)
