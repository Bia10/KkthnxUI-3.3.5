local K, C, L, _ = unpack(select(2, ...))

local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local UIParent = UIParent
local GetRuneCooldown = GetRuneCooldown
local GetTime = GetTime
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHasVehicleUI = UnitHasVehicleUI

if (K.Class == 'DEATHKNIGHT' and C["powerbar"].hide_blizzard_runebar) then
	for i = 1, 6 do
		RuneFrame:UnregisterAllEvents()
		_G['RuneButtonIndividual'..i]:Hide()
	end
end

if C["powerbar"].enable ~= true then return end

local PowerBarAnchor = CreateFrame("Frame", "PowerBarAnchor", UIParent)
PowerBarAnchor:SetSize(C["powerbar"].width, 24)
if not InCombatLockdown() then
	PowerBarAnchor:SetPoint(unpack(C["position"].powerbar))
end

local f = CreateFrame('Frame', nil, UIParent)
f:SetScale(1.4)
f:SetSize(18, 18)
f:SetPoint("CENTER", PowerBarAnchor, "CENTER", 0, 0)
f:EnableMouse(false)

f:RegisterEvent('PLAYER_REGEN_ENABLED')
f:RegisterEvent('PLAYER_REGEN_DISABLED')
f:RegisterEvent('PLAYER_ENTERING_WORLD')

f:RegisterEvent('UNIT_COMBO_POINTS')
f:RegisterEvent('PLAYER_TARGET_CHANGED')

f:RegisterEvent('RUNE_TYPE_UPDATE')

if (C["powerbar"].show_combo) then
	f.ComboPoints = {}

	for i = 1, 5 do
		f.ComboPoints[i] = f:CreateFontString(nil, 'ARTWORK')

		if (C["powerbar"].font_outline) then
			f.ComboPoints[i]:SetFont(C["font"].powerbar_font, C["font"].powerbar_font_size, C["font"].powerbar_font_style)
			f.ComboPoints[i]:SetShadowOffset(0, 0)
		else
			f.ComboPoints[i]:SetFont(C["font"].powerbar_font, C["font"].powerbar_font_size)
			f.ComboPoints[i]:SetShadowOffset(K.mult, -K.mult)
		end

		f.ComboPoints[i]:SetParent(f)
		f.ComboPoints[i]:SetText(i)
		f.ComboPoints[i]:SetAlpha(0)
	end

	f.ComboPoints[1]:SetPoint('CENTER', -52, 0)
	f.ComboPoints[2]:SetPoint('CENTER', -26, 0)
	f.ComboPoints[3]:SetPoint('CENTER', 0, 0)
	f.ComboPoints[4]:SetPoint('CENTER', 26, 0)
	f.ComboPoints[5]:SetPoint('CENTER', 52, 0)
end

if (K.Class == 'DEATHKNIGHT' and C["powerbar"].show_rune_cooldown) then
	f.Rune = {}

	for i = 1, 6 do
		f.Rune[i] = f:CreateFontString(nil, 'ARTWORK')

		if (C["powerbar"].font_outline) then
			f.Rune[i]:SetFont(C["font"].powerbar_font, C["font"].powerbar_font_size, C["font"].powerbar_font_style)

			f.Rune[i]:SetShadowOffset(0, 0)
		else
			f.Rune[i]:SetFont(C["font"].powerbar_font, C["font"].powerbar_font_size)
			f.Rune[i]:SetShadowOffset(K.mult, -K.mult)
		end

		f.Rune[i]:SetShadowOffset(0, 0)
		f.Rune[i]:SetParent(f)
	end

	f.Rune[1]:SetPoint('CENTER', -65, 0)
	f.Rune[2]:SetPoint('CENTER', -39, 0)
	f.Rune[3]:SetPoint('CENTER', 39, 0)
	f.Rune[4]:SetPoint('CENTER', 65, 0)
	f.Rune[5]:SetPoint('CENTER', -13, 0)
	f.Rune[6]:SetPoint('CENTER', 13, 0)
