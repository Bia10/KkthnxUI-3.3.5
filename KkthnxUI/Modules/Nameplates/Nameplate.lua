local K, C, L = unpack(select(2, ...));
if C["nameplate"].enable ~= true then return end

local showhealth = false -- Display health on nameplates, disabling this will make the nameplate thinner automatically
local enhancethreat = false --[[ Color health by color, good color is nonthreat mobs if your a dps/healer, good color is threat mobs if your a tank. 
If this is false, the border will change red with threat, yellow with high/losing threat, gray otherwise]]
local combat = false -- Only show nameplates in combat
local classicons = true --Display class icons above class nameplates

local TEXTURE = [=[Interface\AddOns\KkthnxUI\Media\Textures\KkthnxTex]=]
local FONT = [=[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]=]
local blankTex = [=[Interface\AddOns\KkthnxUI\Media\Textures\Blank]=]
local FONTSIZE = 11
local FONTFLAG = "THINOUTLINE"
local hpHeight = 12
local hpWidth = 100
local iconSize = 26	--Size of all Icons, RaidIcon/ClassIcon/Castbar Icon
local cbHeight = 5
local cbWidth = 100
local goodcolor = {75/255, 175/255, 76/255}
local badcolor = {0.78, 0.25, 0.25}
local transitioncolor = {218/255, 197/255, 92/255} --High Threat, Losing Threat color
local hostilecolor = {0.78, 0.25, 0.25}
local friendlyplayercolor = {75/255, 175/255, 76/255}
local neutralcolor = {218/255, 197/255, 92/255}
local friendlynpccolor = {0.31, 0.45, 0.63}

--Dont Touch
local numChildren = -1
local frames = {}

--Change defaults if we are showing health text or not
if showhealth ~= true then
	hpHeight = 8
	iconSize = 20
end

local NamePlates = CreateFrame("Frame", nil, UIParent)
NamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
if C.nameplate.trackauras == true then
	NamePlates:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end
SetCVar("ShowClassColorInNameplate", 1)
SetCVar("showVKeyCastbar", 1)

local Abbrev = function(name)
	local newname = (string.len(name) > 18) and string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.UTF(newname, 18, false)
end

-- Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	if event == "UNIT_AURA" and unit ~= "player" then return end
	if (K.Class == "PALADIN" and UnitBuff("player", GetSpellInfo(25780))) and GetCombatRatingBonus(CR_DEFENSE_SKILL) > 100 or 
	(K.Class == "WARRIOR" and GetBonusBarOffset() == 2) or 
	(K.Class == "DEATHKNIGHT" and UnitBuff("player", GetSpellInfo(48263))) or
	(K.Class == "DRUID" and GetBonusBarOffset() == 3) then
		K.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;
		
		if ((playerap > playerint) or (playeragi > playerint)) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139))) then
			K.Role = "Melee"
		else
			K.Role = "Caster"
		end
	end
	
	-- Unregister useless events
	if event == "PLAYER_ENTERING_WORLD" then
		if K.Class ~= "WARRIOR" and K.Class ~= "DRUID" then
			RoleUpdater:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")	
		end
		RoleUpdater:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end	
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

local function QueueObject(parent, object)
	parent.queue = parent.queue or {}
	parent.queue[object] = true
end

local function HideObjects(parent)
	for object in pairs(parent.queue) do
		if object:GetObjectType() == "Texture" then
			object:SetTexture(nil)
			object.SetTexture = K.Dummy
		elseif object:GetObjectType() == "FontString" then
			object.ClearAllPoints = K.Dummy
			object.SetFont = K.Dummy
			object.SetPoint = K.Dummy
			object:Hide()
			object.Show = K.Dummy
			object.SetText = K.Dummy
			object.SetShadowOffset = K.Dummy
		else
			object:Hide()
			object.Show = K.Dummy
		end
	end
end

