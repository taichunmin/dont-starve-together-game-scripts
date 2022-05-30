require("class")

local BehaviourTrees = {}
local StateGraphs = {}
local Components = {}
local EventServerFiles = {}

StopUpdatingComponents = {}

local ClientSideInventoryImageFlags = {}

local function EntityWatchWorldState(self, var, fn)
    if self.worldstatewatching == nil then
        self.worldstatewatching = {}
    end

    local watcherfns = self.worldstatewatching[var]
    if watcherfns == nil then
        watcherfns = {}
        self.worldstatewatching[var] = watcherfns
    end

    table.insert(watcherfns, fn)
end

local function EntityStopWatchingWorldState(self, var, fn)
    if self.worldstatewatching ~= nil then
        local watcherfns = self.worldstatewatching[var]
        if watcherfns ~= nil then
            RemoveByValue(watcherfns, fn)

            if next(watcherfns) == nil then
                self.worldstatewatching[var] = nil
            end
        end

        if next(self.worldstatewatching) == nil then
            self.worldstatewatching = nil
        end
    end
end

local function ComponentWatchWorldState(self, var, fn)
    EntityWatchWorldState(self.inst, var, fn)
    TheWorld.components.worldstate:AddWatcher(var, self.inst, fn, self)
end

local function ComponentStopWatchingWorldState(self, var, fn)
    EntityStopWatchingWorldState(self.inst, var, fn)
    TheWorld.components.worldstate:RemoveWatcher(var, self.inst, fn, self)
end

local function LoadComponent(name)
    if Components[name] == nil then
        Components[name] = require("components/"..name)
        assert(Components[name], "could not load component "..name)
        Components[name].WatchWorldState = ComponentWatchWorldState
        Components[name].StopWatchingWorldState = ComponentStopWatchingWorldState
    end
    return Components[name]
end

local function LoadStateGraph(name)
    if StateGraphs[name] == nil then
        local fn = require("stategraphs/"..name)
        assert(fn, "could not load stategraph "..name)
        StateGraphs[name] = fn
    end

    local sg = StateGraphs[name]

    assert(sg, "stategraph "..name.." is not valid")
    return sg
end

-------------------------------------------
--Loading event server files
function event_server_data(eventname, path)
    local fullpath = eventname.."_event_server/"..path
    if EventServerFiles[fullpath] == nil then
        EventServerFiles[fullpath] = requireeventfile(fullpath)
        if path.sub(1, 11) == "components/" then
            EventServerFiles[fullpath].WatchWorldState = ComponentWatchWorldState
            EventServerFiles[fullpath].StopWatchingWorldState = ComponentStopWatchingWorldState
        end
    end
    return EventServerFiles[fullpath]
end

-------------------------------------------
--Override adding network component

local function OnActionComponentsDirty(inst)
    inst.actioncomponents = inst.actionreplica.actioncomponents:value()
end

local function OnModActionComponentsDirty(inst, modname)
    if inst.modactioncomponents == nil then
        inst.modactioncomponents = {}
    end
    inst.modactioncomponents[modname] = inst.actionreplica.modactioncomponents[modname]:value()
end

local function SerializeInherentActions(inst)
    if inst.actionreplica ~= nil then
        local t = {}
        if inst.inherentactions ~= nil then
            local id = 1
            for k, v in pairs(ACTIONS) do
                if inst.inherentactions[v] then
                    table.insert(t, id)
                end
                id = id + 1
            end
        end
        inst.actionreplica.inherentactions:set(t)
    end
end

local function DeserializeInherentActions(inst)
    inst.inherentactions = {}
    for i, v in ipairs(inst.actionreplica.inherentactions:value()) do
        inst.inherentactions[v] = true
    end
    if next(inst.inherentactions) == nil then
        inst.inherentactions = nil
    else
        local id = 1
        for k, v in pairs(ACTIONS) do
            if inst.inherentactions[id] then
                inst.inherentactions[id] = nil
                inst.inherentactions[v] = true
            end
            id = id + 1
        end
    end
end

local function SerializeAction(action)
    if action ~= nil then
        local id = 1
        for k, v in pairs(ACTIONS) do
            if action == v then
                return id
            end
            id = id + 1
        end
    end
    return 0
end

local function DeserializeAction(actionid)
    if actionid > 0 then
        local id = 1
        for k, v in pairs(ACTIONS) do
            if actionid == id then
                return v
            end
            id = id + 1
        end
    end
end

local function OnInherentSceneActionDirty(inst)
    inst.inherentsceneaction = DeserializeAction(inst.actionreplica.inherentsceneaction:value())
end

local function OnInherentSceneAltActionDirty(inst)
    inst.inherentscenealtaction = DeserializeAction(inst.actionreplica.inherentscenealtaction:value())
end

local AddNetworkProxy = Entity.AddNetwork

function Entity:AddNetwork()
    AddNetworkProxy(self)

    local guid = self:GetGUID()
    local inst = Ents[guid]
    inst.actionreplica =
    {
        actioncomponents = net_bytearray(guid, "actioncomponents", "actioncomponentsdirty"),
        inherentactions = net_bytearray(guid, "inherentactions", "inherentactionsdirty"),
        inherentsceneaction = net_byte(guid, "inherentsceneaction", "inherentsceneactiondirty"),
        inherentscenealtaction = net_byte(guid, "inherentscenealtaction", "inherentscenealtactiondirty"),

        modactioncomponents = {}
    }

    for _,modname in pairs(ModManager:GetServerModsNames()) do
        inst.actionreplica.modactioncomponents[modname] = net_smallbytearray(guid, "modactioncomponents"..modname, "modactioncomponentsdirty"..modname)
    end


    if not TheWorld.ismastersim then
        inst:ListenForEvent("actioncomponentsdirty", OnActionComponentsDirty)
        inst:ListenForEvent("inherentactionsdirty", DeserializeInherentActions)
        inst:ListenForEvent("inherentsceneactiondirty", OnInherentSceneActionDirty)
        inst:ListenForEvent("inherentscenealtactiondirty", OnInherentSceneAltActionDirty)

        for _,modname in pairs(ModManager:GetServerModsNames()) do
            inst:ListenForEvent("modactioncomponentsdirty"..modname, function(inst) OnModActionComponentsDirty(inst,modname) end)
        end
    end
end

-------------------------------------------
--Replica components container with overriden accessor

local Replica = Class(function(self, inst)
    self.inst = inst
    self._ = {}
end)

function Replica:__index(name)
    return self._[name] == nil and getmetatable(self)[name] or self.inst:ValidateReplicaComponent(name, self._[name])
end

EntityScript = Class(function(self, entity)
    self.entity = entity
    self.components = {}
    self.lower_components_shadow = {}
    self.GUID = entity:GetGUID()
    self.spawntime = GetTime()
    self.persists = true
    self.inlimbo = false
    self.name = nil

    self.data = nil
    self.listeners = nil
    self.updatecomponents = nil
    self.updatestaticcomponents = nil
    self.actioncomponents = {}
    self.inherentactions = nil
    self.inherentsceneaction = nil
    self.inherentscenealtaction = nil
    self.event_listeners = nil
    self.event_listening = nil
    self.worldstatewatching = nil
    self.pendingtasks = nil
    self.children = nil
    self.platformfollowers = nil

    self.actionreplica = nil
    self.replica = Replica(self)
end)