end

f.Power = CreateFrame('StatusBar', nil, UIParent)
f.Power:SetScale(UIParent:GetScale())
f.Power:SetHeight(K.Scale(6))
f.Power:SetWidth(K.Scale(212))
f.Power:SetPoint('CENTER', f, 0, -23)
f.Power:SetStatusBarTexture(C["media"].texture)
f.Power:SetAlpha(0)

f.Power.Value = f.Power:CreateFontString(nil, 'ARTWORK')

if (C["powerbar"].font_outline) then
	f.Power.Value:SetFont(C["font"].powerbar_font, C["font"].powerbar_font_size, C["font"].powerbar_font_style)
	f.Power.Value:SetShadowOffset(0, 0)
else
	f.Power.Value:SetFont(C["font"].powerbar_font, C["font"].powerbar_font_size)
	f.Power.Value:SetShadowOffset(K.mult, -K.mult)
end

f.Power.Value:SetPoint('CENTER', f.Power, 0, 0)
f.Power.Value:SetVertexColor(1, 1, 1)

f.Power.Background = f.Power:CreateTexture(nil, 'BACKGROUND')
f.Power.Background:SetAllPoints(f.Power)
f.Power.Background:SetTexture(C["media"].blank)
f.Power.Background:SetVertexColor(0.25, 0.25, 0.25, 1)
K.SetShadowBorder(f.Power, 3, 1, 1, 1)

f.Power.Below = f.Power:CreateTexture(nil, 'BACKGROUND')
f.Power.Below:SetHeight(K.Scale(14))
f.Power.Below:SetWidth(K.Scale(14))
f.Power.Below:SetTexture('Interface\\AddOns\\KkthnxUI\\Media\\PowerBar\\textureArrowBelow')

f.Power.Above = f.Power:CreateTexture(nil, 'BACKGROUND')
f.Power.Above:SetHeight(K.Scale(14))
f.Power.Above:SetWidth(K.Scale(14))
f.Power.Above:SetTexture('Interface\\AddOns\\KkthnxUI\\Media\\PowerBar\\textureArrowAbove')

local function SetComboColor(i)
	local comboPoints = GetComboPoints('player', 'target') or 0

	if (i > comboPoints or UnitIsDeadOrGhost('target')) then
		return 1, 1, 1
	else
		return K.ComboColor[i].r, K.ComboColor[i].g, K.ComboColor[i].b
	end
end

local function SetComboAlpha(i)
	local comboPoints = GetComboPoints('player', 'target') or 0

	if (i == comboPoints) then
		return 1
	else
		return 0
	end
end

local function CalcRuneCooldown(self)
	local start, duration, runeReady = GetRuneCooldown(self)
	local time = floor(GetTime() - start)
	local cooldown = ceil(duration - time)

	if (runeReady or UnitIsDeadOrGhost('player')) then
		return '#'
	elseif (not UnitIsDeadOrGhost('player') and cooldown) then
		return cooldown
	end
end

local function SetRuneColor(i)
	if (f.Rune[i].type == 4) then
		return 1, 0, 1
	else
		return K.RuneColor[i].r, K.RuneColor[i].g, K.RuneColor[i].b
	end
end

local function UpdateBarVisibility()
	local _, powerType = UnitPowerType('player')

	if ((not C["powerbar"].enable and powerType == 'ENERGY') or (not C["powerbar"].show_rage and powerType == 'RAGE') or (not C["powerbar"].show_mana and powerType == 'MANA') or (not C["powerbar"].show_rune and powerType == 'RUNEPOWER') or UnitIsDeadOrGhost('player') or UnitHasVehicleUI('player')) then
		f.Power:SetAlpha(0)
	elseif (InCombatLockdown()) then
		securecall('UIFrameFadeIn', f.Power, 0.3, f.Power:GetAlpha(), 1)
	elseif (not InCombatLockdown() and UnitPower('player') > 0) then
		securecall('UIFrameFadeOut', f.Power, 0.3, f.Power:GetAlpha(), 0.4)
	else
		securecall('UIFrameFadeOut', f.Power, 0.3, f.Power:GetAlpha(), 0)
	end