-- Create our blacklist for nameplates
local function CheckBlacklist(frame, ...)
	if C.nameplate.nameabbrev == true then return end
	if K.PlateBlacklist[frame.name:GetText()] then
		frame:SetScript("OnUpdate", function() end)
		frame.hp:Hide()
		frame.cb:Hide()
		frame.overlay:Hide()
		frame.hp.oldlevel:Hide()
	end
end

-- When becoming intoxicated blizzard likes to re-show the old level text, this should fix that
local function HideDrunkenText(frame, ...)
	if frame and frame.oldlevel and frame.oldlevel:IsShown() then
		frame.oldlevel:Hide()
	end
end

local function AdjustNameLevel(frame, ...)
	if UnitName("target") == frame.name:GetText() and frame:GetAlpha() == 1 then
		frame.name:SetDrawLayer("OVERLAY")
	else
		frame.name:SetDrawLayer("BORDER")
	end
end

-- Create aura icons
local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame", nil, parent)
	button:SetWidth(C.nameplate.aurassize)
	button:SetHeight(C.nameplate.aurassize)
	
	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetTexture(0.05, 0.05, 0.05, 0.6)
	button.bg:SetAllPoints(button)
	
	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", K.noscalemult * 3, -K.noscalemult * 3)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -K.noscalemult * 3, K.noscalemult * 3)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	button.cd = CreateFrame("Cooldown", nil, button)
	button.cd:SetAllPoints(button)
	button.cd:SetReverse(true)
	
	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * K.noscalemult, C.font.nameplates_font_style)
	button.count:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	
	return button
end

-- Update an aura icon
local function UpdateAuraIcon(button, unit, index, filter)
	local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)
	
	button.icon:SetTexture(icon)
	button.cd:SetCooldown(expirationTime - duration, duration)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	if count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end
	button.cd:SetScript("OnUpdate", function(self)
		if not button.cd.timer then
			self:SetScript("OnUpdate", nil)
			return
		end
		button.cd.timer.text:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * K.noscalemult, C.font.nameplates_font_style)
		button.cd.timer.text:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
	end)
	button:Show()
end

-- Filter auras on nameplate, and determine if we need to update them or not
local function OnAura(frame, unit)
	if not frame.icons or not frame.unit then return end
	local i = 1
	for index = 1, 40 do
		if i > C.nameplate.width / C.nameplate.aurassize then return end
		local match
		local name, _, _, _, _, duration, _, caster, _, _, spellid = UnitAura(frame.unit, index, "HARMFUL")
		
		if C.nameplate.trackauras == true then
			if K.DebuffWhiteList[name] and caster == "player" then match = true end
		end
		
		if duration and match == true then
			if not frame.icons[i] then frame.icons[i] = CreateAuraIcon(frame) end
			local icon = frame.icons[i]
			if i == 1 then icon:SetPoint("LEFT", frame.icons, "LEFT") end
			if i ~= 1 and i <= C.nameplate.width / C.nameplate.aurassize then icon:SetPoint("LEFT", frame.icons[i-1], "RIGHT", 2, 0) end
			i = i + 1
			UpdateAuraIcon(icon, frame.unit, index, "HARMFUL")
		end
	end
	for index = i, #frame.icons do frame.icons[index]:Hide() end
end

