local K, C, L, _ = unpack(select(2, ...))
if K.Class ~= "MAGE" or K.Level < 24 then return end

--	By Foof and Tohveli
local spells = (UnitFactionGroup("player") == "Horde") and {
	[1] = {53140,53142},
	[2] = {3567,11417},
	[3] = {3563,11418},
	[4] = {3566,11420},
	[5] = {32272,32267},
	[6] = {35715,35717},
	[7] = {49358,49361},
	} or { -- ALLIANCE
	[1] = {53140,53142},
	[2] = {3561,10059},
	[3] = {3562,11416},
	[4] = {3565,11419},
	[5] = {32271,32266},
	[6] = {33690,33691},
	[7] = {49359,49360},
};

local f = CreateFrame("Frame", "TeleportMenu", UIParent)
f:CreatePanel2("Invisible", C.minimap.size, (#spells + 1) * 20 + 4, "TOPRIGHT", Minimap, "BOTTOMLEFT", -4, -4)
tinsert(UISpecialFrames, "TeleportMenu")

local r = CreateFrame("Frame", nil, f)
r:CreatePanel2("Transparent", C.minimap.size, 20, "BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
r:SetBackdropColor(unpack(C["media"].backdrop_color))

local l = r:CreateFontString("TeleportMenuReagentText", "OVERLAY", nil)
l:SetFont(C["font"].basic_font, C["font"].basic_font_size, C["font"].basic_font_style)
l:SetPoint("CENTER", r, "CENTER")

for i, spell in pairs(spells) do
	local teleport = GetSpellInfo(spell[1])
	
	local b = CreateFrame("Button", nil, f, "SecureActionButtonTemplate")
	b:CreatePanel2("Transparent", C.minimap.size, 20, "BOTTOMLEFT", f, "BOTTOMLEFT", 0, (i * 21))
	b:SetBackdropColor(unpack(C["media"].backdrop_color))
	
	local l = b:CreateFontString(nil, "OVERLAY", nil)
	l:SetFont(C["font"].basic_font, C["font"].basic_font_size, C["font"].basic_font_style)
	l:SetText(string.sub(teleport, string.find(teleport,":") + 1))
	b:SetFontString(l)
	
	b:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	b:SetAttribute("type1", "spell")
	b:SetAttribute("spell1", teleport)
	b:SetAttribute("type2", "spell")
	b:SetAttribute("spell2", GetSpellInfo(spell[2]))
end
f:Hide()

local b = CreateFrame("Button", nil, UIParent)
b:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
b:SetWidth(30)
b:SetHeight(12)
b:SetAlpha(0.1)

local bt = b:CreateFontString(nil, 'OVERLAY')
bt:SetFont(C["font"].basic_font, C["font"].basic_font_size, C["font"].basic_font_style)
bt:SetText("TM")
bt:SetTextColor(K.Color.r, K.Color.g, K.Color.b)
bt:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 1, -1)

b:SetScript("OnClick", function(self)
	if _G["TeleportMenu"]:IsShown() then
		_G["TeleportMenu"]:Hide()
	else
		_G["TeleportMenuReagentText"]:SetText(MINIMAP_TRACKING_VENDOR_REAGENT..": [ "..GetItemCount(17031).." ] | [ "..GetItemCount(17032).." ]")
		_G["TeleportMenu"]:Show()
	end
end)

b:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	b:FadeIn()
	GameTooltip:SetOwner(b, "ANCHOR_BOTTOMLEFT")
	GameTooltip:SetText("Toggles TeleportMenu")
end)

b:SetScript("OnLeave", function()
	b:FadeOut()
	GameTooltip:Hide()
end)

f:RegisterEvent("UNIT_SPELLCAST_START")
f:SetScript("OnEvent", function(self)
	if self:IsShown() then
		self:Hide()
	end
end)