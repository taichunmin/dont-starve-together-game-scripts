local STRING_LISTS = {}
for k, v in pairs(STRINGS.LUCY) do
    table.insert(STRING_LISTS, v)
end
local STRING_LIST_IDS = table.invert(STRING_LISTS)

local TALK_SOUNDS =
{
    "dontstarve/characters/woodie/lucy_warn_1",
    "dontstarve/characters/woodie/lucy_warn_2",
    "dontstarve/characters/woodie/lucy_warn_3",
    "dontstarve/characters/woodie/lucy_transform",
}
local TALK_SOUND_IDS = table.invert(TALK_SOUNDS)

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

local function IsStringDirty(inst)
    return inst.sound_override:value() > 0
end

local function OnSayDirty(inst)
    if inst._parent ~= nil and IsStringDirty(inst) then
        local list = STRING_LISTS[inst.string_list:value()]
        local string = list ~= nil and list[inst.string_id:value()] or nil
        if string ~= nil then
            inst._parent.components.talker:Say(string, nil, nil, nil, true)
        end
    end
end

local function GetTalkSound(inst)
    return TALK_SOUNDS[inst.sound_override:value()]
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

local function Say(inst, string_list, string_id, sound_override)
    ClearString(inst)
    inst.string_list:set(STRING_LIST_IDS[string_list])
    inst.string_id:set(string_id)
    inst.sound_override:set(TALK_SOUND_IDS[sound_override] or #TALK_SOUNDS + 1)
    if inst.timeouttask ~= nil then
        inst.timeouttask:Cancel()
    end
    inst.timeouttask = inst:DoTaskInTime(1, OnSayTimeout)
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
        print("Unable to initialize classified data for lucy")
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

    inst.string_list = net_smallbyte(inst.GUID, "lucy_classified.string_list")
    inst.string_id = net_smallbyte(inst.GUID, "lucy_classified.string_id")
    inst.sound_override = net_tinybyte(inst.GUID, "lucy_classified.sound_override", "saydirty")
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
    inst.SetTarget = SetTarget

    inst.timeouttask = nil
    inst.istarget = nil

    inst.persists = false

    return inst
end

return Prefab("lucy_classified", fn)