local goodR, goodG, goodB = unpack(goodcolor)
local badR, badG, badB = unpack(badcolor)
local transitionR, transitionG, transitionB = unpack(transitioncolor)
local function UpdateThreat(frame, elapsed)
	frame.hp:Show()
	
	if enhancethreat ~= true then
		if(frame.region:IsShown()) then
			local _, val = frame.region:GetVertexColor()
			if(val > 0.7) then
				frame.healthbarbackdrop_tex:SetTexture(transitionR, transitionG, transitionB)
			else
				frame.healthbarbackdrop_tex:SetTexture(badR, badG, badB)
			end
		else
			frame.healthbarbackdrop_tex:SetTexture(0.05, 0.05, 0.05, 0.6)
		end
	else
		if not frame.region:IsShown() then
			if InCombatLockdown() and frame.hasclass ~= true and frame.isFriendly ~= true then
				--No Threat
				if Role == "Tank" then
					frame.hp:SetStatusBarColor(badR, badG, badB)
					frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				else
					frame.hp:SetStatusBarColor(goodR, goodG, goodB)
					frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				end		
			else
				--Set colors to their original, not in combat
				frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
				frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
			end
		else
			--Ok we either have threat or we're losing/gaining it
			local r, g, b = frame.region:GetVertexColor()
			if g + b == 0 then
				--Have Threat
				if Role == "Tank" then
					frame.hp:SetStatusBarColor(goodR, goodG, goodB)
					frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				else
					frame.hp:SetStatusBarColor(badR, badG, badB)
					frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				end
			else
				--Losing/Gaining Threat
				frame.hp:SetStatusBarColor(transitionR, transitionG, transitionB)	
				frame.hp.hpbg:SetTexture(transitionR, transitionG, transitionB, 0.25)
			end
		end
	end
	
	-- show current health value
	local minHealth, maxHealth = frame.healthOriginal:GetMinMaxValues()
	local valueHealth = frame.healthOriginal:GetValue()
	local d =(valueHealth/maxHealth)*100
	
	if showhealth == true then
		frame.hp.value:SetText(K.ShortValue(valueHealth).." - "..(string.format("%d%%", math.floor((valueHealth/maxHealth)*100))))
	end
	
	--Change frame style if the frame is our target or not
	if UnitName("target") == frame.name:GetText() and frame:GetAlpha() == 1 then
		--Targetted Unit
		frame.name:SetTextColor(1, 1, 0)
	else
		--Not Targetted
		frame.name:SetTextColor(1, 1, 1)
	end
	
	--Setup frame shadow to change depending on enemy players health, also setup targetted unit to have white shadow
	if frame.hasclass == true or frame.isFriendly == true then
		if(d <= 50 and d >= 20) then
			frame.healthbarbackdrop_tex:SetTexture(1, 1, 0)
		elseif(d < 20) then
			frame.healthbarbackdrop_tex:SetTexture(1, 0, 0)
		else
			frame.healthbarbackdrop_tex:SetTexture(0.05, 0.05, 0.05, 0.6)
		end
	elseif (frame.hasclass ~= true and frame.isFriendly ~= true) and enhancethreat == true then
		frame.healthbarbackdrop_tex:SetTexture(0.05, 0.05, 0.05, 0.6)
	end
end

local function Colorize(frame)
	local r,g,b = frame.hp:GetStatusBarColor()
	if frame.hasclass == true then frame.isFriendly = false return end
	
	if g+b == 0 then -- hostile
		r,g,b = unpack(hostilecolor)
		frame.isFriendly = false
	elseif r+b == 0 then -- friendly npc
		r,g,b = unpack(friendlynpccolor)
		frame.isFriendly = true
	elseif r+g > 1.95 then -- neutral
		r,g,b = unpack(neutralcolor)
		frame.isFriendly = false
	elseif r+g == 0 then -- friendly player
		r,g,b = unpack(friendlyplayercolor)
		frame.isFriendly = true
	else -- enemy player
		frame.isFriendly = false
	end
	frame.hp:SetStatusBarColor(r,g,b)
end