function EntityScript:GetSaveRecord()
    local record = nil

    if self.entity:HasTag("player") then
        record = {
            prefab = self.prefab,
            --id = self.GUID,
            age = self.Network:GetPlayerAge(),
        }

		--if ThePlayer == self then
		--	record.crafting_menu = TheCraftingMenuProfile:SerializeLocalClientSessionData()
		--end

        local platform = self:GetCurrentPlatform()
        if platform then
            local px, py, pz = platform.Transform:GetWorldPosition()
            local x, y, z = self.Transform:GetWorldPosition()

            local rx, ry, rz = x - px, y - py, z - pz

            --Qnan hunting
			if rx ~= rx or ry ~= ry or rz ~= rz then
				print("EntityScript:GetSaveRecord error saving position: ", self.prefab, rx, ry, rz, ":", x, y, z, ":", px, py, pz)
				if CONFIGURATION ~= "PRODUCTION" then
					error("EntityScript:GetSaveRecord qnan error")
				end
				rx, ry, rz = 0, 0, 0
			end

            record.puid = platform.components.walkableplatform:GetUID()

            record.rx = rx and math.floor(rx*1000)/1000 or 0
            record.rz = rz and math.floor(rz*1000)/1000 or 0
            if ry ~= 0 then
                record.ry = ry and math.floor(ry*1000)/1000 or 0
            end
        end
    else
        record = {
            prefab = self.prefab,
            --id = self.GUID,
        }
    end

    local x, y, z = self.Transform:GetWorldPosition()

    --Qnan hunting
	if x ~= x or y ~= y or z ~= z then
		print("EntityScript:GetSaveRecord error saving position: ", self.prefab, x, y, z)
		if CONFIGURATION ~= "PRODUCTION" then
			error("EntityScript:GetSaveRecord qnan error")
		end
		x, y, z = 0, 0, 0
	end

    record.x = x and math.floor(x*1000)/1000 or 0
    record.z = z and math.floor(z*1000)/1000 or 0
    --y is often 0 in our game, so be selective.
    if y ~= 0 then
        record.y = y and math.floor(y*1000)/1000 or 0
    end

    record.skinname = self.skinname
    record.skin_id = self.skin_id
    record.alt_skin_ids = self.alt_skin_ids

    local references = nil
    record.data, references = self:GetPersistData()

    return record, references
end


function EntityScript:Hide()
    self.entity:Hide(false)
end

function EntityScript:Show()
    self.entity:Show(false)
end

function EntityScript:IsInLimbo()
    --V2C: faster than checking tag, but only valid on mastersim
    return self.inlimbo
end

function EntityScript:ForceOutOfLimbo(state)
    self.forcedoutoflimbo = state or nil
    self.entity:SetInLimbo(self:IsInLimbo() and not self.forcedoutoflimbo or false)
end

function EntityScript:RemoveFromScene()
    self.entity:AddTag("INLIMBO")
    self.entity:SetInLimbo(not self.forcedoutoflimbo)
    self.inlimbo = true
    self.entity:Hide()

    self:StopBrain()

    if self.sg then
        self.sg:Stop()
    end
    if self.Physics then
        self.Physics:SetActive(false)
    end
    if self.Light and self.Light:GetDisableOnSceneRemoval() then
        self.Light:Enable(false)
    end
    if self.AnimState then
        self.AnimState:Pause()
    end
    if self.DynamicShadow then
        self.DynamicShadow:Enable(false)
    end
    if self.MiniMapEntity then
        self.MiniMapEntity:SetEnabled(false)
    end

    self:PushEvent("enterlimbo")
end

function EntityScript:ReturnToScene()
    self.entity:RemoveTag("INLIMBO")
    self.entity:SetInLimbo(false)
    self.inlimbo = false
    self.entity:Show()
    if self.Physics then
        self.Physics:SetActive(true)
    end
    if self.Light then
        self.Light:Enable(true)
    end
    if self.AnimState then
        self.AnimState:Resume()
    end
    if self.DynamicShadow then
        self.DynamicShadow:Enable(true)
    end
    if self.MiniMapEntity then
        self.MiniMapEntity:SetEnabled(true)
    end

    self:RestartBrain()

    if self.sg then
        self.sg:Start()
    end
    self:PushEvent("exitlimbo")
end

function EntityScript:__tostring()
    return string.format("%d - %s%s", self.GUID, self.prefab or "", self.inlimbo and "(LIMBO)" or "")
end

function EntityScript:AddInherentAction(act)
    if self.inherentactions == nil then
        self.inherentactions = {}
    end
    self.inherentactions[act] = true
    SerializeInherentActions(self)
end

function EntityScript:RemoveInherentAction(act)
    if self.inherentactions ~= nil then
        self.inherentactions[act] = nil
        if next(self.inherentactions) == nil then
            self.inherentactions = nil
        end
        SerializeInherentActions(self)
    end
end

function EntityScript:GetTimeAlive()
    return GetTime() - self.spawntime
end

function EntityScript:StartUpdatingComponent(cmp, do_static_update)
    if not self:IsValid() then
        return
    end

    if not self.updatecomponents then
        self.updatecomponents = {}
        NewUpdatingEnts[self.GUID] = self
        num_updating_ents = num_updating_ents + 1
    end

    if do_static_update then
        if not self.updatestaticcomponents then
            self.updatestaticcomponents = {}
            NewStaticUpdatingEnts[self.GUID] = self
        end
    end

    if StopUpdatingComponents[cmp] == self then
        StopUpdatingComponents[cmp] = nil
    end

    local cmpname = nil
    for k,v in pairs(self.components) do
        if v == cmp then
            cmpname = k
            break
        end
    end
    self.updatecomponents[cmp] = cmpname or "component"

    if do_static_update then
        self.updatestaticcomponents[cmp] = cmpname or "component"
    end
end

function EntityScript:StopUpdatingComponent(cmp)
    if self.updatecomponents or self.updatestaticcomponents then
        StopUpdatingComponents[cmp] = self
    end
end

function EntityScript:StopUpdatingComponent_Deferred(cmp)
    if self.updatecomponents then
        self.updatecomponents[cmp] = nil

        if IsTableEmpty(self.updatecomponents) then
            self.updatecomponents = nil
            UpdatingEnts[self.GUID] = nil
            NewUpdatingEnts[self.GUID] = nil
            num_updating_ents = num_updating_ents - 1
        end
    end

    if self.updatestaticcomponents then
        self.updatestaticcomponents[cmp] = nil

        if IsTableEmpty(self.updatestaticcomponents) then
            self.updatestaticcomponents = nil
            StaticUpdatingEnts[self.GUID] = nil
            NewStaticUpdatingEnts[self.GUID] = nil
        end
    end