end

local function UpdateArrow()
	if (UnitPower('player') == 0) then
		f.Power.Below:SetAlpha(0.3)
		f.Power.Above:SetAlpha(0.3)
	else
		f.Power.Below:SetAlpha(1)
		f.Power.Above:SetAlpha(1)
	end

	local newPosition = UnitPower('player') / UnitPowerMax('player') * f.Power:GetWidth() - 7
	f.Power.Below:SetPoint('LEFT', f.Power, 'LEFT', newPosition, (K.Scale(-10)))
	f.Power.Above:SetPoint('LEFT', f.Power, 'LEFT', newPosition, (K.Scale(10)))
end

local function UpdateBarValue()
	f.Power:SetMinMaxValues(0, UnitPowerMax('player', f))
	f.Power:SetValue(UnitPower('player'))

	local curValue = UnitPower('player')
	if (C["powerbar"].value_abbrev) then
		f.Power.Value:SetText(UnitPower('player') > 0 and K.ShortValue(curValue) or '')
	else
		f.Power.Value:SetText(UnitPower('player') > 0 and curValue or '')
	end
end

local function UpdateBarColor()
	local _, powerType, altR, altG, altB = UnitPowerType('player')
	local unitPower = PowerBarColor[powerType]

	if (unitPower) then
		f.Power:SetStatusBarColor(unitPower.r, unitPower.g, unitPower.b)
	else
		f.Power:SetStatusBarColor(altR, altG, altB)
	end
end

local function UpdateBar()
	UpdateBarColor()
	UpdateBarValue()
	UpdateArrow()
end

f:SetScript('OnEvent', function(self, event, arg1)
	if (f.ComboPoints) then
		if (event == 'UNIT_COMBO_POINTS' or event == 'PLAYER_TARGET_CHANGED') then
			for i = 1, 5 do
				f.ComboPoints[i]:SetTextColor(SetComboColor(i))
				f.ComboPoints[i]:SetAlpha(SetComboAlpha(i))
			end
		end
	end

	if (event == 'RUNE_TYPE_UPDATE') then
		f.Rune[arg1].type = GetRuneType(arg1)
	end

	if (event == 'PLAYER_ENTERING_WORLD') then
		if (InCombatLockdown()) then
			securecall('UIFrameFadeIn', f, 0.35, f:GetAlpha(), 1)
		else
			securecall('UIFrameFadeOut', f, 0.35, f:GetAlpha(), 0.4)
		end
	end

	if (event == 'PLAYER_REGEN_DISABLED') then
		securecall('UIFrameFadeIn', f, 0.35, f:GetAlpha(), 1)
	end

	if (event == 'PLAYER_REGEN_ENABLED') then
		securecall('UIFrameFadeOut', f, 0.35, f:GetAlpha(), 0.4)
	end
end)

local updateTimer = 0
f:SetScript('OnUpdate', function(self, elapsed)
	updateTimer = updateTimer + elapsed

	if (updateTimer > 0.1) then
		if (f.Rune) then
			for i = 1, 6 do
				if (UnitHasVehicleUI('player')) then
					if (f.Rune[i]:IsShown()) then
						f.Rune[i]:Hide()
					end
				else
					if (not f.Rune[i]:IsShown()) then
						f.Rune[i]:Show()
					end
				end

				f.Rune[i]:SetText(CalcRuneCooldown(i))
				f.Rune[i]:SetTextColor(SetRuneColor(i))
			end
		end

		UpdateBar()
		UpdateBarVisibility()

		updateTimer = 0
	end
end)