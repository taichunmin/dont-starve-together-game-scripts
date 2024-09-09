local function CreateBG(self)
    local inst = CreateEntity("HealthBarBG")
    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddImage()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst.Image:SetTexture(resolvefilepath(self.bar_atlas), self.bar_image)
    inst.Image:SetTint(unpack(self.bg_colour))
    inst.Image:SetWorldOffset(self.bar_world_offset:Get())
    inst.Image:SetUIOffset(self.bar_ui_offset:Get())
    inst.Image:SetSize(self.bar_width, self.bar_height)
    inst.Image:Enable(false)

    inst.persists = false

    return inst
end

local function CreateBar(self)
    local inst = CreateEntity("healthBar")
    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddImage()
    inst.entity:AddLabel()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst.Image:SetTexture(resolvefilepath(self.bar_atlas), self.bar_image)
    inst.Image:SetTint(unpack(self.bar_colour))
    inst.Image:SetWorldOffset(self.bar_world_offset:Get())
    inst.Image:Enable(false)

    inst.Label:SetFontSize(16)
    inst.Label:SetFont(SMALLNUMBERFONT)
    inst.Label:SetWorldOffset(self.bar_world_offset:Get())
    inst.Label:SetUIOffset(self.label_ui_offset:Get())
    inst.Label:Enable(false)

    inst.fill_width = self.bar_width - self.bar_border * 2
    inst.fill_height = self.bar_height - self.bar_border * 2

    inst.persists = false

    return inst
end

local function OnHealthPctDirty(inst)
    local self = inst.components.healthbar
    self:SetValue(self._healthpct:value())
end

local function OnHealthDelta(inst, data)
    inst.components.healthbar._healthpct:set(data.newpercent)
    OnHealthPctDirty(inst)
end

local function OnInit(inst, self)
    self.bg = CreateBG(self)
    self.bg.entity:SetParent(inst.entity)

    self.bar = CreateBar(self)
    self.bar.entity:SetParent(inst.entity)

    if TheWorld.ismastersim then
        inst:ListenForEvent("healthdelta", OnHealthDelta)
        OnHealthDelta(inst, { newpercent = inst.components.health ~= nil and inst.components.health:GetPercent() or 1 })
    else
        inst:ListenForEvent("healthpctdirty", OnHealthPctDirty)
        OnHealthPctDirty(inst)
    end
end

local HealthBar = Class(function(self, inst)
    self.inst = inst

    ----------------------------------

    self.bar_atlas = "images/hud.xml"
    self.bar_image = "stat_bar.tex"

    self.bar_width = 100
    self.bar_height = 10
    self.bar_border = 1
    self.bar_colour = { .7, .1, 0, 1 }
    self.bg_colour = { .075, .07, .07, 1 }

    self.bar_world_offset = Vector3(0, 3, 0)
    self.bar_ui_offset = Vector3(12, 0, 0)
    self.label_ui_offset = Vector3(-50, 0, 0)

    ----------------------------------

    self.enabled = true

    self._healthpct = net_float(inst.GUID, "healthbar._healthpct", "healthpctdirty")
    self._healthpct:set(1)

    --Delay initialization to allow time for configuring the params above
    inst:DoTaskInTime(0, OnInit, self)
end)

local function SetVisible(self, visible)
    if self.bar ~= nil then
        self.bar.Label:Enable(visible)
        self.bar.Image:Enable(visible)
    end
    if self.bg ~= nil then
        self.bg.Image:Enable(visible)
    end
end

function HealthBar:Enable(enable)
    self.enabled = enable ~= false
    if self.enabled then
        self:SetValue(self._healthpct:value())
    else
        SetVisible(self, false)
    end
end

function HealthBar:SetValue(percent)
    if percent > 0 then
        local newwidth = self.bar.fill_width * percent
        local hp = math.max(1, math.floor(percent * 100))
        self.bar.Label:SetText(hp.."%")
        self.bar.Image:SetSize(newwidth, self.bar.fill_height)
        self.bar.Image:SetUIOffset(self.bar_ui_offset.x + (newwidth - self.bar.fill_width) * .5, self.bar_ui_offset.y, self.bar_ui_offset.z)
        SetVisible(self, self.enabled)
    else
        SetVisible(self, false)
    end
end

return HealthBar