end

function EntityScript:StartWallUpdatingComponent(cmp)
    if not self:IsValid() then
        return
    end

    if not self.wallupdatecomponents then
        self.wallupdatecomponents = {}
        NewWallUpdatingEnts[self.GUID] = self
    end

    local cmpname = nil
    for k,v in pairs(self.components) do
        if v == cmp then
            cmpname = k
            break
        end
    end

    self.wallupdatecomponents[cmp] = cmpname or "component"
end



function EntityScript:StopWallUpdatingComponent(cmp)

    if self.wallupdatecomponents then
        self.wallupdatecomponents[cmp] = nil

        local num = 0
        for k,v in pairs(self.wallupdatecomponents) do
            num = num + 1
            break
        end

        if num == 0 then
            self.wallupdatecomponents = nil
            WallUpdatingEnts[self.GUID] = nil
            NewWallUpdatingEnts[self.GUID] = nil
        end
    end
end


function EntityScript:GetComponentName(cmp)
    for k,v in pairs(self.components) do
        if v == cmp then
            return k
        end
    end
    return "component"
end

function EntityScript:AddTag(tag)
    self.entity:AddTag(tag)
end

function EntityScript:RemoveTag(tag)
    self.entity:RemoveTag(tag)
end

function EntityScript:HasTag(tag)
    return self.entity:HasTag(tag)
end

function EntityScript:HasTags(tags)
	for i = 1, #tags do
		if not self.entity:HasTag(tags[i]) then
			return false
		end
	end
	return true
end

function EntityScript:HasOneOfTags(tags)
	for i = 1, #tags do
		if self.entity:HasTag(tags[i]) then
			return true
		end
	end
	return false
end

require("entityreplica")
--Additional initialization for network entity replicas
--defines: EntityScript:ValidateReplicaComponent(name)
--         EntityScript:ReplicateComponent(name)
--         EntityScript:UnreplicateEntity(name)
--         EntityScript:PrereplicateEntity(name)
--         EntityScript:ReplicateEntity()

require("componentactions")
--defines: EntityScript:RegisterComponentActions(name)
--         EntityScript:UnregisterComponentActions(name)
--         EntityScript:CollectActions(type, ...)
--         EntityScript:IsActionValid(action, right)

function EntityScript:AddComponent(name)
    local lower_name = string.lower(name)
    if self.lower_components_shadow[lower_name] ~= nil then
        print("component "..name.." already exists on entity "..tostring(self).."!"..debugstack_oneline(3))
    end

    local cmp = LoadComponent(name)
    assert(cmp, "component ".. name .. " does not exist!")

    self:ReplicateComponent(name)

    local loadedcmp = cmp(self)
    self.components[name] = loadedcmp
    self.lower_components_shadow[lower_name] = true

    local postinitfns = ModManager:GetPostInitFns("ComponentPostInit", name)

    for i, fn in ipairs(postinitfns) do
        fn(loadedcmp, self)
    end

    self:RegisterComponentActions(name)
end

function EntityScript:RemoveComponent(name)
    local cmp = self.components[name]
    if cmp then
        self:StopUpdatingComponent(cmp)
        self:StopWallUpdatingComponent(cmp)
        self.components[name] = nil
        self.lower_components_shadow[string.lower(name)] = nil

        if cmp.OnRemoveFromEntity then
            cmp:OnRemoveFromEntity()
        end

        self:UnreplicateComponent(name)
        self:UnregisterComponentActions(name)
    end
end

function EntityScript:GetBasicDisplayName()
    return (self.displaynamefn ~= nil and self:displaynamefn())
        or (self.nameoverride ~= nil and STRINGS.NAMES[string.upper(self.nameoverride)])
		or (self.name_author_netid ~= nil and ApplyLocalWordFilter(self.name, TEXT_FILTER_CTX_CHAT, self.name_author_netid)) -- this is more lika a TEXT_FILTER_CTX_NAME but its all user input (eg, naming a beefalo) so lets go with TEXT_FILTER_CTX_CHAT
        or self.name
end

function EntityScript:GetAdjectivedName()
    local name = self:GetBasicDisplayName()

    if self:HasTag("player") then
        --No adjectives for players
        return name
    elseif self:HasTag("smolder") then
        return ConstructAdjectivedName(self, name, STRINGS.SMOLDERINGITEM)
    elseif self:HasTag("diseased") then
        return ConstructAdjectivedName(self, name, STRINGS.DISEASEDITEM)
    elseif self:HasTag("rotten") then
        return ConstructAdjectivedName(self, name, STRINGS.UI.HUD.SPOILED)
    elseif self:HasTag("withered") then
        return ConstructAdjectivedName(self, name, STRINGS.WITHEREDITEM)
    elseif not self.no_wet_prefix and (self.always_wet_prefix or self:GetIsWet()) then
        --custom
        if self.wet_prefix ~= nil then
            return ConstructAdjectivedName(self, name, self.wet_prefix)
        end
        --equippable
        local equippable = self.replica.equippable
        if equippable ~= nil then
            local eslot = equippable:EquipSlot()
            if eslot == EQUIPSLOTS.HANDS then
                return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.TOOL)
            elseif eslot == EQUIPSLOTS.HEAD or eslot == EQUIPSLOTS.BODY then
                return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.CLOTHING)
            end
        end
        --edible
        for k, v in pairs(FOODTYPE) do
            if self:HasTag("edible_"..v) then
                return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.FOOD)
            end
        end
        --fuel
        for k, v in pairs(FUELTYPE) do
            if self:HasTag(v.."_fuel") then
                return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.FUEL)
            end
        end
        --generic
        return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.GENERIC)
    end
    return name
end

function EntityScript:GetDisplayName()
    local name = self:GetAdjectivedName()

    if self.prefab ~= nil then
        local name_extention = STRINGS.NAME_DETAIL_EXTENTION[string.upper(self.prefab)]
        if name_extention ~= nil then
            return name.."\n"..name_extention
        end
    end
    return name
end

--Can be used on clients
function EntityScript:GetIsWet()
    if self:HasTag("moistureimmunity") then
        return false
    end

    local replica = self.replica.inventoryitem or self.replica.moisture
    if replica ~= nil then
        return replica:IsWet()
    end
    return self:HasTag("wet") or TheWorld.state.iswet or (self:HasTag("swimming") and not self:HasTag("likewateroffducksback"))
end

function EntityScript:GetSkinBuild()
    if self.skin_build_name == nil then
        self.skin_build_name = GetBuildForItem(self.skinname) --cache the build name so we don't need to search for it in the item tables.
    end
    return self.skin_build_name
end

function EntityScript:GetSkinName()
    return self.override_skinname or self.skinname
end

function EntityScript:SetPrefabName(name)
    self.prefab = name
    self.entity:SetPrefabName(name)
    self.name = self.name or (STRINGS.NAMES[string.upper(self.prefab)] or "MISSING NAME")
