
local isawhorde = UnitFactionGroup("player") == "Horde"
local defaults, db = {framepoint = "TOPLEFT", framex = 240, framey = -240}
local spellidlist = {20166, isawhorde and 53736 or 31801, 20165, 20164, 21084, 20375, isawhorde and 31892 or 53720}
local spells, icons, ids = {}, {}, {}
for _,id in pairs(spellidlist) do
	local name, _, icon = GetSpellInfo(id)
	table.insert(spells, name)
	icons[name], ids[name] = icon, id
end


local b = CreateFrame("CheckButton", "SealClubber", UIParent, "SecureActionButtonTemplate,SecureHandlerBaseTemplate")
b:SetWidth(36) b:SetHeight(36)
b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square") --ADD
b:RegisterForClicks("AnyUp")

local icon = b:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
icon:SetTexture(icons[spells[1]])

b:SetAttribute("*type*", "spell")
b:SetAttribute("unit", "player")
b:SetAttribute("spell", spells[1])

b:EnableMouseWheel(true)
b:Execute([[
	scrollactions = newtable( ']].. table.concat(spells, "','").. [[' )
	scrolloffset = 0
]])
b:WrapScript(b, "OnMouseWheel", [[
	scrolloffset = scrolloffset - offset
	if scrolloffset < 0 then scrolloffset = table.maxn(scrollactions) - 1 end
	if scrolloffset >= table.maxn(scrollactions) then scrolloffset = 0 end

	self:SetAttribute("spell", scrollactions[1 + scrolloffset])
]])


b:RegisterForDrag("LeftButton")
b:SetMovable(true)
b:SetClampedToScreen(true)
b:SetScript("OnDragStart", b.StartMoving)
b:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
	db.framepoint, db.framex, db.framey = "BOTTOMLEFT", frame:GetLeft(), frame:GetBottom()
end)


b:RegisterEvent("ADDON_LOADED")
b:SetScript("OnEvent", function(self, event, addon)
	if addon:lower() ~= "sealclubber" then return end

	SealClubberDB = setmetatable(SealClubberDB or {}, {__index = defaults})
	db = SealClubberDB

	self:SetPoint(db.framepoint, db.framex, db.framey)

	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:SetScript("OnEvent", function() for i,v in pairs(defaults) do if db[i] == v then db[i] = nil end end end)
end)


local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function SetTooltip(frame)
	local spell = frame:GetAttribute("spell")
	GameTooltip:SetOwner(frame, "ANCHOR_NONE")
	GameTooltip:SetPoint(GetTipAnchor(frame))
	GameTooltip:SetHyperlink("spell:"..ids[spell])
end

b:SetScript("OnLeave", function() GameTooltip:Hide() end)
b:SetScript("OnEnter", SetTooltip)
b:SetScript("OnAttributeChanged", function(self, attr, value)
	if attr ~= "spell" then return end
	icon:SetTexture(icons[value])
	SetTooltip(self)
end)


LibStub("tekKonfig-AboutPanel").new(nil, "SealClubber")