local function UpdateObjects(frame)
	local frame = frame:GetParent()
	
	local r, g, b = frame.hp:GetStatusBarColor()
	local r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
	local classname = ""
	
	frame.hp:ClearAllPoints()
	frame.hp:SetSize(hpWidth, hpHeight)	
	frame.hp:SetPoint('TOP', frame, 'TOP', 0, -K.noscalemult*3)
	frame.hp:GetStatusBarTexture():SetHorizTile(true)
	
	frame.healthbarbackdrop_tex:ClearAllPoints()
	frame.healthbarbackdrop_tex:SetPoint("TOPLEFT", frame.hp, "TOPLEFT", -K.noscalemult*3, K.noscalemult*3)
	frame.healthbarbackdrop_tex:SetPoint("BOTTOMRIGHT", frame.hp, "BOTTOMRIGHT", K.noscalemult*3, -K.noscalemult*3)
	
	--Class Icons
	for class, color in pairs(RAID_CLASS_COLORS) do
		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
			classname = class
		end
	end
	if (classname) then
		texcoord = CLASS_BUTTONS[classname]
		if texcoord then
			frame.hasclass = true
		else
			texcoord = {0.5, 0.75, 0.5, 0.75}
			frame.hasclass = false
		end
	else
		texcoord = {0.5, 0.75, 0.5, 0.75}
		frame.hasclass = false
	end
	
	if frame.hp.rcolor == 0 and frame.hp.gcolor == 0 and frame.hp.bcolor ~= 0 then
		texcoord = {0.5, 0.75, 0.5, 0.75}
		frame.hasclass = true
	end
	frame.class:SetTexCoord(texcoord[1],texcoord[2],texcoord[3],texcoord[4])
	
	if classicons ~= true then
		frame.class:SetAlpha(0)
	end
	
	--create variable for original colors
	Colorize(frame)
	frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = frame.hp:GetStatusBarColor()
	frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
	
	--Set the name text
	--frame.name:SetText(frame.oldname:GetText())
	
	-- Set the name text
	if C.nameplate.nameabbrev == true and C.nameplate.trackauras ~= true then
		frame.name:SetText(Abbrev(frame.oldname:GetText()))
	else
		frame.name:SetText(frame.oldname:GetText())
	end
	
	--Setup level text
	local level, elite, mylevel = tonumber(frame.oldlevel:GetText()), frame.elite:IsShown(), UnitLevel("player")
	frame.hp.level:ClearAllPoints()
	if showhealth == true then
		frame.hp.level:SetPoint("RIGHT", frame.hp, "RIGHT", 2, 0)
	else
		frame.hp.level:SetPoint("RIGHT", frame.hp, "LEFT", -1, 0)
	end
	
	frame.hp.level:SetTextColor(frame.oldlevel:GetTextColor())
	if frame.boss:IsShown() then
		frame.hp.level:SetText("B")
		frame.hp.level:SetTextColor(0.8, 0.05, 0)
		frame.hp.level:Show()
	elseif not elite and level == mylevel then
		frame.hp.level:Hide()
	else
		frame.hp.level:SetText(level..(elite and "+" or ""))
	end
	
	frame.overlay:ClearAllPoints()
	frame.overlay:SetAllPoints(frame.hp)
	
	-- Aura tracking
	if C.nameplate.trackauras == true then
		if frame.icons then return end
		frame.icons = CreateFrame("Frame", nil, frame)
		frame.icons:SetPoint("BOTTOMLEFT", frame.hp, "TOPLEFT", 0, C.font.nameplates_font_size + 7)
		frame.icons:SetWidth(20 + C.nameplate.width)
		frame.icons:SetHeight(25)
		frame.icons:SetFrameLevel(frame.hp:GetFrameLevel() + 2)
		frame:RegisterEvent("UNIT_AURA")
		frame:HookScript("OnEvent", OnAura)
	end
	
	HideObjects(frame)
end

local function UpdateCastbar(frame)
	frame:ClearAllPoints()
	frame:SetSize(cbWidth, cbHeight)
	frame:SetPoint('TOP', frame:GetParent().hp, 'BOTTOM', 0, -8)
	frame:GetStatusBarTexture():SetHorizTile(true)
	
	if(not frame.shield:IsShown()) then
		frame:SetStatusBarColor(0.78, 0.25, 0.25, 1)
	end
	
	local frame = frame:GetParent()
	frame.castbarbackdrop_tex:ClearAllPoints()
	frame.castbarbackdrop_tex:SetPoint("TOPLEFT", frame.cb, "TOPLEFT", -K.noscalemult*3, K.noscalemult*3)
	frame.castbarbackdrop_tex:SetPoint("BOTTOMRIGHT", frame.cb, "BOTTOMRIGHT", K.noscalemult*3, -K.noscalemult*3)