end

function EntityScript:SetPrefabNameOverride(nameoverride)
    --Changes what description and name will show for the prefab without actually overriding the prefab itself.
    --nameoverride should be the prefab that you wish to use for name and description. (IE: "spiderhole_rock" uses "spiderhole")
    self.nameoverride = nameoverride
end

function EntityScript:SetDeployExtraSpacing(spacing)
    --Extra spacing required when deploying other entities near this one.
    self.deploy_extra_spacing = spacing
    if spacing ~= nil then
        --see components/map.lua
        TheWorld.Map:RegisterDeployExtraSpacing(spacing)
    end
end

function EntityScript:SetTerraformExtraSpacing(spacing)
    --Extra spacing around entity that connot be terraformed.
    self.terraform_extra_spacing = spacing
    if spacing ~= nil then
        self:AddTag("terraformblocker")
        --see components/map.lua
        TheWorld.Map:RegisterTerraformExtraSpacing(spacing)
    else
        self:RemoveTag("terraformblocker")
    end
end

function EntityScript:SetGroundTargetBlockerRadius(radius)
    --Extra spacing around entity that connot be terraformed.
    self.ground_target_blocker_radius = radius
    if radius ~= nil then
        self:AddTag("groundtargetblocker")
        --see components/map.lua
        TheWorld.Map:RegisterGroundTargetBlocker(radius)
    else
        self:RemoveTag("groundtargetblocker")
    end
end

function EntityScript:SpawnChild(name)
    if self.prefabs then
        assert(self.prefabs, "no prefabs registered for this entity ".. name)
        local prefab = self.prefabs[name]
        assert(prefab, "Could not spawn unknown child type "..name)
        local inst = SpawnPrefab(prefab)
        assert(inst, "Could not spawn prefab "..name.." "..prefab)
        self:AddChild(inst)
        return inst
    else
        local inst = SpawnPrefab(name)
        self:AddChild(inst)
        return inst
    end

end

function EntityScript:RemoveChild(child)
    child.parent = nil
    if self.children then
        self.children[child] = nil
    end
    child.entity:SetParent(nil)
end

function EntityScript:AddChild(child)
    child.platform = nil

    if child.parent then
        child.parent:RemoveChild(child)
    end

    child.parent = self
    if not self.children then
        self.children = {}
    end

    self.children[child] = true
    child.entity:SetParent(self.entity)
end

function EntityScript:RemovePlatformFollower(child)
    if child.platform ~= self then
        return
    end

    child.platform = nil
    if self.platformfollowers then
        self.platformfollowers[child] = nil
    end
    child.entity:SetPlatform(nil)
end

function EntityScript:AddPlatformFollower(child)
    child.parent = nil

    if child.platform then
        child.platform:RemovePlatformFollower(child)
    end

    child.platform = self
    if not self.platformfollowers then
        self.platformfollowers = {}
    end

    self.platformfollowers[child] = true
    child.entity:SetPlatform(self.entity)
end

--only works on master sim
function EntityScript:GetPlatformFollowers()
    return self.platformfollowers
end

function EntityScript:GetBrainString()
    local str = {}

    if self.brain then
        table.insert(str, "BRAIN:\n")
        table.insert(str, tostring(self.brain))
        table.insert(str, "--------\n")
    end

    return table.concat(str, "")
end

