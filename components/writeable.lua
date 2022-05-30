local writeables = require"writeables"

local function gettext(inst, viewer)
	if inst:HasTag("burnt") then
		return GetDescription(viewer, inst, "BURNT")
	end

	local writeable = inst.components.writeable
    local text = writeable:GetText()
	if text ~= nil then
		if IsXB1() then
			return string.format('"%s"', text)
		else
			return text, writeable.text_filter_context or TEXT_FILTER_CTX_CHAT, writeable.writer_netid
		end
	end

    return GetDescription(viewer, inst, "UNWRITTEN")
end

local function onbuilt(inst, data)
    inst.components.writeable:BeginWriting(data.builder)
end

--V2C: NOTE: do not add "writeable" tag to pristine state because it is more
--           likely for players to encounter signs that are already written.
local function ontextchange(self, text)
    if self.writeable_by_default then
        if text ~= nil then
            self.inst:RemoveTag("writeable")
            self.inst.AnimState:Show("WRITING")
        else
            self.inst:AddTag("writeable")
            self.inst.AnimState:Hide("WRITING")
        end
    end
end

local function onwriter(self, writer)
    self.inst.replica.writeable:SetWriter(writer)
end

local function onautodescribechanged(self, new_ad, old_ad)
    if new_ad then
        self.inst.components.inspectable.getspecialdescription = gettext
    else
        self.inst.components.inspectable.getspecialdescription = nil
    end
end

local Writeable = Class(function(self, inst)
    self.inst = inst

    self.writeable_by_default = true
    self.text = nil

    self.writer = nil
    self.screen = nil

    self.onclosepopups = function(doer) -- yay closures ~gj -- yay ~v2c
        if doer == self.writer then
            self:EndWriting()
        end
    end

    self.generatorfn = nil

    self.automatic_description = true

    self.writeable_distance = 3

    self.inst:ListenForEvent("onbuilt", onbuilt)

    --self.onwritten = nil
    --self.onwritingended = nil
end,
nil,
{
    text = ontextchange,
    writer = onwriter,
    automatic_description = onautodescribechanged,
})


function Writeable:OnSave()
    local data = {}

    data.text = self.text
	data.netid = self.writer_netid
	data.userid = self.writer_userid

    return data
end

function Writeable:OnLoad(data)
	if IsRail() then
    	self.text = TheSim:ApplyWordFilter(data.text)
	else
    	self.text = data.text
	end
	self.writer_netid = data.netid
	self.writer_userid = data.userid
end

function Writeable:SetOnWrittenFn(fn)
    self.onwritten = fn
end

function Writeable:SetOnWritingEndedFn(fn)
    self.onwritingended = fn
end

function Writeable:GetText()
	if IsXB1() then
		if self.text and self.writer_netid then
			return "\1"..self.text.."\1"..self.writer_netid
		end
	end
    return self.text
end

function Writeable:SetText(text)
    self.text = text
end

function Writeable:SetAutomaticDescriptionEnabled(ad_enabled)
    self.automatic_description = ad_enabled
end

function Writeable:SetDefaultWriteable(writeable_by_default)
    if writeable_by_default and not self.writeable_by_default then
        if self.text ~= nil then
            self.inst:RemoveTag("writeable")
            self.inst.AnimState:Show("WRITING")
        else
            self.inst:AddTag("writeable")
            self.inst.AnimState:Hide("WRITING")
        end
    elseif not writeable_by_default and self.writeable_by_default then
        self.inst:RemoveTag("writeable")
        self.inst.AnimState:Hide("WRITING")
    end
    self.writeable_by_default = writeable_by_default
end

function Writeable:SetWriteableDistance(dist)
    self.writeable_distance = dist
end

function Writeable:BeginWriting(doer)
    if self.writer == nil then
        self.inst:StartUpdatingComponent(self)

        self.writer = doer
        self.inst:ListenForEvent("ms_closepopups", self.onclosepopups, doer)
        self.inst:ListenForEvent("onremove", self.onclosepopups, doer)

        if doer.HUD ~= nil then
            self.screen = writeables.makescreen(self.inst, doer)
        end
    end
end

function Writeable:IsWritten()
    return self.text ~= nil
end

function Writeable:IsBeingWritten()
    return self.writer ~= nil
end

function Writeable:Write(doer, text)
    --NOTE: text may be network data, so enforcing length is
    --      NOT redundant in order for rendering to be safe.
    if self.writer == doer and doer ~= nil and
        (text == nil or text:utf8len() <= (writeables.GetLayout(self.inst.prefab).maxcharacters or MAX_WRITEABLE_LENGTH)) then

        if IsRail() then
			text = TheSim:ApplyWordFilter(text)
		end
        self:SetText(text)

        if self.onwritten ~= nil then
            self.onwritten(self.inst, text, doer)
        end

        self:EndWriting()

		if text ~= nil and self.remove_after_write then
			self.inst:Remove()
		end
    end
end

function Writeable:EndWriting()
    if self.writer ~= nil then
        self.inst:StopUpdatingComponent(self)

        if self.screen ~= nil then
            self.writer.HUD:CloseWriteableWidget()
            self.screen = nil
        end

        self.inst:RemoveEventCallback("ms_closepopups", self.onclosepopups, self.writer)
        self.inst:RemoveEventCallback("onremove", self.onclosepopups, self.writer)

		if self.writer:HasTag("player") then
			self.writer_userid = self.writer.userid
			self.writer_netid = TheNet:GetNetIdForUser(self.writer.userid)
		end

        if self.onwritingended ~= nil then
            self.onwritingended(self.inst)
        end

        self.writer = nil
    elseif self.screen ~= nil then
        --Should not have screen and no writer, but just in case...
        if self.screen.inst:IsValid() then
            self.screen:Kill()
        end
        self.screen = nil

        if self.onwritingended ~= nil then
            self.onwritingended(self.inst)
        end
    end
end

--------------------------------------------------------------------------
--Check for auto-closing conditions
--------------------------------------------------------------------------

function Writeable:OnUpdate(dt)
    if self.writer == nil then
        self.inst:StopUpdatingComponent(self)
    elseif (self.writer.components.rider ~= nil and
            self.writer.components.rider:IsRiding())
        or not (self.writer:IsNear(self.inst, self.writeable_distance) and
                CanEntitySeeTarget(self.writer, self.inst)) then
        self:EndWriting()
    end
end

--------------------------------------------------------------------------

function Writeable:OnRemoveFromEntity()
    self:EndWriting()
    self.inst:RemoveTag("writeable")
    self.inst:RemoveEventCallback("onbuilt", onbuilt)
    if self.inst.components.inspectable ~= nil and
        self.inst.components.inspectable.getspecialdescription == gettext then
        self.inst.components.inspectable.getspecialdescription = nil
    end
end

Writeable.OnRemoveEntity = Writeable.EndWriting

return Writeable