end	

-- Determine whether or not the cast is Channelled or a Regular cast so we can grab the proper Cast Name
local function UpdateCastText(frame, curValue)
	local minValue, maxValue = frame:GetMinMaxValues()
	
	if UnitChannelInfo("target") then
		frame.time:SetFormattedText("%.1f ", curValue)
		if C.nameplate.show_castbar_name == true then
			frame.name:SetText(select(1, (UnitChannelInfo("target"))))
		end
	end
	
	if UnitCastingInfo("target") then
		frame.time:SetFormattedText("%.1f ", maxValue - curValue)
		if C.nameplate.show_castbar_name == true then
			frame.name:SetText(select(1, (UnitCastingInfo("target"))))
		end
	end
end

-- Sometimes castbar likes to randomly resize
local OnValueChanged = function(self, curValue)
	UpdateCastText(self, curValue)
	if self.needFix then
		UpdateCastbar(self)
		self.needFix = nil
	end
end

-- Sometimes castbar likes to randomly resize
local OnSizeChanged = function(self)
	self.needFix = true
end


local function OnHide(frame)
	frame.overlay:Hide()
	frame.cb:Hide()
	frame.unit = nil
	frame.guid = nil
	frame.hasclass = nil
	frame.isFriendly = nil
	frame.hp.rcolor = nil
	frame.hp.gcolor = nil
	frame.hp.bcolor = nil
	
	if frame.icons then
		for _, icon in ipairs(frame.icons) do
			icon:Hide()
		end
	end
	
	frame:SetScript("OnUpdate", nil)
end