function EntityScript:GetDebugString()
    if not self:IsValid() then
        return tostring(self).." <INVALID>"
    end

    local str = {}

    table.insert(str, tostring(self))
    if self:IsAsleep() then
        table.insert(str, " <ASLEEP>")
    end
    table.insert(str, string.format(" age %2.2f", self:GetTimeAlive()))
    table.insert(str, "\n")

    table.insert(str, self.entity:GetDebugString())

    table.insert(str, "Buffered Action: "..tostring(self.bufferedaction).."\n")

    if self.sg then
        table.insert(str, "SG:" .. tostring(self.sg).."\n")
    end

    if self.debugstringfn then
        table.insert(str, "DebugString: "..self:debugstringfn().."\n")
    end

    table.insert(str, "-----------\n")

    ----[[
    local cmpkeys = {}
    for k,v in pairs(self.components) do
        table.insert(cmpkeys, k)
    end
    table.sort(cmpkeys)
    for i,key in ipairs(cmpkeys) do
        if self.components[key].GetDebugString and self.components[key]:GetDebugString() then
            table.insert(str, key..": "..self.components[key]:GetDebugString().."\n")
        end
    end
    --]]

    --[[if self.brain then
        table.insert(str, "-------\nBRAIN:\n")
        table.insert(str, tostring(self.brain))
        table.insert(str, "--------\n")
    end
    --]]

    --[[
    if self.event_listening or self.event_listeners then
        table.insert(str, "-------\n")
    end
    if self.event_listening then
        table.insert(str, "Listening for Events:\n")
        for event, sources in pairs(self.event_listening) do
            table.insert(str, string.format("\t%s%s: ", event, GetTableSize(sources) > 1 and string.format("(%u)", GetTableSize(sources)) or "") )

            local max_list = 5 -- this can be a very long list
            local n = 0
            for source, fns in pairs(sources) do
                table.insert(str, string.format("%s%s%s", n > 0 and ", " or "", tostring(source), #fns > 1 and string.format("(%u)", #fns) or ""))
                n = n + 1
                if n >= max_list then 
                    break 
                end
            end
            table.insert(str, "\n")
        end
    end

    if self.event_listeners then
        table.insert(str, "Broadcasting Events:\n")
        for event, listeners in pairs(self.event_listeners) do
            table.insert(str, string.format("\t%s%s: ", event, GetTableSize(listeners) > 1 and string.format("(%u)", GetTableSize(listeners)) or "") )
            local max_list = 5 -- this can be a very long list
            local n = 0
            for listener, fns in pairs(listeners) do
                table.insert(str, string.format("%s%s%s", n > 0 and ", " or "", tostring(listener), #fns > 1 and string.format("(%u)", #fns) or ""))
                n = n + 1
                if n >= max_list then 
                    break 
                end
            end
            table.insert(str, "\n")
        end
    end

    --]]
    --[[
    if self.pendingtasks then
        table.insert(str, "-------\nPending tasks:\n")
        for id,task in pairs(self.pendingtasks) do
            if task then
                table.insert(str, tostring(id)..": "..task.name.. " " ..task.tick)
            end
        end
    end
    --]]
    return table.concat(str, "")
end

function EntityScript:KillTasks()
    KillThreadsWithID(self.GUID)
end

function EntityScript:StartThread(fn)
    return StartThread(fn, self.GUID)
end

function EntityScript:RunScript(name)
    local fn = LoadScript(name)
    fn(self)
end

function EntityScript:RestartBrain()
    self:StopBrain()
    if self.brainfn ~= nil then
        --if type(self.brainfn) ~= "table" then print(self, self.brainfn) end
        self.brain = self.brainfn()
        if self.brain ~= nil then
            self.brain.inst = self
            self.brain:Start()
        end
    end
end

function EntityScript:StopBrain()
    if self.brain ~= nil then
        self.brain:Stop()
        self.brain = nil
    end
end

function EntityScript:SetBrain(brainfn)
    self.brainfn = brainfn
    if self.brain ~= nil then
        self:RestartBrain()
    end
end

function EntityScript:SetStateGraph(name)
    if self.sg ~= nil then
        SGManager:RemoveInstance(self.sg)
    end
    local sg = LoadStateGraph(name)
    assert(sg ~= nil)
    if sg ~= nil then
        self.sg = StateGraphInstance(sg, self)
        SGManager:AddInstance(self.sg)
        self.sg:GoToState(self.sg.sg.defaultstate)
        return self.sg
    end
end

function EntityScript:ClearStateGraph()
    if self.sg ~= nil then
        SGManager:RemoveInstance(self.sg)
        self.sg = nil
    end
end

local function AddListener(t, event, inst, fn)
    local listeners = t[event]
    if not listeners then
        listeners = {}
        t[event] = listeners
    end

    local listener_fns = listeners[inst]
    if not listener_fns then
        listener_fns = {}
        listeners[inst] = listener_fns
    end

    --source.event_listeners[event][self][1]

    table.insert(listener_fns, fn)
end

function EntityScript:ListenForEvent(event, fn, source)
    --print ("Listen for event", self, event, source)
    source = source or self

    if not source.event_listeners then
        source.event_listeners = {}
    end

    AddListener(source.event_listeners, event, self, fn)


    if not self.event_listening then
        self.event_listening = {}
    end

    AddListener(self.event_listening, event, source, fn)

end

local function RemoveListener(t, event, inst, fn)
    if t then
        local listeners = t[event]
        if listeners then
            local listener_fns = listeners[inst]
            if listener_fns then
                RemoveByValue(listener_fns, fn)
                if next(listener_fns) == nil then
                    listeners[inst] = nil
                end
            end
            if next(listeners) == nil then
                t[event] = nil
            end
        end
    end
end


function EntityScript:RemoveEventCallback(event, fn, source)
    assert(type(fn) == "function") -- signature change, fn is new parameter and is required

    source = source or self

    RemoveListener(source.event_listeners, event, self, fn)
    RemoveListener(self.event_listening, event, source, fn)

end

function EntityScript:RemoveAllEventCallbacks()

    --self.event_listening[event][source][1]

    --tell others that we are no longer listening for them
    if self.event_listening then
        for event, sources  in pairs(self.event_listening) do
            for source, fns in pairs(sources) do
                if source.event_listeners then
                    local listeners = source.event_listeners[event]
                    if listeners then
                        listeners[self] = nil
                    end
                end
            end
        end
        self.event_listening = nil
    end    

    --tell others who are listening to us to stop
    if self.event_listeners then
        for event, listeners in pairs(self.event_listeners) do
            for listener, fns in pairs(listeners) do
                if listener.event_listening then
                    local sources = listener.event_listening[event]
                    if sources then
                        sources[self] = nil
                    end
                end
            end
        end
        self.event_listeners = nil
    end
end

function EntityScript:WatchWorldState(var, fn)
    EntityWatchWorldState(self, var, fn)
    TheWorld.components.worldstate:AddWatcher(var, self, fn, self)
end

function EntityScript:StopWatchingWorldState(var, fn)
    EntityStopWatchingWorldState(self, var, fn)
    TheWorld.components.worldstate:RemoveWatcher(var, self, fn, self)
end

function EntityScript:StopAllWatchingWorldStates()
    if self.worldstatewatching ~= nil then
        for var in pairs(self.worldstatewatching) do
            TheWorld.components.worldstate:RemoveWatcher(var, self)
        end

        self.worldstatewatching = nil
    end
end

function EntityScript:PushEvent(event, data)
    if self.event_listeners then
        local listeners = self.event_listeners[event]
        if listeners then
            --make a copy list of all callbacks first in case
            --listener tables become altered in some handlers
            local tocall = {}
            for entity, fns in pairs(listeners) do
                for i, fn in ipairs(fns) do
                    table.insert(tocall, fn)
                end
            end
            for i, fn in ipairs(tocall) do
                fn(self, data)
            end
        end
    end

    if self.sg and
        self.sg:IsListeningForEvent(event) and
        SGManager:OnPushEvent(self.sg) then
        self.sg:PushEvent(event, data)
    end

    if self.brain then
        self.brain:PushEvent(event, data)
    end
end

function EntityScript:SetPhysicsRadiusOverride(radius)
    self.physicsradiusoverride = radius
end

function EntityScript:GetPhysicsRadius(default)
    return self.physicsradiusoverride or (self.Physics ~= nil and self.Physics:GetRadius()) or default
end

function EntityScript:GetPosition()
    return Point(self.Transform:GetWorldPosition())
end

function EntityScript:GetRotation()
    return self.Transform:GetRotation()
end

function EntityScript:GetAngleToPoint(x, y, z)
    if x == nil then
        return 0
    elseif y == nil and z == nil then
        x, y, z = x:Get()
    end    
    local x1, y1, z1 = self.Transform:GetWorldPosition()
    return math.atan2(z1 - z, x - x1) / DEGREES
end

function EntityScript:GetPositionAdjacentTo(target, distance)
    if target == nil then
        return nil
    end
    local p1 = Vector3(self.Transform:GetWorldPosition())
    local p2 = Vector3(target.Transform:GetWorldPosition())
    local offset = p1-p2
    offset:Normalize()
    offset = offset * distance
    return (p2 + offset)
end

function EntityScript:ForceFacePoint(x, y, z)
    self.Transform:SetRotation(self:GetAngleToPoint(x, y, z))
end

function EntityScript:FacePoint(x, y, z)
    if self.sg ~= nil and self.sg:HasStateTag("busy") then
        return
    end
    self.Transform:SetRotation(self:GetAngleToPoint(x, y, z))
end

-- consider using IsNear if you're checking if something is inside/outside a certain horizontal distance
function EntityScript:GetDistanceSqToInst(inst)
    assert(self:IsValid() and inst:IsValid())
    local p1x, p1y, p1z = self.Transform:GetWorldPosition()
    local p2x, p2y, p2z = inst.Transform:GetWorldPosition()
    return distsq(p1x, p1z, p2x, p2z)
end

function EntityScript:IsNear(otherinst, dist)
    return otherinst ~= nil and self:GetDistanceSqToInst(otherinst) < dist * dist
end

function EntityScript:GetDistanceSqToPoint(x, y, z)
    if y == nil and z == nil and x ~= nil then
        x, y, z = x:Get()
    end
    local x1, y1, z1 = self.Transform:GetWorldPosition()
    return distsq(x, z, x1, z1)
end

function EntityScript:IsNearPlayer(range, isalive)
    local x, y, z = self.Transform:GetWorldPosition()
    return IsAnyPlayerInRange(x, y, z, range, isalive)
end

function EntityScript:GetNearestPlayer(isalive)
    local x, y, z = self.Transform:GetWorldPosition()
    return FindClosestPlayer(x, y, z, isalive)
end

function EntityScript:GetDistanceSqToClosestPlayer(isalive)
    local x, y, z = self.Transform:GetWorldPosition()
    local player, distsq = FindClosestPlayer(x, y, z, isalive)
    return distsq or math.huge
end

function EntityScript:FaceAwayFromPoint(dest, force)
    if not force and self.sg ~= nil and self.sg:HasStateTag("busy") then
        return
    end
    local x, y, z = self.Transform:GetWorldPosition()
    self.Transform:SetRotation(math.atan2(z - dest.z, dest.x - x) / DEGREES + 180)
end

function EntityScript:IsAsleep()
    return not self.entity:IsAwake()
end

function EntityScript:CancelAllPendingTasks()
    if self.pendingtasks then
        for k,v in pairs(self.pendingtasks) do
            k:Cancel()
        end
        self.pendingtasks = nil
    end
end

local function task_finish(task, success, inst)
    --print ("TASK DONE", task, success, inst)
    if inst and inst.pendingtasks and inst.pendingtasks[task] then
        inst.pendingtasks[task] = nil
    else
        print ("   NOT FOUND")
    end
end

function EntityScript:DoStaticPeriodicTask(time, fn, initialdelay, ...)
    --print ("DO PERIODIC", time, self)
    local per = staticScheduler:ExecutePeriodic(time, fn, nil, initialdelay, self.GUID, self, ...)

    if not self.pendingtasks then
        self.pendingtasks = {}
    end

    self.pendingtasks[per] = true
    per.onfinish = task_finish --function() if self.pendingtasks then self.pendingtasks[per] = nil end end
    return per
end

function EntityScript:DoStaticTaskInTime(time, fn, ...)
    --print ("DO TASK IN TIME", time, self)
    if not self.pendingtasks then
        self.pendingtasks = {}
    end

    local per = staticScheduler:ExecuteInTime(time, fn, self.GUID, self, ...)
    self.pendingtasks[per] = true
    per.onfinish = task_finish -- function() if self and self.pendingtasks then self.pendingtasks[per] = nil end end
    return per
end

function EntityScript:DoPeriodicTask(time, fn, initialdelay, ...)

    --print ("DO PERIODIC", time, self)
    local per = scheduler:ExecutePeriodic(time, fn, nil, initialdelay, self.GUID, self, ...)

    if not self.pendingtasks then
        self.pendingtasks = {}
    end

    self.pendingtasks[per] = true
    per.onfinish = task_finish --function() if self.pendingtasks then self.pendingtasks[per] = nil end end
    return per
end

function EntityScript:DoTaskInTime(time, fn, ...)
    --print ("DO TASK IN TIME", time, self)
    if not self.pendingtasks then
        self.pendingtasks = {}
    end

    local per = scheduler:ExecuteInTime(time, fn, self.GUID, self, ...)
    self.pendingtasks[per] = true
    per.onfinish = task_finish -- function() if self and self.pendingtasks then self.pendingtasks[per] = nil end end
    return per
end

function EntityScript:GetTaskInfo(time)
    local taskinfo = {}
    taskinfo.start = GetTime()
    taskinfo.time = time
    return taskinfo
end

function EntityScript:TimeRemainingInTask(taskinfo)
    local timeleft = (taskinfo.start + taskinfo.time) - GetTime()
    if timeleft < 1 then timeleft = 1 end
    return timeleft
end

function EntityScript:ResumeTask(time, fn, ...)
    local task = self:DoTaskInTime(time, fn, ...)
    local taskinfo = self:GetTaskInfo(time)

    return task, taskinfo
end

function EntityScript:ClearBufferedAction()
    if self.bufferedaction ~= nil then
        self.bufferedaction:Fail()
        self.bufferedaction = nil
    end
end

EntityScript.InterruptBufferedAction = EntityScript.ClearBufferedAction

function EntityScript:PreviewBufferedAction(bufferedaction)
    if bufferedaction ~= nil and
        self.bufferedaction ~= nil and
        bufferedaction.target == self.bufferedaction.target and
        bufferedaction.action == self.bufferedaction.action and
        bufferedaction.inv_obj == self.bufferedaction.inv_obj and
        not (self.sg ~= nil and self.sg:HasStateTag("idle") and self:HasTag("idle")) then
        return
    end

    if bufferedaction.action == ACTIONS.WALKTO then
        self.bufferedaction = nil
    elseif self.sg ~= nil then
        self.bufferedaction = bufferedaction
        if not self.sg:PreviewAction(bufferedaction) then
            self.bufferedaction = nil
        end
    elseif bufferedaction.action.instant then
        self.bufferedaction = bufferedaction
        self:PerformPreviewBufferedAction()
    else
        self.bufferedaction = nil
    end
end

function EntityScript:PerformPreviewBufferedAction()
    if self.bufferedaction ~= nil and not self.bufferedaction.ispreviewing then
        if self.components.playercontroller ~= nil then
            self.components.playercontroller:RemoteBufferedAction(self.bufferedaction)
        end
        self.bufferedaction.ispreviewing = true
    end
end

function EntityScript:PushBufferedAction(bufferedaction)
    if bufferedaction ~= nil and
        self.bufferedaction ~= nil and
        bufferedaction.target == self.bufferedaction.target and
        bufferedaction.action == self.bufferedaction.action and
        bufferedaction.inv_obj == self.bufferedaction.inv_obj and
        not (self.sg ~= nil and self.sg:HasStateTag("idle")) then
        return
    end

    if self.bufferedaction ~= nil then
        self.bufferedaction:Fail()
        self.bufferedaction = nil
    end

    local success, reason = bufferedaction:TestForStart()
    if not success then
        self:PushEvent("actionfailed", { action = bufferedaction, reason = reason })
        return
    end

    --walkto is kind of a nil action - the locomotor will have put us at the destination by now if we get to here
    if bufferedaction.action == ACTIONS.WALKTO then
        self:PushEvent("performaction", { action = bufferedaction })
        bufferedaction:Succeed()
        self.bufferedaction = nil
    elseif bufferedaction.action.instant then
        if bufferedaction.target ~= nil and bufferedaction.target.Transform ~= nil and (self.sg == nil or self.sg:HasStateTag("canrotate")) then
            self:FacePoint(bufferedaction.target.Transform:GetWorldPosition())
        end
        self:PushEvent("performaction", { action = bufferedaction })
        bufferedaction:Do()
        self.bufferedaction = nil
    else
        self.bufferedaction = bufferedaction
        if self.sg == nil then
            self:PushEvent("startaction", { action = bufferedaction })
        elseif not self.sg:StartAction(bufferedaction) then
            self:PushEvent("performaction", { action = bufferedaction })
            self.bufferedaction:Fail()
            self.bufferedaction = nil
        end
    end
end

function EntityScript:PerformBufferedAction()
    if self.bufferedaction then
        if self.bufferedaction.target and self.bufferedaction.target:IsValid() and self.bufferedaction.target.Transform then
            self:FacePoint(self.bufferedaction.target.Transform:GetWorldPosition())
        end

        self:PushEvent("performaction", { action = self.bufferedaction })

		local action_theme_music = self:HasTag("player") and (self.bufferedaction.action.theme_music or (self.bufferedaction.action.theme_music_fn ~= nil and self.bufferedaction.action.theme_music_fn(self.bufferedaction)))
		if action_theme_music then
			self:PushEvent("play_theme_music", {theme = action_theme_music})
		end

        local success, reason = self.bufferedaction:Do()
        if success then
            self.bufferedaction = nil
            return true
        end

        self:PushEvent("actionfailed", { action = self.bufferedaction, reason = reason })

        self.bufferedaction:Fail()
        self.bufferedaction = nil
    end
end

function EntityScript:GetBufferedAction()
    return self.bufferedaction or (self.components.locomotor ~= nil and self.components.locomotor.bufferedaction) or nil
end

function EntityScript:OnBuilt(builder)
    for k,v in pairs(self.components) do
        if v.OnBuilt then
            v:OnBuilt(builder)
        end
    end

    if self.OnBuiltFn then
        self:OnBuiltFn(builder)
    end
end

function EntityScript:Remove()
    if self.parent then
        self.parent:RemoveChild(self)
    end

    if self.platform then
        self.platform:RemovePlatformFollower(self)
    end

    OnRemoveEntity(self.GUID)

    self:PushEvent("onremove")

    --tell our listeners to forget about us
    self:StopAllWatchingWorldStates()
    self:RemoveAllEventCallbacks()
    self:CancelAllPendingTasks()

    for k, v in pairs(self.components) do
        if v and type(v) == "table" and v.OnRemoveEntity then
            v:OnRemoveEntity()
        end
    end

    for k, v in pairs(rawget(self.replica, "_")) do
        if v and type(v) == "table" and v.OnRemoveEntity then
            v:OnRemoveEntity()
        end
    end

    if self.updatecomponents then
        self.updatecomponents = nil
        UpdatingEnts[self.GUID] = nil
        num_updating_ents = num_updating_ents - 1
    end
    NewUpdatingEnts[self.GUID] = nil

    if self.updatestaticcomponents then
        self.updatestaticcomponents = nil
        StaticUpdatingEnts[self.GUID] = nil
    end
    NewStaticUpdatingEnts[self.GUID] = nil

    if self.wallupdatecomponents then
        self.wallupdatecomponents = nil
        WallUpdatingEnts[self.GUID] = nil
    end
    NewWallUpdatingEnts[self.GUID] = nil

    if self.children then
        for k,v in pairs(self.children) do
            k.parent = nil
            k:Remove()
        end
    end

    if self.platformfollowers then
        for k,v in pairs(self.platformfollowers) do
            k.platform = nil
        end
    end

    if self.OnRemoveEntity then
        self:OnRemoveEntity()
    end
    self.persists = false
    self.entity:Retire()
end

function EntityScript:IsValid()
    return self.entity:IsValid()
end

function EntityScript:CanInteractWith(inst)
    if not inst:IsValid() then
        return false
    end
    local parent = inst.entity:GetParent()
    if parent and parent ~= self then
        return false
    end

    return true
end

function EntityScript:OnUsedAsItem(action, doer, target)
    for k,v in pairs(self.components) do
        if v.OnUsedAsItem then
            v:OnUsedAsItem(action, doer, target)
        end
    end
end

function EntityScript:CanDoAction(action)
    if self.inherentactions ~= nil and self.inherentactions[action] then
        return true
    end
    if self:HasTag(action.id.."_tool") then
        return true
    end
    local inventory = self.replica.inventory
    if inventory ~= nil then
        local item = inventory:GetActiveItem()
        if item ~= nil and item:CanDoAction(action) then
            return true
        end
        item = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil and item:CanDoAction(action) then
            return true
        end
    end
end

function EntityScript:IsOnValidGround() -- this currently does not support boats. IsOnPassablePoint may be what you actually want to call
	return TheWorld.Map:IsVisualGroundAtPoint(self.Transform:GetWorldPosition())
end

function EntityScript:IsOnPassablePoint(include_water, floating_platforms_are_not_passable)
    local x, y, z = self.Transform:GetWorldPosition()
    return TheWorld.Map:IsPassableAtPoint(x, y, z, include_water or false, floating_platforms_are_not_passable or false)
end

function EntityScript:IsOnOcean(allow_boats)
    local x, y, z = self.Transform:GetWorldPosition()
    return TheWorld.Map:IsOceanAtPoint(x, y, z, allow_boats)
end

function EntityScript:GetCurrentPlatform()
    if TheWorld.ismastersim then
        if self.parent then
            return self.parent:GetCurrentPlatform()
        end
        return self.platform
    else
        local parent = self.entity:GetParent()
        if parent then
            return parent:GetCurrentPlatform()
        end
        return self.entity:GetPlatform()
    end
end

function EntityScript:GetCurrentTileType()
-- WARNING: This function is only an approximate, if you only care if the ground is valid or not then call IsOnValidGround()
    local map = TheWorld.Map
    local ptx, pty, ptz = self.Transform:GetWorldPosition()
    local tilecenter_x, tilecenter_y, tilecenter_z  = map:GetTileCenterPoint(ptx, 0, ptz)
    local tx, ty = map:GetTileCoordsAtPoint(ptx, 0, ptz)
    local actual_tile = map:GetTile(tx, ty)

    if actual_tile ~= nil and tilecenter_x ~= nil and tilecenter_z ~= nil then
        if actual_tile >= GROUND.UNDERGROUND then
            local xpercent = (tilecenter_x - ptx) / TILE_SCALE + .25
            local ypercent = (tilecenter_z - ptz) / TILE_SCALE + .25

            local x_min = xpercent > .666 and -1 or 0
            local x_max = xpercent < .333 and 1 or 0
            local y_min = ypercent > .666 and -1 or 0
            local y_max = ypercent < .333 and 1 or 0

            local x_off = 0
            local y_off = 0

            for x = x_min, x_max do
                for y = y_min, y_max do
                    local tile = map:GetTile(tx + x, ty + y)
                    if tile > actual_tile then
                        actual_tile = tile
                        x_off = x
                        y_off = y
                    end
                end
            end
        end

        return actual_tile, GetTileInfo(actual_tile)
    end

    --print (string.format("(%d+%d, %d+%d), (%2.2f, %2.2f), %d", tx, x_off, ty, y_off, xpercent, ypercent, actual_tile))
end

function EntityScript:PutBackOnGround()
	local x, y, z = self.Transform:GetWorldPosition()
    if not TheWorld.Map:IsPassableAtPoint(x, y, z, true) then
        local dest = FindNearbyLand(self:GetPosition(), 8) or FindNearbyOcean(self:GetPosition(), 8)
        if dest ~= nil then
            if self.Physics ~= nil then
                self.Physics:Teleport(dest:Get())
            elseif self.Transform ~= nil then
                self.Transform:SetPosition(dest:Get())
            end
        end
    end
end

function EntityScript:GetPersistData()
    local references = {}
    local data = {}
    for k, v in pairs(self.components) do
        if v.OnSave then
            local t, refs = v:OnSave()
            if type(t) == "table" and not IsTableEmpty(t) then
                data[k] = t
            end

            if refs then
                for k1, v1 in pairs(refs) do
                    table.insert(references, v1)
                end
            end
        end
    end

    if self.OnSave then
        local refs = self.OnSave(self, data)

        if refs then
            for k, v in pairs(refs) do
                table.insert(references, v)
            end
        end
    end

    if not IsTableEmpty(data) or not IsTableEmpty(references) then
        return data, references
    end
end

function EntityScript:LoadPostPass(newents, savedata)
    if savedata ~= nil then
        for k, v in pairs(savedata) do
            local cmp = self.components[k]
            if cmp ~= nil and cmp.LoadPostPass ~= nil then
                cmp:LoadPostPass(newents, v)
            end
        end
    end

    if self.OnLoadPostPass ~= nil then
        self:OnLoadPostPass(newents, savedata)
    end
end

function EntityScript:SetPersistData(data, newents)
    if self.OnPreLoad ~= nil then
        self:OnPreLoad(data, newents)
    end

    if data ~= nil then
        for k, v in pairs(data) do
            local cmp = self.components[k]
            if cmp == nil and type(v) == "table" and v.add_component_if_missing then
				self:AddComponent(k)
                cmp = self.components[k]
            end
            if cmp ~= nil and cmp.OnLoad ~= nil then
                cmp:OnLoad(v, newents)
            end
        end
    end

    if self.OnLoad ~= nil then
        self:OnLoad(data, newents)
    end
end

function EntityScript:GetAdjective()
	if self.displayadjectivefn ~= nil then
		return self:displayadjectivefn(self)
	elseif self:HasTag("critter") then
		for k,_ in pairs(TUNING.CRITTER_TRAITS) do
			if self:HasTag("trait_"..k) then
				return STRINGS.UI.HUD.CRITTER_TRAITS[k]
			end
		end
    elseif self:HasTag("small_livestock") then
        return not self:HasTag("sickness")
            and ((self:HasTag("stale") and STRINGS.UI.HUD.HUNGRY) or
                (self:HasTag("spoiled") and STRINGS.UI.HUD.STARVING))
            or nil
    elseif self:HasTag("stale") then
        return self:HasTag("frozen") and STRINGS.UI.HUD.STALE_FROZEN or STRINGS.UI.HUD.STALE
    elseif self:HasTag("spoiled") then
        return self:HasTag("frozen") and STRINGS.UI.HUD.STALE_FROZEN or STRINGS.UI.HUD.SPOILED
    end
end

function EntityScript:SetInherentSceneAction(action)
    self.inherentsceneaction = action
    if self.actionreplica.inherentsceneaction ~= nil then
        self.actionreplica.inherentsceneaction:set(SerializeAction(action))
    end
end

function EntityScript:SetInherentSceneAltAction(action)
    self.inherentscenealtaction = action
    if self.actionreplica.inherentscenealtaction ~= nil then
        self.actionreplica.inherentscenealtaction:set(SerializeAction(action))
    end
end

function EntityScript:LongUpdate(dt)
    if self.OnLongUpdate ~= nil then
        self:OnLongUpdate(dt)
    end

    for k, v in pairs(self.components) do
        if v.LongUpdate ~= nil then
            v:LongUpdate(dt)
        end
    end
end

function EntityScript:SetClientSideInventoryImageOverride(flagname, srcinventoryimage, destinventoryimage, destatlas)
    --destatlas is optional
    self.inventoryimageremapping = self.inventoryimageremapping or {}
    self.inventoryimageremapping[flagname] = self.inventoryimageremapping[flagname] or {}
    self.inventoryimageremapping[flagname][hash(srcinventoryimage)] = {image = destinventoryimage, atlas = destatlas}
    if ClientSideInventoryImageFlags[flagname] and ThePlayer then
        ThePlayer:PushEvent("clientsideinventoryflagschanged")
    end
end

function EntityScript:HasClientSideInventoryImageOverrides()
    return self.inventoryimageremapping ~= nil
end

--do not call this if you have no client side inventory image overrides
function EntityScript:GetClientSideInventoryImageOverride(imagenamehash)
    for flag, remaps in pairs(self.inventoryimageremapping) do
        if ClientSideInventoryImageFlags[flag] and remaps[imagenamehash] then
            return remaps[imagenamehash]
        end
    end
end

function EntityScript:SetClientSideInventoryImageOverrideFlag(name, value)
    value = (not value) ~= true or nil
    local updated = ClientSideInventoryImageFlags[name] ~= value
    ClientSideInventoryImageFlags[name] = value
    if updated and ThePlayer then
        ThePlayer:PushEvent("clientsideinventoryflagschanged")
    end
end

function EntityScript:IsInLight()
    if self.LightWatcher then
        return self.LightWatcher:IsInLight()
    else
        local lightThresh = self.lightThresh or 0.1
        local darkThresh = self.darkThresh or 0.05

        local x, y, z = self.Transform:GetWorldPosition()
        local light = TheSim:GetLightAtPoint(x, y, z, lightThresh)

        local move_to_light = self.inLight == false and light >= lightThresh

        if move_to_light or (self.inLight ~= false and light <= darkThresh) then
            self.inLight = move_to_light
        end

        return self.inLight ~= false
    end
end

function EntityScript:IsLightGreaterThan(lightThresh)
    if self.LightWatcher then
        return self.LightWatcher:GetLightValue() >= lightThresh
    else
        local x, y, z = self.Transform:GetWorldPosition()
        return TheSim:GetLightAtPoint(x, y, z, lightThresh) >= lightThresh
    end
end

function EntityScript:DebuffsEnabled()
    return self.components.debuffable == nil or self.components.debuffable:IsEnabled()
end

function EntityScript:HasDebuff(name)
    if self.components.debuffable == nil then
        return false
    end
    return self.components.debuffable:HasDebuff(name)
end

function EntityScript:GetDebuff(name)
    if self.components.debuffable == nil then
        return nil
    end
    return self.components.debuffable:GetDebuff(name)
end

function EntityScript:AddDebuff(name, prefab, data, skip_test, pre_buff_fn)
    if self.components.debuffable == nil then
        self:AddComponent("debuffable")
    end

    if skip_test or (self:DebuffsEnabled() and not IsEntityDeadOrGhost(self)) then
        if pre_buff_fn then
            pre_buff_fn()
        end
        self.components.debuffable:AddDebuff(name, prefab, data)
        return true
    end

    return false
end

function EntityScript:RemoveDebuff(name)
    if self.components.debuffable == nil then
        return
    end
    self.components.debuffable:RemoveDebuff(name)
end