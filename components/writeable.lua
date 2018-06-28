local writeables = require"writeables"

local function gettext(inst, viewer)
    local text = inst.components.writeable:GetText()
    return inst:HasTag("burnt") and GetDescription(viewer, inst, "BURNT") or
            text and string.format('"%s"', text)
            or GetDescription(viewer, inst, "UNWRITTEN")
end

local function onbuilt(inst, data)
    inst.components.writeable:BeginWriting(data.builder)
end

--V2C: NOTE: do not add "writeable" tag to pristine state because it is more
--           likely for players to encounter signs that are already written.
local function ontextchange(self, text)
    if text ~= nil then
        self.inst:RemoveTag("writeable")
        self.inst.AnimState:Show("WRITING")
    else
        self.inst:AddTag("writeable")
        self.inst.AnimState:Hide("WRITING")
    end
end

local function onwriter(self, writer)
    self.inst.replica.writeable:SetWriter(writer)
end

local Writeable = Class(function(self, inst)
    self.inst = inst
    self.text = nil

    self.writer = nil
    self.screen = nil

    self.onclosepopups = function(doer) -- yay closures ~gj -- yay ~v2c
        if doer == self.writer then
            self:EndWriting()
        end
    end

    self.generatorfn = nil

    inst.components.inspectable.getspecialdescription = gettext

    self.inst:ListenForEvent("onbuilt", onbuilt)
end,
nil,
{
    text = ontextchange,
    writer = onwriter,
})


function Writeable:OnSave()
    local data = {}

    data.text = self.text
	if IsXB1() then
		data.netid = self.netid
	end

    return data

end

function Writeable:OnLoad(data)
	if IsRail() then
    	self.text = TheSim:ApplyWordFilter(data.text)
	else
    	self.text = data.text
	end
	if IsXB1() then
		self.netid = data.netid
	end
end

function Writeable:GetText(viewer)
	if IsXB1() then
		if self.text and self.netid then
			return "\1"..self.text.."\1"..self.netid
		end
	end
    return self.text
end

function Writeable:SetText(text)
    self.text = text
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
        (text == nil or text:utf8len() <= MAX_WRITEABLE_LENGTH) then
        if IsRail() then
			text = TheSim:ApplyWordFilter(text)
		end
        self:SetText(text)
        self:EndWriting()
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

		if IsXB1() then
			if self.writer:HasTag("player") and self.writer:GetDisplayName() then
				local ClientObjs = TheNet:GetClientTable()
				if ClientObjs ~= nil and #ClientObjs > 0 then
					for i, v in ipairs(ClientObjs) do
						if self.writer:GetDisplayName() == v.name then
							self.netid = v.netid
							break
						end
					end
				end
			end
		end

        self.writer = nil
    elseif self.screen ~= nil then
        --Should not have screen and no writer, but just in case...
        if self.screen.inst:IsValid() then
            self.screen:Kill()
        end
        self.screen = nil
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
        or not (self.writer:IsNear(self.inst, 3) and
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