local function SkinObjects(frame)
	local hp, cb = frame:GetChildren()
	local threat, hpborder, cbshield, cbborder, cbicon, overlay, oldname, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
	frame.healthOriginal = hp
	
	--Just make sure these are correct
	hp:SetFrameLevel(9)
	cb:SetFrameLevel(9)
	
	-- Create Cast Icon Backdrop frame
	local healthbarbackdrop_tex = hp:CreateTexture(nil, "BACKGROUND")
	healthbarbackdrop_tex:SetPoint("TOPLEFT", hp, "TOPLEFT", -K.noscalemult*3, K.noscalemult*3)
	healthbarbackdrop_tex:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", K.noscalemult*3, -K.noscalemult*3)
	healthbarbackdrop_tex:SetTexture(0.1, 0.1, 0.1)
	frame.healthbarbackdrop_tex = healthbarbackdrop_tex
	
	hp:SetStatusBarTexture(TEXTURE)
	frame.hp = hp
	
	--Actual Background for the Healthbar
	hp.hpbg = hp:CreateTexture(nil, 'BORDER')
	hp.hpbg:SetAllPoints(hp)
	hp.hpbg:SetTexture(1,1,1,0.25) 
	
	--Create Overlay Highlight
	frame.overlay = overlay
	frame.overlay:SetTexture(1,1,1,0.15)
	frame.overlay:SetAllPoints(hp)
	
	--Create Name
	hp.level = hp:CreateFontString(nil, "OVERLAY")
	hp.level:SetFont(FONT, FONTSIZE, FONTFLAG)
	hp.level:SetTextColor(1, 1, 1)
	hp.level:SetShadowOffset(K.mult, -K.mult)
	
	--Needed for level text
	frame.oldlevel = oldlevel
	frame.boss = bossicon
	frame.elite = elite
	
	--Create Health Text
	if C.nameplate.health_value == true then
		hp.value = hp:CreateFontString(nil, "OVERLAY")	
		hp.value:SetFont(FONT, FONTSIZE, FONTFLAG)
		hp.value:SetPoint("CENTER", hp)
		hp.value:SetTextColor(1,1,1)
		hp.value:SetShadowOffset(K.mult, -K.mult)
	end
	
	-- Create Cast Bar Backdrop frame
	local castbarbackdrop_tex = cb:CreateTexture(nil, "BACKGROUND")
	castbarbackdrop_tex:SetPoint("TOPLEFT", cb, "TOPLEFT", -K.noscalemult*3, K.noscalemult*3)
	castbarbackdrop_tex:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", K.noscalemult*3, -K.noscalemult*3)
	castbarbackdrop_tex:SetTexture(0.1, 0.1, 0.1)
	frame.castbarbackdrop_tex = castbarbackdrop_tex
	
	--Setup CastBar Icon
	cbicon:ClearAllPoints()
	cbicon:SetPoint("TOPLEFT", hp, "TOPRIGHT", 8, 0)		
	cbicon:SetSize(iconSize, iconSize)
	cbicon:SetTexCoord(.07, .93, .07, .93)
	cbicon:SetDrawLayer("OVERLAY")
	
	-- Create Cast Icon Backdrop frame
	local casticonbackdrop_tex = cb:CreateTexture(nil, "BACKGROUND")
	casticonbackdrop_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -K.noscalemult*3, K.noscalemult*3)
	casticonbackdrop_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", K.noscalemult*3, -K.noscalemult*3)
	casticonbackdrop_tex:SetTexture(0.1, 0.1, 0.1)
	
	--Create Health Backdrop Frame
	local casticonbackdrop2_tex = cb:CreateTexture(nil, "ARTWORK")
	casticonbackdrop2_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -K.noscalemult, K.noscalemult)
	casticonbackdrop2_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", K.noscalemult, -K.noscalemult)
	casticonbackdrop2_tex:SetTexture(0.1, 0.1, 0.1)
	
	--Create Cast Time Text
	cb.time = cb:CreateFontString(nil, "ARTWORK")
	cb.time:SetPoint("RIGHT", cb, "LEFT", -1, 0)
	cb.time:SetFont(FONT, FONTSIZE, FONTFLAG)
	cb.time:SetTextColor(1, 1, 1)
	cb.time:SetShadowOffset(K.mult, -K.mult)
	
	--Create Cast Name Text
	cb.name = cb:CreateFontString(nil, "ARTWORK")
	cb.name:SetPoint("TOP", cb, "BOTTOM", 0, -3)
	cb.name:SetFont(FONT, FONTSIZE, FONTFLAG)
	cb.name:SetTextColor(1, 1, 1)
	cb.name:SetShadowOffset(K.mult, -K.mult)
	
	cb.icon = cbicon
	cb.shield = cbshield
	cb:HookScript('OnShow', UpdateCastbar)
	cb:HookScript('OnSizeChanged', OnSizeChanged)
	cb:HookScript('OnValueChanged', OnValueChanged)	
	cb:SetStatusBarTexture(TEXTURE)
	frame.cb = cb
	
	--Create Name Text
	local name = hp:CreateFontString(nil, 'OVERLAY')
	name:SetPoint('BOTTOMLEFT', hp, 'TOPLEFT', -10, 3)
	name:SetPoint('BOTTOMRIGHT', hp, 'TOPRIGHT', 10, 3)
	name:SetFont(FONT, FONTSIZE, FONTFLAG)
	name:SetShadowOffset(K.mult, -K.mult)
	frame.oldname = oldname
	frame.name = name
	
	--Reposition and Resize RaidIcon
	raidicon:ClearAllPoints()
	raidicon:SetPoint("BOTTOM", hp, "TOP", 0, 16)
	raidicon:SetSize(iconSize*1.4, iconSize*1.4)
	frame.raidicon = raidicon
	
	--Create Class Icon
	local cIconTex = hp:CreateTexture(nil, "OVERLAY")
	cIconTex:SetPoint("BOTTOM", hp, "TOP", 0, 16)
	cIconTex:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	cIconTex:SetSize(iconSize, iconSize)
	frame.class = cIconTex
	
	--Hide Old Stuff
	QueueObject(frame, oldlevel)
	QueueObject(frame, threat)
	QueueObject(frame, hpborder)
	QueueObject(frame, cbshield)
	QueueObject(frame, cbborder)
	QueueObject(frame, oldname)
	QueueObject(frame, bossicon)
	QueueObject(frame, elite)
	
	UpdateObjects(hp)
	UpdateCastbar(cb)
	
	frame.hp:HookScript('OnShow', UpdateObjects)
	frame:HookScript('OnHide', OnHide)
	frames[frame] = true
end

-- Scan all visible nameplate for a known unit
local function CheckUnit_Guid(frame, ...)
	if UnitExists("target") and frame:GetAlpha() == 1 and UnitName("target") == frame.name:GetText() then
		frame.guid = UnitGUID("target")
		frame.unit = "target"
		OnAura(frame, "target")
	elseif frame.overlay:IsShown() and UnitExists("mouseover") and UnitName("mouseover") == frame.name:GetText() then
		frame.guid = UnitGUID("mouseover")
		frame.unit = "mouseover"
		OnAura(frame, "mouseover")
	else
		frame.unit = nil
	end
end

-- Attempt to match a nameplate with a GUID from the combat log
local function MatchGUID(frame, destGUID, spellID)
	if not frame.guid then return end
	
	if frame.guid == destGUID then
		for _, icon in ipairs(frame.icons) do
			if icon.spellID == spellID then
				icon:Hide()
			end
		end
	end
end

-- Run a function for all visible nameplates, we use this for the blacklist, to check unitguid, and to hide drunken text
local function ForEachPlate(functionToRun, ...)
	for frame in pairs(frames) do
		if frame:IsShown() then
			functionToRun(frame, ...)
		end
	end
end

local select = select
local function HookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()
		
		if(not frames[frame] and not frame:GetName() and region and region:GetObjectType() == 'Texture' and region:GetTexture() == [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]) then
			SkinObjects(frame)
			frame.region = region
		end
	end
end

CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
	if(WorldFrame:GetNumChildren() ~= numChildren) then
		numChildren = WorldFrame:GetNumChildren()
		HookFrames(WorldFrame:GetChildren())
	end
	
	if self.elapsed and self.elapsed > 0.2 then
		ForEachPlate(UpdateThreat, self.elapsed)
		ForEachPlate(AdjustNameLevel)
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
	
	ForEachPlate(CheckBlacklist)
	ForEachPlate(HideDrunkenText)
	ForEachPlate(CheckUnit_Guid)
end)

function NamePlates:COMBAT_LOG_EVENT_UNFILTERED(_, event, ...)
	if event == "SPELL_AURA_REMOVED" then
		local _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = ...
		
		if sourceGUID == UnitGUID("player") then
			ForEachPlate(MatchGUID, destGUID, spellID)
		end
	end
end

-- Only show nameplates when in combat
if C.nameplate.combat == true then
	NamePlates:RegisterEvent("PLAYER_REGEN_ENABLED")
	NamePlates:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	function NamePlates:PLAYER_REGEN_ENABLED()
		SetCVar("nameplateShowEnemies", 0)
	end
	
	function NamePlates:PLAYER_REGEN_DISABLED()
		SetCVar("nameplateShowEnemies", 1)
	end
end

NamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
function NamePlates:PLAYER_ENTERING_WORLD()
	if C.nameplate.combat == true then
		if InCombatLockdown() then
			SetCVar("nameplateShowEnemies", 1)
		else
			SetCVar("nameplateShowEnemies", 0)
		end
	end
	
	if C.nameplate.enable == true and C.nameplate.enhance_threat == true then
		SetCVar("threatWarning", 3)
	end
end